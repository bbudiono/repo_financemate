// SANDBOX FILE: For testing/development. See .cursorrules.

//
//  KeychainManager.swift
//  FinanceMate-Sandbox
//
//  Created by Assistant on 6/2/25.
//

/*
* Purpose: Secure keychain management for user credentials and sensitive data in Sandbox environment
* Issues & Complexity Summary: Secure credential storage using macOS Keychain Services
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~250
  - Core Algorithm Complexity: Medium
  - Dependencies: 3 New (KeychainServices, SecureCoding, ErrorHandling)
  - State Management Complexity: Low
  - Novelty/Uncertainty Factor: Low
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 70%
* Problem Estimate (Inherent Problem Difficulty %): 65%
* Initial Code Complexity Estimate %: 68%
* Justification for Estimates: Standard keychain implementation with proper error handling
* Final Code Complexity (Actual %): TBD - Implementation in progress
* Overall Result Score (Success & Quality %): TBD - TDD development
* Key Variances/Learnings: Robust keychain security implementation for authentication data
* Last Updated: 2025-06-02
*/

import Foundation
import Security

// MARK: - Keychain Manager

public class KeychainManager {
    
    // MARK: - Private Properties
    
    private let serviceName = "com.ablankcanvas.financemate.sandbox"
    private let accessGroup: String? = nil // Use default access group for sandbox
    
    // MARK: - Initialization
    
    public init() {}
    
    // MARK: - Generic Keychain Operations
    
    public func save(_ data: Data, for key: String) throws {
        // Delete any existing item first
        delete(for: key)
        
        var query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: serviceName,
            kSecAttrAccount: key,
            kSecValueData: data,
            kSecAttrAccessible: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup] = accessGroup
        }
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            throw KeychainError.saveFailed(status)
        }
    }
    
    public func retrieve(for key: String) -> Data? {
        var query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: serviceName,
            kSecAttrAccount: key,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ]
        
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup] = accessGroup
        }
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data else {
            return nil
        }
        
        return data
    }
    
    public func delete(for key: String) {
        var query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: serviceName,
            kSecAttrAccount: key
        ]
        
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup] = accessGroup
        }
        
        SecItemDelete(query as CFDictionary)
    }
    
    public func exists(for key: String) -> Bool {
        return retrieve(for: key) != nil
    }
    
    // MARK: - User Credentials Methods
    
    public func saveUserCredentials(_ user: AuthenticatedUser) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        let userData = try encoder.encode(user)
        try save(userData, for: userCredentialsKey)
    }
    
    public func retrieveUserCredentials() -> AuthenticatedUser? {
        guard let userData = retrieve(for: userCredentialsKey) else {
            return nil
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            return try decoder.decode(AuthenticatedUser.self, from: userData)
        } catch {
            print("Failed to decode user credentials: \(error)")
            return nil
        }
    }
    
    public func clearUserCredentials() {
        delete(for: userCredentialsKey)
    }
    
    // MARK: - Secure String Storage
    
    public func saveSecureString(_ string: String, for key: String) throws {
        guard let data = string.data(using: .utf8) else {
            throw KeychainError.invalidData
        }
        try save(data, for: key)
    }
    
    public func retrieveSecureString(for key: String) -> String? {
        guard let data = retrieve(for: key),
              let string = String(data: data, encoding: .utf8) else {
            return nil
        }
        return string
    }
    
    // MARK: - Biometric Storage (if available)
    
    public func saveBiometricProtected(_ data: Data, for key: String) throws {
        delete(for: key)
        
        var query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: serviceName,
            kSecAttrAccount: key,
            kSecValueData: data,
            kSecAttrAccessControl: createBiometricAccessControl()
        ]
        
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup] = accessGroup
        }
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            throw KeychainError.saveFailed(status)
        }
    }
    
    public func retrieveBiometricProtected(for key: String) async throws -> Data? {
        var query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: serviceName,
            kSecAttrAccount: key,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne,
            kSecUseOperationPrompt: "Authenticate to access your credentials"
        ]
        
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup] = accessGroup
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                var result: AnyObject?
                let status = SecItemCopyMatching(query as CFDictionary, &result)
                
                switch status {
                case errSecSuccess:
                    if let data = result as? Data {
                        continuation.resume(returning: data)
                    } else {
                        continuation.resume(throwing: KeychainError.invalidData)
                    }
                case -128: // errSecUserCancel equivalent
                    continuation.resume(throwing: KeychainError.userCancelled)
                case errSecAuthFailed:
                    continuation.resume(throwing: KeychainError.authenticationFailed)
                default:
                    continuation.resume(throwing: KeychainError.retrieveFailed(status))
                }
            }
        }
    }
    
    // MARK: - Utility Methods
    
    public func clearAllKeychainData() {
        let keysToDelete = [
            userCredentialsKey,
            "token_apple",
            "token_google",
            "user_session"
        ]
        
        for key in keysToDelete {
            delete(for: key)
        }
    }
    
    public func listStoredKeys() -> [String] {
        var query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: serviceName,
            kSecReturnAttributes: true,
            kSecMatchLimit: kSecMatchLimitAll
        ]
        
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup] = accessGroup
        }
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let items = result as? [[CFString: Any]] else {
            return []
        }
        
        return items.compactMap { item in
            item[kSecAttrAccount] as? String
        }
    }
    
    // MARK: - Private Methods
    
    private var userCredentialsKey: String {
        return "user_credentials"
    }
    
    private func createBiometricAccessControl() -> SecAccessControl {
        var error: Unmanaged<CFError>?
        
        let accessControl = SecAccessControlCreateWithFlags(
            kCFAllocatorDefault,
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            [.biometryCurrentSet],
            &error
        )
        
        if let error = error {
            print("Failed to create biometric access control: \(error.takeRetainedValue())")
            // Fallback to device passcode
            return SecAccessControlCreateWithFlags(
                kCFAllocatorDefault,
                kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                [.devicePasscode],
                nil
            )!
        }
        
        return accessControl!
    }
}

// MARK: - Keychain Error Types

public enum KeychainError: Error, LocalizedError {
    case saveFailed(OSStatus)
    case retrieveFailed(OSStatus)
    case deleteFailed(OSStatus)
    case invalidData
    case userCancelled
    case authenticationFailed
    case biometricNotAvailable
    case accessControlCreationFailed
    
    public var errorDescription: String? {
        switch self {
        case .saveFailed(let status):
            return "Failed to save to keychain (Status: \(status))"
        case .retrieveFailed(let status):
            return "Failed to retrieve from keychain (Status: \(status))"
        case .deleteFailed(let status):
            return "Failed to delete from keychain (Status: \(status))"
        case .invalidData:
            return "Invalid data format"
        case .userCancelled:
            return "User cancelled authentication"
        case .authenticationFailed:
            return "Authentication failed"
        case .biometricNotAvailable:
            return "Biometric authentication not available"
        case .accessControlCreationFailed:
            return "Failed to create access control"
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .saveFailed, .retrieveFailed, .deleteFailed:
            return "Check keychain access permissions and try again"
        case .invalidData:
            return "Verify the data format and try again"
        case .userCancelled:
            return "Authentication is required to continue"
        case .authenticationFailed:
            return "Please try authenticating again"
        case .biometricNotAvailable:
            return "Use device passcode instead"
        case .accessControlCreationFailed:
            return "Biometric authentication may not be configured"
        }
    }
}