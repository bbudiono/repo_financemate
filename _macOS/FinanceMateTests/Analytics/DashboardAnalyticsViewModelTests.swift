//
// DashboardAnalyticsViewModelTests.swift
// FinanceMateTests
//
// Dashboard Analytics Integration Test Suite  
// Created: 2025-07-07
// Target: FinanceMateTests
//

/*
 * Purpose: Comprehensive test suite for DashboardAnalyticsViewModel split-based dashboard integration
 * Issues & Complexity Summary: Complex real-time analytics integration, Charts framework, accessibility compliance
 * Key Complexity Drivers:
   - Logic Scope (Est. LoC): ~300
   - Core Algorithm Complexity: High
   - Dependencies: AnalyticsEngine, Charts framework, DashboardViewModel
   - State Management Complexity: High (real-time updates, chart data)
   - Novelty/Uncertainty Factor: Medium
 * AI Pre-Task Self-Assessment: 87%
 * Problem Estimate: 88%
 * Initial Code Complexity Estimate: 90%
 * Final Code Complexity: TBD
 * Overall Result Score: TBD
 * Key Variances/Learnings: TBD
 * Last Updated: 2025-07-07
 */

import XCTest
import CoreData
import Charts
@testable import FinanceMate

@MainActor
class DashboardAnalyticsViewModelTests: XCTestCase {
    
    var viewModel: DashboardAnalyticsViewModel!
    var analyticsEngine: AnalyticsEngine!
    var testContext: NSManagedObjectContext!
    var persistenceController: PersistenceController!
    
    override func setUp() async throws {
        try await super.setUp()
        
        // Create in-memory Core Data stack for testing
        persistenceController = PersistenceController(inMemory: true)
        testContext = persistenceController.container.viewContext
        
        // Initialize analytics engine
        analyticsEngine = AnalyticsEngine(context: testContext)
        
        // Initialize dashboard analytics view model
        viewModel = DashboardAnalyticsViewModel(
            context: testContext,
            analyticsEngine: analyticsEngine
        )
        
        // Create test data
        try await createTestAnalyticsData()
    }
    
    override func tearDown() async throws {
        viewModel = nil
        analyticsEngine = nil
        testContext = nil
        persistenceController = nil
        try await super.tearDown()
    }
    
    // MARK: - Test Data Creation
    
    private func createTestAnalyticsData() async throws {
        // Create transactions with varied split allocations for comprehensive analytics testing
        let calendar = Calendar.current
        let currentDate = Date()
        
        for i in 0..<10 {
            let transaction = Transaction(context: testContext)
            transaction.id = UUID()
            transaction.amount = Double.random(in: 100...2000)
            transaction.date = calendar.date(byAdding: .day, value: -i * 7, to: currentDate)!
            transaction.category = ["Business", "Personal", "Investment"][i % 3]
            transaction.note = "Test transaction \(i)"
            
            // Create line items with varied split patterns
            let lineItem = LineItem(context: testContext)
            lineItem.id = UUID()
            lineItem.amount = transaction.amount
            lineItem.itemDescription = "Analytics test item \(i)"
            lineItem.transaction = transaction
            
            // Create split allocations based on transaction type
            if transaction.category == "Business" {
                // 80/20 business/personal split
                let businessSplit = SplitAllocation(context: testContext)
                businessSplit.id = UUID()
                businessSplit.percentage = 80.0
                businessSplit.taxCategory = "Business"
                businessSplit.lineItem = lineItem
                
                let personalSplit = SplitAllocation(context: testContext)
                personalSplit.id = UUID()
                personalSplit.percentage = 20.0
                personalSplit.taxCategory = "Personal"
                personalSplit.lineItem = lineItem
            } else {
                // 100% single category
                let split = SplitAllocation(context: testContext)
                split.id = UUID()
                split.percentage = 100.0
                split.taxCategory = transaction.category == "Personal" ? "Personal" : "Investment"
                split.lineItem = lineItem
            }
        }
        
        try testContext.save()
    }
    
    // MARK: - Initialization Tests
    
    func testDashboardAnalyticsViewModelInitialization() {
        XCTAssertNotNil(viewModel, "DashboardAnalyticsViewModel should initialize successfully")
        XCTAssertEqual(viewModel.context, testContext, "Context should be properly assigned")
        XCTAssertNotNil(viewModel.analyticsEngine, "Analytics engine should be assigned")
        XCTAssertFalse(viewModel.isLoading, "Should not be loading initially")
        XCTAssertNil(viewModel.errorMessage, "Should not have error message initially")
    }
    
    func testInitialDataState() {
        XCTAssertTrue(viewModel.categorySummaryCards.isEmpty, "Category summary cards should be empty initially")
        XCTAssertTrue(viewModel.trendChartData.isEmpty, "Trend chart data should be empty initially")
        XCTAssertEqual(viewModel.totalBalance, 0.0, "Total balance should be zero initially")
        XCTAssertTrue(viewModel.wealthProgressionData.isEmpty, "Wealth progression data should be empty initially")
    }
    
    // MARK: - Analytics Integration Tests
    
    func testLoadAnalyticsData() async throws {
        // Test loading analytics data with split-aware calculations
        await viewModel.loadAnalyticsData()
        
        XCTAssertFalse(viewModel.isLoading, "Should not be loading after completion")
        XCTAssertNil(viewModel.errorMessage, "Should not have error message after successful load")
        XCTAssertGreaterThan(viewModel.categorySummaryCards.count, 0, "Should have category summary cards")
        XCTAssertGreaterThan(viewModel.totalBalance, 0, "Should have positive total balance")
    }
    
    func testSplitBasedSummaryCards() async throws {
        // Test split-based summary cards showing tax category breakdowns
        await viewModel.loadAnalyticsData()
        
        let summaryCards = viewModel.categorySummaryCards
        XCTAssertGreaterThan(summaryCards.count, 0, "Should have summary cards")
        
        // Verify each card has required properties
        for card in summaryCards {
            XCTAssertFalse(card.categoryName.isEmpty, "Category name should not be empty")
            XCTAssertGreaterThanOrEqual(card.amount, 0, "Amount should be non-negative")
            XCTAssertGreaterThanOrEqual(card.percentage, 0, "Percentage should be non-negative")
            XCTAssertLessThanOrEqual(card.percentage, 100, "Percentage should not exceed 100%")
            XCTAssertNotNil(card.color, "Card should have color assigned")
        }
        
        // Verify percentages sum to approximately 100%
        let totalPercentage = summaryCards.map(\.percentage).reduce(0, +)
        XCTAssertEqual(totalPercentage, 100.0, accuracy: 0.01, "Percentages should sum to 100%")
    }
    
    func testTrendAnalysisCharts() async throws {
        // Test trend analysis charts using Charts framework
        await viewModel.loadAnalyticsData()
        
        let chartData = viewModel.trendChartData
        XCTAssertGreaterThan(chartData.count, 0, "Should have chart data points")
        
        for dataPoint in chartData {
            XCTAssertNotNil(dataPoint.date, "Data point should have date")
            XCTAssertGreaterThanOrEqual(dataPoint.amount, 0, "Amount should be non-negative")
            XCTAssertFalse(dataPoint.category.isEmpty, "Category should not be empty")
        }
        
        // Verify data is sorted by date
        let sortedData = chartData.sorted { $0.date < $1.date }
        XCTAssertEqual(chartData, sortedData, "Chart data should be sorted by date")
    }
    
    func testWealthProgressionTracking() async throws {
        // Test wealth progression tracking with split-aware calculations
        await viewModel.loadAnalyticsData()
        
        let progressionData = viewModel.wealthProgressionData
        XCTAssertGreaterThan(progressionData.count, 0, "Should have progression data")
        
        for progression in progressionData {
            XCTAssertNotNil(progression.date, "Progression should have date")
            XCTAssertGreaterThanOrEqual(progression.cumulativeBalance, 0, "Cumulative balance should be non-negative")
            XCTAssertNotNil(progression.splitBreakdown, "Should have split breakdown")
        }
        
        // Verify progression is chronological
        let sortedProgression = progressionData.sorted { $0.date < $1.date }
        XCTAssertEqual(progressionData, sortedProgression, "Progression data should be chronological")
    }
    
    func testExpensePatternRecognition() async throws {
        // Test expense pattern recognition and anomaly detection
        await viewModel.loadAnalyticsData()
        
        let patterns = viewModel.detectedPatterns
        XCTAssertNotNil(patterns, "Should have pattern detection results")
        
        for pattern in patterns {
            XCTAssertFalse(pattern.patternType.isEmpty, "Pattern type should not be empty")
            XCTAssertGreaterThan(pattern.confidence, 0, "Confidence should be positive")
            XCTAssertLessThanOrEqual(pattern.confidence, 1.0, "Confidence should not exceed 100%")
            XCTAssertFalse(pattern.description.isEmpty, "Pattern description should not be empty")
        }
    }
    
    func testAnomalyDetection() async throws {
        // Test anomaly detection for split allocations
        await viewModel.loadAnalyticsData()
        
        let anomalies = viewModel.detectedAnomalies
        XCTAssertNotNil(anomalies, "Should have anomaly detection results")
        
        for anomaly in anomalies {
            XCTAssertNotNil(anomaly.transactionId, "Anomaly should reference transaction")
            XCTAssertGreaterThan(anomaly.severityScore, 0, "Severity score should be positive")
            XCTAssertFalse(anomaly.reason.isEmpty, "Anomaly reason should not be empty")
            XCTAssertNotNil(anomaly.suggestedAction, "Should have suggested action")
        }
    }
    
    // MARK: - Real-Time Updates Tests
    
    func testRealTimeUpdates() async throws {
        // Test real-time updates when data changes
        await viewModel.loadAnalyticsData()
        
        let initialBalance = viewModel.totalBalance
        let initialCardCount = viewModel.categorySummaryCards.count
        
        // Add new transaction
        let newTransaction = Transaction(context: testContext)
        newTransaction.id = UUID()
        newTransaction.amount = 500.0
        newTransaction.date = Date()
        newTransaction.category = "Business"
        
        let lineItem = LineItem(context: testContext)
        lineItem.id = UUID()
        lineItem.amount = 500.0
        lineItem.transaction = newTransaction
        
        let split = SplitAllocation(context: testContext)
        split.id = UUID()
        split.percentage = 100.0
        split.taxCategory = "Business"
        split.lineItem = lineItem
        
        try testContext.save()
        
        // Trigger refresh
        await viewModel.refreshAnalyticsData()
        
        XCTAssertGreaterThan(viewModel.totalBalance, initialBalance, "Balance should increase after new transaction")
        XCTAssertGreaterThanOrEqual(viewModel.categorySummaryCards.count, initialCardCount, "Should maintain or increase card count")
    }
    
    func testAutoRefreshOnDataChange() async throws {
        // Test automatic refresh when Core Data changes
        await viewModel.loadAnalyticsData()
        
        let initialBalance = viewModel.totalBalance
        
        // Enable auto-refresh
        viewModel.enableAutoRefresh()
        
        // Add transaction (should trigger auto-refresh)
        let transaction = Transaction(context: testContext)
        transaction.id = UUID()
        transaction.amount = 300.0
        transaction.date = Date()
        transaction.category = "Personal"
        
        try testContext.save()
        
        // Wait for auto-refresh
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        XCTAssertNotEqual(viewModel.totalBalance, initialBalance, "Balance should update automatically")
        
        viewModel.disableAutoRefresh()
    }
    
    // MARK: - Interactive Chart Tests
    
    func testInteractiveChartElements() async throws {
        // Test interactive chart elements with glassmorphism styling
        await viewModel.loadAnalyticsData()
        
        let chartConfig = viewModel.chartConfiguration
        XCTAssertNotNil(chartConfig, "Should have chart configuration")
        XCTAssertTrue(chartConfig.isInteractive, "Charts should be interactive")
        XCTAssertNotNil(chartConfig.glassmorphismStyle, "Should have glassmorphism styling")
        
        // Test chart interaction
        let dataPoint = viewModel.trendChartData.first
        XCTAssertNotNil(dataPoint, "Should have at least one data point")
        
        if let point = dataPoint {
            viewModel.selectChartDataPoint(point)
            XCTAssertEqual(viewModel.selectedDataPoint, point, "Should select data point")
            XCTAssertNotNil(viewModel.detailView, "Should show detail view for selected point")
        }
    }
    
    func testChartGlasmorphismStyling() async throws {
        // Test glassmorphism styling consistency
        await viewModel.loadAnalyticsData()
        
        let styling = viewModel.chartStyling
        XCTAssertNotNil(styling, "Should have chart styling")
        XCTAssertTrue(styling.usesGlasmorphism, "Should use glassmorphism")
        XCTAssertNotNil(styling.backgroundBlur, "Should have background blur")
        XCTAssertNotNil(styling.borderRadius, "Should have border radius")
        XCTAssertGreaterThan(styling.opacity, 0, "Should have opacity settings")
    }
    
    // MARK: - Accessibility Tests
    
    func testVoiceOverAccessibility() async throws {
        // Test VoiceOver accessibility for all analytics components
        await viewModel.loadAnalyticsData()
        
        let accessibilityData = viewModel.accessibilityData
        XCTAssertNotNil(accessibilityData, "Should have accessibility data")
        
        // Test summary cards accessibility
        for (index, card) in viewModel.categorySummaryCards.enumerated() {
            let accessibilityLabel = accessibilityData.summaryCardLabels[index]
            XCTAssertFalse(accessibilityLabel.isEmpty, "Summary card should have accessibility label")
            XCTAssertTrue(accessibilityLabel.contains(card.categoryName), "Label should contain category name")
            XCTAssertTrue(accessibilityLabel.contains(String(format: "%.0f", card.percentage)), "Label should contain percentage")
        }
        
        // Test chart accessibility
        XCTAssertFalse(accessibilityData.chartDescription.isEmpty, "Chart should have accessibility description")
        XCTAssertGreaterThan(accessibilityData.chartDataDescriptions.count, 0, "Should have data point descriptions")
    }
    
    func testKeyboardNavigation() {
        // Test keyboard navigation support
        let navigationSupport = viewModel.keyboardNavigationSupport
        XCTAssertNotNil(navigationSupport, "Should support keyboard navigation")
        XCTAssertTrue(navigationSupport.supportsTabNavigation, "Should support tab navigation")
        XCTAssertTrue(navigationSupport.supportsArrowKeyNavigation, "Should support arrow key navigation")
        XCTAssertTrue(navigationSupport.supportsEnterKeySelection, "Should support enter key selection")
    }
    
    // MARK: - Performance Tests
    
    func testPerformanceWithLargeDataset() async throws {
        // Create large dataset for performance testing
        await createLargeAnalyticsDataset(transactionCount: 1000)
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        await viewModel.loadAnalyticsData()
        
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        XCTAssertNotNil(viewModel.categorySummaryCards, "Should handle large dataset")
        XCTAssertLessThan(timeElapsed, 3.0, "Should complete within 3 seconds for 1000 transactions")
        XCTAssertFalse(viewModel.isLoading, "Should complete loading")
    }
    
    func testMemoryUsageWithComplexCharts() async throws {
        // Test memory efficiency with complex chart data
        await createLargeAnalyticsDataset(transactionCount: 500)
        
        let initialMemory = getMemoryUsage()
        
        await viewModel.loadAnalyticsData()
        
        let finalMemory = getMemoryUsage()
        let memoryIncrease = finalMemory - initialMemory
        
        // Should not use more than 75MB additional memory for complex charts
        XCTAssertLessThan(memoryIncrease, 75_000_000, "Memory usage should be reasonable for complex charts")
    }
    
    // MARK: - Error Handling Tests
    
    func testErrorHandlingOnDataFailure() async throws {
        // Test error handling when analytics data loading fails
        let failingEngine = FailingAnalyticsEngine(context: testContext)
        let failingViewModel = DashboardAnalyticsViewModel(
            context: testContext,
            analyticsEngine: failingEngine
        )
        
        await failingViewModel.loadAnalyticsData()
        
        XCTAssertFalse(failingViewModel.isLoading, "Should not be loading after error")
        XCTAssertNotNil(failingViewModel.errorMessage, "Should have error message")
        XCTAssertTrue(failingViewModel.categorySummaryCards.isEmpty, "Should have empty data on error")
    }
    
    func testGracefulDegradation() async throws {
        // Test graceful degradation when some analytics features fail
        let partialFailingEngine = PartialFailingAnalyticsEngine(context: testContext)
        let partialViewModel = DashboardAnalyticsViewModel(
            context: testContext,
            analyticsEngine: partialFailingEngine
        )
        
        await partialViewModel.loadAnalyticsData()
        
        XCTAssertFalse(partialViewModel.isLoading, "Should complete loading despite partial failures")
        XCTAssertNotNil(partialViewModel.errorMessage, "Should have warning message")
        XCTAssertGreaterThan(partialViewModel.categorySummaryCards.count, 0, "Should have some data despite partial failure")
    }
    
    // MARK: - Helper Methods
    
    private func createLargeAnalyticsDataset(transactionCount: Int) async {
        let calendar = Calendar.current
        let currentDate = Date()
        
        for i in 0..<transactionCount {
            let transaction = Transaction(context: testContext)
            transaction.id = UUID()
            transaction.amount = Double.random(in: 50...5000)
            transaction.date = calendar.date(byAdding: .day, value: -i, to: currentDate)!
            transaction.category = ["Business", "Personal", "Investment", "Education", "Healthcare"][i % 5]
            
            let lineItem = LineItem(context: testContext)
            lineItem.id = UUID()
            lineItem.amount = transaction.amount
            lineItem.transaction = transaction
            
            // Create varied split patterns
            if i % 3 == 0 {
                // Single category
                let split = SplitAllocation(context: testContext)
                split.id = UUID()
                split.percentage = 100.0
                split.taxCategory = transaction.category
                split.lineItem = lineItem
            } else {
                // Multiple splits
                let split1 = SplitAllocation(context: testContext)
                split1.id = UUID()
                split1.percentage = Double.random(in: 30...70)
                split1.taxCategory = "Business"
                split1.lineItem = lineItem
                
                let split2 = SplitAllocation(context: testContext)
                split2.id = UUID()
                split2.percentage = 100.0 - split1.percentage
                split2.taxCategory = "Personal"
                split2.lineItem = lineItem
            }
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

// MARK: - Mock Analytics Engines for Testing

class FailingAnalyticsEngine: AnalyticsEngine {
    override func aggregateSplitsByTaxCategory() async throws -> [String: Double] {
        throw AnalyticsError.aggregationFailed("Test failure")
    }
    
    override func calculateFinancialMetrics() async throws -> FinancialMetrics {
        throw AnalyticsError.calculationError("Test failure")
    }
}

class PartialFailingAnalyticsEngine: AnalyticsEngine {
    override func analyzeMonthlyTrends(for date: Date) async throws -> MonthlyAnalyticsData {
        throw AnalyticsError.calculationError("Partial test failure")
    }
    
    // Other methods work normally
}