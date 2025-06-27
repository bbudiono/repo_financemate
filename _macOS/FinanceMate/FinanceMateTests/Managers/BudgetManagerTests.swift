//
//  BudgetManagerTests.swift
//  FinanceMateTests
//
//  Purpose: Comprehensive unit tests for BudgetManager
//  Issues & Complexity Summary: Tests all budget management functionality including CRUD operations, category management, and spending tracking
//  Key Complexity Drivers:
//    - Logic Scope (Est. LoC): ~400
//    - Core Algorithm Complexity: High
//    - Dependencies: 5 (XCTest, CoreData, BudgetManager, CoreDataStack, SwiftUI)
//    - State Management Complexity: High
//    - Novelty/Uncertainty Factor: Medium
//  AI Pre-Task Self-Assessment: 85%
//  Problem Estimate: 80%
//  Initial Code Complexity Estimate: 82%
//  Final Code Complexity: 88%
//  Overall Result Score: 95%
//  Key Variances/Learnings: Complex CoreData relationships testing required extensive mock data setup
//  Last Updated: 2025-06-26

import XCTest
import CoreData
import SwiftUI
@testable import FinanceMate

@MainActor
final class BudgetManagerTests: XCTestCase {
    var budgetManager: BudgetManager!
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
        budgetManager = BudgetManager(context: testContext)
    }
    
    override func tearDown() async throws {
        budgetManager = nil
        testContext = nil
        persistentContainer = nil
        try await super.tearDown()
    }
    
    // MARK: - Test Data Model Creation
    
    private func createTestDataModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()
        
        // Budget Entity
        let budgetEntity = NSEntityDescription()
        budgetEntity.name = "Budget"
        budgetEntity.managedObjectClassName = "Budget"
        
        let budgetAttributes = [
            createAttribute(name: "id", type: .uuid),
            createAttribute(name: "name", type: .string),
            createAttribute(name: "totalAmount", type: .decimal),
            createAttribute(name: "budgetType", type: .string),
            createAttribute(name: "startDate", type: .date),
            createAttribute(name: "endDate", type: .date),
            createAttribute(name: "isActive", type: .boolean),
            createAttribute(name: "dateCreated", type: .date),
            createAttribute(name: "dateUpdated", type: .date),
            createAttribute(name: "currency", type: .string),
            createAttribute(name: "notes", type: .string),
            createAttribute(name: "metadata", type: .string)
        ]
        budgetEntity.properties = budgetAttributes
        
        // BudgetCategory Entity
        let categoryEntity = NSEntityDescription()
        categoryEntity.name = "BudgetCategory"
        categoryEntity.managedObjectClassName = "BudgetCategory"
        
        let categoryAttributes = [
            createAttribute(name: "id", type: .uuid),
            createAttribute(name: "name", type: .string),
            createAttribute(name: "budgetedAmount", type: .decimal),
            createAttribute(name: "spentAmount", type: .decimal),
            createAttribute(name: "categoryType", type: .string),
            createAttribute(name: "icon", type: .string),
            createAttribute(name: "colorHex", type: .string),
            createAttribute(name: "alertThreshold", type: .double),
            createAttribute(name: "isActive", type: .boolean),
            createAttribute(name: "dateCreated", type: .date),
            createAttribute(name: "dateUpdated", type: .date)
        ]
        categoryEntity.properties = categoryAttributes
        
        // BudgetAllocation Entity
        let allocationEntity = NSEntityDescription()
        allocationEntity.name = "BudgetAllocation"
        allocationEntity.managedObjectClassName = "BudgetAllocation"
        
        let allocationAttributes = [
            createAttribute(name: "id", type: .uuid),
            createAttribute(name: "amount", type: .decimal),
            createAttribute(name: "percentage", type: .double),
            createAttribute(name: "allocationDate", type: .date),
            createAttribute(name: "notes", type: .string),
            createAttribute(name: "isActive", type: .boolean),
            createAttribute(name: "dateCreated", type: .date),
            createAttribute(name: "dateUpdated", type: .date)
        ]
        allocationEntity.properties = allocationAttributes
        
        // Add relationships
        addRelationships(budgetEntity: budgetEntity, categoryEntity: categoryEntity, allocationEntity: allocationEntity)
        
        model.entities = [budgetEntity, categoryEntity, allocationEntity]
        return model
    }
    
    private func createAttribute(name: String, type: NSAttributeType) -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = name
        attribute.attributeType = type
        attribute.isOptional = true
        if type == .boolean {
            attribute.defaultValue = false
        }
        return attribute
    }
    
    private func addRelationships(budgetEntity: NSEntityDescription, categoryEntity: NSEntityDescription, allocationEntity: NSEntityDescription) {
        // Budget -> Categories (one-to-many)
        let budgetCategoriesRelationship = NSRelationshipDescription()
        budgetCategoriesRelationship.name = "categories"
        budgetCategoriesRelationship.destinationEntity = categoryEntity
        budgetCategoriesRelationship.minCount = 0
        budgetCategoriesRelationship.maxCount = 0
        budgetCategoriesRelationship.deleteRule = .cascadeDeleteRule
        
        // Category -> Budget (many-to-one)
        let categoryBudgetRelationship = NSRelationshipDescription()
        categoryBudgetRelationship.name = "budget"
        categoryBudgetRelationship.destinationEntity = budgetEntity
        categoryBudgetRelationship.minCount = 0
        categoryBudgetRelationship.maxCount = 1
        categoryBudgetRelationship.deleteRule = .nullifyDeleteRule
        
        // Set inverse relationships
        budgetCategoriesRelationship.inverseRelationship = categoryBudgetRelationship
        categoryBudgetRelationship.inverseRelationship = budgetCategoriesRelationship
        
        // Budget -> Allocations (one-to-many)
        let budgetAllocationsRelationship = NSRelationshipDescription()
        budgetAllocationsRelationship.name = "allocations"
        budgetAllocationsRelationship.destinationEntity = allocationEntity
        budgetAllocationsRelationship.minCount = 0
        budgetAllocationsRelationship.maxCount = 0
        budgetAllocationsRelationship.deleteRule = .cascadeDeleteRule
        
        // Allocation -> Budget (many-to-one)
        let allocationBudgetRelationship = NSRelationshipDescription()
        allocationBudgetRelationship.name = "budget"
        allocationBudgetRelationship.destinationEntity = budgetEntity
        allocationBudgetRelationship.minCount = 0
        allocationBudgetRelationship.maxCount = 1
        allocationBudgetRelationship.deleteRule = .nullifyDeleteRule
        
        // Set inverse relationships
        budgetAllocationsRelationship.inverseRelationship = allocationBudgetRelationship
        allocationBudgetRelationship.inverseRelationship = budgetAllocationsRelationship
        
        // Category -> Allocations (one-to-many)
        let categoryAllocationsRelationship = NSRelationshipDescription()
        categoryAllocationsRelationship.name = "allocations"
        categoryAllocationsRelationship.destinationEntity = allocationEntity
        categoryAllocationsRelationship.minCount = 0
        categoryAllocationsRelationship.maxCount = 0
        categoryAllocationsRelationship.deleteRule = .cascadeDeleteRule
        
        // Allocation -> Category (many-to-one)
        let allocationCategoryRelationship = NSRelationshipDescription()
        allocationCategoryRelationship.name = "budgetCategory"
        allocationCategoryRelationship.destinationEntity = categoryEntity
        allocationCategoryRelationship.minCount = 0
        allocationCategoryRelationship.maxCount = 1
        allocationCategoryRelationship.deleteRule = .nullifyDeleteRule
        
        // Set inverse relationships
        categoryAllocationsRelationship.inverseRelationship = allocationCategoryRelationship
        allocationCategoryRelationship.inverseRelationship = categoryAllocationsRelationship
        
        // Add relationships to entities
        budgetEntity.properties.append(contentsOf: [budgetCategoriesRelationship, budgetAllocationsRelationship])
        categoryEntity.properties.append(contentsOf: [categoryBudgetRelationship, categoryAllocationsRelationship])
        allocationEntity.properties.append(contentsOf: [allocationBudgetRelationship, allocationCategoryRelationship])
    }
    
    // MARK: - Initialization Tests
    
    func testBudgetManagerInitialization() {
        XCTAssertNotNil(budgetManager)
        XCTAssertEqual(budgetManager.budgets.count, 0)
        XCTAssertNil(budgetManager.selectedBudget)
        XCTAssertFalse(budgetManager.isLoading)
    }
    
    // MARK: - Budget Creation Tests
    
    func testCreateBudgetWithDefaultCategories() {
        // Given
        let name = "Test Monthly Budget"
        let amount = 2500.0
        let type = BudgetType.monthly
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .month, value: 1, to: startDate)!
        
        // When
        let budget = budgetManager.createBudget(
            name: name,
            amount: amount,
            type: type,
            startDate: startDate,
            endDate: endDate
        )
        
        // Then
        XCTAssertEqual(budget.name, name)
        XCTAssertEqual(budget.totalAmount?.doubleValue, amount)
        XCTAssertEqual(budget.budgetType, type.rawValue)
        XCTAssertEqual(budget.startDate, startDate)
        XCTAssertEqual(budget.endDate, endDate)
        XCTAssertTrue(budget.isActive)
        XCTAssertEqual(budget.currency, "USD")
        XCTAssertNotNil(budget.id)
        XCTAssertNotNil(budget.dateCreated)
        XCTAssertNotNil(budget.dateUpdated)
        
        // Verify default categories were created
        let categories = budgetManager.getBudgetCategories(for: budget)
        XCTAssertEqual(categories.count, BudgetCategoryData.defaultCategories.count)
        
        // Verify budget appears in budgets list
        XCTAssertEqual(budgetManager.budgets.count, 1)
        XCTAssertEqual(budgetManager.budgets.first?.id, budget.id)
    }
    
    func testCreateBudgetWithCustomCategories() {
        // Given
        let customCategories = [
            BudgetCategoryData(name: "Custom Category 1", budgetedAmount: 500.0, type: .housing, color: .blue, alertThreshold: 80.0),
            BudgetCategoryData(name: "Custom Category 2", budgetedAmount: 300.0, type: .food, color: .orange, alertThreshold: 90.0)
        ]
        
        // When
        let budget = budgetManager.createBudget(
            name: "Custom Budget",
            amount: 1000.0,
            type: .weekly,
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())!,
            categories: customCategories
        )
        
        // Then
        let categories = budgetManager.getBudgetCategories(for: budget)
        XCTAssertEqual(categories.count, customCategories.count)
        
        let category1 = categories.first { $0.name == "Custom Category 1" }
        XCTAssertNotNil(category1)
        XCTAssertEqual(category1?.budgetedAmount?.doubleValue, 500.0)
        XCTAssertEqual(category1?.categoryType, BudgetCategoryType.housing.rawValue)
        XCTAssertEqual(category1?.alertThreshold, 80.0)
    }
    
    // MARK: - Budget Fetch Tests
    
    func testFetchBudgetsOrderedByActiveAndDate() {
        // Given - Create multiple budgets with different active states and dates
        let budget1 = budgetManager.createBudget(name: "Old Active", amount: 1000.0, type: .monthly, startDate: Date().addingTimeInterval(-86400), endDate: Date().addingTimeInterval(86400))
        let budget2 = budgetManager.createBudget(name: "New Active", amount: 2000.0, type: .monthly, startDate: Date(), endDate: Date().addingTimeInterval(86400))
        let budget3 = budgetManager.createBudget(name: "Inactive", amount: 1500.0, type: .monthly, startDate: Date(), endDate: Date().addingTimeInterval(86400))
        
        // Make budget3 inactive
        budget3.isActive = false
        budgetManager.updateBudget(budget3)
        
        // When
        budgetManager.fetchBudgets()
        
        // Then
        XCTAssertEqual(budgetManager.budgets.count, 3)
        
        // Active budgets should come first, then sorted by date created (newest first)
        let sortedActiveBudgets = budgetManager.budgets.filter { $0.isActive }
        XCTAssertEqual(sortedActiveBudgets.count, 2)
        XCTAssertEqual(sortedActiveBudgets.first?.name, "New Active")
        
        let inactiveBudgets = budgetManager.budgets.filter { !$0.isActive }
        XCTAssertEqual(inactiveBudgets.count, 1)
        XCTAssertEqual(inactiveBudgets.first?.name, "Inactive")
    }
    
    // MARK: - Budget Update Tests
    
    func testUpdateBudget() {
        // Given
        let budget = budgetManager.createBudget(name: "Original", amount: 1000.0, type: .monthly, startDate: Date(), endDate: Date().addingTimeInterval(86400))
        let originalUpdateDate = budget.dateUpdated
        
        // Wait a moment to ensure timestamp difference
        Thread.sleep(forTimeInterval: 0.1)
        
        // When
        budget.name = "Updated Name"
        budgetManager.updateBudget(budget)
        
        // Then
        XCTAssertEqual(budget.name, "Updated Name")
        XCTAssertNotEqual(budget.dateUpdated, originalUpdateDate)
        XCTAssertEqual(budgetManager.budgets.count, 1)
        XCTAssertEqual(budgetManager.budgets.first?.name, "Updated Name")
    }
    
    // MARK: - Budget Deletion Tests
    
    func testDeleteBudget() {
        // Given
        let budget1 = budgetManager.createBudget(name: "Keep", amount: 1000.0, type: .monthly, startDate: Date(), endDate: Date().addingTimeInterval(86400))
        let budget2 = budgetManager.createBudget(name: "Delete", amount: 2000.0, type: .monthly, startDate: Date(), endDate: Date().addingTimeInterval(86400))
        
        XCTAssertEqual(budgetManager.budgets.count, 2)
        
        // When
        budgetManager.deleteBudget(budget2)
        
        // Then
        XCTAssertEqual(budgetManager.budgets.count, 1)
        XCTAssertEqual(budgetManager.budgets.first?.name, "Keep")
        XCTAssertEqual(budgetManager.budgets.first?.id, budget1.id)
    }
    
    // MARK: - Category Management Tests
    
    func testAddCategoryToBudget() {
        // Given
        let budget = budgetManager.createBudget(name: "Test", amount: 1000.0, type: .monthly, startDate: Date(), endDate: Date().addingTimeInterval(86400))
        let originalCategoryCount = budgetManager.getBudgetCategories(for: budget).count
        
        let categoryData = BudgetCategoryData(name: "New Category", budgetedAmount: 250.0, type: .miscellaneous, color: .gray, alertThreshold: 85.0)
        
        // When
        budgetManager.addCategoryToBudget(budget, categoryData: categoryData)
        
        // Then
        let categories = budgetManager.getBudgetCategories(for: budget)
        XCTAssertEqual(categories.count, originalCategoryCount + 1)
        
        let newCategory = categories.first { $0.name == "New Category" }
        XCTAssertNotNil(newCategory)
        XCTAssertEqual(newCategory?.budgetedAmount?.doubleValue, 250.0)
        XCTAssertEqual(newCategory?.spentAmount?.doubleValue, 0.0)
        XCTAssertEqual(newCategory?.categoryType, BudgetCategoryType.miscellaneous.rawValue)
        XCTAssertEqual(newCategory?.alertThreshold, 85.0)
        XCTAssertTrue(newCategory?.isActive ?? false)
        XCTAssertNotNil(newCategory?.id)
        XCTAssertNotNil(newCategory?.dateCreated)
        XCTAssertEqual(newCategory?.budget?.id, budget.id)
    }
    
    func testUpdateCategory() {
        // Given
        let budget = budgetManager.createBudget(name: "Test", amount: 1000.0, type: .monthly, startDate: Date(), endDate: Date().addingTimeInterval(86400))
        let categories = budgetManager.getBudgetCategories(for: budget)
        let category = categories.first!
        let originalUpdateDate = category.dateUpdated
        
        // Wait a moment to ensure timestamp difference
        Thread.sleep(forTimeInterval: 0.1)
        
        // When
        category.name = "Updated Category Name"
        budgetManager.updateCategory(category)
        
        // Then
        XCTAssertEqual(category.name, "Updated Category Name")
        XCTAssertNotEqual(category.dateUpdated, originalUpdateDate)
    }
    
    func testDeleteCategory() {
        // Given
        let budget = budgetManager.createBudget(name: "Test", amount: 1000.0, type: .monthly, startDate: Date(), endDate: Date().addingTimeInterval(86400))
        let categories = budgetManager.getBudgetCategories(for: budget)
        let originalCount = categories.count
        let categoryToDelete = categories.first!
        
        // When
        budgetManager.deleteCategory(categoryToDelete)
        
        // Then
        let updatedCategories = budgetManager.getBudgetCategories(for: budget)
        XCTAssertEqual(updatedCategories.count, originalCount - 1)
        XCTAssertFalse(updatedCategories.contains { $0.id == categoryToDelete.id })
    }
    
    // MARK: - Spending Operations Tests
    
    func testAddSpendingToCategory() {
        // Given
        let budget = budgetManager.createBudget(name: "Test", amount: 1000.0, type: .monthly, startDate: Date(), endDate: Date().addingTimeInterval(86400))
        let categories = budgetManager.getBudgetCategories(for: budget)
        let category = categories.first!
        let originalSpent = category.spentAmount?.doubleValue ?? 0.0
        let spendingAmount = 150.0
        let description = "Test spending"
        
        // When
        budgetManager.addSpending(to: category, amount: spendingAmount, description: description)
        
        // Then
        XCTAssertEqual(category.spentAmount?.doubleValue, originalSpent + spendingAmount)
        XCTAssertNotNil(category.dateUpdated)
        
        // Verify allocation was created
        let allocations = category.allocations?.allObjects as? [BudgetAllocation] ?? []
        XCTAssertEqual(allocations.count, 1)
        
        let allocation = allocations.first!
        XCTAssertEqual(allocation.amount?.doubleValue, spendingAmount)
        XCTAssertEqual(allocation.notes, description)
        XCTAssertTrue(allocation.isActive)
        XCTAssertEqual(allocation.budget?.id, budget.id)
        XCTAssertEqual(allocation.budgetCategory?.id, category.id)
        XCTAssertNotNil(allocation.id)
        XCTAssertNotNil(allocation.allocationDate)
    }
    
    func testMultipleSpendingOperations() {
        // Given
        let budget = budgetManager.createBudget(name: "Test", amount: 1000.0, type: .monthly, startDate: Date(), endDate: Date().addingTimeInterval(86400))
        let categories = budgetManager.getBudgetCategories(for: budget)
        let category = categories.first!
        
        // When
        budgetManager.addSpending(to: category, amount: 100.0, description: "First spending")
        budgetManager.addSpending(to: category, amount: 75.0, description: "Second spending")
        budgetManager.addSpending(to: category, amount: 50.0, description: "Third spending")
        
        // Then
        XCTAssertEqual(category.spentAmount?.doubleValue, 225.0)
        
        let allocations = category.allocations?.allObjects as? [BudgetAllocation] ?? []
        XCTAssertEqual(allocations.count, 3)
        
        let totalAllocated = allocations.reduce(0.0) { $0 + ($1.amount?.doubleValue ?? 0.0) }
        XCTAssertEqual(totalAllocated, 225.0)
    }
    
    // MARK: - Helper Methods Tests
    
    func testGetActiveBudget() {
        // Given
        let inactiveBudget = budgetManager.createBudget(name: "Inactive", amount: 1000.0, type: .monthly, startDate: Date(), endDate: Date().addingTimeInterval(86400))
        inactiveBudget.isActive = false
        budgetManager.updateBudget(inactiveBudget)
        
        let activeBudget = budgetManager.createBudget(name: "Active", amount: 2000.0, type: .monthly, startDate: Date(), endDate: Date().addingTimeInterval(86400))
        
        // When
        let result = budgetManager.getActiveBudget()
        
        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.id, activeBudget.id)
        XCTAssertEqual(result?.name, "Active")
    }
    
    func testGetActiveBudgetWithNoBudgets() {
        // Given - No budgets created
        
        // When
        let result = budgetManager.getActiveBudget()
        
        // Then
        XCTAssertNil(result)
    }
    
    func testGetTotalSpentAcrossAllBudgets() {
        // Given
        let budget1 = budgetManager.createBudget(name: "Budget 1", amount: 1000.0, type: .monthly, startDate: Date(), endDate: Date().addingTimeInterval(86400))
        let budget2 = budgetManager.createBudget(name: "Budget 2", amount: 2000.0, type: .monthly, startDate: Date(), endDate: Date().addingTimeInterval(86400))
        
        let categories1 = budgetManager.getBudgetCategories(for: budget1)
        let categories2 = budgetManager.getBudgetCategories(for: budget2)
        
        // When
        budgetManager.addSpending(to: categories1.first!, amount: 150.0)
        budgetManager.addSpending(to: categories2.first!, amount: 250.0)
        
        // Then
        let totalSpent = budgetManager.getTotalSpentAcrossAllBudgets()
        XCTAssertEqual(totalSpent, 400.0)
    }
    
    func testGetTotalBudgetedAcrossAllBudgets() {
        // Given
        let budget1 = budgetManager.createBudget(name: "Budget 1", amount: 1000.0, type: .monthly, startDate: Date(), endDate: Date().addingTimeInterval(86400))
        let budget2 = budgetManager.createBudget(name: "Budget 2", amount: 2000.0, type: .monthly, startDate: Date(), endDate: Date().addingTimeInterval(86400))
        
        // When
        let totalBudgeted = budgetManager.getTotalBudgetedAcrossAllBudgets()
        
        // Then
        XCTAssertEqual(totalBudgeted, 3000.0)
    }
    
    // MARK: - Edge Cases and Error Handling Tests
    
    func testCreateBudgetWithEmptyName() {
        // Given
        let emptyName = ""
        
        // When
        let budget = budgetManager.createBudget(
            name: emptyName,
            amount: 1000.0,
            type: .monthly,
            startDate: Date(),
            endDate: Date().addingTimeInterval(86400)
        )
        
        // Then
        XCTAssertEqual(budget.name, emptyName)
        XCTAssertEqual(budgetManager.budgets.count, 1)
    }
    
    func testCreateBudgetWithZeroAmount() {
        // Given
        let zeroAmount = 0.0
        
        // When
        let budget = budgetManager.createBudget(
            name: "Zero Budget",
            amount: zeroAmount,
            type: .monthly,
            startDate: Date(),
            endDate: Date().addingTimeInterval(86400)
        )
        
        // Then
        XCTAssertEqual(budget.totalAmount?.doubleValue, zeroAmount)
        XCTAssertEqual(budgetManager.budgets.count, 1)
    }
    
    func testCreateBudgetWithNegativeAmount() {
        // Given
        let negativeAmount = -500.0
        
        // When
        let budget = budgetManager.createBudget(
            name: "Negative Budget",
            amount: negativeAmount,
            type: .monthly,
            startDate: Date(),
            endDate: Date().addingTimeInterval(86400)
        )
        
        // Then
        XCTAssertEqual(budget.totalAmount?.doubleValue, negativeAmount)
        XCTAssertEqual(budgetManager.budgets.count, 1)
    }
    
    func testCreateBudgetWithEndDateBeforeStartDate() {
        // Given
        let startDate = Date()
        let endDate = Date().addingTimeInterval(-86400) // 1 day before start
        
        // When
        let budget = budgetManager.createBudget(
            name: "Invalid Date Range",
            amount: 1000.0,
            type: .monthly,
            startDate: startDate,
            endDate: endDate
        )
        
        // Then
        XCTAssertEqual(budget.startDate, startDate)
        XCTAssertEqual(budget.endDate, endDate)
        XCTAssertEqual(budgetManager.budgets.count, 1)
    }
    
    // MARK: - Concurrent Operations Tests
    
    func testConcurrentBudgetCreation() {
        let expectation = XCTestExpectation(description: "Concurrent budget creation")
        expectation.expectedFulfillmentCount = 10
        
        let queue = DispatchQueue(label: "test.concurrent", attributes: .concurrent)
        
        // Perform 10 concurrent budget creations
        for i in 0..<10 {
            queue.async {
                Task { @MainActor in
                    let budget = self.budgetManager.createBudget(
                        name: "Concurrent Budget \(i)",
                        amount: Double(1000 + i * 100),
                        type: .monthly,
                        startDate: Date(),
                        endDate: Date().addingTimeInterval(86400)
                    )
                    XCTAssertNotNil(budget.id)
                    expectation.fulfill()
                }
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
        
        // Verify all budgets were created
        XCTAssertEqual(budgetManager.budgets.count, 10)
    }
    
    // MARK: - Performance Tests
    
    func testBudgetCreationPerformance() {
        measure {
            for i in 0..<100 {
                let _ = budgetManager.createBudget(
                    name: "Performance Budget \(i)",
                    amount: Double(1000 + i),
                    type: .monthly,
                    startDate: Date(),
                    endDate: Date().addingTimeInterval(86400)
                )
            }
        }
    }
    
    func testFetchBudgetsPerformance() {
        // Given - Create many budgets
        for i in 0..<100 {
            let _ = budgetManager.createBudget(
                name: "Budget \(i)",
                amount: Double(1000 + i),
                type: .monthly,
                startDate: Date(),
                endDate: Date().addingTimeInterval(86400)
            )
        }
        
        // When - Measure fetch performance
        measure {
            budgetManager.fetchBudgets()
        }
    }
}