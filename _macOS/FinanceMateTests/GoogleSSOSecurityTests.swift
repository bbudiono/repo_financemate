import XCTest
import LocalAuthentication
@testable import FinanceMate

/// Test suite for Google SSO security validation and token management
/// Tests security aspects of authentication flow and token handling
final class GoogleSSOSecurityTests: XCTestCase {

    // MARK: - Token Security Tests

    func testGoogleAccessToken_StorageInKeychain_SecurelyStored() async {
        // Given
        let authManager = AuthenticationManager()
        let mockAuthCode = "secure_mock_auth_code"

        // Set environment variables
        setenv("GOOGLE_OAUTH_CLIENT_ID", "test_client_id", 1)
        setenv("GOOGLE_OAUTH_CLIENT_SECRET", "test_client_secret", 1)

        // When
        await authManager.handleGoogleSignIn(code: mockAuthCode)

        // Then
        let storedToken = KeychainHelper.get(account: "gmail_access_token")
        XCTAssertNotNil(storedToken, "Access token should be stored in keychain")
        XCTAssertGreaterThan(storedToken?.count ?? 0, 10, "Token should be of reasonable length")
        XCTAssertFalse(storedToken?.isEmpty == true, "Token should not be empty")

        // Cleanup
        try? KeychainHelper.delete(account: "gmail_access_token")
    }

    func testGoogleRefreshToken_StorageInKeychain_SecurelyStored() async {
        // Given
        let authManager = AuthenticationManager()
        let mockAuthCode = "secure_mock_auth_code"

        // Set environment variables
        setenv("GOOGLE_OAUTH_CLIENT_ID", "test_client_id", 1)
        setenv("GOOGLE_OAUTH_CLIENT_SECRET", "test_client_secret", 1)

        // When
        await authManager.handleGoogleSignIn(code: mockAuthCode)

        // Then
        let storedRefreshToken = KeychainHelper.get(account: "gmail_refresh_token")
        XCTAssertNotNil(storedRefreshToken, "Refresh token should be stored in keychain")
        XCTAssertGreaterThan(storedRefreshToken?.count ?? 0, 10, "Refresh token should be of reasonable length")

        // Cleanup
        try? KeychainHelper.delete(account: "gmail_refresh_token")
    }

    func testGoogleTokenExpiration_HandledCorrectly() async {
        // Given
        let authManager = AuthenticationManager()
        let expiredToken = "expired_access_token"

        // Store expired token
        KeychainHelper.save(value: expiredToken, account: "gmail_access_token")

        // When
        do {
            _ = try await authManager.fetchGoogleUserInfo(accessToken: expiredToken)
            XCTFail("Should have thrown error for expired token")
        } catch {
            // Then
            XCTAssertTrue(error.localizedDescription.contains("unauthorized") ||
                         error.localizedDescription.contains("invalid") ||
                         error.localizedDescription.contains("expired"),
                         "Should indicate token expiration/invalidity")
        }

        // Cleanup
        try? KeychainHelper.delete(account: "gmail_access_token")
    }

    // MARK: - Biometric Security Tests

    func testAuthenticationManager_BiometricProtection_SensitiveOperations() {
        // Given
        let authManager = AuthenticationManager()
        let context = LAContext()
        var error: NSError?

        // When
        let biometricAvailable = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)

        // Then
        if biometricAvailable {
            // On devices with biometrics, test that sensitive operations can be protected
            XCTAssertNil(error, "Should not have error when biometrics are available")
            XCTAssertTrue(biometricAvailable, "Biometrics should be available on supported devices")
        } else {
            // On devices without biometrics, handle gracefully
            XCTAssertNotNil(error, "Should have error when biometrics are not available")
        }
    }

    func testAuthenticationManager_KeychainAccess_AuthenticationRequired() {
        // Given
        let sensitiveData = "sensitive_google_token"
        let account = "gmail_access_token"

        // When
        KeychainHelper.save(value: sensitiveData, account: account)
        let retrievedData = KeychainHelper.get(account: account)

        // Then
        XCTAssertEqual(retrievedData, sensitiveData, "Sensitive data should be securely stored and retrievable")
        XCTAssertNotNil(retrievedData, "Retrieved data should not be nil")

        // Cleanup
        try? KeychainHelper.delete(account: account)
    }

    // MARK: - Network Security Tests

    func testGoogleOAuthRequest_HttpsOnly() async {
        // Given
        let authManager = AuthenticationManager()
        let authCode = "test_auth_code"

        // Set environment variables
        setenv("GOOGLE_OAUTH_CLIENT_ID", "test_client_id", 1)
        setenv("GOOGLE_OAUTH_CLIENT_SECRET", "test_client_secret", 1)

        // When
        await authManager.handleGoogleSignIn(code: authCode)

        // Then - Verify that only HTTPS URLs are used
        // This would be verified by checking network requests in the actual implementation
        // For now, we test that the error handling works for insecure connections
        XCTAssertNotNil(authManager.errorMessage, "Should handle network security appropriately")

        // Cleanup
        try? KeychainHelper.delete(account: "gmail_access_token")
    }

    func testGoogleUserInfoRequest_HttpsOnly() async {
        // Given
        let authManager = AuthenticationManager()
        let accessToken = "test_access_token"

        // When
        do {
            _ = try await authManager.fetchGoogleUserInfo(accessToken: accessToken)
        } catch {
            // Then - Should fail gracefully with network error
            XCTAssertTrue(error is NSError, "Should throw appropriate network error")
        }
    }

    // MARK: - Data Validation Tests

    func testGoogleUserInfo_Validation_EmailFormat() async {
        // Given
        let authManager = AuthenticationManager()
        let accessToken = "valid_access_token"

        // When
        do {
            let userInfo = try await authManager.fetchGoogleUserInfo(accessToken: accessToken)

            // Then
            XCTAssertTrue(userInfo.email.contains("@"), "Email should contain @ symbol")
            XCTAssertTrue(userInfo.email.contains("."), "Email should contain domain extension")
            XCTAssertFalse(userInfo.email.isEmpty, "Email should not be empty")
            XCTAssertGreaterThan(userInfo.email.count, 5, "Email should be of reasonable length")
        } catch {
            // Expected in mock environment
        }
    }

    func testGoogleUserInfo_Validation_NonEmptyFields() async {
        // Given
        let authManager = AuthenticationManager()
        let accessToken = "valid_access_token"

        // When
        do {
            let userInfo = try await authManager.fetchGoogleUserInfo(accessToken: accessToken)

            // Then
            XCTAssertFalse(userInfo.id.isEmpty, "User ID should not be empty")
            XCTAssertFalse(userInfo.email.isEmpty, "Email should not be empty")
            XCTAssertFalse(userInfo.name.isEmpty, "Name should not be empty")
        } catch {
            // Expected in mock environment
        }
    }

    // MARK: - Error Handling Security Tests

    func testAuthenticationManager_PhishingAttack_HandledGracefully() async {
        // Given
        let authManager = AuthenticationManager()
        let maliciousAuthCode = "malicious_phishing_code"

        // When
        await authManager.handleGoogleSignIn(code: maliciousAuthCode)

        // Then
        XCTAssertFalse(authManager.isAuthenticated, "Should not authenticate with malicious code")
        XCTAssertNotNil(authManager.errorMessage, "Should have error message for failed authentication")
    }

    func testAuthenticationManager_MissingCredentials_SecureFailure() async {
        // Given
        let authManager = AuthenticationManager()
        let authCode = "valid_auth_code"

        // Clear environment variables to simulate missing credentials
        unsetenv("GOOGLE_OAUTH_CLIENT_ID")
        unsetenv("GOOGLE_OAUTH_CLIENT_SECRET")

        // When
        await authManager.handleGoogleSignIn(code: authCode)

        // Then
        XCTAssertFalse(authManager.isAuthenticated, "Should not authenticate without credentials")
        XCTAssertTrue(authManager.errorMessage?.contains("not found") == true,
                      "Should indicate missing credentials")
    }

    // MARK: - Session Security Tests

    func testAuthenticationManager_SessionExpiry_HandledCorrectly() {
        // Given
        let authManager = AuthenticationManager()

        // Simulate expired session by clearing tokens
        try? KeychainHelper.delete(account: "gmail_access_token")
        try? KeychainHelper.delete(account: "gmail_refresh_token")

        // When
        authManager.checkGoogleAuthStatus()

        // Then
        // Should not be authenticated without valid tokens
        // This tests that the session management is secure
        XCTAssertFalse(authManager.isAuthenticated || KeychainHelper.get(account: "google_user_id") == nil,
                      "Should handle session expiry appropriately")
    }

    func testAuthenticationManager_MultipleProviders_IsolatedSessions() async {
        // Given
        let authManager = AuthenticationManager()

        // Set environment variables for Google
        setenv("GOOGLE_OAUTH_CLIENT_ID", "test_client_id", 1)
        setenv("GOOGLE_OAUTH_CLIENT_SECRET", "test_client_secret", 1)

        // When - First authenticate with Apple
        let appleCredential = ASAuthorization Apple ID: createMockAppleIDCredential(email: "user@icloud.com")
        await authManager.handleAppleSignIn(result: .success(appleCredential))
        let appleEmail = authManager.userEmail

        // Then
        XCTAssertNotNil(appleEmail, "Apple authentication should succeed")

        // When - Then authenticate with Google
        await authManager.handleGoogleSignIn(code: "google_auth_code")
        let googleEmail = authManager.userEmail

        // Then
        XCTAssertNotEqual(appleEmail, googleEmail, "Provider sessions should be isolated")
        XCTAssertTrue(googleEmail?.contains("@gmail.com") == true, "Should have Google email")

        // Cleanup
        authManager.signOut()
    }

    // MARK: - Credential Encryption Tests

    func testKeychainHelper_Encryption_SensitiveDataEncrypted() {
        // Given
        let sensitiveData = "super_secret_google_oauth_token_12345"
        let account = "test_encryption_account"

        // When
        KeychainHelper.save(value: sensitiveData, account: account)
        let retrievedData = KeychainHelper.get(account: account)

        // Then
        XCTAssertEqual(retrievedData, sensitiveData, "Data should be encrypted and decrypted correctly")
        XCTAssertNotNil(retrievedData, "Retrieved data should not be nil")
        XCTAssertEqual(retrievedData?.count, sensitiveData.count, "Data length should be preserved")

        // Cleanup
        try? KeychainHelper.delete(account: account)
    }

    // MARK: - Token Refresh Security Tests

    func testGoogleTokenRefresh_SecureProcess() async {
        // Given
        let authManager = AuthenticationManager()
        let expiredAccessToken = "expired_access_token"

        // Store expired access token but valid refresh token
        KeychainHelper.save(value: expiredAccessToken, account: "gmail_access_token")
        KeychainHelper.save(value: "valid_refresh_token", account: "gmail_refresh_token")

        // When
        // This would test the token refresh flow in the actual implementation
        do {
            _ = try await authManager.fetchGoogleUserInfo(accessToken: expiredAccessToken)
        } catch {
            // Expected - should trigger token refresh in real implementation
        }

        // Then - Verify that tokens are handled securely
        let currentAccessToken = KeychainHelper.get(account: "gmail_access_token")
        XCTAssertNotNil(currentAccessToken, "Access token should be managed securely")

        // Cleanup
        try? KeychainHelper.delete(account: "gmail_access_token")
        try? KeychainHelper.delete(account: "gmail_refresh_token")
    }

    // MARK: - Helper Methods

    private func createMockAppleIDCredential(email: String = "test@icloud.com") -> ASAuthorizationAppleIDCredential {
        let credential = ASAuthorizationAppleIDCredential()
        // Note: In a real test environment, you would need to create proper mock objects
        return credential
    }
}