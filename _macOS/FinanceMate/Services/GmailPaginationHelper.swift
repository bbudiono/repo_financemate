import Foundation

actor GmailPaginationHelper {
    struct PaginationResult {
        let emails: [GmailEmail]
        let nextPageToken: String?
        let pageCount: Int
    }

    static func fetchPaginatedEmails(
        accessToken: String,
        checkpoint: CheckpointData,
        cacheService: EmailCacheService,
        gmailAPI: GmailAPIProtocol = GmailAPI.self
    ) async throws -> PaginationResult {
        var allEmails: [GmailEmail] = checkpoint.emails
        var seenEmailIds: Set<String> = Set(checkpoint.emails.map { $0.id })
        var currentPageToken: String? = checkpoint.pageToken
        var pageCount = checkpoint.pageCount

        let startTime = Date()
        var retryCount = 0
        let maxRetries = 3
        var backoffDelay: TimeInterval = 0.1
        let pageSize = 100 // Gmail API max per page

        while true {
            pageCount += 1

            do {
                let result = try await gmailAPI.fetchEmails(
                    accessToken: accessToken,
                    maxResults: pageSize,
                    pageToken: currentPageToken
                )

                guard !result.emails.isEmpty else { break }

                let uniqueNewEmails = result.emails.filter { email in
                    !seenEmailIds.contains(email.id)
                }

                for email in uniqueNewEmails {
                    seenEmailIds.insert(email.id)
                    allEmails.append(email)
                }

                currentPageToken = result.nextPageToken

                // Check if we should continue pagination
                if currentPageToken == nil { break }

                // Simple exponential backoff with jitter
                retryCount = 0
                let jitter = Double.random(in: 0.8...1.2)
                let delay = backoffDelay * jitter
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))

                // Gradually increase backoff
                if pageCount % 5 == 0 {
                    backoffDelay = min(backoffDelay * 1.2, 1.0)
                }

            } catch {
                if retryCount < maxRetries {
                    retryCount += 1
                    let exponentialDelay = backoffDelay * pow(2.0, Double(retryCount - 1))
                    let jitterDelay = exponentialDelay * Double.random(in: 0.8...1.2)

                    try await Task.sleep(nanoseconds: UInt64(jitterDelay * 1_000_000_000))
                    continue
                } else {
                    throw error
                }
            }
        }

        return PaginationResult(
            emails: allEmails,
            nextPageToken: currentPageToken,
            pageCount: pageCount
        )
    }
}