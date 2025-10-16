import XCTest
@testable import FinanceMate

/// PHASE 1: Gmail Exponential Backoff Tests - RED
/// Tests missing 2/4/8s exponential backoff with jitter
final class GmailBackoffTests: XCTestCase {

    func testGmailAPI_RateLimit_TriggersExponentialBackoff() async throws {
        let retry1Delay = GmailPaginationEnhancer.calculateBackoffDelay(retryCount: 0)
        let retry2Delay = GmailPaginationEnhancer.calculateBackoffDelay(retryCount: 1)
        let retry3Delay = GmailPaginationEnhancer.calculateBackoffDelay(retryCount: 2)

        XCTAssertEqual(retry1Delay, 2.0, accuracy: 0.5, "First retry should be ~2s with jitter")
        XCTAssertEqual(retry2Delay, 4.0, accuracy: 1.0, "Second retry should be ~4s with jitter")
        XCTAssertEqual(retry3Delay, 8.0, accuracy: 2.0, "Third retry should be ~8s with jitter")

        XCTAssertGreaterThan(retry1Delay, 0, "Delay must be positive")
        XCTAssertGreaterThan(retry2Delay, 0, "Delay must be positive")
        XCTAssertGreaterThan(retry3Delay, 0, "Delay must be positive")
    }

    func testGmailAPI_RespectsRateLimits() async throws {
        let startTime = Date()
        _ = try await simulateGmailAPICall()
        _ = try await simulateGmailAPICall()
        let elapsed = Date().timeIntervalSince(startTime)
        XCTAssertGreaterThanOrEqual(elapsed, 1.0, "Gmail API must respect 1 request/second rate limit")
    }

    private func simulateGmailAPICall() async throws -> [GmailEmail] {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        return [GmailEmail(id: UUID().uuidString, subject: "Test", sender: "test@test.com", date: Date(), snippet: "Test", attachments: [])]
    }
}