import XCTest
import CoreData
@testable import FinanceMate

final class CoreDataTests: XCTestCase {
    var persistenceController: PersistenceController!
    var context: NSManagedObjectContext!

    override func setUpWithError() throws {
        persistenceController = PersistenceController(inMemory: true)
        context = persistenceController.container.viewContext
    }

    override func tearDownWithError() throws {
        persistenceController = nil
        context = nil
    }

    func testTransactionCreationAndFetch() throws {
        // Create
        let tx = Transaction.create(in: context, amount: 42.0, category: "Test", note: "UnitTest")
        try context.save()

        // Fetch
        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        let results = try context.fetch(request)
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.amount, 42.0)
        XCTAssertEqual(results.first?.category, "Test")
        XCTAssertEqual(results.first?.note, "UnitTest")
    }

    func testTransactionLineItemSplitting() throws {
        // 1. Create a Transaction
        let tx = Transaction.create(in: context, amount: 100.0, category: "Test", note: "LineItemTest")
        
        // 2. Create two LineItems (e.g., "Laptop", "Mouse")
        let laptopItem = LineItem.create(in: context, itemDescription: "Laptop", amount: 80.0, transaction: tx)
        let mouseItem = LineItem.create(in: context, itemDescription: "Mouse", amount: 20.0, transaction: tx)
        
        // 3. For each LineItem, create SplitAllocations (e.g., 70% Business, 30% Personal)
        let laptopBusinessSplit = SplitAllocation.create(in: context, percentage: 70.0, taxCategory: "Business", lineItem: laptopItem)
        let laptopPersonalSplit = SplitAllocation.create(in: context, percentage: 30.0, taxCategory: "Personal", lineItem: laptopItem)
        
        let mouseBusinessSplit = SplitAllocation.create(in: context, percentage: 100.0, taxCategory: "Business", lineItem: mouseItem)
        
        // 4. Save context
        try context.save()
        
        // 5. Fetch Transaction and verify:
        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        let results = try context.fetch(request)
        
        XCTAssertEqual(results.count, 1)
        let fetchedTransaction = results.first!
        
        // - It has 2 LineItems
        XCTAssertEqual(fetchedTransaction.lineItems.count, 2)
        
        // - Each LineItem has correct SplitAllocations
        let lineItems = Array(fetchedTransaction.lineItems)
        let laptopLineItem = lineItems.first { $0.itemDescription == "Laptop" }!
        let mouseLineItem = lineItems.first { $0.itemDescription == "Mouse" }!
        
        XCTAssertEqual(laptopLineItem.splitAllocations.count, 2)
        XCTAssertEqual(mouseLineItem.splitAllocations.count, 1)
        
        // - Each LineItem's splits sum to 100%
        let laptopTotalPercentage = laptopLineItem.splitAllocations.reduce(0.0) { $0 + $1.percentage }
        let mouseTotalPercentage = mouseLineItem.splitAllocations.reduce(0.0) { $0 + $1.percentage }
        
        XCTAssertEqual(laptopTotalPercentage, 100.0, accuracy: 0.01)
        XCTAssertEqual(mouseTotalPercentage, 100.0, accuracy: 0.01)
        
        // Verify specific split allocations
        let laptopSplits = Array(laptopLineItem.splitAllocations)
        let businessSplit = laptopSplits.first { $0.taxCategory == "Business" }!
        let personalSplit = laptopSplits.first { $0.taxCategory == "Personal" }!
        
        XCTAssertEqual(businessSplit.percentage, 70.0, accuracy: 0.01)
        XCTAssertEqual(personalSplit.percentage, 30.0, accuracy: 0.01)
    }
} 