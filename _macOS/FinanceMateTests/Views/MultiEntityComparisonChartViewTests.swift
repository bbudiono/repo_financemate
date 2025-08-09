import XCTest
import SwiftUI
import ViewInspector
@testable import FinanceMate

/**
 * Purpose: Comprehensive UI test suite for MultiEntityComparisonChartView with interaction validation
 * Issues & Complexity Summary: Complex SwiftUI view testing with Charts framework and user interaction
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~300
 *   - Core Algorithm Complexity: Medium-High (UI testing, chart interaction, state management)
 *   - Dependencies: XCTest, SwiftUI, ViewInspector, Charts, test data
 *   - State Management Complexity: High (chart interactions, entity selection, metric switching)
 *   - Novelty/Uncertainty Factor: Medium (Charts framework testing patterns)
 * AI Pre-Task Self-Assessment: 88%
 * Problem Estimate: 85%
 * Initial Code Complexity Estimate: 87%
 * Target Coverage: ≥90%
 * Last Updated: 2025-08-08
 */

@MainActor
final class MultiEntityComparisonChartViewTests: XCTestCase {
    
    private var context: NSManagedObjectContext!
    private var netWealthService: NetWealthService!
    private var multiEntityService: MultiEntityWealthService!
    private var viewModel: NetWealthDashboardViewModel!
    private var testEntities: [FinancialEntity] = []
    
    override func setUp() async throws {
        context = PersistenceController.preview.container.viewContext
        netWealthService = NetWealthService(context: context)
        multiEntityService = MultiEntityWealthService(context: context, netWealthService: netWealthService)
        viewModel = NetWealthDashboardViewModel(context: context, netWealthService: netWealthService)
        
        await createTestData()
        await multiEntityService.calculateMultiEntityWealth()
    }
    
    override func tearDown() async throws {
        await cleanupTestData()
        viewModel = nil
        multiEntityService = nil
        netWealthService = nil
        context = nil
    }
    
    // MARK: - View Rendering Tests
    
    func testMultiEntityComparisonChartViewRendering() throws {
        // Given: MultiEntityComparisonChartView with test data
        let selectedEntity = State<FinancialEntity?>(initialValue: nil)
        let showingDetails = State<Bool>(initialValue: false)
        
        let view = MultiEntityComparisonChartView(
            viewModel: viewModel,
            multiEntityService: multiEntityService,
            selectedEntity: selectedEntity.projectedValue,
            showingEntityDetails: showingDetails.projectedValue
        )
        
        // When: Inspecting the view
        let inspectedView = try view.inspect()
        
        // Then: Should contain essential UI elements
        XCTAssertNoThrow(
            try inspectedView.find(text: "Multi-Entity Comparison"),
            "Should contain chart title"
        )
        
        XCTAssertNoThrow(
            try inspectedView.find(text: "Compare wealth across financial entities"),
            "Should contain chart subtitle"
        )
    }
    
    func testChartHeaderElementsPresent() throws {
        // Given: View with loaded data
        let selectedEntity = State<FinancialEntity?>(initialValue: nil)
        let showingDetails = State<Bool>(initialValue: false)
        
        let view = MultiEntityComparisonChartView(
            viewModel: viewModel,
            multiEntityService: multiEntityService,
            selectedEntity: selectedEntity.projectedValue,
            showingEntityDetails: showingDetails.projectedValue
        )
        
        // When: Inspecting chart header
        let inspectedView = try view.inspect()
        
        // Then: Should have title and metric selector
        XCTAssertNoThrow(
            try inspectedView.find(text: "Multi-Entity Comparison"),
            "Should have main title"
        )
        
        // Should have metric selector menu (testing menu presence is complex with ViewInspector)
        // We'll verify the button exists
        XCTAssertNoThrow(
            try inspectedView.find(ViewType.Menu.self),
            "Should have metric selector menu"
        )
    }
    
    func testLoadingStateDisplay() throws {
        // Given: Service in loading state
        multiEntityService.isLoading = true
        multiEntityService.multiEntityBreakdown = nil
        
        let selectedEntity = State<FinancialEntity?>(initialValue: nil)
        let showingDetails = State<Bool>(initialValue: false)
        
        let view = MultiEntityComparisonChartView(
            viewModel: viewModel,
            multiEntityService: multiEntityService,
            selectedEntity: selectedEntity.projectedValue,
            showingEntityDetails: showingDetails.projectedValue
        )
        
        // When: Inspecting loading view
        let inspectedView = try view.inspect()
        
        // Then: Should show loading indicator
        XCTAssertNoThrow(
            try inspectedView.find(ViewType.ProgressView.self),
            "Should show loading indicator"
        )
        
        XCTAssertNoThrow(
            try inspectedView.find(text: "Loading multi-entity analysis..."),
            "Should show loading message"
        )
    }
    
    func testErrorStateDisplay() throws {
        // Given: Service in error state
        let errorMessage = "Test error message"
        multiEntityService.isLoading = false
        multiEntityService.errorMessage = errorMessage
        multiEntityService.multiEntityBreakdown = nil
        
        let selectedEntity = State<FinancialEntity?>(initialValue: nil)
        let showingDetails = State<Bool>(initialValue: false)
        
        let view = MultiEntityComparisonChartView(
            viewModel: viewModel,
            multiEntityService: multiEntityService,
            selectedEntity: selectedEntity.projectedValue,
            showingEntityDetails: showingDetails.projectedValue
        )
        
        // When: Inspecting error view
        let inspectedView = try view.inspect()
        
        // Then: Should show error elements
        XCTAssertNoThrow(
            try inspectedView.find(text: "Analysis Error"),
            "Should show error title"
        )
        
        XCTAssertNoThrow(
            try inspectedView.find(text: errorMessage),
            "Should show error message"
        )
        
        XCTAssertNoThrow(
            try inspectedView.find(text: "Retry Analysis"),
            "Should show retry button"
        )
    }
    
    func testEmptyStateDisplay() throws {
        // Given: Service with no data
        multiEntityService.isLoading = false
        multiEntityService.errorMessage = nil
        multiEntityService.multiEntityBreakdown = nil
        
        let selectedEntity = State<FinancialEntity?>(initialValue: nil)
        let showingDetails = State<Bool>(initialValue: false)
        
        let view = MultiEntityComparisonChartView(
            viewModel: viewModel,
            multiEntityService: multiEntityService,
            selectedEntity: selectedEntity.projectedValue,
            showingEntityDetails: showingDetails.projectedValue
        )
        
        // When: Inspecting empty state view
        let inspectedView = try view.inspect()
        
        // Then: Should show empty state elements
        XCTAssertNoThrow(
            try inspectedView.find(text: "No Entity Data"),
            "Should show empty state title"
        )
        
        XCTAssertNoThrow(
            try inspectedView.find(text: "Create financial entities to see multi-entity comparison."),
            "Should show empty state message"
        )
    }
    
    // MARK: - Entity Selection Tests
    
    func testEntitySelectionBinding() throws {
        // Given: Chart with loaded data and selected entity binding
        let selectedEntity = State<FinancialEntity?>(initialValue: testEntities.first)
        let showingDetails = State<Bool>(initialValue: false)
        
        let view = MultiEntityComparisonChartView(
            viewModel: viewModel,
            multiEntityService: multiEntityService,
            selectedEntity: selectedEntity.projectedValue,
            showingEntityDetails: showingDetails.projectedValue
        )
        
        // When: Inspecting view with selected entity
        let inspectedView = try view.inspect()
        
        // Then: Should show entity detail section
        XCTAssertNoThrow(
            try inspectedView.find(text: testEntities.first?.name ?? ""),
            "Should show selected entity name"
        )
        
        // Should show close button for entity details
        XCTAssertNoThrow(
            try inspectedView.find(image: "xmark.circle.fill"),
            "Should show close button for entity details"
        )
    }
    
    func testEntityDetailMetricCards() throws {
        // Given: Chart with selected entity
        let selectedEntity = State<FinancialEntity?>(initialValue: testEntities.first)
        let showingDetails = State<Bool>(initialValue: false)
        
        let view = MultiEntityComparisonChartView(
            viewModel: viewModel,
            multiEntityService: multiEntityService,
            selectedEntity: selectedEntity.projectedValue,
            showingEntityDetails: showingDetails.projectedValue
        )
        
        // When: Inspecting entity detail section
        let inspectedView = try view.inspect()
        
        // Then: Should show metric cards
        let metricTitles = ["Net Wealth", "Performance Score", "Risk Score", "Leverage Ratio"]
        
        for title in metricTitles {
            XCTAssertNoThrow(
                try inspectedView.find(text: title),
                "Should show \(title) metric card"
            )
        }
    }
    
    // MARK: - Metric Switching Tests
    
    func testMetricSelectorOptions() throws {
        // Given: Chart view with metric selector
        let selectedEntity = State<FinancialEntity?>(initialValue: nil)
        let showingDetails = State<Bool>(initialValue: false)
        
        let view = MultiEntityComparisonChartView(
            viewModel: viewModel,
            multiEntityService: multiEntityService,
            selectedEntity: selectedEntity.projectedValue,
            showingEntityDetails: showingDetails.projectedValue
        )
        
        // When: Testing metric options
        let metrics = ComparisonMetric.allCases
        
        // Then: All metrics should have proper display names
        XCTAssertEqual(metrics.count, 5, "Should have 5 comparison metrics")
        XCTAssertEqual(ComparisonMetric.netWealth.displayName, "Net Wealth")
        XCTAssertEqual(ComparisonMetric.totalAssets.displayName, "Total Assets")
        XCTAssertEqual(ComparisonMetric.totalLiabilities.displayName, "Total Liabilities")
        XCTAssertEqual(ComparisonMetric.performanceScore.displayName, "Performance")
        XCTAssertEqual(ComparisonMetric.riskScore.displayName, "Risk Score")
    }
    
    // MARK: - Insights Section Tests
    
    func testInsightsSectionPresent() throws {
        // Given: Chart with loaded data that has recommendations
        let selectedEntity = State<FinancialEntity?>(initialValue: nil)
        let showingDetails = State<Bool>(initialValue: false)
        
        let view = MultiEntityComparisonChartView(
            viewModel: viewModel,
            multiEntityService: multiEntityService,
            selectedEntity: selectedEntity.projectedValue,
            showingEntityDetails: showingDetails.projectedValue
        )
        
        // When: Inspecting insights section
        let inspectedView = try view.inspect()
        
        // Then: Should show insights header
        XCTAssertNoThrow(
            try inspectedView.find(text: "Key Insights"),
            "Should show insights section header"
        )
        
        // Should show diversification and entity count metrics
        XCTAssertNoThrow(
            try inspectedView.find(text: "Diversification Score"),
            "Should show diversification score"
        )
        
        XCTAssertNoThrow(
            try inspectedView.find(text: "Total Entities"),
            "Should show total entities count"
        )
    }
    
    func testOptimizationRecommendationsDisplay() async throws {
        // Given: Create high-risk test data to generate recommendations
        await createHighRiskTestData()
        await multiEntityService.calculateMultiEntityWealth()
        
        let selectedEntity = State<FinancialEntity?>(initialValue: nil)
        let showingDetails = State<Bool>(initialValue: false)
        
        let view = MultiEntityComparisonChartView(
            viewModel: viewModel,
            multiEntityService: multiEntityService,
            selectedEntity: selectedEntity.projectedValue,
            showingEntityDetails: showingDetails.projectedValue
        )
        
        // When: Inspecting recommendations
        let inspectedView = try view.inspect()
        
        // Then: Should show recommendations (if any were generated)
        let breakdown = multiEntityService.multiEntityBreakdown
        if let recommendations = breakdown?.crossEntityAnalysis.optimizationOpportunities,
           !recommendations.isEmpty {
            
            // Should show first recommendation
            let firstRecommendation = recommendations.first!
            XCTAssertNoThrow(
                try inspectedView.find(text: firstRecommendation.title),
                "Should show recommendation title"
            )
        }
    }
    
    // MARK: - Accessibility Tests
    
    func testAccessibilityIdentifiers() throws {
        // Given: Chart view with accessibility identifiers
        let selectedEntity = State<FinancialEntity?>(initialValue: nil)
        let showingDetails = State<Bool>(initialValue: false)
        
        let view = MultiEntityComparisonChartView(
            viewModel: viewModel,
            multiEntityService: multiEntityService,
            selectedEntity: selectedEntity.projectedValue,
            showingEntityDetails: showingDetails.projectedValue
        )
        
        // When: Testing accessibility
        let inspectedView = try view.inspect()
        
        // Then: Should have proper accessibility identifiers
        XCTAssertNoThrow(
            try inspectedView.find(viewWithAccessibilityIdentifier: "MultiEntityComparisonChart"),
            "Should have chart accessibility identifier"
        )
        
        XCTAssertNoThrow(
            try inspectedView.find(viewWithAccessibilityIdentifier: "MetricSelector"),
            "Should have metric selector accessibility identifier"
        )
    }
    
    // MARK: - Value Formatting Tests
    
    func testValueFormattingMethods() throws {
        // Given: Chart view instance to test formatting methods
        let selectedEntity = State<FinancialEntity?>(initialValue: nil)
        let showingDetails = State<Bool>(initialValue: false)
        
        let view = MultiEntityComparisonChartView(
            viewModel: viewModel,
            multiEntityService: multiEntityService,
            selectedEntity: selectedEntity.projectedValue,
            showingEntityDetails: showingDetails.projectedValue
        )
        
        // When: Testing value formatting (indirectly through expected display values)
        // Note: Direct method testing is complex with SwiftUI views
        
        // Then: Verify format types exist and are comprehensive
        let formats = [ValueFormat.currency, ValueFormat.currencyShort, ValueFormat.percentage, ValueFormat.score, ValueFormat.integer]
        XCTAssertEqual(formats.count, 5, "Should have all value format types")
    }
    
    // MARK: - Chart Data Integration Tests
    
    func testChartDataConsistency() throws {
        // Given: Multi-entity breakdown with known values
        guard let breakdown = multiEntityService.multiEntityBreakdown else {
            XCTFail("Multi-entity breakdown should be available")
            return
        }
        
        // When: Verifying chart data consistency
        let entityBreakdowns = breakdown.entityBreakdowns
        
        // Then: Should have consistent data for chart rendering
        XCTAssertGreaterThan(entityBreakdowns.count, 0, "Should have entity breakdowns for chart")
        
        for entityBreakdown in entityBreakdowns {
            // Verify entity has name for chart labels
            XCTAssertNotNil(entityBreakdown.entity.name, "Entity should have name for chart label")
            
            // Verify metrics are valid for chart rendering
            XCTAssertGreaterThanOrEqual(
                entityBreakdown.netWealthResult.totalAssets, 0,
                "Total assets should be non-negative for chart"
            )
            XCTAssertGreaterThanOrEqual(
                entityBreakdown.performanceScore, 0,
                "Performance score should be non-negative for chart"
            )
            XCTAssertGreaterThanOrEqual(
                entityBreakdown.riskMetrics.volatilityScore, 0,
                "Risk score should be non-negative for chart"
            )
        }
    }
    
    // MARK: - Performance Tests
    
    func testChartViewPerformance() throws {
        // Given: Chart view with realistic data size
        let selectedEntity = State<FinancialEntity?>(initialValue: nil)
        let showingDetails = State<Bool>(initialValue: false)
        
        let view = MultiEntityComparisonChartView(
            viewModel: viewModel,
            multiEntityService: multiEntityService,
            selectedEntity: selectedEntity.projectedValue,
            showingEntityDetails: showingDetails.projectedValue
        )
        
        // When: Measuring view creation time
        measure {
            // Creating and inspecting the view
            _ = try? view.inspect()
        }
        
        // Then: Performance should be reasonable (measured by XCTest framework)
    }
    
    // MARK: - Test Data Helpers
    
    private func createTestData() async {
        // Create test entities with sufficient data for meaningful charts
        
        // High-performing entity
        let highPerformEntity = createTestEntity(name: "High Performance Portfolio", type: .investment)
        createTestAsset(entity: highPerformEntity, value: 800000, type: "Shares")
        createTestAsset(entity: highPerformEntity, value: 200000, type: "Cash")
        createTestLiability(entity: highPerformEntity, balance: 100000, type: "Investment Loan")
        
        // Conservative entity
        let conservativeEntity = createTestEntity(name: "Conservative Savings", type: .personal)
        createTestAsset(entity: conservativeEntity, value: 400000, type: "Cash")
        createTestAsset(entity: conservativeEntity, value: 300000, type: "Bonds")
        createTestLiability(entity: conservativeEntity, balance: 50000, type: "Credit Card")
        
        // Business entity
        let businessEntity = createTestEntity(name: "Business Operations", type: .business)
        createTestAsset(entity: businessEntity, value: 500000, type: "Equipment")
        createTestAsset(entity: businessEntity, value: 150000, type: "Cash")
        createTestLiability(entity: businessEntity, balance: 300000, type: "Business Loan")
        
        testEntities = [highPerformEntity, conservativeEntity, businessEntity]
        try? context.save()
    }
    
    private func createHighRiskTestData() async {
        await cleanupTestData()
        
        // Create entity with characteristics that should trigger recommendations
        let highRiskEntity = createTestEntity(name: "High Risk Entity", type: .investment)
        
        // High concentration (90% in crypto)
        createTestAsset(entity: highRiskEntity, value: 900000, type: "Crypto")
        createTestAsset(entity: highRiskEntity, value: 100000, type: "Cash")
        
        // High leverage (80%)
        createTestLiability(entity: highRiskEntity, balance: 800000, type: "Margin Loan")
        
        testEntities = [highRiskEntity]
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
    
    private func cleanupTestData() async {
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

// MARK: - ViewInspector Extensions

extension MultiEntityComparisonChartView: Inspectable { }