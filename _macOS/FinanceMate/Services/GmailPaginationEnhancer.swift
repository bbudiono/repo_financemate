import Foundation
import CommonCrypto

/// PHASE 1: Gmail Pagination Enhancement Service
/// BLUEPRINT MANDATORY: 2/4/8s exponential backoff with jitter, email ID/hash deduplication, accurate progress
struct GmailPaginationEnhancer {

    // MARK: - Exponential Backoff (2/4/8s with ±25% jitter)

    /// BLUEPRINT MANDATORY: Calculate exponential backoff delay with jitter
    /// Pattern: 2s, 4s, 8s with ±25% random jitter to prevent thundering herd
    static func calculateBackoffDelay(retryCount: Int) -> Double {
        let baseDelay = 2.0 * pow(2.0, Double(retryCount))
        let jitterPercentage = 0.25 // ±25% jitter
        let jitterAmount = baseDelay * jitterPercentage
        let jitter = Double.random(in: -jitterAmount...jitterAmount)
        return max(baseDelay + jitter, 0.5) // Minimum 0.5s delay
    }

    // MARK: - Email Deduplication (ID + content hash)

    /// BLUEPRINT MANDATORY: Remove duplicate emails by ID and content hash
    /// Returns unique emails and tracks duplicates removed
    static func deduplicateEmails(_ emails: [GmailEmail]) -> (unique: [GmailEmail], duplicatesRemoved: Int, contentHashes: Set<String>) {
        var uniqueEmails: [GmailEmail] = []
        var seenIds: Set<String> = []
        var seenHashes: Set<String> = []

        for email in emails {
            let contentHash = email.snippet.sha256()

            // Skip if same ID already seen
            if seenIds.contains(email.id) {
                continue
            }

            // Skip if same content hash already seen (duplicate content)
            if seenHashes.contains(contentHash) {
                continue
            }

            uniqueEmails.append(email)
            seenIds.insert(email.id)
            seenHashes.insert(contentHash)
        }

        let duplicatesRemoved = emails.count - uniqueEmails.count
        return (uniqueEmails, duplicatesRemoved, seenHashes)
    }

    // MARK: - Progress Tracking

    /// BLUEPRINT MANDATORY: Create accurate progress snapshot with ETA
    static func createProgressSnapshot(
        totalTarget: Int,
        processedSoFar: Int,
        currentPage: Int,
        uniqueEmails: Int,
        duplicatesFiltered: Int,
        fetchErrors: Int,
        estimatedTotal: Int,
        startTime: Date
    ) -> GmailPaginationProgress {
        let elapsed = Date().timeIntervalSince(startTime)
        let emailsPerSecond = elapsed > 0 ? Double(processedSoFar) / elapsed : 0.0
        let processedPercentage = totalTarget > 0 ? Double(processedSoFar) / Double(totalTarget) : 0.0

        let remainingEmails = max(0, estimatedTotal - processedSoFar)
        let estimatedTimeRemaining = emailsPerSecond > 0 ? Double(remainingEmails) / emailsPerSecond : nil

        return GmailPaginationProgress(
            totalTarget: totalTarget,
            processedSoFar: processedSoFar,
            currentPage: currentPage,
            uniqueEmailsFound: uniqueEmails,
            duplicatesFiltered: duplicatesFiltered,
            fetchErrors: fetchErrors,
            processedPercentage: processedPercentage,
            emailsPerSecond: emailsPerSecond,
            estimatedTimeRemaining: estimatedTimeRemaining,
            estimatedTotalAvailable: estimatedTotal,
            timestamp: Date()
        )
    }

    // MARK: - Rate Limiting

    /// BLUEPRINT MANDATORY: Enforce minimum interval between Gmail API requests
    static func enforceRateLimit(lastRequestTime: Date, minimumInterval: TimeInterval = 1.0) async {
        let elapsed = Date().timeIntervalSince(lastRequestTime)
        let waitTime = max(0, minimumInterval - elapsed)

        if waitTime > 0 {
            try? await Task.sleep(nanoseconds: UInt64(waitTime * 1_000_000_000))
        }
    }
}

// MARK: - Progress Data Structure

struct GmailPaginationProgress {
    let totalTarget: Int
    let processedSoFar: Int
    let currentPage: Int
    let uniqueEmailsFound: Int
    let duplicatesFiltered: Int
    let fetchErrors: Int
    let processedPercentage: Double
    let emailsPerSecond: Double
    let estimatedTimeRemaining: Double?
    let estimatedTotalAvailable: Int
    let timestamp: Date
}

// MARK: - String SHA256 Extension

extension String {
    func sha256() -> String {
        let data = Data(self.utf8)
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes { buffer in
            CC_SHA256(buffer.baseAddress, CC_LONG(data.count), &hash)
        }
        return hash.map { String(format: "%02x", $0) }.joined()
    }
}