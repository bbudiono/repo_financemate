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
} 