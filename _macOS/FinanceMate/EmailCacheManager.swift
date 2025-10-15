import Foundation

/// BLUEPRINT Lines 74, 91: Email caching to reduce API calls
/// Caches Gmail emails for 1 hour to minimize API usage
struct EmailCache: Codable {
    let emails: [GmailEmail]
    let fetchedAt: Date
}

class EmailCacheManager {
    private static let cacheKey = "gmail_email_cache"
    private static let cacheExpirySeconds: TimeInterval = 3600 // 1 hour

    static func save(emails: [GmailEmail]) {
        let cache = EmailCache(emails: emails, fetchedAt: Date())
        if let data = try? JSONEncoder().encode(cache) {
            UserDefaults.standard.set(data, forKey: cacheKey)
            NSLog(" Cached %d emails", emails.count)
        }
    }

    static func load() -> [GmailEmail]? {
        guard let data = UserDefaults.standard.data(forKey: cacheKey),
              let cache = try? JSONDecoder().decode(EmailCache.self, from: data) else {
            NSLog("️ No cache found")
            return nil
        }

        let elapsed = Date().timeIntervalSince(cache.fetchedAt)
        if elapsed < cacheExpirySeconds {
            NSLog(" Cache hit: %d emails (%.1f min old)", cache.emails.count, elapsed / 60)
            return cache.emails
        } else {
            NSLog("️ Cache expired (%.1f min old)", elapsed / 60)
            return nil
        }
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: cacheKey)
        NSLog("️ Cache cleared")
    }

    /// Invalidate the current cache (alias for clear)
    static func invalidate() {
        clear()
    }
}
