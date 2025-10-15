import Foundation

/// Service for managing Gmail email cache operations
/// Handles loading, saving, and expiry of cached email data
class EmailCacheService {
    private let cacheManager = EmailCacheManager.self

    /// Load cached emails if available and not expired
    /// - Returns: Array of cached emails or nil if cache miss/expired
    func loadCachedEmails() -> [GmailEmail]? {
        return cacheManager.load()
    }

    /// Save emails to cache with current timestamp
    /// - Parameter emails: Array of emails to cache
    func saveEmailsToCache(_ emails: [GmailEmail]) {
        cacheManager.save(emails: emails)
    }

    /// Check if cache exists and is valid
    /// - Returns: True if cache is available and not expired
    func isCacheValid() -> Bool {
        return cacheManager.load() != nil
    }

    /// Clear the email cache
    func clearCache() {
        cacheManager.clear()
    }

    /// Invalidate the email cache (alias for clearCache)
    func invalidateCache() {
        cacheManager.invalidate()
    }

    // MARK: - Attachment Caching (Delegates to AttachmentCacheService)

    /// Cache attachment data
    func cacheAttachment(_ data: Data, for messageId: String, filename: String) {
        AttachmentCacheService.shared.cache(data, for: messageId, filename: filename)
    }

    /// Retrieve cached attachment data
    func getCachedAttachment(for messageId: String, filename: String) -> Data? {
        return AttachmentCacheService.shared.get(for: messageId, filename: filename)
    }

    /// Clear cached attachments older than specified age
    func clearOldAttachments(maxAge: TimeInterval = 86400) {
        AttachmentCacheService.shared.clearOld(maxAge: maxAge)
    }
}
