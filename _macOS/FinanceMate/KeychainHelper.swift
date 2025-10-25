import Foundation
import Security

/// Secure storage helper for OAuth tokens and sensitive data
/// Uses macOS Keychain for secure, encrypted persistence
struct KeychainHelper {
    /// Keychain service identifier for FinanceMate
    private static let service = "com.ablankcanvas.FinanceMate"

    /// Retrieve value from Keychain
    /// - Parameter account: Account identifier (e.g., "gmail_access_token")
    /// - Returns: Stored value or nil if not found
    static func get(account: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecMatchLimit as String: kSecMatchLimitOne,  // Return single item only
            kSecReturnData as String: true
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }

        return value
    }

    static func save(value: String, account: String) {
        guard let data = value.data(using: .utf8) else {
            NSLog("❌ KeychainHelper.save FAILED: Could not encode value for account: \(account)")
            return
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        // Delete existing item (ignore if not found)
        let deleteStatus = SecItemDelete(query as CFDictionary)
        if deleteStatus == errSecSuccess {
            NSLog("🗑️  Deleted existing Keychain item: \(account)")
        }

        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly  // BLUEPRINT Line 229
        ]

        let addStatus = SecItemAdd(addQuery as CFDictionary, nil)
        if addStatus == errSecSuccess {
            NSLog("✅ KeychainHelper.save SUCCESS: \(account)")
        } else {
            NSLog("❌ KeychainHelper.save FAILED: \(account) - Status: \(addStatus)")
        }
    }

    static func delete(account: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw NSError(domain: "Keychain", code: Int(status))
        }
    }
}
