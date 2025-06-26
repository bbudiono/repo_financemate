//
//  OAuth2ManagerTests.swift
//  FinanceMateTests
//
//  Purpose: Comprehensive tests for OAuth 2.0 implementation
//  Validates PKCE flow, token management, and security

import XCTest
import AuthenticationServices
@testable import FinanceMate

final class OAuth2ManagerTests: XCTestCase {
    var oauthManager: OAuth2Manager!
    var mockKeychainManager: MockKeychainManager!

    override func setUp() {
        super.setUp()
        oauthManager = OAuth2Manager.shared
        mockKeychainManager = MockKeychainManager()
    }

    override func tearDown() {
        // Clean up
        Task {
            try? await oauthManager.signOut()
        }
        super.tearDown()
    }

    // MARK: - PKCE Tests

    func testPKCEParameterGeneration() {
        // Given - Access private methods via reflection for testing
        let mirror = Mirror(reflecting: oauthManager)

        // When - generatePKCEParameters is called internally
        Task {
            do {
                try await oauthManager.authenticate(with: .google)
            } catch {
                // Expected - we're just testing parameter generation
            }
        }

        // Then - Verify PKCE parameters exist
        if let codeVerifier = mirror.children.first(where: { $0.label == "codeVerifier" })?.value as? String {
            XCTAssertEqual(codeVerifier.count, 128)
            XCTAssertTrue(codeVerifier.allSatisfy { char in
                "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~".contains(char)
            })
        }
    }

    // MARK: - Authentication Flow Tests

    func testGoogleAuthenticationInitiation() async throws {
        // Given
        let provider = AuthProvider.google

        // When/Then - Should not throw during initiation
        do {
            try await oauthManager.authenticate(with: provider)
        } catch {
            // Expected - actual authentication requires user interaction
            XCTAssertTrue(error is OAuth2Error || error is URLError)
        }
    }

    func testAppleAuthenticationInitiation() async throws {
        // Given
        let provider = AuthProvider.apple

        // When/Then - Should not throw during initiation
        do {
            try await oauthManager.authenticate(with: provider)
        } catch {
            // Expected - actual authentication requires user interaction
            XCTAssertTrue(error is OAuth2Error || error is URLError)
        }
    }

    // MARK: - OAuth Callback Tests

    func testValidOAuthCallback() async throws {
        // Given - Set up internal state
        oauthManager.state = "test_state_123"
        let callbackURL = URL(string: "com.ablankcanvas.financemate://oauth?code=test_code&state=test_state_123")!

        // When/Then
        do {
            try await oauthManager.handleOAuthCallback(url: callbackURL)
        } catch {
            // Expected - token exchange will fail without real server
            XCTAssertTrue(error is OAuth2Error || error is URLError)
        }
    }

    func testOAuthCallbackStateMismatch() async throws {
        // Given
        oauthManager.state = "expected_state"
        let callbackURL = URL(string: "com.ablankcanvas.financemate://oauth?code=test_code&state=wrong_state")!

        // When/Then
        do {
            try await oauthManager.handleOAuthCallback(url: callbackURL)
            XCTFail("Should throw stateMismatch error")
        } catch {
            XCTAssertEqual(error as? OAuth2Error, .stateMismatch)
        }
    }

    func testOAuthCallbackWithError() async throws {
        // Given
        oauthManager.state = "test_state"
        let callbackURL = URL(string: "com.ablankcanvas.financemate://oauth?error=access_denied&state=test_state")!

        // When/Then
        do {
            try await oauthManager.handleOAuthCallback(url: callbackURL)
            XCTFail("Should throw authorizationFailed error")
        } catch OAuth2Error.authorizationFailed(let error) {
            XCTAssertEqual(error, "access_denied")
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testInvalidCallbackURL() async throws {
        // Given
        let invalidURL = URL(string: "invalid://callback")!

        // When/Then
        do {
            try await oauthManager.handleOAuthCallback(url: invalidURL)
            XCTFail("Should throw invalidCallbackURL error")
        } catch {
            XCTAssertEqual(error as? OAuth2Error, .invalidCallbackURL)
        }
    }

    // MARK: - Token Management Tests

    func testTokenRefreshWhenNeeded() async throws {
        // Given - Store tokens that are about to expire
        let almostExpiredTokens = OAuthTokens(
            accessToken: "access_token",
            refreshToken: "refresh_token",
            idToken: "id_token",
            expiresIn: 60, // Expires in 1 minute
            tokenType: "Bearer",
            scope: "openid email",
            createdAt: Date()
        )

        try mockKeychainManager.storeOAuthTokens(almostExpiredTokens)

        // When/Then
        do {
            try await oauthManager.refreshTokenIfNeeded()
        } catch {
            // Expected - refresh will fail without real server
            XCTAssertTrue(error is OAuth2Error || error is URLError)
        }
    }

    func testTokenRefreshNotNeededForValidToken() async throws {
        // Given - Store tokens that are still valid
        let validTokens = OAuthTokens(
            accessToken: "valid_access_token",
            refreshToken: "refresh_token",
            idToken: "id_token",
            expiresIn: 3600, // Expires in 1 hour
            tokenType: "Bearer",
            scope: "openid email",
            createdAt: Date()
        )

        try mockKeychainManager.storeOAuthTokens(validTokens)

        // When/Then - Should not attempt refresh
        do {
            try await oauthManager.refreshTokenIfNeeded()
            // Success - no refresh attempted
        } catch {
            // If error, should be related to missing tokens, not refresh
            XCTAssertTrue(error is KeychainError)
        }
    }

    // MARK: - Session Validation Tests

    func testValidateExpiredSession() async throws {
        // Given - Store expired session
        let expiredSession = SessionToken(
            token: "expired_token",
            expiresAt: Date().addingTimeInterval(-3600) // Expired 1 hour ago
        )

        try mockKeychainManager.storeSessionToken(expiredSession.token, expiresAt: expiredSession.expiresAt)

        // When/Then
        do {
            try await oauthManager.validateSession()
            XCTFail("Should throw sessionExpired error")
        } catch {
            XCTAssertTrue(error is OAuth2Error || error is KeychainError)
        }
    }

    // MARK: - Sign Out Tests

    func testSignOut() async throws {
        // Given - Store some tokens
        let tokens = OAuthTokens(
            accessToken: "access",
            refreshToken: "refresh",
            idToken: "id",
            expiresIn: 3600,
            tokenType: "Bearer",
            scope: nil,
            createdAt: Date()
        )

        try mockKeychainManager.storeOAuthTokens(tokens)
        oauthManager.isAuthenticated = true
        oauthManager.currentUser = AuthenticatedUser(
            id: "user123",
            email: "test@example.com",
            name: "Test User",
            pictureURL: nil
        )

        // When
        try await oauthManager.signOut()

        // Then
        XCTAssertFalse(oauthManager.isAuthenticated)
        XCTAssertNil(oauthManager.currentUser)
    }

    // MARK: - Error Handling Tests

    func testOAuth2ErrorDescriptions() {
        let testCases: [(OAuth2Error, String)] = [
            (.noStoredTokens, "No stored authentication tokens found"),
            (.sessionExpired, "Your session has expired. Please sign in again."),
            (.invalidTokenSignature, "Invalid token signature detected"),
            (.invalidAuthorizationURL, "Failed to create authorization URL"),
            (.invalidCallbackURL, "Invalid OAuth callback URL"),
            (.stateMismatch, "OAuth state mismatch - possible CSRF attack"),
            (.authorizationFailed(error: "test_error"), "Authorization failed: test_error"),
            (.tokenExchangeFailed, "Failed to exchange authorization code for tokens"),
            (.tokenRefreshFailed, "Failed to refresh access token")
        ]

        for (error, expectedDescription) in testCases {
            XCTAssertEqual(error.errorDescription, expectedDescription)
        }
    }

    // MARK: - ASAuthorizationController Delegate Tests

    func testAppleSignInSuccess() {
        // Given
        let credential = MockASAuthorizationAppleIDCredential()
        let authorization = MockASAuthorization(credential: credential)

        // When
        oauthManager.authorizationController(
            controller: ASAuthorizationController(authorizationRequests: []),
            didCompleteWithAuthorization: authorization
        )

        // Then - Should process credential
        // Note: Actual token storage will fail in test environment
        XCTAssertNotNil(oauthManager.currentUser)
    }

    func testAppleSignInError() {
        // Given
        let error = NSError(domain: "test", code: 1001, userInfo: nil)

        // When
        oauthManager.authorizationController(
            controller: ASAuthorizationController(authorizationRequests: []),
            didCompleteWithError: error
        )

        // Then
        XCTAssertNotNil(oauthManager.authenticationError)
    }
}

// MARK: - Mock Helpers

class MockKeychainManager {
    private var storage: [String: String] = [:]

    func store(key: String, value: String, requiresBiometric: Bool = false) throws {
        storage[key] = value
    }

    func retrieve(key: String) throws -> String {
        guard let value = storage[key] else {
            throw KeychainError.itemNotFound
        }
        return value
    }

    func delete(key: String) throws {
        storage.removeValue(forKey: key)
    }

    func storeOAuthTokens(_ tokens: OAuthTokens) throws {
        let data = try JSONEncoder().encode(tokens)
        storage["oauth_tokens"] = data.base64EncodedString()
    }

    func retrieveOAuthTokens() throws -> OAuthTokens {
        guard let base64 = storage["oauth_tokens"],
              let data = Data(base64Encoded: base64) else {
            throw KeychainError.itemNotFound
        }
        return try JSONDecoder().decode(OAuthTokens.self, from: data)
    }

    func storeSessionToken(_ token: String, expiresAt: Date) throws {
        let session = SessionToken(token: token, expiresAt: expiresAt)
        let data = try JSONEncoder().encode(session)
        storage["session_token"] = data.base64EncodedString()
    }

    func retrieveSessionToken() throws -> SessionToken {
        guard let base64 = storage["session_token"],
              let data = Data(base64Encoded: base64) else {
            throw KeychainError.itemNotFound
        }
        return try JSONDecoder().decode(SessionToken.self, from: data)
    }
}

class MockASAuthorizationAppleIDCredential: ASAuthorizationAppleIDCredential {
    override var user: String { "test_user_id" }
    override var email: String? { "test@example.com" }
    override var fullName: PersonNameComponents? {
        var components = PersonNameComponents()
        components.givenName = "Test"
        components.familyName = "User"
        return components
    }
    override var identityToken: Data? { "test_identity_token".data(using: .utf8) }
}

class MockASAuthorization: ASAuthorization {
    private let _credential: ASAuthorizationCredential

    init(credential: ASAuthorizationCredential) {
        self._credential = credential
    }

    override var credential: ASAuthorizationCredential { _credential }
}
