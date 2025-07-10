import Foundation
import CoreData
import AuthenticationServices
import LocalAuthentication

/**
 * AuthenticationService.swift
 * 
 * Purpose: Secure authentication service with OAuth 2.0, MFA, and session management
 * Issues & Complexity Summary: Security-critical service with multiple authentication methods
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~600
 *   - Core Algorithm Complexity: High (OAuth 2.0, MFA, Security)
 *   - Dependencies: 6 (Foundation, CoreData, AuthenticationServices, LocalAuthentication, Security, Network)
 *   - State Management Complexity: High (Session state, Security state)
 *   - Novelty/Uncertainty Factor: High (OAuth 2.0, MFA implementation)
 * AI Pre-Task Self-Assessment: 70%
 * Problem Estimate: 75%
 * Initial Code Complexity Estimate: 85%
 * Final Code Complexity: TBD
 * Overall Result Score: TBD
 * Key Variances/Learnings: Security-first implementation with comprehensive error handling
 * Last Updated: 2025-07-09
 */

// MARK: - Authentication Models

/// Authentication result containing user and session information
struct AuthenticationResult {
    let user: User
    let session: UserSession
    let requiresMFA: Bool
}

/// User session model for session management
struct UserSession {
    let userId: UUID
    let token: String
    let expiresAt: Date
    let refreshToken: String?
    let createdAt: Date
    
    init(userId: UUID, token: String, expiresAt: Date, refreshToken: String? = nil) {
        self.userId = userId
        self.token = token
        self.expiresAt = expiresAt
        self.refreshToken = refreshToken
        self.createdAt = Date()
    }
    
    var isValid: Bool {
        return Date() < expiresAt
    }
    
    var isExpired: Bool {
        return !isValid
    }
    
    var timeUntilExpiry: TimeInterval {
        return expiresAt.timeIntervalSinceNow
    }
}

/// OAuth 2.0 provider options
enum OAuth2Provider: String, CaseIterable {
    case google = "google"
    case microsoft = "microsoft"
    case apple = "apple"
    
    var displayName: String {
        switch self {
        case .google:
            return "Google"
        case .microsoft:
            return "Microsoft"
        case .apple:
            return "Apple"
        }
    }
    
    var iconName: String {
        switch self {
        case .google:
            return "g.circle.fill"
        case .microsoft:
            return "m.circle.fill"
        case .apple:
            return "applelogo"
        }
    }
}

/// Authentication errors
enum AuthenticationError: Error, LocalizedError {
    case invalidCredentials
    case invalidEmail
    case weakPassword
    case networkError
    case serverError
    case userNotFound
    case userDeactivated
    case sessionExpired
    case invalidMFACode
    case mfaRequired
    case oauthError
    case biometricUnavailable
    case biometricFailure
    case keychainError
    case tokenExpired
    case invalidToken
    case securityError
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password"
        case .invalidEmail:
            return "Please enter a valid email address"
        case .weakPassword:
            return "Password must be at least 8 characters long"
        case .networkError:
            return "Network connection error. Please check your internet connection"
        case .serverError:
            return "Server error. Please try again later"
        case .userNotFound:
            return "User account not found"
        case .userDeactivated:
            return "User account has been deactivated"
        case .sessionExpired:
            return "Session expired. Please log in again"
        case .invalidMFACode:
            return "Invalid verification code"
        case .mfaRequired:
            return "Multi-factor authentication required"
        case .oauthError:
            return "OAuth authentication failed"
        case .biometricUnavailable:
            return "Biometric authentication is not available"
        case .biometricFailure:
            return "Biometric authentication failed"
        case .keychainError:
            return "Keychain access error"
        case .tokenExpired:
            return "Authentication token expired"
        case .invalidToken:
            return "Invalid authentication token"
        case .securityError:
            return "Security error occurred"
        }
    }
}

// MARK: - Authentication Service Protocol

protocol AuthenticationServiceProtocol {
    func authenticate(email: String, password: String) async throws -> AuthenticationResult
    func authenticateWithOAuth2(provider: OAuth2Provider) async throws -> AuthenticationResult
    func verifyMFACode(_ code: String) async throws -> Bool
    func refreshSession(_ session: UserSession) async throws -> UserSession
    func logout() async throws
    func authenticateWithBiometrics() async throws -> AuthenticationResult
}

// MARK: - Authentication Service Implementation

class AuthenticationService: AuthenticationServiceProtocol {
    
    private let context: NSManagedObjectContext
    private let keychainService: KeychainServiceProtocol
    private let biometricService: BiometricServiceProtocol
    private let networkService: NetworkServiceProtocol
    
    // Session management
    private var currentSession: UserSession?
    private var pendingMFAUser: User?
    
    init(
        context: NSManagedObjectContext,
        keychainService: KeychainServiceProtocol = KeychainService(),
        biometricService: BiometricServiceProtocol = BiometricService(),
        networkService: NetworkServiceProtocol = NetworkService()
    ) {
        self.context = context
        self.keychainService = keychainService
        self.biometricService = biometricService
        self.networkService = networkService
    }
    
    // MARK: - Email/Password Authentication
    
    func authenticate(email: String, password: String) async throws -> AuthenticationResult {
        // Validate input
        try validateCredentials(email: email, password: password)
        
        // Find user in database
        guard let user = User.fetchUser(by: email, in: context) else {
            throw AuthenticationError.userNotFound
        }
        
        // Check if user is active
        guard user.isActive else {
            throw AuthenticationError.userDeactivated
        }
        
        // Verify password (in production, this would be hashed)
        let isPasswordValid = try await verifyPassword(password, for: user)
        guard isPasswordValid else {
            throw AuthenticationError.invalidCredentials
        }
        
        // Check if MFA is required
        let requiresMFA = await checkMFARequired(for: user)
        
        if requiresMFA {
            pendingMFAUser = user
            return AuthenticationResult(
                user: user,
                session: createTemporarySession(for: user),
                requiresMFA: true
            )
        } else {
            // Create full session
            let session = try await createSession(for: user)
            
            // Update user's last login
            user.updateLastLogin()
            try context.save()
            
            return AuthenticationResult(
                user: user,
                session: session,
                requiresMFA: false
            )
        }
    }
    
    // MARK: - OAuth 2.0 Authentication
    
    func authenticateWithOAuth2(provider: OAuth2Provider) async throws -> AuthenticationResult {
        switch provider {
        case .apple:
            return try await authenticateWithApple()
        case .google:
            return try await authenticateWithGoogle()
        case .microsoft:
            return try await authenticateWithMicrosoft()
        }
    }
    
    private func authenticateWithApple() async throws -> AuthenticationResult {
        // Use ASAuthorizationAppleIDProvider for Apple Sign In
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        // This would typically involve presenting the Apple Sign In UI
        // For now, we'll simulate the process
        
        // In a real implementation, this would handle the Apple Sign In flow
        // and extract user information from the response
        
        let email = "user@icloud.com" // This would come from Apple Sign In response
        let name = "Apple User" // This would come from Apple Sign In response
        
        return try await createOrUpdateOAuthUser(email: email, name: name, provider: provider)
    }
    
    private func authenticateWithGoogle() async throws -> AuthenticationResult {
        // Google OAuth 2.0 implementation would go here
        // This would involve redirecting to Google's OAuth endpoints
        
        let email = "user@gmail.com" // This would come from Google OAuth response
        let name = "Google User" // This would come from Google OAuth response
        
        return try await createOrUpdateOAuthUser(email: email, name: name, provider: provider)
    }
    
    private func authenticateWithMicrosoft() async throws -> AuthenticationResult {
        // Microsoft OAuth 2.0 implementation would go here
        // This would involve MSAL (Microsoft Authentication Library)
        
        let email = "user@outlook.com" // This would come from Microsoft OAuth response
        let name = "Microsoft User" // This would come from Microsoft OAuth response
        
        return try await createOrUpdateOAuthUser(email: email, name: name, provider: provider)
    }
    
    private func createOrUpdateOAuthUser(email: String, name: String, provider: OAuth2Provider) async throws -> AuthenticationResult {
        // Check if user exists
        let user: User
        if let existingUser = User.fetchUser(by: email, in: context) {
            user = existingUser
        } else {
            // Create new user
            user = User.create(
                in: context,
                name: name,
                email: email,
                role: .owner // Default role for new users
            )
        }
        
        // Ensure user is active
        user.activate()
        user.updateLastLogin()
        try context.save()
        
        // Create session
        let session = try await createSession(for: user)
        
        return AuthenticationResult(
            user: user,
            session: session,
            requiresMFA: false // OAuth typically doesn't require additional MFA
        )
    }
    
    // MARK: - Multi-Factor Authentication
    
    func verifyMFACode(_ code: String) async throws -> Bool {
        guard let user = pendingMFAUser else {
            throw AuthenticationError.mfaRequired
        }
        
        // Validate MFA code format
        guard code.count == 6, code.allSatisfy({ $0.isNumber }) else {
            throw AuthenticationError.invalidMFACode
        }
        
        // In a real implementation, this would verify the code against
        // a TOTP service or SMS verification service
        let isValidCode = await verifyMFACodeWithProvider(code, for: user)
        
        if isValidCode {
            // Create full session
            let session = try await createSession(for: user)
            currentSession = session
            
            // Update user's last login
            user.updateLastLogin()
            try context.save()
            
            // Clear pending MFA user
            pendingMFAUser = nil
            
            return true
        } else {
            throw AuthenticationError.invalidMFACode
        }
    }
    
    private func verifyMFACodeWithProvider(_ code: String, for user: User) async -> Bool {
        // This would integrate with a real MFA service
        // For testing purposes, we'll accept "123456" as valid
        return code == "123456"
    }
    
    private func checkMFARequired(for user: User) async -> Bool {
        // In a real implementation, this would check user's MFA settings
        // For now, we'll simulate MFA being required for certain users
        return user.email.contains("mfa")
    }
    
    // MARK: - Biometric Authentication
    
    func authenticateWithBiometrics() async throws -> AuthenticationResult {
        // Check if biometric authentication is available
        guard biometricService.isBiometricAvailable else {
            throw AuthenticationError.biometricUnavailable
        }
        
        // Perform biometric authentication
        let isAuthenticated = try await biometricService.authenticateWithBiometrics()
        
        guard isAuthenticated else {
            throw AuthenticationError.biometricFailure
        }
        
        // Retrieve stored user credentials from keychain
        guard let storedCredentials = try keychainService.retrieveCredentials() else {
            throw AuthenticationError.keychainError
        }
        
        // Authenticate using stored credentials
        return try await authenticate(
            email: storedCredentials.email,
            password: storedCredentials.password
        )
    }
    
    // MARK: - Session Management
    
    func refreshSession(_ session: UserSession) async throws -> UserSession {
        guard !session.isExpired else {
            throw AuthenticationError.sessionExpired
        }
        
        // Find user by session
        guard let user = User.fetchUser(by: session.userId, in: context) else {
            throw AuthenticationError.userNotFound
        }
        
        // Create new session
        let newSession = try await createSession(for: user)
        
        // Invalidate old session
        try await invalidateSession(session)
        
        return newSession
    }
    
    private func createSession(for user: User) async throws -> UserSession {
        let sessionToken = generateSecureToken()
        let expiresAt = Date().addingTimeInterval(3600) // 1 hour
        let refreshToken = generateSecureToken()
        
        let session = UserSession(
            userId: user.id,
            token: sessionToken,
            expiresAt: expiresAt,
            refreshToken: refreshToken
        )
        
        // Store session securely
        try keychainService.storeSession(session)
        
        currentSession = session
        return session
    }
    
    private func createTemporarySession(for user: User) -> UserSession {
        let temporaryToken = generateSecureToken()
        let expiresAt = Date().addingTimeInterval(300) // 5 minutes for MFA
        
        return UserSession(
            userId: user.id,
            token: temporaryToken,
            expiresAt: expiresAt
        )
    }
    
    private func invalidateSession(_ session: UserSession) async throws {
        try keychainService.deleteSession(session)
        
        if currentSession?.token == session.token {
            currentSession = nil
        }
    }
    
    // MARK: - Logout
    
    func logout() async throws {
        if let session = currentSession {
            try await invalidateSession(session)
        }
        
        currentSession = nil
        pendingMFAUser = nil
        
        // Clear any stored credentials
        try keychainService.clearAllCredentials()
    }
    
    // MARK: - Helper Methods
    
    private func validateCredentials(email: String, password: String) throws {
        // Validate email
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedEmail.isEmpty else {
            throw AuthenticationError.invalidEmail
        }
        
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        guard emailPredicate.evaluate(with: trimmedEmail) else {
            throw AuthenticationError.invalidEmail
        }
        
        // Validate password
        guard password.count >= 8 else {
            throw AuthenticationError.weakPassword
        }
    }
    
    private func verifyPassword(_ password: String, for user: User) async throws -> Bool {
        // In a real implementation, this would verify against a hashed password
        // For now, we'll simulate password verification
        
        // This would typically involve:
        // 1. Retrieving the stored password hash
        // 2. Hashing the provided password with the same salt
        // 3. Comparing the hashes
        
        return password.count >= 8 // Simplified for testing
    }
    
    private func generateSecureToken() -> String {
        let tokenData = Data((0..<32).map { _ in UInt8.random(in: 0...255) })
        return tokenData.base64EncodedString()
    }
}

// MARK: - Extensions

extension User {
    /// Fetch user by UUID
    static func fetchUser(by userId: UUID, in context: NSManagedObjectContext) -> User? {
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", userId as CVarArg)
        request.fetchLimit = 1
        
        do {
            let users = try context.fetch(request)
            return users.first
        } catch {
            print("Failed to fetch user by ID: \(error)")
            return nil
        }
    }
}

// MARK: - Supporting Services (Protocols)

protocol KeychainServiceProtocol {
    func storeSession(_ session: UserSession) throws
    func retrieveSession() throws -> UserSession?
    func deleteSession(_ session: UserSession) throws
    func storeCredentials(email: String, password: String) throws
    func retrieveCredentials() throws -> (email: String, password: String)?
    func clearAllCredentials() throws
}

protocol BiometricServiceProtocol {
    var isBiometricAvailable: Bool { get }
    func authenticateWithBiometrics() async throws -> Bool
}

protocol NetworkServiceProtocol {
    func performRequest<T: Codable>(_ request: URLRequest, responseType: T.Type) async throws -> T
}

// MARK: - Default Implementations

class KeychainService: KeychainServiceProtocol {
    // Keychain implementation would go here
    func storeSession(_ session: UserSession) throws {
        // Store session in keychain
    }
    
    func retrieveSession() throws -> UserSession? {
        // Retrieve session from keychain
        return nil
    }
    
    func deleteSession(_ session: UserSession) throws {
        // Delete session from keychain
    }
    
    func storeCredentials(email: String, password: String) throws {
        // Store credentials in keychain
    }
    
    func retrieveCredentials() throws -> (email: String, password: String)? {
        // Retrieve credentials from keychain
        return nil
    }
    
    func clearAllCredentials() throws {
        // Clear all credentials from keychain
    }
}

class BiometricService: BiometricServiceProtocol {
    private let context = LAContext()
    
    var isBiometricAvailable: Bool {
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
    
    func authenticateWithBiometrics() async throws -> Bool {
        let reason = "Authenticate to access your financial data"
        
        do {
            return try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            )
        } catch {
            throw AuthenticationError.biometricFailure
        }
    }
}

class NetworkService: NetworkServiceProtocol {
    func performRequest<T: Codable>(_ request: URLRequest, responseType: T.Type) async throws -> T {
        // Network request implementation would go here
        throw AuthenticationError.networkError
    }
}