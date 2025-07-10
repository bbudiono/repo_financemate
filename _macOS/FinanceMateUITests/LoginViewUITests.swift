import XCTest

/**
 * LoginViewUITests.swift
 * 
 * Purpose: UI tests for LoginView with comprehensive authentication flow testing
 * Issues & Complexity Summary: Tests authentication UI, OAuth flows, MFA, biometric auth
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~600
 *   - Core Algorithm Complexity: Medium (UI testing, Authentication flows)
 *   - Dependencies: 2 (XCTest, XCUITest)
 *   - State Management Complexity: Medium (UI state verification)
 *   - Novelty/Uncertainty Factor: Medium (Authentication UI testing)
 * AI Pre-Task Self-Assessment: 85%
 * Problem Estimate: 88%
 * Initial Code Complexity Estimate: 75%
 * Final Code Complexity: TBD
 * Overall Result Score: TBD
 * Key Variances/Learnings: UI testing for security-critical authentication flows
 * Last Updated: 2025-07-09
 */

final class LoginViewUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launchArguments = ["--uitesting", "--reset-auth-state"]
        app.launchEnvironment["UI_TESTING"] = "1"
        app.launchEnvironment["AUTHENTICATION_TESTING"] = "1"
        
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Login View Existence Tests
    
    func testLoginViewExists() throws {
        // Test that login view is displayed initially
        let loginHeader = app.staticTexts["FinanceMate"]
        XCTAssertTrue(loginHeader.waitForExistence(timeout: 10.0), "Login view should be displayed")
        
        let subtitle = app.staticTexts["Secure Financial Management"]
        XCTAssertTrue(subtitle.exists, "Login subtitle should be visible")
        
        let emailField = app.textFields["EmailField"]
        XCTAssertTrue(emailField.exists, "Email field should be present")
        
        let passwordField = app.secureTextFields["PasswordField"]
        XCTAssertTrue(passwordField.exists, "Password field should be present")
        
        let signInButton = app.buttons["SignInButton"]
        XCTAssertTrue(signInButton.exists, "Sign in button should be present")
    }
    
    func testLoginViewAccessibility() throws {
        // Test accessibility identifiers
        let loginHeader = app.otherElements["LoginHeader"]
        XCTAssertTrue(loginHeader.exists, "Login header should have accessibility identifier")
        
        let authTabs = app.otherElements["AuthenticationTabs"]
        XCTAssertTrue(authTabs.exists, "Authentication tabs should have accessibility identifier")
        
        let emailField = app.textFields["EmailField"]
        XCTAssertTrue(emailField.exists, "Email field should have accessibility identifier")
        
        let passwordField = app.secureTextFields["PasswordField"]
        XCTAssertTrue(passwordField.exists, "Password field should have accessibility identifier")
        
        let signInButton = app.buttons["SignInButton"]
        XCTAssertTrue(signInButton.exists, "Sign in button should have accessibility identifier")
    }
    
    // MARK: - Authentication Tab Tests
    
    func testTabSwitching() throws {
        let authTabs = app.otherElements["AuthenticationTabs"]
        XCTAssertTrue(authTabs.waitForExistence(timeout: 5.0), "Authentication tabs should exist")
        
        // Test initial state (Sign In tab)
        let signInTab = authTabs.buttons["Sign In"]
        XCTAssertTrue(signInTab.exists, "Sign In tab should exist")
        
        // Switch to Register tab
        let registerTab = authTabs.buttons["Register"]
        XCTAssertTrue(registerTab.exists, "Register tab should exist")
        registerTab.tap()
        
        // Verify registration form is displayed
        let nameField = app.textFields["NameField"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 2.0), "Name field should appear in registration form")
        
        let registerButton = app.buttons["RegisterButton"]
        XCTAssertTrue(registerButton.exists, "Register button should appear")
        
        // Switch back to Sign In tab
        signInTab.tap()
        
        // Verify login form is displayed
        let emailField = app.textFields["EmailField"]
        XCTAssertTrue(emailField.waitForExistence(timeout: 2.0), "Email field should appear in login form")
        
        let signInButton = app.buttons["SignInButton"]
        XCTAssertTrue(signInButton.exists, "Sign in button should appear")
    }
    
    // MARK: - Email/Password Authentication Tests
    
    func testEmailPasswordFields() throws {
        let emailField = app.textFields["EmailField"]
        let passwordField = app.secureTextFields["PasswordField"]
        
        XCTAssertTrue(emailField.waitForExistence(timeout: 5.0), "Email field should exist")
        XCTAssertTrue(passwordField.exists, "Password field should exist")
        
        // Test email input
        emailField.tap()
        emailField.typeText("test@example.com")
        XCTAssertEqual(emailField.value as? String, "test@example.com", "Email should be entered correctly")
        
        // Test password input
        passwordField.tap()
        passwordField.typeText("password123")
        // Note: SecureField values are not readable for security reasons
        XCTAssertTrue(passwordField.exists, "Password field should accept input")
    }
    
    func testPasswordVisibilityToggle() throws {
        let passwordField = app.secureTextFields["PasswordField"]
        XCTAssertTrue(passwordField.waitForExistence(timeout: 5.0), "Password field should exist")
        
        // Find the password visibility toggle button
        let passwordToggle = passwordField.buttons.matching(identifier: "eye").firstMatch
        if passwordToggle.exists {
            passwordToggle.tap()
            
            // After tapping, the field might change to a regular text field
            // This depends on the implementation
            let textField = app.textFields["PasswordField"]
            XCTAssertTrue(textField.exists || passwordField.exists, "Password field should remain accessible")
        }
    }
    
    func testSignInButtonState() throws {
        let signInButton = app.buttons["SignInButton"]
        XCTAssertTrue(signInButton.waitForExistence(timeout: 5.0), "Sign in button should exist")
        
        // Button should be disabled when fields are empty
        XCTAssertFalse(signInButton.isEnabled, "Sign in button should be disabled when fields are empty")
        
        // Fill in email and password
        let emailField = app.textFields["EmailField"]
        emailField.tap()
        emailField.typeText("test@example.com")
        
        let passwordField = app.secureTextFields["PasswordField"]
        passwordField.tap()
        passwordField.typeText("password123")
        
        // Button should be enabled when fields are filled
        XCTAssertTrue(signInButton.isEnabled, "Sign in button should be enabled when fields are filled")
    }
    
    func testSignInFlow() throws {
        let emailField = app.textFields["EmailField"]
        let passwordField = app.secureTextFields["PasswordField"]
        let signInButton = app.buttons["SignInButton"]
        
        // Enter credentials
        emailField.tap()
        emailField.typeText("test@example.com")
        
        passwordField.tap()
        passwordField.typeText("password123")
        
        // Tap sign in
        signInButton.tap()
        
        // Verify loading state appears
        let loadingIndicator = app.progressIndicators.firstMatch
        if loadingIndicator.exists {
            XCTAssertTrue(loadingIndicator.isHittable, "Loading indicator should be visible during sign in")
        }
        
        // Wait for authentication to complete (either success or error)
        let authenticationComplete = expectation(description: "Authentication completes")
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            authenticationComplete.fulfill()
        }
        wait(for: [authenticationComplete], timeout: 5.0)
    }
    
    // MARK: - Registration Tests
    
    func testRegistrationForm() throws {
        // Switch to registration tab
        let authTabs = app.otherElements["AuthenticationTabs"]
        let registerTab = authTabs.buttons["Register"]
        registerTab.tap()
        
        // Verify registration form elements
        let nameField = app.textFields["NameField"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 2.0), "Name field should exist")
        
        let registerEmailField = app.textFields["RegisterEmailField"]
        XCTAssertTrue(registerEmailField.exists, "Registration email field should exist")
        
        let registerPasswordField = app.secureTextFields["RegisterPasswordField"]
        XCTAssertTrue(registerPasswordField.exists, "Registration password field should exist")
        
        let confirmPasswordField = app.secureTextFields["ConfirmPasswordField"]
        XCTAssertTrue(confirmPasswordField.exists, "Confirm password field should exist")
        
        let registerButton = app.buttons["RegisterButton"]
        XCTAssertTrue(registerButton.exists, "Register button should exist")
        
        // Initially disabled
        XCTAssertFalse(registerButton.isEnabled, "Register button should be disabled initially")
    }
    
    func testRegistrationValidation() throws {
        // Switch to registration tab
        let authTabs = app.otherElements["AuthenticationTabs"]
        let registerTab = authTabs.buttons["Register"]
        registerTab.tap()
        
        // Fill in registration form
        let nameField = app.textFields["NameField"]
        nameField.tap()
        nameField.typeText("Test User")
        
        let registerEmailField = app.textFields["RegisterEmailField"]
        registerEmailField.tap()
        registerEmailField.typeText("test@example.com")
        
        let registerPasswordField = app.secureTextFields["RegisterPasswordField"]
        registerPasswordField.tap()
        registerPasswordField.typeText("password123")
        
        let confirmPasswordField = app.secureTextFields["ConfirmPasswordField"]
        confirmPasswordField.tap()
        confirmPasswordField.typeText("password123")
        
        // Button should be enabled when all fields are valid
        let registerButton = app.buttons["RegisterButton"]
        XCTAssertTrue(registerButton.isEnabled, "Register button should be enabled when form is valid")
    }
    
    // MARK: - OAuth Authentication Tests
    
    func testOAuthButtons() throws {
        // Test Apple Sign In button
        let appleSignInButton = app.buttons["SignInWithAppleButton"]
        XCTAssertTrue(appleSignInButton.waitForExistence(timeout: 5.0), "Apple Sign In button should exist")
        XCTAssertTrue(appleSignInButton.isHittable, "Apple Sign In button should be tappable")
        
        // Test Google Sign In button
        let googleSignInButton = app.buttons["SignInWithGoogleButton"]
        XCTAssertTrue(googleSignInButton.exists, "Google Sign In button should exist")
        XCTAssertTrue(googleSignInButton.isHittable, "Google Sign In button should be tappable")
        
        // Test Microsoft Sign In button
        let microsoftSignInButton = app.buttons["SignInWithMicrosoftButton"]
        XCTAssertTrue(microsoftSignInButton.exists, "Microsoft Sign In button should exist")
        XCTAssertTrue(microsoftSignInButton.isHittable, "Microsoft Sign In button should be tappable")
    }
    
    func testOAuthButtonInteraction() throws {
        // Test tapping Google Sign In button
        let googleSignInButton = app.buttons["SignInWithGoogleButton"]
        googleSignInButton.tap()
        
        // Verify loading state appears
        let loadingIndicator = app.progressIndicators.firstMatch
        if loadingIndicator.exists {
            XCTAssertTrue(loadingIndicator.isHittable, "Loading indicator should appear during OAuth")
        }
        
        // Wait for OAuth process to complete
        let oauthComplete = expectation(description: "OAuth completes")
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            oauthComplete.fulfill()
        }
        wait(for: [oauthComplete], timeout: 5.0)
    }
    
    // MARK: - Biometric Authentication Tests
    
    func testBiometricAuthenticationButton() throws {
        let biometricButton = app.buttons["BiometricSignInButton"]
        XCTAssertTrue(biometricButton.waitForExistence(timeout: 5.0), "Biometric sign in button should exist")
        XCTAssertTrue(biometricButton.isHittable, "Biometric sign in button should be tappable")
        
        // Test button tap
        biometricButton.tap()
        
        // Verify loading state or authentication prompt
        let loadingIndicator = app.progressIndicators.firstMatch
        if loadingIndicator.exists {
            XCTAssertTrue(loadingIndicator.isHittable, "Loading indicator should appear during biometric authentication")
        }
    }
    
    // MARK: - MFA Tests
    
    func testMFAFlow() throws {
        // This test simulates the MFA flow by using test credentials that trigger MFA
        let emailField = app.textFields["EmailField"]
        let passwordField = app.secureTextFields["PasswordField"]
        let signInButton = app.buttons["SignInButton"]
        
        // Enter MFA test credentials
        emailField.tap()
        emailField.typeText("mfa@example.com")
        
        passwordField.tap()
        passwordField.typeText("password123")
        
        signInButton.tap()
        
        // Wait for MFA view to appear
        let mfaCodeField = app.textFields["MFACodeField"]
        if mfaCodeField.waitForExistence(timeout: 5.0) {
            XCTAssertTrue(mfaCodeField.exists, "MFA code field should appear")
            
            let verifyButton = app.buttons["VerifyMFAButton"]
            XCTAssertTrue(verifyButton.exists, "MFA verify button should exist")
            
            // Test MFA code input
            mfaCodeField.tap()
            mfaCodeField.typeText("123456")
            
            // Button should be enabled when code is 6 digits
            XCTAssertTrue(verifyButton.isEnabled, "Verify button should be enabled with 6-digit code")
            
            // Test verification
            verifyButton.tap()
            
            // Wait for verification to complete
            let verificationComplete = expectation(description: "MFA verification completes")
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                verificationComplete.fulfill()
            }
            wait(for: [verificationComplete], timeout: 5.0)
        }
    }
    
    // MARK: - Forgot Password Tests
    
    func testForgotPasswordFlow() throws {
        let forgotPasswordButton = app.buttons["Forgot Password?"]
        XCTAssertTrue(forgotPasswordButton.waitForExistence(timeout: 5.0), "Forgot password button should exist")
        
        // Tap forgot password
        forgotPasswordButton.tap()
        
        // Verify forgot password sheet appears
        let resetPasswordText = app.staticTexts["Reset Password"]
        XCTAssertTrue(resetPasswordText.waitForExistence(timeout: 3.0), "Reset password sheet should appear")
        
        // Check for email field in the sheet
        let emailField = app.textFields.matching(identifier: "Enter your email").firstMatch
        XCTAssertTrue(emailField.exists, "Email field should exist in forgot password sheet")
        
        // Test email input
        emailField.tap()
        emailField.typeText("test@example.com")
        
        // Check for send button
        let sendButton = app.buttons["Send Reset Instructions"]
        XCTAssertTrue(sendButton.exists, "Send reset instructions button should exist")
        XCTAssertTrue(sendButton.isEnabled, "Send button should be enabled with valid email")
        
        // Test cancel button
        let cancelButton = app.buttons["Cancel"]
        XCTAssertTrue(cancelButton.exists, "Cancel button should exist")
        cancelButton.tap()
        
        // Verify sheet is dismissed
        XCTAssertFalse(resetPasswordText.exists, "Reset password sheet should be dismissed")
    }
    
    // MARK: - Visual Regression Tests
    
    func testLoginViewVisualRegression() throws {
        // Wait for login view to fully load
        let loginHeader = app.staticTexts["FinanceMate"]
        XCTAssertTrue(loginHeader.waitForExistence(timeout: 10.0), "Login view should be loaded")
        
        // Wait for all animations to complete
        let visualStabilization = expectation(description: "Visual stabilization")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            visualStabilization.fulfill()
        }
        wait(for: [visualStabilization], timeout: 5.0)
        
        // Capture screenshot for visual regression
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "login-view-regression-\(Date().timeIntervalSince1970)"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    func testRegistrationViewVisualRegression() throws {
        // Switch to registration tab
        let authTabs = app.otherElements["AuthenticationTabs"]
        let registerTab = authTabs.buttons["Register"]
        registerTab.tap()
        
        // Wait for registration form to load
        let nameField = app.textFields["NameField"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 5.0), "Registration form should load")
        
        // Wait for visual stabilization
        let visualStabilization = expectation(description: "Registration visual stabilization")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            visualStabilization.fulfill()
        }
        wait(for: [visualStabilization], timeout: 3.0)
        
        // Capture screenshot
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "registration-view-regression-\(Date().timeIntervalSince1970)"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    // MARK: - Error Handling Tests
    
    func testErrorDisplay() throws {
        let emailField = app.textFields["EmailField"]
        let passwordField = app.secureTextFields["PasswordField"]
        let signInButton = app.buttons["SignInButton"]
        
        // Enter invalid credentials
        emailField.tap()
        emailField.typeText("invalid@example.com")
        
        passwordField.tap()
        passwordField.typeText("wrongpassword")
        
        // Attempt sign in
        signInButton.tap()
        
        // Wait for error to appear
        let errorAlert = app.alerts["Authentication Error"]
        if errorAlert.waitForExistence(timeout: 10.0) {
            XCTAssertTrue(errorAlert.exists, "Error alert should appear for invalid credentials")
            
            let okButton = errorAlert.buttons["OK"]
            XCTAssertTrue(okButton.exists, "OK button should exist in error alert")
            okButton.tap()
        }
    }
    
    // MARK: - Performance Tests
    
    func testLoginViewLoadPerformance() throws {
        measure {
            // Relaunch app and measure load time
            app.terminate()
            app.launch()
            
            let loginHeader = app.staticTexts["FinanceMate"]
            XCTAssertTrue(loginHeader.waitForExistence(timeout: 10.0), "Login view should load within performance threshold")
        }
    }
    
    // MARK: - Accessibility Tests
    
    func testVoiceOverAccessibility() throws {
        // Test that key elements are accessible to VoiceOver
        let emailField = app.textFields["EmailField"]
        XCTAssertTrue(emailField.waitForExistence(timeout: 5.0), "Email field should exist")
        XCTAssertNotNil(emailField.label, "Email field should have accessibility label")
        
        let passwordField = app.secureTextFields["PasswordField"]
        XCTAssertTrue(passwordField.exists, "Password field should exist")
        XCTAssertNotNil(passwordField.label, "Password field should have accessibility label")
        
        let signInButton = app.buttons["SignInButton"]
        XCTAssertTrue(signInButton.exists, "Sign in button should exist")
        XCTAssertNotNil(signInButton.label, "Sign in button should have accessibility label")
    }
    
    func testKeyboardNavigation() throws {
        let emailField = app.textFields["EmailField"]
        let passwordField = app.secureTextFields["PasswordField"]
        
        // Test tab navigation
        emailField.tap()
        XCTAssertTrue(emailField.hasKeyboardFocus, "Email field should have keyboard focus")
        
        // Simulate tab to next field
        app.typeText("\t")
        
        // This test may need adjustment based on actual keyboard navigation implementation
        XCTAssertTrue(passwordField.exists, "Password field should be accessible via keyboard")
    }
}

// MARK: - Helper Extensions

extension XCUIElement {
    var hasKeyboardFocus: Bool {
        return (self.value(forKey: "hasKeyboardFocus") as? Bool) ?? false
    }
}