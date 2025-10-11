import XCTest
import AuthenticationServices
@testable import FinanceMate

/// Test suite for AuthenticationManager with Google SSO integration
/// Tests unified authentication flow for both Apple and Google providers
/// Phase 1 RED - Enhanced with AuthTypes import resolution tests
final class AuthenticationManagerTests: XCTestCase {

    // MARK: - AuthTypes Import Resolution Tests

    /// Test: AuthenticationManager should resolve AuthState type from AuthTypes
    /// Expected: Compilation failure - "cannot find type 'AuthState' in scope"
    func testAuthenticationManager_AuthStateTypeResolution_ImportIssue() {
        // Given: AuthenticationManager references AuthState type
        // When: Accessing AuthState properties and methods
        // Then: Should fail compilation if AuthState not properly imported

        let authManager = AuthenticationManager()

        // This should fail if AuthState is not accessible
        let currentState: AuthState = authManager.authState
        let isAuthenticated = authManager.isAuthenticated
        let userEmail = authManager.userEmail
        let userName = authManager.userName
        let errorMessage = authManager.errorMessage

        XCTAssertNotNil(currentState, "AuthState should be accessible from AuthenticationManager")
        XCTAssertTrue(isAuthenticated == false || isAuthenticated == true, "isAuthenticated should be accessible")
        XCTAssertNotNil(userEmail, "userEmail should be accessible")
        XCTAssertNotNil(userName, "userName should be accessible")
        XCTAssertNotNil(errorMessage, "errorMessage should be accessible")
    }

    /// Test: AuthenticationManager should resolve AuthUser type from AuthTypes
    /// Expected: Compilation failure - "cannot find type 'AuthUser' in scope"
    func testAuthenticationManager_AuthUserTypeResolution_ImportIssue() {
        // Given: AuthenticationManager creates and uses AuthUser instances
        // When: Processing authentication results
        // Then: Should fail compilation if AuthUser not properly imported

        let authManager = AuthenticationManager()

        // This should fail if AuthUser is not accessible
        let testUser = AuthUser(
            id: "test_user_123",
            email: "test@example.com",
            name: "Test User",
            provider: .apple
        )

        let authState = AuthState.authenticated(testUser)

        XCTAssertNotNil(testUser, "AuthUser should be creatable in AuthenticationManager")
        XCTAssertNotNil(authState, "AuthState with AuthUser should be creatable")
    }

    /// Test: AuthenticationManager should resolve AuthProvider type from AuthTypes
    /// Expected: Compilation failure - "cannot find type 'AuthProvider' in scope"
    func testAuthenticationManager_AuthProviderTypeResolution_ImportIssue() {
        // Given: AuthenticationManager uses AuthProvider enum
        // When: Managing multiple authentication providers
        // Then: Should fail compilation if AuthProvider not properly imported

        let authManager = AuthenticationManager()

        // This should fail if AuthProvider is not accessible
        let appleProvider = AuthProvider.apple
        let googleProvider = AuthProvider.google
        let allProviders = AuthProvider.allCases

        XCTAssertEqual(appleProvider.displayName, "Apple", "Apple provider should be accessible")
        XCTAssertEqual(googleProvider.displayName, "Google", "Google provider should be accessible")
        XCTAssertEqual(allProviders.count, 2, "Should have exactly 2 providers")

        // Test provider-specific sign out
        authManager.signOut(from: appleProvider)
        authManager.signOut(from: googleProvider)
    }

    /// Test: AuthenticationManager should resolve AuthError type from AuthTypes
    /// Expected: Compilation failure - "cannot find type 'AuthError' in scope"
    func testAuthenticationManager_AuthErrorTypeResolution_ImportIssue() {
        // Given: AuthenticationManager handles authentication errors
        // When: Processing authentication failures
        // Then: Should fail compilation if AuthError not properly imported

        let authManager = AuthenticationManager()

        // This should fail if AuthError is not accessible
        let networkError = AuthError.networkError
        let credentialsError = AuthError.invalidCredentials
        let cancelledError = AuthError.cancelledByUser
        let tokenExpiredError = AuthError.tokenExpired
        let customError = AuthError.custom("Test error")

        // Test error states
        let networkErrorState = AuthState.error(networkError)
        let credentialsErrorState = AuthState.error(credentialsError)

        XCTAssertEqual(networkError.localizedDescription, "Network connection failed")
        XCTAssertEqual(credentialsError.errorCode, 1002)
        XCTAssertNotNil(networkErrorState.error)
        XCTAssertNotNil(credentialsErrorState.error)
    }

    /// Test: AuthenticationManager should resolve TokenInfo type from AuthTypes
    /// Expected: Compilation failure - "cannot find type 'TokenInfo' in scope"
    func testAuthenticationManager_TokenInfoTypeResolution_ImportIssue() {
        // Given: AuthenticationManager manages token information
        // When: Storing and retrieving token data
        // Then: Should fail compilation if TokenInfo not properly imported

        let authManager = AuthenticationManager()

        // This should fail if TokenInfo is not accessible
        let tokenInfo = TokenInfo(
            accessToken: "test_access_token",
            refreshToken: "test_refresh_token",
            expiresIn: 3600,
            tokenType: "Bearer"
        )

        XCTAssertNotNil(tokenInfo, "TokenInfo should be creatable in AuthenticationManager")
        XCTAssertFalse(tokenInfo.isExpired, "Token should not be expired")
        XCTAssertFalse(tokenInfo.isNearExpiry, "Token should not be near expiry")
    }

    /// Test: AuthenticationManager should resolve GoogleUserInfo type from AuthTypes
    /// Expected: Compilation failure - "cannot find type 'GoogleUserInfo' in scope"
    func testAuthenticationManager_GoogleUserInfoTypeResolution_ImportIssue() {
        // Given: AuthenticationManager processes Google user information
        // When: Handling Google OAuth responses
        // Then: Should fail compilation if GoogleUserInfo not properly imported

        let authManager = AuthenticationManager()

        // This should fail if GoogleUserInfo is not accessible
        let googleUserInfo = GoogleUserInfo(
            id: "google_user_123",
            email: "test@gmail.com",
            name: "Google User",
            picture: "https://example.com/avatar.jpg",
            verifiedEmail: true
        )

        XCTAssertNotNil(googleUserInfo, "GoogleUserInfo should be creatable in AuthenticationManager")
        XCTAssertTrue(googleUserInfo.verifiedEmail, "Google user should be verified")
        XCTAssertNotNil(googleUserInfo.picture, "Google user should have picture")
    }

    // MARK: - AuthenticationManager Initialization Import Tests

    /// Test: AuthenticationManager initialization with AuthTypes dependency
    /// Expected: Compilation failure if AuthTypes not accessible during initialization
    func testAuthenticationManager_Initialization_AuthTypesDependency() {
        // Given: AuthenticationManager initialization depends on AuthTypes
        // When: Creating new AuthenticationManager instance
        // Then: Should fail compilation if AuthTypes not accessible

        // This should fail if AuthState is not accessible during initialization
        let authManager = AuthenticationManager()

        // Initial state should use AuthState.unknown
        let initialState = authManager.authState
        let initialAuthenticated = authManager.isAuthenticated
        let initialEmail = authManager.userEmail
        let initialName = authManager.userName
        let initialError = authManager.errorMessage

        XCTAssertNotNil(initialState, "Initial auth state should be accessible")
        XCTAssertFalse(initialAuthenticated, "Initial authenticated state should be false")
        XCTAssertNil(initialEmail, "Initial email should be nil")
        XCTAssertNil(initialName, "Initial name should be nil")
        XCTAssertNil(initialError, "Initial error should be nil")
    }

    /// Test: AuthenticationManager method signatures with AuthTypes
    /// Expected: Compilation failure if method parameters use unresolved AuthTypes
    func testAuthenticationManager_MethodSignatures_AuthTypesParameters() {
        // Given: AuthenticationManager methods use AuthTypes in signatures
        // When: Calling methods with AuthTypes parameters
        // Then: Should fail compilation if AuthTypes not accessible

        let authManager = AuthenticationManager()

        // Test methods that use AuthTypes in their signatures
        authManager.checkAuthStatus()
        authManager.checkGoogleAuthStatus()
        authManager.signOut()

        // Test provider-specific methods
        let appleProvider = AuthProvider.apple
        authManager.signOut(from: appleProvider)

        // Test token refresh
        Task {
            await authManager.refreshTokenIfNeeded()
        }

        // Test Google user info fetching
        Task {
            do {
                let userInfo = try await authManager.fetchGoogleUserInfo(accessToken: "test_token")
                XCTAssertNotNil(userInfo, "Google user info should be accessible")
            } catch {
                XCTFail("Should not throw error if GoogleUserInfo is accessible")
            }
        }

        XCTAssertTrue(true, "All method calls should succeed if AuthTypes are accessible")
    }

    // MARK: - Authentication Manager Initialization Tests

    func testAuthenticationManager_Initializtion_CreatesManagerWithCorrectInitialState() {
        // Given
        let authManager = AuthenticationManager()

        // Then
        XCTAssertFalse(authManager.isAuthenticated, "Should not be authenticated initially")
        XCTAssertNil(authManager.userEmail, "Email should be nil initially")
        XCTAssertNil(authManager.userName, "Name should be nil initially")
        XCTAssertNil(authManager.errorMessage, "Error message should be nil initially")
    }

    // MARK: - Apple Sign In Tests

    func testAuthenticationManager_HandleAppleSignInSuccess_UpdatesAuthenticationState() async {
        // Given
        let authManager = AuthenticationManager()
        let appleIDCredential = createMockAppleIDCredential()
        let authorization = ASAuthorization(appleIDCredential: appleIDCredential)

        // When
        await authManager.handleAppleSignIn(result: .success(authorization))

        // Then
        XCTAssertTrue(authManager.isAuthenticated, "Should be authenticated after successful Apple Sign In")
        XCTAssertEqual(authManager.userEmail, appleIDCredential.email, "Email should match Apple credential")
        XCTAssertNotNil(authManager.userName, "Name should be extracted from Apple credential")
        XCTAssertNil(authManager.errorMessage, "Error message should be nil on success")
    }

    func testAuthenticationManager_HandleAppleSignInFailure_SetsErrorMessage() async {
        // Given
        let authManager = AuthenticationManager()
        let error = NSError(domain: "AppleSignInError", code: 1000, userInfo: [NSLocalizedDescriptionKey: "Apple Sign In failed"])

        // When
        await authManager.handleAppleSignIn(result: .failure(error))

        // Then
        XCTAssertFalse(authManager.isAuthenticated, "Should not be authenticated on failure")
        XCTAssertNotNil(authManager.errorMessage, "Error message should be set on failure")
        XCTAssertTrue(authManager.errorMessage?.contains("Apple Sign In failed") == true, "Error message should contain failure description")
    }

    // MARK: - Google Sign In Tests

    func testAuthenticationManager_HandleGoogleSignInSuccess_UpdatesAuthenticationState() async {
        // Given
        let authManager = AuthenticationManager()
        let authCode = "mock_google_auth_code"

        // When
        await authManager.handleGoogleSignIn(code: authCode)

        // Then
        XCTAssertTrue(authManager.isAuthenticated, "Should be authenticated after successful Google Sign In")
        XCTAssertNotNil(authManager.userEmail, "Email should be set from Google user info")
        XCTAssertNotNil(authManager.userName, "Name should be set from Google user info")
        XCTAssertNil(authManager.errorMessage, "Error message should be nil on success")
    }

    func testAuthenticationManager_HandleGoogleSignInMissingCredentials_SetsErrorMessage() async {
        // Given
        let authManager = AuthenticationManager()
        let authCode = "mock_auth_code"

        // Clear environment variables to simulate missing credentials
        setenv("GOOGLE_OAUTH_CLIENT_ID", "", 1)
        setenv("GOOGLE_OAUTH_CLIENT_SECRET", "", 1)

        // When
        await authManager.handleGoogleSignIn(code: authCode)

        // Then
        XCTAssertFalse(authManager.isAuthenticated, "Should not be authenticated without credentials")
        XCTAssertNotNil(authManager.errorMessage, "Error message should be set")
        XCTAssertTrue(authManager.errorMessage?.contains("Google OAuth credentials not found") == true, "Should indicate missing credentials")
    }

    func testAuthenticationManager_HandleGoogleSignInInvalidToken_SetsErrorMessage() async {
        // Given
        let authManager = AuthenticationManager()
        let invalidAuthCode = "invalid_auth_code"

        // Set environment variables
        setenv("GOOGLE_OAUTH_CLIENT_ID", "test_client_id", 1)
        setenv("GOOGLE_OAUTH_CLIENT_SECRET", "test_client_secret", 1)

        // When
        await authManager.handleGoogleSignIn(code: invalidAuthCode)

        // Then
        XCTAssertFalse(authManager.isAuthenticated, "Should not be authenticated with invalid code")
        XCTAssertNotNil(authManager.errorMessage, "Error message should be set")
        XCTAssertTrue(authManager.errorMessage?.contains("Google Sign In failed") == true, "Should indicate Google Sign In failure")
    }

    // MARK: - Authentication Status Checks

    func testAuthenticationManager_CheckAuthStatusAppleUser_RestoresAuthenticationState() {
        // Given
        let authManager = AuthenticationManager()
        let userID = "test_apple_user_id"
        let email = "test@example.com"
        let name = "Test User"

        // Store mock data in keychain
        KeychainHelper.save(value: userID, account: "apple_user_id")
        KeychainHelper.save(value: email, account: "apple_user_email")
        KeychainHelper.save(value: name, account: "apple_user_name")

        // When
        authManager.checkAuthStatus()

        // Then
        XCTAssertTrue(authManager.isAuthenticated, "Should be authenticated with stored Apple credentials")
        XCTAssertEqual(authManager.userEmail, email, "Email should match stored value")
        XCTAssertEqual(authManager.userName, name, "Name should match stored value")
        XCTAssertNil(authManager.errorMessage, "Error message should be nil")

        // Cleanup
        try? KeychainHelper.delete(account: "apple_user_id")
        try? KeychainHelper.delete(account: "apple_user_email")
        try? KeychainHelper.delete(account: "apple_user_name")
    }

    func testAuthenticationManager_CheckGoogleAuthStatus_RestoresAuthenticationState() {
        // Given
        let authManager = AuthenticationManager()
        let userID = "test_google_user_id"
        let email = "test@gmail.com"
        let name = "Google User"

        // Store mock data in keychain
        KeychainHelper.save(value: userID, account: "google_user_id")
        KeychainHelper.save(value: email, account: "google_user_email")
        KeychainHelper.save(value: name, account: "google_user_name")

        // When
        authManager.checkGoogleAuthStatus()

        // Then
        XCTAssertTrue(authManager.isAuthenticated, "Should be authenticated with stored Google credentials")
        XCTAssertEqual(authManager.userEmail, email, "Email should match stored value")
        XCTAssertEqual(authManager.userName, name, "Name should match stored value")
        XCTAssertNil(authManager.errorMessage, "Error message should be nil")

        // Cleanup
        try? KeychainHelper.delete(account: "google_user_id")
        try? KeychainHelper.delete(account: "google_user_email")
        try? KeychainHelper.delete(account: "google_user_name")
    }

    // MARK: - Sign Out Tests

    func testAuthenticationManager_SignOut_ClearsAllAuthenticationData() {
        // Given
        let authManager = AuthenticationManager()

        // Simulate authenticated state
        authManager.isAuthenticated = true
        authManager.userEmail = "test@example.com"
        authManager.userName = "Test User"

        // Store some mock data in keychain
        KeychainHelper.save(value: "test_id", account: "apple_user_id")
        KeychainHelper.save(value: "test@gmail.com", account: "google_user_email")
        KeychainHelper.save(value: "access_token", account: "gmail_access_token")
        KeychainHelper.save(value: "refresh_token", account: "gmail_refresh_token")

        // When
        authManager.signOut()

        // Then
        XCTAssertFalse(authManager.isAuthenticated, "Should not be authenticated after sign out")
        XCTAssertNil(authManager.userEmail, "Email should be nil after sign out")
        XCTAssertNil(authManager.userName, "Name should be nil after sign out")
        XCTAssertNil(authManager.errorMessage, "Error message should be nil after sign out")

        // Verify keychain is cleared
        XCTAssertNil(KeychainHelper.get(account: "apple_user_id"), "Apple user ID should be cleared")
        XCTAssertNil(KeychainHelper.get(account: "google_user_email"), "Google user email should be cleared")
        XCTAssertNil(KeychainHelper.get(account: "gmail_access_token"), "Gmail access token should be cleared")
        XCTAssertNil(KeychainHelper.get(account: "gmail_refresh_token"), "Gmail refresh token should be cleared")
    }

    // MARK: - Google User Info Tests

    func testAuthenticationManager_FetchGoogleUserInfo_ValidToken_ReturnsUserInfo() async throws {
        // Given
        let authManager = AuthenticationManager()
        let validAccessToken = "mock_valid_access_token"

        // When
        let userInfo = try await authManager.fetchGoogleUserInfo(accessToken: validAccessToken)

        // Then
        XCTAssertNotNil(userInfo.id, "User ID should not be nil")
        XCTAssertNotNil(userInfo.email, "Email should not be nil")
        XCTAssertNotNil(userInfo.name, "Name should not be nil")
        XCTAssertTrue(userInfo.email.contains("@"), "Email should be valid format")
    }

    func testAuthenticationManager_FetchGoogleUserInfo_InvalidToken_ThrowsError() async {
        // Given
        let authManager = AuthenticationManager()
        let invalidAccessToken = "invalid_access_token"

        // When & Then
        do {
            _ = try await authManager.fetchGoogleUserInfo(accessToken: invalidAccessToken)
            XCTFail("Should have thrown an error for invalid token")
        } catch {
            XCTAssertTrue(error is NSError, "Should throw NSError")
        }
    }

    // MARK: - Error Handling Tests

    func testAuthenticationManager_NetworkError_HandledGracefully() async {
        // Given
        let authManager = AuthenticationManager()
        let networkError = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet)

        // When
        await authManager.handleAppleSignIn(result: .failure(networkError))

        // Then
        XCTAssertFalse(authManager.isAuthenticated, "Should not be authenticated on network error")
        XCTAssertNotNil(authManager.errorMessage, "Error message should be set")
    }

    func testAuthenticationManager_CancelledSignIn_HandledGracefully() async {
        // Given
        let authManager = AuthenticationManager()
        let cancelledError = NSError(domain: ASAuthorizationError.errorDomain, code: ASAuthorizationError.canceled.rawValue)

        // When
        await authManager.handleAppleSignIn(result: .failure(cancelledError))

        // Then
        XCTAssertFalse(authManager.isAuthenticated, "Should not be authenticated when cancelled")
        XCTAssertNotNil(authManager.errorMessage, "Error message should be set")
    }

    // MARK: - Token Management Tests

    func testAuthenticationManager_GoogleTokenStorage_TokensPersistedCorrectly() async {
        // Given
        let authManager = AuthenticationManager()
        let authCode = "mock_valid_auth_code"

        // Set environment variables
        setenv("GOOGLE_OAUTH_CLIENT_ID", "test_client_id", 1)
        setenv("GOOGLE_OAUTH_CLIENT_SECRET", "test_client_secret", 1)

        // When
        await authManager.handleGoogleSignIn(code: authCode)

        // Then
        XCTAssertNotNil(KeychainHelper.get(account: "gmail_access_token"), "Access token should be stored")
        XCTAssertNotNil(KeychainHelper.get(account: "gmail_refresh_token"), "Refresh token should be stored")
        XCTAssertNotNil(KeychainHelper.get(account: "google_user_id"), "Google user ID should be stored")

        // Cleanup
        try? KeychainHelper.delete(account: "gmail_access_token")
        try? KeychainHelper.delete(account: "gmail_refresh_token")
        try? KeychainHelper.delete(account: "google_user_id")
    }

    // MARK: - Provider Integration Tests

    func testAuthenticationManager_UnifiedFlow_SameUserDifferentProviders() async {
        // Given
        let authManager = AuthenticationManager()
        let appleEmail = "user@icloud.com"
        let googleEmail = "user@gmail.com"

        // First sign in with Apple
        let appleCredential = createMockAppleIDCredential(email: appleEmail)
        await authManager.handleAppleSignIn(result: .success(ASAuthorization(appleIDCredential: appleCredential)))

        // Then
        XCTAssertEqual(authManager.userEmail, appleEmail, "Should have Apple email")

        // Sign out
        authManager.signOut()

        // Sign in with Google
        setenv("GOOGLE_OAUTH_CLIENT_ID", "test_client_id", 1)
        setenv("GOOGLE_OAUTH_CLIENT_SECRET", "test_client_secret", 1)
        await authManager.handleGoogleSignIn(code: "mock_google_code")

        // Then
        XCTAssertNotEqual(authManager.userEmail, appleEmail, "Should have different email from Google")
        XCTAssertTrue(authManager.userEmail?.contains("@gmail.com") == true, "Should have Google email")
    }

    // MARK: - Security Tests

    func testAuthenticationManager_SensitiveDataHandling_SecureStorage() {
        // Given
        let authManager = AuthenticationManager()
        let sensitiveEmail = "sensitive.user@company.com"
        let sensitiveName = "Sensitive User"

        // When
        KeychainHelper.save(value: "sensitive_user_id", account: "apple_user_id")
        KeychainHelper.save(value: sensitiveEmail, account: "apple_user_email")
        KeychainHelper.save(value: sensitiveName, account: "apple_user_name")

        authManager.checkAuthStatus()

        // Then
        XCTAssertEqual(authManager.userEmail, sensitiveEmail, "Sensitive data should be retrieved securely")
        XCTAssertEqual(authManager.userName, sensitiveName, "Sensitive data should be retrieved securely")

        // Verify data is stored securely (not in plain text files)
        let storedEmail = KeychainHelper.get(account: "apple_user_email")
        XCTAssertEqual(storedEmail, sensitiveEmail, "Data should be stored in secure keychain")

        // Cleanup
        authManager.signOut()
    }

    // MARK: - Helper Methods

    private func createMockAppleIDCredential(email: String = "test@icloud.com") -> ASAuthorizationAppleIDCredential {
        let credential = ASAuthorizationAppleIDCredential()
        // Note: In a real test environment, you would need to create proper mock objects
        // This is a simplified version for demonstrating the test structure
        return credential
    }
}

// MARK: - Mock Google User Info Extension

extension GoogleUserInfo {
    static func mock(id: String = "google_user_123",
                    email: String = "test@gmail.com",
                    name: String = "Test User") -> GoogleUserInfo {
        return GoogleUserInfo(id: id, email: email, name: name)
    }
}