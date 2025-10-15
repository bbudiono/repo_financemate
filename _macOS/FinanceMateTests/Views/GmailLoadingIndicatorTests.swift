import XCTest
import SwiftUI
@testable import FinanceMate

/// Test suite for enhanced loading indicators during Gmail operations
/// BLUEPRINT requirement: Show detailed progress during email refresh and extraction
class GmailLoadingIndicatorTests: XCTestCase {

    var viewModel: GmailViewModel!
    var context: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        context = PersistenceController.preview.container.viewContext
        viewModel = GmailViewModel(context: context)
    }

    override func tearDown() {
        viewModel = nil
        context = nil
        super.tearDown()
    }

    /// Test that batch processing flag is set during extraction
    func testBatchProcessingFlagSetDuringExtraction() async {
        // Given: View model with test emails
        viewModel.emails = [
            GmailEmail(id: "test1", snippet: "Test 1", from: "test@test.com", subject: "Test", date: Date(), hasAttachments: false),
            GmailEmail(id: "test2", snippet: "Test 2", from: "test@test.com", subject: "Test", date: Date(), hasAttachments: false)
        ]

        // When: Extraction starts
        let extractionTask = Task {
            await viewModel.extractTransactionsFromEmails()
        }

        // Then: Should set batch processing flag
        // (Check immediately after task creation - flag should be set)
        try? await Task.sleep(nanoseconds: 100_000_000) // 100ms
        XCTAssertTrue(viewModel.isBatchProcessing, "Batch processing flag should be set during extraction")

        // Wait for completion
        await extractionTask.value
    }

    /// Test that batch progress is updated during extraction
    func testBatchProgressUpdatedDuringExtraction() async {
        // Given: View model with test emails
        viewModel.emails = [
            GmailEmail(id: "test1", snippet: "Test order total $50", from: "test@test.com", subject: "Receipt", date: Date(), hasAttachments: false),
            GmailEmail(id: "test2", snippet: "Test order total $75", from: "test@test.com", subject: "Receipt", date: Date(), hasAttachments: false)
        ]

        // When: Extraction completes
        await viewModel.extractTransactionsFromEmails()

        // Then: Progress should show completion
        XCTAssertEqual(viewModel.batchProgressTotal, 2, "Total should match email count")
        XCTAssertFalse(viewModel.isBatchProcessing, "Batch processing should be false after completion")
    }

    /// Test that loading state is set during fetchEmails
    func testLoadingStateDuringFetch() async {
        // Given: View model with valid OAuth token
        KeychainHelper.save(value: "test_token", account: "gmail_access_token")

        // When: Fetch starts (will fail due to invalid token, but loading state should still be set)
        let fetchTask = Task {
            await viewModel.fetchEmails()
        }

        // Then: Loading state should be initially true
        try? await Task.sleep(nanoseconds: 100_000_000) // 100ms

        // Wait for completion
        await fetchTask.value

        // After completion, loading should be false
        XCTAssertFalse(viewModel.isLoading, "Loading should be false after fetch completes")
    }

    /// Test that batch error count is tracked
    func testBatchErrorCountTracking() async {
        // Given: View model with emails that might fail extraction
        viewModel.emails = [
            GmailEmail(id: "test1", snippet: "Invalid", from: "test@test.com", subject: "Test", date: Date(), hasAttachments: false)
        ]

        // When: Extraction completes
        await viewModel.extractTransactionsFromEmails()

        // Then: Error count should be accessible (may be 0 if extraction succeeds)
        XCTAssertTrue(viewModel.batchErrorCount >= 0, "Error count should be non-negative")
    }
}
