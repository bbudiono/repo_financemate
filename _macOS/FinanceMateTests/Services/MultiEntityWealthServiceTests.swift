import XCTest
import CoreData
@testable import FinanceMate

/**
 * Purpose: Comprehensive test suite for MultiEntityWealthService with real data validation
 * Issues & Complexity Summary: Complex service testing with Core Data integration and mock entities
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~400
 *   - Core Algorithm Complexity: High (service integration, async testing, data validation)
 *   - Dependencies: XCTest, Core Data, MultiEntityWealthService, test fixtures
 *   - State Management Complexity: High (async service calls, entity relationships)
 *   - Novelty/Uncertainty Factor: Low (established testing patterns)
 * AI Pre-Task Self-Assessment: 92%
 * Problem Estimate: 90%
 * Initial Code Complexity Estimate: 88%
 * Target Coverage: ≥95%
 * Last Updated: 2025-08-08
 */

final class MultiEntityWealthServiceTests: XCTestCase {
    
    private var context: NSManagedObjectContext!
    private var netWealthService: NetWealthService!
    private var multiEntityService: MultiEntityWealthService!
    private var testEntities: [FinancialEntity] = []
    
    override func setUp() throws {
        context = PersistenceController.preview.container.viewContext
        netWealthService = NetWealthService(context: context)
        multiEntityService = MultiEntityWealthService(context: context, netWealthService: netWealthService)
        
        createTestData()
    }
    
    override func tearDown() throws {
        cleanupTestData()
        multiEntityService = nil
        netWealthService = nil
        context = nil
    }
    
    // MARK: - Multi-Entity Wealth Calculation Tests
    
    func testCalculateMultiEntityWealth() throws {
        // Given: Test entities with assets and liabilities exist
        XCTAssertEqual(testEntities.count, 3, "Should have 3 test entities")
        
        // When: Calculating multi-entity wealth
        multiEntityService.calculateMultiEntityWealth()
        
        // Then: Multi-entity breakdown should be calculated
        XCTAssertNotNil(multiEntityService.multiEntityBreakdown, "Multi-entity breakdown should be calculated")
        XCTAssertFalse(multiEntityService.isLoading, "Loading should be complete")
        XCTAssertNil(multiEntityService.errorMessage, "Should not have error message")
        
        let breakdown = multiEntityService.multiEntityBreakdown!
        XCTAssertEqual(breakdown.entityBreakdowns.count, 3, "Should have breakdowns for all entities")
        XCTAssertTrue(breakdown.consolidatedWealth.netWealth > 0, "Consolidated net wealth should be positive")
        XCTAssertEqual(
            breakdown.consolidatedWealth.totalAssets,
            breakdown.entityBreakdowns.reduce(0) { $0 + $1.netWealthResult.totalAssets },
            accuracy: 0.01,
            "Consolidated assets should equal sum of entity assets"
        )
    }
    
    func testMultiEntityWealthWithEmptyEntities() throws {
        // Given: No entities exist
        cleanupTestData()
        
        // When: Calculating multi-entity wealth
        multiEntityService.calculateMultiEntityWealth()
        
        // Then: Should handle empty case gracefully
        let breakdown = multiEntityService.multiEntityBreakdown!
        XCTAssertEqual(breakdown.entityBreakdowns.count, 0, "Should have no entity breakdowns")
        XCTAssertEqual(breakdown.consolidatedWealth.netWealth, 0, "Consolidated wealth should be zero")
        XCTAssertEqual(breakdown.consolidatedWealth.totalAssets, 0, "Total assets should be zero")
        XCTAssertEqual(breakdown.consolidatedWealth.totalLiabilities, 0, "Total liabilities should be zero")
    }
    
    func testMultiEntityWealthLoadingState() throws {
        // Given: Service is initialized
        XCTAssertFalse(multiEntityService.isLoading, "Should not be loading initially")
        
        // When: Starting calculation (async but checking loading state immediately)
        let task = // Synchronous execution
multiEntityService.calculateMultiEntityWealth()
        
        
        // Give it a moment to start loading
        try Task.sleep(nanoseconds: 1_000_000) // 1ms
        
        // Then: Should show loading state temporarily
        // Note: This might pass quickly depending on test data size
        task.value // Wait for completion
        
        XCTAssertFalse(multiEntityService.isLoading, "Should not be loading after completion")
    }
    
    // MARK: - Cross-Entity Analysis Tests
    
    func testCrossEntityAnalysisCalculation() throws {
        // Given: Test entities with different wealth levels
        multiEntityService.calculateMultiEntityWealth()
        let breakdown = multiEntityService.multiEntityBreakdown!
        
        // When: Examining cross-entity analysis
        let crossEntityAnalysis = breakdown.crossEntityAnalysis
        
        // Then: Analysis should be comprehensive
        XCTAssertEqual(
            crossEntityAnalysis.entityContributions.count,
            testEntities.count,
            "Should have contributions for all entities"
        )
        
        // Verify contribution percentages sum to 100% (within tolerance for positive net wealth)
        let totalContributionPercentage = crossEntityAnalysis.entityContributions
            .reduce(0) { $0 + abs($1.contributionPercentage) }
        
        if crossEntityAnalysis.totalConsolidatedWealth > 0 {
            XCTAssertEqual(
                totalContributionPercentage, 100.0, accuracy: 0.1,
                "Entity contributions should sum to 100%"
            )
        }
        
        // Diversification score should be reasonable
        XCTAssertGreaterThanOrEqual(
            crossEntityAnalysis.diversificationScore, 0,
            "Diversification score should be non-negative"
        )
        XCTAssertLessThanOrEqual(
            crossEntityAnalysis.diversificationScore, 100,
            "Diversification score should not exceed 100"
        )
        
        // Risk distribution should account for all entities
        let totalRiskEntities = crossEntityAnalysis.riskDistribution.lowRisk +
                               crossEntityAnalysis.riskDistribution.mediumRisk +
                               crossEntityAnalysis.riskDistribution.highRisk
        
        XCTAssertEqual(
            totalRiskEntities, testEntities.count,
            "Risk distribution should account for all entities"
        )
    }
    
    func testOptimizationRecommendations() throws {
        // Given: Entities with high risk metrics
        createHighRiskTestData()
        multiEntityService.calculateMultiEntityWealth()
        
        // When: Examining optimization recommendations
        let recommendations = multiEntityService.multiEntityBreakdown?.crossEntityAnalysis.optimizationOpportunities ?? []
        
        // Then: Should generate appropriate recommendations
        XCTAssertGreaterThan(recommendations.count, 0, "Should generate optimization recommendations for high-risk entities")
        
        // Verify recommendation structure
        for recommendation in recommendations {
            XCTAssertFalse(recommendation.title.isEmpty, "Recommendation should have title")
            XCTAssertFalse(recommendation.description.isEmpty, "Recommendation should have description")
            XCTAssertGreaterThanOrEqual(recommendation.potentialImpact, 0, "Potential impact should be non-negative")
            XCTAssertLessThanOrEqual(recommendation.potentialImpact, 100, "Potential impact should be reasonable")
        }
        
        // Recommendations should be sorted by impact
        for i in 0..<(recommendations.count - 1) {
            XCTAssertGreaterThanOrEqual(
                recommendations[i].potentialImpact,
                recommendations[i + 1].potentialImpact,
                "Recommendations should be sorted by impact (descending)"
            )
        }
    }
    
    // MARK: - Performance Metrics Tests
    
    func testPerformanceMetricsCalculation() throws {
        // Given: Test entities exist
        multiEntityService.calculateMultiEntityWealth()
        let breakdown = multiEntityService.multiEntityBreakdown!
        
        // When: Examining performance metrics
        let performanceMetrics = breakdown.performanceMetrics
        
        // Then: Metrics should be calculated for all entities
        XCTAssertEqual(
            performanceMetrics.growthRates.count, testEntities.count,
            "Should have growth rates for all entities"
        )
        XCTAssertEqual(
            performanceMetrics.riskAdjustedReturns.count, testEntities.count,
            "Should have risk-adjusted returns for all entities"
        )
        XCTAssertEqual(
            performanceMetrics.benchmarkComparisons.count, testEntities.count,
            "Should have benchmark comparisons for all entities"
        )
        XCTAssertEqual(
            performanceMetrics.efficiencyMetrics.count, testEntities.count,
            "Should have efficiency metrics for all entities"
        )
        
        // Verify Sharpe ratio calculations are reasonable
        for returnMetric in performanceMetrics.riskAdjustedReturns {
            XCTAssertGreaterThanOrEqual(
                returnMetric.sharpeRatio, -10.0,
                "Sharpe ratio should be reasonable (not extremely negative)"
            )
            XCTAssertLessThanOrEqual(
                returnMetric.sharpeRatio, 10.0,
                "Sharpe ratio should be reasonable (not extremely positive)"
            )
        }
    }
    
    func testBenchmarkComparisons() throws {
        // Given: Test entities with performance scores
        multiEntityService.calculateMultiEntityWealth()
        let breakdown = multiEntityService.multiEntityBreakdown!
        
        // When: Examining benchmark comparisons
        let benchmarkComparisons = breakdown.performanceMetrics.benchmarkComparisons
        
        // Then: All entities should have benchmark comparisons
        for comparison in benchmarkComparisons {
            XCTAssertEqual(comparison.benchmark, "ASX 200", "Should use ASX 200 as benchmark")
            XCTAssertEqual(comparison.benchmarkPerformance, 7.5, "Should use 7.5% as market average")
            XCTAssertEqual(
                comparison.relativePerformance,
                comparison.entityPerformance - comparison.benchmarkPerformance,
                accuracy: 0.01,
                "Relative performance should be calculated correctly"
            )
        }
    }
    
    // MARK: - Entity Risk Metrics Tests
    
    func testEntityRiskMetricsCalculation() throws {
        // Given: Test entities with known risk characteristics
        createDiverseRiskTestData()
        multiEntityService.calculateMultiEntityWealth()
        
        // When: Examining entity risk metrics
        let breakdown = multiEntityService.multiEntityBreakdown!
        
        // Then: Risk metrics should be calculated properly
        for entityBreakdown in breakdown.entityBreakdowns {
            let riskMetrics = entityBreakdown.riskMetrics
            
            // All risk metrics should be within valid ranges
            XCTAssertGreaterThanOrEqual(riskMetrics.concentrationRisk, 0, "Concentration risk should be non-negative")
            XCTAssertLessThanOrEqual(riskMetrics.concentrationRisk, 100, "Concentration risk should not exceed 100%")
            
            XCTAssertGreaterThanOrEqual(riskMetrics.liquidityRisk, 0, "Liquidity risk should be non-negative")
            XCTAssertLessThanOrEqual(riskMetrics.liquidityRisk, 100, "Liquidity risk should not exceed 100%")
            
            XCTAssertGreaterThanOrEqual(riskMetrics.volatilityScore, 0, "Volatility score should be non-negative")
            XCTAssertLessThanOrEqual(riskMetrics.volatilityScore, 100, "Volatility score should not exceed 100")
            
            XCTAssertGreaterThanOrEqual(riskMetrics.leverageRatio, 0, "Leverage ratio should be non-negative")
        }
    }
    
    func testHighConcentrationRiskDetection() throws {
        // Given: Entity with single large asset (high concentration)
        let highConcentrationEntity = createTestEntity(name: "High Concentration Entity", type: .investment)
        
        // Create one very large asset and one small asset
        createTestAsset(entity: highConcentrationEntity, value: 950000, type: "Shares") // 95% of total
        createTestAsset(entity: highConcentrationEntity, value: 50000, type: "Cash") // 5% of total
        
        // When: Calculating multi-entity wealth
        multiEntityService.calculateMultiEntityWealth()
        
        // Then: Should detect high concentration risk
        let entityBreakdown = multiEntityService.multiEntityBreakdown?.entityBreakdowns
            .first { $0.entity == highConcentrationEntity }
        
        XCTAssertNotNil(entityBreakdown, "Should find entity breakdown")
        XCTAssertGreaterThan(
            entityBreakdown!.riskMetrics.concentrationRisk, 90,
            "Should detect high concentration risk (>90%)"
        )
    }
    
    // MARK: - Asset Allocation Tests
    
    func testAssetAllocationCalculation() throws {
        // Given: Entity with diverse assets
        createDiverseAssetTestData()
        multiEntityService.calculateMultiEntityWealth()
        
        // When: Examining asset allocation
        let breakdown = multiEntityService.multiEntityBreakdown!
        let entityBreakdown = breakdown.entityBreakdowns.first!
        
        // Then: Asset allocation should be calculated correctly
        XCTAssertGreaterThan(entityBreakdown.assetAllocation.count, 0, "Should have asset allocation data")
        
        let totalAllocationPercentage = entityBreakdown.assetAllocation
            .reduce(0) { $0 + $1.percentage }
        
        XCTAssertEqual(
            totalAllocationPercentage, 100.0, accuracy: 0.1,
            "Asset allocation percentages should sum to 100%"
        )
        
        // Asset allocation should be sorted by value (descending)
        for i in 0..<(entityBreakdown.assetAllocation.count - 1) {
            XCTAssertGreaterThanOrEqual(
                entityBreakdown.assetAllocation[i].totalValue,
                entityBreakdown.assetAllocation[i + 1].totalValue,
                "Asset allocation should be sorted by value (descending)"
            )
        }
    }
    
    // MARK: - Error Handling Tests
    
    func testErrorHandlingWithInvalidContext() throws {
        // Given: Service with potential Core Data issues
        // Note: This is challenging to test without mocking Core Data failures
        
        // Create an entity but don't save it to create potential inconsistency
        let unsavedEntity = FinancialEntity(context: context)
        unsavedEntity.name = "Unsaved Entity"
        unsavedEntity.entityType = .personal
        unsavedEntity.isActive = true
        // Intentionally not saving to context
        
        // When: Attempting to calculate multi-entity wealth
        multiEntityService.calculateMultiEntityWealth()
        
        // Then: Should handle gracefully (may not find the unsaved entity)
        // The service should still function with saved entities
        XCTAssertNotNil(multiEntityService.multiEntityBreakdown, "Should still create breakdown with valid entities")
    }
    
    // MARK: - Test Data Creation Helpers
    
    private func createTestData() {
        // Create diverse test entities with various wealth levels and risk profiles
        
        // High-net-worth personal entity
        let personalEntity = createTestEntity(name: "Personal Wealth", type: .personal)
        createTestAsset(entity: personalEntity, value: 500000, type: "Cash")
        createTestAsset(entity: personalEntity, value: 750000, type: "Shares")
        createTestAsset(entity: personalEntity, value: 1200000, type: "Property")
        createTestLiability(entity: personalEntity, balance: 450000, type: "Mortgage")
        
        // Business entity with moderate wealth
        let businessEntity = createTestEntity(name: "Business Operations", type: .business)
        createTestAsset(entity: businessEntity, value: 300000, type: "Cash")
        createTestAsset(entity: businessEntity, value: 200000, type: "Equipment")
        createTestLiability(entity: businessEntity, balance: 150000, type: "Business Loan")
        
        // Investment entity with growth focus
        let investmentEntity = createTestEntity(name: "Investment Portfolio", type: .investment)
        createTestAsset(entity: investmentEntity, value: 800000, type: "Shares")
        createTestAsset(entity: investmentEntity, value: 200000, type: "Crypto")
        createTestAsset(entity: investmentEntity, value: 100000, type: "Bonds")
        
        testEntities = [personalEntity, businessEntity, investmentEntity]
        
        // Save context
        try? context.save()
    }
    
    private func createHighRiskTestData() {
        cleanupTestData()
        
        // Create entity with high leverage ratio
        let highLeverageEntity = createTestEntity(name: "High Leverage Entity", type: .business)
        createTestAsset(entity: highLeverageEntity, value: 100000, type: "Equipment")
        createTestLiability(entity: highLeverageEntity, balance: 90000, type: "Business Loan") // 90% leverage
        
        testEntities = [highLeverageEntity]
        try? context.save()
    }
    
    private func createDiverseRiskTestData() {
        cleanupTestData()
        
        // Low risk entity (high cash, low leverage)
        let lowRiskEntity = createTestEntity(name: "Conservative Entity", type: .personal)
        createTestAsset(entity: lowRiskEntity, value: 800000, type: "Cash")
        createTestAsset(entity: lowRiskEntity, value: 200000, type: "Bonds")
        createTestLiability(entity: lowRiskEntity, balance: 100000, type: "Mortgage") // 10% leverage
        
        // High risk entity (concentrated assets, high leverage)
        let highRiskEntity = createTestEntity(name: "Aggressive Entity", type: .investment)
        createTestAsset(entity: highRiskEntity, value: 900000, type: "Crypto") // 90% concentration
        createTestAsset(entity: highRiskEntity, value: 100000, type: "Cash")
        createTestLiability(entity: highRiskEntity, balance: 700000, type: "Margin Loan") // 70% leverage
        
        testEntities = [lowRiskEntity, highRiskEntity]
        try? context.save()
    }
    
    private func createDiverseAssetTestData() {
        cleanupTestData()
        
        let diverseEntity = createTestEntity(name: "Diverse Portfolio", type: .investment)
        createTestAsset(entity: diverseEntity, value: 200000, type: "Cash")
        createTestAsset(entity: diverseEntity, value: 300000, type: "Shares")
        createTestAsset(entity: diverseEntity, value: 150000, type: "Bonds")
        createTestAsset(entity: diverseEntity, value: 100000, type: "Property")
        createTestAsset(entity: diverseEntity, value: 50000, type: "Crypto")
        
        testEntities = [diverseEntity]
        try? context.save()
    }
    
    private func createTestEntity(name: String, type: FinancialEntityType) -> FinancialEntity {
        let entity = FinancialEntity(context: context)
        entity.name = name
        entity.entityType = type
        entity.isActive = true
        entity.createdAt = Date()
        return entity
    }
    
    private func createTestAsset(entity: FinancialEntity, value: Double, type: String) {
        let asset = Asset(context: context)
        asset.name = "\(type) Asset"
        asset.assetDescription = "Test asset for \(entity.name ?? "entity")"
        asset.currentValue = value
        asset.assetType = type
        asset.financialEntity = entity
        asset.createdAt = Date()
    }
    
    private func createTestLiability(entity: FinancialEntity, balance: Double, type: String) {
        let liability = Liability(context: context)
        liability.name = "\(type) Liability"
        liability.liabilityDescription = "Test liability for \(entity.name ?? "entity")"
        liability.currentBalance = balance
        liability.liabilityType = type
        liability.financialEntity = entity
        liability.createdAt = Date()
    }
    
    private func cleanupTestData() {
        // Delete all test entities, assets, and liabilities
        let entityRequest: NSFetchRequest<NSFetchRequestResult> = FinancialEntity.fetchRequest()
        let entityDeleteRequest = NSBatchDeleteRequest(fetchRequest: entityRequest)
        try? context.execute(entityDeleteRequest)
        
        let assetRequest: NSFetchRequest<NSFetchRequestResult> = Asset.fetchRequest()
        let assetDeleteRequest = NSBatchDeleteRequest(fetchRequest: assetRequest)
        try? context.execute(assetDeleteRequest)
        
        let liabilityRequest: NSFetchRequest<NSFetchRequestResult> = Liability.fetchRequest()
        let liabilityDeleteRequest = NSBatchDeleteRequest(fetchRequest: liabilityRequest)
        try? context.execute(liabilityDeleteRequest)
        
        testEntities.removeAll()
        try? context.save()
    }
}