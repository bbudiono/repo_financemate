import Foundation

/// Gmail API pagination service for handling large datasets efficiently
/// Manages API-level pagination with proper rate limiting and error handling
class GmailPaginationService {
    static let shared = GmailPaginationService()

    private init() {}

    /// Fetch emails with pagination support for large datasets
    /// - Parameters:
    ///   - accessToken: Gmail API access token
    ///   - pageSize: Number of emails per page (max 100 per Gmail API)
    ///   - maxResults: Maximum total emails to fetch
    /// - Returns: Array of GmailEmail objects
    /// - Throws: GmailAPIError on fetch failure
    func fetchEmailsWithPagination(accessToken: String, pageSize: Int = 100, maxResults: Int = 1500) async throws -> [GmailEmail] {
        guard !accessToken.isEmpty else {
            throw GmailAPIError.notAuthenticated
        }

        var allEmails: [GmailEmail] = []
        let actualPageSize = min(pageSize, 100) // Gmail API max is 100

        // Simple pagination - fetch multiple pages until maxResults reached
        while allEmails.count < maxResults {
            // Check rate limiting before each API call
            guard GmailRateLimitService.shared.shouldAllowCall() else {
                throw GmailAPIError.rateLimitExceeded
            }

            do {
                // Calculate how many more emails we need
                let remainingCount = maxResults - allEmails.count
                let currentPageSize = min(actualPageSize, remainingCount)

                // Fetch next batch of emails
                let emails = try await GmailAPI.fetchEmails(
                    accessToken: accessToken,
                    maxResults: currentPageSize
                )

                guard !emails.isEmpty else { break } // No more emails

                allEmails.append(contentsOf: emails)

                // Small delay between pages to respect rate limits
                if allEmails.count < maxResults {
                    try await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
                }

            } catch {
                // Handle rate limit errors with retry logic
                if case GmailAPIError.rateLimitExceeded = error {
                    let waitTime = GmailRateLimitService.shared.getTimeToNextCall()
                    if waitTime > 0 {
                        try await Task.sleep(nanoseconds: UInt64(waitTime * 1_000_000_000))
                        continue // Retry the request
                    }
                }
                throw error
            }
        }

        return Array(allEmails.prefix(maxResults))
    }
}