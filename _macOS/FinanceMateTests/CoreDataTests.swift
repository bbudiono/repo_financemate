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
        // This test will fail until the LineItem and SplitAllocation models are implemented
        // 1. Create a Transaction
        let tx = Transaction.create(in: context, amount: 100.0, category: "Test", note: "LineItemTest")
        // 2. Create two LineItems (e.g., "Laptop", "Mouse")
        // 3. For each LineItem, create SplitAllocations (e.g., 70% Business, 30% Personal)
        // 4. Save context
        // 5. Fetch Transaction and verify:
        //    - It has 2 LineItems
        //    - Each LineItem has correct SplitAllocations
        //    - Each LineItem's splits sum to 100%
        XCTFail("LineItem and SplitAllocation model not yet implemented")
    }
} 