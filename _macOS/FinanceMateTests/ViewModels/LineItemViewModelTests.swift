import XCTest
import CoreData
@testable import FinanceMate

/**
 * LineItemViewModelTests.swift
 * 
 * Purpose: Comprehensive TDD unit tests for LineItemViewModel with CRUD operations and validation
 * Issues & Complexity Summary: Tests line item management, Core Data integration, Australian locale, and split allocation support
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~450
 *   - Core Algorithm Complexity: High (CRUD + validation + relationships)
 *   - Dependencies: 5 (Core Data, XCTest, Combine, Foundation, LineItem/SplitAllocation entities)
 *   - State Management Complexity: High (@Published properties, async operations)
 *   - Novelty/Uncertainty Factor: Medium (new ViewModel for Phase 2 features)
 * AI Pre-Task Self-Assessment: 80%
 * Problem Estimate: 85%
 * Initial Code Complexity Estimate: 80%
 * Final Code Complexity: TBD
 * Overall Result Score: TBD
 * Key Variances/Learnings: TDD for advanced line item splitting with percentage validation
 * Last Updated: 2025-07-07
 */

@MainActor
final class LineItemViewModelTests: XCTestCase {
    var viewModel: LineItemViewModel!
    var persistenceController: PersistenceController!
    var context: NSManagedObjectContext!
    var testTransaction: Transaction!
    
    override func setUp() {
        super.setUp()
        persistenceController = PersistenceController(inMemory: true)
        context = persistenceController.container.viewContext
        viewModel = LineItemViewModel(context: context)
        
        // Create a test transaction for line items
        testTransaction = Transaction.create(in: context, amount: 120.00, category: "Test", note: "Test transaction")
        try! context.save()
    }
    
    override func tearDown() {
        testTransaction = nil
        viewModel = nil
        context = nil
        persistenceController = nil
        super.tearDown()
    }
    
    // MARK: - Helper Methods
    
    private func createTestLineItem(description: String, amount: Double, transaction: Transaction? = nil) -> LineItem {
        let targetTransaction = transaction ?? testTransaction!
        let lineItem = LineItem.create(in: context, itemDescription: description, amount: amount, transaction: targetTransaction)
        try! context.save()
        return lineItem
    }
    
    private func createTestSplitAllocation(percentage: Double, taxCategory: String, lineItem: LineItem) -> SplitAllocation {
        let split = SplitAllocation.create(in: context, percentage: percentage, taxCategory: taxCategory, lineItem: lineItem)
        try! context.save()
        return split
    }
    
    // MARK: - Initialization Tests
    
    func testViewModelInitialization() {
        // Given: A Core Data context
        // When: Creating a LineItemViewModel
        let newViewModel = LineItemViewModel(context: context)
        
        // Then: The view model should be properly initialized
        XCTAssertNotNil(newViewModel, "LineItemViewModel should be properly initialized")
        XCTAssertEqual(newViewModel.lineItems.count, 0, "Initial line items array should be empty")
        XCTAssertFalse(newViewModel.isLoading, "Initial loading state should be false")
        XCTAssertNil(newViewModel.errorMessage, "Initial error message should be nil")
        XCTAssertEqual(newViewModel.newLineItem.itemDescription, "", "New line item description should be empty")
        XCTAssertEqual(newViewModel.newLineItem.amount, 0.0, "New line item amount should be zero")
    }
    
    // MARK: - CRUD Operation Tests
    
    func testAddLineItemSuccess() async {
        // Given: Valid line item data
        viewModel.newLineItem.itemDescription = "Office Chair"
        viewModel.newLineItem.amount = 299.99
        
        // When: Adding a line item
        await viewModel.addLineItem(to: testTransaction)
        
        // Then: Line item should be created successfully
        await viewModel.fetchLineItems(for: testTransaction)
        XCTAssertEqual(viewModel.lineItems.count, 1, "Should have one line item")
        XCTAssertEqual(viewModel.lineItems.first?.itemDescription, "Office Chair", "Description should match")
        XCTAssertEqual(viewModel.lineItems.first?.amount, 299.99, accuracy: 0.01, "Amount should match")
        XCTAssertFalse(viewModel.isLoading, "Loading should be complete")
        XCTAssertNil(viewModel.errorMessage, "Should have no error")
    }
    
    func testAddLineItemValidationFailure() async {
        // Given: Invalid line item data (empty description)
        viewModel.newLineItem.itemDescription = ""
        viewModel.newLineItem.amount = 100.0
        
        // When: Adding a line item
        await viewModel.addLineItem(to: testTransaction)
        
        // Then: Should fail validation
        XCTAssertNotNil(viewModel.errorMessage, "Should have validation error")
        XCTAssertTrue(viewModel.errorMessage?.contains("description") == true, "Error should mention description")
        await viewModel.fetchLineItems(for: testTransaction)
        XCTAssertEqual(viewModel.lineItems.count, 0, "Should have no line items")
    }
    
    func testAddLineItemNegativeAmountValidation() async {
        // Given: Invalid line item data (negative amount)
        viewModel.newLineItem.itemDescription = "Test Item"
        viewModel.newLineItem.amount = -50.0
        
        // When: Adding a line item
        await viewModel.addLineItem(to: testTransaction)
        
        // Then: Should fail validation
        XCTAssertNotNil(viewModel.errorMessage, "Should have validation error")
        XCTAssertTrue(viewModel.errorMessage?.contains("amount") == true, "Error should mention amount")
        await viewModel.fetchLineItems(for: testTransaction)
        XCTAssertEqual(viewModel.lineItems.count, 0, "Should have no line items")
    }
    
    func testUpdateLineItemSuccess() async {
        // Given: An existing line item
        let lineItem = createTestLineItem(description: "Original Description", amount: 100.0)
        await viewModel.fetchLineItems(for: testTransaction)
        
        // When: Updating the line item
        lineItem.itemDescription = "Updated Description"
        lineItem.amount = 150.0
        await viewModel.updateLineItem(lineItem)
        
        // Then: Line item should be updated
        await viewModel.fetchLineItems(for: testTransaction)
        XCTAssertEqual(viewModel.lineItems.first?.itemDescription, "Updated Description", "Description should be updated")
        XCTAssertEqual(viewModel.lineItems.first?.amount, 150.0, accuracy: 0.01, "Amount should be updated")
        XCTAssertNil(viewModel.errorMessage, "Should have no error")
    }
    
    func testDeleteLineItemSuccess() async {
        // Given: An existing line item
        let lineItem = createTestLineItem(description: "To Delete", amount: 75.0)
        await viewModel.fetchLineItems(for: testTransaction)
        XCTAssertEqual(viewModel.lineItems.count, 1, "Should have one line item")
        
        // When: Deleting the line item
        await viewModel.deleteLineItem(lineItem)
        
        // Then: Line item should be deleted
        await viewModel.fetchLineItems(for: testTransaction)
        XCTAssertEqual(viewModel.lineItems.count, 0, "Should have no line items")
        XCTAssertNil(viewModel.errorMessage, "Should have no error")
    }
    
    func testFetchLineItemsForTransaction() async {
        // Given: Multiple line items for different transactions
        let otherTransaction = Transaction.create(in: context, amount: 200.0, category: "Other", note: "Other transaction")
        try! context.save()
        
        _ = createTestLineItem(description: "Item 1", amount: 50.0, transaction: testTransaction)
        _ = createTestLineItem(description: "Item 2", amount: 70.0, transaction: testTransaction)
        _ = createTestLineItem(description: "Other Item", amount: 30.0, transaction: otherTransaction)
        
        // When: Fetching line items for test transaction
        await viewModel.fetchLineItems(for: testTransaction)
        
        // Then: Should only get line items for test transaction
        XCTAssertEqual(viewModel.lineItems.count, 2, "Should have two line items for test transaction")
        XCTAssertTrue(viewModel.lineItems.allSatisfy { $0.transaction == testTransaction }, "All line items should belong to test transaction")
    }
    
    // MARK: - Validation Tests
    
    func testDescriptionValidationEmptyString() {
        // Given: Empty description
        let isValid = viewModel.validateDescription("")
        
        // Then: Should be invalid
        XCTAssertFalse(isValid, "Empty description should be invalid")
    }
    
    func testDescriptionValidationWhitespaceOnly() {
        // Given: Whitespace-only description
        let isValid = viewModel.validateDescription("   ")
        
        // Then: Should be invalid
        XCTAssertFalse(isValid, "Whitespace-only description should be invalid")
    }
    
    func testDescriptionValidationMaxLength() {
        // Given: Description at max length (200 characters)
        let maxDescription = String(repeating: "a", count: 200)
        let isValid = viewModel.validateDescription(maxDescription)
        
        // Then: Should be valid
        XCTAssertTrue(isValid, "200-character description should be valid")
    }
    
    func testDescriptionValidationExceedsMaxLength() {
        // Given: Description exceeding max length (201 characters)
        let longDescription = String(repeating: "a", count: 201)
        let isValid = viewModel.validateDescription(longDescription)
        
        // Then: Should be invalid
        XCTAssertFalse(isValid, "201-character description should be invalid")
    }
    
    func testAmountValidationPositive() {
        // Given: Positive amount
        let isValid = viewModel.validateAmount(100.50)
        
        // Then: Should be valid
        XCTAssertTrue(isValid, "Positive amount should be valid")
    }
    
    func testAmountValidationZero() {
        // Given: Zero amount
        let isValid = viewModel.validateAmount(0.0)
        
        // Then: Should be invalid
        XCTAssertFalse(isValid, "Zero amount should be invalid")
    }
    
    func testAmountValidationNegative() {
        // Given: Negative amount
        let isValid = viewModel.validateAmount(-50.0)
        
        // Then: Should be invalid
        XCTAssertFalse(isValid, "Negative amount should be invalid")
    }
    
    func testAmountValidationTwoDecimalPlaces() {
        // Given: Amount with two decimal places
        let isValid = viewModel.validateAmount(99.99)
        
        // Then: Should be valid
        XCTAssertTrue(isValid, "Amount with two decimal places should be valid")
    }
    
    func testAmountValidationMoreThanTwoDecimalPlaces() {
        // Given: Amount with more than two decimal places
        let isValid = viewModel.validateAmount(99.999)
        
        // Then: Should be invalid (assuming validation checks decimal places)
        XCTAssertFalse(isValid, "Amount with more than two decimal places should be invalid")
    }
    
    // MARK: - Loading State Tests
    
    func testLoadingStatesDuringAdd() async {
        // Given: Valid line item data
        viewModel.newLineItem.itemDescription = "Test Item"
        viewModel.newLineItem.amount = 50.0
        
        // When: Adding line item (check loading state changes)
        let addTask = Task {
            await viewModel.addLineItem(to: testTransaction)
        }
        
        // Then: Loading state should be managed properly
        // Note: In a real scenario, we might need to add delays or use expectations to test loading states
        await addTask.value
        XCTAssertFalse(viewModel.isLoading, "Loading should be false after completion")
    }
    
    // MARK: - Error Handling Tests
    
    func testErrorHandlingInvalidTransaction() async {
        // Given: Invalid transaction (nil context)
        let invalidTransaction = Transaction(context: context)
        // Don't save to make it invalid
        
        viewModel.newLineItem.itemDescription = "Test Item"
        viewModel.newLineItem.amount = 50.0
        
        // When: Adding line item to invalid transaction
        await viewModel.addLineItem(to: invalidTransaction)
        
        // Then: Should handle error gracefully
        XCTAssertNotNil(viewModel.errorMessage, "Should have error message")
        XCTAssertFalse(viewModel.isLoading, "Loading should be false")
    }
    
    // MARK: - Australian Locale Compliance Tests
    
    func testAustralianCurrencyFormatting() {
        // Given: Australian locale
        let formatter = viewModel.currencyFormatter
        
        // When: Formatting currency
        let formattedAmount = formatter.string(from: NSNumber(value: 1234.56))
        
        // Then: Should use Australian currency format
        XCTAssertTrue(formattedAmount?.contains("$") == true, "Should include dollar sign")
        XCTAssertTrue(formattedAmount?.contains("1,234.56") == true || formattedAmount?.contains("1234.56") == true, 
                     "Should format amount correctly for Australian locale")
    }
    
    // MARK: - Split Allocation Integration Tests
    
    func testLineItemWithSplitAllocations() async {
        // Given: A line item with split allocations
        let lineItem = createTestLineItem(description: "Mixed Item", amount: 100.0)
        _ = createTestSplitAllocation(percentage: 60.0, taxCategory: "Business", lineItem: lineItem)
        _ = createTestSplitAllocation(percentage: 40.0, taxCategory: "Personal", lineItem: lineItem)
        
        // When: Fetching line items
        await viewModel.fetchLineItems(for: testTransaction)
        
        // Then: Line item should have split allocations
        XCTAssertEqual(viewModel.lineItems.count, 1, "Should have one line item")
        let fetchedLineItem = viewModel.lineItems.first!
        XCTAssertEqual(fetchedLineItem.splitAllocations.count, 2, "Should have two split allocations")
        
        let totalPercentage = fetchedLineItem.splitAllocations.reduce(0.0) { $0 + $1.percentage }
        XCTAssertEqual(totalPercentage, 100.0, accuracy: 0.01, "Split allocations should total 100%")
    }
    
    // MARK: - Performance Tests
    
    func testFetchPerformanceWithLargeDataset() async {
        // Given: Large number of line items
        for i in 0..<100 {
            _ = createTestLineItem(description: "Item \(i)", amount: Double(i) * 10.0)
        }
        
        // When: Fetching line items (measure time)
        let startTime = CFAbsoluteTimeGetCurrent()
        await viewModel.fetchLineItems(for: testTransaction)
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        // Then: Should complete within reasonable time
        XCTAssertEqual(viewModel.lineItems.count, 100, "Should fetch all line items")
        XCTAssertLessThan(timeElapsed, 1.0, "Fetch should complete within 1 second")
    }
    
    // MARK: - Data Integrity Tests
    
    func testLineItemTransactionRelationship() {
        // Given: A line item
        let lineItem = createTestLineItem(description: "Test Item", amount: 50.0)
        
        // When: Checking relationship
        // Then: Line item should be properly linked to transaction
        XCTAssertEqual(lineItem.transaction, testTransaction, "Line item should be linked to transaction")
        XCTAssertTrue(testTransaction.lineItems.contains(lineItem), "Transaction should contain the line item")
    }
    
    func testCascadeDeleteLineItemWithSplits() {
        // Given: A line item with split allocations
        let lineItem = createTestLineItem(description: "Item with Splits", amount: 100.0)
        let split1 = createTestSplitAllocation(percentage: 50.0, taxCategory: "Business", lineItem: lineItem)
        let split2 = createTestSplitAllocation(percentage: 50.0, taxCategory: "Personal", lineItem: lineItem)
        
        let split1ID = split1.id
        let split2ID = split2.id
        
        // When: Deleting the line item
        context.delete(lineItem)
        try! context.save()
        
        // Then: Split allocations should be cascade deleted
        let fetchRequest: NSFetchRequest<SplitAllocation> = SplitAllocation.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id IN %@", [split1ID, split2ID])
        let remainingSplits = try! context.fetch(fetchRequest)
        
        XCTAssertEqual(remainingSplits.count, 0, "Split allocations should be cascade deleted")
    }
}