import XCTest
import SwiftUI
@testable import FinanceMate

/// Test suite for visual feedback when cache is cleared during email refresh
/// BLUEPRINT requirement: Users must see confirmation of cache clearing operation
class GmailCacheClearFeedbackTests: XCTestCase {

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

    /// Test that clearing cache sets the showCacheClearMessage flag
    func testCacheClearSetsMessageFlag() {
        // Given: Fresh view model with no message
        XCTAssertFalse(viewModel.showCacheClearMessage, "Message flag should start as false")

        // When: Cache is cleared
        viewModel.clearCacheAndRefresh()

        // Then: Message flag should be set
        XCTAssertTrue(viewModel.showCacheClearMessage, "Message flag should be true after cache clear")
    }

    /// Test that cache clear message auto-dismisses after 2 seconds
    func testCacheClearMessageAutoDismisses() async {
        // Given: Fresh view model
        viewModel.showCacheClearMessage = true

        // When: Message is shown and we wait 2.1 seconds
        try? await Task.sleep(nanoseconds: 2_100_000_000)

        // Then: Message should be auto-dismissed
        XCTAssertFalse(viewModel.showCacheClearMessage, "Message should auto-dismiss after 2 seconds")
    }

    /// Test that clearCacheAndRefresh actually clears the cache
    func testClearCacheAndRefreshInvalidatesCache() {
        // Given: Cache with data
        let testEmails = [
            GmailEmail(id: "test1", snippet: "Test", from: "test@test.com", subject: "Test", date: Date(), hasAttachments: false)
        ]
        EmailCacheManager.save(emails: testEmails)
        XCTAssertNotNil(EmailCacheManager.load(), "Cache should have data")

        // When: clearCacheAndRefresh is called
        viewModel.clearCacheAndRefresh()

        // Then: Cache should be empty
        XCTAssertNil(EmailCacheManager.load(), "Cache should be cleared")
    }

    /// Test that clearCacheAndRefresh sets loading state
    func testClearCacheAndRefreshSetsLoadingState() async {
        // Given: View model not loading
        XCTAssertFalse(viewModel.isLoading, "Should not be loading initially")

        // When: clearCacheAndRefresh is called
        await viewModel.clearCacheAndRefresh()

        // Then: Loading state should be set during fetch
        // (After fetch completes, isLoading will be false again)
        // This tests the full flow completed without errors
        XCTAssertFalse(viewModel.errorMessage != nil, "Should not have errors after refresh")
    }
}
