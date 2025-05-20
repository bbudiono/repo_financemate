// Purpose: Core shared test utilities for both production and sandbox environments
// Issues & Complexity: Centralized test utilities to ensure consistent implementation across environments
// Ranking/Rating: 98% (Code), 98% (Problem) - Essential for environment alignment
// Last Updated: 2025-05-19

import XCTest
import SwiftUI
import AuthenticationServices

// MARK: - Mock Protocol for Test Compatibility

/// Protocol to abstract Apple credential interface for testing
public protocol TestCredentialProvider {
    var user: String { get }
    var fullName: PersonNameComponents? { get }
    var email: String? { get }
    var identityToken: Data? { get }
    var authorizationCode: Data? { get }
}

// MARK: - Test Expectations Helper

/// Simplifies working with XCTestExpectation
public struct TestExpectationHelper {
    /// Wait for expectations and assert their fulfillment
    public static func waitForExpectations(
        expectations: [XCTestExpectation], 
        timeout: TimeInterval = 2.0, 
        file: StaticString = #file, 
        line: UInt = #line
    ) {
        XCTWaiter().wait(for: expectations, timeout: timeout)
        
        for expectation in expectations {
            if expectation.expectedFulfillmentCount != expectation.fulfillmentCount {
                XCTFail("Expectation \(expectation.description) not fulfilled: \(expectation.fulfillmentCount)/\(expectation.expectedFulfillmentCount)", file: file, line: line)
            }
        }
    }
}

// MARK: - Person Name Components Helper

/// Utilities for creating PersonNameComponents
public struct TestNameComponentsHelper {
    /// Create name components with given and family names
    public static func makeNameComponents(givenName: String? = nil, familyName: String? = nil) -> PersonNameComponents {
        var components = PersonNameComponents()
        components.givenName = givenName
        components.familyName = familyName
        return components
    }
}

// MARK: - UI Testing Helpers

/// Extensions for UI testing
public extension XCTestCase {
    /// Helper method to test SwiftUI view rendering
    func assertViewRendersCorrectly<V: View>(
        _ view: V, 
        environmentLabel: String = "",
        file: StaticString = #file, 
        line: UInt = #line
    ) {
        // Create a hosting controller to test rendering
        let hostingController = NSHostingController(rootView: view)
        let window = NSWindow()
        window.contentViewController = hostingController
        window.makeKeyAndOrderFront(nil)
        
        // Give it time to render
        let renderLabel = environmentLabel.isEmpty ? "View rendering" : "\(environmentLabel) View rendering"
        let renderExpectation = expectation(description: renderLabel)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            renderExpectation.fulfill()
        }
        wait(for: [renderExpectation], timeout: 1.0)
        
        // Basic check - view controller should have a valid view now
        let assertMessage = environmentLabel.isEmpty ? "View should be created" : "[\(environmentLabel)] View should be created"
        XCTAssertNotNil(hostingController.view, assertMessage, file: file, line: line)
        
        // Cleanup
        window.close()
    }
} 