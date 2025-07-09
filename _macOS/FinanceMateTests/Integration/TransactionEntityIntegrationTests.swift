//
//  TransactionEntityIntegrationTests.swift
//  FinanceMateTests
//
//  Created by AI Dev Agent on 2025-07-09.
//  Copyright © 2025 FinanceMate. All rights reserved.
//

import XCTest
import CoreData
import Combine
@testable import FinanceMate

/**
 * Purpose: Comprehensive test suite for Transaction-Entity integration with TDD methodology
 * Issues & Complexity Summary: Core Data relationships, entity assignment validation, UI integration testing
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~400+
 *   - Core Algorithm Complexity: Medium-High (relationships, validation, UI workflows)
 *   - Dependencies: 4 New (FinancialEntity, Transaction, ViewModels, UI components)
 *   - State Management Complexity: Medium (entity assignment, validation, persistence)
 *   - Novelty/Uncertainty Factor: Low (established Core Data patterns, MVVM integration)
 * AI Pre-Task Self-Assessment: 80%
 * Problem Estimate: 75%
 * Initial Code Complexity Estimate: 80%
 * Final Code Complexity: TBD
 * Overall Result Score: TBD
 * Key Variances/Learnings: TBD
 * Last Updated: 2025-07-09
 */

class TransactionEntityIntegrationTests: XCTestCase {
    
    private var testContext: NSManagedObjectContext!
    private var transactionsViewModel: TransactionsViewModel!
    private var entityViewModel: FinancialEntityViewModel!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        
        // Setup test Core Data context
        testContext = PersistenceController.preview.container.viewContext
        
        // Initialize ViewModels with test context
        transactionsViewModel = TransactionsViewModel(context: testContext)
        entityViewModel = FinancialEntityViewModel(context: testContext)
        
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        transactionsViewModel = nil
        entityViewModel = nil
        testContext = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Core Data Relationship Tests
    
    func testTransactionEntityAssignment() {
        // Given
        let testEntity = createTestEntity(name: "Personal", type: .personal)
        let transactionData = createTestTransactionData(amount: 100.0, description: "Test Transaction")
        
        // When
        let transaction = transactionsViewModel.createTransaction(from: transactionData, assignedTo: testEntity)
        
        // Then
        XCTAssertNotNil(transaction, "Transaction should be created successfully")
        XCTAssertEqual(transaction?.assignedEntity, testEntity, "Transaction should be assigned to the specified entity")
        XCTAssertEqual(transaction?.entityName, "Personal", "Transaction should display correct entity name")
        XCTAssertTrue(testEntity.transactions?.contains(transaction!) ?? false, "Entity should contain the assigned transaction")
    }
    
    func testTransactionEntityReassignment() {
        // Given
        let personalEntity = createTestEntity(name: "Personal", type: .personal)
        let businessEntity = createTestEntity(name: "Business", type: .business)
        let transactionData = createTestTransactionData(amount: 200.0, description: "Reassign Test")
        
        // When
        let transaction = transactionsViewModel.createTransaction(from: transactionData, assignedTo: personalEntity)
        let success = transactionsViewModel.reassignTransaction(transaction!, to: businessEntity)
        
        // Then
        XCTAssertTrue(success, "Transaction reassignment should succeed")
        XCTAssertEqual(transaction?.assignedEntity, businessEntity, "Transaction should be reassigned to business entity")
        XCTAssertEqual(transaction?.entityName, "Business", "Transaction should display new entity name")
        XCTAssertFalse(personalEntity.transactions?.contains(transaction!) ?? true, "Original entity should not contain the transaction")
        XCTAssertTrue(businessEntity.transactions?.contains(transaction!) ?? false, "New entity should contain the reassigned transaction")
    }
    
    func testEntityTransactionCollection() {
        // Given
        let testEntity = createTestEntity(name: "Test Entity", type: .personal)
        let transaction1 = createTestTransaction(amount: 50.0, description: "Transaction 1", entity: testEntity)
        let transaction2 = createTestTransaction(amount: 75.0, description: "Transaction 2", entity: testEntity)
        
        // When
        let transactionCount = testEntity.transactionCount
        let totalBalance = testEntity.totalBalance
        
        // Then
        XCTAssertEqual(transactionCount, 2, "Entity should have correct transaction count")
        XCTAssertEqual(totalBalance, 125.0, accuracy: 0.01, "Entity should calculate correct total balance")
        XCTAssertTrue(testEntity.transactions?.contains(transaction1) ?? false, "Entity should contain first transaction")
        XCTAssertTrue(testEntity.transactions?.contains(transaction2) ?? false, "Entity should contain second transaction")
    }
    
    func testTransactionFilteringByEntity() {
        // Given
        let personalEntity = createTestEntity(name: "Personal", type: .personal)
        let businessEntity = createTestEntity(name: "Business", type: .business)
        
        _ = createTestTransaction(amount: 100.0, description: "Personal Expense", entity: personalEntity)
        _ = createTestTransaction(amount: 200.0, description: "Business Expense", entity: businessEntity)
        _ = createTestTransaction(amount: 150.0, description: "Another Personal", entity: personalEntity)
        
        // When
        let personalTransactions = transactionsViewModel.transactions(for: personalEntity)
        let businessTransactions = transactionsViewModel.transactions(for: businessEntity)
        
        // Then
        XCTAssertEqual(personalTransactions.count, 2, "Personal entity should have 2 transactions")
        XCTAssertEqual(businessTransactions.count, 1, "Business entity should have 1 transaction")
        XCTAssertTrue(personalTransactions.allSatisfy { $0.assignedEntity == personalEntity }, "All personal transactions should be assigned to personal entity")
        XCTAssertTrue(businessTransactions.allSatisfy { $0.assignedEntity == businessEntity }, "All business transactions should be assigned to business entity")
    }
    
    func testEntityDeletionHandling() {
        // Given
        let testEntity = createTestEntity(name: "Delete Test", type: .personal)
        let transaction = createTestTransaction(amount: 300.0, description: "Orphan Test", entity: testEntity)
        let defaultEntity = createTestEntity(name: "Personal", type: .personal) // Default entity
        
        // When
        let success = entityViewModel.deleteEntity(testEntity, reassignTransactionsTo: defaultEntity)
        
        // Then
        XCTAssertTrue(success, "Entity deletion should succeed")
        XCTAssertEqual(transaction.assignedEntity, defaultEntity, "Orphaned transaction should be reassigned to default entity")
        XCTAssertEqual(transaction.entityName, "Personal", "Transaction should display default entity name")
        XCTAssertTrue(defaultEntity.transactions?.contains(transaction) ?? false, "Default entity should contain reassigned transaction")
    }
    
    func testDefaultEntityAssignment() {
        // Given
        let defaultEntity = createTestEntity(name: "Personal", type: .personal)
        transactionsViewModel.setDefaultEntity(defaultEntity)
        let transactionData = createTestTransactionData(amount: 250.0, description: "Default Assignment")
        
        // When
        let transaction = transactionsViewModel.createTransaction(from: transactionData) // No explicit entity
        
        // Then
        XCTAssertNotNil(transaction, "Transaction should be created successfully")
        XCTAssertEqual(transaction?.assignedEntity, defaultEntity, "Transaction should be assigned to default entity")
        XCTAssertEqual(transaction?.entityName, "Personal", "Transaction should display default entity name")
    }
    
    func testTransactionEntityValidation() {
        // Given
        let validEntity = createTestEntity(name: "Valid Entity", type: .personal)
        let transactionData = createTestTransactionData(amount: 400.0, description: "Validation Test")
        
        // When
        let validationResult = transactionsViewModel.validateEntityAssignment(entity: validEntity, transactionData: transactionData)
        let nilEntityResult = transactionsViewModel.validateEntityAssignment(entity: nil, transactionData: transactionData)
        
        // Then
        XCTAssertTrue(validationResult.isValid, "Valid entity assignment should pass validation")
        XCTAssertNil(validationResult.errorMessage, "Valid assignment should have no error message")
        XCTAssertFalse(nilEntityResult.isValid, "Nil entity assignment should fail validation")
        XCTAssertNotNil(nilEntityResult.errorMessage, "Nil entity should have error message")
    }
    
    func testEntityBalanceCalculation() {
        // Given
        let testEntity = createTestEntity(name: "Balance Test", type: .business)
        _ = createTestTransaction(amount: 1000.0, description: "Income", entity: testEntity, type: .income)
        _ = createTestTransaction(amount: -300.0, description: "Expense", entity: testEntity, type: .expense)
        _ = createTestTransaction(amount: -200.0, description: "Another Expense", entity: testEntity, type: .expense)
        
        // When
        let totalBalance = testEntity.totalBalance
        let incomeTotal = testEntity.totalIncome
        let expenseTotal = testEntity.totalExpenses
        
        // Then
        XCTAssertEqual(totalBalance, 500.0, accuracy: 0.01, "Entity should calculate correct net balance")
        XCTAssertEqual(incomeTotal, 1000.0, accuracy: 0.01, "Entity should calculate correct income total")
        XCTAssertEqual(expenseTotal, 500.0, accuracy: 0.01, "Entity should calculate correct expense total")
    }
    
    // MARK: - ViewModel Integration Tests
    
    func testTransactionsViewModelEntityManagement() {
        // Given
        let entity1 = createTestEntity(name: "Entity 1", type: .personal)
        let entity2 = createTestEntity(name: "Entity 2", type: .business)
        
        // When
        transactionsViewModel.loadAvailableEntities()
        
        // Then
        XCTAssertTrue(transactionsViewModel.availableEntities.contains(entity1), "ViewModel should load all available entities")
        XCTAssertTrue(transactionsViewModel.availableEntities.contains(entity2), "ViewModel should load all available entities")
        XCTAssertEqual(transactionsViewModel.availableEntities.count, 2, "ViewModel should have correct entity count")
    }
    
    func testSelectedEntityPersistence() {
        // Given
        let testEntity = createTestEntity(name: "Selected Entity", type: .investment)
        
        // When
        transactionsViewModel.selectedEntity = testEntity
        let savedEntityId = transactionsViewModel.getSelectedEntityId()
        
        // Reset ViewModel to simulate app restart
        transactionsViewModel = TransactionsViewModel(context: testContext)
        transactionsViewModel.restoreSelectedEntity(withId: savedEntityId)
        
        // Then
        XCTAssertEqual(transactionsViewModel.selectedEntity?.id, testEntity.id, "Selected entity should persist across ViewModel resets")
        XCTAssertEqual(transactionsViewModel.selectedEntity?.name, "Selected Entity", "Restored entity should have correct properties")
    }
    
    // MARK: - Helper Methods
    
    private func createTestEntity(name: String, type: FinancialEntityType) -> FinancialEntity {
        let entity = FinancialEntity(context: testContext)
        entity.id = UUID()
        entity.name = name
        entity.type = type.rawValue
        entity.isActive = true
        entity.createdAt = Date()
        entity.lastModified = Date()
        
        do {
            try testContext.save()
        } catch {
            XCTFail("Failed to save test entity: \(error)")
        }
        
        return entity
    }
    
    private func createTestTransactionData(amount: Double, description: String) -> TransactionData {
        return TransactionData(
            amount: amount,
            description: description,
            date: Date(),
            category: "Test Category"
        )
    }
    
    private func createTestTransaction(amount: Double, description: String, entity: FinancialEntity, type: TransactionType = .expense) -> Transaction {
        let transaction = Transaction(context: testContext)
        transaction.id = UUID()
        transaction.amount = amount
        transaction.desc = description
        transaction.date = Date()
        transaction.category = "Test Category"
        transaction.assignedEntity = entity
        transaction.type = type.rawValue
        transaction.createdAt = Date()
        
        do {
            try testContext.save()
        } catch {
            XCTFail("Failed to save test transaction: \(error)")
        }
        
        return transaction
    }
}

// MARK: - Supporting Enums and Structs

enum TransactionType: String, CaseIterable {
    case income = "income"
    case expense = "expense"
    case transfer = "transfer"
}

struct EntityAssignmentValidationResult {
    let isValid: Bool
    let errorMessage: String?
}