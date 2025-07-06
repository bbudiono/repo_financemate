//
// AnalyticsEngineTests.swift
// FinanceMateTests
//
// Advanced Analytics Engine Test Suite for Line Item Splitting System
// Created: 2025-07-07
// Target: FinanceMateTests
//

/*
 * Purpose: Comprehensive test suite for AnalyticsEngine split-based financial analytics
 * Issues & Complexity Summary: Complex aggregation algorithms, time-based analysis, performance optimization
 * Key Complexity Drivers:
   - Logic Scope (Est. LoC): ~350
   - Core Algorithm Complexity: High
   - Dependencies: Core Data, LineItem/SplitAllocation entities
   - State Management Complexity: High
   - Novelty/Uncertainty Factor: Medium
 * AI Pre-Task Self-Assessment: 85%
 * Problem Estimate: 90%
 * Initial Code Complexity Estimate: 88%
 * Final Code Complexity: TBD
 * Overall Result Score: TBD
 * Key Variances/Learnings: TBD
 * Last Updated: 2025-07-07
 */

import XCTest
import CoreData
@testable import FinanceMate

@MainActor
class AnalyticsEngineTests: XCTestCase {
    
    var analyticsEngine: AnalyticsEngine!
    var testContext: NSManagedObjectContext!
    var persistenceController: PersistenceController!
    
    override func setUp() async throws {
        try await super.setUp()
        
        // Create in-memory Core Data stack for testing
        persistenceController = PersistenceController(inMemory: true)
        testContext = persistenceController.container.viewContext
        
        // Initialize analytics engine with test context
        analyticsEngine = AnalyticsEngine(context: testContext)
        
        // Create test data
        try await createTestTransactionData()
    }
    
    override func tearDown() async throws {
        analyticsEngine = nil
        testContext = nil
        persistenceController = nil
        try await super.tearDown()
    }
    
    // MARK: - Test Data Creation
    
    private func createTestTransactionData() async throws {
        // Create sample transactions with split allocations
        let transaction1 = Transaction(context: testContext)
        transaction1.id = UUID()
        transaction1.amount = 1000.0
        transaction1.date = Date().addingTimeInterval(-30 * 24 * 60 * 60) // 30 days ago
        transaction1.category = "Business Expense"
        transaction1.note = "Office supplies and equipment"
        
        // Create line items with splits
        let lineItem1 = LineItem(context: testContext)
        lineItem1.id = UUID()
        lineItem1.amount = 600.0
        lineItem1.itemDescription = "Office chair"
        lineItem1.transaction = transaction1
        
        let split1 = SplitAllocation(context: testContext)
        split1.id = UUID()
        split1.percentage = 80.0
        split1.taxCategory = "Business"
        split1.lineItem = lineItem1
        
        let split2 = SplitAllocation(context: testContext)
        split2.id = UUID()
        split2.percentage = 20.0
        split2.taxCategory = "Personal"
        split2.lineItem = lineItem1
        
        // Second line item
        let lineItem2 = LineItem(context: testContext)
        lineItem2.id = UUID()
        lineItem2.amount = 400.0
        lineItem2.itemDescription = "Software subscription"
        lineItem2.transaction = transaction1
        
        let split3 = SplitAllocation(context: testContext)
        split3.id = UUID()
        split3.percentage = 100.0
        split3.taxCategory = "Business"
        split3.lineItem = lineItem2
        
        // Save test data
        try testContext.save()
    }
    
    // MARK: - Core Analytics Tests
    
    func testAnalyticsEngineInitialization() {
        XCTAssertNotNil(analyticsEngine, "AnalyticsEngine should initialize successfully")
        XCTAssertEqual(analyticsEngine.context, testContext, "Context should be properly assigned")
    }
    
    func testSplitPercentageAggregationByTaxCategory() async throws {
        // Test aggregation of split percentages across all transactions by tax category
        let aggregatedData = try await analyticsEngine.aggregateSplitsByTaxCategory()
        
        XCTAssertGreaterThan(aggregatedData.count, 0, "Should have aggregated data")
        XCTAssertTrue(aggregatedData.keys.contains("Business"), "Should contain Business category")
        XCTAssertTrue(aggregatedData.keys.contains("Personal"), "Should contain Personal category")
        
        // Verify calculation accuracy
        let businessTotal = aggregatedData["Business"] ?? 0
        let personalTotal = aggregatedData["Personal"] ?? 0
        
        XCTAssertEqual(businessTotal, 880.0, accuracy: 0.01, "Business allocation should be correct")
        XCTAssertEqual(personalTotal, 120.0, accuracy: 0.01, "Personal allocation should be correct")
    }
    
    func testTimeBasedAnalysisMonthly() async throws {
        // Test monthly analysis for split patterns
        let currentDate = Date()
        let monthlyData = try await analyticsEngine.analyzeMonthlyTrends(for: currentDate)
        
        XCTAssertNotNil(monthlyData, "Monthly data should not be nil")
        XCTAssertGreaterThan(monthlyData.totalTransactions, 0, "Should have transaction data")
        XCTAssertGreaterThan(monthlyData.categories.count, 0, "Should have category breakdowns")
    }
    
    func testTimeBasedAnalysisQuarterly() async throws {
        // Test quarterly analysis for split patterns
        let currentDate = Date()
        let quarterlyData = try await analyticsEngine.analyzeQuarterlyTrends(for: currentDate)
        
        XCTAssertNotNil(quarterlyData, "Quarterly data should not be nil")
        XCTAssertGreaterThanOrEqual(quarterlyData.months.count, 1, "Should have at least one month of data")
    }
    
    func testTimeBasedAnalysisYearly() async throws {
        // Test yearly analysis for split patterns
        let currentDate = Date()
        let yearlyData = try await analyticsEngine.analyzeYearlyTrends(for: currentDate)
        
        XCTAssertNotNil(yearlyData, "Yearly data should not be nil")
        XCTAssertGreaterThanOrEqual(yearlyData.quarters.count, 1, "Should have at least one quarter of data")
    }
    
    func testFinancialMetricsCalculation() async throws {
        // Test calculation of financial metrics: totals, percentages, trends
        let metrics = try await analyticsEngine.calculateFinancialMetrics()
        
        XCTAssertNotNil(metrics, "Financial metrics should not be nil")
        XCTAssertGreaterThan(metrics.totalAmount, 0, "Should have positive total amount")
        XCTAssertGreaterThan(metrics.categoryBreakdown.count, 0, "Should have category breakdown")
        XCTAssertTrue(metrics.categoryBreakdown.keys.contains("Business"), "Should include Business category")
        
        // Verify percentage calculations sum to 100%
        let totalPercentage = metrics.categoryBreakdown.values.reduce(0, +)
        XCTAssertEqual(totalPercentage, 100.0, accuracy: 0.01, "Percentages should sum to 100%")
    }
    
    func testRealTimeBalanceCalculationsWithSplits() async throws {
        // Test real-time balance calculations with split-aware computations
        let balance = try await analyticsEngine.calculateRealTimeBalance()
        
        XCTAssertNotNil(balance, "Balance should not be nil")
        XCTAssertGreaterThan(balance.totalBalance, 0, "Should have positive balance")
        XCTAssertEqual(balance.businessAllocation, 880.0, accuracy: 0.01, "Business allocation should be accurate")
        XCTAssertEqual(balance.personalAllocation, 120.0, accuracy: 0.01, "Personal allocation should be accurate")
    }
    
    func testAustralianLocaleCompliance() async throws {
        // Test Australian locale compliance for all calculated values
        let metrics = try await analyticsEngine.calculateFinancialMetrics()
        
        XCTAssertNotNil(metrics.formattedTotalAmount, "Formatted amount should not be nil")
        XCTAssertTrue(metrics.formattedTotalAmount.contains("AUD"), "Should use AUD currency")
        XCTAssertTrue(metrics.formattedTotalAmount.contains("$"), "Should include currency symbol")
    }
    
    // MARK: - Performance Tests
    
    func testPerformanceWithLargeTransactionDataset() async throws {
        // Create large dataset for performance testing
        await createLargeTestDataset(transactionCount: 1000)
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        let metrics = try await analyticsEngine.calculateFinancialMetrics()
        
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        XCTAssertNotNil(metrics, "Should handle large dataset")
        XCTAssertLessThan(timeElapsed, 2.0, "Should complete within 2 seconds for 1000 transactions")
    }
    
    func testMemoryUsageWithLargeDataset() async throws {
        // Test memory efficiency with large datasets
        await createLargeTestDataset(transactionCount: 1000)
        
        let initialMemory = getMemoryUsage()
        
        let _ = try await analyticsEngine.calculateFinancialMetrics()
        
        let finalMemory = getMemoryUsage()
        let memoryIncrease = finalMemory - initialMemory
        
        // Should not use more than 50MB additional memory
        XCTAssertLessThan(memoryIncrease, 50_000_000, "Memory usage should be reasonable")
    }
    
    // MARK: - Edge Cases
    
    func testEmptyDatasetHandling() async throws {
        // Clear all test data
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: Transaction.fetchRequest())
        try testContext.execute(deleteRequest)
        try testContext.save()
        
        let metrics = try await analyticsEngine.calculateFinancialMetrics()
        
        XCTAssertNotNil(metrics, "Should handle empty dataset gracefully")
        XCTAssertEqual(metrics.totalAmount, 0, "Total should be zero for empty dataset")
        XCTAssertEqual(metrics.categoryBreakdown.count, 0, "Should have no categories")
    }
    
    func testInvalidDataHandling() async throws {
        // Create transaction with invalid split data
        let invalidTransaction = Transaction(context: testContext)
        invalidTransaction.id = UUID()
        invalidTransaction.amount = 100.0
        invalidTransaction.date = Date()
        
        let invalidLineItem = LineItem(context: testContext)
        invalidLineItem.id = UUID()
        invalidLineItem.amount = 100.0
        invalidLineItem.transaction = invalidTransaction
        
        // Create split that exceeds 100%
        let invalidSplit = SplitAllocation(context: testContext)
        invalidSplit.id = UUID()
        invalidSplit.percentage = 150.0 // Invalid: exceeds 100%
        invalidSplit.taxCategory = "Invalid"
        invalidSplit.lineItem = invalidLineItem
        
        try testContext.save()
        
        // Should handle invalid data gracefully
        let metrics = try await analyticsEngine.calculateFinancialMetrics()
        XCTAssertNotNil(metrics, "Should handle invalid data gracefully")
    }
    
    func testConcurrentAnalyticsOperations() async throws {
        // Test concurrent analytics operations for thread safety
        let group = DispatchGroup()
        var results: [FinancialMetrics] = []
        var errors: [Error] = []
        
        for _ in 0..<5 {
            group.enter()
            Task {
                do {
                    let metrics = try await analyticsEngine.calculateFinancialMetrics()
                    results.append(metrics)
                } catch {
                    errors.append(error)
                }
                group.leave()
            }
        }
        
        group.wait()
        
        XCTAssertEqual(errors.count, 0, "Should handle concurrent operations without errors")
        XCTAssertEqual(results.count, 5, "Should complete all concurrent operations")
        
        // Verify all results are consistent
        let firstResult = results[0]
        for result in results {
            XCTAssertEqual(result.totalAmount, firstResult.totalAmount, "Concurrent results should be consistent")
        }
    }
    
    // MARK: - Helper Methods
    
    private func createLargeTestDataset(transactionCount: Int) async {
        for i in 0..<transactionCount {
            let transaction = Transaction(context: testContext)
            transaction.id = UUID()
            transaction.amount = Double.random(in: 10...1000)
            transaction.date = Date().addingTimeInterval(TimeInterval(-i * 24 * 60 * 60))
            transaction.category = "Category \(i % 10)"
            
            let lineItem = LineItem(context: testContext)
            lineItem.id = UUID()
            lineItem.amount = transaction.amount
            lineItem.itemDescription = "Item \(i)"
            lineItem.transaction = transaction
            
            let split = SplitAllocation(context: testContext)
            split.id = UUID()
            split.percentage = Double.random(in: 50...100)
            split.taxCategory = i % 2 == 0 ? "Business" : "Personal"
            split.lineItem = lineItem
        }
        
        try? testContext.save()
    }
    
    private func getMemoryUsage() -> Int64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        if result == KERN_SUCCESS {
            return Int64(info.resident_size)
        }
        
        return 0
    }
}

// MARK: - Analytics Data Models for Testing

extension AnalyticsEngineTests {
    
    struct TestFinancialMetrics {
        let totalAmount: Double
        let categoryBreakdown: [String: Double]
        let formattedTotalAmount: String
    }
    
    struct TestMonthlyData {
        let totalTransactions: Int
        let categories: [String: Double]
        let trends: [String: Double]
    }
    
    struct TestQuarterlyData {
        let months: [TestMonthlyData]
        let totalAmount: Double
    }
    
    struct TestYearlyData {
        let quarters: [TestQuarterlyData]
        let totalAmount: Double
    }
    
    struct TestRealTimeBalance {
        let totalBalance: Double
        let businessAllocation: Double
        let personalAllocation: Double
    }
}