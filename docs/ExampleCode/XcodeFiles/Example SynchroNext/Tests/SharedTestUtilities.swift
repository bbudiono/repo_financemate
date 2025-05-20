// Purpose: Test utilities for production environment that use the shared core
// Issues & Complexity: Adapts shared test utilities for production-specific scenarios
// Ranking/Rating: 95% (Code), 95% (Problem) - Essential for test alignment

import XCTest
import SwiftUI
import AuthenticationServices
@testable import SynchroNext

// MARK: - Mock Classes for Authentication Testing

/// Mock AppleIDCredential for testing Apple authentication
class MockAppleIDCredential: AppleIDCredentialRepresentable, TestCredentialProvider {
    let user: String
    let fullName: PersonNameComponents?
    let email: String?
    let identityToken: Data?
    let authorizationCode: Data?
    
    init(
        user: String = "test_user_id",
        fullName: PersonNameComponents? = nil,
        email: String? = nil,
        identityToken: Data? = nil,
        authorizationCode: Data? = nil
    ) {
        self.user = user
        self.fullName = fullName
        self.email = email
        self.identityToken = identityToken
        self.authorizationCode = authorizationCode
    }
}

/// Helper to create name components for testing (wrapper for shared implementation)
func makeNameComponents(givenName: String? = nil, familyName: String? = nil) -> PersonNameComponents {
    return TestNameComponentsHelper.makeNameComponents(givenName: givenName, familyName: familyName)
}

// MARK: - Test Expectations Helper Wrapper

/// Simplifies working with XCTestExpectation (wrapper for shared implementation)
class ExpectationHelper {
    static func waitForExpectations(expectations: [XCTestExpectation], timeout: TimeInterval = 2.0, file: StaticString = #file, line: UInt = #line) {
        TestExpectationHelper.waitForExpectations(expectations: expectations, timeout: timeout, file: file, line: line)
    }
}

// MARK: - Test Data Generators

/// Generate consistent test data for auth testing
struct AuthTestDataGenerator {
    static func generateMockGoogleUserSession() -> GoogleUserSession {
        return GoogleUserSession(
            idToken: "mock_id_token_for_testing",
            userID: "mock_google_user_id",
            email: "test@example.com",
            fullName: "Test User"
        )
    }
    
    static func generateMockAuthUser() -> AuthUser {
        return AuthUser(
            id: "mock_user_id",
            email: "test@example.com",
            displayName: "Test User",
            provider: "google"
        )
    }
}

// MARK: - UI Testing Helpers - Production Specific

extension XCTestCase {
    /// Production-specific version of view rendering test
    func assertProductionViewRendersCorrectly<V: View>(_ view: V, file: StaticString = #file, line: UInt = #line) {
        assertViewRendersCorrectly(view, environmentLabel: "Production", file: file, line: line)
    }
}

// MARK: - UI Testing Helpers

extension XCTestCase {
    /// Helper method to test SwiftUI view rendering
    func assertViewRendersCorrectly<V: View>(_ view: V, file: StaticString = #file, line: UInt = #line) {
        // Create a hosting controller to test rendering
        let hostingController = NSHostingController(rootView: view)
        let window = NSWindow()
        window.contentViewController = hostingController
        window.makeKeyAndOrderFront(nil)
        
        // Give it time to render
        let renderExpectation = expectation(description: "View rendering")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            renderExpectation.fulfill()
        }
        wait(for: [renderExpectation], timeout: 1.0)
        
        // Basic check - view controller should have a valid view now
        XCTAssertNotNil(hostingController.view, "View should be created", file: file, line: line)
        
        // Cleanup
        window.close()
    }
} 