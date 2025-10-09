import XCTest
import Foundation
@testable import FinanceMate

/// Test suite for Gmail rate limiting performance
/// Focuses on API quota compliance and rate limiting behavior
class GmailRateLimitTests: XCTestCase {

    // MARK: - RED PHASE: Rate Limit Tests

    /// RED PHASE TEST: Rate limiting - should fail initially
    func testGmailRateLimit_RespectsApiQuotas_FailsWhenExceeded() async throws {
        let mockRateLimiter = MockRateLimiter()
        let rateLimitedService = GmailAPIServiceWithRateLimit(rateLimiter: mockRateLimiter)

        var apiCallCount = 0
        var rateLimitHit = false

        for i in 1...10 {
            do {
                _ = try await rateLimitedService.fetchEmails(maxResults: 50)
                apiCallCount += 1
            } catch {
                if error.localizedDescription.contains("rate limit") {
                    rateLimitHit = true
                    break
                }
            }
        }

        // EXPECTED FAILURE: Rate limiting not implemented
        XCTAssertTrue(rateLimitHit, "RED FAILURE: Rate limiting should trigger")
        XCTAssertLessThanOrEqual(apiCallCount, 4, "RED FAILURE: Should limit API calls")
    }
}

// MARK: - Mock Classes for RED Phase Testing

/// Mock rate limiter for testing rate limiting behavior
class MockRateLimiter {
    private var callTimestamps: [Date] = []
    private let maxCallsPerMinute = 4

    func shouldAllowCall() -> Bool {
        let now = Date()
        let oneMinuteAgo = now.addingTimeInterval(-60)
        callTimestamps.removeAll { $0 < oneMinuteAgo }

        if callTimestamps.count < maxCallsPerMinute {
            callTimestamps.append(now)
            return true
        }
        return false
    }

    func reset() {
        callTimestamps.removeAll()
    }
}

/// Enhanced GmailAPIService with rate limiting for testing
class GmailAPIServiceWithRateLimit {
    private let rateLimiter: MockRateLimiter

    init(rateLimiter: MockRateLimiter) {
        self.rateLimiter = rateLimiter
    }

    func fetchEmails(maxResults: Int = 500) async throws -> [GmailEmail] {
        guard rateLimiter.shouldAllowCall() else {
            throw GmailAPIError.rateLimitExceeded
        }
        return try await GmailAPI.fetchEmails(accessToken: "mock_token", maxResults: maxResults)
    }
}

extension GmailAPIError {
    static let rateLimitExceeded = GmailAPIError.invalidURL("Rate limit exceeded")
}