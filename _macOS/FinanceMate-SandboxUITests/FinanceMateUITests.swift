import XCTest

final class FinanceMateUITests: XCTestCase {
    
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        
        // Configure app for headless testing
        app.launchArguments = ["--uitesting", "--headless"]
        app.launchEnvironment["UI_TESTING"] = "1"
        app.launchEnvironment["HEADLESS_MODE"] = "1"
        
        app.launch()
        
        // Wait for app to be ready
        let appReadyExpectation = expectation(description: "App launch complete")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            appReadyExpectation.fulfill()
        }
        wait(for: [appReadyExpectation], timeout: 10.0)
    }
    
    override func tearDownWithError() throws {
        app?.terminate()
        app = nil
    }

    func testAppLaunchesSuccessfully() throws {
        // Test that the app launches without crashing
        XCTAssertTrue(app.exists, "Application should launch successfully")
        
        // Test that main UI elements are present
        let hasValidUI = app.windows.count > 0 || 
                        app.staticTexts.count > 0 || 
                        app.buttons.count > 0
        
        XCTAssertTrue(hasValidUI, "Application should have valid UI elements")
    }
    
    func testMainWindowExists() throws {
        // Wait for window to appear
        let windowExpectation = expectation(description: "Main window appears")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if self.app.windows.count > 0 {
                windowExpectation.fulfill()
            }
        }
        
        wait(for: [windowExpectation], timeout: 5.0)
        
        XCTAssertTrue(app.windows.count > 0, "Main window should be present")
    }
} 