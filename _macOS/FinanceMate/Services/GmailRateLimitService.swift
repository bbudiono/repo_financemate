import Foundation

/// Gmail API rate limiting service
/// Manages API call quotas and prevents exceeding rate limits
class GmailRateLimitService {
    static let shared = GmailRateLimitService()

    // Gmail API rate limits (as per Google documentation)
    private let maxCallsPerMinute = 100
    private let maxCallsPerSecond = 10
    private let maxCallsPer100Seconds = 100

    private var callTimestamps: [Date] = []
    private let synchronizationQueue = DispatchQueue(label: "com.financemate.ratelimit", qos: .userInitiated)

    private init() {}

    /// Check if an API call should be allowed based on rate limits
    /// - Returns: True if call is allowed, false otherwise
    func shouldAllowCall() -> Bool {
        return synchronizationQueue.sync {
            let now = Date()
            cleanupOldTimestamps(now: now)

            // Check per-second limit (most restrictive)
            let recentCalls = callTimestamps.filter { now.timeIntervalSince($0) < 1.0 }
            if recentCalls.count >= maxCallsPerSecond {
                return false
            }

            // Check per-minute limit
            let oneMinuteAgo = now.addingTimeInterval(-60)
            let minuteCalls = callTimestamps.filter { $0 >= oneMinuteAgo }
            if minuteCalls.count >= maxCallsPerMinute {
                return false
            }

            // Check per-100-second limit
            let hundredSecondsAgo = now.addingTimeInterval(-100)
            let hundredSecondCalls = callTimestamps.filter { $0 >= hundredSecondsAgo }
            if hundredSecondCalls.count >= maxCallsPer100Seconds {
                return false
            }

            // Allow the call and record timestamp
            callTimestamps.append(now)
            return true
        }
    }

    /// Get the time to wait before next allowed call
    /// - Returns: Seconds to wait, or 0 if call is allowed now
    func getTimeToNextCall() -> TimeInterval {
        return synchronizationQueue.sync {
            let now = Date()
            cleanupOldTimestamps(now: now)

            // Check each rate limit
            let oneSecondAgo = now.addingTimeInterval(-1.0)
            let recentCalls = callTimestamps.filter { $0 >= oneSecondAgo }
            if recentCalls.count >= maxCallsPerSecond {
                return 1.0 - now.timeIntervalSince(recentCalls.first ?? now)
            }

            let oneMinuteAgo = now.addingTimeInterval(-60)
            let minuteCalls = callTimestamps.filter { $0 >= oneMinuteAgo }
            if minuteCalls.count >= maxCallsPerMinute {
                return 60.0 - now.timeIntervalSince(minuteCalls.first ?? now)
            }

            let hundredSecondsAgo = now.addingTimeInterval(-100)
            let hundredSecondCalls = callTimestamps.filter { $0 >= hundredSecondsAgo }
            if hundredSecondCalls.count >= maxCallsPer100Seconds {
                return 100.0 - now.timeIntervalSince(hundredSecondCalls.first ?? now)
            }

            return 0.0
        }
    }

    /// Reset rate limiting counters
    func reset() {
        synchronizationQueue.sync {
            callTimestamps.removeAll()
        }
    }

    /// Get current rate limit status
    /// - Returns: Dictionary with rate limit information
    func getRateLimitStatus() -> [String: Any] {
        return synchronizationQueue.sync {
            let now = Date()
            cleanupOldTimestamps(now: now)

            let oneSecondAgo = now.addingTimeInterval(-1.0)
            let oneMinuteAgo = now.addingTimeInterval(-60)
            let hundredSecondsAgo = now.addingTimeInterval(-100)

            return [
                "calls_per_second": callTimestamps.filter { $0 >= oneSecondAgo }.count,
                "calls_per_minute": callTimestamps.filter { $0 >= oneMinuteAgo }.count,
                "calls_per_100_seconds": callTimestamps.filter { $0 >= hundredSecondsAgo }.count,
                "max_per_second": maxCallsPerSecond,
                "max_per_minute": maxCallsPerMinute,
                "max_per_100_seconds": maxCallsPer100Seconds,
                "next_call_available": getTimeToNextCall()
            ]
        }
    }

    // MARK: - Private Methods

    /// Clean up old timestamps that are no longer relevant
    private func cleanupOldTimestamps(now: Date) {
        let hundredSecondsAgo = now.addingTimeInterval(-100)
        callTimestamps.removeAll { $0 < hundredSecondsAgo }
    }
}

/// Enhanced Gmail API error with rate limit support
extension GmailAPIError {
    static let rateLimitExceeded = GmailAPIError.invalidURL("Gmail API rate limit exceeded. Please try again later.")
    static let quotaExceeded = GmailAPIError.invalidURL("Gmail API quota exceeded. Please try again later.")
}