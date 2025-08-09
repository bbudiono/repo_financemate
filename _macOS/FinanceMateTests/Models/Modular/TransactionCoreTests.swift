import XCTest
import CoreData
@testable import FinanceMate

/**
 * TransactionCoreTests.swift
 * 
 * Purpose: TDD test suite for TransactionCore module - comprehensive quality validation (I-Q-I Protocol)
 * Issues & Complexity Summary: Core transaction functionality, validation, Core Data operations
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~400 (comprehensive test coverage ≥95%)
 *   - Core Algorithm Complexity: Medium (validation, Core Data operations, error handling)
 *   - Dependencies: 3 (Transaction, Core Data, XCTest)
 *   - State Management Complexity: Medium (Core Data lifecycle testing)
 *   - Novelty/Uncertainty Factor: Low (proven testing patterns)
 * AI Pre-Task Self-Assessment: 90%
 * Problem Estimate: 85%
 * Initial Code Complexity Estimate: 80%
 * I-Q-I Quality Target: 8+/10 - Professional enterprise testing standards
 * Final Code Complexity: TBD
 * Overall Result Score: TBD
 * Key Variances/Learnings: TDD for modular transaction core with real financial data
 * Last Updated: 2025-08-04
 */

@MainActor
final class TransactionCoreTests: XCTestCase {
    var persistenceController: PersistenceController!
    var context: NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        persistenceController = PersistenceController(inMemory: true)
        context = persistenceController.container.viewContext
    }
    
    override func tearDown() {
        context = nil
        persistenceController = nil
        super.tearDown()
    }
    
    // MARK: - Core Transaction Creation Tests (I-Q-I Quality: Professional Standards)
    
    func testTransactionCreationWithValidData() {
        // Given: Valid transaction parameters using real Australian financial data
        let amount = 4299.00 // MacBook Pro price in AUD
        let category = "Business Equipment"
        let note = "MacBook Pro 16-inch for development work"
        let date = Date()
        let type = "expense"
        
        // When: Creating transaction with core factory method
        let transaction = Transaction.create(
            in: context,
            amount: amount,
            category: category,
            note: note,
            date: date,
            type: type
        )
        
        // Then: Transaction should be created with professional quality standards
        XCTAssertNotNil(transaction.id, "Transaction must have UUID")
        XCTAssertEqual(transaction.amount, amount, accuracy: 0.01, "Amount must be precise for financial calculations")
        XCTAssertEqual(transaction.category, category, "Category must match exactly")
        XCTAssertEqual(transaction.note, note, "Note must be preserved accurately")
        XCTAssertEqual(transaction.date, date, "Date must be preserved precisely")
        XCTAssertEqual(transaction.type, type, "Type must match specification")
        XCTAssertNotNil(transaction.createdAt, "CreatedAt timestamp required")
        XCTAssertNotNil(transaction.entityId, "EntityId must be initialized")
        
        // Verify relationship initialization
        XCTAssertNotNil(transaction.lineItems, "LineItems relationship must be initialized")
        XCTAssertEqual(transaction.lineItems.count, 0, "New transaction should have no line items")
    }
    
    func testTransactionCreationWithMinimalValidData() {
        // Given: Minimal valid parameters (testing required vs optional fields)
        let amount = 89.50
        let category = "Coffee"
        
        // When: Creating transaction with minimal parameters
        let transaction = Transaction.create(
            in: context,
            amount: amount,
            category: category
        )
        
        // Then: Should use appropriate defaults for optional parameters
        XCTAssertEqual(transaction.amount, amount, accuracy: 0.01)
        XCTAssertEqual(transaction.category, category)
        XCTAssertNil(transaction.note, "Note should be nil when not provided")
        XCTAssertEqual(transaction.type, "expense", "Should default to expense type")
        XCTAssertLessThanOrEqual(abs(transaction.date.timeIntervalSinceNow), 1.0, "Date should default to current time")
    }
    
    func testTransactionCreationWithValidationMethod() throws {
        // Given: Valid transaction data for validation method
        let amount = 2847.50
        let category = "Office Supplies"
        let note = "Annual office supply order - Officeworks"
        let type = "business_expense"
        
        // When: Using createWithValidation method
        let transaction = try Transaction.createWithValidation(
            in: context,
            amount: amount,
            category: category,
            note: note,
            type: type
        )
        
        // Then: Should create transaction with validation
        XCTAssertEqual(transaction.amount, amount, accuracy: 0.01)
        XCTAssertEqual(transaction.category, category)
        XCTAssertEqual(transaction.note, note)
        XCTAssertEqual(transaction.type, type)
    }
    
    // MARK: - Data Validation Tests (I-Q-I Quality: Comprehensive Error Handling)
    
    func testTransactionCreationWithEmptyCategory() {
        // Given: Empty category (should trigger validation error)
        let amount = 100.00
        let category = ""
        
        // When/Then: Should throw validation error for empty category
        XCTAssertThrowsError(
            try Transaction.createWithValidation(
                in: context,
                amount: amount,
                category: category
            )
        ) { error in
            XCTAssertTrue(error is TransactionValidationError)
            if case TransactionValidationError.invalidCategory(let message) = error {
                XCTAssertTrue(message.contains("empty"), "Error message should indicate empty category issue")
            }
        }
    }
    
    func testTransactionCreationWithWhitespaceCategory() {
        // Given: Category with only whitespace
        let amount = 50.00
        let category = "   \t\n   "
        
        // When/Then: Should throw validation error for whitespace-only category
        XCTAssertThrowsError(
            try Transaction.createWithValidation(
                in: context,
                amount: amount,
                category: category
            )
        ) { error in
            XCTAssertTrue(error is TransactionValidationError)
        }
    }
    
    func testTransactionCreationWithInvalidAmount() {
        // Given: Invalid amount values
        let category = "Test Category"
        let invalidAmounts = [Double.nan, Double.infinity, -Double.infinity]
        
        for invalidAmount in invalidAmounts {
            // When/Then: Should throw validation error for invalid amounts
            XCTAssertThrowsError(
                try Transaction.createWithValidation(
                    in: context,
                    amount: invalidAmount,
                    category: category
                )
            ) { error in
                XCTAssertTrue(error is TransactionValidationError)
                if case TransactionValidationError.invalidAmount(let message) = error {
                    XCTAssertTrue(message.contains("finite"), "Error should indicate finite number requirement")
                }
            }
        }
    }
    
    func testTransactionCreationWithEmptyType() {
        // Given: Empty transaction type
        let amount = 100.00
        let category = "Valid Category"
        let type = ""
        
        // When/Then: Should throw validation error for empty type
        XCTAssertThrowsError(
            try Transaction.createWithValidation(
                in: context,
                amount: amount,
                category: category,
                type: type
            )
        ) { error in
            XCTAssertTrue(error is TransactionValidationError)
            if case TransactionValidationError.invalidType(let message) = error {
                XCTAssertTrue(message.contains("empty"), "Error should indicate empty type issue")
            }
        }
    }
    
    // MARK: - Real Australian Financial Data Tests (I-Q-I Quality: Authentic Data)
    
    func testTransactionWithAustralianBusinessExpense() {
        // Given: Authentic Australian business expense
        let transaction = Transaction.create(
            in: context,
            amount: 1899.00, // Business laptop from JB Hi-Fi
            category: "Computer Equipment",
            note: "ASUS ZenBook Pro - JB Hi-Fi Sydney CBD",
            type: "business_expense"
        )
        
        // Then: Should handle Australian currency amounts correctly
        XCTAssertEqual(transaction.amount, 1899.00, accuracy: 0.01)
        XCTAssertEqual(transaction.category, "Computer Equipment")
        XCTAssertTrue(transaction.note?.contains("JB Hi-Fi") == true, "Should preserve Australian retailer information")
        XCTAssertEqual(transaction.type, "business_expense")
    }
    
    func testTransactionWithAustralianGroceryShopping() {
        // Given: Typical Australian grocery shopping
        let transaction = Transaction.create(
            in: context,
            amount: 157.85,
            category: "Groceries",
            note: "Weekly shop - Woolworths Metro",
            type: "personal_expense"
        )
        
        // Then: Should accurately represent Australian grocery spending
        XCTAssertEqual(transaction.amount, 157.85, accuracy: 0.01)
        XCTAssertEqual(transaction.category, "Groceries")
        XCTAssertTrue(transaction.note?.contains("Woolworths") == true)
        XCTAssertEqual(transaction.type, "personal_expense")
    }
    
    func testTransactionWithAustralianCafePurchase() {
        // Given: Australian café purchase (common Australian expense)
        let transaction = Transaction.create(
            in: context,
            amount: 18.50,
            category: "Food & Beverage",
            note: "Flat white + avocado toast - The Grounds of Alexandria",
            type: "personal_expense"
        )
        
        // Then: Should handle small Australian currency transactions
        XCTAssertEqual(transaction.amount, 18.50, accuracy: 0.01)
        XCTAssertEqual(transaction.category, "Food & Beverage")
        XCTAssertTrue(transaction.note?.contains("Flat white") == true, "Should preserve Australian coffee culture terms")
        XCTAssertTrue(transaction.note?.contains("The Grounds") == true, "Should preserve Australian venue names")
    }
    
    // MARK: - Computed Properties Tests (I-Q-I Quality: API Consistency)
    
    func testEntityNameWithAssignedEntity() {
        // Given: Transaction with assigned entity
        let entity = FinancialEntity.create(in: context, name: "Personal Account", type: "bank_account")
        let transaction = Transaction.create(
            in: context,
            amount: 100.00,
            category: "Test"
        )
        transaction.assignedEntity = entity
        
        // When: Accessing entityName property
        let entityName = transaction.entityName
        
        // Then: Should return entity name
        XCTAssertEqual(entityName, "Personal Account")
    }
    
    func testEntityNameWithoutAssignedEntity() {
        // Given: Transaction without assigned entity
        let transaction = Transaction.create(
            in: context,
            amount: 100.00,
            category: "Test"
        )
        
        // When: Accessing entityName property
        let entityName = transaction.entityName
        
        // Then: Should return "Unassigned" default
        XCTAssertEqual(entityName, "Unassigned")
    }
    
    func testDescPropertyBackwardCompatibility() {
        // Given: Transaction with note
        let transaction = Transaction.create(
            in: context,
            amount: 100.00,
            category: "Test",
            note: "Test description"
        )
        
        // When: Accessing desc property
        let description = transaction.desc
        
        // Then: Should return note content
        XCTAssertEqual(description, "Test description")
        
        // When: Setting desc property
        transaction.desc = "Updated description"
        
        // Then: Should update note property
        XCTAssertEqual(transaction.note, "Updated description")
    }
    
    func testDescPropertyWithEmptyString() {
        // Given: Transaction
        let transaction = Transaction.create(
            in: context,
            amount: 100.00,
            category: "Test"
        )
        
        // When: Setting desc to empty string
        transaction.desc = ""
        
        // Then: Should set note to nil (clean data handling)
        XCTAssertNil(transaction.note)
        
        // When: Accessing desc property with nil note
        let description = transaction.desc
        
        // Then: Should return empty string
        XCTAssertEqual(description, "")
    }
    
    // MARK: - Core Data Fetch Request Tests (I-Q-I Quality: Query Optimization)
    
    func testFetchRequestCreation() {
        // When: Creating fetch request
        let fetchRequest = Transaction.fetchRequest()
        
        // Then: Should return properly configured NSFetchRequest
        XCTAssertEqual(fetchRequest.entityName, "Transaction")
        XCTAssertTrue(fetchRequest.resultType == .managedObjectResultType)
    }
    
    func testFetchTransactionsForEntity() throws {
        // Given: Financial entity with transactions
        let entity = FinancialEntity.create(in: context, name: "Business Account", type: "bank_account")
        
        let transaction1 = Transaction.create(
            in: context,
            amount: 500.00,
            category: "Income",
            note: "Consulting payment"
        )
        transaction1.assignedEntity = entity
        
        let transaction2 = Transaction.create(
            in: context,
            amount: -200.00,
            category: "Expense",
            note: "Office supplies"
        )
        transaction2.assignedEntity = entity
        
        // Create transaction for different entity (should not be included)
        let otherEntity = FinancialEntity.create(in: context, name: "Personal Account", type: "bank_account")
        let otherTransaction = Transaction.create(
            in: context,
            amount: 100.00,
            category: "Personal"
        )
        otherTransaction.assignedEntity = otherEntity
        
        try context.save()
        
        // When: Fetching transactions for specific entity
        let fetchedTransactions = try Transaction.fetchTransactions(for: entity, in: context)
        
        // Then: Should return only transactions for the specified entity
        XCTAssertEqual(fetchedTransactions.count, 2)
        
        let fetchedIds = Set(fetchedTransactions.map { $0.id })
        XCTAssertTrue(fetchedIds.contains(transaction1.id))
        XCTAssertTrue(fetchedIds.contains(transaction2.id))
        XCTAssertFalse(fetchedIds.contains(otherTransaction.id))
        
        // Verify sorting (most recent first)
        XCTAssertGreaterThanOrEqual(fetchedTransactions[0].date, fetchedTransactions[1].date)
    }
    
    func testFetchTransactionsInDateRange() throws {
        // Given: Transactions with different dates
        let baseDate = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -7, to: baseDate)!
        let endDate = Calendar.current.date(byAdding: .day, value: 0, to: baseDate)!
        
        // Transaction within range
        let inRangeTransaction = Transaction.create(
            in: context,
            amount: 100.00,
            category: "Test",
            date: Calendar.current.date(byAdding: .day, value: -3, to: baseDate)!
        )
        
        // Transaction outside range (too old)
        let oldTransaction = Transaction.create(
            in: context,
            amount: 200.00,
            category: "Test",
            date: Calendar.current.date(byAdding: .day, value: -10, to: baseDate)!
        )
        
        // Transaction outside range (too new)
        let futureTransaction = Transaction.create(
            in: context,
            amount: 300.00,
            category: "Test",
            date: Calendar.current.date(byAdding: .day, value: 1, to: baseDate)!
        )
        
        try context.save()
        
        // When: Fetching transactions in date range
        let fetchedTransactions = try Transaction.fetchTransactions(
            from: startDate,
            to: endDate,
            in: context
        )
        
        // Then: Should return only transactions within the date range
        XCTAssertEqual(fetchedTransactions.count, 1)
        XCTAssertEqual(fetchedTransactions.first?.id, inRangeTransaction.id)
    }
    
    // MARK: - Performance Tests (I-Q-I Quality: Scalability Validation)
    
    func testTransactionCreationPerformance() {
        // Given: Large number of transactions to create
        let transactionCount = 1000
        
        // When: Creating many transactions
        measure {
            for i in 0..<transactionCount {
                _ = Transaction.create(
                    in: context,
                    amount: Double(i) * 10.0,
                    category: "Performance Test \(i % 10)",
                    note: "Performance test transaction #\(i)"
                )
            }
        }
        
        // Then: Should handle large-scale creation efficiently
        let fetchRequest = Transaction.fetchRequest()
        do {
            let allTransactions = try context.fetch(fetchRequest)
            XCTAssertGreaterThanOrEqual(allTransactions.count, transactionCount)
        } catch {
            XCTFail("Failed to fetch transactions: \(error)")
        }
    }
    
    func testTransactionFetchPerformance() throws {
        // Given: Large number of transactions in context
        let transactionCount = 500
        
        for i in 0..<transactionCount {
            _ = Transaction.create(
                in: context,
                amount: Double(i) * 5.0,
                category: "Category \(i % 5)",
                note: "Test transaction #\(i)"
            )
        }
        
        try context.save()
        
        // When: Fetching all transactions
        measure {
            do {
                let fetchRequest = Transaction.fetchRequest()
                _ = try context.fetch(fetchRequest)
            } catch {
                XCTFail("Fetch failed: \(error)")
            }
        }
    }
    
    // MARK: - Core Data Persistence Tests (I-Q-I Quality: Data Integrity)
    
    func testTransactionPersistence() throws {
        // Given: Transaction with complete data
        let originalAmount = 4299.00
        let originalCategory = "Business Equipment"
        let originalNote = "MacBook Pro 16-inch"
        
        let transaction = Transaction.create(
            in: context,
            amount: originalAmount,
            category: originalCategory,
            note: originalNote
        )
        
        let transactionId = transaction.id
        
        // When: Saving and refetching
        try context.save()
        
        let fetchRequest = Transaction.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", transactionId as NSUUID)
        
        let fetchedTransactions = try context.fetch(fetchRequest)
        
        // Then: Should persist and fetch correctly
        XCTAssertEqual(fetchedTransactions.count, 1)
        
        let fetchedTransaction = fetchedTransactions.first!
        XCTAssertEqual(fetchedTransaction.id, transactionId)
        XCTAssertEqual(fetchedTransaction.amount, originalAmount, accuracy: 0.01)
        XCTAssertEqual(fetchedTransaction.category, originalCategory)
        XCTAssertEqual(fetchedTransaction.note, originalNote)
    }
    
    // MARK: - Edge Cases and Boundary Tests (I-Q-I Quality: Robustness)
    
    func testTransactionWithVeryLargeAmount() {
        // Given: Very large but valid amount (billionaire's transaction)
        let largeAmount = 999_999_999.99
        
        // When: Creating transaction with large amount
        let transaction = Transaction.create(
            in: context,
            amount: largeAmount,
            category: "Investment"
        )
        
        // Then: Should handle large amounts correctly
        XCTAssertEqual(transaction.amount, largeAmount, accuracy: 0.01)
    }
    
    func testTransactionWithVerySmallAmount() {
        // Given: Very small but valid amount (fraction of cent)
        let smallAmount = 0.001
        
        // When: Creating transaction with small amount
        let transaction = Transaction.create(
            in: context,
            amount: smallAmount,
            category: "Micro Transaction"
        )
        
        // Then: Should handle small amounts with precision
        XCTAssertEqual(transaction.amount, smallAmount, accuracy: 0.0001)
    }
    
    func testTransactionWithNegativeAmount() {
        // Given: Negative amount (refund or correction)
        let negativeAmount = -456.78
        
        // When: Creating transaction with negative amount
        let transaction = Transaction.create(
            in: context,
            amount: negativeAmount,
            category: "Refund"
        )
        
        // Then: Should handle negative amounts correctly
        XCTAssertEqual(transaction.amount, negativeAmount, accuracy: 0.01)
    }
    
    func testTransactionWithUnicodeCategory() {
        // Given: Category with Unicode characters
        let unicodeCategory = "Café & Restaurant 🍽️"
        
        // When: Creating transaction with Unicode category
        let transaction = Transaction.create(
            in: context,
            amount: 89.50,
            category: unicodeCategory
        )
        
        // Then: Should preserve Unicode characters correctly
        XCTAssertEqual(transaction.category, unicodeCategory)
    }
    
    func testTransactionWithLongNote() {
        // Given: Very long note (stress test for string handling)
        let longNote = String(repeating: "This is a very long transaction note that tests the system's ability to handle extensive text input. ", count: 20)
        
        // When: Creating transaction with long note
        let transaction = Transaction.create(
            in: context,
            amount: 100.00,
            category: "Test",
            note: longNote
        )
        
        // Then: Should handle long notes correctly
        XCTAssertEqual(transaction.note, longNote)
        XCTAssertGreaterThan(transaction.note?.count ?? 0, 1000)
    }
}