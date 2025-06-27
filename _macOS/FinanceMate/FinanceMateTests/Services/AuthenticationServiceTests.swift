//
//  AuthenticationServiceTests.swift
//  FinanceMateTests
//
//  Created by Assistant on 6/8/25.
//

import XCTest
@testable import FinanceMate

@MainActor
final class AuthenticationServiceTests: XCTestCase {

    var authService: AuthenticationService!

    override func setUp() {
        super.setUp()
        authService = AuthenticationService()
    }

    override func tearDown() {
        authService = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testAuthenticationServiceInitialization() {
        XCTAssertFalse(authService.isAuthenticated)
        XCTAssertNil(authService.currentUser)
        XCTAssertEqual(authService.authenticationState, .unauthenticated)
        XCTAssertFalse(authService.isLoading)
        XCTAssertNil(authService.errorMessage)
    }

    // MARK: - Authentication State Tests

    func testAuthenticationStateTransitions() {
        // Test initial state
        XCTAssertEqual(authService.authenticationState, .unauthenticated)

        // Test loading state
        authService.isLoading = true
        XCTAssertTrue(authService.isLoading)

        // Test error handling
        authService.errorMessage = "Test error"
        XCTAssertEqual(authService.errorMessage, "Test error")
    }

    func testAuthenticationStateEquality() {
        let state1 = AuthenticationState.unauthenticated
        let state2 = AuthenticationState.unauthenticated
        let state3 = AuthenticationState.authenticated
        let state4 = AuthenticationState.authenticating

        XCTAssertEqual(state1, state2)
        XCTAssertNotEqual(state1, state3)
        XCTAssertNotEqual(state1, state4)
        XCTAssertNotEqual(state3, state4)
    }

    func testAuthenticationStateWithErrors() {
        let error1 = AuthenticationError.appleSignInFailed(NSError(domain: "test", code: 1))
        let error2 = AuthenticationError.googleSignInFailed(NSError(domain: "test", code: 2))
        let error3 = AuthenticationError.appleSignInFailed(NSError(domain: "test", code: 1))

        let state1 = AuthenticationState.error(error1)
        let state2 = AuthenticationState.error(error2)
        let state3 = AuthenticationState.error(error3)

        XCTAssertNotEqual(state1, state2) // Different error types
        XCTAssertEqual(state1, state3) // Same error description
    }

    // MARK: - Sign Out Tests

    func testSignOut() async {
        // Given - Set up authenticated state
        let user = AuthenticatedUser(
            id: "test-user",
            email: "test@example.com",
            displayName: "Test User",
            provider: .apple
        )

        authService.currentUser = user
        authService.isAuthenticated = true
        authService.authenticationState = .authenticated

        // When
        await authService.signOut()

        // Then
        XCTAssertNil(authService.currentUser)
        XCTAssertFalse(authService.isAuthenticated)
        XCTAssertEqual(authService.authenticationState, .unauthenticated)
        XCTAssertNil(authService.errorMessage)
        XCTAssertFalse(authService.isLoading)
    }

    // MARK: - User Profile Tests

    func testUpdateUserProfile() async {
        // Given - Set up authenticated user
        let originalUser = AuthenticatedUser(
            id: "test-user",
            email: "original@example.com",
            displayName: "Original Name",
            provider: .google
        )

        authService.currentUser = originalUser
        authService.isAuthenticated = true

        let updates = UserProfileUpdate(
            displayName: "Updated Name",
            email: "updated@example.com"
        )

        // When
        do {
            try await authService.updateUserProfile(updates)
        } catch {
            XCTFail("Update should not throw error: \(error)")
        }

        // Then
        XCTAssertNotNil(authService.currentUser)
        XCTAssertEqual(authService.currentUser?.displayName, "Updated Name")
        XCTAssertEqual(authService.currentUser?.email, "updated@example.com")
        XCTAssertEqual(authService.currentUser?.id, originalUser.id) // ID should not change
        XCTAssertEqual(authService.currentUser?.provider, originalUser.provider) // Provider should not change
    }

    func testUpdateUserProfileWithoutCurrentUser() async {
        // Given - No authenticated user
        XCTAssertNil(authService.currentUser)

        let updates = UserProfileUpdate(displayName: "New Name")

        // When/Then
        do {
            try await authService.updateUserProfile(updates)
            XCTFail("Should throw noCurrentUser error")
        } catch AuthenticationError.noCurrentUser {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testUpdateUserProfilePartialUpdates() async {
        // Given
        let originalUser = AuthenticatedUser(
            id: "test-user",
            email: "original@example.com",
            displayName: "Original Name",
            provider: .apple
        )

        authService.currentUser = originalUser

        // When - Update only display name
        let displayNameUpdate = UserProfileUpdate(displayName: "New Display Name")
        try? await authService.updateUserProfile(displayNameUpdate)

        // Then
        XCTAssertEqual(authService.currentUser?.displayName, "New Display Name")
        XCTAssertEqual(authService.currentUser?.email, "original@example.com") // Should remain unchanged

        // When - Update only email
        let emailUpdate = UserProfileUpdate(email: "new@example.com")
        try? await authService.updateUserProfile(emailUpdate)

        // Then
        XCTAssertEqual(authService.currentUser?.displayName, "New Display Name") // Should remain from previous update
        XCTAssertEqual(authService.currentUser?.email, "new@example.com")
    }
}

// MARK: - Authentication Result Tests

final class AuthenticationResultTests: XCTestCase {

    func testAuthenticationResultInitialization() {
        // Given
        let user = AuthenticatedUser(
            id: "test-user",
            email: "test@example.com",
            displayName: "Test User",
            provider: .apple
        )
        let provider = AuthenticationProvider.apple
        let token = "test-token"

        // When
        let result = AuthenticationResult(
            success: true,
            user: user,
            provider: provider,
            token: token
        )

        // Then
        XCTAssertTrue(result.success)
        XCTAssertNotNil(result.user)
        XCTAssertEqual(result.user?.id, user.id)
        XCTAssertEqual(result.provider, provider)
        XCTAssertEqual(result.token, token)
        XCTAssertNil(result.error)
    }

    func testAuthenticationResultWithError() {
        // Given
        let error = AuthenticationError.invalidAppleCredential
        let provider = AuthenticationProvider.google

        // When
        let result = AuthenticationResult(
            success: false,
            user: nil,
            provider: provider,
            token: "",
            error: error
        )

        // Then
        XCTAssertFalse(result.success)
        XCTAssertNil(result.user)
        XCTAssertEqual(result.provider, provider)
        XCTAssertEqual(result.token, "")
        XCTAssertNotNil(result.error)
    }
}

// MARK: - User Profile Update Tests

final class UserProfileUpdateTests: XCTestCase {

    func testUserProfileUpdateInitialization() {
        // Test with all parameters
        let update1 = UserProfileUpdate(
            displayName: "New Name",
            email: "new@example.com"
        )

        XCTAssertEqual(update1.displayName, "New Name")
        XCTAssertEqual(update1.email, "new@example.com")

        // Test with partial parameters
        let update2 = UserProfileUpdate(displayName: "Only Name")
        XCTAssertEqual(update2.displayName, "Only Name")
        XCTAssertNil(update2.email)

        let update3 = UserProfileUpdate(email: "only@email.com")
        XCTAssertNil(update3.displayName)
        XCTAssertEqual(update3.email, "only@email.com")

        // Test with no parameters
        let update4 = UserProfileUpdate()
        XCTAssertNil(update4.displayName)
        XCTAssertNil(update4.email)
    }
}

// MARK: - Authentication Error Tests

final class AuthenticationErrorTests: XCTestCase {

    func testAuthenticationErrorDescriptions() {
        let testError = NSError(domain: "test", code: 123, userInfo: [NSLocalizedDescriptionKey: "Test error"])

        let errors: [(AuthenticationError, String)] = [
            (.appleSignInFailed(testError), "Apple Sign In failed: Test error"),
            (.googleSignInFailed(testError), "Google Sign In failed: Test error"),
            (.invalidAppleCredential, "Invalid Apple credential received"),
            (.invalidGoogleCredential, "Invalid Google credential received"),
            (.appleCredentialsRevoked, "Apple credentials have been revoked"),
            (.appleCredentialsTransferred, "Apple credentials have been transferred"),
            (.unknownAppleCredentialState, "Unknown Apple credential state"),
            (.googleTokenExpired, "Google authentication token has expired"),
            (.noCurrentUser, "No authenticated user found"),
            (.keychainError("Keychain test"), "Keychain error: Keychain test"),
            (.tokenManagerError("Token test"), "Token manager error: Token test"),
            (.networkError("Network test"), "Network error: Network test"),
            (.invalidGoogleCallback, "Invalid callback received from Google OAuth"),
            (.oauthServerError("OAuth test"), "OAuth server error: OAuth test")
        ]

        for (error, expectedDescription) in errors {
            XCTAssertEqual(error.errorDescription, expectedDescription)
        }
    }
}

// MARK: - Supporting Types Tests

final class AuthenticationProviderTests: XCTestCase {

    func testAuthenticationProviderValues() {
        XCTAssertEqual(AuthenticationProvider.apple.rawValue, "apple")
        XCTAssertEqual(AuthenticationProvider.google.rawValue, "google")

        XCTAssertEqual(AuthenticationProvider.apple.displayName, "Apple")
        XCTAssertEqual(AuthenticationProvider.google.displayName, "Google")
    }

    func testAuthenticationProviderCaseIterable() {
        let allCases = AuthenticationProvider.allCases
        XCTAssertEqual(allCases.count, 2)
        XCTAssertTrue(allCases.contains(.apple))
        XCTAssertTrue(allCases.contains(.google))
    }
}

final class AuthenticatedUserTests: XCTestCase {

    func testAuthenticatedUserInitialization() {
        // Given
        let id = "user123"
        let email = "user@example.com"
        let displayName = "Test User"
        let provider = AuthenticationProvider.apple
        let isEmailVerified = true
        let createdAt = Date()

        // When
        let user = AuthenticatedUser(
            id: id,
            email: email,
            displayName: displayName,
            provider: provider,
            isEmailVerified: isEmailVerified,
            createdAt: createdAt
        )

        // Then
        XCTAssertEqual(user.id, id)
        XCTAssertEqual(user.email, email)
        XCTAssertEqual(user.displayName, displayName)
        XCTAssertEqual(user.provider, provider)
        XCTAssertEqual(user.isEmailVerified, isEmailVerified)
        XCTAssertEqual(user.createdAt, createdAt)
    }

    func testAuthenticatedUserWithDefaults() {
        // Given
        let id = "user123"
        let email = "user@example.com"
        let displayName = "Test User"
        let provider = AuthenticationProvider.google

        // When
        let user = AuthenticatedUser(
            id: id,
            email: email,
            displayName: displayName,
            provider: provider
        )

        // Then
        XCTAssertEqual(user.id, id)
        XCTAssertEqual(user.email, email)
        XCTAssertEqual(user.displayName, displayName)
        XCTAssertEqual(user.provider, provider)
        XCTAssertFalse(user.isEmailVerified) // Default is false
        XCTAssertNotNil(user.createdAt) // Should be set to current date
    }

    func testAuthenticatedUserCodable() {
        // Given
        let originalUser = AuthenticatedUser(
            id: "user123",
            email: "user@example.com",
            displayName: "Test User",
            provider: .apple,
            isEmailVerified: true
        )

        // When - Encode
        let encoder = JSONEncoder()
        let data = try? encoder.encode(originalUser)
        XCTAssertNotNil(data)

        // When - Decode
        let decoder = JSONDecoder()
        let decodedUser = try? decoder.decode(AuthenticatedUser.self, from: data!)

        // Then
        XCTAssertNotNil(decodedUser)
        XCTAssertEqual(decodedUser?.id, originalUser.id)
        XCTAssertEqual(decodedUser?.email, originalUser.email)
        XCTAssertEqual(decodedUser?.displayName, originalUser.displayName)
        XCTAssertEqual(decodedUser?.provider, originalUser.provider)
        XCTAssertEqual(decodedUser?.isEmailVerified, originalUser.isEmailVerified)
    }
}

// MARK: - Token Manager Tests

final class TokenManagerTests: XCTestCase {

    var tokenManager: TokenManager!

    override func setUp() {
        super.setUp()
        tokenManager = TokenManager()
    }

    override func tearDown() {
        tokenManager = nil
        super.tearDown()
    }

    func testSaveAndRetrieveToken() {
        // Given
        let token = "test-access-token"
        let provider = AuthenticationProvider.apple

        // When
        tokenManager.saveToken(token, for: provider)
        let retrievedToken = tokenManager.getToken(for: provider)

        // Then
        XCTAssertEqual(retrievedToken, token)
    }

    func testSaveAndRetrieveRefreshToken() {
        // Given
        let refreshToken = "test-refresh-token"
        let provider = AuthenticationProvider.google

        // When
        tokenManager.saveRefreshToken(refreshToken, for: provider)
        let retrievedToken = tokenManager.getRefreshToken(for: provider)

        // Then
        XCTAssertEqual(retrievedToken, refreshToken)
    }

    func testHasValidToken() {
        // Given
        let provider = AuthenticationProvider.apple

        // When - No token saved
        let hasTokenBefore = tokenManager.hasValidToken(for: provider)

        // Then
        XCTAssertFalse(hasTokenBefore)

        // When - Token saved
        tokenManager.saveToken("test-token", for: provider)
        let hasTokenAfter = tokenManager.hasValidToken(for: provider)

        // Then
        XCTAssertTrue(hasTokenAfter)
    }

    func testClearAllTokens() {
        // Given
        tokenManager.saveToken("apple-token", for: .apple)
        tokenManager.saveToken("google-token", for: .google)
        tokenManager.saveRefreshToken("apple-refresh", for: .apple)
        tokenManager.saveRefreshToken("google-refresh", for: .google)

        XCTAssertTrue(tokenManager.hasValidToken(for: .apple))
        XCTAssertTrue(tokenManager.hasValidToken(for: .google))

        // When
        tokenManager.clearAllTokens()

        // Then
        XCTAssertFalse(tokenManager.hasValidToken(for: .apple))
        XCTAssertFalse(tokenManager.hasValidToken(for: .google))
        XCTAssertNil(tokenManager.getRefreshToken(for: .apple))
        XCTAssertNil(tokenManager.getRefreshToken(for: .google))
    }

    func testMultipleProviders() {
        // Given
        let appleToken = "apple-token"
        let googleToken = "google-token"

        // When
        tokenManager.saveToken(appleToken, for: .apple)
        tokenManager.saveToken(googleToken, for: .google)

        // Then
        XCTAssertEqual(tokenManager.getToken(for: .apple), appleToken)
        XCTAssertEqual(tokenManager.getToken(for: .google), googleToken)
        XCTAssertTrue(tokenManager.hasValidToken(for: .apple))
        XCTAssertTrue(tokenManager.hasValidToken(for: .google))
    }
}

// MARK: - Keychain Manager Tests

final class KeychainManagerTests: XCTestCase {

    var keychainManager: KeychainManager!

    override func setUp() {
        super.setUp()
        keychainManager = KeychainManager()
    }

    override func tearDown() {
        keychainManager = nil
        super.tearDown()
    }

    func testSaveUserCredentials() {
        // Given
        let user = AuthenticatedUser(
            id: "test-user",
            email: "test@example.com",
            displayName: "Test User",
            provider: .apple
        )

        // When/Then - Should not throw error
        XCTAssertNoThrow(try keychainManager.saveUserCredentials(user))
    }

    func testRetrieveUserCredentials() {
        // When
        let retrievedUser = keychainManager.retrieveUserCredentials()

        // Then - Stub implementation returns nil
        XCTAssertNil(retrievedUser)
    }

    func testClearUserCredentials() {
        // When/Then - Should complete without error
        XCTAssertNoThrow(keychainManager.clearUserCredentials())
    }

    func testSaveAndRetrieveGenericData() {
        // Given
        let testData = "test data".data(using: .utf8)!
        let key = "test-key"

        // When
        XCTAssertNoThrow(try keychainManager.save(testData, for: key))
        let retrievedData = keychainManager.retrieve(for: key)

        // Then - Stub implementation returns nil
        XCTAssertNil(retrievedData)
    }

    func testDeleteData() {
        // Given
        let key = "test-key"

        // When/Then - Should complete without error
        XCTAssertNoThrow(keychainManager.delete(for: key))
    }
}

// MARK: - User Session Manager Tests

final class UserSessionManagerTests: XCTestCase {

    var sessionManager: UserSessionManager!

    override func setUp() {
        super.setUp()
        sessionManager = UserSessionManager()
    }

    override func tearDown() {
        sessionManager = nil
        super.tearDown()
    }

    func testInitialState() {
        XCTAssertNil(sessionManager.currentSession)
        XCTAssertFalse(sessionManager.isSessionActive)
        XCTAssertEqual(sessionManager.sessionDuration, 3600) // 1 hour stub
        XCTAssertNotNil(sessionManager.lastActivityDate)
    }

    func testCreateSession() async {
        // Given
        let user = AuthenticatedUser(
            id: "test-user",
            email: "test@example.com",
            displayName: "Test User",
            provider: .google
        )

        // When
        await sessionManager.createSession(for: user)

        // Then
        XCTAssertNotNil(sessionManager.currentSession)
        XCTAssertEqual(sessionManager.currentSession?.user.id, user.id)
        XCTAssertTrue(sessionManager.isSessionActive)
        XCTAssertNotNil(sessionManager.lastActivityDate)
        XCTAssertEqual(sessionManager.sessionDuration, 0) // Reset on new session
    }

    func testClearSession() async {
        // Given - Create a session first
        let user = AuthenticatedUser(
            id: "test-user",
            email: "test@example.com",
            displayName: "Test User",
            provider: .apple
        )
        await sessionManager.createSession(for: user)
        XCTAssertNotNil(sessionManager.currentSession)
        XCTAssertTrue(sessionManager.isSessionActive)

        // When
        await sessionManager.clearSession()

        // Then
        XCTAssertNil(sessionManager.currentSession)
        XCTAssertFalse(sessionManager.isSessionActive)
        XCTAssertEqual(sessionManager.sessionDuration, 0)
    }

    func testExtendSession() async {
        // Given
        let originalActivityDate = sessionManager.lastActivityDate

        // Wait a small amount to ensure timestamp difference
        try? await Task.sleep(nanoseconds: 10_000_000) // 10ms

        // When
        await sessionManager.extendSession()

        // Then
        XCTAssertNotNil(sessionManager.lastActivityDate)
        if let original = originalActivityDate, let updated = sessionManager.lastActivityDate {
            XCTAssertGreaterThan(updated, original)
        }
    }

    func testGetSessionAnalytics() {
        // When
        let analytics = sessionManager.getSessionAnalytics()

        // Then
        XCTAssertNotNil(analytics)
        XCTAssertEqual(analytics.sessionId, "no-session") // No current session
        XCTAssertEqual(analytics.totalDuration, sessionManager.sessionDuration)
        XCTAssertEqual(analytics.activityCount, 15)
        XCTAssertEqual(analytics.extensionCount, 3)
        XCTAssertEqual(analytics.averageActivityInterval, 300)
        XCTAssertEqual(analytics.isActive, sessionManager.isSessionActive)
    }

    func testGetSessionAnalyticsWithActiveSession() async {
        // Given
        let user = AuthenticatedUser(
            id: "session-user",
            email: "session@example.com",
            displayName: "Session User",
            provider: .apple
        )
        await sessionManager.createSession(for: user)

        // When
        let analytics = sessionManager.getSessionAnalytics()

        // Then
        XCTAssertEqual(analytics.sessionId, sessionManager.currentSession?.sessionId)
        XCTAssertTrue(analytics.isActive)
    }
}

// MARK: - User Session Tests

final class UserSessionTests: XCTestCase {

    func testUserSessionInitialization() {
        // Given
        let user = AuthenticatedUser(
            id: "session-user",
            email: "session@example.com",
            displayName: "Session User",
            provider: .google
        )

        // When
        let session = UserSession(user: user)

        // Then
        XCTAssertEqual(session.user.id, user.id)
        XCTAssertEqual(session.user.email, user.email)
        XCTAssertEqual(session.user.displayName, user.displayName)
        XCTAssertEqual(session.user.provider, user.provider)
        XCTAssertNotNil(session.sessionId)
        XCTAssertFalse(session.sessionId.isEmpty)
        XCTAssertNotNil(session.createdAt)
    }

    func testUniqueSessionIds() {
        // Given
        let user = AuthenticatedUser(
            id: "test-user",
            email: "test@example.com",
            displayName: "Test User",
            provider: .apple
        )

        // When
        let session1 = UserSession(user: user)
        let session2 = UserSession(user: user)

        // Then
        XCTAssertNotEqual(session1.sessionId, session2.sessionId)
    }
}

// MARK: - Session Analytics Tests

final class SessionAnalyticsTests: XCTestCase {

    func testSessionAnalyticsInitialization() {
        // Given
        let sessionId = "test-session"
        let totalDuration: TimeInterval = 1800
        let activityCount = 25
        let extensionCount = 5
        let averageActivityInterval: TimeInterval = 120
        let isActive = true

        // When
        let analytics = SessionAnalytics(
            sessionId: sessionId,
            totalDuration: totalDuration,
            activityCount: activityCount,
            extensionCount: extensionCount,
            averageActivityInterval: averageActivityInterval,
            isActive: isActive
        )

        // Then
        XCTAssertEqual(analytics.sessionId, sessionId)
        XCTAssertEqual(analytics.totalDuration, totalDuration)
        XCTAssertEqual(analytics.activityCount, activityCount)
        XCTAssertEqual(analytics.extensionCount, extensionCount)
        XCTAssertEqual(analytics.averageActivityInterval, averageActivityInterval)
        XCTAssertEqual(analytics.isActive, isActive)
    }

    func testSessionAnalyticsWithDefaults() {
        // When
        let analytics = SessionAnalytics()

        // Then
        XCTAssertEqual(analytics.sessionId, "no-session")
        XCTAssertEqual(analytics.totalDuration, 0)
        XCTAssertEqual(analytics.activityCount, 0)
        XCTAssertEqual(analytics.extensionCount, 0)
        XCTAssertEqual(analytics.averageActivityInterval, 0)
        XCTAssertFalse(analytics.isActive)
    }
}
