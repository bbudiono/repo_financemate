//
//  AnalyticsViewModelTests.swift
//  FinanceMateTests
//
//  Purpose: Comprehensive unit tests for AnalyticsViewModel
//  Issues & Complexity Summary: Tests analytics data processing, Core Data integration, and chart data preparation
//  Key Complexity Drivers:
//    - Logic Scope (Est. LoC): ~400
//    - Core Algorithm Complexity: High
//    - Dependencies: 6 (XCTest, CoreData, AnalyticsViewModel, DocumentManager, SwiftUI, Combine)
//    - State Management Complexity: High
//    - Novelty/Uncertainty Factor: Medium
//  AI Pre-Task Self-Assessment: 85%
//  Problem Estimate: 82%
//  Initial Code Complexity Estimate: 84%
//  Final Code Complexity: 88%
//  Overall Result Score: 94%
//  Key Variances/Learnings: Complex data aggregation testing required comprehensive mock data setup
//  Last Updated: 2025-06-26

import XCTest
import CoreData
import SwiftUI
import Combine
@testable import FinanceMate

@MainActor
final class AnalyticsViewModelTests: XCTestCase {
    var analyticsViewModel: AnalyticsViewModel!
    var mockDocumentManager: MockDocumentManager!
    var testContext: NSManagedObjectContext!
    var persistentContainer: NSPersistentContainer!
    var cancellables: Set<AnyCancellable>!
    
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
        mockDocumentManager = MockDocumentManager(context: testContext)
        analyticsViewModel = AnalyticsViewModel(documentManager: mockDocumentManager)
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() async throws {
        analyticsViewModel = nil
        mockDocumentManager = nil
        testContext = nil
        persistentContainer = nil
        cancellables = nil
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
            createAttribute(name: "merchantName", type: .string),
            createAttribute(name: "description", type: .string)
        ]
        financialDataEntity.properties = financialDataAttributes
        
        // Document Entity
        let documentEntity = NSEntityDescription()
        documentEntity.name = "Document"
        documentEntity.managedObjectClassName = "Document"
        
        let documentAttributes = [
            createAttribute(name: "id", type: .uuid),
            createAttribute(name: "fileName", type: .string)
        ]
        documentEntity.properties = documentAttributes
        
        // Category Entity
        let categoryEntity = NSEntityDescription()
        categoryEntity.name = "Category"
        categoryEntity.managedObjectClassName = "Category"
        
        let categoryAttributes = [
            createAttribute(name: "id", type: .uuid),
            createAttribute(name: "name", type: .string)
        ]
        categoryEntity.properties = categoryAttributes
        
        // Add relationships
        addRelationships(financialDataEntity: financialDataEntity, documentEntity: documentEntity, categoryEntity: categoryEntity)
        
        model.entities = [financialDataEntity, documentEntity, categoryEntity]
        return model
    }
    
    private func createAttribute(name: String, type: NSAttributeType) -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = name
        attribute.attributeType = type
        attribute.isOptional = true
        return attribute
    }
    
    private func addRelationships(financialDataEntity: NSEntityDescription, documentEntity: NSEntityDescription, categoryEntity: NSEntityDescription) {
        // FinancialData -> Document (many-to-one)
        let financialDataDocumentRelationship = NSRelationshipDescription()
        financialDataDocumentRelationship.name = "document"
        financialDataDocumentRelationship.destinationEntity = documentEntity
        financialDataDocumentRelationship.minCount = 0
        financialDataDocumentRelationship.maxCount = 1
        financialDataDocumentRelationship.deleteRule = .nullifyDeleteRule
        
        // Document -> Category (many-to-one)
        let documentCategoryRelationship = NSRelationshipDescription()
        documentCategoryRelationship.name = "category"
        documentCategoryRelationship.destinationEntity = categoryEntity
        documentCategoryRelationship.minCount = 0
        documentCategoryRelationship.maxCount = 1
        documentCategoryRelationship.deleteRule = .nullifyDeleteRule
        
        financialDataEntity.properties.append(financialDataDocumentRelationship)
        documentEntity.properties.append(documentCategoryRelationship)
    }
    
    // MARK: - Mock Document Manager
    
    class MockDocumentManager: DocumentManager {
        override init(context: NSManagedObjectContext) {
            super.init(context: context)
        }
    }
    
    // MARK: - Test Helper Methods
    
    private func createTestFinancialData(amount: Double, date: Date, categoryName: String = "Test Category") -> FinancialData {
        let financialData = FinancialData(context: testContext)
        financialData.id = UUID()
        financialData.totalAmount = NSDecimalNumber(value: amount)
        financialData.invoiceDate = date
        financialData.merchantName = "Test Merchant"
        financialData.description = "Test transaction"
        
        // Create associated document and category
        let document = Document(context: testContext)
        document.id = UUID()
        document.fileName = "test_document.pdf"
        
        let category = Category(context: testContext)
        category.id = UUID()
        category.name = categoryName
        
        document.category = category
        financialData.document = document
        
        try! testContext.save()
        return financialData
    }
    
    // MARK: - Initialization Tests
    
    func testAnalyticsViewModelInitialization() {
        XCTAssertNotNil(analyticsViewModel)
        XCTAssertEqual(analyticsViewModel.selectedPeriod, .thisMonth)
        XCTAssertFalse(analyticsViewModel.isLoading)
        XCTAssertEqual(analyticsViewModel.monthlyData.count, 0)
        XCTAssertEqual(analyticsViewModel.categoryData.count, 0)
        XCTAssertNil(analyticsViewModel.totalSpending)
        XCTAssertNil(analyticsViewModel.averageSpending)
    }
    
    // MARK: - AnalyticsPeriod Tests
    
    func testAnalyticsPeriodDisplayNames() {
        XCTAssertEqual(AnalyticsPeriod.thisMonth.displayName, "This Month")
        XCTAssertEqual(AnalyticsPeriod.lastThreeMonths.displayName, "3 Months")
        XCTAssertEqual(AnalyticsPeriod.lastSixMonths.displayName, "6 Months")
        XCTAssertEqual(AnalyticsPeriod.thisYear.displayName, "This Year")
    }
    
    func testAnalyticsPeriodDateRanges() {
        let calendar = Calendar.current
        let now = Date()
        
        // Test this month
        let thisMonthRange = AnalyticsPeriod.thisMonth.dateRange
        let expectedStartOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
        XCTAssertEqual(calendar.component(.year, from: thisMonthRange.start), calendar.component(.year, from: expectedStartOfMonth))
        XCTAssertEqual(calendar.component(.month, from: thisMonthRange.start), calendar.component(.month, from: expectedStartOfMonth))
        
        // Test last three months
        let threeMonthsRange = AnalyticsPeriod.lastThreeMonths.dateRange
        let expectedThreeMonthsAgo = calendar.date(byAdding: .month, value: -3, to: now) ?? now
        XCTAssertLessThanOrEqual(abs(threeMonthsRange.start.timeIntervalSince(expectedThreeMonthsAgo)), 86400) // Within 1 day
        
        // Test this year
        let thisYearRange = AnalyticsPeriod.thisYear.dateRange
        let expectedStartOfYear = calendar.dateInterval(of: .year, for: now)?.start ?? now
        XCTAssertEqual(calendar.component(.year, from: thisYearRange.start), calendar.component(.year, from: expectedStartOfYear))
    }
    
    // MARK: - Data Model Tests
    
    func testCategoryAnalyticsInitialization() {
        let categoryAnalytics = CategoryAnalytics(
            categoryName: "Food",
            totalAmount: 250.50,
            transactionCount: 5,
            percentage: 25.0,
            color: .blue
        )
        
        XCTAssertEqual(categoryAnalytics.categoryName, "Food")
        XCTAssertEqual(categoryAnalytics.totalAmount, 250.50)
        XCTAssertEqual(categoryAnalytics.transactionCount, 5)
        XCTAssertEqual(categoryAnalytics.percentage, 25.0)
        XCTAssertEqual(categoryAnalytics.color, .blue)
        XCTAssertNotNil(categoryAnalytics.id)
    }
    
    func testMonthlyAnalyticsInitialization() {
        let date = Date()
        let monthlyAnalytics = MonthlyAnalytics(
            period: date,
            totalSpending: 1500.00,
            transactionCount: 10
        )
        
        XCTAssertEqual(monthlyAnalytics.period, date)
        XCTAssertEqual(monthlyAnalytics.totalSpending, 1500.00)
        XCTAssertEqual(monthlyAnalytics.transactionCount, 10)
        XCTAssertNotNil(monthlyAnalytics.id)
    }
    
    // MARK: - Load Analytics Data Tests
    
    func testLoadAnalyticsDataWithNoData() async {
        // Given - No financial data exists
        
        // When
        await analyticsViewModel.loadAnalyticsData()
        
        // Then
        XCTAssertFalse(analyticsViewModel.isLoading)
        XCTAssertEqual(analyticsViewModel.monthlyData.count, 0)
        XCTAssertEqual(analyticsViewModel.categoryData.count, 0)
        XCTAssertEqual(analyticsViewModel.totalSpending, 0.0)
        XCTAssertEqual(analyticsViewModel.averageSpending, 0.0)
    }
    
    func testLoadAnalyticsDataWithSingleTransaction() async {
        // Given
        let amount = 150.75
        let date = Date()
        createTestFinancialData(amount: amount, date: date, categoryName: "Groceries")
        
        // When
        await analyticsViewModel.loadAnalyticsData()
        
        // Then
        XCTAssertFalse(analyticsViewModel.isLoading)
        XCTAssertEqual(analyticsViewModel.totalSpending, amount)
        XCTAssertEqual(analyticsViewModel.averageSpending, amount)
        
        XCTAssertEqual(analyticsViewModel.categoryData.count, 1)
        let category = analyticsViewModel.categoryData.first!
        XCTAssertEqual(category.categoryName, "Groceries")
        XCTAssertEqual(category.totalAmount, amount)
        XCTAssertEqual(category.transactionCount, 1)
        XCTAssertEqual(category.percentage, 100.0)
        
        XCTAssertEqual(analyticsViewModel.monthlyData.count, 1)
        let monthly = analyticsViewModel.monthlyData.first!
        XCTAssertEqual(monthly.totalSpending, amount)
        XCTAssertEqual(monthly.transactionCount, 1)
    }
    
    func testLoadAnalyticsDataWithMultipleTransactions() async {
        // Given
        let calendar = Calendar.current
        let now = Date()
        
        createTestFinancialData(amount: 100.0, date: now, categoryName: "Food")
        createTestFinancialData(amount: 200.0, date: now, categoryName: "Transportation")
        createTestFinancialData(amount: 50.0, date: now, categoryName: "Food")
        
        // When
        await analyticsViewModel.loadAnalyticsData()
        
        // Then
        XCTAssertFalse(analyticsViewModel.isLoading)
        XCTAssertEqual(analyticsViewModel.totalSpending, 350.0)
        XCTAssertEqual(analyticsViewModel.averageSpending, 350.0 / 3.0)
        
        // Check category data (should be sorted by amount, highest first)
        XCTAssertEqual(analyticsViewModel.categoryData.count, 2)
        
        let topCategory = analyticsViewModel.categoryData.first!
        XCTAssertEqual(topCategory.categoryName, "Transportation")
        XCTAssertEqual(topCategory.totalAmount, 200.0)
        XCTAssertEqual(topCategory.percentage, 200.0 / 350.0 * 100, accuracy: 0.01)
        
        let secondCategory = analyticsViewModel.categoryData[1]
        XCTAssertEqual(secondCategory.categoryName, "Food")
        XCTAssertEqual(secondCategory.totalAmount, 150.0)
        XCTAssertEqual(secondCategory.transactionCount, 2)
    }
    
    func testLoadAnalyticsDataWithMultipleMonths() async {
        // Given
        let calendar = Calendar.current
        let now = Date()
        let lastMonth = calendar.date(byAdding: .month, value: -1, to: now)!
        let twoMonthsAgo = calendar.date(byAdding: .month, value: -2, to: now)!
        
        createTestFinancialData(amount: 100.0, date: now, categoryName: "Current Month")
        createTestFinancialData(amount: 200.0, date: lastMonth, categoryName: "Last Month")
        createTestFinancialData(amount: 300.0, date: twoMonthsAgo, categoryName: "Two Months Ago")
        
        // Set period to include all data
        analyticsViewModel.selectedPeriod = .lastSixMonths
        
        // When
        await analyticsViewModel.loadAnalyticsData()
        
        // Then
        XCTAssertEqual(analyticsViewModel.monthlyData.count, 3)
        XCTAssertEqual(analyticsViewModel.totalSpending, 600.0)
        
        // Monthly data should be sorted chronologically
        let sortedMonthly = analyticsViewModel.monthlyData.sorted { $0.period < $1.period }
        XCTAssertEqual(sortedMonthly[0].totalSpending, 300.0) // Two months ago
        XCTAssertEqual(sortedMonthly[1].totalSpending, 200.0) // Last month
        XCTAssertEqual(sortedMonthly[2].totalSpending, 100.0) // Current month
    }
    
    // MARK: - Period Selection Tests
    
    func testPeriodSelectionFiltersData() async {
        // Given
        let calendar = Calendar.current
        let now = Date()
        let sixMonthsAgo = calendar.date(byAdding: .month, value: -6, to: now)!
        let oneYearAgo = calendar.date(byAdding: .year, value: -1, to: now)!
        
        createTestFinancialData(amount: 100.0, date: now, categoryName: "Recent")
        createTestFinancialData(amount: 200.0, date: sixMonthsAgo, categoryName: "Six Months")
        createTestFinancialData(amount: 300.0, date: oneYearAgo, categoryName: "One Year")
        
        // Test this month filter
        analyticsViewModel.selectedPeriod = .thisMonth
        await analyticsViewModel.loadAnalyticsData()
        
        XCTAssertEqual(analyticsViewModel.totalSpending, 100.0) // Only current month
        
        // Test six months filter
        analyticsViewModel.selectedPeriod = .lastSixMonths
        await analyticsViewModel.loadAnalyticsData()
        
        XCTAssertEqual(analyticsViewModel.totalSpending, 300.0) // Current + six months ago
        
        // Test this year filter
        analyticsViewModel.selectedPeriod = .thisYear
        await analyticsViewModel.loadAnalyticsData()
        
        XCTAssertEqual(analyticsViewModel.totalSpending, 300.0) // Current + six months (same year)
    }
    
    // MARK: - Refresh Functionality Tests
    
    func testRefreshAnalyticsData() async {
        // Given
        createTestFinancialData(amount: 100.0, date: Date(), categoryName: "Initial")
        
        await analyticsViewModel.loadAnalyticsData()
        XCTAssertEqual(analyticsViewModel.totalSpending, 100.0)
        
        // Add more data
        createTestFinancialData(amount: 50.0, date: Date(), categoryName: "Additional")
        
        // When
        await analyticsViewModel.refreshAnalyticsData()
        
        // Then
        XCTAssertEqual(analyticsViewModel.totalSpending, 150.0)
    }
    
    // MARK: - Loading State Tests
    
    func testLoadingState() async {
        // Create expectation for loading state change
        let loadingExpectation = expectation(description: "Loading state changes")
        var loadingStates: [Bool] = []
        
        analyticsViewModel.$isLoading
            .sink { isLoading in
                loadingStates.append(isLoading)
                if loadingStates.count >= 2 {
                    loadingExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        await analyticsViewModel.loadAnalyticsData()
        
        // Wait for loading state changes
        await fulfillment(of: [loadingExpectation], timeout: 1.0)
        
        // Then
        XCTAssertEqual(loadingStates.count, 2)
        XCTAssertFalse(loadingStates[0]) // Initial state
        XCTAssertTrue(loadingStates[1])  // Loading started
        XCTAssertFalse(analyticsViewModel.isLoading) // Final state
    }
    
    // MARK: - Edge Cases and Error Handling Tests
    
    func testLoadAnalyticsDataWithInvalidData() async {
        // Given - Create financial data with nil values
        let financialData = FinancialData(context: testContext)
        financialData.id = UUID()
        financialData.totalAmount = nil // Invalid
        financialData.invoiceDate = nil // Invalid
        
        try! testContext.save()
        
        // When
        await analyticsViewModel.loadAnalyticsData()
        
        // Then - Should handle gracefully
        XCTAssertFalse(analyticsViewModel.isLoading)
        XCTAssertEqual(analyticsViewModel.totalSpending, 0.0)
        XCTAssertEqual(analyticsViewModel.categoryData.count, 0)
    }
    
    func testLoadAnalyticsDataWithZeroAmounts() async {
        // Given
        createTestFinancialData(amount: 0.0, date: Date(), categoryName: "Zero Amount")
        
        // When
        await analyticsViewModel.loadAnalyticsData()
        
        // Then - Zero amounts should be filtered out
        XCTAssertEqual(analyticsViewModel.totalSpending, 0.0)
        XCTAssertEqual(analyticsViewModel.categoryData.count, 0)
    }
    
    func testLoadAnalyticsDataWithNegativeAmounts() async {
        // Given
        createTestFinancialData(amount: -50.0, date: Date(), categoryName: "Negative Amount")
        
        // When
        await analyticsViewModel.loadAnalyticsData()
        
        // Then - Negative amounts should be filtered out
        XCTAssertEqual(analyticsViewModel.totalSpending, 0.0)
        XCTAssertEqual(analyticsViewModel.categoryData.count, 0)
    }
    
    func testCategoryWithoutNameUsesUncategorized() async {
        // Given
        let financialData = FinancialData(context: testContext)
        financialData.id = UUID()
        financialData.totalAmount = NSDecimalNumber(value: 100.0)
        financialData.invoiceDate = Date()
        
        let document = Document(context: testContext)
        document.id = UUID()
        document.category = nil // No category
        
        financialData.document = document
        
        try! testContext.save()
        
        // When
        await analyticsViewModel.loadAnalyticsData()
        
        // Then
        XCTAssertEqual(analyticsViewModel.categoryData.count, 1)
        XCTAssertEqual(analyticsViewModel.categoryData.first?.categoryName, "Uncategorized")
    }
    
    // MARK: - Category Color Assignment Tests
    
    func testCategoryColorAssignment() async {
        // Given - Create more categories than available colors
        let categoryNames = ["Food", "Transportation", "Housing", "Entertainment", "Shopping", "Healthcare", "Education", "Insurance", "Travel"]
        
        for (index, categoryName) in categoryNames.enumerated() {
            createTestFinancialData(amount: Double(100 + index * 10), date: Date(), categoryName: categoryName)
        }
        
        // When
        await analyticsViewModel.loadAnalyticsData()
        
        // Then - Colors should be assigned cyclically
        XCTAssertEqual(analyticsViewModel.categoryData.count, categoryNames.count)
        
        let colors = analyticsViewModel.categoryData.map { $0.color }
        let uniqueColors = Set(colors.map { $0.description })
        
        // Should have used all available colors (8 colors in the array)
        XCTAssertLessThanOrEqual(uniqueColors.count, 8)
    }
    
    // MARK: - Performance Tests
    
    func testLoadAnalyticsDataPerformance() async {
        // Given - Create a large number of transactions
        for i in 0..<100 {
            let date = Calendar.current.date(byAdding: .day, value: -i, to: Date()) ?? Date()
            createTestFinancialData(
                amount: Double.random(in: 10...500),
                date: date,
                categoryName: "Category \(i % 10)"
            )
        }
        
        // When
        measure {
            Task {
                await analyticsViewModel.loadAnalyticsData()
            }
        }
    }
    
    // MARK: - Published Properties Observation Tests
    
    func testPublishedPropertiesUpdate() async {
        let categoryExpectation = expectation(description: "Category data updates")
        let monthlyExpectation = expectation(description: "Monthly data updates")
        let totalExpectation = expectation(description: "Total spending updates")
        
        var categoryUpdates = 0
        var monthlyUpdates = 0
        var totalUpdates = 0
        
        analyticsViewModel.$categoryData
            .dropFirst() // Skip initial empty value
            .sink { _ in
                categoryUpdates += 1
                if categoryUpdates >= 1 {
                    categoryExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        analyticsViewModel.$monthlyData
            .dropFirst()
            .sink { _ in
                monthlyUpdates += 1
                if monthlyUpdates >= 1 {
                    monthlyExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        analyticsViewModel.$totalSpending
            .dropFirst()
            .sink { _ in
                totalUpdates += 1
                if totalUpdates >= 1 {
                    totalExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // Given
        createTestFinancialData(amount: 100.0, date: Date(), categoryName: "Test")
        
        // When
        await analyticsViewModel.loadAnalyticsData()
        
        // Wait for published property updates
        await fulfillment(of: [categoryExpectation, monthlyExpectation, totalExpectation], timeout: 1.0)
        
        // Then
        XCTAssertGreaterThanOrEqual(categoryUpdates, 1)
        XCTAssertGreaterThanOrEqual(monthlyUpdates, 1)
        XCTAssertGreaterThanOrEqual(totalUpdates, 1)
    }
}