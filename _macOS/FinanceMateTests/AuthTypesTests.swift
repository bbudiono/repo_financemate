import XCTest
@testable import FinanceMate

/// Test suite for AuthTypes models with import resolution validation
/// Validates authentication types, states, providers, and error handling
/// Phase 1 RED - These tests document AuthTypes accessibility issues
final class AuthTypesTests: XCTestCase {

    // MARK: - Import Resolution Tests

    /// Test: AuthTypes should be accessible from FinanceMate module
    /// Expected: Compilation failure if AuthTypes not properly imported
    func testAuthTypes_ModuleImport_FinanceMateAccessible() {
        // Given: AuthTypes.swift should be accessible in FinanceMate module
        // When: Accessing AuthTypes types
        // Then: Should fail compilation if imports are not resolved

        // Test basic type accessibility
        let authUser = AuthUser(id: "test", email: "test@example.com", name: "Test", provider: .apple)
        let authState = AuthState.authenticated(authUser)
        let authProvider = AuthProvider.apple
        let authError = AuthError.networkError
        let tokenInfo = TokenInfo(accessToken: "test", refreshToken: nil, expiresIn: 3600)
        let googleUserInfo = GoogleUserInfo(id: "test", email: "test@gmail.com", name: "Test")

        // All assertions should pass if types are accessible
        XCTAssertNotNil(authUser, "AuthUser should be accessible")
        XCTAssertNotNil(authState, "AuthState should be accessible")
        XCTAssertNotNil(authProvider, "AuthProvider should be accessible")
        XCTAssertNotNil(authError, "AuthError should be accessible")
        XCTAssertNotNil(tokenInfo, "TokenInfo should be accessible")
        XCTAssertNotNil(googleUserInfo, "GoogleUserInfo should be accessible")
    }

    /// Test: AuthTypes file location and accessibility
    /// Expected: Compilation failure if AuthTypes.swift not found or not in target
    func testAuthTypes_FileLocation_ModelsFolderAccessible() {
        // Given: AuthTypes.swift should be in Models folder and accessible
        // When: Accessing types defined in AuthTypes.swift
        // Then: Should fail if file not found or not in correct target

        // Test all types defined in AuthTypes.swift
        let allProviders = AuthProvider.allCases
        XCTAssertGreaterThanOrEqual(allProviders.count, 2, "Should have at least Apple and Google providers")

        // Test enum cases are accessible
        XCTAssertTrue(allProviders.contains(.apple), "Apple provider should be accessible")
        XCTAssertTrue(allProviders.contains(.google), "Google provider should be accessible")

        // Test AuthState cases are accessible
        let unknownState = AuthState.unknown
        let authenticatingState = AuthState.authenticating
        let signedOutState = AuthState.signedOut

        XCTAssertNotNil(unknownState, "AuthState.unknown should be accessible")
        XCTAssertNotNil(authenticatingState, "AuthState.authenticating should be accessible")
        XCTAssertNotNil(signedOutState, "AuthState.signedOut should be accessible")
    }

    /// Test: AuthTypes target membership for both main and test targets
    /// Expected: Compilation failure if AuthTypes not in both targets
    func testAuthTypes_TargetMembership_BothTargetsAccessible() {
        // Given: AuthTypes should be accessible in both FinanceMate and FinanceMateTests
        // When: Creating instances in test target
        // Then: Should fail if AuthTypes not included in test target

        // Create test instances that require AuthTypes accessibility
        let testAuthUser = AuthUser(
            id: "test_user_123",
            email: "test@example.com",
            name: "Test User",
            provider: .apple
        )

        let testAuthState = AuthState.authenticated(testAuthUser)
        let testTokenInfo = TokenInfo(
            accessToken: "test_access_token",
            refreshToken: "test_refresh_token",
            expiresIn: 3600,
            tokenType: "Bearer"
        )

        let testGoogleUserInfo = GoogleUserInfo(
            id: "google_user_456",
            email: "test@gmail.com",
            name: "Google User",
            picture: "https://example.com/avatar.jpg",
            verifiedEmail: true
        )

        // Verify all instances can be created successfully
        XCTAssertNotNil(testAuthUser, "AuthUser should be creatable in test target")
        XCTAssertNotNil(testAuthState, "AuthState should be creatable in test target")
        XCTAssertNotNil(testTokenInfo, "TokenInfo should be creatable in test target")
        XCTAssertNotNil(testGoogleUserInfo, "GoogleUserInfo should be creatable in test target")
    }

    // MARK: - AuthUser Tests

    func testAuthUser_Initialization_ValidData_CreatesUserSuccessfully() {
        // Given
        let id = "user123"
        let email = "test@example.com"
        let name = "Test User"
        let provider = AuthProvider.apple

        // When
        let user = AuthUser(id: id, email: email, name: name, provider: provider)

        // Then
        XCTAssertEqual(user.id, id, "User ID should match")
        XCTAssertEqual(user.email, email, "User email should match")
        XCTAssertEqual(user.name, name, "User name should match")
        XCTAssertEqual(user.provider, provider, "User provider should match")
    }

    func testAuthUser_Initialization_GoogleProvider_CreatesUserSuccessfully() {
        // Given
        let id = "google456"
        let email = "user@gmail.com"
        let name = "Google User"
        let provider = AuthProvider.google

        // When
        let user = AuthUser(id: id, email: email, name: name, provider: provider)

        // Then
        XCTAssertEqual(user.provider, .google, "Provider should be google")
        XCTAssertEqual(user.email, email, "Email should match")
    }

    func testAuthUser_Equality_SameData_ReturnsTrue() {
        // Given
        let user1 = AuthUser(id: "123", email: "test@example.com", name: "Test", provider: .apple)
        let user2 = AuthUser(id: "123", email: "test@example.com", name: "Test", provider: .apple)

        // Then
        XCTAssertEqual(user1, user2, "Users with same data should be equal")
    }

    func testAuthUser_Equality_DifferentID_ReturnsFalse() {
        // Given
        let user1 = AuthUser(id: "123", email: "test@example.com", name: "Test", provider: .apple)
        let user2 = AuthUser(id: "456", email: "test@example.com", name: "Test", provider: .apple)

        // Then
        XCTAssertNotEqual(user1, user2, "Users with different IDs should not be equal")
    }

    func testAuthUser_Hashable_SameData_SameHashValue() {
        // Given
        let user1 = AuthUser(id: "123", email: "test@example.com", name: "Test", provider: .apple)
        let user2 = AuthUser(id: "123", email: "test@example.com", name: "Test", provider: .apple)

        // When
        let hash1 = user1.hashValue
        let hash2 = user2.hashValue

        // Then
        XCTAssertEqual(hash1, hash2, "Users with same data should have same hash value")
    }

    // MARK: - AuthState Tests

    func testAuthState_UnknownState_CorrectProperties() {
        // Given
        let state = AuthState.unknown

        // Then
        XCTAssertFalse(state.isAuthenticated, "Unknown state should not be authenticated")
        XCTAssertFalse(state.isAuthenticating, "Unknown state should not be authenticating")
        XCTAssertNil(state.user, "Unknown state should have no user")
        XCTAssertNil(state.error, "Unknown state should have no error")
    }

    func testAuthState_AuthenticatingState_CorrectProperties() {
        // Given
        let state = AuthState.authenticating

        // Then
        XCTAssertFalse(state.isAuthenticated, "Authenticating state should not be authenticated")
        XCTAssertTrue(state.isAuthenticating, "Authenticating state should be authenticating")
        XCTAssertNil(state.user, "Authenticating state should have no user")
        XCTAssertNil(state.error, "Authenticating state should have no error")
    }

    func testAuthState_AuthenticatedState_CorrectProperties() {
        // Given
        let user = AuthUser(id: "123", email: "test@example.com", name: "Test", provider: .apple)
        let state = AuthState.authenticated(user)

        // Then
        XCTAssertTrue(state.isAuthenticated, "Authenticated state should be authenticated")
        XCTAssertFalse(state.isAuthenticating, "Authenticated state should not be authenticating")
        XCTAssertEqual(state.user, user, "Authenticated state should have user")
        XCTAssertNil(state.error, "Authenticated state should have no error")
    }

    func testAuthState_SignedOutState_CorrectProperties() {
        // Given
        let state = AuthState.signedOut

        // Then
        XCTAssertFalse(state.isAuthenticated, "Signed out state should not be authenticated")
        XCTAssertFalse(state.isAuthenticating, "Signed out state should not be authenticating")
        XCTAssertNil(state.user, "Signed out state should have no user")
        XCTAssertNil(state.error, "Signed out state should have no error")
    }

    func testAuthState_ErrorState_CorrectProperties() {
        // Given
        let error = AuthError.networkError
        let state = AuthState.error(error)

        // Then
        XCTAssertFalse(state.isAuthenticated, "Error state should not be authenticated")
        XCTAssertFalse(state.isAuthenticating, "Error state should not be authenticating")
        XCTAssertNil(state.user, "Error state should have no user")
        XCTAssertEqual(state.error, error, "Error state should have error")
    }

    // MARK: - AuthProvider Tests

    func testAuthProvider_AppleProvider_CorrectDisplayName() {
        // Given
        let provider = AuthProvider.apple

        // Then
        XCTAssertEqual(provider.displayName, "Apple", "Apple provider should have correct display name")
    }

    func testAuthProvider_GoogleProvider_CorrectDisplayName() {
        // Given
        let provider = AuthProvider.google

        // Then
        XCTAssertEqual(provider.displayName, "Google", "Google provider should have correct display name")
    }

    func testAuthProvider_CaseIterable_AllProvidersIncluded() {
        // Given
        let allProviders = AuthProvider.allCases

        // Then
        XCTAssertEqual(allProviders.count, 2, "Should have exactly 2 providers")
        XCTAssertTrue(allProviders.contains(.apple), "Should include Apple provider")
        XCTAssertTrue(allProviders.contains(.google), "Should include Google provider")
    }

    // MARK: - AuthError Tests

    func testAuthError_NetworkError_CorrectDescription() {
        // Given
        let error = AuthError.networkError

        // Then
        XCTAssertEqual(error.localizedDescription, "Network connection failed", "Network error should have correct description")
        XCTAssertEqual(error.errorCode, 1001, "Network error should have correct error code")
    }

    func testAuthError_InvalidCredentials_CorrectDescription() {
        // Given
        let error = AuthError.invalidCredentials

        // Then
        XCTAssertEqual(error.localizedDescription, "Invalid credentials provided", "Invalid credentials error should have correct description")
        XCTAssertEqual(error.errorCode, 1002, "Invalid credentials error should have correct error code")
    }

    func testAuthError_CancelledByUser_CorrectDescription() {
        // Given
        let error = AuthError.cancelledByUser

        // Then
        XCTAssertEqual(error.localizedDescription, "Authentication cancelled by user", "Cancelled error should have correct description")
        XCTAssertEqual(error.errorCode, 1003, "Cancelled error should have correct error code")
    }

    func testAuthError_TokenExpired_CorrectDescription() {
        // Given
        let error = AuthError.tokenExpired

        // Then
        XCTAssertEqual(error.localizedDescription, "Authentication token has expired", "Token expired error should have correct description")
        XCTAssertEqual(error.errorCode, 1004, "Token expired error should have correct error code")
    }

    func testAuthError_CustomError_CorrectDescription() {
        // Given
        let customMessage = "Custom error message"
        let error = AuthError.custom(customMessage)

        // Then
        XCTAssertEqual(error.localizedDescription, customMessage, "Custom error should have provided message")
        XCTAssertEqual(error.errorCode, 9999, "Custom error should have custom error code")
    }

    func testAuthError_Equatable_SameError_ReturnsTrue() {
        // Given
        let error1 = AuthError.networkError
        let error2 = AuthError.networkError

        // Then
        XCTAssertEqual(error1, error2, "Same errors should be equal")
    }

    func testAuthError_Equatable_DifferentError_ReturnsFalse() {
        // Given
        let error1 = AuthError.networkError
        let error2 = AuthError.invalidCredentials

        // Then
        XCTAssertNotEqual(error1, error2, "Different errors should not be equal")
    }

    func testAuthError_CustomErrorEquatable_SameMessage_ReturnsTrue() {
        // Given
        let error1 = AuthError.custom("Test message")
        let error2 = AuthError.custom("Test message")

        // Then
        XCTAssertEqual(error1, error2, "Custom errors with same message should be equal")
    }

    func testAuthError_CustomErrorEquatable_DifferentMessage_ReturnsFalse() {
        // Given
        let error1 = AuthError.custom("Message 1")
        let error2 = AuthError.custom("Message 2")

        // Then
        XCTAssertNotEqual(error1, error2, "Custom errors with different messages should not be equal")
    }

    // MARK: - Integration Tests

    func testAuthUserWithProvider_AllProviders_CreatesCorrectUsers() {
        // Given
        let providers: [AuthProvider] = [.apple, .google]

        // When & Then
        for provider in providers {
            let user = AuthUser(id: "test-id", email: "test@example.com", name: "Test User", provider: provider)
            XCTAssertEqual(user.provider, provider, "User should have correct provider: \(provider)")
        }
    }

    func testAuthStateTransitions_ValidFlow_CreatesCorrectStates() {
        // Given
        let user = AuthUser(id: "123", email: "test@example.com", name: "Test", provider: .apple)
        let error = AuthError.networkError

        // When & Then - Test complete authentication flow
        let unknownState = AuthState.unknown
        let authenticatingState = AuthState.authenticating
        let authenticatedState = AuthState.authenticated(user)
        let errorState = AuthState.error(error)
        let signedOutState = AuthState.signedOut

        XCTAssertFalse(unknownState.isAuthenticated)
        XCTAssertTrue(authenticatingState.isAuthenticating)
        XCTAssertTrue(authenticatedState.isAuthenticated)
        XCTAssertNotNil(errorState.error)
        XCTAssertFalse(signedOutState.isAuthenticated)
    }
}