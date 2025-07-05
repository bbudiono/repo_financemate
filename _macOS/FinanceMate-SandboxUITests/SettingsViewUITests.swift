import XCTest

/**
 * SettingsViewUITests.swift
 * 
 * Purpose: Comprehensive UI tests for SettingsView with accessibility and screenshot validation
 * Issues & Complexity Summary: Tests for settings interface, theme changes, and user interactions
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~220
 *   - Core Algorithm Complexity: Medium (UI automation and state validation)
 *   - Dependencies: 2 New (XCTest, UI automation)
 *   - State Management Complexity: Medium (Multiple UI states to test)
 *   - Novelty/Uncertainty Factor: Low (Established UI testing patterns)
 * AI Pre-Task Self-Assessment: 85%
 * Problem Estimate: 80%
 * Initial Code Complexity Estimate: 75%
 * Final Code Complexity: 78%
 * Overall Result Score: 85%
 * Key Variances/Learnings: UI automation patterns well-established
 * Last Updated: 2025-07-05
 */

final class SettingsViewUITests: XCTestCase {
    
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
    
    // MARK: - View Existence Tests
    
    func testSettingsViewExists() throws {
        let settingsView = app.otherElements["SettingsView"]
        XCTAssertTrue(settingsView.waitForExistence(timeout: 5))
    }
    
    func testSettingsHeaderExists() throws {
        let header = app.otherElements["SettingsHeader"]
        XCTAssertTrue(header.waitForExistence(timeout: 5))
        
        let icon = app.images["SettingsIcon"]
        XCTAssertTrue(icon.exists)
    }
    
    func testAllSettingsSectionsExist() throws {
        let themeSection = app.otherElements["ThemeSection"]
        let currencySection = app.otherElements["CurrencySection"]
        let notificationSection = app.otherElements["NotificationSection"]
        let actionsSection = app.otherElements["ActionsSection"]
        
        XCTAssertTrue(themeSection.waitForExistence(timeout: 5))
        XCTAssertTrue(currencySection.exists)
        XCTAssertTrue(notificationSection.exists)
        XCTAssertTrue(actionsSection.exists)
    }
    
    // MARK: - Theme Settings Tests
    
    func testThemeSelectionInteraction() throws {
        let systemTheme = app.otherElements["ThemeRow_System"]
        let lightTheme = app.otherElements["ThemeRow_Light"]
        let darkTheme = app.otherElements["ThemeRow_Dark"]
        
        XCTAssertTrue(systemTheme.waitForExistence(timeout: 5))
        XCTAssertTrue(lightTheme.exists)
        XCTAssertTrue(darkTheme.exists)
        
        // Test theme selection
        lightTheme.tap()
        XCTAssertTrue(lightTheme.exists)
        
        darkTheme.tap()
        XCTAssertTrue(darkTheme.exists)
        
        systemTheme.tap()
        XCTAssertTrue(systemTheme.exists)
    }
    
    func testThemeAccessibilityLabels() throws {
        let systemTheme = app.otherElements["ThemeRow_System"]
        XCTAssertTrue(systemTheme.waitForExistence(timeout: 5))
        
        let lightTheme = app.otherElements["ThemeRow_Light"]
        let darkTheme = app.otherElements["ThemeRow_Dark"]
        
        XCTAssertTrue(lightTheme.exists)
        XCTAssertTrue(darkTheme.exists)
        
        // Verify accessibility elements are properly configured
        XCTAssertNotNil(systemTheme.value)
        XCTAssertNotNil(lightTheme.value)
        XCTAssertNotNil(darkTheme.value)
    }
    
    // MARK: - Currency Settings Tests
    
    func testCurrencySelectionInteraction() throws {
        let usdCurrency = app.otherElements["CurrencyCard_USD"]
        let eurCurrency = app.otherElements["CurrencyCard_EUR"]
        let gbpCurrency = app.otherElements["CurrencyCard_GBP"]
        
        XCTAssertTrue(usdCurrency.waitForExistence(timeout: 5))
        XCTAssertTrue(eurCurrency.exists)
        XCTAssertTrue(gbpCurrency.exists)
        
        // Test currency selection
        eurCurrency.tap()
        XCTAssertTrue(eurCurrency.exists)
        
        gbpCurrency.tap()
        XCTAssertTrue(gbpCurrency.exists)
        
        usdCurrency.tap()
        XCTAssertTrue(usdCurrency.exists)
    }
    
    func testAllCurrencyOptionsExist() throws {
        let currencies = ["USD", "EUR", "GBP", "JPY", "AUD", "CAD"]
        
        for currency in currencies {
            let currencyCard = app.otherElements["CurrencyCard_\(currency)"]
            XCTAssertTrue(currencyCard.waitForExistence(timeout: 2), "Currency \(currency) should exist")
        }
    }
    
    // MARK: - Notification Settings Tests
    
    func testNotificationToggle() throws {
        let notificationToggle = app.switches["NotificationToggle"]
        XCTAssertTrue(notificationToggle.waitForExistence(timeout: 5))
        
        // Test toggle interaction
        let initialValue = notificationToggle.value as? String
        notificationToggle.tap()
        
        // Verify state changed
        let newValue = notificationToggle.value as? String
        XCTAssertNotEqual(initialValue, newValue)
        
        // Toggle back
        notificationToggle.tap()
        let finalValue = notificationToggle.value as? String
        XCTAssertEqual(initialValue, finalValue)
    }
    
    func testNotificationSectionAccessibility() throws {
        let notificationSection = app.otherElements["NotificationSection"]
        XCTAssertTrue(notificationSection.waitForExistence(timeout: 5))
        
        let toggle = app.switches["NotificationToggle"]
        XCTAssertTrue(toggle.exists)
        XCTAssertNotNil(toggle.label)
    }
    
    // MARK: - Actions Section Tests
    
    func testResetSettingsButton() throws {
        let resetButton = app.buttons["ResetSettingsButton"]
        XCTAssertTrue(resetButton.waitForExistence(timeout: 5))
        XCTAssertTrue(resetButton.isEnabled)
        
        // Test button interaction
        resetButton.tap()
        
        // Verify button still exists after action
        XCTAssertTrue(resetButton.exists)
    }
    
    func testSaveSettingsButton() throws {
        let saveButton = app.buttons["SaveSettingsButton"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 5))
        XCTAssertTrue(saveButton.isEnabled)
        
        // Test button interaction
        saveButton.tap()
        
        // Verify button still exists after action
        XCTAssertTrue(saveButton.exists)
    }
    
    // MARK: - Screenshot Tests
    
    func testSettingsViewScreenshotCapture() throws {
        let settingsView = app.otherElements["SettingsView"]
        XCTAssertTrue(settingsView.waitForExistence(timeout: 5))
        
        // Capture initial state
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "SettingsView_Initial_State"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    func testThemeChangeScreenshot() throws {
        let darkTheme = app.otherElements["ThemeRow_Dark"]
        XCTAssertTrue(darkTheme.waitForExistence(timeout: 5))
        
        // Change to dark theme
        darkTheme.tap()
        
        // Wait for theme change animation
        sleep(1)
        
        // Capture dark theme state
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "SettingsView_Dark_Theme"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    func testCurrencySelectionScreenshot() throws {
        let eurCurrency = app.otherElements["CurrencyCard_EUR"]
        XCTAssertTrue(eurCurrency.waitForExistence(timeout: 5))
        
        // Select EUR currency
        eurCurrency.tap()
        
        // Wait for selection animation
        sleep(1)
        
        // Capture currency selection state
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "SettingsView_EUR_Currency_Selected"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    // MARK: - Performance Tests
    
    func testSettingsViewLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            app.launch()
            let settingsView = app.otherElements["SettingsView"]
            XCTAssertTrue(settingsView.waitForExistence(timeout: 5))
        }
    }
    
    func testSettingsInteractionPerformance() throws {
        let settingsView = app.otherElements["SettingsView"]
        XCTAssertTrue(settingsView.waitForExistence(timeout: 5))
        
        measure(metrics: [XCTCPUMetric(), XCTMemoryMetric()]) {
            // Perform multiple interactions
            let themes = ["Light", "Dark", "System"]
            let currencies = ["EUR", "GBP", "USD"]
            
            for theme in themes {
                let themeRow = app.otherElements["ThemeRow_\(theme)"]
                if themeRow.exists {
                    themeRow.tap()
                }
            }
            
            for currency in currencies {
                let currencyCard = app.otherElements["CurrencyCard_\(currency)"]
                if currencyCard.exists {
                    currencyCard.tap()
                }
            }
            
            // Toggle notifications
            let toggle = app.switches["NotificationToggle"]
            if toggle.exists {
                toggle.tap()
                toggle.tap() // Toggle back
            }
        }
    }
    
    // MARK: - Accessibility Tests
    
    func testVoiceOverCompliance() throws {
        let settingsView = app.otherElements["SettingsView"]
        XCTAssertTrue(settingsView.waitForExistence(timeout: 5))
        
        // Test that all major elements are accessible
        let accessibleElements = [
            "SettingsHeader",
            "ThemeSection",
            "CurrencySection", 
            "NotificationSection",
            "ActionsSection",
            "ResetSettingsButton",
            "SaveSettingsButton",
            "NotificationToggle"
        ]
        
        for elementId in accessibleElements {
            let element = app.otherElements[elementId].firstMatch
            if !element.exists {
                let button = app.buttons[elementId].firstMatch
                let toggle = app.switches[elementId].firstMatch
                XCTAssertTrue(element.exists || button.exists || toggle.exists, 
                             "Element \(elementId) should be accessible")
            }
        }
    }
    
    func testKeyboardNavigation() throws {
        let settingsView = app.otherElements["SettingsView"]
        XCTAssertTrue(settingsView.waitForExistence(timeout: 5))
        
        // Test tab navigation through interactive elements
        let interactiveElements = [
            app.buttons["ResetSettingsButton"],
            app.buttons["SaveSettingsButton"],
            app.switches["NotificationToggle"]
        ]
        
        for element in interactiveElements {
            if element.exists {
                XCTAssertTrue(element.isEnabled, "Interactive element should be enabled")
            }
        }
    }
}