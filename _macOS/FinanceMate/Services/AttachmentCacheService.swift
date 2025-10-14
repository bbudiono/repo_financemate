import Foundation

/// Service for caching Gmail attachments
/// Handles both small (UserDefaults) and large (FileManager) attachments
class AttachmentCacheService {
    static let shared = AttachmentCacheService()
    private init() {}

    /// Cache attachment data
    /// - Parameters:
    ///   - data: Raw attachment data
    ///   - messageId: Gmail message ID
    ///   - filename: Attachment filename
    func cache(_ data: Data, for messageId: String, filename: String) {
        let cacheKey = "attachment-\(messageId)-\(filename)"

        if data.count < 1_000_000 {  // 1MB limit
            UserDefaults.standard.set(data, forKey: cacheKey)
        } else {
            let tempDir = FileManager.default.temporaryDirectory
            let fileURL = tempDir.appendingPathComponent(cacheKey)

            do {
                try data.write(to: fileURL)
                UserDefaults.standard.set(fileURL.path, forKey: "\(cacheKey)-path")
            } catch {
                print("Failed to cache large attachment: \(error)")
            }
        }
    }

    /// Retrieve cached attachment data
    /// - Parameters:
    ///   - messageId: Gmail message ID
    ///   - filename: Attachment filename
    /// - Returns: Cached attachment data, or nil if not cached
    func get(for messageId: String, filename: String) -> Data? {
        let cacheKey = "attachment-\(messageId)-\(filename)"

        if let data = UserDefaults.standard.data(forKey: cacheKey) {
            return data
        }

        if let filePath = UserDefaults.standard.string(forKey: "\(cacheKey)-path") {
            return try? Data(contentsOf: URL(fileURLWithPath: filePath))
        }

        return nil
    }

    /// Clear cached attachments older than specified age
    /// - Parameter maxAge: Maximum age in seconds (default: 24 hours)
    func clearOld(maxAge: TimeInterval = 86400) {
        let cacheKeys = UserDefaults.standard.dictionaryRepresentation().keys.filter {
            $0.hasPrefix("attachment-")
        }

        for key in cacheKeys {
            UserDefaults.standard.removeObject(forKey: key)

            if let filePath = UserDefaults.standard.string(forKey: "\(key)-path") {
                try? FileManager.default.removeItem(at: URL(fileURLWithPath: filePath))
                UserDefaults.standard.removeObject(forKey: "\(key)-path")
            }
        }
    }
}
