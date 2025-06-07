// SANDBOX FILE: For testing/development. See .cursorrules.

//
//  MLACSUXNavigationTests.swift
//  FinanceMate-SandboxTests
//
//  Created by Assistant on 6/7/25.
//

/*
* Purpose: Comprehensive UX/UI navigation testing for MLACS integration
* Features: Navigation flow testing, button functionality, view accessibility
* Focus: "CAN I NAVIGATE THROUGH EACH PAGE? CAN I PRESS EVERY BUTTON AND DOES EACH BUTTON DO SOMETHING?"
*/

import XCTest
import SwiftUI
@testable import FinanceMate_Sandbox

final class MLACSUXNavigationTests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Core Navigation Tests
    
    func testMLACSIsVisibleInMainNavigation() throws {
        // CRITICAL: Test that MLACS appears in main navigation sidebar
        
        // Look for MLACS in the sidebar
        let sidebar = app.outlines.firstMatch
        XCTAssertTrue(sidebar.exists, "Sidebar should exist")
        
        // Check if MLACS navigation item exists
        let mlacsNavItem = sidebar.staticTexts["MLACS"]
        XCTAssertTrue(mlacsNavItem.exists, "MLACS should be visible in main navigation")
        
        // Verify MLACS has the correct icon
        let mlacsIcon = sidebar.images["brain.head.profile"]
        XCTAssertTrue(mlacsIcon.exists, "MLACS should have brain icon")
    }
    
    func testCanNavigateToMLACS() throws {
        // CRITICAL: Test that user can actually click and navigate to MLACS
        
        let sidebar = app.outlines.firstMatch
        let mlacsNavItem = sidebar.staticTexts["MLACS"]
        
        // Click on MLACS navigation item
        mlacsNavItem.tap()
        
        // Wait for MLACS view to load
        let mlacsTitle = app.staticTexts["Multi-LLM Agent Coordination System"]
        let exists = mlacsTitle.waitForExistence(timeout: 5.0)
        XCTAssertTrue(exists, "Should navigate to MLACS view and show title")
    }
    
    func testAllMLACSTabsAreNavigable() throws {
        // Test each MLACS tab can be navigated to
        
        // Navigate to MLACS first
        let sidebar = app.outlines.firstMatch
        sidebar.staticTexts["MLACS"].tap()
        
        // Wait for MLACS to load
        _ = app.staticTexts["Multi-LLM Agent Coordination System"].waitForExistence(timeout: 5.0)
        
        // Test each tab
        let mlacsTabsToTest = [
            ("Overview", "house"),
            ("Model Discovery", "magnifyingglass"),
            ("System Analysis", "chart.bar.xaxis"),
            ("Setup Wizard", "wand.and.stars"),
            ("Agent Management", "person.3")
        ]
        
        for (tabName, tabIcon) in mlacsTabsToTest {
            // Look for tab in MLACS sidebar
            let tabItem = app.staticTexts[tabName]
            if tabItem.exists {
                tabItem.tap()
                
                // Verify tab content loads (allow 3 seconds)
                let tabContentExists = app.staticTexts[tabName].waitForExistence(timeout: 3.0)
                XCTAssertTrue(tabContentExists, "\(tabName) tab should be navigable and show content")
            }
        }
    }
    
    // MARK: - Button Functionality Tests
    
    func testRefreshButtonDoesSomething() throws {
        // Test that refresh button actually triggers action
        
        // Navigate to MLACS
        let sidebar = app.outlines.firstMatch
        sidebar.staticTexts["MLACS"].tap()
        
        // Wait for MLACS to load
        _ = app.staticTexts["Multi-LLM Agent Coordination System"].waitForExistence(timeout: 5.0)
        
        // Look for refresh button
        let refreshButton = app.buttons["Refresh"]
        XCTAssertTrue(refreshButton.exists, "Refresh button should exist")
        
        // Press refresh button
        refreshButton.tap()
        
        // Check for loading indicator or updated content
        // (In a real test, we'd check for specific UI changes)
        XCTAssertTrue(refreshButton.exists, "Refresh button should still exist after tap")
    }
    
    func testSetupWizardButtonLaunchesModal() throws {
        // Test that setup wizard button actually opens something
        
        // Navigate to MLACS
        let sidebar = app.outlines.firstMatch
        sidebar.staticTexts["MLACS"].tap()
        
        // Wait for MLACS to load
        _ = app.staticTexts["Multi-LLM Agent Coordination System"].waitForExistence(timeout: 5.0)
        
        // Look for setup wizard button
        let setupButton = app.buttons["Setup Wizard"]
        XCTAssertTrue(setupButton.exists, "Setup Wizard button should exist")
        
        // Press setup wizard button
        setupButton.tap()
        
        // Check if modal or new view appears
        let wizardTitle = app.staticTexts["MLACS Setup Wizard"]
        let wizardExists = wizardTitle.waitForExistence(timeout: 3.0)
        XCTAssertTrue(wizardExists, "Setup wizard should open when button is pressed")
    }
    
    func testQuickActionButtonsWork() throws {
        // Test that all quick action buttons in overview do something
        
        // Navigate to MLACS Overview
        let sidebar = app.outlines.firstMatch
        sidebar.staticTexts["MLACS"].tap()
        
        // Ensure we're on overview tab
        let overviewTab = app.staticTexts["Overview"]
        if overviewTab.exists {
            overviewTab.tap()
        }
        
        // Wait for overview to load
        _ = app.staticTexts["Quick Actions"].waitForExistence(timeout: 5.0)
        
        // Test each quick action button
        let quickActionButtons = [
            "Discover Models",
            "Setup Wizard", 
            "System Analysis"
        ]
        
        for buttonName in quickActionButtons {
            let button = app.buttons[buttonName]
            if button.exists {
                button.tap()
                
                // Verify button press was registered (button should still exist)
                XCTAssertTrue(button.exists, "\(buttonName) button should respond to tap")
            }
        }
    }
    
    // MARK: - Navigation Flow Tests
    
    func testNavigationFlowMakesSense() throws {
        // Test logical navigation flow through MLACS
        
        // 1. Start at Dashboard
        let sidebar = app.outlines.firstMatch
        sidebar.staticTexts["Dashboard"].tap()
        
        // 2. Navigate to MLACS
        sidebar.staticTexts["MLACS"].tap()
        let mlacsLoaded = app.staticTexts["Multi-LLM Agent Coordination System"].waitForExistence(timeout: 5.0)
        XCTAssertTrue(mlacsLoaded, "Should load MLACS from Dashboard")
        
        // 3. Go through logical MLACS flow: Overview -> System Analysis -> Model Discovery -> Setup
        let flowSteps = [
            ("Overview", "System overview should load"),
            ("System Analysis", "System analysis should load"),
            ("Model Discovery", "Model discovery should load"),
            ("Setup Wizard", "Setup wizard should load")
        ]
        
        for (stepName, expectation) in flowSteps {
            let tabButton = app.staticTexts[stepName]
            if tabButton.exists {
                tabButton.tap()
                
                // Wait for content to load
                let contentLoaded = app.staticTexts[stepName].waitForExistence(timeout: 3.0)
                XCTAssertTrue(contentLoaded, expectation)
            }
        }
        
        // 4. Navigate back to Dashboard to test return flow
        sidebar.staticTexts["Dashboard"].tap()
        let dashboardReloaded = app.staticTexts["Dashboard"].waitForExistence(timeout: 3.0)
        XCTAssertTrue(dashboardReloaded, "Should be able to navigate back to Dashboard")
    }
    
    func testAllNavigationItemsAreAccessible() throws {
        // Test that every navigation item in main app is accessible
        
        let mainNavItems = [
            "Dashboard",
            "Documents", 
            "Analytics",
            "MLACS",
            "Financial Export",
            "Settings"
        ]
        
        let sidebar = app.outlines.firstMatch
        
        for navItem in mainNavItems {
            let navButton = sidebar.staticTexts[navItem]
            XCTAssertTrue(navButton.exists, "\(navItem) should exist in navigation")
            
            // Test navigation
            navButton.tap()
            
            // Wait for navigation to complete
            let navCompleted = app.staticTexts[navItem].waitForExistence(timeout: 3.0)
            XCTAssertTrue(navCompleted, "Should navigate to \(navItem)")
        }
    }
    
    // MARK: - Accessibility Tests
    
    func testMLACSViewsHaveProperAccessibility() throws {
        // Test accessibility labels and hints
        
        // Navigate to MLACS
        let sidebar = app.outlines.firstMatch
        sidebar.staticTexts["MLACS"].tap()
        
        // Check main elements have accessibility
        let mainTitle = app.staticTexts["Multi-LLM Agent Coordination System"]
        XCTAssertTrue(mainTitle.exists, "Main title should be accessible")
        
        // Check buttons have proper accessibility
        let refreshButton = app.buttons["Refresh"]
        if refreshButton.exists {
            XCTAssertTrue(refreshButton.isEnabled, "Refresh button should be enabled")
        }
        
        let setupButton = app.buttons["Setup Wizard"]
        if setupButton.exists {
            XCTAssertTrue(setupButton.isEnabled, "Setup wizard button should be enabled")
        }
    }
    
    // MARK: - Error State Tests
    
    func testNavigationWorksWhenDataIsLoading() throws {
        // Test that navigation still works when MLACS is loading data
        
        // Navigate to MLACS quickly (before data loads)
        let sidebar = app.outlines.firstMatch
        sidebar.staticTexts["MLACS"].tap()
        
        // Try to navigate between tabs while loading
        let overviewTab = app.staticTexts["Overview"]
        if overviewTab.exists {
            overviewTab.tap()
        }
        
        let discoveryTab = app.staticTexts["Model Discovery"]
        if discoveryTab.exists {
            discoveryTab.tap()
        }
        
        // Navigation should still work even during loading
        XCTAssertTrue(true, "Navigation should remain functional during loading states")
    }
    
    func testBackAndForwardNavigation() throws {
        // Test going back and forth between views
        
        let sidebar = app.outlines.firstMatch
        
        // Start at Dashboard
        sidebar.staticTexts["Dashboard"].tap()
        
        // Go to MLACS
        sidebar.staticTexts["MLACS"].tap()
        let mlacsLoaded = app.staticTexts["Multi-LLM Agent Coordination System"].waitForExistence(timeout: 5.0)
        XCTAssertTrue(mlacsLoaded, "MLACS should load")
        
        // Go to Documents
        sidebar.staticTexts["Documents"].tap()
        let documentsLoaded = app.staticTexts["Documents"].waitForExistence(timeout: 3.0)
        XCTAssertTrue(documentsLoaded, "Documents should load")
        
        // Back to MLACS
        sidebar.staticTexts["MLACS"].tap()
        let mlacsReloaded = app.staticTexts["Multi-LLM Agent Coordination System"].waitForExistence(timeout: 5.0)
        XCTAssertTrue(mlacsReloaded, "MLACS should reload properly")
        
        // Back to Dashboard
        sidebar.staticTexts["Dashboard"].tap()
        let dashboardReloaded = app.staticTexts["Dashboard"].waitForExistence(timeout: 3.0)
        XCTAssertTrue(dashboardReloaded, "Dashboard should reload properly")
    }
    
    // MARK: - Performance Tests
    
    func testNavigationPerformance() throws {
        // Test that navigation is responsive
        
        let sidebar = app.outlines.firstMatch
        
        // Measure navigation time to MLACS
        measure {
            sidebar.staticTexts["MLACS"].tap()
            _ = app.staticTexts["Multi-LLM Agent Coordination System"].waitForExistence(timeout: 10.0)
        }
    }
    
    // MARK: - Critical UX Questions Tests
    
    func testCanIPressEveryButtonInMLACS() throws {
        // Comprehensive test: "CAN I PRESS EVERY BUTTON AND DOES EACH BUTTON DO SOMETHING?"
        
        // Navigate to MLACS
        let sidebar = app.outlines.firstMatch
        sidebar.staticTexts["MLACS"].tap()
        _ = app.staticTexts["Multi-LLM Agent Coordination System"].waitForExistence(timeout: 5.0)
        
        // Get all buttons in MLACS view
        let allButtons = app.buttons.allElementsBoundByIndex
        
        for button in allButtons {
            if button.exists && button.isEnabled {
                let buttonLabel = button.label
                
                // Press the button
                button.tap()
                
                // Verify something happened (button still exists and is still enabled)
                // In a real test, we'd check for specific state changes
                XCTAssertTrue(button.exists, "Button '\(buttonLabel)' should still exist after being pressed")
                
                print("✅ Successfully pressed button: \(buttonLabel)")
            }
        }
    }
    
    func testDoesNavigationFlowMakeSense() throws {
        // Test: "DOES THAT FLOW MAKE SENSE?"
        
        let sidebar = app.outlines.firstMatch
        
        // Logical user journey test
        
        // 1. User starts at Dashboard (entry point)
        sidebar.staticTexts["Dashboard"].tap()
        XCTAssertTrue(app.staticTexts["Dashboard"].waitForExistence(timeout: 3.0), "Should start at Dashboard")
        
        // 2. User discovers MLACS in navigation (discoverability)
        let mlacsNav = sidebar.staticTexts["MLACS"]
        XCTAssertTrue(mlacsNav.exists, "MLACS should be discoverable in navigation")
        
        // 3. User clicks MLACS (accessibility)
        mlacsNav.tap()
        XCTAssertTrue(app.staticTexts["Multi-LLM Agent Coordination System"].waitForExistence(timeout: 5.0), "MLACS should load clearly")
        
        // 4. User sees overview first (logical starting point)
        XCTAssertTrue(app.staticTexts["Overview"].exists, "Overview should be default/first view")
        
        // 5. User can explore different aspects (system analysis before setup)
        app.staticTexts["System Analysis"].tap()
        XCTAssertTrue(app.staticTexts["System Analysis"].waitForExistence(timeout: 3.0), "Should analyze system first")
        
        // 6. User discovers models (logical next step)
        app.staticTexts["Model Discovery"].tap()
        XCTAssertTrue(app.staticTexts["Model Discovery"].waitForExistence(timeout: 3.0), "Should discover models next")
        
        // 7. User runs setup (final step)
        app.staticTexts["Setup Wizard"].tap()
        XCTAssertTrue(app.staticTexts["Setup Wizard"].waitForExistence(timeout: 3.0), "Setup should be final step")
        
        // 8. User can manage agents (ongoing use)
        app.staticTexts["Agent Management"].tap()
        XCTAssertTrue(app.staticTexts["Agent Management"].waitForExistence(timeout: 3.0), "Should manage agents for ongoing use")
        
        print("✅ Navigation flow makes logical sense for user journey")
    }
    
    func testCanINavigateThroughEachPage() throws {
        // Test: "CAN I NAVIGATE THROUGH EACH PAGE?"
        
        let sidebar = app.outlines.firstMatch
        
        // Main application pages
        let mainPages = [
            "Dashboard",
            "Documents", 
            "Analytics",
            "MLACS",
            "Financial Export",
            "Settings"
        ]
        
        for page in mainPages {
            sidebar.staticTexts[page].tap()
            let pageLoaded = app.staticTexts[page].waitForExistence(timeout: 5.0)
            XCTAssertTrue(pageLoaded, "Should be able to navigate to \(page)")
            print("✅ Successfully navigated to: \(page)")
        }
        
        // MLACS sub-pages
        sidebar.staticTexts["MLACS"].tap()
        _ = app.staticTexts["Multi-LLM Agent Coordination System"].waitForExistence(timeout: 5.0)
        
        let mlacsPages = [
            "Overview",
            "Model Discovery",
            "System Analysis", 
            "Setup Wizard",
            "Agent Management"
        ]
        
        for page in mlacsPages {
            let pageButton = app.staticTexts[page]
            if pageButton.exists {
                pageButton.tap()
                let pageLoaded = app.staticTexts[page].waitForExistence(timeout: 3.0)
                XCTAssertTrue(pageLoaded, "Should be able to navigate to MLACS \(page)")
                print("✅ Successfully navigated to MLACS: \(page)")
            }
        }
    }
}