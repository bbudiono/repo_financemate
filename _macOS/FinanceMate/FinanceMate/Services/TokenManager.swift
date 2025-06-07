

//
//  TokenManager.swift
//  FinanceMate
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

// MARK: - Supporting Types

public enum AuthenticationProvider: String, CaseIterable, Codable {
    case apple = "apple"
    case google = "google"
    case microsoft = "microsoft"
    case github = "github"
    case linkedin = "linkedin"
    case facebook = "facebook"
    case demo = "demo"
}

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
            
        case .demo:
            // Demo tokens are always valid and don't need refresh
            if let existingToken = getToken(for: provider) {
                return existingToken
            }
            // Create a new demo token if none exists
            let newToken = "demo_token_\(Date().timeIntervalSince1970)"
            saveToken(newToken, for: provider)
            return newToken
            
        case .microsoft, .github, .linkedin, .facebook:
            // For other providers, use a similar pattern to Google
            let newToken = "\(provider.rawValue)_token_\(Date().timeIntervalSince1970)"
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
    
    public func saveRefreshToken(_ refreshToken: String, for provider: AuthenticationProvider) {
        let key = refreshTokenKeychainKey(for: provider)
        do {
            let data = refreshToken.data(using: .utf8)!
            try keychain.save(data, for: key)
        } catch {
            print("Failed to save refresh token for \(provider.rawValue): \(error)")
        }
    }
    
    public func getRefreshToken(for provider: AuthenticationProvider) -> String? {
        let key = refreshTokenKeychainKey(for: provider)
        do {
            guard let data = keychain.retrieve(for: key) else { return nil }
            return String(data: data, encoding: .utf8)
        } catch {
            print("Failed to retrieve refresh token for \(provider.rawValue): \(error)")
            return nil
        }
    }
    
    public func clearAllTokens() {
        for provider in AuthenticationProvider.allCases {
            revokeToken(for: provider)
            // Also clear refresh tokens
            let refreshKey = refreshTokenKeychainKey(for: provider)
            keychain.delete(for: refreshKey)
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
    
    // MARK: - Private Methods
    
    private func isTokenValid(_ tokenInfo: TokenInfo) -> Bool {
        // Check if token is expired (with buffer)
        let expirationWithBuffer = tokenInfo.expiresAt.addingTimeInterval(-tokenExpirationBuffer)
        return Date() < expirationWithBuffer
    }
    
    private func tokenKeychainKey(for provider: AuthenticationProvider) -> String {
        return "token_\(provider.rawValue)"
    }
    
    private func refreshTokenKeychainKey(for provider: AuthenticationProvider) -> String {
        return "refresh_token_\(provider.rawValue)"
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