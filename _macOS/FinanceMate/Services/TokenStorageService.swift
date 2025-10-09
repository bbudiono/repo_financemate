import Foundation
import Security
import os.log

// Import auth types from AuthTypes.swift
// These types are available in the same module

/**
 * Purpose: Secure storage service for authentication tokens and credentials
 * Issues & Complexity Summary: Keychain-based secure storage following KISS principles
 * Key Complexity Drivers:
 * - Logic Scope (Est. LoC): ~200
 * - Core Algorithm Complexity: Medium (Keychain API integration)
 * - Dependencies: Foundation, Security only
 * - State Management Complexity: Low (stateless service)
 * - Novelty/Uncertainty Factor: Low (standard Keychain patterns)
 * AI Pre-Task Self-Assessment: 95%
 * Problem Estimate: 90%
 * Initial Code Complexity Estimate: 75%
 * Final Code Complexity: 78%
 * Overall Result Score: 96%
 * Key Variances/Learnings: Proper error handling and security practices
 * Last Updated: 2025-10-07
 */

/// Token storage service for managing authentication credentials
public class TokenStorageService {

    public static let shared = TokenStorageService()

    private static let logger = Logger(subsystem: "FinanceMate", category: "TokenStorageService")

    // MARK: - Storage Keys

    private struct Keys {
        static let service = "com.ablankcanvas.FinanceMate"
        static let currentProvider = "current_provider"

        // Apple Sign In
        static let appleUserID = "apple_user_id"
        static let appleUserEmail = "apple_user_email"
        static let appleUserName = "apple_user_name"
        static let appleIDToken = "apple_id_token"
        static let appleRefreshToken = "apple_refresh_token"

        // Google OAuth
        static let googleUserID = "google_user_id"
        static let googleUserEmail = "google_user_email"
        static let googleUserName = "google_user_name"
        static let googleAccessToken = "google_access_token"
        static let googleRefreshToken = "google_refresh_token"
        static let googleUserInfo = "google_user_info"
    }

    private init() {}

    // MARK: - Apple Sign In Storage

    /// Store Apple Sign In credentials
    public func storeAppleCredentials(userID: String, email: String, name: String, idToken: String?, refreshToken: String?) {
        Self.logger.info("Storing Apple Sign In credentials for user: \(email)")

        store(value: userID, key: Keys.appleUserID)
        store(value: email, key: Keys.appleUserEmail)
        store(value: name, key: Keys.appleUserName)

        if let idToken = idToken {
            store(value: idToken, key: Keys.appleIDToken)
        }

        if let refreshToken = refreshToken {
            store(value: refreshToken, key: Keys.appleRefreshToken)
        }

        // Set current provider
        store(value: AuthProvider.apple.rawValue, key: Keys.currentProvider)
    }

    /// Retrieve Apple Sign In credentials
    public func getAppleCredentials() -> AppleCredentials? {
        let userID = retrieve(key: Keys.appleUserID)
        let email = retrieve(key: Keys.appleUserEmail)
        let name = retrieve(key: Keys.appleUserName)
        let idToken = retrieve(key: Keys.appleIDToken)
        let refreshToken = retrieve(key: Keys.appleRefreshToken)

        // Return nil if no user ID is stored
        guard userID != nil else { return nil }

        return AppleCredentials(
            userID: userID,
            email: email,
            name: name,
            idToken: idToken,
            refreshToken: refreshToken
        )
    }

    // MARK: - Google OAuth Storage

    /// Store Google OAuth credentials
    public func storeGoogleCredentials(userID: String, email: String, name: String, accessToken: String, refreshToken: String?, userInfo: GoogleUserInfo?) {
        Self.logger.info("Storing Google OAuth credentials for user: \(email)")

        store(value: userID, key: Keys.googleUserID)
        store(value: email, key: Keys.googleUserEmail)
        store(value: name, key: Keys.googleUserName)
        store(value: accessToken, key: Keys.googleAccessToken)

        if let refreshToken = refreshToken {
            store(value: refreshToken, key: Keys.googleRefreshToken)
        }

        if let userInfo = userInfo,
           let userData = try? JSONEncoder().encode(userInfo) {
            storeData(data: userData, key: Keys.googleUserInfo)
        }

        // Set current provider
        store(value: AuthProvider.google.rawValue, key: Keys.currentProvider)
    }

    /// Retrieve Google OAuth credentials
    public func getGoogleCredentials() -> GoogleCredentials? {
        let userID = retrieve(key: Keys.googleUserID)
        let email = retrieve(key: Keys.googleUserEmail)
        let name = retrieve(key: Keys.googleUserName)
        let accessToken = retrieve(key: Keys.googleAccessToken)
        let refreshToken = retrieve(key: Keys.googleRefreshToken)

        var userInfo: GoogleUserInfo?
        if let userData = retrieveData(key: Keys.googleUserInfo) {
            userInfo = try? JSONDecoder().decode(GoogleUserInfo.self, from: userData)
        }

        // Return nil if no user ID is stored
        guard userID != nil else { return nil }

        return GoogleCredentials(
            userID: userID,
            email: email,
            name: name,
            accessToken: accessToken,
            refreshToken: refreshToken,
            userInfo: userInfo
        )
    }

    // MARK: - Current Provider Management

    /// Get the current authentication provider
    public func getCurrentProvider() -> AuthProvider? {
        guard let providerString = retrieve(key: Keys.currentProvider) else { return nil }
        return AuthProvider(rawValue: providerString)
    }

    /// Clear the current provider
    public func clearCurrentProvider() {
        delete(key: Keys.currentProvider)
    }

    // MARK: - Credential Management

    /// Clear all stored credentials
    public func clearAllCredentials() {
        Self.logger.info("Clearing all stored credentials")

        // Clear Apple credentials
        delete(key: Keys.appleUserID)
        delete(key: Keys.appleUserEmail)
        delete(key: Keys.appleUserName)
        delete(key: Keys.appleIDToken)
        delete(key: Keys.appleRefreshToken)

        // Clear Google credentials
        delete(key: Keys.googleUserID)
        delete(key: Keys.googleUserEmail)
        delete(key: Keys.googleUserName)
        delete(key: Keys.googleAccessToken)
        delete(key: Keys.googleRefreshToken)
        delete(key: Keys.googleUserInfo)

        // Clear current provider
        clearCurrentProvider()
    }

    /// Check if any credentials are stored
    public func hasStoredCredentials() -> Bool {
        return retrieve(key: Keys.appleUserID) != nil || retrieve(key: Keys.googleUserID) != nil
    }

    // MARK: - AuthState Management (for compatibility with AuthenticationManager)

    /// Store authentication state
    public func storeAuthState(_ authState: AuthState) {
        if let authData = try? JSONEncoder().encode(authState) {
            storeData(data: authData, key: "auth_state")
        }
    }

    /// Retrieve authentication state
    public func getAuthState() -> AuthState? {
        guard let authData = retrieveData(key: "auth_state") else { return nil }
        return try? JSONDecoder().decode(AuthState.self, from: authData)
    }

    /// Clear authentication state
    public func clearAuthState() {
        delete(key: "auth_state")
    }

    // MARK: - Token Info Management (for compatibility with AuthenticationManager)

    /// Store token information
    public func storeTokenInfo(_ tokenInfo: TokenInfo, for provider: AuthProvider) {
        if let tokenData = try? JSONEncoder().encode(tokenInfo) {
            storeData(data: tokenData, key: "token_info_\(provider.rawValue)")
        }
    }

    /// Retrieve token information
    public func getTokenInfo(for provider: AuthProvider) -> TokenInfo? {
        guard let tokenData = retrieveData(key: "token_info_\(provider.rawValue)") else { return nil }
        return try? JSONDecoder().decode(TokenInfo.self, from: tokenData)
    }

    /// Clear token information
    public func clearTokenInfo(for provider: AuthProvider) {
        delete(key: "token_info_\(provider.rawValue)")
    }

    /// Update Google access token
    public func updateGoogleAccessToken(_ accessToken: String, refreshToken: String?) {
        store(value: accessToken, key: Keys.googleAccessToken)

        if let refreshToken = refreshToken {
            store(value: refreshToken, key: Keys.googleRefreshToken)
        }
    }

    // MARK: - Data Management (for compatibility with AuthenticationManager)

    /// Clear all data
    public func clearAllData() {
        clearAllCredentials()
    }

    /// Clear data for specific provider
    public func clearData(for provider: AuthProvider) {
        switch provider {
        case .apple:
            delete(key: Keys.appleUserID)
            delete(key: Keys.appleUserEmail)
            delete(key: Keys.appleUserName)
            delete(key: Keys.appleIDToken)
            delete(key: Keys.appleRefreshToken)
            clearAuthState()
            clearTokenInfo(for: .apple)
        case .google:
            delete(key: Keys.googleUserID)
            delete(key: Keys.googleUserEmail)
            delete(key: Keys.googleUserName)
            delete(key: Keys.googleAccessToken)
            delete(key: Keys.googleRefreshToken)
            delete(key: Keys.googleUserInfo)
            clearAuthState()
            clearTokenInfo(for: .google)
        }
    }

    // MARK: - Private Keychain Methods

    private func store(value: String, key: String) {
        guard let data = value.data(using: .utf8) else {
            Self.logger.error("Failed to convert string to data for key: \(key)")
            return
        }
        storeData(data: data, key: key)
    }

    private func storeData(data: Data, key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Keys.service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]

        // Delete any existing item
        SecItemDelete(query as CFDictionary)

        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)

        if status != errSecSuccess {
            Self.logger.error("Failed to store data for key \(key): \(status)")
        }
    }

    private func retrieve(key: String) -> String? {
        guard let data = retrieveData(key: key) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }

    private func retrieveData(key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Keys.service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecSuccess, let data = result as? Data {
            return data
        }

        return nil
    }

    private func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Keys.service,
            kSecAttrAccount as String: key
        ]

        SecItemDelete(query as CFDictionary)
    }
}

// MARK: - Credential Data Structures

/// Apple Sign In credentials container
public struct AppleCredentials {
    public let userID: String?
    public let email: String?
    public let name: String?
    public let idToken: String?
    public let refreshToken: String?

    public init(userID: String?, email: String?, name: String?, idToken: String?, refreshToken: String?) {
        self.userID = userID
        self.email = email
        self.name = name
        self.idToken = idToken
        self.refreshToken = refreshToken
    }
}

/// Google OAuth credentials container
public struct GoogleCredentials {
    public let userID: String?
    public let email: String?
    public let name: String?
    public let accessToken: String?
    public let refreshToken: String?
    public let userInfo: GoogleUserInfo?

    public init(userID: String?, email: String?, name: String?, accessToken: String?, refreshToken: String?, userInfo: GoogleUserInfo?) {
        self.userID = userID
        self.email = email
        self.name = name
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.userInfo = userInfo
    }
}