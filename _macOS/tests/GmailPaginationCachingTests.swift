import XCTest
import CoreData
@testable import FinanceMate

/// Gmail Pagination Caching Tests - RED Phase
/// BLUEPRINT MVP Enhancement: Persistent Gmail caching for cross-session deduplication
/// Failing tests to prove persistent caching gap exists
final class GmailPaginationCachingTests: XCTestCase {

    var testContext: NSManagedObjectContext!
    var testViewModel: GmailViewModel!
    var testPersistenceController: PersistenceController!

    override func setUpWithError() throws {
        testPersistenceController = PersistenceController(inMemory: true)
        testContext = testPersistenceController.container.viewContext
        testViewModel = GmailViewModel(context: testContext)
    }

    override func tearDownWithError() throws {
        testContext = nil
        testViewModel = nil
        testPersistenceController = nil
    }

    /// Test that Gmail emails are cached persistently across sessions
    /// RED PHASE: This should fail because current caching is only in UserDefaults (1 hour expiry)
    func testPageTokenPersistentCaching() throws {
        // P0 VIOLATION: Current EmailCacheService only uses UserDefaults with 1-hour expiry
        // No persistent Core Data caching exists for cross-session deduplication

        // Simulate first pagination batch
        let firstBatch = createTestEmails(count: 10, startId: "cache-test-001")

        // Current cache service only saves to UserDefaults
        let cacheService = EmailCacheService()
        cacheService.saveEmailsToCache(firstBatch)

        // Verify UserDefaults cache works (this should pass)
        let cachedEmails = cacheService.loadCachedEmails()
        XCTAssertNotNil(cachedEmails, "UserDefaults cache should work")
        XCTAssertEqual(cachedEmails?.count, 10, "Should cache 10 emails")

        // P0 VERIFICATION: Test persistent Core Data caching (this should fail)
        // No Core Data email cache entity exists for persistent storage
        let fetchRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "CachedEmail")
        let coreDataCachedEmails = try testContext.fetch(fetchRequest)

        // This assertion will fail because no CachedEmail entity exists in Core Data model
        XCTAssertEqual(coreDataCachedEmails.count, 10, "Core Data should persist cached emails across sessions")

        // Test that cached emails survive app restart (simulation)
        let newViewModel = GmailViewModel(context: testContext)
        let newCacheService = EmailCacheService()
        let persistedEmails = newCacheService.loadCachedEmails()

        // This may pass due to UserDefaults, but true persistence test above will fail
        XCTAssertNotNil(persistedEmails, "Cache should survive app restart simulation")
    }

    /// Test that duplicate emails are properly deduplicated across pagination calls
    /// RED PHASE: This should fail because current deduplication is only in-memory per session
    func testDeduplicationWithCache() throws {
        // P0 VIOLATION: Current deduplication only works within single session's memory
        // No persistent deduplication across pagination sessions

        // Create overlapping email sets (simulating pagination with duplicates)
        let firstBatch = createTestEmails(count: 5, startId: "dedup-test-001")
        let secondBatch = createTestEmails(count: 5, startId: "dedup-test-003") // Overlap with 2 emails

        // Process first batch
        let cacheService = EmailCacheService()
        cacheService.saveEmailsToCache(firstBatch)

        // Simulate pagination by processing second batch with current deduplication
        let allEmails = firstBatch + secondBatch
        let uniqueEmailIds = Set(allEmails.map { $0.id })

        // Current in-memory deduplication should work
        XCTAssertEqual(uniqueEmailIds.count, 8, "In-memory deduplication should work (8 unique IDs)")

        // P0 VERIFICATION: Test persistent deduplication across cache boundaries
        // This will fail because no persistent email ID tracking exists

        // Clear in-memory state (simulate new session)
        let newViewModel = GmailViewModel(context: testContext)

        // Try to load cached emails and deduplicate with new batch
        let cachedEmails = cacheService.loadCachedEmails()
        let combinedEmails = (cachedEmails ?? []) + secondBatch
        let combinedUniqueIds = Set(combinedEmails.map { $0.id })

        // This should fail because persistent deduplication doesn't exist
        XCTAssertEqual(combinedUniqueIds.count, 8, "Persistent deduplication should prevent duplicates across sessions")

        // Test that we can query cache to see if email was already processed
        // No such capability exists in current implementation
        let testEmailId = "dedup-test-002" // Should be in first batch
        let isEmailCached = checkIfEmailIsCached(emailId: testEmailId)

        // This will fail because no persistent cache query method exists
        XCTAssertTrue(isEmailCached, "Should be able to query if email was cached previously")
    }

    /// Test that pagination progress counters are accurate and persist across UI updates
    /// RED PHASE: This should fail because progress tracking doesn't account for cache hits
    func testPaginationProgressCounters() throws {
        // P0 VIOLATION: Progress counters don't account for cached emails properly
        // UI shows wrong totals when cache hits occur

        // Set up test with cached emails
        let cachedBatch = createTestEmails(count: 20, startId: "progress-test-001")
        let cacheService = EmailCacheService()
        cacheService.saveEmailsToCache(cachedBatch)

        // Simulate Gmail pagination that finds cache hit
        testViewModel.emails = cachedBatch
        testViewModel.extractedTransactions = createTestTransactions(from: cachedBatch)

        // Test progress counter calculation
        let unprocessedCount = testViewModel.unprocessedEmails.count
        let totalPages = Int(ceil(Double(unprocessedCount) / 50.0)) // 50 per page

        // Current implementation should show correct numbers for cached data
        XCTAssertGreaterThan(unprocessedCount, 0, "Should have unprocessed emails")

        // P0 VERIFICATION: Test that progress accounts for cache efficiency
        // This will fail because progress tracking doesn't differentiate between cache hits and new fetches

        // Simulate fetching more emails that overlap with cache
        let newBatch = createTestEmails(count: 10, startId: "progress-test-015") // Overlap 6 emails
        let allEmails = cachedBatch + newBatch
        let allUniqueIds = Set(allEmails.map { $0.id })

        // Progress should reflect unique emails, not raw count
        // This assertion will likely fail because progress doesn't account for deduplication
        XCTAssertEqual(allUniqueIds.count, 24, "Progress should account for deduplicated unique emails")

        // Test that UI progress bar shows accurate percentage
        let processedInCache = cachedBatch.count
        let totalUnique = allUniqueIds.count
        let cacheEfficiency = Double(processedInCache) / Double(totalUnique)

        // No current mechanism exists to report cache efficiency to UI
        // This will fail because cache efficiency reporting doesn't exist
        XCTAssertGreaterThan(cacheEfficiency, 0.5, "Should report cache efficiency > 50%")
    }

    // MARK: - Helper Methods

    private func createTestEmails(count: Int, startId: String) -> [GmailEmail] {
        return (0..<count).map { index in
            GmailEmail(
                id: "\(startId)-\(index)",
                subject: "Test Email \(index)",
                sender: "test@example.com",
                date: Date().addingTimeInterval(-Double(index * 3600)), // 1 hour apart
                snippet: "Test content \(index)",
                attachments: []
            )
        }
    }

    private func createTestTransactions(from emails: [GmailEmail]) -> [ExtractedTransaction] {
        return emails.enumerated().map { index, email in
            ExtractedTransaction(
                id: "tx-\(email.id)",
                merchant: "Test Merchant \(index)",
                amount: Double(index + 1) * 10.0,
                date: email.date,
                category: "Test Category",
                items: [],
                confidence: 0.8,
                rawText: email.snippet,
                emailSubject: email.subject,
                emailSender: email.sender
            )
        }
    }

    private func checkIfEmailIsCached(emailId: String) -> Bool {
        // P0 VIOLATION: No method exists to query if specific email is cached
        // Current implementation can only load all cached emails or check validity

        let cacheService = EmailCacheService()
        if let cachedEmails = cacheService.loadCachedEmails() {
            return cachedEmails.contains { $0.id == emailId }
        }
        return false
    }
}