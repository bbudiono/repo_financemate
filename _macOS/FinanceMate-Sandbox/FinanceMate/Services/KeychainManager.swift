//
//  KeychainManager.swift
//  FinanceMate
//
//  Purpose: Secure credential storage using macOS Keychain Services
//  Security Level: Production-grade with audit compliance

import CryptoKit
import Foundation
import IOKit
import Security

@MainActor
public final class KeychainManager {
    public static let shared = KeychainManager()

    private let serviceName = "com.ablankcanvas.FinanceMate"
    private let accessGroup = "com.ablankcanvas.shared"

    // Encryption key for additional security layer
    private var encryptionKey: SymmetricKey {
        // Derive key from device-specific data
        let deviceID = getDeviceIdentifier()
        let keyData = SHA256.hash(data: deviceID.data(using: .utf8)!)
        return SymmetricKey(data: keyData)
    }

    private init() {}

    // MARK: - Public Methods

    /// Store sensitive data in keychain with encryption
    public func store(key: String, value: String, requiresBiometric: Bool = false) throws {
        let encryptedData = try encrypt(value)

        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecValueData as String: encryptedData,
            kSecAttrAccessGroup as String: accessGroup
        ]

        if requiresBiometric {
            query[kSecAttrAccessControl as String] = try createBiometricAccessControl()
        }

        // Delete existing item if present
        SecItemDelete(query as CFDictionary)

        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)

        if status != errSecSuccess {
            throw KeychainError.unableToStore(status: status)
        }

        // Audit log
        SecurityAuditLogger.shared.log(event: .keychainStore(key: key, requiresBiometric: requiresBiometric))
    }

    /// Retrieve and decrypt data from keychain
    public func retrieve(key: String) throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecAttrAccessGroup as String: accessGroup,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data else {
            throw KeychainError.itemNotFound
        }

        let decryptedValue = try decrypt(data)

        // Audit log
        SecurityAuditLogger.shared.log(event: .keychainRetrieve(key: key))

        return decryptedValue
    }

    /// Delete item from keychain
    public func delete(key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecAttrAccessGroup as String: accessGroup
        ]

        let status = SecItemDelete(query as CFDictionary)

        if status != errSecSuccess && status != errSecItemNotFound {
            throw KeychainError.unableToDelete(status: status)
        }

        // Audit log
        SecurityAuditLogger.shared.log(event: .keychainDelete(key: key))
    }

    /// Clear all stored credentials
    public func clearAll() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccessGroup as String: accessGroup
        ]

        let status = SecItemDelete(query as CFDictionary)

        if status != errSecSuccess && status != errSecItemNotFound {
            throw KeychainError.unableToDelete(status: status)
        }

        // Audit log
        SecurityAuditLogger.shared.log(event: .keychainClearAll)
    }

    // MARK: - OAuth Token Storage

    public func storeOAuthTokens(_ tokens: OAuthTokens) throws {
        let tokenData = try JSONEncoder().encode(tokens)
        let tokenString = tokenData.base64EncodedString()
        try store(key: "oauth_tokens", value: tokenString, requiresBiometric: true)
    }

    public func retrieveOAuthTokens() throws -> OAuthTokens {
        let tokenString = try retrieve(key: "oauth_tokens")
        guard let tokenData = Data(base64Encoded: tokenString) else {
            throw KeychainError.invalidData
        }
        return try JSONDecoder().decode(OAuthTokens.self, from: tokenData)
    }

    // MARK: - Session Token Storage

    public func storeSessionToken(_ token: String, expiresAt: Date) throws {
        let session = SessionToken(token: token, expiresAt: expiresAt)
        let sessionData = try JSONEncoder().encode(session)
        let sessionString = sessionData.base64EncodedString()
        try store(key: "session_token", value: sessionString)
    }

    public func retrieveSessionToken() throws -> SessionToken {
        let sessionString = try retrieve(key: "session_token")
        guard let sessionData = Data(base64Encoded: sessionString) else {
            throw KeychainError.invalidData
        }
        let session = try JSONDecoder().decode(SessionToken.self, from: sessionData)

        // Check if expired
        if session.expiresAt < Date() {
            try delete(key: "session_token")
            throw KeychainError.tokenExpired
        }

        return session
    }

    // MARK: - Private Methods

    private func encrypt(_ value: String) throws -> Data {
        guard let data = value.data(using: .utf8) else {
            throw KeychainError.invalidData
        }

        let sealedBox = try AES.GCM.seal(data, using: encryptionKey)
        guard let encryptedData = sealedBox.combined else {
            throw KeychainError.encryptionFailed
        }

        return encryptedData
    }

    private func decrypt(_ data: Data) throws -> String {
        let sealedBox = try AES.GCM.SealedBox(combined: data)
        let decryptedData = try AES.GCM.open(sealedBox, using: encryptionKey)

        guard let value = String(data: decryptedData, encoding: .utf8) else {
            throw KeychainError.decryptionFailed
        }

        return value
    }

    private func createBiometricAccessControl() throws -> SecAccessControl {
        var error: Unmanaged<CFError>?

        guard let accessControl = SecAccessControlCreateWithFlags(
            kCFAllocatorDefault,
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            [.biometryCurrentSet, .privateKeyUsage],
            &error
        ) else {
            throw KeychainError.accessControlCreationFailed
        }

        return accessControl
    }

    private func getDeviceIdentifier() -> String {
        // Get hardware UUID for device-specific encryption
        let service = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching("IOPlatformExpertDevice"))

        var serialNumber = "default-device-id"
        if let serialNumberAsCFString = IORegistryEntryCreateCFProperty(
            service,
            kIOPlatformSerialNumberKey as CFString,
            kCFAllocatorDefault,
            0
        ) {
            serialNumber = serialNumberAsCFString.takeUnretainedValue() as? String ?? serialNumber
        }

        IOObjectRelease(service)
        return serialNumber
    }
}

// MARK: - Supporting Types
// OAuthTokens and SessionToken are now defined in CommonTypes.swift

public enum KeychainError: LocalizedError {
    case itemNotFound
    case duplicateItem
    case invalidData
    case unableToStore(status: OSStatus)
    case unableToDelete(status: OSStatus)
    case encryptionFailed
    case decryptionFailed
    case accessControlCreationFailed
    case tokenExpired

    public var errorDescription: String? {
        switch self {
        case .itemNotFound:
            return "The requested item was not found in the keychain"
        case .duplicateItem:
            return "An item with this key already exists"
        case .invalidData:
            return "The data is invalid or corrupted"
        case .unableToStore(let status):
            return "Unable to store item in keychain: \(status)"
        case .unableToDelete(let status):
            return "Unable to delete item from keychain: \(status)"
        case .encryptionFailed:
            return "Failed to encrypt data"
        case .decryptionFailed:
            return "Failed to decrypt data"
        case .accessControlCreationFailed:
            return "Failed to create biometric access control"
        case .tokenExpired:
            return "The token has expired"
        }
    }
}
