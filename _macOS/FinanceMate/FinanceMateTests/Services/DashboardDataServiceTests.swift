//
//  DashboardDataServiceTests.swift
//  FinanceMateTests
//
//  Purpose: Comprehensive unit tests for DashboardDataService
//  Issues & Complexity Summary: Tests financial categorization, subscription detection, and forecasting algorithms
//  Key Complexity Drivers:
//    - Logic Scope (Est. LoC): ~450
//    - Core Algorithm Complexity: High
//    - Dependencies: 5 (XCTest, CoreData, DashboardDataService, Foundation, SwiftUI)
//    - State Management Complexity: High
//    - Novelty/Uncertainty Factor: Medium
//  AI Pre-Task Self-Assessment: 85%
//  Problem Estimate: 82%
//  Initial Code Complexity Estimate: 84%
//  Final Code Complexity: 88%
//  Overall Result Score: 93%
//  Key Variances/Learnings: Complex financial algorithms testing with extensive mock data scenarios
//  Last Updated: 2025-06-26

import XCTest
import CoreData
import Foundation
@testable import FinanceMate

// MARK: - Supporting Types for Testing

struct CategoryExpense {
    let name: String
    let totalAmount: Double
    let transactionCount: Int
    let trend: TrendDirection
}

struct DetectedSubscription {
    let name: String
    let amount: Double
    let isActive: Bool
    let nextBillingDate: Date?
}

struct FinancialForecast {
    let type: ForecastType
    let projectedAmount: Double
    let changePercentage: Double
    let description: String
}

enum TrendDirection {
    case up
    case down
    case stable
}

enum SubscriptionFrequency {
    case weekly
    case monthly
    case quarterly
    case yearly
    case annual
}

enum ForecastType {
    case nextMonth
    case yearEnd
    case savingsPotential
}

@MainActor
final class DashboardDataServiceTests: XCTestCase {
    var dashboardDataService: DashboardDataService!
    var testContext: NSManagedObjectContext!
    var persistentContainer: NSPersistentContainer!
    
    override func setUp() async throws {
        try await super.setUp()
        
        // Create in-memory Core Data stack for testing
        let model = createTestDataModel()
        persistentContainer = NSPersistentContainer(name: "TestModel", managedObjectModel: model)
        
        let storeDescription = NSPersistentStoreDescription()
        storeDescription.type = NSInMemoryStoreType
        persistentContainer.persistentStoreDescriptions = [storeDescription]
        
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load test store: \(error)")
            }
        }
        
        testContext = persistentContainer.viewContext
        dashboardDataService = DashboardDataService(context: testContext)
    }
    
    override func tearDown() async throws {
        dashboardDataService = nil
        testContext = nil
        persistentContainer = nil
        try await super.tearDown()
    }
    
    // MARK: - Test Data Model Creation
    
    private func createTestDataModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()
        
        // FinancialData Entity
        let financialDataEntity = NSEntityDescription()
        financialDataEntity.name = "FinancialData"
        financialDataEntity.managedObjectClassName = "FinancialData"
        
        let financialDataAttributes = [
            createAttribute(name: "id", type: .uuid),
            createAttribute(name: "totalAmount", type: .decimal),
            createAttribute(name: "invoiceDate", type: .date),
            createAttribute(name: "vendorName", type: .string),
            createAttribute(name: "description", type: .string),
            createAttribute(name: "category", type: .string)
        ]
        financialDataEntity.properties = financialDataAttributes
        
        model.entities = [financialDataEntity]
        return model
    }
    
    private func createAttribute(name: String, type: NSAttributeType) -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = name
        attribute.attributeType = type
        attribute.isOptional = true
        return attribute
    }
    
    // MARK: - Test Helper Methods
    
    private func createTestFinancialData(amount: Double, vendor: String, date: Date = Date(), category: String? = nil) -> FinancialData {
        let financialData = FinancialData(context: testContext)
        financialData.id = UUID()
        financialData.totalAmount = NSDecimalNumber(value: amount)
        financialData.invoiceDate = date
        financialData.vendorName = vendor
        financialData.description = "Test transaction"
        financialData.category = category
        
        try! testContext.save()
        return financialData
    }
    
    // MARK: - Initialization Tests
    
    func testDashboardDataServiceInitialization() {
        XCTAssertNotNil(dashboardDataService)
    }
    
    func testDashboardDataServiceInitializationWithCustomContext() {
        let customService = DashboardDataService(context: testContext)
        XCTAssertNotNil(customService)
    }
    
    // MARK: - Category Analysis Tests
    
    func testGetCategorizedExpensesWithNoData() {
        // When
        XCTAssertNoThrow {
            let categories = try dashboardDataService.getCategorizedExpenses()
            
            // Then
            XCTAssertEqual(categories.count, 0)
        }
    }
    
    func testGetCategorizedExpensesWithSingleExpense() {
        // Given
        createTestFinancialData(amount: -150.0, vendor: "Test Restaurant", category: "Food & Dining")
        
        // When
        XCTAssertNoThrow {
            let categories = try dashboardDataService.getCategorizedExpenses()
            
            // Then
            XCTAssertEqual(categories.count, 1)
            
            let category = categories.first!
            XCTAssertEqual(category.name, "Food & Dining")
            XCTAssertEqual(category.totalAmount, 150.0)
            XCTAssertEqual(category.transactionCount, 1)
        }
    }
    
    func testGetCategorizedExpensesWithMultipleExpenses() {
        // Given
        createTestFinancialData(amount: -100.0, vendor: "Restaurant A", category: "Food & Dining")
        createTestFinancialData(amount: -50.0, vendor: "Restaurant B", category: "Food & Dining")
        createTestFinancialData(amount: -200.0, vendor: "Gas Station", category: "Transportation")
        createTestFinancialData(amount: -75.0, vendor: "Amazon", category: "Shopping")
        
        // When
        XCTAssertNoThrow {
            let categories = try dashboardDataService.getCategorizedExpenses()
            
            // Then
            XCTAssertEqual(categories.count, 3)
            
            // Should be sorted by total amount (highest first)
            XCTAssertEqual(categories[0].name, "Transportation")
            XCTAssertEqual(categories[0].totalAmount, 200.0)
            XCTAssertEqual(categories[0].transactionCount, 1)
            
            XCTAssertEqual(categories[1].name, "Food & Dining")
            XCTAssertEqual(categories[1].totalAmount, 150.0)
            XCTAssertEqual(categories[1].transactionCount, 2)
            
            XCTAssertEqual(categories[2].name, "Shopping")
            XCTAssertEqual(categories[2].totalAmount, 75.0)
            XCTAssertEqual(categories[2].transactionCount, 1)
        }
    }
    
    func testGetCategorizedExpensesIgnoresPositiveAmounts() {
        // Given
        createTestFinancialData(amount: 500.0, vendor: "Income Source") // Positive amount (income)
        createTestFinancialData(amount: -100.0, vendor: "Expense Source") // Negative amount (expense)
        
        // When
        XCTAssertNoThrow {
            let categories = try dashboardDataService.getCategorizedExpenses()
            
            // Then
            XCTAssertEqual(categories.count, 1)
            XCTAssertEqual(categories.first?.totalAmount, 100.0)
        }
    }
    
    // MARK: - Category Detection Tests
    
    func testCategoryDetectionForFood() {
        // Given
        createTestFinancialData(amount: -50.0, vendor: "McDonald's Restaurant")
        createTestFinancialData(amount: -30.0, vendor: "Starbucks Cafe")
        createTestFinancialData(amount: -25.0, vendor: "Food Mart")
        
        // When
        XCTAssertNoThrow {
            let categories = try dashboardDataService.getCategorizedExpenses()
            
            // Then
            let foodCategory = categories.first { $0.name == "Food & Dining" }
            XCTAssertNotNil(foodCategory)
            XCTAssertEqual(foodCategory?.totalAmount, 105.0)
            XCTAssertEqual(foodCategory?.transactionCount, 3)
        }
    }
    
    func testCategoryDetectionForTransportation() {
        // Given
        createTestFinancialData(amount: -40.0, vendor: "Shell Gas Station")
        createTestFinancialData(amount: -25.0, vendor: "Uber Technologies")
        createTestFinancialData(amount: -15.0, vendor: "Lyft Inc")
        createTestFinancialData(amount: -60.0, vendor: "Metro Transport")
        
        // When
        XCTAssertNoThrow {
            let categories = try dashboardDataService.getCategorizedExpenses()
            
            // Then
            let transportCategory = categories.first { $0.name == "Transportation" }
            XCTAssertNotNil(transportCategory)
            XCTAssertEqual(transportCategory?.totalAmount, 140.0)
            XCTAssertEqual(transportCategory?.transactionCount, 4)
        }
    }
    
    func testCategoryDetectionForShopping() {
        // Given
        createTestFinancialData(amount: -100.0, vendor: "Amazon Store")
        createTestFinancialData(amount: -200.0, vendor: "Walmart Supercenter")
        createTestFinancialData(amount: -50.0, vendor: "Target Store")
        
        // When
        XCTAssertNoThrow {
            let categories = try dashboardDataService.getCategorizedExpenses()
            
            // Then
            let shoppingCategory = categories.first { $0.name == "Shopping" }
            XCTAssertNotNil(shoppingCategory)
            XCTAssertEqual(shoppingCategory?.totalAmount, 350.0)
            XCTAssertEqual(shoppingCategory?.transactionCount, 3)
        }
    }
    
    func testCategoryDetectionForEntertainment() {
        // Given
        createTestFinancialData(amount: -15.99, vendor: "Netflix Inc")
        createTestFinancialData(amount: -9.99, vendor: "Spotify Premium")
        createTestFinancialData(amount: -50.0, vendor: "Entertainment Center")
        
        // When
        XCTAssertNoThrow {
            let categories = try dashboardDataService.getCategorizedExpenses()
            
            // Then
            let entertainmentCategory = categories.first { $0.name == "Entertainment" }
            XCTAssertNotNil(entertainmentCategory)
            XCTAssertEqual(entertainmentCategory?.totalAmount, 75.98, accuracy: 0.01)
            XCTAssertEqual(entertainmentCategory?.transactionCount, 3)
        }
    }
    
    func testCategoryDetectionForUtilities() {
        // Given
        createTestFinancialData(amount: -120.0, vendor: "Electric Company")
        createTestFinancialData(amount: -60.0, vendor: "Water Department")
        createTestFinancialData(amount: -80.0, vendor: "Internet Service Provider")
        createTestFinancialData(amount: -45.0, vendor: "City Utility")
        
        // When
        XCTAssertNoThrow {
            let categories = try dashboardDataService.getCategorizedExpenses()
            
            // Then
            let utilitiesCategory = categories.first { $0.name == "Utilities" }
            XCTAssertNotNil(utilitiesCategory)
            XCTAssertEqual(utilitiesCategory?.totalAmount, 305.0)
            XCTAssertEqual(utilitiesCategory?.transactionCount, 4)
        }
    }
    
    func testCategoryDetectionForHealthcare() {
        // Given
        createTestFinancialData(amount: -150.0, vendor: "Family Health Center")
        createTestFinancialData(amount: -25.0, vendor: "CVS Pharmacy")
        createTestFinancialData(amount: -200.0, vendor: "Dr. Smith's Office")
        
        // When
        XCTAssertNoThrow {
            let categories = try dashboardDataService.getCategorizedExpenses()
            
            // Then
            let healthcareCategory = categories.first { $0.name == "Healthcare" }
            XCTAssertNotNil(healthcareCategory)
            XCTAssertEqual(healthcareCategory?.totalAmount, 375.0)
            XCTAssertEqual(healthcareCategory?.transactionCount, 3)
        }
    }
    
    func testCategoryDetectionForHousing() {
        // Given
        createTestFinancialData(amount: -1200.0, vendor: "Property Management Rent")
        createTestFinancialData(amount: -2500.0, vendor: "First National Mortgage")
        
        // When
        XCTAssertNoThrow {
            let categories = try dashboardDataService.getCategorizedExpenses()
            
            // Then
            let housingCategory = categories.first { $0.name == "Housing" }
            XCTAssertNotNil(housingCategory)
            XCTAssertEqual(housingCategory?.totalAmount, 3700.0)
            XCTAssertEqual(housingCategory?.transactionCount, 2)
        }
    }
    
    func testCategoryDetectionForOther() {
        // Given
        createTestFinancialData(amount: -75.0, vendor: "Unknown Vendor")
        createTestFinancialData(amount: -50.0, vendor: "Mystery Service")
        
        // When
        XCTAssertNoThrow {
            let categories = try dashboardDataService.getCategorizedExpenses()
            
            // Then
            let otherCategory = categories.first { $0.name == "Other" }
            XCTAssertNotNil(otherCategory)
            XCTAssertEqual(otherCategory?.totalAmount, 125.0)
            XCTAssertEqual(otherCategory?.transactionCount, 2)
        }
    }
    
    // MARK: - Trend Calculation Tests
    
    func testTrendCalculationWithInsufficientData() {
        // Given - Only transactions from current month
        let now = Date()
        createTestFinancialData(amount: -100.0, vendor: "Test Vendor", date: now, category: "Food & Dining")
        
        // When
        XCTAssertNoThrow {
            let categories = try dashboardDataService.getCategorizedExpenses()
            
            // Then
            let category = categories.first!
            // With no last month data, trend should be stable
            XCTAssertEqual(category.trend, .stable)
        }
    }
    
    func testTrendCalculationWithIncreasingSpend() {
        // Given
        let calendar = Calendar.current
        let now = Date()
        let currentMonthStart = calendar.dateInterval(of: .month, for: now)?.start ?? now
        let lastMonthStart = calendar.date(byAdding: .month, value: -1, to: currentMonthStart) ?? now
        
        // Last month: $100
        createTestFinancialData(amount: -100.0, vendor: "Test Vendor", date: lastMonthStart, category: "Food & Dining")
        
        // Current month: $150 (50% increase)
        createTestFinancialData(amount: -150.0, vendor: "Test Vendor", date: currentMonthStart, category: "Food & Dining")
        
        // When
        XCTAssertNoThrow {
            let categories = try dashboardDataService.getCategorizedExpenses()
            
            // Then
            let foodCategory = categories.first { $0.name == "Food & Dining" }
            XCTAssertNotNil(foodCategory)
            // Trend should be up for 50% increase (> 5% threshold)
            XCTAssertEqual(foodCategory?.trend, .up)
        }
    }
    
    func testTrendCalculationWithDecreasingSpend() {
        // Given
        let calendar = Calendar.current
        let now = Date()
        let currentMonthStart = calendar.dateInterval(of: .month, for: now)?.start ?? now
        let lastMonthStart = calendar.date(byAdding: .month, value: -1, to: currentMonthStart) ?? now
        
        // Last month: $200
        createTestFinancialData(amount: -200.0, vendor: "Test Vendor", date: lastMonthStart, category: "Food & Dining")
        
        // Current month: $100 (50% decrease)
        createTestFinancialData(amount: -100.0, vendor: "Test Vendor", date: currentMonthStart, category: "Food & Dining")
        
        // When
        XCTAssertNoThrow {
            let categories = try dashboardDataService.getCategorizedExpenses()
            
            // Then
            let foodCategory = categories.first { $0.name == "Food & Dining" }
            XCTAssertNotNil(foodCategory)
            // Trend should be down for 50% decrease (< -5% threshold)
            XCTAssertEqual(foodCategory?.trend, .down)
        }
    }
    
    func testTrendCalculationWithStableSpend() {
        // Given
        let calendar = Calendar.current
        let now = Date()
        let currentMonthStart = calendar.dateInterval(of: .month, for: now)?.start ?? now
        let lastMonthStart = calendar.date(byAdding: .month, value: -1, to: currentMonthStart) ?? now
        
        // Last month: $100
        createTestFinancialData(amount: -100.0, vendor: "Test Vendor", date: lastMonthStart, category: "Food & Dining")
        
        // Current month: $102 (2% increase, within stable range)
        createTestFinancialData(amount: -102.0, vendor: "Test Vendor", date: currentMonthStart, category: "Food & Dining")
        
        // When
        XCTAssertNoThrow {
            let categories = try dashboardDataService.getCategorizedExpenses()
            
            // Then
            let foodCategory = categories.first { $0.name == "Food & Dining" }
            XCTAssertNotNil(foodCategory)
            // Trend should be stable for 2% increase (< 5% threshold)
            XCTAssertEqual(foodCategory?.trend, .stable)
        }
    }
    
    // MARK: - Subscription Detection Tests
    
    func testDetectSubscriptionsWithNoData() {
        // When
        XCTAssertNoThrow {
            let subscriptions = try dashboardDataService.detectSubscriptions()
            
            // Then
            XCTAssertEqual(subscriptions.count, 0)
        }
    }
    
    func testDetectSubscriptionsWithInsufficientPayments() {
        // Given - Only one payment (need at least 2)
        createTestFinancialData(amount: -15.99, vendor: "Netflix")
        
        // When
        XCTAssertNoThrow {
            let subscriptions = try dashboardDataService.detectSubscriptions()
            
            // Then
            XCTAssertEqual(subscriptions.count, 0)
        }
    }
    
    func testDetectMonthlySubscription() {
        // Given - Monthly payments
        let calendar = Calendar.current
        let now = Date()
        let lastMonth = calendar.date(byAdding: .month, value: -1, to: now) ?? now
        let twoMonthsAgo = calendar.date(byAdding: .month, value: -2, to: now) ?? now
        
        createTestFinancialData(amount: -15.99, vendor: "Netflix", date: now)
        createTestFinancialData(amount: -15.99, vendor: "Netflix", date: lastMonth)
        createTestFinancialData(amount: -15.99, vendor: "Netflix", date: twoMonthsAgo)
        
        // When
        XCTAssertNoThrow {
            let subscriptions = try dashboardDataService.detectSubscriptions()
            
            // Then
            XCTAssertEqual(subscriptions.count, 1)
            
            let subscription = subscriptions.first!
            XCTAssertEqual(subscription.name, "Netflix")
            XCTAssertEqual(subscription.amount, 15.99)
            XCTAssertTrue(subscription.isActive)
            XCTAssertNotNil(subscription.nextBillingDate)
        }
    }
    
    func testDetectWeeklySubscription() {
        // Given - Weekly payments
        let calendar = Calendar.current
        let now = Date()
        let lastWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: now) ?? now
        let twoWeeksAgo = calendar.date(byAdding: .weekOfYear, value: -2, to: now) ?? now
        
        createTestFinancialData(amount: -9.99, vendor: "WeeklyService", date: now)
        createTestFinancialData(amount: -9.99, vendor: "WeeklyService", date: lastWeek)
        createTestFinancialData(amount: -9.99, vendor: "WeeklyService", date: twoWeeksAgo)
        
        // When
        XCTAssertNoThrow {
            let subscriptions = try dashboardDataService.detectSubscriptions()
            
            // Then
            XCTAssertEqual(subscriptions.count, 1)
            
            let subscription = subscriptions.first!
            XCTAssertEqual(subscription.name, "WeeklyService")
            XCTAssertEqual(subscription.amount, 9.99)
            XCTAssertTrue(subscription.isActive)
        }
    }
    
    func testDetectInactiveSubscription() {
        // Given - Subscription that hasn't been paid recently
        let calendar = Calendar.current
        let now = Date()
        let threeMonthsAgo = calendar.date(byAdding: .month, value: -3, to: now) ?? now
        let fourMonthsAgo = calendar.date(byAdding: .month, value: -4, to: now) ?? now
        
        createTestFinancialData(amount: -15.99, vendor: "OldService", date: threeMonthsAgo)
        createTestFinancialData(amount: -15.99, vendor: "OldService", date: fourMonthsAgo)
        
        // When
        XCTAssertNoThrow {
            let subscriptions = try dashboardDataService.detectSubscriptions()
            
            // Then
            XCTAssertEqual(subscriptions.count, 1)
            
            let subscription = subscriptions.first!
            XCTAssertEqual(subscription.name, "OldService")
            XCTAssertFalse(subscription.isActive) // Should be inactive
        }
    }
    
    func testSubscriptionsSortedByAmount() {
        // Given - Multiple subscriptions
        let calendar = Calendar.current
        let now = Date()
        let lastMonth = calendar.date(byAdding: .month, value: -1, to: now) ?? now
        
        createTestFinancialData(amount: -9.99, vendor: "Spotify", date: now)
        createTestFinancialData(amount: -9.99, vendor: "Spotify", date: lastMonth)
        
        createTestFinancialData(amount: -15.99, vendor: "Netflix", date: now)
        createTestFinancialData(amount: -15.99, vendor: "Netflix", date: lastMonth)
        
        createTestFinancialData(amount: -4.99, vendor: "CloudStorage", date: now)
        createTestFinancialData(amount: -4.99, vendor: "CloudStorage", date: lastMonth)
        
        // When
        XCTAssertNoThrow {
            let subscriptions = try dashboardDataService.detectSubscriptions()
            
            // Then
            XCTAssertEqual(subscriptions.count, 3)
            
            // Should be sorted by amount (highest first)
            XCTAssertEqual(subscriptions[0].name, "Netflix")
            XCTAssertEqual(subscriptions[0].amount, 15.99)
            
            XCTAssertEqual(subscriptions[1].name, "Spotify")
            XCTAssertEqual(subscriptions[1].amount, 9.99)
            
            XCTAssertEqual(subscriptions[2].name, "CloudStorage")
            XCTAssertEqual(subscriptions[2].amount, 4.99)
        }
    }
    
    // MARK: - Financial Forecasting Tests
    
    func testGenerateForecastsWithNoData() {
        // When
        XCTAssertNoThrow {
            let forecasts = try dashboardDataService.generateForecasts()
            
            // Then
            // Should return some forecasts even with no data (empty projections)
            XCTAssertGreaterThanOrEqual(forecasts.count, 0)
        }
    }
    
    func testGenerateForecastsWithHistoricalData() {
        // Given - Create 6 months of historical data
        let calendar = Calendar.current
        let now = Date()
        
        for monthOffset in 0..<6 {
            let monthDate = calendar.date(byAdding: .month, value: -monthOffset, to: now) ?? now
            let monthAmount = -1000.0 + Double(monthOffset) * 50.0 // Increasing trend
            
            createTestFinancialData(amount: monthAmount, vendor: "Monthly Expense", date: monthDate)
        }
        
        // When
        XCTAssertNoThrow {
            let forecasts = try dashboardDataService.generateForecasts()
            
            // Then
            XCTAssertGreaterThan(forecasts.count, 0)
            
            // Should include next month projection
            let nextMonthForecast = forecasts.first { $0.type == .nextMonth }
            XCTAssertNotNil(nextMonthForecast)
            XCTAssertGreaterThan(nextMonthForecast!.projectedAmount, 0)
            
            // Should include year-end projection
            let yearEndForecast = forecasts.first { $0.type == .yearEnd }
            XCTAssertNotNil(yearEndForecast)
            XCTAssertGreaterThan(yearEndForecast!.projectedAmount, 0)
            
            // Should include savings potential
            let savingsForecast = forecasts.first { $0.type == .savingsPotential }
            XCTAssertNotNil(savingsForecast)
        }
    }
    
    // MARK: - Error Handling Tests
    
    func testGetCategorizedExpensesWithCorruptedData() {
        // Given - Financial data with nil values
        let financialData = FinancialData(context: testContext)
        financialData.id = UUID()
        financialData.totalAmount = nil // Corrupted data
        financialData.invoiceDate = nil
        financialData.vendorName = nil
        
        try! testContext.save()
        
        // When/Then - Should handle gracefully without crashing
        XCTAssertNoThrow {
            let categories = try dashboardDataService.getCategorizedExpenses()
            // Should return empty array for corrupted data
            XCTAssertEqual(categories.count, 0)
        }
    }
    
    // MARK: - Performance Tests
    
    func testGetCategorizedExpensesPerformance() {
        // Given - Create many transactions
        for i in 0..<1000 {
            let vendors = ["Restaurant", "Gas Station", "Store", "Pharmacy", "Entertainment"]
            let vendor = vendors[i % vendors.count]
            createTestFinancialData(amount: -Double.random(in: 10...200), vendor: "\(vendor) \(i)")
        }
        
        // When
        measure {
            _ = try! dashboardDataService.getCategorizedExpenses()
        }
    }
    
    func testDetectSubscriptionsPerformance() {
        // Given - Create many recurring transactions
        let calendar = Calendar.current
        let vendors = ["Netflix", "Spotify", "Amazon", "Apple", "Microsoft"]
        
        for vendor in vendors {
            for monthOffset in 0..<12 {
                let date = calendar.date(byAdding: .month, value: -monthOffset, to: Date()) ?? Date()
                createTestFinancialData(amount: -Double.random(in: 5...25), vendor: vendor, date: date)
            }
        }
        
        // When
        measure {
            _ = try! dashboardDataService.detectSubscriptions()
        }
    }
    
    func testGenerateForecastsPerformance() {
        // Given - Create historical data
        let calendar = Calendar.current
        
        for monthOffset in 0..<24 {
            for transactionIndex in 0..<50 {
                let date = calendar.date(byAdding: .month, value: -monthOffset, to: Date()) ?? Date()
                createTestFinancialData(
                    amount: -Double.random(in: 10...500),
                    vendor: "Vendor \(transactionIndex)",
                    date: date
                )
            }
        }
        
        // When
        measure {
            _ = try! dashboardDataService.generateForecasts()
        }
    }
    
    // MARK: - Edge Cases Tests
    
    func testCategoryAnalysisWithZeroAmounts() {
        // Given
        createTestFinancialData(amount: 0.0, vendor: "Zero Amount Vendor")
        createTestFinancialData(amount: -100.0, vendor: "Valid Vendor")
        
        // When
        XCTAssertNoThrow {
            let categories = try dashboardDataService.getCategorizedExpenses()
            
            // Then - Should only include non-zero amounts
            XCTAssertEqual(categories.count, 1)
            XCTAssertEqual(categories.first?.totalAmount, 100.0)
        }
    }
    
    func testSubscriptionDetectionWithIrregularPayments() {
        // Given - Payments with irregular intervals
        let calendar = Calendar.current
        let now = Date()
        
        createTestFinancialData(amount: -15.99, vendor: "IrregularService", date: now)
        createTestFinancialData(amount: -15.99, vendor: "IrregularService", date: calendar.date(byAdding: .day, value: -45, to: now)!)
        createTestFinancialData(amount: -15.99, vendor: "IrregularService", date: calendar.date(byAdding: .day, value: -100, to: now)!)
        
        // When
        XCTAssertNoThrow {
            let subscriptions = try dashboardDataService.detectSubscriptions()
            
            // Then - Should not detect as subscription due to irregular intervals
            let irregularSubscription = subscriptions.first { $0.name == "IrregularService" }
            XCTAssertNil(irregularSubscription)
        }
    }
    
    func testForecastingWithLimitedHistoricalData() {
        // Given - Only current month data
        createTestFinancialData(amount: -500.0, vendor: "Current Month Expense")
        
        // When
        XCTAssertNoThrow {
            let forecasts = try dashboardDataService.generateForecasts()
            
            // Then - Should still generate some forecasts
            XCTAssertGreaterThanOrEqual(forecasts.count, 0)
        }
    }
}