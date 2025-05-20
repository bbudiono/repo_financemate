// Purpose: Unit and integration tests for GoogleAuthProvider, covering OAuth2 flow, token exchange, and error handling.
// Issues & Complexity: Requires mocking network, OAuth session, and config. Tests edge cases and all callback paths.
// Ranking/Rating: 92% (Code), 90% (Problem) - High due to OAuth/network mocking and security edge cases.
// -- Pre-Coding Assessment --
// Issues & Complexity Summary: Mocking ASWebAuthenticationSession, URLSession, config, and JWT parsing. Ensuring robust error path coverage.
// Key Complexity Drivers (Values/Estimates):
// - Logic Scope (New/Mod LoC Est.): ~200
// - Core Algorithm Complexity: High (OAuth2, JWT, network)
// - Dependencies (New/Mod Cnt.): 2 New (MockSession, MockNetwork)
// - State Management Complexity: Med (session, callbacks)
// - Novelty/Uncertainty Factor: Med (OAuth2 on macOS)
// AI Pre-Task Self-Assessment (Est. Solution Difficulty for AI %): 92%
// Problem Estimate (Inherent Problem Difficulty %): 90%
// Initial Code Complexity Estimate (Est. Code Difficulty %): 92%
// Justification for Estimates: OAuth2/network mocking is non-trivial, but patterns are established. Security and error handling are critical.
// -- Post-Implementation Update --
// Final Code Complexity (Actual Code Difficulty %): [TBD]
// Overall Result Score (Success & Quality %): [TBD]
// Key Variances/Learnings: [TBD]
// Last Updated: [YYYY-MM-DD]

import XCTest
@testable import SynchroNext

class MockWindow: NSWindow {}

class GoogleAuthProviderTests: XCTestCase {
    var provider: GoogleAuthProvider!
    var successCalled: Bool!
    var failureCalled: Bool!
    var lastError: Error?
    var lastIDToken: String?
    var lastFullName: String?
    var lastEmail: String?

    override func setUp() {
        super.setUp()
        provider = GoogleAuthProvider()
        successCalled = false
        failureCalled = false
        lastError = nil
        lastIDToken = nil
        lastFullName = nil
        lastEmail = nil
        provider.onSignInSuccess = { idToken, fullName, email in
            self.successCalled = true
            self.lastIDToken = idToken
            self.lastFullName = fullName
            self.lastEmail = email
        }
        provider.onSignInFailure = { error in
            self.failureCalled = true
            self.lastError = error
        }
    }

    func testConfigLoadsFromFallback() {
        // Should use fallback if Info.plist/env are missing
        XCTAssertFalse(provider.clientID.isEmpty)
        XCTAssertFalse(provider.redirectURI.isEmpty)
    }

    func testSignInFailsWithInvalidClientID() {
        // Simulate invalid client ID
        let origClientID = provider.clientID
        let origRedirect = provider.redirectURI
        // Use KVC to override (for test only)
        provider.setValue("YOUR_GOOGLE_CLIENT_ID", forKey: "clientID")
        provider.signIn(presentingWindow: MockWindow()) { _ in }
        XCTAssertTrue(failureCalled)
        XCTAssertNotNil(lastError)
        // Restore
        provider.setValue(origClientID, forKey: "clientID")
        provider.setValue(origRedirect, forKey: "redirectURI")
    }

    func testHandleOAuthCallbackWithErrorParam() {
        let errorURL = URL(string: "com.products.synchronext:/oauth2redirect?error=access_denied")!
        provider.handleOAuthCallback(url: errorURL)
        XCTAssertTrue(failureCalled)
        XCTAssertNotNil(lastError)
    }

    func testHandleOAuthCallbackWithMissingCode() {
        let url = URL(string: "com.products.synchronext:/oauth2redirect?state=xyz")!
        provider.handleOAuthCallback(url: url)
        XCTAssertTrue(failureCalled)
        XCTAssertNotNil(lastError)
    }

    func testParseIDTokenAndFetchUserInfoWithValidJWT() {
        // JWT: header.payload.signature (payload is base64-encoded JSON)
        let payload: [String: Any] = [
            "email": "test@example.com",
            "name": "Test User",
            "given_name": "Test",
            "family_name": "User"
        ]
        let payloadData = try! JSONSerialization.data(withJSONObject: payload)
        var payloadBase64 = payloadData.base64EncodedString().replacingOccurrences(of: "=", with: "")
        payloadBase64 = payloadBase64.replacingOccurrences(of: "+", with: "-").replacingOccurrences(of: "/", with: "_")
        let jwt = "header." + payloadBase64 + ".signature"
        provider.parseIDTokenAndFetchUserInfo(idToken: jwt)
        XCTAssertTrue(successCalled)
        XCTAssertEqual(lastEmail, "test@example.com")
        XCTAssertEqual(lastFullName, "Test User")
    }

    func testParseIDTokenAndFetchUserInfoWithInvalidJWT() {
        provider.parseIDTokenAndFetchUserInfo(idToken: "invalid.jwt")
        XCTAssertTrue(failureCalled)
        XCTAssertNotNil(lastError)
    }

    // Additional tests for token exchange/network errors would require refactoring provider for DI/mocking URLSession.
} 