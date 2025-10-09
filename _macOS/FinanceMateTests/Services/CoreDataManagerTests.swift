import XCTest
import CoreData
@testable import FinanceMate

/// Test suite for CoreDataManager
/// Validates Core Data transaction persistence operations
class CoreDataManagerTests: XCTestCase {
    var coreDataManager: CoreDataManager!
    var testContext: NSManagedObjectContext!
    var testPersistentContainer: NSPersistentContainer!

    override func setUpWithError() throws {
        try super.setUpWithError()

        // Create in-memory Core Data stack for testing
        testPersistentContainer = NSPersistentContainer(name: "FinanceMate")

        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        testPersistentContainer.persistentStoreDescriptions = [description]

        testPersistentContainer.loadPersistentStores { _, error in
            XCTAssertNil(error)
        }

        testContext = testPersistentContainer.viewContext
        coreDataManager = CoreDataManager(context: testContext)
    }

    override func tearDownWithError() throws {
        testContext = nil
        coreDataManager = nil
        testPersistentContainer = nil
        try super.tearDownWithError()
    }

    // MARK: - Save Transaction Tests

    func testSaveTransaction_ValidTransaction_SavesSuccessfully() async throws {
        // Given
        let extractedTransaction = ExtractedTransaction(
            merchant: "Test Merchant",
            amount: 25.99,
            date: Date(),
            category: "Food",
            confidence: 0.9
        )

        // When
        let result = try await coreDataManager.saveTransaction(extractedTransaction)

        // Then
        XCTAssertTrue(result)

        // Verify transaction was saved
        let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        let savedTransactions = try testContext.fetch(fetchRequest)
        XCTAssertEqual(savedTransactions.count, 1)
        XCTAssertEqual(savedTransactions.first?.merchantName, "Test Merchant")
        XCTAssertEqual(savedTransactions.first?.amount, 25.99)
    }

    func testSaveTransaction_MultipleTransactions_SavesAll() async throws {
        // Given
        let transactions = [
            ExtractedTransaction(merchant: "Merchant 1", amount: 10.0, date: Date(), category: "Food", confidence: 0.9),
            ExtractedTransaction(merchant: "Merchant 2", amount: 20.0, date: Date(), category: "Transport", confidence: 0.8),
            ExtractedTransaction(merchant: "Merchant 3", amount: 30.0, date: Date(), category: "Entertainment", confidence: 0.95)
        ]

        // When
        let savedCount = try await coreDataManager.saveTransactions(transactions)

        // Then
        XCTAssertEqual(savedCount, 3)

        // Verify all transactions were saved
        let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        let savedTransactions = try testContext.fetch(fetchRequest)
        XCTAssertEqual(savedTransactions.count, 3)

        let merchantNames = savedTransactions.map { $0.merchantName }.sorted()
        XCTAssertEqual(merchantNames, ["Merchant 1", "Merchant 2", "Merchant 3"])
    }

    func testSaveTransaction_EmptyArray_ReturnsZero() async throws {
        // Given
        let emptyTransactions: [ExtractedTransaction] = []

        // When
        let savedCount = try await coreDataManager.saveTransactions(emptyTransactions)

        // Then
        XCTAssertEqual(savedCount, 0)

        // Verify no transactions were saved
        let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        let savedTransactions = try testContext.fetch(fetchRequest)
        XCTAssertEqual(savedTransactions.count, 0)
    }

    // MARK: - Fetch Transaction Tests

    func testGetAllTransactions_EmptyDatabase_ReturnsEmptyArray() async throws {
        // When
        let transactions = try await coreDataManager.getAllTransactions()

        // Then
        XCTAssertEqual(transactions.count, 0)
    }

    func testGetAllTransactions_WithSavedTransactions_ReturnsAllTransactions() async throws {
        // Given
        let transactions = [
            ExtractedTransaction(merchant: "Merchant 1", amount: 10.0, date: Date(), category: "Food", confidence: 0.9),
            ExtractedTransaction(merchant: "Merchant 2", amount: 20.0, date: Date(), category: "Transport", confidence: 0.8)
        ]
        _ = try await coreDataManager.saveTransactions(transactions)

        // When
        let fetchedTransactions = try await coreDataManager.getAllTransactions()

        // Then
        XCTAssertEqual(fetchedTransactions.count, 2)

        let merchantNames = fetchedTransactions.map { $0.merchantName }.sorted()
        XCTAssertEqual(merchantNames, ["Merchant 1", "Merchant 2"])
    }

    func testGetTransactions_DateRange_ReturnsFilteredTransactions() async throws {
        // Given
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: today)!

        let transactions = [
            ExtractedTransaction(merchant: "Today", amount: 10.0, date: today, category: "Food", confidence: 0.9),
            ExtractedTransaction(merchant: "Yesterday", amount: 20.0, date: yesterday, category: "Transport", confidence: 0.8),
            ExtractedTransaction(merchant: "Two Days Ago", amount: 30.0, date: twoDaysAgo, category: "Entertainment", confidence: 0.95)
        ]
        _ = try await coreDataManager.saveTransactions(transactions)

        // When - fetch yesterday and today only
        let fetchedTransactions = try await coreDataManager.getTransactions(from: yesterday, to: today)

        // Then
        XCTAssertEqual(fetchedTransactions.count, 2)

        let merchantNames = fetchedTransactions.map { $0.merchantName }.sorted()
        XCTAssertEqual(merchantNames, ["Today", "Yesterday"])
    }

    func testGetTransactions_DateRangeNoResults_ReturnsEmptyArray() async throws {
        // Given
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        let transaction = ExtractedTransaction(merchant: "Test", amount: 10.0, date: today, category: "Food", confidence: 0.9)
        _ = try await coreDataManager.saveTransaction(transaction)

        // When - fetch future dates
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        let dayAfterTomorrow = Calendar.current.date(byAdding: .day, value: 2, to: today)!
        let fetchedTransactions = try await coreDataManager.getTransactions(from: tomorrow, to: dayAfterTomorrow)

        // Then
        XCTAssertEqual(fetchedTransactions.count, 0)
    }

    // MARK: - Delete Transaction Tests

    func testDeleteTransaction_ValidID_DeletesSuccessfully() async throws {
        // Given
        let transaction = ExtractedTransaction(merchant: "Test", amount: 10.0, date: Date(), category: "Food", confidence: 0.9)
        _ = try await coreDataManager.saveTransaction(transaction)

        let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        let savedTransactions = try testContext.fetch(fetchRequest)
        XCTAssertEqual(savedTransactions.count, 1)

        let transactionID = savedTransactions.first!.objectID

        // When
        let result = try await coreDataManager.deleteTransaction(id: transactionID)

        // Then
        XCTAssertTrue(result)

        // Verify transaction was deleted
        let remainingTransactions = try testContext.fetch(fetchRequest)
        XCTAssertEqual(remainingTransactions.count, 0)
    }

    func testDeleteTransaction_InvalidID_ReturnsFalse() async throws {
        // Given
        let invalidID = NSManagedObjectID()

        // When
        let result = try await coreDataManager.deleteTransaction(id: invalidID)

        // Then
        XCTAssertFalse(result)
    }

    // MARK: - Error Handling Tests

    func testSaveTransaction_ContextSaveError_ThrowsCoreDataError() async throws {
        // Given - corrupt the context to force a save error
        testContext.shouldDeleteInaccessibleFaults = true

        let transaction = ExtractedTransaction(merchant: "Test", amount: 10.0, date: Date(), category: "Food", confidence: 0.9)

        // When & Then
        do {
            _ = try await coreDataManager.saveTransaction(transaction)
            XCTFail("Expected CoreDataError to be thrown")
        } catch {
            XCTAssertTrue(error is CoreDataError)
        }
    }

    // MARK: - Performance Tests

    func testPerformanceSaveTransactions_LargeDataSet() async throws {
        // Given
        let largeDataSet = (0..<100).map { index in
            ExtractedTransaction(
                merchant: "Merchant \(index)",
                amount: Double(index) * 1.5,
                date: Date(),
                category: "Test Category",
                confidence: 0.8
            )
        }

        // When & Then
        measure {
            Task {
                do {
                    _ = try await coreDataManager.saveTransactions(largeDataSet)
                } catch {
                    XCTFail("Performance test failed: \(error)")
                }
            }
        }
    }

    func testPerformanceFetchTransactions_LargeDataSet() async throws {
        // Given
        let largeDataSet = (0..<1000).map { index in
            ExtractedTransaction(
                merchant: "Merchant \(index)",
                amount: Double(index) * 1.5,
                date: Date(),
                category: "Test Category",
                confidence: 0.8
            )
        }
        _ = try await coreDataManager.saveTransactions(largeDataSet)

        // When & Then
        measure {
            Task {
                do {
                    _ = try await coreDataManager.getAllTransactions()
                } catch {
                    XCTFail("Performance test failed: \(error)")
                }
            }
        }
    }
}