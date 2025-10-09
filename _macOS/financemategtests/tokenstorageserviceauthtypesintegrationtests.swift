import XCTest
import Security
@testable import FinanceMate

/// Comprehensive failing tests for TokenStorageService AuthTypes integration
/// Phase 1 RED - These tests document TokenStorageService import issues with AuthTypes
/// Following atomic TDD methodology - tests fail before implementation
final class TokenStorageServiceAuthTypesIntegrationTests: XCTestCase {

    // MARK: - TokenStorageService AuthTypes Integration Tests

    /// Test: TokenStorageService should use AuthState from AuthTypes
    /// Expected: Compilation failure - "cannot find type 'AuthState' in scope"
    func testTokenStorageService_AuthStateType_ImportResolution() {
        // Given: TokenStorageService stores and retrieves AuthState
        // When: Using AuthState in TokenStorageService methods
        // Then: Should fail compilation due to missing AuthState import

        let tokenStorage = TokenStorageService.shared

        // This should fail: "cannot find type 'AuthState' in scope"
        let authState = AuthState.unknown

        tokenStorage.storeAuthState(authState)
        let retrievedAuthState = tokenStorage.getAuthState()

        XCTAssertNotNil(retrievedAuthState, "AuthState should be accessible in TokenStorageService")
    }

    /// Test: TokenStorageService should use AuthProvider from AuthTypes
    /// Expected: Compilation failure - "cannot find type 'AuthProvider' in scope"
    func testTokenStorageService_AuthProviderType_ImportResolution() {
        // Given: TokenStorageService uses AuthProvider for provider-specific operations
        // When: Using AuthProvider in TokenStorageService methods
        // Then: Should fail compilation due to missing AuthProvider import

        let tokenStorage = TokenStorageService.shared

        // This should fail: "cannot find type 'AuthProvider' in scope"
        let appleProvider = AuthProvider.apple
        let googleProvider = AuthProvider.google

        // Test provider-specific operations
        tokenStorage.clearData(for: appleProvider)
        tokenStorage.clearData(for: googleProvider)

        let currentProvider = tokenStorage.getCurrentProvider()
        XCTAssertNotNil(currentProvider, "AuthProvider should be accessible in TokenStorageService")
    }

    /// Test: TokenStorageService should use AuthUser from AuthTypes
    /// Expected: Compilation failure - "cannot find type 'AuthUser' in scope"
    func testTokenStorageService_AuthUserType_ImportResolution() {
        // Given: TokenStorageService stores user information
        // When: Using AuthUser indirectly through AuthState
        // Then: Should fail compilation due to missing AuthUser import

        let tokenStorage = TokenStorageService.shared

        // This should fail: "cannot find type 'AuthUser' in scope"
        let user = AuthUser(id: "test", email: "test@example.com", name: "Test", provider: .apple)
        let authState = AuthState.authenticated(user)

        tokenStorage.storeAuthState(authState)
        let retrievedAuthState = tokenStorage.getAuthState()

        XCTAssertEqual(retrievedAuthState?.user?.id, user.id, "AuthUser should be accessible through AuthState")
    }

    /// Test: TokenStorageService should use TokenInfo from AuthTypes
    /// Expected: Compilation failure - "cannot find type 'TokenInfo' in scope"
    func testTokenStorageService_TokenInfoType_ImportResolution() {
        // Given: TokenStorageService stores token information
        // When: Using TokenInfo in storage operations
        // Then: Should fail compilation due to missing TokenInfo import

        let tokenStorage = TokenStorageService.shared

        // This should fail: "cannot find type 'TokenInfo' in scope"
        let tokenInfo = TokenInfo(
            accessToken: "test_access_token",
            refreshToken: "test_refresh_token",
            expiresIn: 3600,
            tokenType: "Bearer"
        )

        // Test token storage operations
        tokenStorage.storeTokenInfo(tokenInfo, for: .apple)
        let retrievedTokenInfo = tokenStorage.getTokenInfo(for: .apple)

        XCTAssertNotNil(retrievedTokenInfo, "TokenInfo should be accessible in TokenStorageService")
    }

    /// Test: TokenStorageService should use GoogleUserInfo from AuthTypes
    /// Expected: Compilation failure - "cannot find type 'GoogleUserInfo' in scope"
    func testTokenStorageService_GoogleUserInfoType_ImportResolution() {
        // Given: TokenStorageService stores Google user information
        // When: Using GoogleUserInfo in Google credential operations
        // Then: Should fail compilation due to missing GoogleUserInfo import

        let tokenStorage = TokenStorageService.shared

        // This should fail: "cannot find type 'GoogleUserInfo' in scope"
        let googleUserInfo = GoogleUserInfo(
            id: "google_user_123",
            email: "test@gmail.com",
            name: "Google User",
            picture: "https://example.com/avatar.jpg",
            verifiedEmail: true
        )

        // Test Google credential storage
        tokenStorage.storeGoogleCredentials(
            userID: googleUserInfo.id,
            email: googleUserInfo.email,
            name: googleUserInfo.name,
            accessToken: "google_access_token",
            refreshToken: "google_refresh_token",
            userInfo: googleUserInfo
        )

        let retrievedCredentials = tokenStorage.getGoogleCredentials()
        XCTAssertEqual(retrievedCredentials.userInfo?.id, googleUserInfo.id, "GoogleUserInfo should be accessible in TokenStorageService")
    }

    // MARK: - TokenStorageService Method Tests with AuthTypes

    /// Test: TokenStorageService Apple Sign In operations with AuthTypes
    /// Expected: Compilation failure - AuthTypes not accessible in Apple operations
    func testTokenStorageService_AppleSignIn_AuthTypesIntegration() {
        // Given: TokenStorageService stores Apple Sign In credentials
        // When: Performing Apple Sign In storage operations
        // Then: Should fail compilation due to AuthTypes not being accessible

        let tokenStorage = TokenStorageService.shared

        let userID = "apple_user_123"
        let email = "user@icloud.com"
        let name = "Apple User"
        let idToken = "apple_id_token"
        let refreshToken = "apple_refresh_token"
        let provider = AuthProvider.apple

        // Test Apple credential storage
        tokenStorage.storeAppleCredentials(
            userID: userID,
            email: email,
            name: name,
            idToken: idToken,
            refreshToken: refreshToken
        )

        // Test token info storage
        let tokenInfo = TokenInfo(
            accessToken: idToken,
            refreshToken: refreshToken,
            expiresIn: 3600
        )
        tokenStorage.storeTokenInfo(tokenInfo, for: provider)

        // Test retrieval
        let appleCredentials = tokenStorage.getAppleCredentials()
        let storedTokenInfo = tokenStorage.getTokenInfo(for: provider)
        let currentProvider = tokenStorage.getCurrentProvider()

        XCTAssertEqual(appleCredentials.userID, userID, "Apple credentials should be stored and retrieved")
        XCTAssertEqual(storedTokenInfo?.accessToken, idToken, "Token info should be stored and retrieved")
        XCTAssertEqual(currentProvider, provider, "Current provider should be set correctly")
    }

    /// Test: TokenStorageService Google OAuth operations with AuthTypes
    /// Expected: Compilation failure - AuthTypes not accessible in Google operations
    func testTokenStorageService_GoogleOAuth_AuthTypesIntegration() {
        // Given: TokenStorageService stores Google OAuth credentials
        // When: Performing Google OAuth storage operations
        // Then: Should fail compilation due to AuthTypes not being accessible

        let tokenStorage = TokenStorageService.shared

        let userID = "google_user_456"
        let email = "user@gmail.com"
        let name = "Google User"
        let accessToken = "google_access_token"
        let refreshToken = "google_refresh_token"
        let provider = AuthProvider.google

        let googleUserInfo = GoogleUserInfo(
            id: userID,
            email: email,
            name: name,
            picture: "https://example.com/avatar.jpg",
            verifiedEmail: true
        )

        // Test Google credential storage
        tokenStorage.storeGoogleCredentials(
            userID: userID,
            email: email,
            name: name,
            accessToken: accessToken,
            refreshToken: refreshToken,
            userInfo: googleUserInfo
        )

        // Test token info storage
        let tokenInfo = TokenInfo(
            accessToken: accessToken,
            refreshToken: refreshToken,
            expiresIn: 3600,
            tokenType: "Bearer"
        )
        tokenStorage.storeTokenInfo(tokenInfo, for: provider)

        // Test retrieval
        let googleCredentials = tokenStorage.getGoogleCredentials()
        let storedTokenInfo = tokenStorage.getTokenInfo(for: provider)
        let currentProvider = tokenStorage.getCurrentProvider()

        XCTAssertEqual(googleCredentials.userID, userID, "Google credentials should be stored and retrieved")
        XCTAssertEqual(googleCredentials.userInfo?.id, userID, "Google user info should be stored and retrieved")
        XCTAssertEqual(storedTokenInfo?.accessToken, accessToken, "Token info should be stored and retrieved")
        XCTAssertEqual(currentProvider, provider, "Current provider should be set correctly")
    }

    /// Test: TokenStorageService authentication state management with AuthTypes
    /// Expected: Compilation failure - AuthState not accessible in state management
    func testTokenStorageService_AuthStateManagement_AuthTypesIntegration() {
        // Given: TokenStorageService manages authentication state
        // When: Storing and retrieving authentication states
        // Then: Should fail compilation due to AuthState not being accessible

        let tokenStorage = TokenStorageService.shared

        // Create test user
        let user = AuthUser(id: "test_user", email: "test@example.com", name: "Test User", provider: .apple)

        // Test all authentication states
        let unknownState = AuthState.unknown
        let authenticatingState = AuthState.authenticating
        let authenticatedState = AuthState.authenticated(user)
        let signedOutState = AuthState.signedOut
        let errorState = AuthState.error(.networkError)

        // Store and retrieve each state
        let states: [AuthState] = [unknownState, authenticatingState, authenticatedState, signedOutState, errorState]

        for (index, state) in states.enumerated() {
            tokenStorage.storeAuthState(state)
            let retrievedState = tokenStorage.getAuthState()
            XCTAssertNotNil(retrievedState, "AuthState at index \(index) should be retrievable")
        }

        // Test current provider after state changes
        let currentProvider = tokenStorage.getCurrentProvider()
        XCTAssertNotNil(currentProvider, "Current provider should be accessible after state changes")
    }

    /// Test: TokenStorageService provider-specific data clearing with AuthTypes
    /// Expected: Compilation failure - AuthProvider not accessible in clearing operations
    func testTokenStorageService_ProviderDataClearing_AuthTypesIntegration() {
        // Given: TokenStorageService clears data for specific providers
        // When: Clearing provider-specific data
        // Then: Should fail compilation due to AuthProvider not being accessible

        let tokenStorage = TokenStorageService.shared

        // Store data for both providers
        let appleProvider = AuthProvider.apple
        let googleProvider = AuthProvider.google

        // Store Apple credentials
        tokenStorage.storeAppleCredentials(
            userID: "apple_user",
            email: "apple@icloud.com",
            name: "Apple User",
            idToken: "apple_token",
            refreshToken: nil
        )

        // Store Google credentials
        tokenStorage.storeGoogleCredentials(
            userID: "google_user",
            email: "google@gmail.com",
            name: "Google User",
            accessToken: "google_token",
            refreshToken: "google_refresh",
            userInfo: GoogleUserInfo(id: "google_user", email: "google@gmail.com", name: "Google User")
        )

        // Clear data for specific providers
        tokenStorage.clearData(for: appleProvider)
        tokenStorage.clearData(for: googleProvider)

        // Verify current provider is cleared
        let currentProvider = tokenStorage.getCurrentProvider()
        XCTAssertNil(currentProvider, "Current provider should be nil after clearing all providers")
    }

    /// Test: TokenStorageService token validation with AuthTypes
    /// Expected: Compilation failure - TokenInfo not accessible in validation
    func testTokenStorageService_TokenValidation_AuthTypesIntegration() {
        // Given: TokenStorageService validates token information
        // When: Checking token validity and expiration
        // Then: Should fail compilation due to TokenInfo not being accessible

        let tokenStorage = TokenStorageService.shared

        // Create tokens with different expiration times
        let validToken = TokenInfo(
            accessToken: "valid_token",
            refreshToken: "refresh_token",
            expiresIn: 3600, // 1 hour from now
            tokenType: "Bearer"
        )

        let expiredToken = TokenInfo(
            accessToken: "expired_token",
            refreshToken: "expired_refresh",
            expiresIn: -3600, // 1 hour ago (expired)
            tokenType: "Bearer"
        )

        let nearExpiryToken = TokenInfo(
            accessToken: "near_expiry_token",
            refreshToken: "near_expiry_refresh",
            expiresIn: 300, // 5 minutes from now (near expiry)
            tokenType: "Bearer"
        )

        // Store tokens for different providers
        tokenStorage.storeTokenInfo(validToken, for: .apple)
        tokenStorage.storeTokenInfo(expiredToken, for: .google)
        tokenStorage.storeTokenInfo(nearExpiryToken, for: .apple)

        // Test token validation
        let hasValidAppleToken = tokenStorage.hasValidToken(for: .apple)
        let hasValidGoogleToken = tokenStorage.hasValidToken(for: .google)

        XCTAssertTrue(hasValidAppleToken, "Apple should have valid token")
        XCTAssertFalse(hasValidGoogleToken, "Google should not have valid token (expired)")

        // Retrieve and validate token properties
        let appleTokenInfo = tokenStorage.getTokenInfo(for: .apple)
        let googleTokenInfo = tokenStorage.getTokenInfo(for: .google)

        XCTAssertNotNil(appleTokenInfo, "Apple token info should be retrievable")
        XCTAssertNotNil(googleTokenInfo, "Google token info should be retrievable")
    }

    // MARK: - TokenStorageService Error Handling Tests with AuthTypes

    /// Test: TokenStorageService error handling with AuthTypes
    /// Expected: Compilation failure - AuthError not accessible in error handling
    func testTokenStorageService_ErrorHandling_AuthTypesIntegration() {
        // Given: TokenStorageService handles authentication errors
        // When: Storing error states
        // Then: Should fail compilation due to AuthError not being accessible

        let tokenStorage = TokenStorageService.shared

        // Test different error types
        let networkError = AuthError.networkError
        let credentialsError = AuthError.invalidCredentials
        let cancelledError = AuthError.cancelledByUser
        let tokenExpiredError = AuthError.tokenExpired
        let customError = AuthError.custom("Test custom error")

        // Create error states
        let networkErrorState = AuthState.error(networkError)
        let credentialsErrorState = AuthState.error(credentialsError)
        let cancelledErrorState = AuthState.error(cancelledError)
        let tokenExpiredErrorState = AuthState.error(tokenExpiredError)
        let customErrorState = AuthState.error(customError)

        // Store and retrieve error states
        let errorStates = [
            networkErrorState,
            credentialsErrorState,
            cancelledErrorState,
            tokenExpiredErrorState,
            customErrorState
        ]

        for (index, errorState) in errorStates.enumerated() {
            tokenStorage.storeAuthState(errorState)
            let retrievedState = tokenStorage.getAuthState()

            if case .error(let error) = retrievedState {
                XCTAssertNotNil(error, "Error at index \(index) should be retrievable")
                XCTAssertNotNil(error.localizedDescription, "Error description should be accessible")
                XCTAssertNotNil(error.errorCode, "Error code should be accessible")
            }
        }
    }

    // MARK: - TokenStorageService Comprehensive Integration Test

    /// Test: Complete TokenStorageService integration with all AuthTypes
    /// Expected: Compilation failure - comprehensive AuthTypes import issues
    func testTokenStorageService_CompleteIntegration_AllAuthTypes() {
        // Given: TokenStorageService integrates with all AuthTypes
        // When: Performing complete authentication workflow
        // Then: Should fail compilation due to comprehensive AuthTypes import issues

        let tokenStorage = TokenStorageService.shared

        // Complete Apple Sign In workflow
        let appleUser = AuthUser(
            id: "apple_complete_user",
            email: "apple@icloud.com",
            name: "Apple Complete User",
            provider: .apple
        )

        let appleTokenInfo = TokenInfo(
            accessToken: "apple_access_token",
            refreshToken: "apple_refresh_token",
            expiresIn: 3600,
            tokenType: "Bearer"
        )

        let appleAuthState = AuthState.authenticated(appleUser)

        // Store Apple data
        tokenStorage.storeAppleCredentials(
            userID: appleUser.id,
            email: appleUser.email,
            name: appleUser.name,
            idToken: appleTokenInfo.accessToken,
            refreshToken: appleTokenInfo.refreshToken
        )

        tokenStorage.storeTokenInfo(appleTokenInfo, for: .apple)
        tokenStorage.storeAuthState(appleAuthState)

        // Complete Google OAuth workflow
        let googleUserInfo = GoogleUserInfo(
            id: "google_complete_user",
            email: "google@gmail.com",
            name: "Google Complete User",
            picture: "https://example.com/google_avatar.jpg",
            verifiedEmail: true
        )

        let googleUser = AuthUser(
            id: googleUserInfo.id,
            email: googleUserInfo.email,
            name: googleUserInfo.name,
            provider: .google
        )

        let googleTokenInfo = TokenInfo(
            accessToken: "google_access_token",
            refreshToken: "google_refresh_token",
            expiresIn: 3600,
            tokenType: "Bearer"
        )

        let googleAuthState = AuthState.authenticated(googleUser)

        // Store Google data
        tokenStorage.storeGoogleCredentials(
            userID: googleUser.id,
            email: googleUser.email,
            name: googleUser.name,
            accessToken: googleTokenInfo.accessToken,
            refreshToken: googleTokenInfo.refreshToken,
            userInfo: googleUserInfo
        )

        tokenStorage.storeTokenInfo(googleTokenInfo, for: .google)
        tokenStorage.storeAuthState(googleAuthState)

        // Verify all data is stored and retrievable
        let currentProvider = tokenStorage.getCurrentProvider()
        let currentAuthState = tokenStorage.getAuthState()
        let appleTokenInfoRetrieved = tokenStorage.getTokenInfo(for: .apple)
        let googleTokenInfoRetrieved = tokenStorage.getTokenInfo(for: .google)
        let appleCredentials = tokenStorage.getAppleCredentials()
        let googleCredentials = tokenStorage.getGoogleCredentials()

        // Verify all AuthTypes are working correctly
        XCTAssertNotNil(currentProvider, "Current provider should be accessible")
        XCTAssertNotNil(currentAuthState, "Current auth state should be accessible")
        XCTAssertNotNil(appleTokenInfoRetrieved, "Apple token info should be retrievable")
        XCTAssertNotNil(googleTokenInfoRetrieved, "Google token info should be retrievable")
        XCTAssertNotNil(appleCredentials, "Apple credentials should be retrievable")
        XCTAssertNotNil(googleCredentials, "Google credentials should be retrievable")

        // Verify user information is accessible
        if case .authenticated(let user) = currentAuthState {
            XCTAssertNotNil(user.id, "User ID should be accessible")
            XCTAssertNotNil(user.email, "User email should be accessible")
            XCTAssertNotNil(user.name, "User name should be accessible")
            XCTAssertNotNil(user.provider, "User provider should be accessible")
        }

        // Test error state storage
        let errorState = AuthState.error(.custom("Test error for complete integration"))
        tokenStorage.storeAuthState(errorState)
        let retrievedErrorState = tokenStorage.getAuthState()

        if case .error(let error) = retrievedErrorState {
            XCTAssertNotNil(error.localizedDescription, "Error description should be accessible")
        }

        // Test clearing all data
        tokenStorage.clearAllData()
        let clearedAuthState = tokenStorage.getAuthState()
        let clearedProvider = tokenStorage.getCurrentProvider()

        XCTAssertNil(clearedAuthState, "Auth state should be cleared")
        XCTAssertNil(clearedProvider, "Current provider should be cleared")
    }
}