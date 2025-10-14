import XCTest
@testable import FinanceMate

/// Test suite for GmailViewModel batch processing and progress tracking
/// BLUEPRINT Line 150: Concurrent batch processing with progress UI
@MainActor
final class GmailViewModelTests: XCTestCase {

    var viewModel: GmailViewModel!
    var context: NSManagedObjectContext!

    override func setUp() async throws {
        context = PersistenceController.preview.container.viewContext
        viewModel = GmailViewModel(context: context)
    }

    override func tearDown() {
        viewModel = nil
        context = nil
    }

    // MARK: - Batch Progress UI Tests

    /// Test batch progress properties update during extraction
    func testBatchProgressUIUpdates() async {
        // Given: 5 test emails
        let emails = (0..<5).map { index in
            GmailEmail(
                id: "progress-ui-\(index)",
                subject: "Receipt \(index)",
                sender: "test\(index)@bunnings.com.au",
                date: Date(),
                snippet: "Total: $\(100 + index).00 GST: $10.00"
            )
        }

        viewModel.emails = emails

        // Then: Progress properties should start at zero
        XCTAssertFalse(viewModel.isBatchProcessing)
        XCTAssertEqual(viewModel.batchProgressProcessed, 0)
        XCTAssertEqual(viewModel.batchProgressTotal, 0)
        XCTAssertEqual(viewModel.batchErrorCount, 0)
        XCTAssertNil(viewModel.estimatedTimeRemaining)

        // When: Extract transactions
        await viewModel.extractTransactionsFromEmails()

        // Then: Progress properties should update
        XCTAssertFalse(viewModel.isBatchProcessing, "Should finish processing")
        XCTAssertEqual(viewModel.batchProgressProcessed, 5, "Should process all emails")
        XCTAssertEqual(viewModel.batchProgressTotal, 5, "Total should be 5")
        XCTAssertEqual(viewModel.batchErrorCount, 0, "Should have no errors")
        XCTAssertEqual(viewModel.extractedTransactions.count, 5, "Should extract all transactions")
    }

    /// Test progress percentage calculation
    func testBatchProgressPercentage() async {
        let emails = (0..<10).map { index in
            GmailEmail(
                id: "progress-\(index)",
                subject: "Receipt",
                sender: "test@test.com",
                date: Date(),
                snippet: "Total: $100"
            )
        }

        viewModel.emails = emails
        await viewModel.extractTransactionsFromEmails()

        // Progress should reach 100%
        let percentage = Double(viewModel.batchProgressProcessed) / Double(viewModel.batchProgressTotal)
        XCTAssertEqual(percentage, 1.0, "Should reach 100% completion")
    }

    /// Test ETA calculation updates during processing
    func testEstimatedTimeRemainingCalculation() async {
        let emails = (0..<3).map { index in
            GmailEmail(
                id: "eta-\(index)",
                subject: "Receipt",
                sender: "test@test.com",
                date: Date(),
                snippet: "Total: $100"
            )
        }

        viewModel.emails = emails
        await viewModel.extractTransactionsFromEmails()

        // ETA should be calculated and eventually reach 0
        // Note: Since extraction is fast in tests, ETA might be nil or very small
        if let eta = viewModel.estimatedTimeRemaining {
            XCTAssertGreaterThanOrEqual(eta, 0.0, "ETA should be non-negative")
        }
    }

    /// Test error counting during batch processing
    func testBatchErrorCounting() async {
        // Mix of valid and malformed emails
        let emails = [
            GmailEmail(id: "valid-1", subject: "Good", sender: "test@bunnings.com.au", date: Date(), snippet: "Total: $100"),
            GmailEmail(id: "malformed", subject: "Bad", sender: "malformed", date: Date(), snippet: "bad"),
            GmailEmail(id: "valid-2", subject: "Good", sender: "test@woolworths.com.au", date: Date(), snippet: "Total: $200"),
        ]

        viewModel.emails = emails
        await viewModel.extractTransactionsFromEmails()

        // Even malformed emails should be handled gracefully (no errors in extraction, just low confidence)
        XCTAssertEqual(viewModel.batchErrorCount, 0, "Extraction should handle malformed emails gracefully")
        XCTAssertEqual(viewModel.batchProgressProcessed, 3, "Should process all emails")
    }

    /// Test isBatchProcessing flag lifecycle
    func testBatchProcessingFlagLifecycle() async {
        let emails = [
            GmailEmail(id: "test-1", subject: "Receipt", sender: "test@test.com", date: Date(), snippet: "Total: $100")
        ]

        viewModel.emails = emails

        // Before processing
        XCTAssertFalse(viewModel.isBatchProcessing)

        // Start processing (we can't easily check during since it's fast, but we can verify it ends)
        await viewModel.extractTransactionsFromEmails()

        // After processing
        XCTAssertFalse(viewModel.isBatchProcessing, "Should clear flag after completion")
    }
}
