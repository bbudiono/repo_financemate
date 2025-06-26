//
//  TokenManager.swift
//  FinanceMate
//
//  Created by Assistant on 6/11/25.
//

import Foundation
import Security

// MARK: - Unified Token Manager (AUTH-CONSOLIDATION-001)

@MainActor
public class TokenManager: ObservableObject {
    private let service = "com.financemate.tokens"
    private let keychainManager = KeychainManager.shared

    public init() {}

    // MARK: - Authentication Token Methods

    public func saveToken(_ token: String, for provider: AuthenticationProvider) {
        let tokenKey = "\(provider.rawValue)_access_token"
        try? keychainManager.store(key: tokenKey, value: token)
    }

    public func saveRefreshToken(_ refreshToken: String, for provider: AuthenticationProvider) {
        let refreshKey = "\(provider.rawValue)_refresh_token"
        try? keychainManager.store(key: refreshKey, value: refreshToken)
    }

    public func getToken(for provider: AuthenticationProvider) -> String? {
        let tokenKey = "\(provider.rawValue)_access_token"
        return try? keychainManager.retrieve(key: tokenKey)
    }

    public func getRefreshToken(for provider: AuthenticationProvider) -> String? {
        let refreshKey = "\(provider.rawValue)_refresh_token"
        return try? keychainManager.retrieve(key: refreshKey)
    }

    public func hasValidToken(for provider: AuthenticationProvider) -> Bool {
        getToken(for: provider) != nil
    }

    public func clearTokens(for provider: AuthenticationProvider) {
        let tokenKey = "\(provider.rawValue)_access_token"
        let refreshKey = "\(provider.rawValue)_refresh_token"
        try? keychainManager.delete(key: tokenKey)
        try? keychainManager.delete(key: refreshKey)
    }

    public func clearAllTokens() {
        AuthenticationProvider.allCases.forEach { provider in
            clearTokens(for: provider)
        }
    }

    // MARK: - API Key Methods (consolidated from stubs)

    public func validateAPIKeyFormat(_ apiKey: String, provider: LLMProvider) -> Bool {
        guard !apiKey.isEmpty else { return false }

        switch provider {
        case .openai:
            return apiKey.hasPrefix("sk-") && apiKey.count > 10
        case .anthropic:
            return apiKey.hasPrefix("sk-ant-") && apiKey.count > 15
        case .googleai:
            return apiKey.count > 10 // Generic validation for Google AI
        }
    }
}
