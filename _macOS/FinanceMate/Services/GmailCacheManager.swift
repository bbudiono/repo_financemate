import Foundation

/// Enhanced Gmail cache manager with expiration and invalidation support
/// Handles email cache operations with proper lifecycle management
class GmailCacheManager {
    static let shared = GmailCacheManager()

    private let cacheExpirationTime: TimeInterval = 1800 // 30 minutes
    private let cacheKey = "GmailEmailCache"
    private let timestampKey = "GmailCacheTimestamp"

    private init() {}

    /// Load cached emails if available and not expired
    /// - Returns: Array of cached emails or nil if cache miss/expired
    func load() -> [GmailEmail]? {
        guard let cachedData = UserDefaults.standard.data(forKey: cacheKey),
              let emails = try? JSONDecoder().decode([GmailEmail].self, from: cachedData),
              !isCacheExpired() else {
            return nil
        }
        return emails
    }

    /// Save emails to cache with current timestamp
    /// - Parameter emails: Array of emails to cache
    func save(emails: [GmailEmail]) {
        guard let encodedData = try? JSONEncoder().encode(emails) else { return }
        UserDefaults.standard.set(encodedData, forKey: cacheKey)
        UserDefaults.standard.set(Date(), forKey: timestampKey)
    }

    /// Check if cache exists and is valid (not expired)
    /// - Returns: True if cache is available and not expired
    func isValid() -> Bool {
        return load() != nil
    }

    /// Clear the email cache completely
    func clear() {
        UserDefaults.standard.removeObject(forKey: cacheKey)
        UserDefaults.standard.removeObject(forKey: timestampKey)
    }

    /// Invalidate cache (clear current data)
    func invalidate() {
        clear()
    }

    // MARK: - Private Methods

    /// Check if cache has expired based on timestamp
    /// - Returns: True if cache is expired
    private func isCacheExpired() -> Bool {
        guard let timestamp = UserDefaults.standard.object(forKey: timestampKey) as? Date else {
            return true // No timestamp means expired
        }

        let timeSinceCache = Date().timeIntervalSince(timestamp)
        return timeSinceCache > cacheExpirationTime
    }
}

/// Extension to provide backward compatibility
extension EmailCacheService {
    /// Invalidate cache using the enhanced cache manager
    func invalidateCache() {
        GmailCacheManager.shared.invalidate()
    }

    /// Check if cache is valid
    func isCacheValid() -> Bool {
        return GmailCacheManager.shared.isValid()
    }

    /// Clear cache
    func clearCache() {
        GmailCacheManager.shared.clear()
    }
}