import XCTest
@testable import FinanceMate

/**
 * OCRCameraViewUITests.swift
 * 
 * Purpose: Comprehensive UI tests for OCR camera interface with accessibility, glassmorphism styling, and user workflow validation
 * Issues & Complexity Summary: Tests camera permissions, capture workflow, UI responsiveness, and accessibility compliance
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~200+
 *   - Core Algorithm Complexity: Medium
 *   - Dependencies: 2 (XCTest, UI Testing Framework)
 *   - State Management Complexity: Medium
 *   - Novelty/Uncertainty Factor: Low-Medium
 * AI Pre-Task Self-Assessment: 82%
 * Problem Estimate: 80%
 * Initial Code Complexity Estimate: 80%
 * Final Code Complexity: TBD
 * Overall Result Score: TBD
 * Key Variances/Learnings: UI automation for camera interface with accessibility validation
 * Last Updated: 2025-07-08
 */

final class OCRCameraViewUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        
        // Configure app for UI testing
        app.launchArguments.append("--uitesting")
        app.launchEnvironment["ENABLE_OCR_TESTING"] = "1"
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Camera Interface Tests
    
    func testCameraViewPresentation() throws {
        // Navigate to transactions view
        navigateToTransactionsView()
        
        // When: Tapping OCR camera button
        let ocrButton = app.buttons["Add Receipt"]
        XCTAssertTrue(ocrButton.exists, "OCR button should exist in transactions view")
        ocrButton.tap()
        
        // Then: Should present camera interface
        let cameraView = app.otherElements["OCRCameraView"]
        XCTAssertTrue(cameraView.waitForExistence(timeout: 2.0), "Camera view should appear")
        
        // Verify camera preview is visible
        let cameraPreview = app.otherElements["CameraPreview"]
        XCTAssertTrue(cameraPreview.exists, "Camera preview should be visible")
        
        // Verify capture button is present
        let captureButton = app.buttons["CapturePhoto"]
        XCTAssertTrue(captureButton.exists, "Capture button should be present")
        XCTAssertTrue(captureButton.isEnabled, "Capture button should be enabled")
    }
    
    func testCameraPermissions() throws {
        // Navigate to camera view
        navigateToTransactionsView()
        app.buttons["Add Receipt"].tap()
        
        // Wait for permission dialog (if needed)
        let permissionAlert = app.alerts.firstMatch
        if permissionAlert.waitForExistence(timeout: 3.0) {
            // Grant camera permission
            let allowButton = permissionAlert.buttons["Allow"]
            if allowButton.exists {
                allowButton.tap()
            }
        }
        
        // Verify camera view loads properly after permissions
        let cameraView = app.otherElements["OCRCameraView"]
        XCTAssertTrue(cameraView.waitForExistence(timeout: 5.0), "Camera view should load after permissions")
        
        // Verify no error state
        let errorMessage = app.staticTexts["Camera Error"]
        XCTAssertFalse(errorMessage.exists, "Should not show camera error after permission granted")
    }
    
    func testCaptureButtonFunctionality() throws {
        // Navigate to camera view
        navigateToOCRCamera()
        
        // When: Tapping capture button
        let captureButton = app.buttons["CapturePhoto"]
        XCTAssertTrue(captureButton.exists, "Capture button should exist")
        
        captureButton.tap()
        
        // Then: Should show processing indicator
        let processingIndicator = app.activityIndicators["OCRProcessing"]
        XCTAssertTrue(processingIndicator.waitForExistence(timeout: 2.0), "Should show processing indicator")
        
        // Wait for processing to complete
        XCTAssertTrue(processingIndicator.waitForNonExistence(timeout: 10.0), "Processing should complete")
        
        // Should navigate to review screen or show results
        let reviewView = app.otherElements["OCRReviewView"]
        let resultsView = app.otherElements["OCRResultsView"]
        
        let reviewOrResultsExists = reviewView.waitForExistence(timeout: 2.0) || resultsView.waitForExistence(timeout: 2.0)
        XCTAssertTrue(reviewOrResultsExists, "Should show review or results view after capture")
    }
    
    func testCameraControlsAccessibility() throws {
        // Navigate to camera view
        navigateToOCRCamera()
        
        // Test capture button accessibility
        let captureButton = app.buttons["CapturePhoto"]
        XCTAssertTrue(captureButton.exists, "Capture button should exist")
        XCTAssertTrue(captureButton.isHittable, "Capture button should be hittable")
        
        // Verify accessibility label
        let accessibilityLabel = captureButton.label
        XCTAssertFalse(accessibilityLabel.isEmpty, "Capture button should have accessibility label")
        XCTAssertTrue(accessibilityLabel.contains("Capture") || accessibilityLabel.contains("Take Photo"), 
                     "Accessibility label should be descriptive")
        
        // Test close/cancel button accessibility
        let closeButton = app.buttons["Close"]
        XCTAssertTrue(closeButton.exists, "Close button should exist")
        XCTAssertTrue(closeButton.isHittable, "Close button should be hittable")
        
        // Test flash toggle accessibility (if available)
        let flashButton = app.buttons["Flash Toggle"]
        if flashButton.exists {
            XCTAssertTrue(flashButton.isHittable, "Flash button should be hittable")
        }
    }
    
    func testGlassmorphismStyling() throws {
        // Navigate to camera view
        navigateToOCRCamera()
        
        // Verify glassmorphism styling elements are present
        let cameraControls = app.otherElements["CameraControls"]
        XCTAssertTrue(cameraControls.exists, "Camera controls container should exist")
        
        // Test that UI elements have proper visual styling (indirect test via existence)
        let captureButton = app.buttons["CapturePhoto"]
        XCTAssertTrue(captureButton.exists, "Styled capture button should exist")
        
        // Verify overlay elements for glassmorphism effect
        let overlayView = app.otherElements["GlassmorphismOverlay"]
        if overlayView.exists {
            XCTAssertTrue(overlayView.isHittable == false, "Overlay should not intercept touches")
        }
        
        // Test visual feedback on button press
        captureButton.press(forDuration: 0.1)
        // Button should remain accessible after press
        XCTAssertTrue(captureButton.exists, "Button should remain accessible after press")
    }
    
    // MARK: - Error Handling UI Tests
    
    func testCameraAccessDeniedScenario() throws {
        // This test simulates camera access denied scenario
        app.launchEnvironment["SIMULATE_CAMERA_DENIED"] = "1"
        app.terminate()
        app.launch()
        
        // Navigate to camera view
        navigateToTransactionsView()
        app.buttons["Add Receipt"].tap()
        
        // Should show error state instead of camera
        let errorView = app.otherElements["CameraErrorView"]
        XCTAssertTrue(errorView.waitForExistence(timeout: 3.0), "Should show camera error view")
        
        let errorMessage = app.staticTexts["Camera Access Denied"]
        XCTAssertTrue(errorMessage.exists, "Should show access denied message")
        
        // Should provide settings button
        let settingsButton = app.buttons["Open Settings"]
        XCTAssertTrue(settingsButton.exists, "Should provide settings button")
        XCTAssertTrue(settingsButton.isEnabled, "Settings button should be enabled")
    }
    
    func testImagePickerFallback() throws {
        // When camera is not available, should offer file picker
        app.launchEnvironment["SIMULATE_NO_CAMERA"] = "1"
        app.terminate()
        app.launch()
        
        navigateToTransactionsView()
        app.buttons["Add Receipt"].tap()
        
        // Should present image picker instead of camera
        let imagePickerView = app.otherElements["ImagePickerView"]
        XCTAssertTrue(imagePickerView.waitForExistence(timeout: 3.0), "Should show image picker fallback")
        
        let chooseFileButton = app.buttons["Choose File"]
        XCTAssertTrue(chooseFileButton.exists, "Should provide file selection option")
    }
    
    // MARK: - Workflow Integration Tests
    
    func testCompleteOCRWorkflow() throws {
        // Navigate to camera and capture
        navigateToOCRCamera()
        
        // Capture photo
        let captureButton = app.buttons["CapturePhoto"]
        captureButton.tap()
        
        // Wait for processing
        let processingIndicator = app.activityIndicators["OCRProcessing"]
        XCTAssertTrue(processingIndicator.waitForExistence(timeout: 2.0), "Should show processing")
        XCTAssertTrue(processingIndicator.waitForNonExistence(timeout: 10.0), "Processing should complete")
        
        // Should show results or review interface
        let reviewView = app.otherElements["OCRReviewView"]
        if reviewView.waitForExistence(timeout: 2.0) {
            // Review interface workflow
            testReviewInterfaceWorkflow()
        } else {
            // Direct results workflow
            let resultsView = app.otherElements["OCRResultsView"]
            XCTAssertTrue(resultsView.exists, "Should show results view")
            
            // Verify extracted data is displayed
            let merchantName = app.staticTexts["ExtractedMerchant"]
            let totalAmount = app.staticTexts["ExtractedAmount"]
            
            XCTAssertTrue(merchantName.exists, "Should display extracted merchant name")
            XCTAssertTrue(totalAmount.exists, "Should display extracted amount")
        }
    }
    
    func testReviewInterfaceWorkflow() {
        // Assumes we're in the review interface
        let reviewView = app.otherElements["OCRReviewView"]
        XCTAssertTrue(reviewView.exists, "Should be in review interface")
        
        // Test editing extracted data
        let merchantField = app.textFields["MerchantNameField"]
        if merchantField.exists {
            merchantField.tap()
            merchantField.typeText(" - Edited")
        }
        
        let amountField = app.textFields["AmountField"]
        if amountField.exists {
            amountField.tap()
            amountField.clearAndEnterText("99.99")
        }
        
        // Approve changes
        let approveButton = app.buttons["Approve"]
        XCTAssertTrue(approveButton.exists, "Should have approve button")
        XCTAssertTrue(approveButton.isEnabled, "Approve button should be enabled")
        
        approveButton.tap()
        
        // Should proceed to completion
        let completionView = app.otherElements["OCRCompletionView"]
        XCTAssertTrue(completionView.waitForExistence(timeout: 2.0), "Should show completion view")
    }
    
    // MARK: - Performance and Responsiveness Tests
    
    func testUIResponsiveness() throws {
        // Navigate to camera view
        navigateToOCRCamera()
        
        // Test rapid button taps don't cause issues
        let captureButton = app.buttons["CapturePhoto"]
        let closeButton = app.buttons["Close"]
        
        // Rapid interaction test
        for _ in 0..<5 {
            captureButton.tap()
            Thread.sleep(forTimeInterval: 0.1)
        }
        
        // UI should remain responsive
        XCTAssertTrue(closeButton.isHittable, "Close button should remain responsive")
        XCTAssertTrue(captureButton.exists, "Capture button should still exist")
    }
    
    func testMemoryUnderStress() throws {
        // Simulate memory pressure scenario
        navigateToOCRCamera()
        
        // Perform multiple capture operations
        let captureButton = app.buttons["CapturePhoto"]
        
        for i in 0..<3 {
            captureButton.tap()
            
            // Wait for processing to complete
            let processingIndicator = app.activityIndicators["OCRProcessing"]
            if processingIndicator.waitForExistence(timeout: 1.0) {
                XCTAssertTrue(processingIndicator.waitForNonExistence(timeout: 10.0), 
                             "Processing \(i+1) should complete")
            }
            
            // Return to camera for next iteration (if not last)
            if i < 2 {
                let backButton = app.buttons["Back to Camera"]
                if backButton.exists {
                    backButton.tap()
                }
            }
        }
        
        // App should remain stable
        XCTAssertTrue(app.state == .runningForeground, "App should remain stable under stress")
    }
    
    // MARK: - Accessibility Compliance Tests
    
    func testVoiceOverSupport() throws {
        // Navigate to camera view
        navigateToOCRCamera()
        
        // Test VoiceOver navigation
        let captureButton = app.buttons["CapturePhoto"]
        let closeButton = app.buttons["Close"]
        
        // Verify elements are accessible to VoiceOver
        XCTAssertTrue(captureButton.isAccessibilityElement, "Capture button should be accessibility element")
        XCTAssertTrue(closeButton.isAccessibilityElement, "Close button should be accessibility element")
        
        // Verify accessibility traits
        XCTAssertTrue(captureButton.accessibilityTraits.contains(.button), "Should have button trait")
        
        // Test accessibility labels are descriptive
        let captureLabel = captureButton.label
        XCTAssertGreaterThan(captureLabel.count, 5, "Accessibility label should be descriptive")
    }
    
    func testKeyboardNavigation() throws {
        // Navigate to camera view
        navigateToOCRCamera()
        
        // Test tab navigation (for users who prefer keyboard)
        let captureButton = app.buttons["CapturePhoto"]
        let closeButton = app.buttons["Close"]
        
        // Verify buttons can be focused
        captureButton.hover()
        XCTAssertTrue(captureButton.hasFocus || captureButton.isHittable, "Capture button should be focusable")
        
        closeButton.hover()
        XCTAssertTrue(closeButton.hasFocus || closeButton.isHittable, "Close button should be focusable")
    }
    
    // MARK: - Helper Methods
    
    private func navigateToTransactionsView() {
        // Navigate to the transactions tab
        let transactionsTab = app.buttons["Transactions"]
        if transactionsTab.exists {
            transactionsTab.tap()
        } else {
            // Alternative navigation if tab structure is different
            let mainWindow = app.windows.firstMatch
            if mainWindow.exists {
                // Look for transactions link in main view
                let transactionsLink = app.buttons["View Transactions"]
                if transactionsLink.exists {
                    transactionsLink.tap()
                }
            }
        }
        
        // Verify we're in transactions view
        let transactionsView = app.otherElements["TransactionsView"]
        XCTAssertTrue(transactionsView.waitForExistence(timeout: 3.0), "Should navigate to transactions view")
    }
    
    private func navigateToOCRCamera() {
        navigateToTransactionsView()
        
        let ocrButton = app.buttons["Add Receipt"]
        XCTAssertTrue(ocrButton.exists, "OCR button should exist")
        ocrButton.tap()
        
        // Wait for camera view to appear
        let cameraView = app.otherElements["OCRCameraView"]
        XCTAssertTrue(cameraView.waitForExistence(timeout: 3.0), "Camera view should appear")
    }
}

// MARK: - XCUIElement Extensions for Testing

extension XCUIElement {
    func clearAndEnterText(_ text: String) {
        guard self.elementType == .textField else { return }
        
        self.tap()
        self.selectAll()
        self.typeText(text)
    }
    
    func selectAll() {
        self.coordinate(withNormalizedOffset: CGVector(dx: 0.0, dy: 0.0)).tap()
        self.typeText(XCUIKeyboardKey.command.rawValue + "a")
    }
}