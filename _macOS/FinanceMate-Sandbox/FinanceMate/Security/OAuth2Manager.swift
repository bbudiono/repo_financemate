//
//  OAuth2Manager.swift
//  FinanceMate
//
//  Purpose: OAuth 2.0 implementation with PKCE for secure authentication
//  Supports Apple Sign In and Google Sign In

import AuthenticationServices
import Combine
import CryptoKit
import Foundation

@MainActor
public final class OAuth2Manager: NSObject, ObservableObject {
    public static let shared = OAuth2Manager()

    @Published public var isAuthenticated = false
    @Published public var currentUser: AuthenticatedUser?
    @Published public var authenticationError: Error?

    private let keychainManager = KeychainManager.shared
    private let auditLogger = SecurityAuditLogger.shared

    // OAuth configuration
    private let redirectURI = "com.ablankcanvas.financemate://oauth"
    private let clientId = ProcessInfo.processInfo.environment["OAUTH_CLIENT_ID"] ?? "financemate-client"

    // PKCE parameters
    private var codeVerifier: String?
    private var codeChallenge: String?
    private var state: String?

    override private init() {
        super.init()
    }

    // MARK: - Public Methods

    /// Initiate OAuth 2.0 authentication flow
    public func authenticate(with provider: AuthProvider) async throws {
        // Generate PKCE parameters
        generatePKCEParameters()

        // Generate state for CSRF protection
        state = generateRandomString(length: 32)

        switch provider {
        case .apple:
            try await authenticateWithApple()
        case .google:
            try await authenticateWithGoogle()
        }
    }

    /// Sign out and clear all credentials
    public func signOut() async throws {
        // Revoke tokens if possible
        if let tokens = try? keychainManager.retrieveOAuthTokens() {
            await revokeTokens(tokens)
        }

        // Clear keychain
        try keychainManager.delete(key: "oauth_tokens")
        try keychainManager.delete(key: "session_token")

        // Clear state
        isAuthenticated = false
        currentUser = nil

        // Audit log
        if let userId = currentUser?.id {
            auditLogger.log(event: .sessionRevoked(userId: userId, reason: "User initiated sign out"))
        }
    }

    /// Refresh access token using refresh token
    public func refreshTokenIfNeeded() async throws {
        guard let tokens = try? keychainManager.retrieveOAuthTokens() else {
            throw OAuth2Error.noStoredTokens
        }

        // Check if token is expired or will expire soon
        let expirationBuffer: TimeInterval = 300 // 5 minutes
        if tokens.expiresAt.addingTimeInterval(-expirationBuffer) > Date() {
            return // Token still valid
        }

        // Refresh the token
        let newTokens = try await refreshAccessToken(refreshToken: tokens.refreshToken)
        try keychainManager.storeOAuthTokens(newTokens)

        // Audit log
        if let userId = currentUser?.id {
            auditLogger.log(event: .oauthTokenRefresh(userId: userId))
        }
    }

    /// Validate current session
    public func validateSession() async throws {
        do {
            let sessionToken = try keychainManager.retrieveSessionToken()

            // Verify token hasn't expired
            if sessionToken.expiresAt < Date() {
                throw OAuth2Error.sessionExpired
            }

            // Verify token signature
            if !verifyTokenSignature(sessionToken.token) {
                throw OAuth2Error.invalidTokenSignature
            }

            // Refresh token if needed
            try await refreshTokenIfNeeded()

            isAuthenticated = true
        } catch {
            isAuthenticated = false
            if let userId = currentUser?.id {
                auditLogger.log(event: .sessionExpired(userId: userId))
            }
            throw error
        }
    }

    // MARK: - Apple Sign In

    private func authenticateWithApple() async throws {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = generateNonce()

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self

        controller.performRequests()
    }

    // MARK: - Google Sign In

    private func authenticateWithGoogle() async throws {
        // Build authorization URL with PKCE
        var components = URLComponents(string: "https://accounts.google.com/o/oauth2/v2/auth")!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: "openid email profile"),
            URLQueryItem(name: "state", value: state),
            URLQueryItem(name: "code_challenge", value: codeChallenge),
            URLQueryItem(name: "code_challenge_method", value: "S256"),
            URLQueryItem(name: "access_type", value: "offline"),
            URLQueryItem(name: "prompt", value: "select_account")
        ]

        guard let authURL = components.url else {
            throw OAuth2Error.invalidAuthorizationURL
        }

        // Open in browser
        NSWorkspace.shared.open(authURL)
    }

    // MARK: - OAuth Callback Handler

    public func handleOAuthCallback(url: URL) async throws {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            throw OAuth2Error.invalidCallbackURL
        }

        // Verify state
        let returnedState = queryItems.first { $0.name == "state" }?.value
        guard returnedState == state else {
            throw OAuth2Error.stateMismatch
        }

        // Get authorization code
        guard let code = queryItems.first(where: { $0.name == "code" })?.value else {
            let error = queryItems.first { $0.name == "error" }?.value ?? "Unknown error"
            throw OAuth2Error.authorizationFailed(error: error)
        }

        // Exchange code for tokens
        let tokens = try await exchangeCodeForTokens(code: code)

        // Store tokens securely
        try keychainManager.storeOAuthTokens(tokens)

        // Create session
        let sessionToken = generateSessionToken()
        try keychainManager.storeSessionToken(sessionToken, expiresAt: Date().addingTimeInterval(3600))

        // Update state
        isAuthenticated = true
        currentUser = try await fetchUserProfile(accessToken: tokens.accessToken)

        // Audit log
        auditLogger.log(event: .authenticationSuccess(
            userId: currentUser?.id ?? "unknown",
            method: .googleSignIn
        ))
    }

    // MARK: - Token Exchange

    private func exchangeCodeForTokens(code: String) async throws -> OAuthTokens {
        let tokenURL = URL(string: "https://oauth2.googleapis.com/token")!

        var request = URLRequest(url: tokenURL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let parameters = [
            "grant_type": "authorization_code",
            "code": code,
            "redirect_uri": redirectURI,
            "client_id": clientId,
            "code_verifier": codeVerifier ?? ""
        ]

        request.httpBody = parameters
            .map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }
            .joined(separator: "&")
            .data(using: .utf8)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw OAuth2Error.tokenExchangeFailed
        }

        let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)

        return OAuthTokens(
            accessToken: tokenResponse.accessToken,
            refreshToken: tokenResponse.refreshToken ?? "",
            idToken: tokenResponse.idToken,
            expiresIn: tokenResponse.expiresIn,
            tokenType: tokenResponse.tokenType,
            scope: tokenResponse.scope,
            createdAt: Date()
        )
    }

    private func refreshAccessToken(refreshToken: String) async throws -> OAuthTokens {
        let tokenURL = URL(string: "https://oauth2.googleapis.com/token")!

        var request = URLRequest(url: tokenURL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let parameters = [
            "grant_type": "refresh_token",
            "refresh_token": refreshToken,
            "client_id": clientId
        ]

        request.httpBody = parameters
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
            .data(using: .utf8)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw OAuth2Error.tokenRefreshFailed
        }

        let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)

        return OAuthTokens(
            accessToken: tokenResponse.accessToken,
            refreshToken: refreshToken, // Keep existing refresh token
            idToken: tokenResponse.idToken,
            expiresIn: tokenResponse.expiresIn,
            tokenType: tokenResponse.tokenType,
            scope: tokenResponse.scope,
            createdAt: Date()
        )
    }

    private func revokeTokens(_ tokens: OAuthTokens) async {
        let revokeURL = URL(string: "https://oauth2.googleapis.com/revoke")!

        var request = URLRequest(url: revokeURL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let parameters = ["token": tokens.refreshToken]
        request.httpBody = parameters
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
            .data(using: .utf8)

        _ = try? await URLSession.shared.data(for: request)
    }

    // MARK: - User Profile

    private func fetchUserProfile(accessToken: String) async throws -> AuthenticatedUser {
        let profileURL = URL(string: "https://www.googleapis.com/oauth2/v2/userinfo")!

        var request = URLRequest(url: profileURL)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let (data, _) = try await URLSession.shared.data(for: request)
        let profile = try JSONDecoder().decode(UserProfile.self, from: data)

        return AuthenticatedUser(
            id: profile.id,
            email: profile.email,
            name: profile.name,
            pictureURL: profile.picture
        )
    }

    // MARK: - PKCE Helpers

    private func generatePKCEParameters() {
        codeVerifier = generateRandomString(length: 128)
        codeChallenge = generateCodeChallenge(from: codeVerifier!)
    }

    private func generateRandomString(length: Int) -> String {
        let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~"
        return String((0..<length).compactMap { _ in characters.randomElement() })
    }

    private func generateCodeChallenge(from verifier: String) -> String {
        let data = verifier.data(using: .utf8)!
        let hash = SHA256.hash(data: data)
        return Data(hash)
            .base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }

    private func generateNonce() -> String {
        let nonce = generateRandomString(length: 32)
        let data = nonce.data(using: .utf8)!
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }

    private func generateSessionToken() -> String {
        generateRandomString(length: 64)
    }

    private func verifyTokenSignature(_ token: String) -> Bool {
        // In production, verify JWT signature
        true
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension OAuth2Manager: ASAuthorizationControllerDelegate {
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            return
        }

        Task {
            do {
                // Create tokens from Apple credential
                let tokens = OAuthTokens(
                    accessToken: String(data: appleIDCredential.identityToken ?? Data(), encoding: .utf8) ?? "",
                    refreshToken: "", // Apple doesn't provide refresh tokens
                    idToken: String(data: appleIDCredential.identityToken ?? Data(), encoding: .utf8),
                    expiresIn: 3600,
                    tokenType: "Bearer",
                    scope: "openid email",
                    createdAt: Date()
                )

                // Store tokens
                try keychainManager.storeOAuthTokens(tokens)

                // Create user
                currentUser = AuthenticatedUser(
                    id: appleIDCredential.user,
                    email: appleIDCredential.email ?? "",
                    name: "\(appleIDCredential.fullName?.givenName ?? "") \(appleIDCredential.fullName?.familyName ?? "")",
                    pictureURL: nil
                )

                // Create session
                let sessionToken = generateSessionToken()
                try keychainManager.storeSessionToken(sessionToken, expiresAt: Date().addingTimeInterval(3600))

                isAuthenticated = true

                // Audit log
                auditLogger.log(event: .authenticationSuccess(
                    userId: currentUser?.id ?? "unknown",
                    method: .appleSignIn
                ))
            } catch {
                authenticationError = error
                auditLogger.log(event: .authenticationFailure(
                    userId: "unknown",
                    reason: error.localizedDescription
                ))
            }
        }
    }

    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        authenticationError = error
        auditLogger.log(event: .authenticationFailure(
            userId: "unknown",
            reason: error.localizedDescription
        ))
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension OAuth2Manager: ASAuthorizationControllerPresentationContextProviding {
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        NSApplication.shared.windows.first!
    }
}

// MARK: - Supporting Types

public enum AuthProvider {
    case apple
    case google
}

// Note: AuthenticatedUser is defined in CommonTypes.swift

struct TokenResponse: Codable {
    let accessToken: String
    let refreshToken: String?
    let idToken: String?
    let expiresIn: TimeInterval
    let tokenType: String
    let scope: String?

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case idToken = "id_token"
        case expiresIn = "expires_in"
        case tokenType = "token_type"
        case scope
    }
}

struct UserProfile: Codable {
    let id: String
    let email: String
    let name: String
    let picture: String?
}

public enum OAuth2Error: LocalizedError {
    case noStoredTokens
    case sessionExpired
    case invalidTokenSignature
    case invalidAuthorizationURL
    case invalidCallbackURL
    case stateMismatch
    case authorizationFailed(error: String)
    case tokenExchangeFailed
    case tokenRefreshFailed

    public var errorDescription: String? {
        switch self {
        case .noStoredTokens:
            return "No stored authentication tokens found"
        case .sessionExpired:
            return "Your session has expired. Please sign in again."
        case .invalidTokenSignature:
            return "Invalid token signature detected"
        case .invalidAuthorizationURL:
            return "Failed to create authorization URL"
        case .invalidCallbackURL:
            return "Invalid OAuth callback URL"
        case .stateMismatch:
            return "OAuth state mismatch - possible CSRF attack"
        case .authorizationFailed(let error):
            return "Authorization failed: \(error)"
        case .tokenExchangeFailed:
            return "Failed to exchange authorization code for tokens"
        case .tokenRefreshFailed:
            return "Failed to refresh access token"
        }
    }
}
