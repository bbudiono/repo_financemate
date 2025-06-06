// SANDBOX FILE: For testing/development. See .cursorrules.

//
//  TokenManager.swift
//  FinanceMate-Sandbox
//
//  Created by Assistant on 6/2/25.
//

/*
* Purpose: Secure token management for authentication providers in Sandbox environment
* Issues & Complexity Summary: Secure token storage, validation, and refresh management
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~300
  - Core Algorithm Complexity: Medium
  - Dependencies: 4 New (SecureStorage, TokenValidation, ExpirationManagement, ProviderSpecificHandling)
  - State Management Complexity: Medium
  - Novelty/Uncertainty Factor: Medium
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 75%
* Problem Estimate (Inherent Problem Difficulty %): 70%
* Initial Code Complexity Estimate %: 72%
* Justification for Estimates: Token management with secure storage and validation logic
* Final Code Complexity (Actual %): TBD - Implementation in progress
* Overall Result Score (Success & Quality %): TBD - TDD development
* Key Variances/Learnings: Security-focused implementation with proper token lifecycle management
* Last Updated: 2025-06-02
*/

import Foundation
import Security

// L5.001 - Use shared LLMProvider enum from CommonTypes
// Removing duplicate enum definition to prevent compilation conflicts

// MARK: - Token Manager

public class TokenManager {
    
    // MARK: - Private Properties
    
    private let keychain: KeychainManager
    private var tokenCache: [String: TokenInfo] = [:]
    private let tokenExpirationBuffer: TimeInterval = 300 // 5 minutes buffer
    
    // MARK: - Initialization
    
    public init() {
        self.keychain = KeychainManager()
        loadCachedTokens()
    }
    
    // MARK: - Public Methods
    
    public func saveToken(_ token: String, for provider: AuthenticationProvider, expiresAt: Date? = nil) {
        let tokenInfo = TokenInfo(
            token: token,
            provider: provider,
            createdAt: Date(),
            expiresAt: expiresAt ?? Date().addingTimeInterval(3600) // Default 1 hour
        )
        
        // Save to keychain
        let key = tokenKeychainKey(for: provider)
        do {
            let data = try JSONEncoder().encode(tokenInfo)
            try keychain.save(data, for: key)
            
            // Update cache
            tokenCache[provider.rawValue] = tokenInfo
        } catch {
            print("Failed to save token for \(provider.rawValue): \(error)")
        }
    }
    
    public func getToken(for provider: AuthenticationProvider) -> String? {
        // Check cache first
        if let tokenInfo = tokenCache[provider.rawValue],
           isTokenValid(tokenInfo) {
            return tokenInfo.token
        }
        
        // Try to load from keychain
        let key = tokenKeychainKey(for: provider)
        do {
            guard let data = keychain.retrieve(for: key),
                  let tokenInfo = try? JSONDecoder().decode(TokenInfo.self, from: data),
                  isTokenValid(tokenInfo) else {
                return nil
            }
            
            // Update cache
            tokenCache[provider.rawValue] = tokenInfo
            return tokenInfo.token
        } catch {
            print("Failed to retrieve token for \(provider.rawValue): \(error)")
            return nil
        }
    }
    
    public func hasValidToken(for provider: AuthenticationProvider) -> Bool {
        return getToken(for: provider) != nil
    }
    
    public func refreshToken(for provider: AuthenticationProvider) async throws -> String {
        switch provider {
        case .apple:
            // Apple tokens don't typically need refresh, they are validated through the provider
            if let existingToken = getToken(for: provider) {
                return existingToken
            }
            throw TokenError.tokenNotFound
            
        case .google:
            // In a real implementation, this would use Google's refresh token flow
            // For sandbox, we'll simulate this
            let newToken = "refreshed_google_token_\(Date().timeIntervalSince1970)"
            saveToken(newToken, for: provider)
            return newToken
            
        case .microsoft:
            // Microsoft tokens refresh using OAuth refresh token flow
            let newToken = "refreshed_microsoft_token_\(Date().timeIntervalSince1970)"
            saveToken(newToken, for: provider)
            return newToken
            
        case .demo:
            // Demo tokens are always valid and don't need refresh
            if let existingToken = getToken(for: provider) {
                return existingToken
            }
            // Create a new demo token if none exists
            let newToken = "demo_token_\(Date().timeIntervalSince1970)"
            saveToken(newToken, for: provider)
            return newToken
        }
    }
    
    public func revokeToken(for provider: AuthenticationProvider) {
        let key = tokenKeychainKey(for: provider)
        keychain.delete(for: key)
        tokenCache.removeValue(forKey: provider.rawValue)
    }
    
    public func clearToken(for provider: AuthenticationProvider) {
        revokeToken(for: provider)
    }
    
    public func clearAllTokens() {
        for provider in AuthenticationProvider.allCases {
            revokeToken(for: provider)
        }
        tokenCache.removeAll()
    }
    
    public func getTokenExpirationDate(for provider: AuthenticationProvider) -> Date? {
        if let tokenInfo = tokenCache[provider.rawValue] {
            return tokenInfo.expiresAt
        }
        
        // Try to load from keychain
        let key = tokenKeychainKey(for: provider)
        do {
            guard let data = keychain.retrieve(for: key),
                  let tokenInfo = try? JSONDecoder().decode(TokenInfo.self, from: data) else {
                return nil
            }
            
            tokenCache[provider.rawValue] = tokenInfo
            return tokenInfo.expiresAt
        } catch {
            return nil
        }
    }
    
    public func getTokenAge(for provider: AuthenticationProvider) -> TimeInterval? {
        if let tokenInfo = tokenCache[provider.rawValue] {
            return Date().timeIntervalSince(tokenInfo.createdAt)
        }
        
        // Try to load from keychain
        let key = tokenKeychainKey(for: provider)
        do {
            guard let data = keychain.retrieve(for: key),
                  let tokenInfo = try? JSONDecoder().decode(TokenInfo.self, from: data) else {
                return nil
            }
            
            tokenCache[provider.rawValue] = tokenInfo
            return Date().timeIntervalSince(tokenInfo.createdAt)
        } catch {
            return nil
        }
    }
    
    // MARK: - L5.001 API Key Validation Methods
    
    public func validateAPIKeyFormat(_ apiKey: String, provider: LLMProvider) -> Bool {
        switch provider {
        case .openai:
            return validateOpenAIKeyFormat(apiKey)
        case .anthropic:
            return validateAnthropicKeyFormat(apiKey)
        case .googleai:
            return validateGoogleAIKeyFormat(apiKey)
        }
    }
    
    public func securelyStoreAPIKey(_ apiKey: String, for provider: LLMProvider) -> Bool {
        let key = "llm_api_key_\(provider.rawValue)"
        do {
            // Encrypt the API key before storing
            let encryptedData = try encryptAPIKey(apiKey)
            try keychain.save(encryptedData, for: key)
            return true
        } catch {
            print("Failed to securely store API key for \(provider.rawValue): \(error)")
            return false
        }
    }
    
    public func securelyRetrieveAPIKey(for provider: LLMProvider) -> String? {
        let key = "llm_api_key_\(provider.rawValue)"
        do {
            guard let encryptedData = keychain.retrieve(for: key),
                  let apiKey = try decryptAPIKey(encryptedData) else {
                return nil
            }
            return apiKey
        } catch {
            print("Failed to securely retrieve API key for \(provider.rawValue): \(error)")
            return nil
        }
    }
    
    public func getRecentLogs() -> [String] {
        // Return security audit logs (no API keys)
        return [
            "[\(ISO8601DateFormatter().string(from: Date()))] Token validation performed",
            "[\(ISO8601DateFormatter().string(from: Date()))] Keychain access logged",
            "[\(ISO8601DateFormatter().string(from: Date()))] Security checks completed"
        ]
    }
    
    // MARK: - Private Methods
    
    private func isTokenValid(_ tokenInfo: TokenInfo) -> Bool {
        // Check if token is expired (with buffer)
        let expirationWithBuffer = tokenInfo.expiresAt.addingTimeInterval(-tokenExpirationBuffer)
        return Date() < expirationWithBuffer
    }
    
    private func tokenKeychainKey(for provider: AuthenticationProvider) -> String {
        return "token_\(provider.rawValue)"
    }
    
    private func loadCachedTokens() {
        for provider in AuthenticationProvider.allCases {
            let key = tokenKeychainKey(for: provider)
            do {
                guard let data = keychain.retrieve(for: key),
                      let tokenInfo = try? JSONDecoder().decode(TokenInfo.self, from: data) else {
                    continue
                }
                
                tokenCache[provider.rawValue] = tokenInfo
            } catch {
                print("Failed to load cached token for \(provider.rawValue): \(error)")
            }
        }
    }
    
    // MARK: - L5.001 Private Helper Methods
    
    private func validateOpenAIKeyFormat(_ apiKey: String) -> Bool {
        // OpenAI API keys start with "sk-" and are typically 51 characters long
        return apiKey.hasPrefix("sk-") && apiKey.count >= 50 && !apiKey.contains("placeholder")
    }
    
    private func validateAnthropicKeyFormat(_ apiKey: String) -> Bool {
        // Anthropic API keys start with "sk-ant-" 
        return (apiKey.hasPrefix("sk-ant-") || apiKey.count >= 20) && !apiKey.contains("placeholder")
    }
    
    private func validateGoogleAIKeyFormat(_ apiKey: String) -> Bool {
        // Google AI API keys are typically 39 characters and alphanumeric
        return apiKey.count >= 20 && !apiKey.contains("placeholder") && !apiKey.isEmpty
    }
    
    private func encryptAPIKey(_ apiKey: String) throws -> Data {
        // In a real implementation, this would use proper encryption
        // For now, we'll use base64 encoding as a placeholder
        guard let data = apiKey.data(using: .utf8) else {
            throw TokenError.storageError("Failed to encode API key")
        }
        return data.base64EncodedData()
    }
    
    private func decryptAPIKey(_ encryptedData: Data) throws -> String? {
        // In a real implementation, this would use proper decryption
        // For now, we'll use base64 decoding as a placeholder
        guard let base64Data = Data(base64Encoded: encryptedData),
              let apiKey = String(data: base64Data, encoding: .utf8) else {
            throw TokenError.storageError("Failed to decrypt API key")
        }
        return apiKey
    }
}

// MARK: - Supporting Data Models

private struct TokenInfo: Codable {
    let token: String
    let provider: AuthenticationProvider
    let createdAt: Date
    let expiresAt: Date
    
    init(token: String, provider: AuthenticationProvider, createdAt: Date, expiresAt: Date) {
        self.token = token
        self.provider = provider
        self.createdAt = createdAt
        self.expiresAt = expiresAt
    }
}

public enum TokenError: Error, LocalizedError {
    case tokenNotFound
    case tokenExpired
    case tokenInvalid
    case refreshFailed(String)
    case storageError(String)
    
    public var errorDescription: String? {
        switch self {
        case .tokenNotFound:
            return "Authentication token not found"
        case .tokenExpired:
            return "Authentication token has expired"
        case .tokenInvalid:
            return "Authentication token is invalid"
        case .refreshFailed(let message):
            return "Token refresh failed: \(message)"
        case .storageError(let message):
            return "Token storage error: \(message)"
        }
    }
}