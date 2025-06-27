import XCTest
import Foundation

// Import the app module
@testable import FinanceMate

// Create a simple test runner
class TestRunner {
    static func main() {
        print("🧪 Running E2E Tests...")
        
        // Initialize the test suite
        let testSuite = XCTestSuite(name: "E2E Tests")
        
        // Add authentication tests
        let authTests = AuthenticationE2ETests.defaultTestSuite
        testSuite.addTest(authTests)
        
        // Run the tests
        let testRun = testSuite.run()
        
        // Report results
        print("\n📊 Test Results:")
        print("================")
        print("Total tests: \(testRun.totalTestCount)")
        print("Passed: \(testRun.testCaseCount - testRun.totalFailureCount)")
        print("Failed: \(testRun.totalFailureCount)")
        
        if testRun.totalFailureCount > 0 {
            print("\n❌ TESTS FAILED")
            exit(1)
        } else {
            print("\n✅ ALL TESTS PASSED")
            
            // Check for screenshots
            let fileManager = FileManager.default
            let artifactsPath = "\(NSHomeDirectory())/Documents/test_artifacts"
            
            if let contents = try? fileManager.contentsOfDirectory(atPath: artifactsPath) {
                print("\n📸 Screenshots captured:")
                for file in contents {
                    print("  - \(file)")
                }
            }
            
            exit(0)
        }
    }
}

// Include the test files content
import XCTest

class AuthenticationE2ETests: XCTestCase {
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launch()
    }
    
    func testSuccessfulLoginJourney() throws {
        let app = XCUIApplication()
        
        // This monitor will handle the "Sign In with Apple" system dialog
        let interruptionMonitor = addUIInterruptionMonitor(withDescription: "Apple Sign-In") { (alert) -> Bool in
            // IMPORTANT: Use the alert to find the "Continue" or "Continue with Password" button
            // The exact button name can vary.
            let continueButton = alert.buttons.element(boundBy: 0) // A common but fragile way
            if continueButton.exists {
                continueButton.tap()
                return true // We handled the alert
            }
            
            // Fallback for different OS versions if the first method fails
            let continueWithPasswordButton = alert.buttons["Continue with Password"]
            if continueWithPasswordButton.exists {
                continueWithPasswordButton.tap()
                // You might need to handle a password field here as well
                return true
            }
            
            XCTFail("Could not handle Apple Sign-In dialog.")
            return false // We did not handle the alert
        }
        
        // Wait for the welcome screen to appear
        let welcomeText = app.staticTexts["Welcome to FinanceMate"]
        XCTAssertTrue(welcomeText.waitForExistence(timeout: 5.0), "Welcome screen did not appear")
        
        // Screenshot 1: Welcome/Login screen
        _ = ScreenshotService.capture(name: "E2E_Auth_WelcomeScreen", in: self)
        
        // Click Sign In with Apple button
        let signInButton = app.buttons["Sign In with Apple"]
        XCTAssertTrue(signInButton.exists, "Sign In button not found")
        signInButton.tap()
        
        // IMPORTANT: Tapping the app again is sometimes needed to make the interruption handler fire.
        // This is a quirk of XCUITest.
        app.tap()

        // Wait for dashboard to appear AFTER the interruption is handled
        let dashboardButton = app.buttons["Dashboard"]
        XCTAssertTrue(dashboardButton.waitForExistence(timeout: 15.0), "Dashboard did not appear after login. The interruption was likely not handled correctly.")
        
        // Screenshot 2: Main dashboard after successful authentication
        _ = ScreenshotService.capture(name: "E2E_Auth_Success_Dashboard", in: self)
        
        // Verify we can see main navigation items
        XCTAssertTrue(app.buttons["Documents"].exists, "Documents navigation not found")
        XCTAssertTrue(app.buttons["Analytics"].exists, "Analytics navigation not found")
        XCTAssertTrue(app.buttons["Settings"].exists, "Settings navigation not found")

        // It's critical to remove the monitor once done
        removeUIInterruptionMonitor(interruptionMonitor)
    }
    
    func testGoogleSignInJourney() throws {
        let app = XCUIApplication()
        
        // Wait for welcome screen
        let welcomeText = app.staticTexts["Welcome to FinanceMate"]
        XCTAssertTrue(welcomeText.waitForExistence(timeout: 5.0), "Welcome screen did not appear")
        
        // Note: Current ContentView only shows "Sign In with Apple" button
        // Google Sign In would be in a separate SignInView if implemented
        // For now, we'll verify that only Apple Sign In is available
        
        let appleSignInButton = app.buttons["Sign In with Apple"]
        XCTAssertTrue(appleSignInButton.exists, "Apple Sign In button not found")
        
        // Verify Google Sign In is NOT present in the current UI
        let googleSignInButton = app.buttons["Sign In with Google"]
        XCTAssertFalse(googleSignInButton.exists, "Google Sign In should not be present in ContentView")
        
        // Alternative: Look for any button containing "Google"
        let googleButtons = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] 'google'"))
        XCTAssertEqual(googleButtons.count, 0, "No Google sign in options should be present")
        
        // Screenshot: Current authentication options
        _ = ScreenshotService.capture(name: "E2E_Auth_AvailableOptions", in: self)
    }
}

struct ScreenshotService {
    @discardableResult
    static func capture(name: String, in testCase: XCTestCase) -> String? {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        testCase.add(attachment)
        
        // --- For CI/CD Artifacts ---
        // This part saves the screenshot to a file for external collection.
        let fileManager = FileManager.default
        // Assuming the derived data path for test artifacts. This might need adjustment.
        // A more robust solution involves passing an output directory via environment variables.
        let artifactsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            .appendingPathComponent("test_artifacts")

        do {
            try fileManager.createDirectory(at: artifactsDirectory, withIntermediateDirectories: true, attributes: nil)
            let screenshotURL = artifactsDirectory.appendingPathComponent("\(name).png")
            try screenshot.pngRepresentation.write(to: screenshotURL)
            print("📸 Screenshot saved to: \(screenshotURL.path)")
            return screenshotURL.path
        } catch {
            XCTFail("Failed to save screenshot: \(error.localizedDescription)")
            return nil
        }
    }
}TestRunner.main()
