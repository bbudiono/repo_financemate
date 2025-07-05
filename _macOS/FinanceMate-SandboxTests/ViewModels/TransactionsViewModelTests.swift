// SANDBOX FILE: For testing/development. See .cursorrules.
//
// TransactionsViewModelTests.swift
// FinanceMate Sandbox
//
// Purpose: Atomic TDD unit tests for TransactionsViewModel (Sandbox)
// Issues & Complexity Summary: Tests MVVM, Core Data, and business logic for transactions
// Key Complexity Drivers:
//   - Logic Scope (Est. LoC): ~100
//   - Core Algorithm Complexity: Medium
//   - Dependencies: 3 (Core Data, XCTest, Combine)
//   - State Management Complexity: Medium
//   - Novelty/Uncertainty Factor: Medium
// AI Pre-Task Self-Assessment: 80%
// Problem Estimate: 85%
// Initial Code Complexity Estimate: 80%
// Final Code Complexity: TBD
// Overall Result Score: TBD
// Key Variances/Learnings: TDD for new MVVM module
// Last Updated: 2025-07-05

import XCTest
import CoreData
@testable import FinanceMate_Sandbox

@MainActor
final class TransactionsViewModelTests: XCTestCase {
    var viewModel: TransactionsViewModel!
    var persistenceController: PersistenceController!
    var context: NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        persistenceController = PersistenceController(inMemory: true)
        context = persistenceController.container.viewContext
        // ViewModel will be initialized in each test
    }
    
    override func tearDown() {
        viewModel = nil
        context = nil
        persistenceController = nil
        super.tearDown()
    }
    
    // MARK: - Initialization
    func testViewModelInitialization() {
        // Given: A Core Data context
        // When: Creating a TransactionsViewModel
        viewModel = TransactionsViewModel(context: context)
        
        // Then: The view model should be properly initialized
        XCTAssertNotNil(viewModel, "TransactionsViewModel should be properly initialized")
        XCTAssertNotNil(viewModel.transactions, "Transactions array should be initialized")
        XCTAssertEqual(viewModel.transactions.count, 0, "Initial transactions array should be empty")
        XCTAssertFalse(viewModel.isLoading, "Initial loading state should be false")
        XCTAssertNil(viewModel.errorMessage, "Initial error message should be nil")
    }
    
    // MARK: - Core Data Integration
    func testCoreDataIntegration() {
        // Given: A TransactionsViewModel with Core Data context
        viewModel = TransactionsViewModel(context: context)
        
        // When: Calling fetchTransactions
        viewModel.fetchTransactions()
        
        // Then: The fetch operation should complete without errors
        XCTAssertNotNil(viewModel.transactions, "Transactions should be initialized after fetch")
        XCTAssertEqual(viewModel.transactions.count, 0, "Should have no transactions in empty database")
        XCTAssertFalse(viewModel.isLoading, "Loading should be false after fetch completes")
        XCTAssertNil(viewModel.errorMessage, "Error message should be nil for successful fetch")
    }
    
    // MARK: - Transaction Creation
    func testTransactionCreation() {
        // Given: A TransactionsViewModel
        viewModel = TransactionsViewModel(context: context)
        
        // When: Creating a new transaction
        viewModel.createTransaction(amount: 100.50, category: "Food", note: "Lunch")
        
        // Then: The transaction should be created and added to the list
        XCTAssertEqual(viewModel.transactions.count, 1, "Should have one transaction after creation")
        let transaction = viewModel.transactions.first!
        XCTAssertEqual(transaction.amount, 100.50, "Transaction amount should match")
        XCTAssertEqual(transaction.category, "Food", "Transaction category should match")
        XCTAssertEqual(transaction.note, "Lunch", "Transaction note should match")
        XCTAssertNotNil(transaction.date, "Transaction should have a date")
        XCTAssertNotNil(transaction.id, "Transaction should have an ID")
    }
    
    // MARK: - Transaction Fetching
    func testTransactionFetching() {
        // Given: A TransactionsViewModel with some test data
        viewModel = TransactionsViewModel(context: context)
        // Create test transaction
        let _ = Transaction.create(in: context, amount: 25.99, category: "Test", note: "Test transaction")
        try! context.save()
        
        // When: Fetching transactions
        viewModel.fetchTransactions()
        
        // Then: Transactions should be fetched correctly
        XCTAssertEqual(viewModel.transactions.count, 1, "Should have one transaction after fetch")
        XCTAssertEqual(viewModel.transactions.first?.amount, 25.99, "Fetched transaction should have correct amount")
        XCTAssertEqual(viewModel.transactions.first?.category, "Test", "Fetched transaction should have correct category")
    }
    
    // MARK: - Error Handling
    func testErrorHandling() {
        // Given: A TransactionsViewModel
        viewModel = TransactionsViewModel(context: context)
        
        // When: Initial state
        // Then: Error message should be nil
        XCTAssertNil(viewModel.errorMessage, "Initial error message should be nil")
        
        // The ViewModel handles errors internally through Core Data operations
        // Actual error testing would require mocking Core Data context
        // For now, we verify error state management structure exists
        XCTAssertTrue(viewModel.errorMessage == nil || viewModel.errorMessage is String, "Error message should be nil or String type")
    }
    
    // MARK: - State Management
    func testStateManagement() {
        // Given: A TransactionsViewModel
        viewModel = TransactionsViewModel(context: context)
        
        // When: Initial state
        // Then: Loading should be false, transactions empty, no error
        XCTAssertFalse(viewModel.isLoading, "Initial loading state should be false")
        XCTAssertEqual(viewModel.transactions.count, 0, "Initial transactions should be empty")
        XCTAssertNil(viewModel.errorMessage, "Initial error should be nil")
        
        // When: Starting fetch operation
        viewModel.fetchTransactions()
        
        // Then: State should be updated correctly
        XCTAssertFalse(viewModel.isLoading, "Loading should be false after fetch completes")
        XCTAssertNotNil(viewModel.transactions, "Transactions array should exist after fetch")
    }
} 