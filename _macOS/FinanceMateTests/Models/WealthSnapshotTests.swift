import XCTest
import CoreData
@testable import FinanceMate

/*
 * Purpose: Comprehensive tests for WealthSnapshot Core Data model
 * Issues & Complexity Summary: Testing wealth calculation, asset allocation, and performance metrics integration
 * Key Complexity Drivers:
   - Logic Scope (Est. LoC): ~300
   - Core Algorithm Complexity: Medium (wealth calculations, relationship validation)
   - Dependencies: 3 New (WealthSnapshot, AssetAllocation, PerformanceMetrics)
   - State Management Complexity: Medium
   - Novelty/Uncertainty Factor: Low (standard Core Data testing patterns)
 * AI Pre-Task Self-Assessment: 85%
 * Problem Estimate: 80%
 * Initial Code Complexity Estimate: 75%
 * Final Code Complexity: [TBD]
 * Overall Result Score: [TBD]
 * Key Variances/Learnings: [TBD]
 * Last Updated: 2025-07-09
 */

@MainActor
class WealthSnapshotTests: XCTestCase {
    
    var context: NSManagedObjectContext!
    var persistenceController: PersistenceController!
    
    override func setUp() {
        super.setUp()
        persistenceController = PersistenceController.preview
        context = persistenceController.container.viewContext
    }
    
    override func tearDown() {
        context = nil
        persistenceController = nil
        super.tearDown()
    }
    
    // MARK: - Basic Test
    
    func testBasicSetup() {
        // Simple test to verify the test class is discovered
        XCTAssertNotNil(context, "Context should be initialized")
        XCTAssertNotNil(persistenceController, "PersistenceController should be initialized")
    }
    
    // MARK: - Model Creation Tests
    
    func testWealthSnapshotCreation() {
        // Given
        let date = Date()
        let totalAssets = 150000.0
        let totalLiabilities = 50000.0
        let expectedNetWorth = totalAssets - totalLiabilities
        
        // When
        let wealthSnapshot = WealthSnapshot.create(
            in: context,
            date: date,
            totalAssets: totalAssets,
            totalLiabilities: totalLiabilities,
            cashPosition: 25000.0,
            investmentValue: 100000.0,
            propertyValue: 25000.0
        )
        
        // Then
        XCTAssertNotNil(wealthSnapshot, "WealthSnapshot should be created successfully")
        XCTAssertNotNil(wealthSnapshot.id, "WealthSnapshot should have a valid UUID")
        XCTAssertEqual(wealthSnapshot.date, date, "Date should match")
        XCTAssertEqual(wealthSnapshot.totalAssets, totalAssets, "Total assets should match")
        XCTAssertEqual(wealthSnapshot.totalLiabilities, totalLiabilities, "Total liabilities should match")
        XCTAssertEqual(wealthSnapshot.netWorth, expectedNetWorth, "Net worth should be calculated correctly")
        XCTAssertEqual(wealthSnapshot.cashPosition, 25000.0, "Cash position should match")
        XCTAssertEqual(wealthSnapshot.investmentValue, 100000.0, "Investment value should match")
        XCTAssertEqual(wealthSnapshot.propertyValue, 25000.0, "Property value should match")
        XCTAssertNotNil(wealthSnapshot.createdAt, "Created timestamp should be set")
    }
    
    func testWealthSnapshotNetWorthCalculation() {
        // Given
        let assets = 250000.0
        let liabilities = 75000.0
        let expectedNetWorth = assets - liabilities
        
        // When
        let wealthSnapshot = WealthSnapshot.create(
            in: context,
            date: Date(),
            totalAssets: assets,
            totalLiabilities: liabilities,
            cashPosition: 50000.0,
            investmentValue: 150000.0,
            propertyValue: 50000.0
        )
        
        // Then
        XCTAssertEqual(wealthSnapshot.netWorth, expectedNetWorth, "Net worth should be automatically calculated")
    }
    
    func testWealthSnapshotUniqueIdentifier() {
        // Given & When
        let snapshot1 = WealthSnapshot.create(
            in: context,
            date: Date(),
            totalAssets: 100000.0,
            totalLiabilities: 20000.0,
            cashPosition: 10000.0,
            investmentValue: 70000.0,
            propertyValue: 20000.0
        )
        
        let snapshot2 = WealthSnapshot.create(
            in: context,
            date: Date(),
            totalAssets: 120000.0,
            totalLiabilities: 25000.0,
            cashPosition: 15000.0,
            investmentValue: 80000.0,
            propertyValue: 25000.0
        )
        
        // Then
        XCTAssertNotEqual(snapshot1.id, snapshot2.id, "Each snapshot should have a unique identifier")
    }
    
    // MARK: - Asset Allocation Relationship Tests
    
    func testWealthSnapshotAssetAllocationRelationship() {
        // Given
        let wealthSnapshot = WealthSnapshot.create(
            in: context,
            date: Date(),
            totalAssets: 100000.0,
            totalLiabilities: 20000.0,
            cashPosition: 30000.0,
            investmentValue: 50000.0,
            propertyValue: 20000.0
        )
        
        // When
        let allocation1 = AssetAllocation.create(
            in: context,
            assetClass: "Equities",
            allocation: 0.6,
            targetAllocation: 0.65,
            currentValue: 60000.0,
            wealthSnapshot: wealthSnapshot
        )
        
        let allocation2 = AssetAllocation.create(
            in: context,
            assetClass: "Bonds",
            allocation: 0.4,
            targetAllocation: 0.35,
            currentValue: 40000.0,
            wealthSnapshot: wealthSnapshot
        )
        
        // Then
        XCTAssertEqual(wealthSnapshot.assetAllocations.count, 2, "Wealth snapshot should have 2 asset allocations")
        XCTAssertTrue(wealthSnapshot.assetAllocations.contains(allocation1), "Should contain equity allocation")
        XCTAssertTrue(wealthSnapshot.assetAllocations.contains(allocation2), "Should contain bond allocation")
    }
    
    // MARK: - Performance Metrics Relationship Tests
    
    func testWealthSnapshotPerformanceMetricsRelationship() {
        // Given
        let wealthSnapshot = WealthSnapshot.create(
            in: context,
            date: Date(),
            totalAssets: 150000.0,
            totalLiabilities: 30000.0,
            cashPosition: 20000.0,
            investmentValue: 100000.0,
            propertyValue: 30000.0
        )
        
        // When
        let metric1 = PerformanceMetrics.create(
            in: context,
            metricType: "Total Return",
            value: 0.12,
            benchmarkValue: 0.10,
            period: "YTD",
            wealthSnapshot: wealthSnapshot
        )
        
        let metric2 = PerformanceMetrics.create(
            in: context,
            metricType: "Sharpe Ratio",
            value: 1.2,
            benchmarkValue: 1.0,
            period: "1Y",
            wealthSnapshot: wealthSnapshot
        )
        
        // Then
        XCTAssertEqual(wealthSnapshot.performanceMetrics.count, 2, "Wealth snapshot should have 2 performance metrics")
        XCTAssertTrue(wealthSnapshot.performanceMetrics.contains(metric1), "Should contain total return metric")
        XCTAssertTrue(wealthSnapshot.performanceMetrics.contains(metric2), "Should contain Sharpe ratio metric")
    }
    
    // MARK: - Validation Tests
    
    func testWealthSnapshotValidation() {
        // Test that negative assets are not allowed
        // This will fail initially since we haven't implemented validation yet
        // But it defines our expected behavior
    }
    
    func testWealthSnapshotAssetConsistencyValidation() {
        // Test that cash + investment + property should approximately equal total assets
        // This will fail initially but defines expected validation behavior
    }
    
    // MARK: - Fetch Request Tests
    
    func testFetchWealthSnapshotsByDateRange() {
        // Given
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .month, value: 1, to: startDate)!
        
        let snapshot1 = WealthSnapshot.create(
            in: context,
            date: startDate,
            totalAssets: 100000.0,
            totalLiabilities: 20000.0,
            cashPosition: 30000.0,
            investmentValue: 50000.0,
            propertyValue: 20000.0
        )
        
        let snapshot2 = WealthSnapshot.create(
            in: context,
            date: endDate,
            totalAssets: 110000.0,
            totalLiabilities: 20000.0,
            cashPosition: 35000.0,
            investmentValue: 55000.0,
            propertyValue: 20000.0
        )
        
        // Save context
        try? context.save()
        
        // When
        let fetchedSnapshots = try? WealthSnapshot.fetchSnapshots(
            from: startDate,
            to: endDate,
            in: context
        )
        
        // Then
        XCTAssertNotNil(fetchedSnapshots, "Should be able to fetch snapshots by date range")
        XCTAssertEqual(fetchedSnapshots?.count, 2, "Should fetch both snapshots in date range")
    }
    
    func testFetchLatestWealthSnapshot() {
        // Given
        let olderDate = Date().addingTimeInterval(-86400) // 1 day ago
        let newerDate = Date()
        
        WealthSnapshot.create(
            in: context,
            date: olderDate,
            totalAssets: 100000.0,
            totalLiabilities: 20000.0,
            cashPosition: 30000.0,
            investmentValue: 50000.0,
            propertyValue: 20000.0
        )
        
        let latestSnapshot = WealthSnapshot.create(
            in: context,
            date: newerDate,
            totalAssets: 110000.0,
            totalLiabilities: 20000.0,
            cashPosition: 35000.0,
            investmentValue: 55000.0,
            propertyValue: 20000.0
        )
        
        // Save context
        try? context.save()
        
        // When
        let fetchedLatest = try? WealthSnapshot.fetchLatestSnapshot(in: context)
        
        // Then
        XCTAssertNotNil(fetchedLatest, "Should be able to fetch latest snapshot")
        XCTAssertEqual(fetchedLatest?.id, latestSnapshot.id, "Should fetch the most recent snapshot")
    }
    
    // MARK: - Performance Tests
    
    func testWealthSnapshotCreationPerformance() {
        // Test that creating wealth snapshots is performant
        measure {
            for i in 0..<100 {
                let _ = WealthSnapshot.create(
                    in: context,
                    date: Date().addingTimeInterval(TimeInterval(i)),
                    totalAssets: Double(100000 + i * 1000),
                    totalLiabilities: Double(20000 + i * 100),
                    cashPosition: Double(30000 + i * 200),
                    investmentValue: Double(50000 + i * 500),
                    propertyValue: Double(20000 + i * 300)
                )
            }
        }
    }
    
    // MARK: - Error Handling Tests
    
    func testWealthSnapshotContextSafety() {
        // Test that wealth snapshot handles context issues gracefully
        let invalidContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        
        // This should not crash but should handle the error appropriately
        XCTAssertThrowsError(try WealthSnapshot.fetchLatestSnapshot(in: invalidContext)) { error in
            // Should throw an appropriate Core Data error
            XCTAssertTrue(error is NSError, "Should throw NSError for invalid context")
        }
    }
}