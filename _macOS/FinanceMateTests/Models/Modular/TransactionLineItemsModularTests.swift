import XCTest
import CoreData
@testable import FinanceMate

/**
 * TransactionLineItemsModularTests.swift
 * 
 * Purpose: TDD test suite for TransactionLineItems modular component - I-Q-I Protocol validation
 * Issues & Complexity Summary: Modular line item functionality, relationships, Australian financial validation
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~500 (comprehensive test coverage ≥95%)
 *   - Core Algorithm Complexity: Medium-High (relationship testing, business logic validation)
 *   - Dependencies: 4 (LineItem, Transaction, SplitAllocation, Core Data)
 *   - State Management Complexity: Medium-High (relationship integrity testing)
 *   - Novelty/Uncertainty Factor: Low (proven testing patterns)
 * AI Pre-Task Self-Assessment: 90%
 * Problem Estimate: 85%
 * Initial Code Complexity Estimate: 80%
 * I-Q-I Quality Target: 8+/10 - Professional enterprise testing standards
 * Final Code Complexity: TBD
 * Overall Result Score: TBD
 * Key Variances/Learnings: TDD for modular line item architecture with Australian financial context
 * Last Updated: 2025-08-04
 */

@MainActor
final class TransactionLineItemsModularTests: XCTestCase {
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
    
    // MARK: - LineItem Core Creation Tests (I-Q-I Professional Standards)
    
    func testLineItemCreationWithValidData() {
        // Given: Valid transaction and line item parameters
        let transaction = Transaction.create(
            in: context,
            amount: 4299.00,
            category: "Business Equipment",
            note: "Comprehensive office setup"
        )
        
        let itemDescription = "MacBook Pro 16-inch M3 Max"
        let amount = 4299.00
        
        // When: Creating line item with factory method
        let lineItem = LineItem.create(
            in: context,
            itemDescription: itemDescription,
            amount: amount,
            transaction: transaction
        )
        
        // Then: LineItem should be created with professional quality standards
        XCTAssertNotNil(lineItem.id, "LineItem must have UUID for unique identification")
        XCTAssertEqual(lineItem.itemDescription, itemDescription, "Description must match exactly")
        XCTAssertEqual(lineItem.amount, amount, accuracy: 0.01, "Amount must be precise for financial calculations")
        XCTAssertEqual(lineItem.transaction, transaction, "Transaction relationship must be established")
        
        // Verify relationship integrity
        XCTAssertTrue(transaction.lineItems.contains(lineItem), "Transaction should contain the line item")
    }
    
    func testLineItemCreationWithValidationMethod() throws {
        // Given: Valid transaction and parameters for validation method
        let transaction = Transaction.create(
            in: context,
            amount: 1899.00,
            category: "Technology",
            note: "Professional development equipment"
        )
        
        // When: Using createWithValidation method
        let lineItem = try LineItem.createWithValidation(
            in: context,
            itemDescription: "ASUS ZenBook Pro 15 OLED",
            amount: 1899.00,
            transaction: transaction
        )
        
        // Then: Should create line item with validation
        XCTAssertEqual(lineItem.itemDescription, "ASUS ZenBook Pro 15 OLED")
        XCTAssertEqual(lineItem.amount, 1899.00, accuracy: 0.01)
        XCTAssertEqual(lineItem.transaction, transaction)
    }
    
    // MARK: - Data Validation Tests (I-Q-I Quality: Comprehensive Error Handling)
    
    func testLineItemCreationWithEmptyDescription() {
        // Given: Valid transaction but empty description
        let transaction = Transaction.create(
            in: context,
            amount: 100.00,
            category: "Test"
        )
        
        // When/Then: Should throw validation error for empty description
        XCTAssertThrowsError(
            try LineItem.createWithValidation(
                in: context,
                itemDescription: "",
                amount: 100.00,
                transaction: transaction
            )
        ) { error in
            XCTAssertTrue(error is LineItemValidationError)
            if case LineItemValidationError.invalidDescription(let message) = error {
                XCTAssertTrue(message.contains("empty"), "Error should indicate empty description issue")
            }
        }
    }
    
    func testLineItemCreationWithWhitespaceDescription() {
        // Given: Transaction and whitespace-only description
        let transaction = Transaction.create(
            in: context,
            amount: 50.00,
            category: "Test"
        )
        
        // When/Then: Should throw validation error for whitespace-only description
        XCTAssertThrowsError(
            try LineItem.createWithValidation(
                in: context,
                itemDescription: "   \t\n   ",
                amount: 50.00,
                transaction: transaction
            )
        ) { error in
            XCTAssertTrue(error is LineItemValidationError)
        }
    }
    
    func testLineItemCreationWithTooLongDescription() {
        // Given: Transaction and excessively long description
        let transaction = Transaction.create(
            in: context,
            amount: 100.00,
            category: "Test"
        )
        
        let tooLongDescription = String(repeating: "A", count: 501) // Over 500 character limit
        
        // When/Then: Should throw validation error for excessive length
        XCTAssertThrowsError(
            try LineItem.createWithValidation(
                in: context,
                itemDescription: tooLongDescription,
                amount: 100.00,
                transaction: transaction
            )
        ) { error in
            XCTAssertTrue(error is LineItemValidationError)
            if case LineItemValidationError.invalidDescription(let message) = error {
                XCTAssertTrue(message.contains("500 characters"), "Error should indicate character limit")
            }
        }
    }
    
    func testLineItemCreationWithInvalidAmount() {
        // Given: Valid transaction but invalid amounts
        let transaction = Transaction.create(
            in: context,
            amount: 100.00,
            category: "Test"
        )
        
        let invalidAmounts = [Double.nan, Double.infinity, -Double.infinity]
        
        for invalidAmount in invalidAmounts {
            // When/Then: Should throw validation error for invalid amounts
            XCTAssertThrowsError(
                try LineItem.createWithValidation(
                    in: context,
                    itemDescription: "Test Item",
                    amount: invalidAmount,
                    transaction: transaction
                )
            ) { error in
                XCTAssertTrue(error is LineItemValidationError)
                if case LineItemValidationError.invalidAmount(let message) = error {
                    XCTAssertTrue(message.contains("finite"), "Error should indicate finite number requirement")
                }
            }
        }
    }
    
    func testLineItemCreationWithExcessiveAmount() {
        // Given: Transaction and amount exceeding maximum
        let transaction = Transaction.create(
            in: context,
            amount: 100.00,
            category: "Test"
        )
        
        let excessiveAmount = 1_000_000_000.00 // Over maximum allowed
        
        // When/Then: Should throw validation error for excessive amount
        XCTAssertThrowsError(
            try LineItem.createWithValidation(
                in: context,
                itemDescription: "Excessive Amount Item",
                amount: excessiveAmount,
                transaction: transaction
            )
        ) { error in
            XCTAssertTrue(error is LineItemValidationError)
            if case LineItemValidationError.invalidAmount(let message) = error {
                XCTAssertTrue(message.contains("maximum"), "Error should indicate maximum value exceeded")
            }
        }
    }
    
    // MARK: - Australian Financial Context Tests (I-Q-I Quality: Localized Business Logic)
    
    func testLineItemAustralianBusinessExpense() {
        // Given: Authentic Australian business expense transaction
        let businessTransaction = Transaction.create(
            in: context,
            amount: 3499.00,
            category: "Office Equipment",
            note: "New office setup - Harvey Norman"
        )
        
        // When: Creating line items for Australian business equipment
        let deskItem = LineItem.create(
            in: context,
            itemDescription: "Sit-stand desk (Jarvis frame + bamboo top)",
            amount: 899.00,
            transaction: businessTransaction
        )
        
        let chairItem = LineItem.create(
            in: context,
            itemDescription: "Herman Miller Aeron chair - Size B",
            amount: 1299.00,
            transaction: businessTransaction
        )
        
        let monitorItem = LineItem.create(
            in: context,
            itemDescription: "Dell UltraSharp 32\" 4K monitor",
            amount: 649.00,
            transaction: businessTransaction
        )
        
        let accessoriesItem = LineItem.create(
            in: context,
            itemDescription: "Monitor arm + cable management accessories",
            amount: 299.00,
            transaction: businessTransaction
        )
        
        let gstItem = LineItem.create(
            in: context,
            itemDescription: "GST (10%)",
            amount: 314.60,
            transaction: businessTransaction
        )
        
        // Then: Should handle Australian business context correctly
        let lineItems = [deskItem, chairItem, monitorItem, accessoriesItem, gstItem]
        let totalLineItems = lineItems.reduce(0.0) { $0 + $1.amount }
        
        XCTAssertEqual(totalLineItems, 3460.60, accuracy: 0.01, "Line items should sum to subtotal + GST")
        XCTAssertEqual(businessTransaction.lineItems.count, 5)
        
        // Verify Australian business context
        XCTAssertTrue(deskItem.itemDescription.contains("Jarvis"), "Should preserve Australian furniture brand names")
        XCTAssertTrue(chairItem.itemDescription.contains("Herman Miller"), "Should preserve international brand names")
        XCTAssertTrue(gstItem.itemDescription.contains("GST"), "Should include Australian tax context")
    }
    
    func testLineItemAustralianGroceryShopping() {
        // Given: Typical Australian grocery shopping transaction
        let groceryTransaction = Transaction.create(
            in: context,
            amount: 247.85,
            category: "Groceries",
            note: "Weekly shop - Coles Supermarket"
        )
        
        // When: Creating realistic Australian grocery line items
        let produce = LineItem.create(
            in: context,
            itemDescription: "Fresh produce - Aussie bananas, avocados, spinach",
            amount: 34.60,
            transaction: groceryTransaction
        )
        
        let meat = LineItem.create(
            in: context,
            itemDescription: "Australian grass-fed beef + organic chicken",
            amount: 89.40,
            transaction: groceryTransaction
        )
        
        let dairy = LineItem.create(
            in: context,
            itemDescription: "A2 milk, Bega cheese, Chobani yogurt",
            amount: 28.90,
            transaction: groceryTransaction
        )
        
        let pantry = LineItem.create(
            in: context,
            itemDescription: "Arnott's biscuits, Vegemite, pasta",
            amount: 24.70,
            transaction: groceryTransaction
        )
        
        let household = LineItem.create(
            in: context,
            itemDescription: "Finish dishwasher tablets, toilet paper",
            amount: 45.80,
            transaction: groceryTransaction
        )
        
        let beverages = LineItem.create(
            in: context,
            itemDescription: "T2 tea, Vittoria coffee beans",
            amount: 24.45,
            transaction: groceryTransaction
        )
        
        // Then: Should represent authentic Australian grocery shopping
        let groceryItems = [produce, meat, dairy, pantry, household, beverages]
        
        for item in groceryItems {
            XCTAssertTrue(item.amount > 0, "All grocery items should have positive amounts")
            XCTAssertFalse(item.itemDescription.isEmpty, "All items should have descriptions")
        }
        
        let totalGroceries = groceryItems.reduce(0.0) { $0 + $1.amount }
        XCTAssertEqual(totalGroceries, 247.85, accuracy: 0.01)
        
        // Verify Australian grocery brands and products
        XCTAssertTrue(meat.itemDescription.contains("Australian"), "Should emphasize Australian produce")
        XCTAssertTrue(dairy.itemDescription.contains("A2 milk"), "Should include Australian dairy brands")
        XCTAssertTrue(pantry.itemDescription.contains("Vegemite"), "Should include iconic Australian products")
    }
    
    func testLineItemAustralianRestaurantBill() {
        // Given: Australian restaurant dining experience
        let restaurantTransaction = Transaction.create(
            in: context,
            amount: 156.80,
            category: "Dining & Entertainment",
            note: "Dinner - Bennelong Restaurant, Sydney Opera House"
        )
        
        // When: Breaking down fine dining bill
        let entrees = LineItem.create(
            in: context,
            itemDescription: "2x Sydney rock oysters (6 each)",
            amount: 42.00,
            transaction: restaurantTransaction
        )
        
        let mains = LineItem.create(
            in: context,
            itemDescription: "Barramundi + Wagyu beef eye fillet",
            amount: 89.00,
            transaction: restaurantTransaction
        )
        
        let drinks = LineItem.create(
            in: context,
            itemDescription: "Hunter Valley Semillon + craft beer",
            amount: 25.80,
            transaction: restaurantTransaction
        )
        
        // Then: Should reflect authentic Australian fine dining
        let diningItems = [entrees, mains, drinks]
        let totalDining = diningItems.reduce(0.0) { $0 + $1.amount }
        
        XCTAssertEqual(totalDining, 156.80, accuracy: 0.01)
        
        // Verify Australian dining context
        XCTAssertTrue(entrees.itemDescription.contains("Sydney rock oysters"), "Should feature Australian seafood")
        XCTAssertTrue(mains.itemDescription.contains("Barramundi"), "Should feature Australian fish")
        XCTAssertTrue(mains.itemDescription.contains("Wagyu"), "Should feature premium Australian beef")
        XCTAssertTrue(drinks.itemDescription.contains("Hunter Valley"), "Should feature Australian wine regions")
    }
    
    // MARK: - Business Logic Tests (I-Q-I Quality: Professional Financial Logic)
    
    func testCalculatePercentageOfTransaction() {
        // Given: Transaction with multiple line items
        let transaction = Transaction.create(
            in: context,
            amount: 1000.00,
            category: "Mixed Expenses"
        )
        
        let item1 = LineItem.create(
            in: context,
            itemDescription: "Major item",
            amount: 600.00,
            transaction: transaction
        )
        
        let item2 = LineItem.create(
            in: context,
            itemDescription: "Minor item",
            amount: 250.00,
            transaction: transaction
        )
        
        // When: Calculating percentages
        let percentage1 = item1.calculatePercentageOfTransaction()
        let percentage2 = item2.calculatePercentageOfTransaction()
        
        // Then: Should calculate correct percentages
        XCTAssertEqual(percentage1, 0.60, accuracy: 0.001, "Major item should be 60%")
        XCTAssertEqual(percentage2, 0.25, accuracy: 0.001, "Minor item should be 25%")
    }
    
    func testCalculatePercentageWithZeroTransaction() {
        // Given: Transaction with zero amount (edge case)
        let transaction = Transaction.create(
            in: context,
            amount: 0.00,
            category: "Zero Transaction"
        )
        
        let lineItem = LineItem.create(
            in: context,
            itemDescription: "Item in zero transaction",
            amount: 100.00,
            transaction: transaction
        )
        
        // When: Calculating percentage
        let percentage = lineItem.calculatePercentageOfTransaction()
        
        // Then: Should handle zero transaction gracefully
        XCTAssertEqual(percentage, 0.0, "Should return 0% for zero transaction amount")
    }
    
    func testSplitAllocationManagement() {
        // Given: LineItem for split allocation testing
        let transaction = Transaction.create(
            in: context,
            amount: 500.00,
            category: "Mixed Business Expense"
        )
        
        let lineItem = LineItem.create(
            in: context,
            itemDescription: "Business lunch with client",
            amount: 280.00,
            transaction: transaction
        )
        
        // When: Initially checking split allocations
        XCTAssertFalse(lineItem.hasSplitAllocations(), "New line item should have no split allocations")
        XCTAssertEqual(lineItem.getSplitAllocations().count, 0, "Should return empty array")
        XCTAssertTrue(lineItem.validateSplitAllocations(), "Empty split allocations should be valid")
        
        // Note: Split allocation creation will be tested in TransactionSplitAllocations module
    }
    
    // MARK: - Australian Tax Context Tests (I-Q-I Quality: Localized Compliance)
    
    func testFormattedAmountAUD() {
        // Given: LineItems with various amounts
        let transaction = Transaction.create(
            in: context,
            amount: 1000.00,
            category: "Currency Testing"
        )
        
        let item1 = LineItem.create(
            in: context,
            itemDescription: "Standard amount",
            amount: 123.45,
            transaction: transaction
        )
        
        let item2 = LineItem.create(
            in: context,
            itemDescription: "Large amount",
            amount: 12345.67,
            transaction: transaction
        )
        
        let item3 = LineItem.create(
            in: context,
            itemDescription: "Small amount",
            amount: 5.99,
            transaction: transaction
        )
        
        // When: Formatting amounts for Australian display
        let formatted1 = item1.formattedAmountAUD()
        let formatted2 = item2.formattedAmountAUD()
        let formatted3 = item3.formattedAmountAUD()
        
        // Then: Should format correctly for Australian currency
        XCTAssertTrue(formatted1.contains("123.45"), "Should contain the correct amount")
        XCTAssertTrue(formatted1.contains("$"), "Should contain currency symbol")
        
        XCTAssertTrue(formatted2.contains("12,345.67"), "Should include comma separators for large amounts")
        XCTAssertTrue(formatted3.contains("5.99"), "Should handle small amounts correctly")
    }
    
    func testGSTApplicability() {
        // Given: Transaction for GST testing
        let transaction = Transaction.create(
            in: context,
            amount: 500.00,
            category: "Tax Testing"
        )
        
        // Regular business items (GST applicable)
        let businessItem = LineItem.create(
            in: context,
            itemDescription: "Office supplies and stationery",
            amount: 89.50,
            transaction: transaction
        )
        
        let technologyItem = LineItem.create(
            in: context,
            itemDescription: "Computer software license",
            amount: 299.00,
            transaction: transaction
        )
        
        // GST-exempt items
        let medicalItem = LineItem.create(
            in: context,
            itemDescription: "Medical consultation and treatment",
            amount: 180.00,
            transaction: transaction
        )
        
        let educationItem = LineItem.create(
            in: context,
            itemDescription: "University course fees",
            amount: 1200.00,
            transaction: transaction
        )
        
        let basicFoodItem = LineItem.create(
            in: context,
            itemDescription: "Milk and bread - basic food items",
            amount: 8.50,
            transaction: transaction
        )
        
        // When: Checking GST applicability
        // Then: Should correctly identify GST status based on Australian tax rules
        XCTAssertTrue(businessItem.isGSTApplicable(), "Business supplies should be subject to GST")
        XCTAssertTrue(technologyItem.isGSTApplicable(), "Software should be subject to GST")
        
        XCTAssertFalse(medicalItem.isGSTApplicable(), "Medical services should be GST-exempt")
        XCTAssertFalse(educationItem.isGSTApplicable(), "Education should be GST-exempt")
        XCTAssertFalse(basicFoodItem.isGSTApplicable(), "Basic food items should be GST-exempt")
    }
    
    // MARK: - Query Methods Tests (I-Q-I Quality: Optimized Data Access)
    
    func testFetchLineItemsForTransaction() throws {
        // Given: Transaction with multiple line items
        let transaction = Transaction.create(
            in: context,
            amount: 500.00,
            category: "Multi-item Transaction"
        )
        
        let item1 = LineItem.create(
            in: context,
            itemDescription: "Apple MacBook Pro",
            amount: 300.00,
            transaction: transaction
        )
        
        let item2 = LineItem.create(
            in: context,
            itemDescription: "Dell Monitor",
            amount: 200.00,
            transaction: transaction
        )
        
        // Create line item for different transaction (should not be included)
        let otherTransaction = Transaction.create(
            in: context,
            amount: 100.00,
            category: "Other Transaction"
        )
        
        let otherItem = LineItem.create(
            in: context,
            itemDescription: "Other Item",
            amount: 100.00,
            transaction: otherTransaction
        )
        
        try context.save()
        
        // When: Fetching line items for specific transaction
        let fetchedItems = try LineItem.fetchLineItems(for: transaction, in: context)
        
        // Then: Should return only line items for the specified transaction
        XCTAssertEqual(fetchedItems.count, 2)
        
        let fetchedIds = Set(fetchedItems.map { $0.id })
        XCTAssertTrue(fetchedIds.contains(item1.id))
        XCTAssertTrue(fetchedIds.contains(item2.id))
        XCTAssertFalse(fetchedIds.contains(otherItem.id))
        
        // Verify sorting (alphabetical by description)
        XCTAssertLessThanOrEqual(fetchedItems[0].itemDescription, fetchedItems[1].itemDescription)
    }
    
    func testFetchLineItemsWithAmountAboveThreshold() throws {
        // Given: Line items with various amounts
        let transaction = Transaction.create(
            in: context,
            amount: 1000.00,
            category: "Amount Testing"
        )
        
        let smallItem = LineItem.create(
            in: context,
            itemDescription: "Small item",
            amount: 25.00,
            transaction: transaction
        )
        
        let mediumItem = LineItem.create(
            in: context,
            itemDescription: "Medium item",
            amount: 150.00,
            transaction: transaction
        )
        
        let largeItem = LineItem.create(
            in: context,
            itemDescription: "Large item",
            amount: 500.00,
            transaction: transaction
        )
        
        try context.save()
        
        // When: Fetching items above threshold
        let itemsAbove100 = try LineItem.fetchLineItems(withAmountAbove: 100.0, in: context)
        
        // Then: Should return only items above the threshold
        XCTAssertEqual(itemsAbove100.count, 2)
        
        let fetchedIds = Set(itemsAbove100.map { $0.id })
        XCTAssertTrue(fetchedIds.contains(mediumItem.id))
        XCTAssertTrue(fetchedIds.contains(largeItem.id))
        XCTAssertFalse(fetchedIds.contains(smallItem.id))
        
        // Verify sorting (highest amount first)
        XCTAssertGreaterThanOrEqual(itemsAbove100[0].amount, itemsAbove100[1].amount)
    }
    
    func testFetchLineItemsWithDescriptionSearch() throws {
        // Given: Line items with various descriptions
        let transaction = Transaction.create(
            in: context,
            amount: 1000.00,
            category: "Search Testing"
        )
        
        let appleItem = LineItem.create(
            in: context,
            itemDescription: "Apple MacBook Pro M3",
            amount: 300.00,
            transaction: transaction
        )
        
        let appleAccessory = LineItem.create(
            in: context,
            itemDescription: "Apple Magic Mouse",
            amount: 99.00,
            transaction: transaction
        )
        
        let dellItem = LineItem.create(
            in: context,
            itemDescription: "Dell UltraSharp Monitor",
            amount: 400.00,
            transaction: transaction
        )
        
        try context.save()
        
        // When: Searching for items containing "Apple"
        let appleItems = try LineItem.fetchLineItems(withDescriptionContaining: "Apple", in: context)
        
        // Then: Should return only Apple items
        XCTAssertEqual(appleItems.count, 2)
        
        let appleIds = Set(appleItems.map { $0.id })
        XCTAssertTrue(appleIds.contains(appleItem.id))
        XCTAssertTrue(appleIds.contains(appleAccessory.id))
        XCTAssertFalse(appleIds.contains(dellItem.id))
        
        // Test case-insensitive search
        let lowercaseSearch = try LineItem.fetchLineItems(withDescriptionContaining: "apple", in: context)
        XCTAssertEqual(lowercaseSearch.count, 2, "Search should be case-insensitive")
    }
    
    // MARK: - Collection Extension Tests (I-Q-I Quality: Professional Utility Methods)
    
    func testCollectionTotalAmount() {
        // Given: Collection of line items
        let transaction = Transaction.create(
            in: context,
            amount: 1000.00,
            category: "Collection Testing"
        )
        
        let items = [
            LineItem.create(in: context, itemDescription: "Item 1", amount: 150.00, transaction: transaction),
            LineItem.create(in: context, itemDescription: "Item 2", amount: 250.50, transaction: transaction),
            LineItem.create(in: context, itemDescription: "Item 3", amount: 99.95, transaction: transaction)
        ]
        
        // When: Calculating total amount
        let total = items.totalAmount()
        
        // Then: Should sum all amounts correctly
        XCTAssertEqual(total, 500.45, accuracy: 0.01)
    }
    
    func testCollectionGroupedByAmountRanges() {
        // Given: Line items with various amounts
        let transaction = Transaction.create(
            in: context,
            amount: 2000.00,
            category: "Range Testing"
        )
        
        let items = [
            LineItem.create(in: context, itemDescription: "Under 50", amount: 25.00, transaction: transaction),
            LineItem.create(in: context, itemDescription: "50-200 range", amount: 150.00, transaction: transaction),
            LineItem.create(in: context, itemDescription: "200-1000 range", amount: 500.00, transaction: transaction),
            LineItem.create(in: context, itemDescription: "Over 1000", amount: 1500.00, transaction: transaction)
        ]
        
        // When: Grouping by amount ranges
        let groups = items.groupedByAmountRanges()
        
        // Then: Should group correctly by Australian dollar ranges
        XCTAssertEqual(groups["Under A$50"]?.count, 1)
        XCTAssertEqual(groups["A$50 - A$200"]?.count, 1)
        XCTAssertEqual(groups["A$200 - A$1,000"]?.count, 1)
        XCTAssertEqual(groups["Over A$1,000"]?.count, 1)
        
        XCTAssertEqual(groups["Under A$50"]?.first?.amount, 25.00)
        XCTAssertEqual(groups["Over A$1,000"]?.first?.amount, 1500.00)
    }
    
    func testCollectionCandidatesForSplitAllocations() {
        // Given: Line items with various characteristics
        let transaction = Transaction.create(
            in: context,
            amount: 1000.00,
            category: "Split Testing"
        )
        
        let businessItem = LineItem.create(
            in: context,
            itemDescription: "Business lunch meeting",
            amount: 150.00,
            transaction: transaction
        )
        
        let officeItem = LineItem.create(
            in: context,
            itemDescription: "Office supplies purchase",
            amount: 250.00,
            transaction: transaction
        )
        
        let personalItem = LineItem.create(
            in: context,
            itemDescription: "Personal grocery shopping",
            amount: 80.00,
            transaction: transaction
        )
        
        let smallBusinessItem = LineItem.create(
            in: context,
            itemDescription: "Business card printing",
            amount: 50.00,
            transaction: transaction
        )
        
        let items = [businessItem, officeItem, personalItem, smallBusinessItem]
        
        // When: Finding candidates for split allocations
        let candidates = items.candidatesForSplitAllocations()
        
        // Then: Should identify business-related items above threshold
        XCTAssertEqual(candidates.count, 2)
        
        let candidateIds = Set(candidates.map { $0.id })
        XCTAssertTrue(candidateIds.contains(businessItem.id), "Business lunch should be split candidate")
        XCTAssertTrue(candidateIds.contains(officeItem.id), "Office supplies should be split candidate")
        XCTAssertFalse(candidateIds.contains(personalItem.id), "Personal items shouldn't be candidates")
        XCTAssertFalse(candidateIds.contains(smallBusinessItem.id), "Small amounts shouldn't be candidates")
    }
    
    // MARK: - Performance Tests (I-Q-I Quality: Scalability Validation)
    
    func testLineItemCreationPerformance() {
        // Given: Large number of line items to create
        let transaction = Transaction.create(
            in: context,
            amount: 10000.00,
            category: "Performance Test"
        )
        
        let itemCount = 500
        
        // When: Creating many line items
        measure {
            for i in 0..<itemCount {
                _ = LineItem.create(
                    in: context,
                    itemDescription: "Performance test item #\(i)",
                    amount: Double(i) * 2.0,
                    transaction: transaction
                )
            }
        }
        
        // Then: Should handle large-scale creation efficiently
        XCTAssertEqual(transaction.lineItems.count, itemCount)
    }
    
    func testLineItemQueryPerformance() throws {
        // Given: Large number of line items
        let transaction = Transaction.create(
            in: context,
            amount: 10000.00,
            category: "Query Performance"
        )
        
        let itemCount = 200
        for i in 0..<itemCount {
            _ = LineItem.create(
                in: context,
                itemDescription: "Query test item #\(i)",
                amount: Double(i) * 5.0,
                transaction: transaction
            )
        }
        
        try context.save()
        
        // When: Performing various queries
        measure {
            do {
                _ = try LineItem.fetchLineItems(for: transaction, in: context)
                _ = try LineItem.fetchLineItems(withAmountAbove: 100.0, in: context)
                _ = try LineItem.fetchLineItems(withDescriptionContaining: "test", in: context)
            } catch {
                XCTFail("Query failed: \(error)")
            }
        }
    }
    
    // MARK: - Edge Cases and Boundary Tests (I-Q-I Quality: Robustness)
    
    func testLineItemWithZeroAmount() {
        // Given: Transaction and zero amount (free item scenario)
        let transaction = Transaction.create(
            in: context,
            amount: 100.00,
            category: "Promotional"
        )
        
        // When: Creating line item with zero amount
        let freeItem = LineItem.create(
            in: context,
            itemDescription: "Complimentary business card holder",
            amount: 0.00,
            transaction: transaction
        )
        
        // Then: Should handle zero amounts correctly
        XCTAssertEqual(freeItem.amount, 0.00, accuracy: 0.01)
        XCTAssertEqual(freeItem.itemDescription, "Complimentary business card holder")
        XCTAssert(freeItem.isGSTApplicable() == false, "Zero amount items should not be subject to GST")
    }
    
    func testLineItemWithNegativeAmount() {
        // Given: Transaction and negative amount (discount scenario)
        let transaction = Transaction.create(
            in: context,
            amount: 100.00,
            category: "Discounted Purchase"
        )
        
        // When: Creating line item with negative amount
        let discountItem = LineItem.create(
            in: context,
            itemDescription: "Early bird discount (15%)",
            amount: -15.00,
            transaction: transaction
        )
        
        // Then: Should handle negative amounts correctly
        XCTAssertEqual(discountItem.amount, -15.00, accuracy: 0.01)
        XCTAssertEqual(discountItem.calculatePercentageOfTransaction(), 0.15, accuracy: 0.01)
    }
    
    func testLineItemWithUnicodeDescription() {
        // Given: Transaction with Unicode characters
        let transaction = Transaction.create(
            in: context,
            amount: 100.00,
            category: "International"
        )
        
        // When: Creating line item with Unicode description
        let unicodeItem = LineItem.create(
            in: context,
            itemDescription: "Café au lait ☕️ + croissant 🥐",
            amount: 18.50,
            transaction: transaction
        )
        
        // Then: Should preserve Unicode characters correctly
        XCTAssertEqual(unicodeItem.itemDescription, "Café au lait ☕️ + croissant 🥐")
        XCTAssertTrue(unicodeItem.itemDescription.contains("☕️"))
        XCTAssertTrue(unicodeItem.itemDescription.contains("🥐"))
    }
}