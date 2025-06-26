//
//  AuthenticationService.swift
//  FinanceMate
//
//  Purpose: Main authentication service integrating all security components
//  Provides a unified interface for authentication across the app

import AuthenticationServices
import Combine
import Foundation
import SwiftUI

// MARK: - Apple Auth Data Model

// AppleAuthData is now defined in CommonTypes.swift

@MainActor
public class AuthenticationService: ObservableObject {
    // MARK: - Published Properties

    @Published public var isAuthenticated: Bool = false
    @Published public var currentUser: AuthenticatedUser?
    @Published public var authenticationState: AuthenticationState = .unauthenticated
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?
    @Published public var requiresBiometric: Bool = false
    @Published public var sessionExpiresAt: Date?

    // MARK: - Security Components

    private let oauth2Manager = OAuth2Manager.shared
    private let sessionManager = SessionManager.shared
    private let biometricManager = BiometricAuthManager.shared
    // Note: Using the basic keychain manager for API keys
    private let keychainManager = KeychainManager.shared
    private let auditLogger = SecurityAuditLogger.shared

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    public init() {
        setupBindings()
        checkExistingAuthentication()
    }

    // MARK: - Authentication Methods

    public func signInWithApple() async throws -> AuthenticationResult {
        isLoading = true
        defer { isLoading = false }

        do {
            // Use OAuth2Manager for Apple Sign In
            try await oauth2Manager.authenticate(with: .apple)

            // Wait for OAuth2Manager to update
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

            guard let user = oauth2Manager.currentUser else {
                throw AuthenticationError.networkError("No user returned from Apple Sign In")
            }

            // Create session with optional biometric
            if biometricManager.isBiometricAvailable && requiresBiometric {
                try await sessionManager.createSession(for: user, withBiometric: true)
            } else {
                try await sessionManager.createSession(for: user)
            }

            // Update local state
            currentUser = user
            isAuthenticated = true
            authenticationState = .authenticated

            return AuthenticationResult(
                success: true,
                user: user,
                provider: .apple,
                token: "apple_token" // OAuth2Manager handles actual token
            )
        } catch {
            errorMessage = "Apple Sign In failed: \(error.localizedDescription)"
            auditLogger.log(event: .authenticationFailure(
                userId: "unknown",
                reason: error.localizedDescription
            ))
            throw AuthenticationError.appleSignInFailed(error)
        }
    }

    public func handleAppleSignIn(authData: AppleAuthData) async throws {
        isLoading = true
        defer { isLoading = false }

        do {
            // Create authenticated user from Apple credentials
            let user = AuthenticatedUser(
                id: authData.userIdentifier,
                email: authData.email,
                name: authData.fullName,
                pictureURL: nil
            )

            // Create session with optional biometric
            if biometricManager.isBiometricAvailable && requiresBiometric {
                try await sessionManager.createSession(for: user, withBiometric: true)
            } else {
                try await sessionManager.createSession(for: user)
            }

            // Update OAuth2Manager state
            oauth2Manager.currentUser = user
            oauth2Manager.isAuthenticated = true

            // Update local state
            currentUser = user
            isAuthenticated = true
            authenticationState = .authenticated

            // Audit log
            auditLogger.log(event: .authenticationSuccess(
                userId: user.id,
                method: .appleSignIn
            ))
        } catch {
            errorMessage = "Apple Sign In failed: \(error.localizedDescription)"
            auditLogger.log(event: .authenticationFailure(
                userId: "unknown",
                reason: error.localizedDescription
            ))
            throw error
        }
    }

    public func signInWithGoogle() async throws -> AuthenticationResult {
        isLoading = true
        defer { isLoading = false }

        do {
            // Use OAuth2Manager for Google Sign In
            try await oauth2Manager.authenticate(with: .google)

            // OAuth callback will be handled by the app's URL handler
            // which should call handleOAuthCallback

            guard let user = oauth2Manager.currentUser else {
                throw AuthenticationError.networkError("Google authentication incomplete")
            }

            // Create session
            if biometricManager.isBiometricAvailable && requiresBiometric {
                try await sessionManager.createSession(for: user, withBiometric: true)
            } else {
                try await sessionManager.createSession(for: user)
            }

            // Update local state
            currentUser = user
            isAuthenticated = true
            authenticationState = .authenticated

            return AuthenticationResult(
                success: true,
                user: user,
                provider: .google,
                token: "google_token" // OAuth2Manager handles actual token
            )
        } catch {
            errorMessage = "Google Sign In failed: \(error.localizedDescription)"
            auditLogger.log(event: .authenticationFailure(
                userId: "unknown",
                reason: error.localizedDescription
            ))
            throw AuthenticationError.googleSignInFailed(error)
        }
    }

    // MARK: - OAuth Callback Handler

    public func handleOAuthCallback(url: URL) async throws {
        do {
            try await oauth2Manager.handleOAuthCallback(url: url)

            guard let user = oauth2Manager.currentUser else {
                throw AuthenticationError.networkError("No user after OAuth callback")
            }

            // Create session after successful OAuth
            if biometricManager.isBiometricAvailable && requiresBiometric {
                try await sessionManager.createSession(for: user, withBiometric: true)
            } else {
                try await sessionManager.createSession(for: user)
            }

            currentUser = user
            isAuthenticated = true
            authenticationState = .authenticated
        } catch {
            errorMessage = "OAuth callback failed: \(error.localizedDescription)"
            throw error
        }
    }

    // MARK: - Biometric Authentication

    public func enableBiometricAuthentication() async throws {
        guard biometricManager.isBiometricAvailable else {
            throw AuthenticationError.keychainError("Biometric authentication is not available on this device")
        }

        try await biometricManager.enableBiometricAuth()
        requiresBiometric = true

        // Re-create session with biometric if already authenticated
        if let user = currentUser {
            try await sessionManager.createSession(for: user, withBiometric: true)
        }
    }

    public func disableBiometricAuthentication() async throws {
        try await biometricManager.disableBiometricAuth()
        requiresBiometric = false

        // Re-create session without biometric
        if let user = currentUser {
            try await sessionManager.createSession(for: user, withBiometric: false)
        }
    }

    public func authenticateWithBiometric(reason: String) async throws -> Bool {
        try await biometricManager.authenticate(reason: reason)
    }

    // MARK: - Session Management

    public func validateSession() async throws {
        guard sessionManager.isSessionActive else {
            throw AuthenticationError.keychainError("Your session has expired. Please sign in again.")
        }

        do {
            // Validate with SessionManager
            let isValid = try await sessionManager.validateSession()

            if !isValid {
                throw AuthenticationError.keychainError("Your session has expired. Please sign in again.")
            }

            // Refresh OAuth tokens if needed
            try await oauth2Manager.refreshTokenIfNeeded()
        } catch {
            // Session invalid - sign out
            await signOut()
            throw error
        }
    }

    public func extendSession() async throws {
        try await sessionManager.extendSession()
    }

    public func lockSession() async {
        await sessionManager.lockSession()
        authenticationState = .error(.keychainError("Session expired"))
    }

    public func unlockSession() async throws {
        try await sessionManager.unlockSession()
        authenticationState = .authenticated
    }

    // MARK: - Sign Out

    public func signOut() async {
        isLoading = true
        defer { isLoading = false }

        // Terminate session
        try? await sessionManager.terminateSession(reason: "User initiated sign out")

        // Sign out from OAuth
        try? await oauth2Manager.signOut()

        // Clear local state
        currentUser = nil
        isAuthenticated = false
        authenticationState = .unauthenticated
        sessionExpiresAt = nil
        errorMessage = nil
    }

    // MARK: - Authorization

    public func authorizeAction(_ action: SecurityAction) async throws {
        try await sessionManager.authorizeAction(action)
    }

    // MARK: - Security Audit

    public func getSecurityAuditReport() -> AuditVerificationResult {
        auditLogger.verifyAuditLog()
    }

    public func exportSecurityAuditLog(from startDate: Date, to endDate: Date) -> Data? {
        auditLogger.exportAuditLog(from: startDate, to: endDate)
    }

    // MARK: - Private Methods

    private func setupBindings() {
        // Bind OAuth2Manager state
        oauth2Manager.$isAuthenticated
            .sink { [weak self] isAuthenticated in
                self?.isAuthenticated = isAuthenticated
            }
            .store(in: &cancellables)

        oauth2Manager.$currentUser
            .sink { [weak self] user in
                self?.currentUser = user
            }
            .store(in: &cancellables)

        // Bind SessionManager state
        sessionManager.$isSessionActive
            .sink { [weak self] isActive in
                if !isActive && self?.isAuthenticated == true {
                    Task {
                        await self?.signOut()
                    }
                }
            }
            .store(in: &cancellables)

        sessionManager.$sessionExpiresAt
            .sink { [weak self] expiresAt in
                self?.sessionExpiresAt = expiresAt
            }
            .store(in: &cancellables)

        sessionManager.$requiresReauthentication
            .sink { [weak self] requiresReauth in
                if requiresReauth {
                    self?.authenticationState = .error(.keychainError("Session requires reauthentication"))
                }
            }
            .store(in: &cancellables)

        // Monitor authentication state
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

        // Check biometric settings
        requiresBiometric = biometricManager.isBiometricAuthEnabled()
    }

    private func checkExistingAuthentication() {
        Task {
            do {
                // Try to validate existing session
                try await oauth2Manager.validateSession()

                if oauth2Manager.isAuthenticated,
                   let user = oauth2Manager.currentUser {
                    // Restore session
                    if try await sessionManager.validateSession() {
                        currentUser = user
                        isAuthenticated = true
                        authenticationState = .authenticated
                    }
                }
            } catch {
                // No valid session - stay logged out
                print("No existing valid session: \(error)")
            }
        }
    }
}

// MARK: - Authentication State Extensions

extension AuthenticationState {
    public var displayText: String {
        switch self {
        case .unauthenticated: return "Not Signed In"
        case .authenticating: return "Signing In..."
        case .authenticated: return "Signed In"
        case .error: return "Error"
        }
    }

    public var icon: String {
        switch self {
        case .unauthenticated: return "person.crop.circle.badge.xmark"
        case .authenticating: return "person.crop.circle.badge.clock"
        case .authenticated: return "person.crop.circle.badge.checkmark"
        case .error: return "exclamationmark.circle"
        }
    }

    public var color: Color {
        switch self {
        case .unauthenticated: return .gray
        case .authenticating: return .orange
        case .authenticated: return .green
        case .error: return .red
        }
    }
}
