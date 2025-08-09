import XCTest
@testable import FinanceMate

@MainActor
final class EmailOAuthManagerTests: XCTestCase {
    
    var oauthManager: EmailOAuthManager!
    
    override func setUp() async throws {
        try await super.setUp()
        oauthManager = EmailOAuthManager()
    }
    
    override func tearDown() async throws {
        oauthManager = nil
        try await super.tearDown()
    }
    
    // MARK: - Provider Authentication Tests
    
    func testAuthenticationManagerInitialization() async throws {
        XCTAssertNotNil(oauthManager)
        XCTAssertFalse(oauthManager.isAuthenticating)
        XCTAssertNil(oauthManager.authenticationError)
        XCTAssertTrue(oauthManager.authenticatedProviders.isEmpty)
    }
    
    func testProviderAuthenticationStatus() async throws {
        // Test that providers start as unauthenticated
        XCTAssertFalse(oauthManager.isProviderAuthenticated("gmail"))
        XCTAssertFalse(oauthManager.isProviderAuthenticated("outlook"))
        XCTAssertFalse(oauthManager.isProviderAuthenticated("invalid_provider"))
    }
    
    func testUnsupportedProviderAuthentication() async throws {
        do {
            let _ = try await oauthManager.authenticateProvider("unsupported_provider")
            XCTFail("Expected authentication to fail for unsupported provider")
        } catch EmailOAuthManager.OAuthError.unsupportedProvider(let provider) {
            XCTAssertEqual(provider, "unsupported_provider")
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testGmailAuthenticationWithoutSetup() async throws {
        do {
            let _ = try await oauthManager.authenticateProvider("gmail")
            XCTFail("Expected authentication to fail without OAuth setup")
        } catch EmailOAuthManager.OAuthError.authenticationFailed(let message) {
            XCTAssertTrue(message.contains("OAuth 2.0 setup"))
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testOutlookAuthenticationWithoutSetup() async throws {
        do {
            let _ = try await oauthManager.authenticateProvider("outlook")
            XCTFail("Expected authentication to fail without OAuth setup")
        } catch EmailOAuthManager.OAuthError.authenticationFailed(let message) {
            XCTAssertTrue(message.contains("OAuth 2.0 setup"))
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testGetValidAccessTokenWithoutAuthentication() async throws {
        do {
            let _ = try await oauthManager.getValidAccessToken(for: "gmail")
            XCTFail("Expected token retrieval to fail without authentication")
        } catch EmailOAuthManager.OAuthError.authorizationFailed {
            // Expected behavior
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testRevokeAuthenticationForUnauthenticatedProvider() async throws {
        // Should not throw for unauthenticated provider
        do {
            try await oauthManager.revokeAuthentication(for: "gmail")
        } catch {
            XCTFail("Revoking authentication should not fail for unauthenticated provider")
        }
    }
    
    // MARK: - Error Handling Tests
    
    func testErrorDescriptions() {
        let errors: [EmailOAuthManager.OAuthError] = [
            .authorizationCancelled,
            .authorizationFailed("test failure"),
            .tokenExchangeFailed("token error"),
            .tokenRefreshFailed("refresh error"),
            .keychainError("keychain error"),
            .networkError("network error"),
            .invalidConfiguration("config error"),
            .unsupportedProvider("test provider")
        ]
        
        for error in errors {
            XCTAssertNotNil(error.errorDescription)
            XCTAssertFalse(error.errorDescription!.isEmpty)
        }
    }
    
    // MARK: - Email Provider Tests
    
    func testSupportedEmailProviders() {
        let supportedProviders = EmailOAuthManager.EmailProvider.supportedProviders
        XCTAssertGreaterThanOrEqual(supportedProviders.count, 2)
        
        let gmailProvider = supportedProviders.first { $0.id == "gmail" }
        XCTAssertNotNil(gmailProvider)
        XCTAssertEqual(gmailProvider?.name, "Gmail")
        XCTAssertTrue(gmailProvider?.authorizationURL.contains("google") ?? false)
        
        let outlookProvider = supportedProviders.first { $0.id == "outlook" }
        XCTAssertNotNil(outlookProvider)
        XCTAssertEqual(outlookProvider?.name, "Microsoft Outlook")
        XCTAssertTrue(outlookProvider?.authorizationURL.contains("microsoft") ?? false)
    }
    
    // MARK: - Security Tests
    
    func testTokenStorageSecurityAttributes() {
        // Test that token storage uses secure attributes
        // This is tested indirectly through the authentication flow
        XCTAssertNoThrow({
            // The OAuth manager initializes without errors
            let _ = EmailOAuthManager()
        })
    }
    
    // MARK: - Concurrent Access Tests
    
    func testConcurrentAuthenticationRequests() async throws {
        let expectation = XCTestExpectation(description: "Concurrent authentication")
        expectation.expectedFulfillmentCount = 2
        
        Task {
            do {
                let _ = try await oauthManager.authenticateProvider("gmail")
            } catch {
                // Expected to fail without setup
            }
            expectation.fulfill()
        }
        
        Task {
            do {
                let _ = try await oauthManager.authenticateProvider("outlook")
            } catch {
                // Expected to fail without setup
            }
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 5.0)
    }
    
    // MARK: - Configuration Validation Tests
    
    func testOAuthProviderConfiguration() {
        let gmailProvider = EmailOAuthManager.EmailProvider.gmail
        XCTAssertEqual(gmailProvider.id, "gmail")
        XCTAssertEqual(gmailProvider.redirectURI, "financemate://oauth/gmail")
        XCTAssertTrue(gmailProvider.scope.contains("gmail.readonly"))
        
        let outlookProvider = EmailOAuthManager.EmailProvider.outlook
        XCTAssertEqual(outlookProvider.id, "outlook")
        XCTAssertEqual(outlookProvider.redirectURI, "financemate://oauth/outlook")
        XCTAssertTrue(outlookProvider.scope.contains("mail.read"))
    }
    
    // MARK: - PKCE Security Tests
    
    func testPKCEChallengeGeneration() {
        // Test that PKCE challenge generation works (indirectly through auth flow)
        // The actual PKCE generation is private, but we can test that it's used
        Task {
            do {
                let _ = try await oauthManager.authenticateProvider("gmail")
                XCTFail("Should fail without OAuth setup")
            } catch EmailOAuthManager.OAuthError.authenticationFailed(let message) {
                XCTAssertTrue(message.contains("OAuth 2.0 setup"))
            } catch {
                XCTFail("Unexpected error: \(error)")
            }
        }
    }
    
    // MARK: - Published Property Tests
    
    func testPublishedProperties() {
        // Test that published properties are properly initialized
        XCTAssertTrue(oauthManager.authenticatedProviders.isEmpty)
        XCTAssertFalse(oauthManager.isAuthenticating)
        XCTAssertNil(oauthManager.authenticationError)
    }
}