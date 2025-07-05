import XCTest

final class FinanceMateUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testExample() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssert(app.staticTexts["FinanceMate Production"].exists)
    }
} 