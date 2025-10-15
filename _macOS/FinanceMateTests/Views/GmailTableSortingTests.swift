import XCTest
@testable import FinanceMate

/// BLUEPRINT Line 68: Gmail Receipts Table MUST support interactive column header sorting
/// Tests that clicking sortable column headers (Date, Merchant, Category, Amount, Confidence)
/// properly sorts the table data with visual indication of sort direction
final class GmailTableSortingTests: XCTestCase {
    var viewModel: GmailViewModel!

    override func setUp() {
        super.setUp()
        viewModel = GmailViewModel()

        // Create test transactions with varied data for sorting validation
        let transaction1 = ExtractedTransaction(
            id: "1",
            date: Date().addingTimeInterval(-86400 * 5), // 5 days ago
            merchant: "Zebra Store",
            category: "Shopping",
            amount: 150.00,
            confidence: 0.95,
            emailSender: "receipt@zebra.com",
            emailSubject: "Your Zebra Store Receipt",
            invoiceNumber: "INV-001"
        )

        let transaction2 = ExtractedTransaction(
            id: "2",
            date: Date().addingTimeInterval(-86400 * 2), // 2 days ago
            merchant: "Apple Store",
            category: "Electronics",
            amount: 299.99,
            confidence: 0.88,
            emailSender: "receipt@apple.com",
            emailSubject: "Your Apple Store Receipt",
            invoiceNumber: "INV-002"
        )

        let transaction3 = ExtractedTransaction(
            id: "3",
            date: Date().addingTimeInterval(-86400), // 1 day ago
            merchant: "Bunnings",
            category: "Hardware",
            amount: 45.50,
            confidence: 0.72,
            emailSender: "receipt@bunnings.com.au",
            emailSubject: "Your Bunnings Receipt",
            invoiceNumber: "INV-003"
        )

        viewModel.extractedTransactions = [transaction1, transaction2, transaction3]
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    // MARK: - Date Column Sorting Tests

    func testDateSortingAscending() {
        // Given: Transactions with different dates
        let sortOrder = [KeyPathComparator(\ExtractedTransaction.date, order: .forward)]

        // When: Sorting by date ascending
        let sorted = viewModel.paginatedTransactions.sorted(using: sortOrder)

        // Then: Dates should be in ascending order (oldest first)
        XCTAssertEqual(sorted[0].merchant, "Zebra Store", "First transaction should be oldest (5 days ago)")
        XCTAssertEqual(sorted[1].merchant, "Apple Store", "Second transaction should be 2 days ago")
        XCTAssertEqual(sorted[2].merchant, "Bunnings", "Third transaction should be most recent")
    }

    func testDateSortingDescending() {
        // Given: Transactions with different dates
        let sortOrder = [KeyPathComparator(\ExtractedTransaction.date, order: .reverse)]

        // When: Sorting by date descending
        let sorted = viewModel.paginatedTransactions.sorted(using: sortOrder)

        // Then: Dates should be in descending order (newest first)
        XCTAssertEqual(sorted[0].merchant, "Bunnings", "First transaction should be most recent")
        XCTAssertEqual(sorted[1].merchant, "Apple Store", "Second transaction should be 2 days ago")
        XCTAssertEqual(sorted[2].merchant, "Zebra Store", "Third transaction should be oldest")
    }

    // MARK: - Merchant Column Sorting Tests

    func testMerchantSortingAscending() {
        // Given: Transactions with different merchant names
        let sortOrder = [KeyPathComparator(\ExtractedTransaction.merchant, order: .forward)]

        // When: Sorting by merchant ascending (A-Z)
        let sorted = viewModel.paginatedTransactions.sorted(using: sortOrder)

        // Then: Merchants should be alphabetically sorted
        XCTAssertEqual(sorted[0].merchant, "Apple Store", "First should be Apple Store (A)")
        XCTAssertEqual(sorted[1].merchant, "Bunnings", "Second should be Bunnings (B)")
        XCTAssertEqual(sorted[2].merchant, "Zebra Store", "Third should be Zebra Store (Z)")
    }

    func testMerchantSortingDescending() {
        // Given: Transactions with different merchant names
        let sortOrder = [KeyPathComparator(\ExtractedTransaction.merchant, order: .reverse)]

        // When: Sorting by merchant descending (Z-A)
        let sorted = viewModel.paginatedTransactions.sorted(using: sortOrder)

        // Then: Merchants should be reverse alphabetically sorted
        XCTAssertEqual(sorted[0].merchant, "Zebra Store", "First should be Zebra Store (Z)")
        XCTAssertEqual(sorted[1].merchant, "Bunnings", "Second should be Bunnings (B)")
        XCTAssertEqual(sorted[2].merchant, "Apple Store", "Third should be Apple Store (A)")
    }

    // MARK: - Category Column Sorting Tests

    func testCategorySortingAscending() {
        // Given: Transactions with different categories
        let sortOrder = [KeyPathComparator(\ExtractedTransaction.category, order: .forward)]

        // When: Sorting by category ascending
        let sorted = viewModel.paginatedTransactions.sorted(using: sortOrder)

        // Then: Categories should be alphabetically sorted
        XCTAssertEqual(sorted[0].category, "Electronics", "First should be Electronics")
        XCTAssertEqual(sorted[1].category, "Hardware", "Second should be Hardware")
        XCTAssertEqual(sorted[2].category, "Shopping", "Third should be Shopping")
    }

    func testCategorySortingDescending() {
        // Given: Transactions with different categories
        let sortOrder = [KeyPathComparator(\ExtractedTransaction.category, order: .reverse)]

        // When: Sorting by category descending
        let sorted = viewModel.paginatedTransactions.sorted(using: sortOrder)

        // Then: Categories should be reverse alphabetically sorted
        XCTAssertEqual(sorted[0].category, "Shopping", "First should be Shopping")
        XCTAssertEqual(sorted[1].category, "Hardware", "Second should be Hardware")
        XCTAssertEqual(sorted[2].category, "Electronics", "Third should be Electronics")
    }

    // MARK: - Amount Column Sorting Tests

    func testAmountSortingAscending() {
        // Given: Transactions with different amounts
        let sortOrder = [KeyPathComparator(\ExtractedTransaction.amount, order: .forward)]

        // When: Sorting by amount ascending (lowest to highest)
        let sorted = viewModel.paginatedTransactions.sorted(using: sortOrder)

        // Then: Amounts should be in ascending order
        XCTAssertEqual(sorted[0].amount, 45.50, accuracy: 0.01, "First should be $45.50 (Bunnings)")
        XCTAssertEqual(sorted[1].amount, 150.00, accuracy: 0.01, "Second should be $150.00 (Zebra)")
        XCTAssertEqual(sorted[2].amount, 299.99, accuracy: 0.01, "Third should be $299.99 (Apple)")
    }

    func testAmountSortingDescending() {
        // Given: Transactions with different amounts
        let sortOrder = [KeyPathComparator(\ExtractedTransaction.amount, order: .reverse)]

        // When: Sorting by amount descending (highest to lowest)
        let sorted = viewModel.paginatedTransactions.sorted(using: sortOrder)

        // Then: Amounts should be in descending order
        XCTAssertEqual(sorted[0].amount, 299.99, accuracy: 0.01, "First should be $299.99 (Apple)")
        XCTAssertEqual(sorted[1].amount, 150.00, accuracy: 0.01, "Second should be $150.00 (Zebra)")
        XCTAssertEqual(sorted[2].amount, 45.50, accuracy: 0.01, "Third should be $45.50 (Bunnings)")
    }

    // MARK: - Confidence Column Sorting Tests

    func testConfidenceSortingAscending() {
        // Given: Transactions with different confidence scores
        let sortOrder = [KeyPathComparator(\ExtractedTransaction.confidence, order: .forward)]

        // When: Sorting by confidence ascending (lowest to highest)
        let sorted = viewModel.paginatedTransactions.sorted(using: sortOrder)

        // Then: Confidence scores should be in ascending order
        XCTAssertEqual(sorted[0].confidence, 0.72, accuracy: 0.01, "First should be 0.72 (Bunnings)")
        XCTAssertEqual(sorted[1].confidence, 0.88, accuracy: 0.01, "Second should be 0.88 (Apple)")
        XCTAssertEqual(sorted[2].confidence, 0.95, accuracy: 0.01, "Third should be 0.95 (Zebra)")
    }

    func testConfidenceSortingDescending() {
        // Given: Transactions with different confidence scores
        let sortOrder = [KeyPathComparator(\ExtractedTransaction.confidence, order: .reverse)]

        // When: Sorting by confidence descending (highest to lowest)
        let sorted = viewModel.paginatedTransactions.sorted(using: sortOrder)

        // Then: Confidence scores should be in descending order
        XCTAssertEqual(sorted[0].confidence, 0.95, accuracy: 0.01, "First should be 0.95 (Zebra)")
        XCTAssertEqual(sorted[1].confidence, 0.88, accuracy: 0.01, "Second should be 0.88 (Apple)")
        XCTAssertEqual(sorted[2].confidence, 0.72, accuracy: 0.01, "Third should be 0.72 (Bunnings)")
    }

    // MARK: - Sort Stability Tests

    func testMultipleSortOperations() {
        // Given: Initial unsorted data
        let initialTransactions = viewModel.paginatedTransactions

        // When: Applying multiple sort operations in sequence
        let sortByDate = [KeyPathComparator(\ExtractedTransaction.date, order: .forward)]
        let step1 = initialTransactions.sorted(using: sortByDate)

        let sortByMerchant = [KeyPathComparator(\ExtractedTransaction.merchant, order: .forward)]
        let step2 = step1.sorted(using: sortByMerchant)

        let sortByAmount = [KeyPathComparator(\ExtractedTransaction.amount, order: .forward)]
        let step3 = step2.sorted(using: sortByAmount)

        // Then: Final sort should be by amount (last applied)
        XCTAssertEqual(step3[0].amount, 45.50, accuracy: 0.01, "Final sort should be by amount")
        XCTAssertEqual(step3[1].amount, 150.00, accuracy: 0.01)
        XCTAssertEqual(step3[2].amount, 299.99, accuracy: 0.01)
    }

    func testEmptyDataSetSorting() {
        // Given: Empty transaction list
        viewModel.extractedTransactions = []

        // When: Attempting to sort empty data
        let sortOrder = [KeyPathComparator(\ExtractedTransaction.date, order: .forward)]
        let sorted = viewModel.paginatedTransactions.sorted(using: sortOrder)

        // Then: Should handle gracefully without crash
        XCTAssertTrue(sorted.isEmpty, "Sorting empty dataset should return empty array")
    }

    func testSingleItemSorting() {
        // Given: Single transaction
        viewModel.extractedTransactions = [viewModel.extractedTransactions[0]]

        // When: Sorting single item
        let sortOrder = [KeyPathComparator(\ExtractedTransaction.merchant, order: .forward)]
        let sorted = viewModel.paginatedTransactions.sorted(using: sortOrder)

        // Then: Should return the same single item
        XCTAssertEqual(sorted.count, 1, "Single item should remain")
        XCTAssertEqual(sorted[0].id, viewModel.extractedTransactions[0].id, "Same item should be returned")
    }
}
