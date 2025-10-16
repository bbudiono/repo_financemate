import XCTest
@testable import FinanceMate

/// PRIORITY 1A: Gmail Pagination Enhancement Tests
/// Tests exponential backoff calculation, email deduplication, and progress tracking
final class GmailPaginationEnhancerTests: XCTestCase {

    /// PRIORITY 1A: Test exponential backoff calculation (2/4/8s with jitter)
    func testExponentialBackoffCalculation() throws {
        // Test base delay calculation
        let retry0 = GmailPaginationEnhancer.calculateBackoffDelay(retryCount: 0)
        let retry1 = GmailPaginationEnhancer.calculateBackoffDelay(retryCount: 1)
        let retry2 = GmailPaginationEnhancer.calculateBackoffDelay(retryCount: 2)

        // Verify exponential pattern (2s, 4s, 8s base) with jitter
        XCTAssertEqual(retry0, 2.0, accuracy: 0.4, "First retry should be ~2 seconds with jitter")
        XCTAssertEqual(retry1, 4.0, accuracy: 0.8, "Second retry should be ~4 seconds with jitter")
        XCTAssertEqual(retry2, 8.0, accuracy: 1.6, "Third retry should be ~8 seconds with jitter")

        // Verify no negative delays
        XCTAssertGreaterThan(retry0, 0, "Delay should be positive")
        XCTAssertGreaterThan(retry1, 0, "Delay should be positive")
        XCTAssertGreaterThan(retry2, 0, "Delay should be positive")
    }

    /// PRIORITY 1A: Test email deduplication by ID and content hash
    func testEmailDeduplication() throws {
        let testDate = Date()

        // Create test emails with some duplicates
        let emails = [
            GmailEmail(id: "1", subject: "Receipt from Amazon", sender: "amazon@amazon.com", date: testDate, snippet: "Order #123"),
            GmailEmail(id: "2", subject: "Receipt from Amazon", sender: "amazon@amazon.com", date: testDate, snippet: "Order #123"), // Content duplicate
            GmailEmail(id: "1", subject: "Duplicate ID", sender: "test@test.com", date: testDate, snippet: "Different content"), // ID duplicate
            GmailEmail(id: "3", subject: "Unique Email", sender: "unique@test.com", date: testDate, snippet: "Unique content")
        ]

        let result = GmailPaginationEnhancer.deduplicateEmails(emails)

        XCTAssertEqual(result.unique.count, 2, "Should have 2 unique emails")
        XCTAssertEqual(result.duplicatesRemoved, 2, "Should have removed 2 duplicates")
        XCTAssertGreaterThan(result.contentHashes.count, 0, "Should track content hashes")

        // Verify the correct emails are kept (most recent first)
        let uniqueIds = result.unique.map { $0.id }
        XCTAssertTrue(uniqueIds.contains("1"), "Should keep email ID 1 (first occurrence)")
        XCTAssertTrue(uniqueIds.contains("3"), "Should keep email ID 3 (unique)")
        XCTAssertFalse(uniqueIds.contains("2"), "Should remove duplicate content email ID 2")
    }

    /// PRIORITY 1A: Test progress tracking calculations
    func testProgressTracking() throws {
        let startTime = Date(timeIntervalSinceNow: -10) // 10 seconds ago

        let progress = GmailPaginationEnhancer.createProgressSnapshot(
            totalTarget: 1000,
            processedSoFar: 250,
            currentPage: 3,
            uniqueEmails: 240,
            duplicatesFiltered: 10,
            fetchErrors: 2,
            estimatedTotal: 1200,
            startTime: startTime
        )

        XCTAssertEqual(progress.totalTarget, 1000, "Should track total target")
        XCTAssertEqual(progress.processedSoFar, 250, "Should track processed count")
        XCTAssertEqual(progress.currentPage, 3, "Should track current page")
        XCTAssertEqual(progress.uniqueEmailsFound, 240, "Should track unique emails")
        XCTAssertEqual(progress.duplicatesFiltered, 10, "Should track duplicates filtered")
        XCTAssertEqual(progress.fetchErrors, 2, "Should track fetch errors")

        // Test calculations
        XCTAssertEqual(progress.processedPercentage, 0.25, accuracy: 0.01, "Should calculate 25% processed")
        XCTAssertGreaterThan(progress.emailsPerSecond, 20, "Should calculate reasonable rate (25 emails / 10s)")
        XCTAssertNotNil(progress.estimatedTimeRemaining, "Should calculate ETA")
        XCTAssertNotNil(progress.estimatedTotalAvailable, "Should track estimated total")
    }

    /// PRIORITY 1A: Test progress logging (verifies no crashes)
    func testProgressLogging() throws {
        let progress = GmailPaginationEnhancer.createProgressSnapshot(
            totalTarget: 100,
            processedSoFar: 50,
            currentPage: 2,
            uniqueEmails: 48,
            duplicatesFiltered: 2,
            fetchErrors: 0,
            estimatedTotal: 100,
            startTime: Date(timeIntervalSinceNow: -5)
        )

        // Should not crash when logging progress
        XCTAssertNoThrow(GmailPaginationEnhancer.logProgress(progress), "Progress logging should not crash")
    }

    /// PRIORITY 1A: Test content hash generation
    func testContentHashGeneration() throws {
        let content1 = "Test Content"
        let content2 = "Test Content"
        let content3 = "Different Content"

        let hash1 = content1.sha256()
        let hash2 = content2.sha256()
        let hash3 = content3.sha256()

        // Same content should produce same hash
        XCTAssertEqual(hash1, hash2, "Same content should produce same hash")

        // Different content should produce different hash
        XCTAssertNotEqual(hash1, hash3, "Different content should produce different hash")

        // Hash should not be empty
        XCTAssertFalse(hash1.isEmpty, "Hash should not be empty")
        XCTAssertFalse(hash3.isEmpty, "Hash should not be empty")
    }
}