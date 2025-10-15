import XCTest
@testable import FinanceMate

/// BLUEPRINT Line 139: Manual refresh control MUST allow explicit data fetch
/// Tests force refresh parameter bypasses cache and fetches fresh data
final class GmailViewModelForceRefreshTests: XCTestCase {
    var viewModel: GmailViewModel!
    var testContext: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        testContext = PersistenceController.preview.container.viewContext
        viewModel = GmailViewModel(context: testContext)

        // Clear any existing cache
        EmailCacheManager.clear()
    }

    override func tearDown() {
        EmailCacheManager.clear()
        viewModel = nil
        testContext = nil
        super.tearDown()
    }

    // MARK: - Force Refresh Tests

    /// Test that forceRefresh: true bypasses cache
    func testForceRefreshBypassesCache() async {
        // Given: Valid cache exists with mock data
        let cachedEmails = [
            GmailEmail(
                id: "cached-1",
                from: "cache@test.com",
                subject: "Cached Email",
                body: "This is from cache",
                date: Date(),
                labels: []
            )
        ]
        EmailCacheManager.save(emails: cachedEmails)

        // Verify cache is valid
        XCTAssertNotNil(EmailCacheManager.load(), "Cache should exist")

        // When: fetchEmails called with forceRefresh: true
        // NOTE: This test will fail until we implement the parameter
        await viewModel.fetchEmails(forceRefresh: true)

        // Then: Should NOT use cached data (loadedFromCache should be false)
        // This will fail until we add the @Published var loadedFromCache
        XCTAssertFalse(viewModel.loadedFromCache, "Force refresh should bypass cache")
    }

    /// Test that default behavior (no forceRefresh) uses cache
    func testDefaultBehaviorUsesCache() async {
        // Given: Valid cache exists
        let cachedEmails = [
            GmailEmail(
                id: "cached-2",
                from: "cache@test.com",
                subject: "Cached Email 2",
                body: "This is from cache",
                date: Date(),
                labels: []
            )
        ]
        EmailCacheManager.save(emails: cachedEmails)

        // When: fetchEmails called WITHOUT forceRefresh parameter
        await viewModel.fetchEmails()

        // Then: Should use cache (loadedFromCache should be true)
        XCTAssertTrue(viewModel.loadedFromCache, "Default behavior should use cache")
        XCTAssertEqual(viewModel.emails.count, 1, "Should load cached email")
    }

    /// Test that forceRefresh: false uses cache
    func testForceRefreshFalseUsesCache() async {
        // Given: Valid cache exists
        let cachedEmails = [
            GmailEmail(
                id: "cached-3",
                from: "cache@test.com",
                subject: "Cached Email 3",
                body: "This is from cache",
                date: Date(),
                labels: []
            )
        ]
        EmailCacheManager.save(emails: cachedEmails)

        // When: fetchEmails called with forceRefresh: false
        await viewModel.fetchEmails(forceRefresh: false)

        // Then: Should use cache
        XCTAssertTrue(viewModel.loadedFromCache, "forceRefresh: false should use cache")
        XCTAssertEqual(viewModel.emails.count, 1, "Should load cached email")
    }

    /// Test that loadedFromCache property tracks cache usage
    func testLoadedFromCachePropertyTracking() async {
        // Test 1: With cache
        let cachedEmails = [
            GmailEmail(
                id: "cached-4",
                from: "cache@test.com",
                subject: "Test",
                body: "Body",
                date: Date(),
                labels: []
            )
        ]
        EmailCacheManager.save(emails: cachedEmails)

        await viewModel.fetchEmails()
        XCTAssertTrue(viewModel.loadedFromCache, "Should be true when loading from cache")

        // Test 2: Clear cache and force refresh
        EmailCacheManager.clear()

        await viewModel.fetchEmails(forceRefresh: true)
        XCTAssertFalse(viewModel.loadedFromCache, "Should be false when not using cache")
    }
}
