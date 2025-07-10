import XCTest
import CoreData
@testable import FinanceMate

/**
 * AuthenticationViewModelTests.swift
 * 
 * Purpose: TDD tests for AuthenticationViewModel with secure authentication flow
 * Issues & Complexity Summary: Tests authentication, session management, OAuth 2.0, MFA
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~800
 *   - Core Algorithm Complexity: High (Security, OAuth, MFA, Session management)
 *   - Dependencies: 5 (XCTest, CoreData, Foundation, Security, AuthenticationServices)
 *   - State Management Complexity: High (Authentication state, Session state)
 *   - Novelty/Uncertainty Factor: High (Security implementation, OAuth 2.0)
 * AI Pre-Task Self-Assessment: 70%
 * Problem Estimate: 75%
 * Initial Code Complexity Estimate: 80%
 * Final Code Complexity: TBD
 * Overall Result Score: TBD
 * Key Variances/Learnings: TDD for security-critical authentication system
 * Last Updated: 2025-07-09
 */

class AuthenticationViewModelTests: XCTestCase {
    
    var authViewModel: AuthenticationViewModel!
    var testContext: NSManagedObjectContext!
    var mockAuthService: MockAuthenticationService!
    
    override func setUp() {
        super.setUp()
        
        // Create test Core Data context
        testContext = PersistenceController.preview.container.viewContext
        
        // Create mock authentication service
        mockAuthService = MockAuthenticationService()
        
        // Create authentication view model with test context
        authViewModel = AuthenticationViewModel(
            context: testContext,
            authService: mockAuthService
        )
    }
    
    override func tearDown() {
        authViewModel = nil
        testContext = nil
        mockAuthService = nil
        super.tearDown()
    }
    
    // MARK: - Authentication State Tests
    
    func testInitialAuthenticationState() {
        // Given: New AuthenticationViewModel
        // When: ViewModel is initialized
        // Then: Should have correct initial state
        XCTAssertFalse(authViewModel.isAuthenticated, "Should not be authenticated initially")
        XCTAssertFalse(authViewModel.isLoading, "Should not be loading initially")
        XCTAssertNil(authViewModel.currentUser, "Should have no current user initially")
        XCTAssertNil(authViewModel.errorMessage, "Should have no error message initially")
        XCTAssertEqual(authViewModel.authenticationState, .unauthenticated, "Should be in unauthenticated state")
    }
    
    func testAuthenticationStateTransitions() {
        // Given: Authentication view model
        // When: Authentication state changes
        authViewModel.authenticationState = .authenticating
        
        // Then: Should update related properties
        XCTAssertTrue(authViewModel.isLoading, "Should be loading during authentication")
        XCTAssertFalse(authViewModel.isAuthenticated, "Should not be authenticated during authentication")
        
        // When: Authentication succeeds
        authViewModel.authenticationState = .authenticated
        
        // Then: Should update authentication status
        XCTAssertTrue(authViewModel.isAuthenticated, "Should be authenticated after successful authentication")
        XCTAssertFalse(authViewModel.isLoading, "Should not be loading after authentication")
    }
    
    // MARK: - Email/Password Authentication Tests
    
    func testEmailPasswordAuthenticationSuccess() async {
        // Given: Valid credentials
        let email = "test@example.com"
        let password = "validPassword123"
        
        // Configure mock service for success
        mockAuthService.shouldSucceed = true
        mockAuthService.mockUser = createMockUser(email: email)
        
        // When: Attempting authentication
        await authViewModel.authenticate(email: email, password: password)
        
        // Then: Should be authenticated
        XCTAssertTrue(authViewModel.isAuthenticated, "Should be authenticated after successful login")
        XCTAssertNotNil(authViewModel.currentUser, "Should have current user after login")
        XCTAssertEqual(authViewModel.currentUser?.email, email, "Current user should have correct email")
        XCTAssertNil(authViewModel.errorMessage, "Should have no error message after successful login")
        XCTAssertEqual(authViewModel.authenticationState, .authenticated, "Should be in authenticated state")
    }
    
    func testEmailPasswordAuthenticationFailure() async {
        // Given: Invalid credentials
        let email = "test@example.com"
        let password = "invalidPassword"
        
        // Configure mock service for failure
        mockAuthService.shouldSucceed = false
        mockAuthService.mockError = AuthenticationError.invalidCredentials
        
        // When: Attempting authentication
        await authViewModel.authenticate(email: email, password: password)
        
        // Then: Should not be authenticated
        XCTAssertFalse(authViewModel.isAuthenticated, "Should not be authenticated after failed login")
        XCTAssertNil(authViewModel.currentUser, "Should have no current user after failed login")
        XCTAssertNotNil(authViewModel.errorMessage, "Should have error message after failed login")
        XCTAssertEqual(authViewModel.authenticationState, .unauthenticated, "Should be in unauthenticated state")
    }
    
    func testEmailPasswordValidation() async {
        // Test empty email
        await authViewModel.authenticate(email: "", password: "password123")
        XCTAssertNotNil(authViewModel.errorMessage, "Should have error for empty email")
        
        // Test invalid email format
        await authViewModel.authenticate(email: "invalid-email", password: "password123")
        XCTAssertNotNil(authViewModel.errorMessage, "Should have error for invalid email format")
        
        // Test empty password
        await authViewModel.authenticate(email: "test@example.com", password: "")
        XCTAssertNotNil(authViewModel.errorMessage, "Should have error for empty password")
        
        // Test short password
        await authViewModel.authenticate(email: "test@example.com", password: "123")
        XCTAssertNotNil(authViewModel.errorMessage, "Should have error for short password")
    }
    
    // MARK: - OAuth 2.0 Authentication Tests
    
    func testOAuth2GoogleAuthentication() async {
        // Given: OAuth 2.0 provider
        let provider = OAuth2Provider.google
        
        // Configure mock service for OAuth success
        mockAuthService.shouldSucceed = true
        mockAuthService.mockUser = createMockUser(email: "test@gmail.com")
        
        // When: Attempting OAuth authentication
        await authViewModel.authenticateWithOAuth2(provider: provider)
        
        // Then: Should be authenticated
        XCTAssertTrue(authViewModel.isAuthenticated, "Should be authenticated after OAuth login")
        XCTAssertNotNil(authViewModel.currentUser, "Should have current user after OAuth login")
        XCTAssertEqual(authViewModel.authenticationState, .authenticated, "Should be in authenticated state")
    }
    
    func testOAuth2MicrosoftAuthentication() async {
        // Given: OAuth 2.0 provider
        let provider = OAuth2Provider.microsoft
        
        // Configure mock service for OAuth success
        mockAuthService.shouldSucceed = true
        mockAuthService.mockUser = createMockUser(email: "test@outlook.com")
        
        // When: Attempting OAuth authentication
        await authViewModel.authenticateWithOAuth2(provider: provider)
        
        // Then: Should be authenticated
        XCTAssertTrue(authViewModel.isAuthenticated, "Should be authenticated after Microsoft OAuth login")
        XCTAssertNotNil(authViewModel.currentUser, "Should have current user after Microsoft OAuth login")
    }
    
    func testOAuth2AppleAuthentication() async {
        // Given: OAuth 2.0 provider
        let provider = OAuth2Provider.apple
        
        // Configure mock service for OAuth success
        mockAuthService.shouldSucceed = true
        mockAuthService.mockUser = createMockUser(email: "test@icloud.com")
        
        // When: Attempting OAuth authentication
        await authViewModel.authenticateWithOAuth2(provider: provider)
        
        // Then: Should be authenticated
        XCTAssertTrue(authViewModel.isAuthenticated, "Should be authenticated after Apple OAuth login")
        XCTAssertNotNil(authViewModel.currentUser, "Should have current user after Apple OAuth login")
    }
    
    // MARK: - Multi-Factor Authentication Tests
    
    func testMFAInitiation() async {
        // Given: User with MFA enabled
        let email = "mfa@example.com"
        let password = "password123"
        
        // Configure mock service for MFA required
        mockAuthService.shouldRequireMFA = true
        mockAuthService.mockUser = createMockUser(email: email)
        
        // When: Attempting authentication
        await authViewModel.authenticate(email: email, password: password)
        
        // Then: Should require MFA
        XCTAssertEqual(authViewModel.authenticationState, .mfaRequired, "Should require MFA")
        XCTAssertFalse(authViewModel.isAuthenticated, "Should not be fully authenticated yet")
        XCTAssertTrue(authViewModel.isMFARequired, "Should indicate MFA is required")
    }
    
    func testMFAVerificationSuccess() async {
        // Given: MFA required state
        authViewModel.authenticationState = .mfaRequired
        authViewModel.currentUser = createMockUser(email: "mfa@example.com")
        
        // Configure mock service for MFA success
        mockAuthService.shouldSucceed = true
        
        // When: Verifying MFA code
        await authViewModel.verifyMFACode("123456")
        
        // Then: Should be authenticated
        XCTAssertTrue(authViewModel.isAuthenticated, "Should be authenticated after MFA verification")
        XCTAssertEqual(authViewModel.authenticationState, .authenticated, "Should be in authenticated state")
        XCTAssertFalse(authViewModel.isMFARequired, "Should no longer require MFA")
    }
    
    func testMFAVerificationFailure() async {
        // Given: MFA required state
        authViewModel.authenticationState = .mfaRequired
        authViewModel.currentUser = createMockUser(email: "mfa@example.com")
        
        // Configure mock service for MFA failure
        mockAuthService.shouldSucceed = false
        mockAuthService.mockError = AuthenticationError.invalidMFACode
        
        // When: Verifying invalid MFA code
        await authViewModel.verifyMFACode("000000")
        
        // Then: Should remain in MFA required state
        XCTAssertFalse(authViewModel.isAuthenticated, "Should not be authenticated with invalid MFA code")
        XCTAssertEqual(authViewModel.authenticationState, .mfaRequired, "Should remain in MFA required state")
        XCTAssertNotNil(authViewModel.errorMessage, "Should have error message for invalid MFA code")
    }
    
    // MARK: - Session Management Tests
    
    func testSessionCreation() async {
        // Given: Successful authentication
        let email = "test@example.com"
        let password = "password123"
        
        mockAuthService.shouldSucceed = true
        mockAuthService.mockUser = createMockUser(email: email)
        
        // When: Authenticating
        await authViewModel.authenticate(email: email, password: password)
        
        // Then: Should create session
        XCTAssertNotNil(authViewModel.currentSession, "Should have current session")
        XCTAssertTrue(authViewModel.isSessionValid, "Session should be valid")
        XCTAssertEqual(authViewModel.currentSession?.userId, authViewModel.currentUser?.id, "Session should be linked to current user")
    }
    
    func testSessionExpiration() async {
        // Given: Active session
        let user = createMockUser(email: "test@example.com")
        authViewModel.currentUser = user
        authViewModel.currentSession = UserSession(
            userId: user.id,
            token: "test-token",
            expiresAt: Date().addingTimeInterval(-1) // Expired
        )
        
        // When: Checking session validity
        let isValid = authViewModel.isSessionValid
        
        // Then: Session should be expired
        XCTAssertFalse(isValid, "Expired session should be invalid")
    }
    
    func testSessionRefresh() async {
        // Given: Valid session near expiration
        let user = createMockUser(email: "test@example.com")
        authViewModel.currentUser = user
        authViewModel.currentSession = UserSession(
            userId: user.id,
            token: "test-token",
            expiresAt: Date().addingTimeInterval(300) // 5 minutes from now
        )
        
        // Configure mock service for session refresh
        mockAuthService.shouldSucceed = true
        
        // When: Refreshing session
        await authViewModel.refreshSession()
        
        // Then: Should have new session
        XCTAssertNotNil(authViewModel.currentSession, "Should have refreshed session")
        XCTAssertTrue(authViewModel.isSessionValid, "Refreshed session should be valid")
    }
    
    // MARK: - Logout Tests
    
    func testLogout() async {
        // Given: Authenticated user
        let user = createMockUser(email: "test@example.com")
        authViewModel.currentUser = user
        authViewModel.authenticationState = .authenticated
        authViewModel.currentSession = UserSession(
            userId: user.id,
            token: "test-token",
            expiresAt: Date().addingTimeInterval(3600)
        )
        
        // When: Logging out
        await authViewModel.logout()
        
        // Then: Should be logged out
        XCTAssertFalse(authViewModel.isAuthenticated, "Should not be authenticated after logout")
        XCTAssertNil(authViewModel.currentUser, "Should have no current user after logout")
        XCTAssertNil(authViewModel.currentSession, "Should have no session after logout")
        XCTAssertEqual(authViewModel.authenticationState, .unauthenticated, "Should be in unauthenticated state")
    }
    
    // MARK: - Security Tests
    
    func testSecureTokenStorage() async {
        // Given: Successful authentication
        let email = "test@example.com"
        let password = "password123"
        
        mockAuthService.shouldSucceed = true
        mockAuthService.mockUser = createMockUser(email: email)
        
        // When: Authenticating
        await authViewModel.authenticate(email: email, password: password)
        
        // Then: Should securely store token
        XCTAssertTrue(authViewModel.isTokenSecurelyStored, "Token should be securely stored")
        XCTAssertFalse(authViewModel.isTokenInMemoryOnly, "Token should not be in memory only")
    }
    
    func testBiometricAuthentication() async {
        // Given: Biometric authentication available
        mockAuthService.isBiometricAvailable = true
        mockAuthService.shouldSucceed = true
        
        // When: Attempting biometric authentication
        await authViewModel.authenticateWithBiometrics()
        
        // Then: Should authenticate with biometrics
        XCTAssertTrue(authViewModel.isAuthenticated, "Should be authenticated with biometrics")
        XCTAssertNotNil(authViewModel.currentUser, "Should have current user after biometric authentication")
    }
    
    func testBiometricAuthenticationUnavailable() async {
        // Given: Biometric authentication unavailable
        mockAuthService.isBiometricAvailable = false
        
        // When: Attempting biometric authentication
        await authViewModel.authenticateWithBiometrics()
        
        // Then: Should fail gracefully
        XCTAssertFalse(authViewModel.isAuthenticated, "Should not be authenticated when biometrics unavailable")
        XCTAssertNotNil(authViewModel.errorMessage, "Should have error message when biometrics unavailable")
    }
    
    // MARK: - Error Handling Tests
    
    func testNetworkErrorHandling() async {
        // Given: Network error
        mockAuthService.shouldSucceed = false
        mockAuthService.mockError = AuthenticationError.networkError
        
        // When: Attempting authentication
        await authViewModel.authenticate(email: "test@example.com", password: "password123")
        
        // Then: Should handle network error
        XCTAssertFalse(authViewModel.isAuthenticated, "Should not be authenticated with network error")
        XCTAssertNotNil(authViewModel.errorMessage, "Should have error message for network error")
        XCTAssertTrue(authViewModel.errorMessage?.contains("network") ?? false, "Error message should mention network")
    }
    
    func testServerErrorHandling() async {
        // Given: Server error
        mockAuthService.shouldSucceed = false
        mockAuthService.mockError = AuthenticationError.serverError
        
        // When: Attempting authentication
        await authViewModel.authenticate(email: "test@example.com", password: "password123")
        
        // Then: Should handle server error
        XCTAssertFalse(authViewModel.isAuthenticated, "Should not be authenticated with server error")
        XCTAssertNotNil(authViewModel.errorMessage, "Should have error message for server error")
    }
    
    // MARK: - Performance Tests
    
    func testAuthenticationPerformance() {
        measure {
            let expectation = self.expectation(description: "Authentication performance")
            
            Task {
                mockAuthService.shouldSucceed = true
                mockAuthService.mockUser = createMockUser(email: "test@example.com")
                
                await authViewModel.authenticate(email: "test@example.com", password: "password123")
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 5.0)
        }
    }
    
    // MARK: - Helper Methods
    
    private func createMockUser(email: String) -> User {
        return User.create(
            in: testContext,
            name: "Test User",
            email: email,
            role: .owner
        )
    }
}

// MARK: - Mock Classes

class MockAuthenticationService: AuthenticationServiceProtocol {
    var shouldSucceed = true
    var shouldRequireMFA = false
    var mockUser: User?
    var mockError: AuthenticationError?
    var isBiometricAvailable = true
    
    func authenticate(email: String, password: String) async throws -> AuthenticationResult {
        if shouldSucceed {
            return AuthenticationResult(
                user: mockUser!,
                session: UserSession(
                    userId: mockUser!.id,
                    token: "mock-token",
                    expiresAt: Date().addingTimeInterval(3600)
                ),
                requiresMFA: shouldRequireMFA
            )
        } else {
            throw mockError ?? AuthenticationError.invalidCredentials
        }
    }
    
    func authenticateWithOAuth2(provider: OAuth2Provider) async throws -> AuthenticationResult {
        if shouldSucceed {
            return AuthenticationResult(
                user: mockUser!,
                session: UserSession(
                    userId: mockUser!.id,
                    token: "oauth-token",
                    expiresAt: Date().addingTimeInterval(3600)
                ),
                requiresMFA: false
            )
        } else {
            throw mockError ?? AuthenticationError.oauthError
        }
    }
    
    func verifyMFACode(_ code: String) async throws -> Bool {
        if shouldSucceed {
            return true
        } else {
            throw mockError ?? AuthenticationError.invalidMFACode
        }
    }
    
    func refreshSession(_ session: UserSession) async throws -> UserSession {
        if shouldSucceed {
            return UserSession(
                userId: session.userId,
                token: "refreshed-token",
                expiresAt: Date().addingTimeInterval(3600)
            )
        } else {
            throw mockError ?? AuthenticationError.sessionExpired
        }
    }
    
    func logout() async throws {
        // Mock logout implementation
    }
    
    func authenticateWithBiometrics() async throws -> AuthenticationResult {
        if !isBiometricAvailable {
            throw AuthenticationError.biometricUnavailable
        }
        
        if shouldSucceed {
            return AuthenticationResult(
                user: mockUser!,
                session: UserSession(
                    userId: mockUser!.id,
                    token: "biometric-token",
                    expiresAt: Date().addingTimeInterval(3600)
                ),
                requiresMFA: false
            )
        } else {
            throw mockError ?? AuthenticationError.biometricFailure
        }
    }
}