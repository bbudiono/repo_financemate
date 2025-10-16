import Foundation

struct CheckpointData {
    let emails: [GmailEmail]
    let pageToken: String?
    let pageCount: Int
    let emailCount: Int
}

struct GmailSyncCheckpointManager {
    private static let checkpointKey = "gmail_sync_checkpoint"
    private let cacheService: EmailCacheService

    init(cacheService: EmailCacheService) {
        self.cacheService = cacheService
    }

    func saveCheckpoint(
        emails: [GmailEmail],
        pageToken: String?,
        pageCount: Int
    ) {
        let checkpoint: [String: Any] = [
            "pageToken": pageToken ?? "",
            "pageCount": pageCount,
            "emailCount": emails.count,
            "timestamp": Date().timeIntervalSince1970
        ]
        UserDefaults.standard.set(checkpoint, forKey: Self.checkpointKey)

        // Save emails to cache for resume
        cacheService.saveEmailsToCache(emails)

        NSLog("[CHECKPOINT] Saved: %d emails, page %d, token: %@", emails.count, pageCount, pageToken ?? "nil")
    }

    func loadCheckpoint() -> CheckpointData {
        guard let checkpoint = UserDefaults.standard.dictionary(forKey: Self.checkpointKey),
              let pageCount = checkpoint["pageCount"] as? Int,
              let emailCount = checkpoint["emailCount"] as? Int,
              let timestamp = checkpoint["timestamp"] as? TimeInterval else {
            return CheckpointData(
                emails: [],
                pageToken: nil,
                pageCount: 0,
                emailCount: 0
            )
        }

        // Only resume if checkpoint is less than 1 hour old
        let age = Date().timeIntervalSince1970 - timestamp
        guard age < 3600 else {
            NSLog("[CHECKPOINT] Checkpoint too old (%.0f seconds), starting fresh", age)
            clearCheckpoint()
            return CheckpointData(
                emails: [],
                pageToken: nil,
                pageCount: 0,
                emailCount: 0
            )
        }

        let pageToken = checkpoint["pageToken"] as? String
        let cachedEmails = cacheService.loadCachedEmails() ?? []

        NSLog("[CHECKPOINT] Loaded: %d emails, page %d, age: %.0fs", cachedEmails.count, pageCount, age)

        return CheckpointData(
            emails: cachedEmails,
            pageToken: pageToken?.isEmpty == true ? nil : pageToken,
            pageCount: pageCount,
            emailCount: emailCount
        )
    }

    func clearCheckpoint() {
        UserDefaults.standard.removeObject(forKey: Self.checkpointKey)
        NSLog("[CHECKPOINT] Cleared")
    }
}