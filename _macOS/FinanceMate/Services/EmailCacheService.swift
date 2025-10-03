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
        // Future implementation if needed
        // EmailCacheManager doesn't expose clear() yet
    }
}
