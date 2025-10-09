//
// DashboardRealDataValidationTests.swift
// FinanceMateTests
//
// Purpose: Atomic TDD test for BLUEPRINT.md line 178 compliance
// Tests: Real Data Processing Only - no mock data in dashboard analytics
// Requirement: All dashboard analytics must use real transaction data from Core Data
//
// BLUEPRINT.md Line 178: "All dashboard analytics and financial metrics must use real
// transaction data from Core Data, absolutely no mock, sample, or placeholder data in
// any calculations or displays with data validation."

import XCTest
import CoreData
@testable import FinanceMate

final class DashboardRealDataValidationTests: XCTestCase {

    var testContext: NSManagedObjectContext!
    var dashboardService: DashboardDataService!
    var metricsService: DashboardMetricsService!

    override func setUp() {
        super.setUp()
        // Create test Core Data context
        let persistenceController = PersistenceController.preview
        testContext = persistenceController.container.viewContext

        dashboardService = DashboardDataService(context: testContext)
        metricsService = DashboardMetricsService(context: testContext)

        // Clear any existing test data
        clearTestData()
    }

    override func tearDown() {
        clearTestData()
        testContext = nil
        dashboardService = nil
        metricsService = nil
        super.tearDown()
    }

    // MARK: - BLUEPRINT.md Line 178 Compliance Tests

    /// Test 1: Validate dashboard metrics use only real Core Data transactions
    func testDashboardMetrics_UseOnlyRealCoreDataTransactions() throws {
        // Arrange: Create real test transactions in Core Data
        let testTransactions = [
            (amount: 1500.0, category: "Salary", note: "Monthly salary"),
            (amount: -250.0, category: "Groceries", note: "Weekly shopping"),
            (amount: -100.0, category: "Transport", note: "Fuel"),
            (amount: -75.0, category: "Entertainment", note: "Movie tickets")
        ]

        // Insert real transactions into Core Data
        for transaction in testTransactions {
            let entity = Transaction(context: testContext)
            entity.id = UUID()
            entity.amount = transaction.amount
            entity.category = transaction.category
            entity.note = transaction.note
            entity.date = Date()
        }

        try testContext.save()

        // Act: Calculate dashboard metrics using real data
        let metrics = metricsService.calculateMetrics()
        let dashboardResults = try dashboardService.calculateDashboardMetrics()

        // Assert: Validate metrics match real transaction calculations
        let expectedTotalBalance = testTransactions.reduce(0) { $0 + $1.amount }
        let expectedTransactionCount = testTransactions.count

        XCTAssertEqual(metrics.totalBalance, expectedTotalBalance,
                      "Total balance must match real transaction sum")
        XCTAssertEqual(metrics.totalTransactions, expectedTransactionCount,
                      "Transaction count must match real Core Data transactions")
        XCTAssertEqual(dashboardResults.0, expectedTotalBalance,
                      "Dashboard service balance must match real transaction sum")
        XCTAssertEqual(dashboardResults.1, expectedTransactionCount,
                      "Dashboard service count must match real Core Data transactions")
    }

    /// Test 2: Validate monthly spending calculation uses real transaction data
    func testMonthlySpendingCalculation_UsesRealTransactionData() throws {
        // Arrange: Create transactions across different months
        let calendar = Calendar.current
        let now = Date()

        // Current month transactions
        let currentMonthDate = calendar.date(byAdding: .day, value: -5, to: now)!
        let lastMonthDate = calendar.date(byAdding: .month, value: -1, to: now)!

        let currentMonthTransaction = Transaction(context: testContext)
        currentMonthTransaction.id = UUID()
        currentMonthTransaction.amount = -300.0
        currentMonthTransaction.category = "Shopping"
        currentMonthTransaction.date = currentMonthDate

        let lastMonthTransaction = Transaction(context: testContext)
        lastMonthTransaction.id = UUID()
        lastMonthTransaction.amount = -200.0
        lastMonthTransaction.category = "Utilities"
        lastMonthTransaction.date = lastMonthDate

        try testContext.save()

        // Act: Calculate metrics
        let metrics = metricsService.calculateMetrics()

        // Assert: Validate monthly spending uses only current month real data
        XCTAssertEqual(metrics.monthlySpending, 300.0,
                      "Monthly spending must use real current month transaction data")
    }

    /// Test 3: Validate trend calculations use historical real data
    func testTrendCalculations_UseHistoricalRealData() throws {
        // Arrange: Create historical transactions for trend calculation
        let calendar = Calendar.current
        let now = Date()

        let previousMonthDate = calendar.date(byAdding: .month, value: -1, to: now)!

        // Previous month transaction
        let previousTransaction = Transaction(context: testContext)
        previousTransaction.id = UUID()
        previousTransaction.amount = -500.0
        previousTransaction.category = "Previous Expense"
        previousTransaction.date = previousMonthDate

        try testContext.save()

        // Act: Calculate metrics
        let metrics = metricsService.calculateMetrics()

        // Assert: Validate trend calculations based on real historical data
        // With zero current month spending, trend should show decrease
        switch metrics.spendingTrend {
        case .down(let percent):
            XCTAssertGreaterThan(percent, 0, "Spending trend should show decrease based on real data")
        case .neutral, .up:
            XCTFail("Spending trend must reflect real historical data comparison")
        }
    }

    /// Test 4: Validate empty database scenario returns zero metrics (no fallback to mock data)
    func testEmptyDatabase_ReturnsZeroMetrics_NoMockDataFallback() throws {
        // Arrange: Ensure empty database
        clearTestData()

        // Act: Calculate metrics on empty database
        let metrics = metricsService.calculateMetrics()
        let dashboardResults = try dashboardService.calculateDashboardMetrics()

        // Assert: Validate zero values - no mock data should appear
        XCTAssertEqual(metrics.totalBalance, 0.0, "Empty database should return zero balance")
        XCTAssertEqual(metrics.totalTransactions, 0, "Empty database should return zero count")
        XCTAssertEqual(metrics.monthlySpending, 0.0, "Empty database should return zero spending")
        XCTAssertEqual(dashboardResults.0, 0.0, "Dashboard service should return zero balance")
        XCTAssertEqual(dashboardResults.1, 0, "Dashboard service should return zero count")
        XCTAssertTrue(dashboardResults.2.isEmpty, "Dashboard service should return empty recent transactions")
    }

    /// Test 5: Validate data integrity across multiple calculations
    func testDataIntegrity_MultipleCalculations_ConsistentRealData() throws {
        // Arrange: Create test transactions
        let testAmount = 1000.0
        let transaction = Transaction(context: testContext)
        transaction.id = UUID()
        transaction.amount = testAmount
        transaction.category = "Test Category"
        transaction.date = Date()

        try testContext.save()

        // Act: Calculate metrics multiple times
        let metrics1 = metricsService.calculateMetrics()
        let metrics2 = metricsService.calculateMetrics()
        let dashboardResults1 = try dashboardService.calculateDashboardMetrics()
        let dashboardResults2 = try dashboardService.calculateDashboardMetrics()

        // Assert: Validate consistent results across multiple calculations
        XCTAssertEqual(metrics1.totalBalance, metrics2.totalBalance,
                      "Multiple calculations must return consistent real data results")
        XCTAssertEqual(metrics1.totalTransactions, metrics2.totalTransactions,
                      "Transaction count must be consistent across calculations")
        XCTAssertEqual(dashboardResults1.0, dashboardResults2.0,
                      "Dashboard service must return consistent results")
        XCTAssertEqual(dashboardResults1.1, dashboardResults2.1,
                      "Dashboard service count must be consistent")
    }

    // MARK: - Helper Methods

    private func clearTestData() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Transaction")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)

        do {
            try testContext.execute(deleteRequest)
            try testContext.save()
        } catch {
            print("Failed to clear test data: \(error)")
        }
    }
}