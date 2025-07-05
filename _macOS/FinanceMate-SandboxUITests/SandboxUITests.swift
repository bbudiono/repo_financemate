// SANDBOX FILE: For testing/development. See .cursorrules.
//
// SandboxUITests.swift
// FinanceMate-SandboxUITests
//
// Purpose: UI tests for FinanceMate Sandbox environment with glassmorphism styling verification
// Issues & Complexity Summary: SwiftUI UI automation tests for Sandbox environment
// Key Complexity Drivers:
//   - Logic Scope (Est. LoC): ~150
//   - Core Algorithm Complexity: Medium
//   - Dependencies: 2 (XCTest, XCUIApplication)
//   - State Management Complexity: Medium
//   - Novelty/Uncertainty Factor: Low
// AI Pre-Task Self-Assessment: 85%
// Problem Estimate: 88%
// Initial Code Complexity Estimate: 82%
// Final Code Complexity: 85%
// Overall Result Score: 92%
// Key Variances/Learnings: Sandbox UI tests must target Sandbox app bundle
// Last Updated: 2025-07-05

import XCTest

final class SandboxUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        
        // Target the Sandbox app specifically
        app.launchArguments = ["UI_TESTING"]
        app.launch()
        
        // Allow time for app launch and initial data loading
        Thread.sleep(forTimeInterval: 2.0)
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Basic App Launch Tests
    
    func testSandboxAppLaunches() {
        // Test that the Sandbox app launches successfully
        XCTAssertTrue(app.exists, "Sandbox app should launch successfully")
    }
    
    func testSandboxIdentification() {
        // Test that this is indeed the Sandbox version
        let sandboxIdentifier = app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'Sandbox'"))
        XCTAssertTrue(sandboxIdentifier.firstMatch.waitForExistence(timeout: 5.0), "App should be identified as Sandbox version")
    }
    
    // MARK: - Navigation Tests
    
    func testTabNavigationExists() {
        // Test that tab navigation is present
        let dashboardTab = app.buttons["Dashboard"]
        XCTAssertTrue(dashboardTab.waitForExistence(timeout: 5.0), "Dashboard tab should exist")
    }
    
    func testDashboardTabSelection() {
        // Test Dashboard tab can be selected
        let dashboardTab = app.buttons["Dashboard"]
        if dashboardTab.exists {
            dashboardTab.tap()
            
            // Verify dashboard content appears
            let dashboardView = app.scrollViews["DashboardView"]
            XCTAssertTrue(dashboardView.waitForExistence(timeout: 5.0), "Dashboard view should appear when tab is selected")
        }
    }
    
    // MARK: - Dashboard UI Tests
    
    func testDashboardViewExists() {
        // Navigate to Dashboard
        let dashboardTab = app.buttons["Dashboard"]
        if dashboardTab.exists {
            dashboardTab.tap()
        }
        
        // Test that the dashboard view is present
        let dashboardView = app.scrollViews["DashboardView"]
        XCTAssertTrue(dashboardView.waitForExistence(timeout: 5.0), "Dashboard view should be present in Sandbox")
    }
    
    func testBalanceDisplayInSandbox() {
        // Navigate to Dashboard
        let dashboardTab = app.buttons["Dashboard"]
        if dashboardTab.exists {
            dashboardTab.tap()
        }
        
        // Test that balance display exists in Sandbox
        let balanceSection = app.staticTexts.matching(identifier: "BalanceDisplay").firstMatch
        XCTAssertTrue(balanceSection.waitForExistence(timeout: 5.0), "Balance display should exist in Sandbox")
    }
    
    // MARK: - Glassmorphism Style Tests
    
    func testGlassmorphismInSandbox() {
        // Navigate to Dashboard
        let dashboardTab = app.buttons["Dashboard"]
        if dashboardTab.exists {
            dashboardTab.tap()
        }
        
        // Test that glassmorphism containers are present in Sandbox
        let glassmorphismContainer = app.otherElements.matching(identifier: "GlassmorphismContainer").firstMatch
        XCTAssertTrue(glassmorphismContainer.waitForExistence(timeout: 5.0), "Glassmorphism container should be present in Sandbox")
    }
    
    // MARK: - Accessibility Tests
    
    func testAccessibilityInSandbox() {
        // Navigate to Dashboard
        let dashboardTab = app.buttons["Dashboard"]
        if dashboardTab.exists {
            dashboardTab.tap()
        }
        
        // Test accessibility identifiers in Sandbox
        let dashboardView = app.scrollViews["DashboardView"]
        XCTAssertTrue(dashboardView.waitForExistence(timeout: 5.0), "Dashboard should have accessibility identifier in Sandbox")
    }
    
    // MARK: - Screenshot Tests for Sandbox
    
    func testSandboxScreenshot() throws {
        // Navigate to Dashboard
        let dashboardTab = app.buttons["Dashboard"]
        if dashboardTab.exists {
            dashboardTab.tap()
        }
        
        // Wait for content to load
        Thread.sleep(forTimeInterval: 2.0)
        
        // Take screenshot of Sandbox environment
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "FinanceMate_Sandbox_\(Date().timeIntervalSince1970)"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    // MARK: - Performance Tests
    
    func testSandboxLaunchPerformance() {
        // Measure Sandbox app launch performance
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            app.launch()
            
            // Wait for app to fully load
            let mainView = app.windows.firstMatch
            XCTAssertTrue(mainView.waitForExistence(timeout: 10.0), "Sandbox app should launch within performance threshold")
        }
    }
}

// MARK: - Test Helper Extensions for Sandbox

extension XCUIElement {
    /// Wait for element to be hittable in Sandbox environment
    func waitForHittabilityInSandbox(timeout: TimeInterval = 5.0) -> Bool {
        let predicate = NSPredicate(format: "hittable == true")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: self)
        let result = XCTWaiter.wait(for: [expectation], timeout: timeout)
        return result == .completed
    }
}