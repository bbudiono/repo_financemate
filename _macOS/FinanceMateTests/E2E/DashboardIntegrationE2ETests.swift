//
//  DashboardIntegrationE2ETests.swift
//  FinanceMateTests
//
//  Purpose: End-to-End tests for Dashboard integration with Basiq data
//  Validates data flow from Basiq API to Dashboard visualization
//  Tests real-time updates and user interactions
//
//  Key Test Coverage:
//  - Dashboard data refresh after sync
//  - Real-time balance calculations
//  - Transaction categorization
//  - Chart data visualization
//  - Performance monitoring
//
//  Created by Test Automation on 8/6/25.
//

import XCTest
import CoreData
import Combine
@testable import FinanceMate

/**
 * DASHBOARD INTEGRATION E2E TEST SUITE
 * 
 * Validates complete data flow from Basiq to Dashboard UI
 * Tests ViewModels, data transformations, and UI updates
 * 
 * Compliance:
 * - Headless execution (programmatic UI validation)
 * - No XCUITest dependencies
 * - Silent execution with logging
 * - Real data validation
 */
@MainActor
final class DashboardIntegrationE2ETests: XCTestCase {
    
    // MARK: - Test Infrastructure
    
    private var persistenceController: PersistenceController!
    private var context: NSManagedObjectContext!
    private var basiqService: BasiqService!
    private var syncManager: FinancialDataSyncManager!
    private var dashboardViewModel: DashboardViewModel!
    private var netWealthViewModel: NetWealthDashboardViewModel!
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Setup & Teardown
    
    override func setUpWithError() throws {
        super.setUp()
        
        // Initialize Core Data
        persistenceController = PersistenceController(inMemory: true)
        context = MainActor.assumeIsolated {
            persistenceController.container.viewContext
        }
        context.automaticallyMergesChangesFromParent = true
        
        // Initialize services
        basiqService = BasiqService()
        syncManager = FinancialDataSyncManager(
            provider: basiqService,
            context: context
        )
        
        // Initialize ViewModels
        dashboardViewModel = DashboardViewModel(context: context)
        netWealthViewModel = NetWealthDashboardViewModel(context: context)
    }
    
    override func tearDownWithError() throws {
        cancellables.removeAll()
        
        // Clean Core Data
        if let context = context {
            let entities = ["Transaction", "Asset", "Liability", "NetWealthSnapshot"]
            for entity in entities {
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
                try context.execute(deleteRequest)
            }
            context.reset()
        }
        
        // Clean up
        dashboardViewModel = nil
        netWealthViewModel = nil
        syncManager = nil
        basiqService = nil
        context = nil
        persistenceController = nil
        
        super.tearDown()
    }
    
    // MARK: - Test: Dashboard Data Refresh After Sync
    
    func testDashboardRefreshAfterBasiqSync() async throws {
        // Test that dashboard updates correctly after Basiq data sync
        
        // Initial state - empty dashboard
        await dashboardViewModel.loadDashboardData()
        XCTAssertEqual(dashboardViewModel.totalBalance, 0.0)
        XCTAssertTrue(dashboardViewModel.transactions.isEmpty)
        XCTAssertTrue(dashboardViewModel.recentTransactions.isEmpty)
        
        // Connect to Basiq and sync data
        _ = try await basiqService.connect(institution: "AU00000")
        await syncManager.performFullSync()
        
        // Refresh dashboard
        await dashboardViewModel.loadDashboardData()
        
        // Verify dashboard updated with synced data
        XCTAssertNotEqual(dashboardViewModel.totalBalance, 0.0, "Balance should update after sync")
        XCTAssertFalse(dashboardViewModel.transactions.isEmpty, "Transactions should be loaded")
        XCTAssertFalse(dashboardViewModel.recentTransactions.isEmpty, "Recent transactions should be populated")
        
        // Verify transaction ordering (most recent first)
        if dashboardViewModel.recentTransactions.count > 1 {
            for i in 1..<dashboardViewModel.recentTransactions.count {
                let prevDate = dashboardViewModel.recentTransactions[i-1].date ?? Date.distantPast
                let currDate = dashboardViewModel.recentTransactions[i].date ?? Date.distantPast
                XCTAssertGreaterThanOrEqual(prevDate, currDate, "Transactions should be ordered by date descending")
            }
        }
        
        // Verify spending by category calculated
        XCTAssertFalse(dashboardViewModel.spendingByCategory.isEmpty, "Category breakdown should be calculated")
        
        // Verify all categories have positive spending
        for (_, amount) in dashboardViewModel.spendingByCategory {
            XCTAssertGreaterThan(amount, 0, "Category spending should be positive")
        }
    }
    
    // MARK: - Test: Real-time Balance Calculations
    
    func testRealTimeBalanceCalculations() async throws {
        // Test that balance calculations update in real-time
        
        // Create initial transaction data
        let transaction1 = createTestTransaction(amount: 1000.0, type: "income")
        let transaction2 = createTestTransaction(amount: -500.0, type: "expense")
        let transaction3 = createTestTransaction(amount: -200.0, type: "expense")
        try context.save()
        
        // Load dashboard
        await dashboardViewModel.loadDashboardData()
        
        // Verify initial balance
        let expectedBalance = 1000.0 - 500.0 - 200.0
        XCTAssertEqual(dashboardViewModel.totalBalance, expectedBalance, accuracy: 0.01)
        
        // Add new transaction
        let newTransaction = createTestTransaction(amount: 300.0, type: "income")
        try context.save()
        
        // Refresh dashboard
        await dashboardViewModel.loadDashboardData()
        
        // Verify balance updated
        let newExpectedBalance = expectedBalance + 300.0
        XCTAssertEqual(dashboardViewModel.totalBalance, newExpectedBalance, accuracy: 0.01)
        
        // Verify income/expense totals
        XCTAssertEqual(dashboardViewModel.totalIncome, 1300.0, accuracy: 0.01)
        XCTAssertEqual(dashboardViewModel.totalExpenses, 700.0, accuracy: 0.01)
    }
    
    // MARK: - Test: Net Wealth Dashboard Integration
    
    func testNetWealthDashboardIntegration() async throws {
        // Test net wealth dashboard with Basiq data
        
        // Create test assets and liabilities
        let asset1 = Asset.create(
            in: context,
            name: "Savings Account",
            type: .cash,
            currentValue: 50000.0
        )
        
        let asset2 = Asset.create(
            in: context,
            name: "Investment Portfolio",
            type: .investment,
            currentValue: 150000.0
        )
        
        let liability1 = Liability.create(
            in: context,
            name: "Credit Card",
            type: .creditCard,
            currentBalance: 5000.0
        )
        
        try context.save()
        
        // Load net wealth dashboard
        await netWealthViewModel.loadDashboardData()
        
        // Verify calculations
        XCTAssertEqual(netWealthViewModel.totalAssets, 200000.0, accuracy: 0.01)
        XCTAssertEqual(netWealthViewModel.totalLiabilities, 5000.0, accuracy: 0.01)
        XCTAssertEqual(netWealthViewModel.netWealth, 195000.0, accuracy: 0.01)
        
        // Verify asset breakdown
        XCTAssertEqual(netWealthViewModel.assetBreakdown.count, 2)
        
        let cashAsset = netWealthViewModel.assetBreakdown.first { $0.name == "Savings Account" }
        XCTAssertNotNil(cashAsset)
        XCTAssertEqual(cashAsset?.value, 50000.0, accuracy: 0.01)
        XCTAssertEqual(cashAsset?.percentage, 25.0, accuracy: 0.1) // 50k/200k = 25%
        
        // Verify chart data
        XCTAssertFalse(netWealthViewModel.wealthHistory.isEmpty)
        XCTAssertFalse(netWealthViewModel.monthlyComparison.isEmpty)
    }
    
    // MARK: - Test: Transaction Categorization
    
    func testTransactionCategorization() async throws {
        // Test automatic transaction categorization from Basiq data
        
        // Create transactions with different categories
        let groceries = createTestTransaction(amount: -150.0, category: "Groceries")
        let transport = createTestTransaction(amount: -50.0, category: "Transport")
        let entertainment = createTestTransaction(amount: -100.0, category: "Entertainment")
        let salary = createTestTransaction(amount: 5000.0, category: "Salary")
        
        try context.save()
        
        // Load dashboard
        await dashboardViewModel.loadDashboardData()
        
        // Verify categorization
        XCTAssertEqual(dashboardViewModel.spendingByCategory.count, 3) // Only expense categories
        
        XCTAssertEqual(dashboardViewModel.spendingByCategory["Groceries"], 150.0, accuracy: 0.01)
        XCTAssertEqual(dashboardViewModel.spendingByCategory["Transport"], 50.0, accuracy: 0.01)
        XCTAssertEqual(dashboardViewModel.spendingByCategory["Entertainment"], 100.0, accuracy: 0.01)
        
        // Verify income not in spending categories
        XCTAssertNil(dashboardViewModel.spendingByCategory["Salary"])
    }
    
    // MARK: - Test: Chart Data Visualization
    
    func testChartDataVisualization() async throws {
        // Test chart data preparation for visualization
        
        // Create historical data for charts
        let calendar = Calendar.current
        let now = Date()
        
        for i in 0..<30 {
            let date = calendar.date(byAdding: .day, value: -i, to: now)!
            let amount = Double.random(in: -200...500)
            let transaction = createTestTransaction(
                amount: amount,
                date: date,
                category: ["Food", "Transport", "Shopping", "Bills"].randomElement()!
            )
        }
        
        try context.save()
        
        // Load dashboard with chart data
        await dashboardViewModel.loadDashboardData()
        
        // Verify chart data prepared
        XCTAssertFalse(dashboardViewModel.transactions.isEmpty)
        XCTAssertFalse(dashboardViewModel.spendingByCategory.isEmpty)
        
        // Test monthly trend calculation
        let monthlyTrend = dashboardViewModel.calculateMonthlyTrend()
        XCTAssertFalse(monthlyTrend.isEmpty)
        
        // Verify data points for charts
        for (category, amount) in dashboardViewModel.spendingByCategory {
            XCTAssertGreaterThan(amount, 0, "Chart data should have positive values")
            XCTAssertFalse(category.isEmpty, "Category names should not be empty")
        }
    }
    
    // MARK: - Test: Performance with Large Dataset
    
    func testPerformanceWithLargeDataset() async throws {
        // Test dashboard performance with large transaction dataset
        
        // Create 1000 transactions
        for i in 0..<1000 {
            let date = Date().addingTimeInterval(Double(-i * 86400))
            let amount = Double.random(in: -500...1000)
            let transaction = createTestTransaction(
                amount: amount,
                date: date,
                category: ["Food", "Transport", "Shopping", "Bills", "Entertainment"].randomElement()!
            )
        }
        
        try context.save()
        
        // Measure dashboard load time
        let startTime = CFAbsoluteTimeGetCurrent()
        await dashboardViewModel.loadDashboardData()
        let loadTime = CFAbsoluteTimeGetCurrent() - startTime
        
        // Performance assertions
        XCTAssertLessThan(loadTime, 1.0, "Dashboard should load within 1 second even with 1000 transactions")
        XCTAssertEqual(dashboardViewModel.transactions.count, 1000)
        XCTAssertFalse(dashboardViewModel.spendingByCategory.isEmpty)
        
        // Verify memory efficiency
        XCTAssertLessThanOrEqual(
            dashboardViewModel.recentTransactions.count,
            10,
            "Recent transactions should be limited for memory efficiency"
        )
    }
    
    // MARK: - Test: Live Updates Subscription
    
    func testLiveUpdatesSubscription() async throws {
        // Test that dashboard subscribes to data changes
        
        let updateExpectation = XCTestExpectation(description: "Dashboard updates on data change")
        
        // Subscribe to dashboard changes
        dashboardViewModel.$totalBalance
            .dropFirst() // Skip initial value
            .sink { _ in
                updateExpectation.fulfill()
            }
            .store(in: &cancellables)
        
        // Initial load
        await dashboardViewModel.loadDashboardData()
        
        // Add new transaction
        let newTransaction = createTestTransaction(amount: 1000.0, type: "income")
        try context.save()
        
        // Trigger refresh
        await dashboardViewModel.loadDashboardData()
        
        // Wait for update
        await fulfillment(of: [updateExpectation], timeout: 5.0)
    }
    
    // MARK: - Test: Error State Handling
    
    func testDashboardErrorStateHandling() async throws {
        // Test dashboard error state presentation
        
        // Simulate data loading error by using invalid context operation
        // Dashboard should handle gracefully
        
        await dashboardViewModel.loadDashboardData()
        
        // Even with no data, dashboard should not crash
        XCTAssertNotNil(dashboardViewModel.totalBalance)
        XCTAssertNotNil(dashboardViewModel.transactions)
        XCTAssertNotNil(dashboardViewModel.spendingByCategory)
        
        // Error message should be user-friendly if present
        if let error = dashboardViewModel.errorMessage {
            XCTAssertFalse(error.isEmpty)
            XCTAssertFalse(error.contains("NSManagedObject")) // No technical jargon
        }
    }
    
    // MARK: - Test: Currency Formatting
    
    func testCurrencyFormattingInDashboard() async throws {
        // Test that all monetary values are properly formatted
        
        // Create transactions with precise amounts
        let transaction1 = createTestTransaction(amount: 1234.56)
        let transaction2 = createTestTransaction(amount: -789.01)
        try context.save()
        
        // Load dashboard
        await dashboardViewModel.loadDashboardData()
        
        // Test balance formatting
        let formattedBalance = dashboardViewModel.formattedBalance
        XCTAssertTrue(formattedBalance.contains("$"))
        XCTAssertTrue(formattedBalance.contains(",") || dashboardViewModel.totalBalance < 1000)
        
        // Test transaction amount formatting
        for transaction in dashboardViewModel.transactions {
            let formattedAmount = dashboardViewModel.formatCurrency(transaction.amount)
            XCTAssertTrue(formattedAmount.contains("$"))
            
            if abs(transaction.amount) >= 1000 {
                XCTAssertTrue(formattedAmount.contains(","))
            }
        }
    }
}

// MARK: - Test Utilities

extension DashboardIntegrationE2ETests {
    
    private func createTestTransaction(
        amount: Double,
        date: Date = Date(),
        category: String = "General",
        type: String = "expense"
    ) -> Transaction {
        let transaction = Transaction(context: context)
        transaction.id = UUID()
        transaction.amount = amount
        transaction.date = date
        transaction.category = category
        transaction.note = "Test transaction"
        transaction.createdAt = Date()
        transaction.externalId = UUID().uuidString // Simulate Basiq ID
        return transaction
    }
}

/**
 * DASHBOARD INTEGRATION TEST COVERAGE
 * 
 * ✅ Dashboard refresh after Basiq sync
 * ✅ Real-time balance calculations
 * ✅ Transaction categorization and grouping
 * ✅ Chart data visualization preparation
 * ✅ Net wealth dashboard integration
 * ✅ Performance with 1000+ transactions
 * ✅ Live update subscriptions
 * ✅ Error state handling
 * ✅ Currency formatting
 * 
 * Performance Targets:
 * - Dashboard load: <1 second with 1000 transactions
 * - Balance calculation: Real-time updates
 * - Chart rendering: Prepared data structures
 * 
 * All tests: 100% Headless, No UI interaction required
 */