import XCTest
import CoreData
@testable import FinanceMate

/**
 * TransactionLineItemsTests.swift
 * 
 * Purpose: TDD test suite for TransactionLineItems module - line item decomposition functionality
 * Issues & Complexity Summary: LineItem entity validation, transaction relationships, itemized breakdown
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~250
 *   - Core Algorithm Complexity: Medium (item decomposition, relationship management)
 *   - Dependencies: 3 (Transaction, SplitAllocation, Core Data)
 *   - State Management Complexity: Medium (parent-child relationships)
 *   - Novelty/Uncertainty Factor: Low (established Core Data patterns)
 * AI Pre-Task Self-Assessment: 90%
 * Problem Estimate: 80%
 * Initial Code Complexity Estimate: 75%
 * Final Code Complexity: TBD
 * Overall Result Score: TBD
 * Key Variances/Learnings: TDD for complex transaction decomposition logic
 * Last Updated: 2025-08-04
 */

@MainActor
final class TransactionLineItemsTests: XCTestCase {
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
    
    // MARK: - LineItem Core Functionality Tests
    
    func testLineItemCreation() {
        // Given: A parent transaction
        let transaction = Transaction.create(
            in: context,
            amount: 567.89,
            category: "Office Supplies",
            note: "Business equipment purchase"
        )
        
        // When: Creating line items for the transaction
        let laptopItem = LineItem.create(
            in: context,
            itemDescription: "MacBook Pro 16-inch",
            amount: 4299.00,
            transaction: transaction
        )
        
        let mouseItem = LineItem.create(
            in: context,
            itemDescription: "Magic Mouse",
            amount: 149.00,
            transaction: transaction
        )
        
        // Then: Line items should be properly created and linked
        XCTAssertNotNil(laptopItem.id, "LineItem should have UUID")
        XCTAssertEqual(laptopItem.itemDescription, "MacBook Pro 16-inch")
        XCTAssertEqual(laptopItem.amount, 4299.00, accuracy: 0.01)
        XCTAssertEqual(laptopItem.transaction, transaction)
        
        XCTAssertNotNil(mouseItem.id, "LineItem should have UUID")
        XCTAssertEqual(mouseItem.itemDescription, "Magic Mouse")
        XCTAssertEqual(mouseItem.amount, 149.00, accuracy: 0.01)
        XCTAssertEqual(mouseItem.transaction, transaction)
        
        // Verify relationship from transaction side
        XCTAssertTrue(transaction.lineItems.contains(laptopItem))
        XCTAssertTrue(transaction.lineItems.contains(mouseItem))
        XCTAssertEqual(transaction.lineItems.count, 2)
    }
    
    func testLineItemFetchRequest() {
        // Given: Line items in database
        let transaction = Transaction.create(
            in: context,
            amount: 234.56,
            category: "Groceries"
        )
        
        let item1 = LineItem.create(
            in: context,
            itemDescription: "Organic vegetables",
            amount: 89.50,
            transaction: transaction
        )
        
        let item2 = LineItem.create(
            in: context,
            itemDescription: "Free-range chicken",
            amount: 145.06,
            transaction: transaction
        )
        
        // When: Using fetch request
        let fetchRequest = LineItem.fetchRequest()
        
        // Then: Should be able to fetch line items
        do {
            let lineItems = try context.fetch(fetchRequest)
            XCTAssertGreaterThanOrEqual(lineItems.count, 2)
            
            let fetchedIds = Set(lineItems.map { $0.id })
            XCTAssertTrue(fetchedIds.contains(item1.id))
            XCTAssertTrue(fetchedIds.contains(item2.id))
        } catch {
            XCTFail("Failed to fetch line items: \(error)")
        }
    }
    
    // MARK: - Real Australian Business Transaction Tests
    
    func testLineItemsAustralianBusinessExpense() {
        // Given: Authentic Australian business expense transaction
        let businessTransaction = Transaction.create(
            in: context,
            amount: 2458.90,
            category: "Business Equipment",
            note: "Office setup - JB Hi-Fi purchase"
        )
        
        // When: Breaking down into realistic line items
        let laptop = LineItem.create(
            in: context,
            itemDescription: "ASUS ZenBook Pro - Business laptop",
            amount: 1899.00,
            transaction: businessTransaction
        )
        
        let monitor = LineItem.create(
            in: context,
            itemDescription: "Dell 27-inch monitor",
            amount: 449.00,
            transaction: businessTransaction
        )
        
        let keyboard = LineItem.create(
            in: context,
            itemDescription: "Logitech MX Keys",
            amount: 110.90,
            transaction: businessTransaction
        )
        
        // Then: All line items should reflect real Australian business purchases
        XCTAssertEqual(laptop.amount, 1899.00, accuracy: 0.01)
        XCTAssertEqual(monitor.amount, 449.00, accuracy: 0.01)
        XCTAssertEqual(keyboard.amount, 110.90, accuracy: 0.01)
        
        // Verify total breakdown matches transaction patterns (GST inclusive)
        let totalLineItems = laptop.amount + monitor.amount + keyboard.amount
        XCTAssertEqual(totalLineItems, 2458.90, accuracy: 0.01)
        
        XCTAssertEqual(businessTransaction.lineItems.count, 3)
    }
    
    func testLineItemsGroceryShoppingBreakdown() {
        // Given: Australian grocery shopping transaction
        let groceryTransaction = Transaction.create(
            in: context,
            amount: 157.85,
            category: "Groceries",
            note: "Weekly shop - Woolworths"
        )
        
        // When: Creating realistic grocery line items
        let produce = LineItem.create(
            in: context,
            itemDescription: "Fresh produce - vegetables & fruit",
            amount: 45.60,
            transaction: groceryTransaction
        )
        
        let meat = LineItem.create(
            in: context,
            itemDescription: "Free-range chicken & beef mince",
            amount: 67.80,
            transaction: groceryTransaction
        )
        
        let dairy = LineItem.create(
            in: context,
            itemDescription: "Milk, cheese & yogurt",
            amount: 28.90,
            transaction: groceryTransaction
        )
        
        let pantry = LineItem.create(
            in: context,
            itemDescription: "Bread, pasta & pantry items",
            amount: 15.55,
            transaction: groceryTransaction
        )
        
        // Then: Line items should represent realistic grocery categories
        let expectedAmounts = [45.60, 67.80, 28.90, 15.55]
        let actualAmounts = [produce.amount, meat.amount, dairy.amount, pantry.amount]
        
        for (expected, actual) in zip(expectedAmounts, actualAmounts) {
            XCTAssertEqual(actual, expected, accuracy: 0.01)
        }
        
        let totalItems = actualAmounts.reduce(0, +)
        XCTAssertEqual(totalItems, 157.85, accuracy: 0.01)
        XCTAssertEqual(groceryTransaction.lineItems.count, 4)
    }
    
    func testLineItemsRestaurantBillBreakdown() {
        // Given: Australian restaurant bill with itemized breakdown
        let restaurantTransaction = Transaction.create(
            in: context,
            amount: 189.50,
            category: "Dining",
            note: "Business lunch - The Grounds of Alexandria"
        )
        
        // When: Breaking down restaurant bill items
        let mains = LineItem.create(
            in: context,
            itemDescription: "2x Signature burgers",
            amount: 68.00,
            transaction: restaurantTransaction
        )
        
        let drinks = LineItem.create(
            in: context,
            itemDescription: "2x Craft beers + coffee",
            amount: 35.50,
            transaction: restaurantTransaction
        )
        
        let dessert = LineItem.create(
            in: context,
            itemDescription: "Shared dessert platter",
            amount: 24.00,
            transaction: restaurantTransaction
        )
        
        let service = LineItem.create(
            in: context,
            itemDescription: "Service charge (10%)",
            amount: 12.75,
            transaction: restaurantTransaction
        )
        
        let tip = LineItem.create(
            in: context,
            itemDescription: "Tip (25%)",
            amount: 49.25,
            transaction: restaurantTransaction
        )
        
        // Then: Should reflect realistic Australian dining experience
        let itemAmounts = [mains.amount, drinks.amount, dessert.amount, service.amount, tip.amount]
        let expectedAmounts = [68.00, 35.50, 24.00, 12.75, 49.25]
        
        for (expected, actual) in zip(expectedAmounts, itemAmounts) {
            XCTAssertEqual(actual, expected, accuracy: 0.01)
        }
        
        let totalBill = itemAmounts.reduce(0, +)
        XCTAssertEqual(totalBill, 189.50, accuracy: 0.01)
        XCTAssertEqual(restaurantTransaction.lineItems.count, 5)
    }
    
    // MARK: - LineItem Relationship Tests
    
    func testLineItemTransactionRelationshipIntegrity() {
        // Given: Multiple transactions with line items
        let transaction1 = Transaction.create(
            in: context,
            amount: 100.00,
            category: "Category1"
        )
        
        let transaction2 = Transaction.create(
            in: context,
            amount: 200.00,
            category: "Category2"
        )
        
        // When: Creating line items for different transactions
        let item1 = LineItem.create(
            in: context,
            itemDescription: "Item for transaction 1",
            amount: 50.00,
            transaction: transaction1
        )
        
        let item2 = LineItem.create(
            in: context,
            itemDescription: "Another item for transaction 1",
            amount: 50.00,
            transaction: transaction1
        )
        
        let item3 = LineItem.create(
            in: context,
            itemDescription: "Item for transaction 2",
            amount: 200.00,
            transaction: transaction2
        )
        
        // Then: Relationships should be correctly maintained
        XCTAssertEqual(transaction1.lineItems.count, 2)
        XCTAssertEqual(transaction2.lineItems.count, 1)
        
        XCTAssertTrue(transaction1.lineItems.contains(item1))
        XCTAssertTrue(transaction1.lineItems.contains(item2))
        XCTAssertFalse(transaction1.lineItems.contains(item3))
        
        XCTAssertTrue(transaction2.lineItems.contains(item3))
        XCTAssertFalse(transaction2.lineItems.contains(item1))
        XCTAssertFalse(transaction2.lineItems.contains(item2))
    }
    
    func testLineItemSplitAllocationRelationship() {
        // Given: A line item
        let transaction = Transaction.create(
            in: context,
            amount: 500.00,
            category: "Mixed Expense"
        )
        
        let lineItem = LineItem.create(
            in: context,
            itemDescription: "Business lunch with client meeting",
            amount: 280.00,
            transaction: transaction
        )
        
        // When: Creating split allocations (will be tested in SplitAllocation tests)
        // For now, just verify the relationship exists
        
        // Then: LineItem should have splitAllocations relationship
        XCTAssertNotNil(lineItem.splitAllocations, "LineItem should have splitAllocations relationship")
    }
    
    // MARK: - Performance Tests with Real Data
    
    func testLineItemPerformanceWithManyItems() {
        // Given: A transaction with many line items (large receipt scenario)
        let largeTransaction = Transaction.create(
            in: context,
            amount: 2847.50,
            category: "Office Supplies",
            note: "Annual office supply order - Officeworks"
        )
        
        // When: Creating many line items (realistic office supply order)
        let officeSupplies = [
            ("A4 Copy Paper - 10 reams", 89.90),
            ("Ballpoint pens - 50 pack", 45.60),
            ("Printer cartridges - set of 4", 234.80),
            ("Folders & binders - assorted", 67.30),
            ("Whiteboard markers - 20 pack", 78.90),
            ("Desk organizers - set of 5", 145.70),
            ("Notebooks & notepads - bulk", 95.40),
            ("Staplers & hole punches", 123.50),
            ("Calculator & office tools", 189.20),
            ("Filing cabinets - 2 units", 567.80),
            ("Desk chairs - 3 units", 789.60),
            ("Monitor stands - 4 units", 234.50),
            ("Cable management", 89.70),
            ("Cleaning supplies", 67.80),
            ("First aid kit", 56.90)
        ]
        
        measure {
            for (description, amount) in officeSupplies {
                _ = LineItem.create(
                    in: context,
                    itemDescription: description,
                    amount: amount,
                    transaction: largeTransaction
                )
            }
        }
        
        // Then: All line items should be created efficiently
        XCTAssertEqual(largeTransaction.lineItems.count, officeSupplies.count)
        
        let totalAmount = officeSupplies.reduce(0.0) { $0 + $1.1 }
        XCTAssertEqual(totalAmount, 2847.50, accuracy: 0.01)
    }
    
    // MARK: - Edge Cases and Validation Tests
    
    func testLineItemWithZeroAmount() {
        // Given: A transaction and zero amount scenario
        let transaction = Transaction.create(
            in: context,
            amount: 100.00,
            category: "Test"
        )
        
        // When: Creating line item with zero amount (e.g., free item)
        let freeItem = LineItem.create(
            in: context,
            itemDescription: "Complimentary coffee",
            amount: 0.00,
            transaction: transaction
        )
        
        // Then: Should handle zero amounts correctly
        XCTAssertEqual(freeItem.amount, 0.00, accuracy: 0.01)
        XCTAssertEqual(freeItem.itemDescription, "Complimentary coffee")
        XCTAssertEqual(freeItem.transaction, transaction)
    }
    
    func testLineItemWithLongDescription() {
        // Given: A transaction
        let transaction = Transaction.create(
            in: context,
            amount: 89.50,
            category: "Professional Services"
        )
        
        // When: Creating line item with very long description
        let longDescription = "Professional accounting consultation for small business tax planning and quarterly BAS preparation including GST reconciliation and record keeping advice for Australian Tax Office compliance requirements and business activity statement lodgement"
        
        let lineItem = LineItem.create(
            in: context,
            itemDescription: longDescription,
            amount: 89.50,
            transaction: transaction
        )
        
        // Then: Should handle long descriptions correctly
        XCTAssertEqual(lineItem.itemDescription, longDescription)
        XCTAssertEqual(lineItem.amount, 89.50, accuracy: 0.01)
    }
    
    func testLineItemUnicodeDescriptions() {
        // Given: A transaction
        let transaction = Transaction.create(
            in: context,
            amount: 145.80,
            category: "International Food"
        )
        
        // When: Creating line items with Unicode descriptions
        let unicodeItems = [
            ("Café au lait ☕️", 8.50),
            ("Paella Valenciana 🥘", 67.80),
            ("Sushi platter 🍱", 45.90),
            ("Crème brûlée 🍮", 23.60)
        ]
        
        for (description, amount) in unicodeItems {
            let lineItem = LineItem.create(
                in: context,
                itemDescription: description,
                amount: amount,
                transaction: transaction
            )
            
            // Then: Should preserve Unicode characters
            XCTAssertEqual(lineItem.itemDescription, description)
            XCTAssertEqual(lineItem.amount, amount, accuracy: 0.01)
        }
        
        XCTAssertEqual(transaction.lineItems.count, unicodeItems.count)
    }
    
    // MARK: - Core Data Persistence Tests
    
    func testLineItemPersistence() {
        // Given: A transaction with line items
        let transaction = Transaction.create(
            in: context,
            amount: 234.50,
            category: "Test Persistence"
        )
        
        let lineItem = LineItem.create(
            in: context,
            itemDescription: "Test item for persistence",
            amount: 234.50,
            transaction: transaction
        )
        
        let itemId = lineItem.id
        
        // When: Saving and fetching from context
        do {
            try context.save()
            
            let fetchRequest = LineItem.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", itemId as NSUUID)
            
            let fetchedItems = try context.fetch(fetchRequest)
            
            // Then: Should persist and fetch correctly
            XCTAssertEqual(fetchedItems.count, 1)
            
            let fetchedItem = fetchedItems.first!
            XCTAssertEqual(fetchedItem.id, itemId)
            XCTAssertEqual(fetchedItem.itemDescription, "Test item for persistence")
            XCTAssertEqual(fetchedItem.amount, 234.50, accuracy: 0.01)
            XCTAssertEqual(fetchedItem.transaction.id, transaction.id)
        } catch {
            XCTFail("Failed to save or fetch line item: \(error)")
        }
    }
}