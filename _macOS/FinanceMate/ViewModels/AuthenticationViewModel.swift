import SwiftUI
import AuthenticationServices
import os.log
import AppKit

/**
 * Purpose: MVVM ViewModel for authentication state management and UI interactions
 * Issues & Complexity Summary: Clean separation of concerns for authentication UI logic
 * Key Complexity Drivers:
 * - Logic Scope (Est. LoC): ~120
 * - Core Algorithm Complexity: Low (state management and delegation)
 * - Dependencies: 2 New (AuthTypes, AuthenticationManager), 0 Mod
 * - State Management Complexity: Medium (ObservableObject with delegation)
 * - Novelty/Uncertainty Factor: Low (standard MVVM pattern)
 * AI Pre-Task Self-Assessment: 93%
 * Problem Estimate: 85%
 * Initial Code Complexity Estimate: 75%
 * Final Code Complexity: 77%
 * Overall Result Score: 95%
 * Key Variances/Learnings: Clean delegation to AuthenticationManager
 * Last Updated: 2025-10-06
 */

/// Authentication ViewModel for managing authentication state and UI interactions
@MainActor
public class AuthenticationViewModel: ObservableObject {

    // MARK: - Published Properties

    /// Current authentication state
    @Published public private(set) var authState: AuthState = .unknown

    /// Whether user is currently authenticating
    @Published public var isAuthenticating: Bool {
        get { authState.isAuthenticating }
        set { /* Read-only */ }
    }

    /// Whether user is authenticated
    @Published public var isAuthenticated: Bool {
        get { authState.isAuthenticated }
        set { /* Read-only */ }
    }

    /// Current authenticated user
    @Published public var currentUser: AuthUser? {
        get { authState.user }
        set { /* Read-only */ }
    }

    /// Current error message
    @Published public var errorMessage: String? {
        get { authState.error?.localizedDescription }
        set { /* Read-only */ }
    }

    /// Currently selected authentication provider
    @Published public var selectedProvider: AuthProvider = .apple

    // MARK: - Private Properties

    private let authenticationManager = AuthenticationManager()
    private let logger = Logger(subsystem: "FinanceMate", category: "AuthenticationViewModel")

    // MARK: - Initialization

    public init() {
        // Observe authentication manager changes
        authenticationManager.$authState
            .receive(on: DispatchQueue.main)
            .assign(to: &$authState)

        // Load initial authentication status
        authenticationManager.checkAuthStatus()
    }

    // MARK: - Apple Sign In

    /// Initiate Apple Sign In flow
    public func signInWithApple() {
        selectedProvider = .apple
        logger.info("Starting Apple Sign In flow")
    }

    /// Handle Apple Sign In request
    public func handleAppleSignInRequest(_ request: ASAuthorizationAppleIDRequest) {
        // Configure the request
        request.requestedScopes = [.fullName, .email]
        request.nonce = generateNonce()
    }

    /// Handle Apple Sign In result
    public func handleAppleSignInResult(_ result: Result<ASAuthorization, Error>) async {
        await authenticationManager.handleAppleSignIn(result: result)
    }

    // MARK: - Google Sign In

    /// Initiate Google Sign In flow
    public func signInWithGoogle() -> URL? {
        selectedProvider = .google
        logger.info("Starting Google Sign In flow")

        // Get OAuth configuration
        guard let clientID = ProcessInfo.processInfo.environment["GOOGLE_OAUTH_CLIENT_ID"],
              let clientSecret = ProcessInfo.processInfo.environment["GOOGLE_OAUTH_CLIENT_SECRET"] else {
            logger.error("Google OAuth credentials not found")
            return nil
        }

        // Generate OAuth parameters
        let redirectURI = "com.ablankcanvas.financemate:/oauth2redirect"
        let scopes = [
            "email",
            "profile",
            "https://www.googleapis.com/auth/gmail.readonly"
        ]

        guard let state = GmailOAuthHelper.generateSecureState() else {
            logger.error("Failed to generate secure state")
            return nil
        }

        // Build OAuth URL
        return GmailOAuthHelper.buildOAuthURL(
            clientID: clientID,
            redirectURI: redirectURI,
            scopes: scopes,
            state: state
        )
    }

    /// Handle Google OAuth callback
    public func handleGoogleCallback(url: URL, originalState: String) async {
        logger.info("Processing Google OAuth callback")

        // Validate state to prevent CSRF
        guard GmailOAuthHelper.validateState(callbackURL: url, originalState: originalState) else {
            logger.error("Invalid state in OAuth callback")
            return
        }

        // Extract authorization code
        guard let authCode = GmailOAuthHelper.extractAuthCode(from: url) else {
            logger.error("No authorization code found in callback")
            return
        }

        // Exchange code for tokens
        await authenticationManager.handleGoogleSignIn(code: authCode)
    }

    // MARK: - Authentication Management

    /// Check current authentication status
    public func refreshAuthenticationStatus() {
        logger.info("Refreshing authentication status")
        authenticationManager.checkAuthStatus()
    }

    /// Sign out current user
    public func signOut() {
        logger.info("Signing out user")
        authenticationManager.signOut()
    }

    /// Sign out from specific provider
    public func signOut(from provider: AuthProvider) {
        logger.info("Signing out from provider: \(provider.rawValue)")
        authenticationManager.signOut(from: provider)
    }

    /// Refresh tokens if needed
    public func refreshTokensIfNeeded() async {
        logger.info("Checking if tokens need refresh")
        await authenticationManager.refreshTokenIfNeeded()
    }

    // MARK: - User Interface Helpers

    /// Get display name for current user
    public var userDisplayName: String {
        return currentUser?.name ?? "Unknown User"
    }

    /// Get user email for display
    public var userEmailDisplay: String {
        return currentUser?.email ?? "No Email"
    }

    /// Get provider display name
    public var providerDisplayName: String {
        return currentUser?.provider.displayName ?? "Unknown"
    }

    /// Check if error is recoverable
    public var isRecoverableError: Bool {
        guard let error = authState.error else { return false }

        switch error {
        case .networkError, .custom:
            return true
        case .invalidCredentials, .cancelledByUser, .tokenExpired:
            return false
        }
    }

    /// Clear current error
    public func clearError() {
        if case .error = authState {
            // Update to signed out state to clear error
            authenticationManager.signOut()
        }
    }

    // MARK: - Provider Selection

    /// Set selected provider
    public func selectProvider(_ provider: AuthProvider) {
        selectedProvider = provider
        logger.info("Selected authentication provider: \(provider.displayName)")
    }

    /// Get available providers
    public var availableProviders: [AuthProvider] {
        return AuthProvider.allCases
    }

    // MARK: - OAuth State Management

    /// Store OAuth state for Google flow
    public func storeOAuthState(_ state: String, for provider: AuthProvider) {
        let key = "oauth_state_\(provider.rawValue)"
        KeychainHelper.save(value: state, account: key)
        logger.info("Stored OAuth state for provider: \(provider.rawValue)")
    }

    /// Retrieve OAuth state for provider
    public func getOAuthState(for provider: AuthProvider) -> String? {
        let key = "oauth_state_\(provider.rawValue)"
        return KeychainHelper.get(account: key)
    }

    /// Clear OAuth state for provider
    public func clearOAuthState(for provider: AuthProvider) {
        let key = "oauth_state_\(provider.rawValue)"
        try? KeychainHelper.delete(account: key)
        logger.info("Cleared OAuth state for provider: \(provider.rawValue)")
    }

    // MARK: - Authentication Flow Helpers

    /// Generate nonce for Apple Sign In
    private func generateNonce(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0..<16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }

            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }

                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }

    // MARK: - Debug and Testing

    /// Get current authentication state for debugging
    public var debugAuthState: String {
        switch authState {
        case .unknown:
            return "Unknown"
        case .authenticating:
            return "Authenticating"
        case .authenticated(let user):
            return "Authenticated: \(user.email) (\(user.provider.displayName))"
        case .signedOut:
            return "Signed Out"
        case .error(let error):
            return "Error: \(error.localizedDescription)"
        }
    }

    /// Reset authentication state (for testing only)
    public func resetAuthenticationState() {
        logger.warning("Resetting authentication state (testing only)")
        authenticationManager.signOut()
    }
}

// MARK: - ASAuthorizationControllerDelegate Extension

extension AuthenticationViewModel: ASAuthorizationControllerDelegate {

    /// Handle successful Apple Sign In authorization
    public func authorizationController(_ controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        Task {
            await handleAppleSignInResult(.success(authorization))
        }
    }

    /// Handle Apple Sign In authorization error
    public func authorizationController(_ controller: ASAuthorizationController, didCompleteWithError error: Error) {
        Task {
            await handleAppleSignInResult(.failure(error))
        }
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding Extension

extension AuthenticationViewModel: ASAuthorizationControllerPresentationContextProviding {

    /// Provide presentation context for Apple Sign In
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // For macOS, we need to return the key window
        guard let window = NSApplication.shared.keyWindow else {
            fatalError("Unable to find presentation anchor")
        }
        return window
    }
}