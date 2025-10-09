import XCTest
import Foundation
@testable import FinanceMate

/// Test suite for Gmail caching performance enhancements
/// Focuses on cache expiration, invalidation, and performance
class GmailCachePerformanceTests: XCTestCase {

    // MARK: - Test Properties
    var gmailAPIService: GmailAPIService!
    var mockPersistenceController: PersistenceController!

    // Test data for consistent testing
    let testEmails = [
        GmailEmail(id: "email_1", subject: "Receipt from Store A", sender: "storea@example.com", date: Date(), snippet: "$25.99"),
        GmailEmail(id: "email_2", subject: "Invoice from Service B", sender: "serviceb@example.com", date: Date(), snippet: "$150.00")
    ]

    // MARK: - Setup & Teardown

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockPersistenceController = PersistenceController.preview
        gmailAPIService = GmailAPIService()
        clearTestCache()
    }

    override func tearDownWithError() throws {
        gmailAPIService = nil
        mockPersistenceController = nil
        clearTestCache()
        try super.tearDownWithError()
    }

    private func clearTestCache() {
        UserDefaults.standard.removeObject(forKey: "GmailCache_test")
        UserDefaults.standard.removeObject(forKey: "GmailRateLimit_test")
    }

    // MARK: - RED PHASE: Cache Tests

    /// RED PHASE TEST: Cache expiration behavior - should fail initially
    func testGmailCache_ExpirationBehavior_FailsWhenCacheExpired() async throws {
        let cacheService = EmailCacheService()
        cacheService.saveEmailsToCache(testEmails)

        // Simulate expired cache
        UserDefaults.standard.set(Date().addingTimeInterval(-3600), forKey: "GmailCacheTimestamp")

        let cachedEmails = cacheService.loadCachedEmails()

        // EXPECTED FAILURE: Current implementation doesn't check expiration
        XCTAssertNil(cachedEmails, "RED FAILURE: Cache should return nil for expired entries")
    }

    /// RED PHASE TEST: Cache invalidation - should fail initially
    func testGmailCache_InvalidationOnChanges_FailsWhenCacheStale() async throws {
        let cacheService = EmailCacheService()
        cacheService.saveEmailsToCache(testEmails)

        // Attempt cache invalidation (method doesn't exist yet)
        cacheService.invalidateCache()

        let cachedEmails = cacheService.loadCachedEmails()

        // EXPECTED FAILURE: Cache invalidation not implemented
        XCTAssertNil(cachedEmails, "RED FAILURE: Cache should be nil after invalidation")
    }

    /// RED PHASE TEST: Performance improvement - should fail initially
    func testGmailCache_PerformanceImprovement_FailsToReduceLoadTime() async throws {
        let startTime = Date()
        _ = try await gmailAPIService.fetchEmails(maxResults: 100)
        let coldFetchTime = Date().timeIntervalSince(startTime)

        let cacheService = EmailCacheService()
        cacheService.saveEmailsToCache(testEmails)

        let warmStartTime = Date()
        let cachedEmails = cacheService.loadCachedEmails()
        let warmFetchTime = Date().timeIntervalSince(warmStartTime)

        // EXPECTED FAILURE: Cache not optimized for performance
        XCTAssertLessThan(warmFetchTime, coldFetchTime * 0.1, "RED FAILURE: Cache should be 10x faster")
        XCTAssertNotNil(cachedEmails, "RED FAILURE: Cache should return emails")
    }
}

// Extensions for RED phase tests (methods don't exist yet)
extension EmailCacheService {
    func invalidateCache() {
        // Method doesn't exist - RED phase will fail
    }
}