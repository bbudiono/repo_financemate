import Foundation
import AuthenticationServices
import Security
import os.log

/**
 * EmailOAuthManager.swift
 * 
 * Purpose: Secure OAuth 2.0 authentication management for email providers
 * Issues & Complexity Summary: OAuth flows, token management, Keychain security
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~300 (OAuth flows + token management + security)
 *   - Core Algorithm Complexity: High (OAuth 2.0 PKCE flow, token refresh)
 *   - Dependencies: 4 New (AuthenticationServices, Security, Keychain, WebKit)
 *   - State Management Complexity: High (OAuth state, token lifecycle, security)
 *   - Novelty/Uncertainty Factor: Medium (OAuth standards, but provider-specific)
 * AI Pre-Task Self-Assessment: 88%
 * Problem Estimate: 90%
 * Initial Code Complexity Estimate: 92%
 * Target Coverage: OAuth security and token management compliance
 * Privacy Compliance: PKCE flow, minimal scope, secure token storage
 * Last Updated: 2025-08-09
 */

/// Secure OAuth 2.0 authentication manager for Gmail and Outlook email providers
@MainActor
final class EmailOAuthManager: ObservableObject {
    
    // MARK: - Error Types
    
    enum OAuthError: Error, LocalizedError {
        case authorizationCancelled
        case authorizationFailed(String)
        case tokenExchangeFailed(String)
        case tokenRefreshFailed(String)
        case keychainError(String)
        case networkError(String)
        case invalidConfiguration(String)
        case unsupportedProvider(String)
        
        var errorDescription: String? {
            switch self {
            case .authorizationCancelled:
                return "User cancelled authorization"
            case .authorizationFailed(let reason):
                return "Authorization failed: \(reason)"
            case .tokenExchangeFailed(let reason):
                return "Token exchange failed: \(reason)"
            case .tokenRefreshFailed(let reason):
                return "Token refresh failed: \(reason)"
            case .keychainError(let reason):
                return "Keychain error: \(reason)"
            case .networkError(let reason):
                return "Network error: \(reason)"
            case .invalidConfiguration(let reason):
                return "Invalid configuration: \(reason)"
            case .unsupportedProvider(let provider):
                return "Unsupported email provider: \(provider)"
            }
        }
    }
    
    // MARK: - Data Models
    
    struct EmailProvider {
        let id: String
        let name: String
        let authorizationURL: String
        let tokenURL: String
        let clientId: String
        let clientSecret: String
        let scope: String
        let redirectURI: String
        
        static let gmail = EmailProvider(
            id: "gmail",
            name: "Gmail",
            authorizationURL: ProductionAPIConfig.gmailAuthURL,
            tokenURL: ProductionAPIConfig.gmailTokenURL,
            clientId: ProductionAPIConfig.gmailClientId,
            clientSecret: ProductionAPIConfig.gmailClientSecret,
            scope: ProductionAPIConfig.gmailScope,
            redirectURI: ProductionAPIConfig.gmailRedirectURI
        )
        
        static let outlook = EmailProvider(
            id: "outlook",
            name: "Microsoft Outlook",
            authorizationURL: ProductionAPIConfig.outlookAuthURL,
            tokenURL: ProductionAPIConfig.outlookTokenURL,
            clientId: ProductionAPIConfig.outlookClientId,
            clientSecret: ProductionAPIConfig.outlookClientSecret,
            scope: ProductionAPIConfig.outlookScope,
            redirectURI: ProductionAPIConfig.outlookRedirectURI
        )
        
        static let supportedProviders = [gmail, outlook]
    }
    
    struct OAuthTokens {
        let accessToken: String
        let refreshToken: String?
        let expiresAt: Date
        let scope: String
        let provider: String
    }
    
    // MARK: - Published Properties
    
    @Published private(set) var authenticatedProviders: Set<String> = []
    @Published private(set) var isAuthenticating: Bool = false
    @Published private(set) var authenticationError: String?
    
    // MARK: - Private Properties
    
    private let logger = Logger(subsystem: "FinanceMate", category: "EmailOAuthManager")
    private let urlSession: URLSession
    private var currentAuthSession: ASWebAuthenticationSession?
    
    // MARK: - Initialization
    
    init() {
        // Validate production configuration
        if !ProductionAPIConfig.isReadyForProduction {
            logger.warning("Production API credentials not fully configured")
            logger.info("\(ProductionAPIConfig.configurationSummary, privacy: .public)")
        }
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30.0
        self.urlSession = URLSession(configuration: config)
        
        // Check for existing authenticated providers
        Task {
            await loadAuthenticatedProviders()
        }
    }
    
    // MARK: - Public Interface
    
    /// Authenticate with an email provider using OAuth 2.0 PKCE flow
    func authenticateProvider(_ providerId: String) async throws -> OAuthTokens {
        guard let provider = EmailProvider.supportedProviders.first(where: { $0.id == providerId }) else {
            throw OAuthError.unsupportedProvider(providerId)
        }
        
        isAuthenticating = true
        authenticationError = nil
        
        defer {
            isAuthenticating = false
        }
        
        do {
            // Step 1: Generate PKCE parameters
            let pkceChallenge = try generatePKCEChallenge()
            
            // Step 2: Initiate authorization flow
            let authorizationCode = try await requestAuthorizationCode(
                provider: provider,
                codeChallenge: pkceChallenge.challenge,
                codeChallengeMethod: pkceChallenge.method
            )
            
            // Step 3: Exchange authorization code for tokens
            let tokens = try await exchangeCodeForTokens(
                provider: provider,
                authorizationCode: authorizationCode,
                codeVerifier: pkceChallenge.verifier
            )
            
            // Step 4: Store tokens securely
            try await storeTokensSecurely(tokens, for: providerId)
            
            // Step 5: Update authenticated providers
            authenticatedProviders.insert(providerId)
            
            logger.info("Successfully authenticated with \(provider.name)")
            return tokens
            
        } catch {
            let errorMessage = error.localizedDescription
            authenticationError = errorMessage
            logger.error("Authentication failed for \(provider.name, privacy: .public): \(errorMessage, privacy: .public)")
            throw error
        }
    }
    
    /// Get valid access token for provider (handles refresh if needed)
    func getValidAccessToken(for providerId: String) async throws -> String {
        guard authenticatedProviders.contains(providerId) else {
            throw OAuthError.authorizationFailed("Provider not authenticated: \(providerId)")
        }
        
        // Retrieve stored tokens
        guard let tokens = try retrieveStoredTokens(for: providerId) else {
            throw OAuthError.tokenExchangeFailed("No stored tokens for provider")
        }
        
        // Check if token is still valid
        if tokens.expiresAt > Date().addingTimeInterval(300) { // 5 minute buffer
            return tokens.accessToken
        }
        
        // Token expired, attempt refresh
        guard let refreshToken = tokens.refreshToken else {
            throw OAuthError.tokenRefreshFailed("No refresh token available")
        }
        
        let refreshedTokens = try await refreshAccessToken(
            provider: EmailProvider.supportedProviders.first(where: { $0.id == providerId })!,
            refreshToken: refreshToken
        )
        
        // Store refreshed tokens
        try await storeTokensSecurely(refreshedTokens, for: providerId)
        
        return refreshedTokens.accessToken
    }
    
    /// Revoke authentication for a provider
    func revokeAuthentication(for providerId: String) async throws {
        // Remove from authenticated providers
        authenticatedProviders.remove(providerId)
        
        // Remove stored tokens
        try removeStoredTokens(for: providerId)
        
        logger.info("Revoked authentication for provider: \(providerId)")
    }
    
    /// Check if provider is currently authenticated
    func isProviderAuthenticated(_ providerId: String) -> Bool {
        return authenticatedProviders.contains(providerId)
    }
    
    // MARK: - OAuth 2.0 PKCE Implementation
    
    private struct PKCEChallenge {
        let verifier: String
        let challenge: String
        let method: String
    }
    
    private func generatePKCEChallenge() throws -> PKCEChallenge {
        // Generate code verifier (43-128 characters)
        var bytes = [UInt8](repeating: 0, count: 32)
        let result = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        
        guard result == errSecSuccess else {
            throw OAuthError.authorizationFailed("Failed to generate secure random bytes")
        }
        
        let codeVerifier = Data(bytes).base64URLEncodedString()
        
        // Generate code challenge (SHA256 hash of verifier)
        guard let verifierData = codeVerifier.data(using: .utf8) else {
            throw OAuthError.authorizationFailed("Failed to encode code verifier")
        }
        
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        verifierData.withUnsafeBytes { bytes in
            _ = CC_SHA256(bytes.bindMemory(to: UInt8.self).baseAddress, CC_LONG(verifierData.count), &hash)
        }
        
        let codeChallenge = Data(hash).base64URLEncodedString()
        
        return PKCEChallenge(
            verifier: codeVerifier,
            challenge: codeChallenge,
            method: "S256"
        )
    }
    
    private func requestAuthorizationCode(provider: EmailProvider, codeChallenge: String, codeChallengeMethod: String) async throws -> String {
        // Build authorization URL
        var components = URLComponents(string: provider.authorizationURL)!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: provider.clientId),
            URLQueryItem(name: "redirect_uri", value: provider.redirectURI),
            URLQueryItem(name: "scope", value: provider.scope),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "code_challenge", value: codeChallenge),
            URLQueryItem(name: "code_challenge_method", value: codeChallengeMethod),
            URLQueryItem(name: "access_type", value: "offline"), // For refresh tokens
            URLQueryItem(name: "prompt", value: "consent")
        ]
        
        guard let authURL = components.url else {
            throw OAuthError.invalidConfiguration("Failed to build authorization URL")
        }
        
        // Create authentication session
        return try await withCheckedThrowingContinuation { continuation in
            currentAuthSession = ASWebAuthenticationSession(
                url: authURL,
                callbackURLScheme: "com.ablankcanvas.financemate"
            ) { callbackURL, error in
                if let error = error {
                    if let authError = error as? ASWebAuthenticationSessionError,
                       authError.code == .canceledLogin {
                        continuation.resume(throwing: OAuthError.authorizationCancelled)
                    } else {
                        continuation.resume(throwing: OAuthError.authorizationFailed(error.localizedDescription))
                    }
                    return
                }
                
                guard let callbackURL = callbackURL else {
                    continuation.resume(throwing: OAuthError.authorizationFailed("No callback URL received"))
                    return
                }
                
                // Extract authorization code from callback URL
                guard let components = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false),
                      let codeItem = components.queryItems?.first(where: { $0.name == "code" }),
                      let code = codeItem.value else {
                    continuation.resume(throwing: OAuthError.authorizationFailed("No authorization code received"))
                    return
                }
                
                continuation.resume(returning: code)
            }
            
            currentAuthSession?.presentationContextProvider = AuthenticationPresentationContextProvider()
            currentAuthSession?.prefersEphemeralWebBrowserSession = true
            currentAuthSession?.start()
        }
    }
    
    private func exchangeCodeForTokens(provider: EmailProvider, authorizationCode: String, codeVerifier: String) async throws -> OAuthTokens {
        guard let tokenURL = URL(string: provider.tokenURL) else {
            throw OAuthError.invalidConfiguration("Invalid token URL")
        }
        
        // Prepare token request
        var request = URLRequest(url: tokenURL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let parameters = [
            "client_id": provider.clientId,
            "client_secret": provider.clientSecret,
            "code": authorizationCode,
            "redirect_uri": provider.redirectURI,
            "grant_type": "authorization_code",
            "code_verifier": codeVerifier
        ]
        
        let bodyString = parameters.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
        request.httpBody = bodyString.data(using: .utf8)
        
        // Execute token request
        let (data, response) = try await urlSession.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw OAuthError.networkError("Invalid response type")
        }
        
        guard httpResponse.statusCode == 200 else {
            throw OAuthError.tokenExchangeFailed("HTTP \(httpResponse.statusCode)")
        }
        
        // Parse token response
        struct TokenResponse: Codable {
            let access_token: String
            let refresh_token: String?
            let expires_in: Int
            let scope: String?
        }
        
        let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
        
        return OAuthTokens(
            accessToken: tokenResponse.access_token,
            refreshToken: tokenResponse.refresh_token,
            expiresAt: Date().addingTimeInterval(TimeInterval(tokenResponse.expires_in)),
            scope: tokenResponse.scope ?? provider.scope,
            provider: provider.id
        )
    }
    
    private func refreshAccessToken(provider: EmailProvider, refreshToken: String) async throws -> OAuthTokens {
        guard let tokenURL = URL(string: provider.tokenURL) else {
            throw OAuthError.invalidConfiguration("Invalid token URL")
        }
        
        var request = URLRequest(url: tokenURL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let parameters = [
            "client_id": provider.clientId,
            "refresh_token": refreshToken,
            "grant_type": "refresh_token"
        ]
        
        let bodyString = parameters.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
        request.httpBody = bodyString.data(using: .utf8)
        
        let (data, response) = try await urlSession.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw OAuthError.tokenRefreshFailed("Failed to refresh token")
        }
        
        struct RefreshResponse: Codable {
            let access_token: String
            let expires_in: Int
            let scope: String?
        }
        
        let refreshResponse = try JSONDecoder().decode(RefreshResponse.self, from: data)
        
        return OAuthTokens(
            accessToken: refreshResponse.access_token,
            refreshToken: refreshToken, // Keep existing refresh token
            expiresAt: Date().addingTimeInterval(TimeInterval(refreshResponse.expires_in)),
            scope: refreshResponse.scope ?? provider.scope,
            provider: provider.id
        )
    }
    
    // MARK: - Secure Token Storage
    
    private func storeTokensSecurely(_ tokens: OAuthTokens, for providerId: String) async throws {
        let tokenData = try JSONEncoder().encode(tokens)
        
        // Store in Keychain
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "\(providerId)_oauth_tokens",
            kSecAttrService as String: "FinanceMate",
            kSecAttrDescription as String: "OAuth tokens for \(providerId)",
            kSecValueData as String: tokenData,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        // Delete existing entry first
        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "\(providerId)_oauth_tokens",
            kSecAttrService as String: "FinanceMate"
        ]
        SecItemDelete(deleteQuery as CFDictionary)
        
        // Add new entry
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            throw OAuthError.keychainError("Failed to store tokens: \(status)")
        }
    }
    
    private func retrieveStoredTokens(for providerId: String) throws -> OAuthTokens? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "\(providerId)_oauth_tokens",
            kSecAttrService as String: "FinanceMate",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data else {
            if status == errSecItemNotFound {
                return nil
            }
            throw OAuthError.keychainError("Failed to retrieve tokens: \(status)")
        }
        
        return try JSONDecoder().decode(OAuthTokens.self, from: data)
    }
    
    private func removeStoredTokens(for providerId: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "\(providerId)_oauth_tokens",
            kSecAttrService as String: "FinanceMate"
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw OAuthError.keychainError("Failed to remove tokens: \(status)")
        }
    }
    
    private func loadAuthenticatedProviders() async {
        var authenticated: Set<String> = []
        
        for provider in EmailProvider.supportedProviders {
            do {
                if let _ = try retrieveStoredTokens(for: provider.id) {
                    authenticated.insert(provider.id)
                }
            } catch {
                logger.warning("Failed to load tokens for \(provider.id): \(error.localizedDescription)")
            }
        }
        
        authenticatedProviders = authenticated
    }
}

// MARK: - Presentation Context Provider

private class AuthenticationPresentationContextProvider: NSObject, ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return NSApplication.shared.windows.first ?? NSWindow()
    }
}

// MARK: - Extensions

extension Data {
    func base64URLEncodedString() -> String {
        return base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}

// Import CommonCrypto for SHA256
import CommonCrypto

extension EmailOAuthManager.OAuthTokens: Codable {}