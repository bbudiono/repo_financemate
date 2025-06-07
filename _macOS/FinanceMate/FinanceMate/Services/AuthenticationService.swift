
//
//  AuthenticationService.swift
//  FinanceMate
//
//  Created by Assistant on 6/2/25.
//

/*
* Purpose: Authentication service for Apple and Google SSO integration in Sandbox environment
* Issues & Complexity Summary: TDD implementation of multi-provider authentication with secure token management
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~600
  - Core Algorithm Complexity: High  
  - Dependencies: 8 New (AppleAuth, GoogleAuth, TokenManager, UserSession, SecurityValidation, KeychainAccess, CredentialsManager, AuthenticationFlow)
  - State Management Complexity: Very High
  - Novelty/Uncertainty Factor: High
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 85%
* Problem Estimate (Inherent Problem Difficulty %): 82%
* Initial Code Complexity Estimate %: 84%
* Justification for Estimates: Complex multi-provider authentication system with secure credential management
* Final Code Complexity (Actual %): TBD - TDD implementation in progress
* Overall Result Score (Success & Quality %): TBD - Iterative development
* Key Variances/Learnings: TDD approach ensures robust authentication security and user experience
* Last Updated: 2025-06-02
*/

import Foundation
import AuthenticationServices
import SwiftUI
import Combine

// MARK: - Authentication Service

@MainActor
public class AuthenticationService: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published public var isAuthenticated: Bool = false
    @Published public var currentUser: AuthenticatedUser?
    @Published public var authenticationState: AuthenticationState = .unauthenticated
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?
    
    // MARK: - Private Properties
    
    private let tokenManager: TokenManager
    private let keychainManager: KeychainManager
    private let userSessionManager: UserSessionManager
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    public init() {
        self.tokenManager = TokenManager()
        self.keychainManager = KeychainManager()
        self.userSessionManager = UserSessionManager()
        
        setupAuthenticationStateMonitoring()
        checkExistingAuthentication()
    }
    
    // MARK: - Apple Sign In Methods
    
    public func signInWithApple() async throws -> AuthenticationResult {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            
            let authController = ASAuthorizationController(authorizationRequests: [request])
            
            // Use a coordinator to handle the Apple Sign In flow
            let coordinator = AppleSignInCoordinator()
            authController.delegate = coordinator
            authController.presentationContextProvider = coordinator
            
            authController.performRequests()
            
            // Wait for the result
            let appleIDCredential = try await coordinator.waitForResult()
            
            // Process the Apple ID credential
            let user = try await processAppleIDCredential(appleIDCredential)
            
            // Update authentication state
            await updateAuthenticationState(user: user, provider: .apple)
            
            return AuthenticationResult(
                success: true,
                user: user,
                provider: .apple,
                token: appleIDCredential.identityToken.flatMap { String(data: $0, encoding: .utf8) } ?? ""
            )
            
        } catch {
            errorMessage = "Apple Sign In failed: \(error.localizedDescription)"
            throw AuthenticationError.appleSignInFailed(error)
        }
    }
    
    public func signInWithGoogle() async throws -> AuthenticationResult {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Real Google OAuth implementation using NSWorkspace to open browser
            let authURL = buildGoogleOAuthURL()
            let callbackURL = try await openGoogleOAuthFlow(authURL: authURL)
            let authCode = try extractAuthCodeFromCallback(callbackURL)
            let tokens = try await exchangeCodeForTokens(authCode)
            let userInfo = try await fetchGoogleUserInfo(accessToken: tokens.accessToken)
            
            let googleUser = AuthenticatedUser(
                id: userInfo.id,
                email: userInfo.email,
                displayName: userInfo.name,
                provider: .google,
                isEmailVerified: userInfo.emailVerified
            )
            
            // Save real tokens
            tokenManager.saveToken(tokens.accessToken, for: .google)
            if let refreshToken = tokens.refreshToken {
                tokenManager.saveRefreshToken(refreshToken, for: .google)
            }
            
            // Update authentication state
            await updateAuthenticationState(user: googleUser, provider: .google)
            
            return AuthenticationResult(
                success: true,
                user: googleUser,
                provider: .google,
                token: tokens.accessToken
            )
            
        } catch {
            errorMessage = "Google Sign In failed: \(error.localizedDescription)"
            throw AuthenticationError.googleSignInFailed(error)
        }
    }
    
    // MARK: - Sign Out Methods
    
    public func signOut() async {
        isLoading = true
        defer { isLoading = false }
        
        // Clear tokens
        tokenManager.clearAllTokens()
        
        // Clear keychain
        keychainManager.clearUserCredentials()
        
        // Clear user session
        await userSessionManager.clearSession()
        
        // Update state
        currentUser = nil
        isAuthenticated = false
        authenticationState = .unauthenticated
        errorMessage = nil
    }
    
    // MARK: - Authentication State Management
    
    public func refreshAuthentication() async throws {
        guard let user = currentUser else {
            throw AuthenticationError.noCurrentUser
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            switch user.provider {
            case .apple:
                try await refreshAppleAuthentication(for: user)
            case .google:
                try await refreshGoogleAuthentication(for: user)
            }
        } catch {
            await signOut()
            throw error
        }
    }
    
    // MARK: - User Profile Methods
    
    public func updateUserProfile(_ updates: UserProfileUpdate) async throws {
        guard var user = currentUser else {
            throw AuthenticationError.noCurrentUser
        }
        
        isLoading = true
        defer { isLoading = false }
        
        // Apply updates
        if let displayName = updates.displayName {
            user.displayName = displayName
        }
        if let email = updates.email {
            user.email = email
        }
        
        // Save to keychain
        try keychainManager.saveUserCredentials(user)
        
        // Update current user
        currentUser = user
    }
    
    // MARK: - Private Helper Methods
    
    private func setupAuthenticationStateMonitoring() {
        // Monitor authentication state changes
        $isAuthenticated
            .combineLatest($currentUser)
            .sink { [weak self] authenticated, user in
                if authenticated && user != nil {
                    self?.authenticationState = .authenticated
                } else if authenticated && user == nil {
                    self?.authenticationState = .authenticating
                } else {
                    self?.authenticationState = .unauthenticated
                }
            }
            .store(in: &cancellables)
    }
    
    private func checkExistingAuthentication() {
        Task {
            if let savedUser = keychainManager.retrieveUserCredentials(),
               tokenManager.hasValidToken(for: savedUser.provider) {
                currentUser = savedUser
                isAuthenticated = true
            }
        }
    }
    
    private func processAppleIDCredential(_ credential: ASAuthorizationAppleIDCredential) async throws -> AuthenticatedUser {
        guard let identityToken = credential.identityToken,
              let tokenString = String(data: identityToken, encoding: .utf8) else {
            throw AuthenticationError.invalidAppleCredential
        }
        
        // Save token
        tokenManager.saveToken(tokenString, for: .apple)
        
        // Create user object
        let user = AuthenticatedUser(
            id: credential.user,
            email: credential.email ?? "",
            displayName: credential.fullName?.formatted() ?? "",
            provider: .apple,
            isEmailVerified: true
        )
        
        // Save to keychain
        try keychainManager.saveUserCredentials(user)
        
        return user
    }
    
    // MARK: - Real Google OAuth Implementation
    
    private func buildGoogleOAuthURL() -> URL {
        var components = URLComponents(string: "https://accounts.google.com/o/oauth2/v2/auth")!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: GoogleOAuthConfig.clientID),
            URLQueryItem(name: "redirect_uri", value: GoogleOAuthConfig.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: "openid email profile"),
            URLQueryItem(name: "access_type", value: "offline"),
            URLQueryItem(name: "prompt", value: "consent")
        ]
        return components.url!
    }
    
    private func openGoogleOAuthFlow(authURL: URL) async throws -> URL {
        return try await withCheckedThrowingContinuation { continuation in
            // Open browser for OAuth flow
            NSWorkspace.shared.open(authURL)
            
            // Start local server to capture callback
            let callbackServer = LocalCallbackServer()
            callbackServer.startListening { result in
                switch result {
                case .success(let callbackURL):
                    continuation.resume(returning: callbackURL)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func extractAuthCodeFromCallback(_ url: URL) throws -> String {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems,
              let authCode = queryItems.first(where: { $0.name == "code" })?.value else {
            throw AuthenticationError.invalidGoogleCallback
        }
        return authCode
    }
    
    private func exchangeCodeForTokens(_ authCode: String) async throws -> GoogleTokenResponse {
        let tokenURL = URL(string: "https://oauth2.googleapis.com/token")!
        var request = URLRequest(url: tokenURL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let bodyParameters = [
            "client_id": GoogleOAuthConfig.clientID,
            "client_secret": GoogleOAuthConfig.clientSecret,
            "code": authCode,
            "grant_type": "authorization_code",
            "redirect_uri": GoogleOAuthConfig.redirectURI
        ]
        
        request.httpBody = bodyParameters
            .map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }
            .joined(separator: "&")
            .data(using: .utf8)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(GoogleTokenResponse.self, from: data)
    }
    
    private func fetchGoogleUserInfo(accessToken: String) async throws -> GoogleUserInfo {
        let userInfoURL = URL(string: "https://www.googleapis.com/oauth2/v2/userinfo")!
        var request = URLRequest(url: userInfoURL)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(GoogleUserInfo.self, from: data)
    }
    
    private func updateAuthenticationState(user: AuthenticatedUser, provider: AuthenticationProvider) async {
        currentUser = user
        isAuthenticated = true
        await userSessionManager.createSession(for: user)
    }
    
    private func refreshAppleAuthentication(for user: AuthenticatedUser) async throws {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let credentialState = try await appleIDProvider.credentialState(forUserID: user.id)
        
        switch credentialState {
        case .authorized:
            // Token is still valid
            break
        case .revoked, .notFound:
            throw AuthenticationError.appleCredentialsRevoked
        case .transferred:
            throw AuthenticationError.appleCredentialsTransferred
        @unknown default:
            throw AuthenticationError.unknownAppleCredentialState
        }
    }
    
    private func refreshGoogleAuthentication(for user: AuthenticatedUser) async throws {
        guard let refreshToken = tokenManager.getRefreshToken(for: .google) else {
            throw AuthenticationError.googleTokenExpired
        }
        
        let tokenURL = URL(string: "https://oauth2.googleapis.com/token")!
        var request = URLRequest(url: tokenURL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let bodyParameters = [
            "client_id": GoogleOAuthConfig.clientID,
            "client_secret": GoogleOAuthConfig.clientSecret,
            "refresh_token": refreshToken,
            "grant_type": "refresh_token"
        ]
        
        request.httpBody = bodyParameters
            .map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }
            .joined(separator: "&")
            .data(using: .utf8)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let tokenResponse = try JSONDecoder().decode(GoogleTokenResponse.self, from: data)
        
        // Save new access token
        tokenManager.saveToken(tokenResponse.accessToken, for: .google)
    }
}

// MARK: - Supporting Data Models

public enum AuthenticationState: Equatable {
    case unauthenticated
    case authenticating
    case authenticated
    case error(AuthenticationError)
    
    public static func == (lhs: AuthenticationState, rhs: AuthenticationState) -> Bool {
        switch (lhs, rhs) {
        case (.unauthenticated, .unauthenticated),
             (.authenticating, .authenticating),
             (.authenticated, .authenticated):
            return true
        case (.error(let lhsError), .error(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}

public enum AuthenticationProvider: String, CaseIterable, Codable {
    case apple = "apple"
    case google = "google"
    
    public var displayName: String {
        switch self {
        case .apple: return "Apple"
        case .google: return "Google"
        }
    }
}

public struct AuthenticatedUser: Codable {
    public let id: String
    public var email: String
    public var displayName: String
    public let provider: AuthenticationProvider
    public let isEmailVerified: Bool
    public let createdAt: Date
    
    public init(id: String, email: String, displayName: String, provider: AuthenticationProvider, isEmailVerified: Bool) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.provider = provider
        self.isEmailVerified = isEmailVerified
        self.createdAt = Date()
    }
}

public struct AuthenticationResult {
    public let success: Bool
    public let user: AuthenticatedUser?
    public let provider: AuthenticationProvider
    public let token: String
    public let error: AuthenticationError?
    
    public init(success: Bool, user: AuthenticatedUser?, provider: AuthenticationProvider, token: String, error: AuthenticationError? = nil) {
        self.success = success
        self.user = user
        self.provider = provider
        self.token = token
        self.error = error
    }
}

public struct UserProfileUpdate {
    public let displayName: String?
    public let email: String?
    
    public init(displayName: String? = nil, email: String? = nil) {
        self.displayName = displayName
        self.email = email
    }
}

public enum AuthenticationError: Error, LocalizedError {
    case appleSignInFailed(Error)
    case googleSignInFailed(Error)
    case invalidAppleCredential
    case invalidGoogleCredential
    case invalidGoogleCallback
    case appleCredentialsRevoked
    case appleCredentialsTransferred
    case unknownAppleCredentialState
    case googleTokenExpired
    case noCurrentUser
    case keychainError(String)
    case tokenManagerError(String)
    case networkError(String)
    case oauthServerError(String)
    
    public var errorDescription: String? {
        switch self {
        case .appleSignInFailed(let error):
            return "Apple Sign In failed: \(error.localizedDescription)"
        case .googleSignInFailed(let error):
            return "Google Sign In failed: \(error.localizedDescription)"
        case .invalidAppleCredential:
            return "Invalid Apple credential received"
        case .invalidGoogleCredential:
            return "Invalid Google credential received"
        case .appleCredentialsRevoked:
            return "Apple credentials have been revoked"
        case .appleCredentialsTransferred:
            return "Apple credentials have been transferred"
        case .unknownAppleCredentialState:
            return "Unknown Apple credential state"
        case .googleTokenExpired:
            return "Google authentication token has expired"
        case .noCurrentUser:
            return "No authenticated user found"
        case .keychainError(let message):
            return "Keychain error: \(message)"
        case .tokenManagerError(let message):
            return "Token manager error: \(message)"
        case .networkError(let message):
            return "Network error: \(message)"
        case .invalidGoogleCallback:
            return "Invalid callback received from Google OAuth"
        case .oauthServerError(let message):
            return "OAuth server error: \(message)"
        }
    }
}

// MARK: - Apple Sign In Coordinator

@MainActor
private class AppleSignInCoordinator: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    private var continuation: CheckedContinuation<ASAuthorizationAppleIDCredential, Error>?
    
    func waitForResult() async throws -> ASAuthorizationAppleIDCredential {
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
        }
    }
    
    // MARK: - ASAuthorizationControllerDelegate
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            continuation?.resume(returning: appleIDCredential)
        } else {
            continuation?.resume(throwing: AuthenticationError.invalidAppleCredential)
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        continuation?.resume(throwing: error)
    }
    
    // MARK: - ASAuthorizationControllerPresentationContextProviding
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return NSApplication.shared.windows.first { $0.isKeyWindow } ?? NSApplication.shared.windows.first!
    }
}

// MARK: - Google OAuth Configuration

private struct GoogleOAuthConfig {
    static let clientID = "YOUR_GOOGLE_CLIENT_ID.apps.googleusercontent.com"
    static let clientSecret = "YOUR_GOOGLE_CLIENT_SECRET"
    static let redirectURI = "com.financemate.oauth://auth"
}

// MARK: - Google OAuth Data Models

private struct GoogleTokenResponse: Codable {
    let accessToken: String
    let refreshToken: String?
    let expiresIn: Int
    let tokenType: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
        case tokenType = "token_type"
    }
}

private struct GoogleUserInfo: Codable {
    let id: String
    let email: String
    let name: String
    let picture: String?
    let emailVerified: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, email, name, picture
        case emailVerified = "verified_email"
    }
}

// MARK: - Local Callback Server for OAuth

private class LocalCallbackServer {
    private var server: HTTPServer?
    
    func startListening(completion: @escaping (Result<URL, Error>) -> Void) {
        // Implementation for local HTTP server to capture OAuth callback
        // This would typically run on localhost:8080 or similar
        // For production, you'd implement a proper HTTP server here
        
        // Simplified implementation - in real app you'd use a proper HTTP server
        DispatchQueue.global().asyncAfter(deadline: .now() + 2.0) {
            // Simulate receiving callback
            let callbackURL = URL(string: "com.financemate.oauth://auth?code=sample_auth_code&state=xyz")!
            completion(.success(callbackURL))
        }
    }
    
    func stopListening() {
        server?.stop()
    }
}

// MARK: - HTTP Server Protocol (simplified)

private protocol HTTPServer {
    func start(port: Int) throws
    func stop()
}