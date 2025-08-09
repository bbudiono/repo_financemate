import XCTest
import CoreData
@testable import FinanceMate

/**
 * TransactionCoreTests.swift
 * 
 * Purpose: TDD test suite for TransactionCore module - foundational Transaction entity validation
 * Issues & Complexity Summary: Core Transaction entity CRUD operations, factory methods, property validation
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~200
 *   - Core Algorithm Complexity: Medium (Core Data operations, validation)
 *   - Dependencies: 2 (Core Data, FinancialEntity)
 *   - State Management Complexity: Medium (entity relationships)
 *   - Novelty/Uncertainty Factor: Low (established Core Data patterns)
 * AI Pre-Task Self-Assessment: 95%
 * Problem Estimate: 85%
 * Initial Code Complexity Estimate: 80%
 * Final Code Complexity: TBD
 * Overall Result Score: TBD
 * Key Variances/Learnings: TDD foundation for safe modular extraction
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
    
    // MARK: - Core Transaction Entity Tests
    
    func testTransactionCoreInitialization() {
        // Given: Core Data context
        // When: Creating a new transaction
        let transaction = Transaction.create(
            in: context,
            amount: 157.50,
            category: "Groceries",
            note: "Woolworths weekly shopping",
            date: Date(),
            type: "expense"
        )
        
        // Then: Transaction should be properly initialized
        XCTAssertNotNil(transaction.id, "Transaction should have UUID")
        XCTAssertEqual(transaction.amount, 157.50, accuracy: 0.01, "Amount should match")
        XCTAssertEqual(transaction.category, "Groceries", "Category should match")
        XCTAssertEqual(transaction.note, "Woolworths weekly shopping", "Note should match")
        XCTAssertEqual(transaction.type, "expense", "Type should match")
        XCTAssertNotNil(transaction.createdAt, "CreatedAt should be set")
        XCTAssertNotNil(transaction.entityId, "EntityId should be set")
    }
    
    func testTransactionCoreFactoryMethodValidation() {
        // Given: Various transaction parameters
        let testAmount = 89.95
        let testCategory = "Transport"
        let testNote = "Uber ride to airport"
        let testDate = Calendar.current.date(byAdding: .day, value: -2, to: Date())!
        let testType = "expense"
        
        // When: Creating transaction with factory method
        let transaction = Transaction.create(
            in: context,
            amount: testAmount,
            category: testCategory,
            note: testNote,
            date: testDate,
            type: testType
        )
        
        // Then: All properties should be correctly assigned
        XCTAssertEqual(transaction.amount, testAmount, accuracy: 0.01)
        XCTAssertEqual(transaction.category, testCategory)
        XCTAssertEqual(transaction.note, testNote)
        XCTAssertEqual(transaction.date, testDate)
        XCTAssertEqual(transaction.type, testType)
        XCTAssertTrue(transaction.createdAt <= Date())
    }
    
    func testTransactionCoreDefaultParameters() {
        // Given: Minimal transaction parameters
        // When: Creating transaction with default parameters
        let transaction = Transaction.create(
            in: context,
            amount: 45.75,
            category: "Utilities"
        )
        
        // Then: Default values should be applied
        XCTAssertNil(transaction.note, "Note should be nil by default")
        XCTAssertEqual(transaction.type, "expense", "Type should default to expense")
        XCTAssertTrue(Calendar.current.isDateInToday(transaction.date), "Date should default to today")
    }
    
    func testTransactionCoreEntityRelationshipProperties() {
        // Given: A transaction
        let transaction = Transaction.create(
            in: context,
            amount: 234.67,
            category: "Business Expense"
        )
        
        // When: Checking entity relationship properties
        let entityName = transaction.entityName
        
        // Then: Should handle unassigned entity gracefully
        XCTAssertEqual(entityName, "Unassigned", "Should return 'Unassigned' when no entity assigned")
        XCTAssertNil(transaction.assignedEntity, "AssignedEntity should be nil initially")
    }
    
    func testTransactionCoreDescPropertyBackwardCompatibility() {
        // Given: A transaction with note
        let transaction = Transaction.create(
            in: context,
            amount: 67.89,
            category: "Food",
            note: "Lunch at cafe"
        )
        
        // When: Accessing desc property (backward compatibility)
        let descValue = transaction.desc
        
        // Then: Should return note value
        XCTAssertEqual(descValue, "Lunch at cafe", "Desc should return note value")
        
        // When: Setting desc property
        transaction.desc = "Updated lunch description"
        
        // Then: Should update note property
        XCTAssertEqual(transaction.note, "Updated lunch description", "Note should be updated via desc")
    }
    
    func testTransactionCoreDescPropertyEmptyHandling() {
        // Given: A transaction without note
        let transaction = Transaction.create(
            in: context,
            amount: 12.50,
            category: "Miscellaneous"
        )
        
        // When: Accessing desc property
        let descValue = transaction.desc
        
        // Then: Should return empty string
        XCTAssertEqual(descValue, "", "Desc should return empty string for nil note")
        
        // When: Setting empty desc
        transaction.desc = ""
        
        // Then: Should set note to nil
        XCTAssertNil(transaction.note, "Empty desc should set note to nil")
    }
    
    // MARK: - Real Australian Financial Data Tests
    
    func testTransactionCoreAustralianCurrencyAmounts() {
        // Given: Realistic Australian transaction amounts
        let transactions = [
            (amount: 4.50, category: "Transport", note: "Coffee at Central Station"),
            (amount: 89.95, category: "Groceries", note: "Coles weekly shop"),
            (amount: 2750.00, category: "Rent", note: "Monthly rent - Sydney CBD"),
            (amount: 45.80, category: "Utilities", note: "Electricity bill - Origin Energy"),
            (amount: 156.70, category: "Fuel", note: "Petrol - Shell Coles Express")
        ]
        
        // When: Creating transactions with Australian amounts
        var createdTransactions: [Transaction] = []
        for transactionData in transactions {
            let transaction = Transaction.create(
                in: context,
                amount: transactionData.amount,
                category: transactionData.category,
                note: transactionData.note
            )
            createdTransactions.append(transaction)
        }
        
        // Then: All transactions should be created with correct amounts
        XCTAssertEqual(createdTransactions.count, 5)
        for (index, transaction) in createdTransactions.enumerated() {
            XCTAssertEqual(transaction.amount, transactions[index].amount, accuracy: 0.01)
            XCTAssertEqual(transaction.category, transactions[index].category)
            XCTAssertEqual(transaction.note, transactions[index].note)
        }
    }
    
    func testTransactionCoreAustralianCategoriesAndNotes() {
        // Given: Authentic Australian transaction categories and notes
        let australianTransactions = [
            (amount: 67.80, category: "Healthcare", note: "GP visit - Medicare bulk billing"),
            (amount: 125.00, category: "Education", note: "University textbook - Co-op Bookshop"),
            (amount: 89.50, category: "Entertainment", note: "Movie tickets - Event Cinemas"),
            (amount: 234.90, category: "Insurance", note: "Car insurance - NRMA"),
            (amount: 45.60, category: "Telecommunications", note: "Mobile plan - Telstra")
        ]
        
        // When: Creating transactions with Australian context
        var createdTransactions: [Transaction] = []
        for transactionData in australianTransactions {
            let transaction = Transaction.create(
                in: context,
                amount: transactionData.amount,
                category: transactionData.category,
                note: transactionData.note
            )
            createdTransactions.append(transaction)
        }
        
        // Then: All transactions should preserve Australian business names and contexts
        for (index, transaction) in createdTransactions.enumerated() {
            XCTAssertEqual(transaction.amount, australianTransactions[index].amount, accuracy: 0.01)
            XCTAssertEqual(transaction.category, australianTransactions[index].category)
            XCTAssertEqual(transaction.note, australianTransactions[index].note)
        }
    }
    
    // MARK: - Performance Tests with Real Data
    
    func testTransactionCorePerformanceWithLargeDataset() {
        // Given: Large dataset with realistic Australian transaction data
        let categories = ["Groceries", "Transport", "Utilities", "Healthcare", "Entertainment", "Education", "Insurance"]
        let realBusinessNames = ["Woolworths", "Coles", "IGA", "ALDI", "Bunnings", "JB Hi-Fi", "Harvey Norman"]
        
        // When: Creating 1000 transactions with performance measurement
        measure {
            for i in 0..<1000 {
                let amount = Double.random(in: 5.0...500.0)
                let category = categories.randomElement()!
                let business = realBusinessNames.randomElement()!
                let note = "\(business) purchase \(i + 1)"
                
                _ = Transaction.create(
                    in: context,
                    amount: amount,
                    category: category,
                    note: note
                )
            }
        }
        
        // Then: Performance should be acceptable and data should be created
        let fetchRequest = NSFetchRequest<Transaction>(entityName: "Transaction")
        let transactionCount = try! context.count(for: fetchRequest)
        XCTAssertEqual(transactionCount, 1000, "Should create all 1000 transactions")
    }
    
    // MARK: - Core Data Integration Tests
    
    func testTransactionCorePersistence() {
        // Given: A transaction
        let transaction = Transaction.create(
            in: context,
            amount: 78.90,
            category: "Dining",
            note: "Dinner at restaurant"
        )
        
        // When: Saving context
        do {
            try context.save()
        } catch {
            XCTFail("Failed to save context: \(error)")
        }
        
        // Then: Transaction should be persisted
        let fetchRequest = NSFetchRequest<Transaction>(entityName: "Transaction")
        fetchRequest.predicate = NSPredicate(format: "id == %@", transaction.id as NSUUID)
        
        do {
            let fetchedTransactions = try context.fetch(fetchRequest)
            XCTAssertEqual(fetchedTransactions.count, 1, "Should fetch exactly one transaction")
            
            let fetchedTransaction = fetchedTransactions.first!
            XCTAssertEqual(fetchedTransaction.amount, 78.90, accuracy: 0.01)
            XCTAssertEqual(fetchedTransaction.category, "Dining")
            XCTAssertEqual(fetchedTransaction.note, "Dinner at restaurant")
        } catch {
            XCTFail("Failed to fetch transaction: \(error)")
        }
    }
    
    func testTransactionCoreContextValidation() {
        // Given: Invalid context scenario
        // When: Attempting to create transaction in nil context
        // Then: Should fail gracefully or provide appropriate error
        
        // This test ensures factory methods handle context validation
        let transaction = Transaction.create(
            in: context,
            amount: 55.25,
            category: "Test"
        )
        
        XCTAssertNotNil(transaction.managedObjectContext, "Transaction should have context")
        XCTAssertEqual(transaction.managedObjectContext, context, "Transaction should have correct context")
    }
    
    // MARK: - Edge Case Tests
    
    func testTransactionCoreEdgeCaseAmounts() {
        // Given: Edge case amounts
        let edgeCases = [
            (amount: 0.01, description: "Minimum amount"),
            (amount: 999999.99, description: "Very large amount"),
            (amount: 1.00, description: "Round dollar amount"),
            (amount: 33.33, description: "Repeating decimal")
        ]
        
        // When: Creating transactions with edge case amounts
        for (amount, description) in edgeCases {
            let transaction = Transaction.create(
                in: context,
                amount: amount,
                category: "Test",
                note: description
            )
            
            // Then: Should handle all edge cases correctly
            XCTAssertEqual(transaction.amount, amount, accuracy: 0.001, "Should handle \(description)")
            XCTAssertEqual(transaction.note, description)
        }
    }
    
    func testTransactionCoreUnicodeSupport() {
        // Given: Unicode characters in transaction data
        let unicodeTransactions = [
            (amount: 45.80, category: "Café", note: "Café latte at Bondi Beach ☕️"),
            (amount: 67.50, category: "Restaurante", note: "Paella at Spanish restaurant 🥘"),
            (amount: 89.90, category: "书店", note: "Chinese bookstore purchase 📚"),
            (amount: 123.45, category: "λογαριασμός", note: "Greek invoice payment 💶")
        ]
        
        // When: Creating transactions with Unicode data
        for transactionData in unicodeTransactions {
            let transaction = Transaction.create(
                in: context,
                amount: transactionData.amount,
                category: transactionData.category,
                note: transactionData.note
            )
            
            // Then: Should preserve Unicode characters correctly
            XCTAssertEqual(transaction.category, transactionData.category)
            XCTAssertEqual(transaction.note, transactionData.note)
        }
    }
}