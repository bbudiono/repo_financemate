import XCTest

final class SimpleValidationTests: XCTestCase {

    func testBasicMath() {
        XCTAssertEqual(2 + 2, 4, "Basic math should work")
    }

    func testStringOperations() {
        let text = "FinanceMate"
        XCTAssertFalse(text.isEmpty, "Text should not be empty")
        XCTAssertEqual(text.count, 10, "Text should have correct length")
    }

    func testArrayOperations() {
        let numbers = [1, 2, 3, 4, 5]
        XCTAssertEqual(numbers.count, 5, "Array should have 5 elements")
        XCTAssertTrue(numbers.contains(3), "Array should contain 3")
    }
}