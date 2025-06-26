//
//  DashboardDataTests.swift
//  FinanceMateTests
//
//  Purpose: TDD tests for real dashboard data integration
//

import XCTest
import CoreData
@testable import FinanceMate

class DashboardDataTests: XCTestCase {
    var testContext: NSManagedObjectContext!
    var sut: DashboardDataService!

    override func setUp() {
        super.setUp()

        // Create in-memory Core Data stack for testing
        let container = NSPersistentContainer(name: "FinanceMate")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]

        container.loadPersistentStores { _, error in
            XCTAssertNil(error)
        }

        testContext = container.viewContext
        sut = DashboardDataService(context: testContext)
    }

    override func tearDown() {
        testContext = nil
        sut = nil
        super.tearDown()
    }

    // MARK: - Category Tests

    func testCategorizeExpenses_shouldGroupByCategory() throws {
        // Given: Financial data with different categories
        createFinancialData(amount: -50.0, category: "Food & Dining", vendor: "Restaurant A")
        createFinancialData(amount: -30.0, category: "Food & Dining", vendor: "Cafe B")
        createFinancialData(amount: -100.0, category: "Transportation", vendor: "Gas Station")
        createFinancialData(amount: -200.0, category: "Shopping", vendor: "Store X")

        try testContext.save()

        // When: Categorizing expenses
        let categories = try sut.getCategorizedExpenses()

        // Then: Should group correctly
        XCTAssertEqual(categories.count, 3)

        let foodCategory = categories.first { $0.name == "Food & Dining" }
        XCTAssertNotNil(foodCategory)
        XCTAssertEqual(foodCategory?.totalAmount, 80.0)
        XCTAssertEqual(foodCategory?.transactionCount, 2)

        let transportCategory = categories.first { $0.name == "Transportation" }
        XCTAssertNotNil(transportCategory)
        XCTAssertEqual(transportCategory?.totalAmount, 100.0)
        XCTAssertEqual(transportCategory?.transactionCount, 1)
    }

    func testCategorizeExpenses_shouldCalculateTrends() throws {
        // Given: Current month expenses
        let now = Date()
        createFinancialData(amount: -100.0, category: "Food & Dining", date: now)

        // And: Last month expenses
        let lastMonth = Calendar.current.date(byAdding: .month, value: -1, to: now)!
        createFinancialData(amount: -80.0, category: "Food & Dining", date: lastMonth)

        try testContext.save()

        // When: Getting categorized expenses
        let categories = try sut.getCategorizedExpenses()

        // Then: Should calculate trend
        let foodCategory = categories.first { $0.name == "Food & Dining" }
        XCTAssertNotNil(foodCategory)
        XCTAssertEqual(foodCategory?.trend, .up) // Spending increased
        XCTAssertEqual(foodCategory?.trendPercentage, 25.0) // 25% increase
    }

    // MARK: - Subscription Tests

    func testDetectSubscriptions_shouldIdentifyRecurringPayments() throws {
        // Given: Recurring monthly payments
        let baseDate = Date()
        for monthOffset in 0..<3 {
            let date = Calendar.current.date(byAdding: .month, value: -monthOffset, to: baseDate)!
            createFinancialData(amount: -15.99, vendor: "Netflix", date: date)
            createFinancialData(amount: -9.99, vendor: "Spotify", date: date)
        }

        try testContext.save()

        // When: Detecting subscriptions
        let subscriptions = try sut.detectSubscriptions()

        // Then: Should identify recurring payments
        XCTAssertEqual(subscriptions.count, 2)

        let netflix = subscriptions.first { $0.name == "Netflix" }
        XCTAssertNotNil(netflix)
        XCTAssertEqual(netflix?.amount, 15.99)
        XCTAssertEqual(netflix?.frequency, .monthly)
        XCTAssertTrue(netflix?.isActive ?? false)

        let spotify = subscriptions.first { $0.name == "Spotify" }
        XCTAssertNotNil(spotify)
        XCTAssertEqual(spotify?.amount, 9.99)
    }

    func testDetectSubscriptions_shouldCalculateNextBilling() throws {
        // Given: A subscription paid on the 15th
        let lastPayment = Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 15))!
        createFinancialData(amount: -15.99, vendor: "Netflix", date: lastPayment)

        // Previous payments
        for monthOffset in 1...2 {
            let date = Calendar.current.date(byAdding: .month, value: -monthOffset, to: lastPayment)!
            createFinancialData(amount: -15.99, vendor: "Netflix", date: date)
        }

        try testContext.save()

        // When: Detecting subscriptions
        let subscriptions = try sut.detectSubscriptions()

        // Then: Should calculate next billing date
        let netflix = subscriptions.first { $0.name == "Netflix" }
        XCTAssertNotNil(netflix)

        let expectedNextBilling = Calendar.current.date(byAdding: .month, value: 1, to: lastPayment)!
        XCTAssertEqual(netflix?.nextBillingDate, expectedNextBilling)
    }

    // MARK: - Forecast Tests

    func testGenerateForecasts_shouldProjectBasedOnTrends() throws {
        // Given: 6 months of historical data with increasing expenses
        let baseAmount = 1000.0
        for monthOffset in 0..<6 {
            let date = Calendar.current.date(byAdding: .month, value: -monthOffset, to: Date())!
            let amount = baseAmount + (Double(monthOffset) * 50.0) // Increasing trend
            createFinancialData(amount: -amount, date: date)
        }

        try testContext.save()

        // When: Generating forecasts
        let forecasts = try sut.generateForecasts()

        // Then: Should project future expenses
        XCTAssertGreaterThan(forecasts.count, 0)

        let nextMonthForecast = forecasts.first { $0.type == .nextMonth }
        XCTAssertNotNil(nextMonthForecast)
        XCTAssertGreaterThan(nextMonthForecast?.projectedAmount ?? 0, baseAmount)

        let yearEndForecast = forecasts.first { $0.type == .yearEnd }
        XCTAssertNotNil(yearEndForecast)
    }

    func testGenerateForecasts_shouldIdentifySavingsPotential() throws {
        // Given: Expenses with some discretionary spending
        createFinancialData(amount: -50.0, category: "Food & Dining")
        createFinancialData(amount: -30.0, category: "Entertainment")
        createFinancialData(amount: -100.0, category: "Utilities") // Essential
        createFinancialData(amount: -200.0, category: "Rent") // Essential

        try testContext.save()

        // When: Generating forecasts
        let forecasts = try sut.generateForecasts()

        // Then: Should identify savings potential
        let savingsPotential = forecasts.first { $0.type == .savingsPotential }
        XCTAssertNotNil(savingsPotential)
        XCTAssertGreaterThan(savingsPotential?.projectedAmount ?? 0, 0)
    }

    // MARK: - Helper Methods

    private func createFinancialData(
        amount: Double,
        category: String? = nil,
        vendor: String? = nil,
        date: Date = Date()
    ) {
        let data = FinancialData(context: testContext)
        data.id = UUID()
        data.totalAmount = NSDecimalNumber(value: amount)
        data.invoiceDate = date
        data.vendorName = vendor
        data.category = category
        data.currency = "USD"
    }
}

// MARK: - Test Models

struct CategoryExpense {
    let name: String
    let totalAmount: Double
    let transactionCount: Int
    let trend: CategoryTrend
    let trendPercentage: Double
}

enum CategoryTrend {
    case up, down, stable
}

struct DetectedSubscription {
    let name: String
    let amount: Double
    let frequency: SubscriptionFrequency
    let isActive: Bool
    let nextBillingDate: Date?
    let lastPaymentDate: Date
}

enum SubscriptionFrequency {
    case weekly, monthly, quarterly, annual
}

struct FinancialForecast {
    let type: ForecastType
    let projectedAmount: Double
    let confidence: Double
    let description: String
    let changePercentage: Double
}

enum ForecastType {
    case nextMonth, yearEnd, savingsPotential
}
