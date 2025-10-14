import XCTest
@testable import FinanceMate

/// Tests for concurrent batch extraction (BLUEPRINT Line 150)
/// Validates TaskGroup performance and progress tracking
class IntelligentExtractionConcurrentTests: XCTestCase {

    // MARK: - Test: Concurrent Batch Processing Performance

    /// Test that concurrent extraction is significantly faster than sequential
    /// BLUEPRINT requirement: 5× faster for bulk operations
    /// Expected: 10 emails in <5s (vs ~17s sequential at 1.7s/email)
    func testConcurrentBatchProcessing() async throws {
        // Arrange: Create 10 test emails
        let testEmails = (0..<10).map { index in
            GmailEmail(
                id: "test-\(index)",
                subject: "Test Invoice \(index)",
                sender: "test@example.com",
                date: Date(),
                snippet: "Test transaction $100.00"
            )
        }

        // Act: Measure concurrent extraction time
        let start = Date()
        let results = await IntelligentExtractionService.extractBatch(testEmails, maxConcurrency: 5)
        let duration = Date().timeIntervalSince(start)

        // Assert: Should complete in <5s (with 5 concurrent tasks)
        // Note: On Apple Silicon M1+, each extraction ~1.7s sequential = 17s total
        // With concurrency=5: 17s / 5 ≈ 3.4s expected
        XCTAssertLessThan(duration, 5.0, "Concurrent batch should complete in <5s (actual: \(duration)s)")

        // Assert: Should extract all emails
        XCTAssertEqual(results.count, 10, "Should extract transactions from all 10 emails")

        // Assert: All extractions should have valid data
        for transaction in results {
            XCTAssertFalse(transaction.merchant.isEmpty, "Merchant should not be empty")
            XCTAssertGreaterThanOrEqual(transaction.confidence, 0.0, "Confidence should be valid")
        }
    }

    // MARK: - Test: Progress Callback

    /// Test that progress callback reports accurate counts during batch processing
    func testBatchProgressCallback() async throws {
        // Arrange: Create 5 test emails
        let testEmails = (0..<5).map { index in
            GmailEmail(
                id: "progress-\(index)",
                subject: "Progress Test \(index)",
                sender: "test@example.com",
                date: Date(),
                snippet: "Progress test $50.00"
            )
        }

        var progressUpdates: [(processed: Int, total: Int, errors: Int)] = []

        // Act: Extract with progress tracking
        _ = await IntelligentExtractionService.extractBatch(
            testEmails,
            maxConcurrency: 5
        ) { processed, total, errors in
            progressUpdates.append((processed, total, errors))
        }

        // Assert: Progress updates should occur
        XCTAssertGreaterThan(progressUpdates.count, 0, "Should have progress updates")

        // Assert: Final progress should be complete
        if let final = progressUpdates.last {
            XCTAssertEqual(final.processed, 5, "Final processed count should be 5")
            XCTAssertEqual(final.total, 5, "Total should remain 5")
        }

        // Assert: Progress should be monotonically increasing
        for i in 1..<progressUpdates.count {
            XCTAssertGreaterThanOrEqual(
                progressUpdates[i].processed,
                progressUpdates[i-1].processed,
                "Processed count should never decrease"
            )
        }
    }

    // MARK: - Test: Error Handling

    /// Test that batch extraction handles errors gracefully and continues processing
    func testBatchErrorHandling() async throws {
        // Arrange: Mix of valid and potentially problematic emails
        let testEmails = [
            GmailEmail(id: "1", subject: "Valid", sender: "valid@test.com", date: Date(), snippet: "$100.00"),
            GmailEmail(id: "2", subject: "No Amount", sender: "test@example.com", date: Date(), snippet: "No money here"),
            GmailEmail(id: "3", subject: "Valid", sender: "another@test.com", date: Date(), snippet: "$200.00"),
            GmailEmail(id: "4", subject: "Malformed", sender: "malformed-no-at-sign", date: Date(), snippet: "$50.00"),
            GmailEmail(id: "5", subject: "Valid", sender: "last@test.com", date: Date(), snippet: "$300.00")
        ]

        var finalErrorCount = 0

        // Act: Extract batch with error tracking
        let results = await IntelligentExtractionService.extractBatch(
            testEmails,
            maxConcurrency: 5
        ) { processed, total, errors in
            finalErrorCount = errors
        }

        // Assert: Should still return results (even if some failed)
        XCTAssertGreaterThan(results.count, 0, "Should extract some transactions despite errors")

        // Assert: Should process all emails (success or manual review)
        XCTAssertLessThanOrEqual(results.count, 5, "Should not create more transactions than emails")

        // Note: Malformed emails should route to manual review tier, not crash
        // This tests resilience, not perfection
    }

    // MARK: - Test: Concurrent Safety

    /// Test that concurrent extraction doesn't cause data races or corruption
    func testConcurrentSafety() async throws {
        // Arrange: Create 20 emails to stress-test concurrency
        let testEmails = (0..<20).map { index in
            GmailEmail(
                id: "safety-\(index)",
                subject: "Concurrent Test \(index)",
                sender: "test\(index)@example.com",
                date: Date(),
                snippet: "Test $\(index * 10).00"
            )
        }

        // Act: Extract with high concurrency
        let results = await IntelligentExtractionService.extractBatch(testEmails, maxConcurrency: 5)

        // Assert: All IDs should be unique (no duplicates from race conditions)
        let uniqueIDs = Set(results.map { $0.id })
        XCTAssertEqual(uniqueIDs.count, results.count, "All transaction IDs should be unique")

        // Assert: Results should match input count
        XCTAssertEqual(results.count, 20, "Should process all 20 emails")
    }

    // MARK: - Test: Max Concurrency Enforcement

    /// Test that maxConcurrency parameter is respected
    func testMaxConcurrencyEnforcement() async throws {
        // Arrange: Create enough emails to test concurrency limits
        let testEmails = (0..<10).map { index in
            GmailEmail(
                id: "concurrency-\(index)",
                subject: "Concurrency Test \(index)",
                sender: "test@example.com",
                date: Date(),
                snippet: "Test $100.00"
            )
        }

        // Act: Extract with maxConcurrency=2 (lower than default 5)
        let start = Date()
        let results = await IntelligentExtractionService.extractBatch(testEmails, maxConcurrency: 2)
        let duration = Date().timeIntervalSince(start)

        // Assert: With maxConcurrency=2, should take longer than maxConcurrency=5
        // Expected: ~8-10s (vs ~3-5s with maxConcurrency=5)
        // This is a rough heuristic, not a precise measurement
        XCTAssertGreaterThan(duration, 3.0, "Lower concurrency should take longer")

        // Assert: Should still extract all emails
        XCTAssertEqual(results.count, 10, "Should extract all 10 emails")
    }
}
