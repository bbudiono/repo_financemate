import XCTest
import CoreData
@testable import FinanceMate

final class TransactionQueryHelperTests: XCTestCase {

    var testContext: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        testContext = PersistenceController.preview.container.viewContext
        clearTestData()
    }

    override func tearDown() {
        clearTestData()
        testContext = nil
        super.tearDown()
    }

    private func clearTestData() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Transaction")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        try? testContext.execute(deleteRequest)
        try? testContext.save()
    }

    private func createTestTransaction(amount: Double, category: String = "Groceries", description: String = "Test Item") -> Transaction {
        let transaction = Transaction(context: testContext)
        transaction.amount = amount
        transaction.category = category
        transaction.itemDescription = description
        transaction.date = Date()
        transaction.source = "manual"
        transaction.taxCategory = "Personal"
        try? testContext.save()
        return transaction
    }

    // MARK: - Balance Tests

    func testGetTotalBalance_EmptyDatabase_ReturnsZero() {
        let balance = TransactionQueryHelper.getTotalBalance(context: testContext)
        XCTAssertEqual(balance, 0.0, "Empty database should return $0 balance")
    }

    func testGetTotalBalance_WithTransactions_ReturnsCorrectSum() {
        createTestTransaction(amount: 100.0)
        createTestTransaction(amount: -50.0)
        createTestTransaction(amount: 25.0)

        let balance = TransactionQueryHelper.getTotalBalance(context: testContext)
        XCTAssertEqual(balance, 75.0, "Balance should sum all transactions: 100 - 50 + 25 = 75")
    }

    // MARK: - Count Tests

    func testGetTransactionCount_EmptyDatabase_ReturnsZero() {
        let count = TransactionQueryHelper.getTransactionCount(context: testContext)
        XCTAssertEqual(count, 0, "Empty database should return 0 count")
    }

    func testGetTransactionCount_WithTransactions_ReturnsCorrectCount() {
        createTestTransaction(amount: 10)
        createTestTransaction(amount: 20)
        createTestTransaction(amount: 30)

        let count = TransactionQueryHelper.getTransactionCount(context: testContext)
        XCTAssertEqual(count, 3, "Should count all transactions")
    }

    // MARK: - Recent Transactions Tests

    func testGetRecentTransactions_ReturnsNewestFirst() {
        let old = createTestTransaction(amount: 10, description: "Old")
        old.date = Calendar.current.date(byAdding: .day, value: -5, to: Date())!

        let recent = createTestTransaction(amount: 20, description: "Recent")
        recent.date = Date()

        try? testContext.save()

        let results = TransactionQueryHelper.getRecentTransactions(context: testContext, limit: 5)

        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results.first?.itemDescription, "Recent", "Newest transaction should be first")
        XCTAssertEqual(results.last?.itemDescription, "Old", "Oldest should be last")
    }

    func testGetRecentTransactions_RespectsLimit() {
        for i in 1...10 {
            createTestTransaction(amount: Double(i))
        }

        let results = TransactionQueryHelper.getRecentTransactions(context: testContext, limit: 3)
        XCTAssertEqual(results.count, 3, "Should return only 3 transactions when limit is 3")
    }

    // MARK: - Category Spending Tests

    func testGetCategorySpending_FiltersCorrectly() {
        createTestTransaction(amount: 50, category: "Groceries")
        createTestTransaction(amount: 30, category: "Groceries")
        createTestTransaction(amount: 20, category: "Dining")

        let groceriesSpending = TransactionQueryHelper.getCategorySpending(context: testContext, category: "Groceries")

        XCTAssertEqual(groceriesSpending, 80.0, "Should sum only Groceries: 50 + 30 = 80")
    }

    func testGetCategorySpending_NonExistentCategory_ReturnsZero() {
        createTestTransaction(amount: 100, category: "Groceries")

        let spending = TransactionQueryHelper.getCategorySpending(context: testContext, category: "Travel")
        XCTAssertEqual(spending, 0.0, "Non-existent category should return $0")
    }

    func testGetCategorySpending_UsesAbsoluteValues() {
        createTestTransaction(amount: -50, category: "Groceries")  // Expense (negative)
        createTestTransaction(amount: 30, category: "Groceries")   // Income (positive)

        let spending = TransactionQueryHelper.getCategorySpending(context: testContext, category: "Groceries")

        XCTAssertEqual(spending, 80.0, "Should use absolute values: |-50| + |30| = 80")
    }
}
