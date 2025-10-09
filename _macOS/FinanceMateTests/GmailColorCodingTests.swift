import XCTest
import SwiftUI
@testable import FinanceMate

final class GmailColorCodingTests: XCTestCase {

    var viewModel: GmailViewModel!

    override func setUp() {
        super.setUp()
        viewModel = GmailViewModel(context: PersistenceController.preview.container.viewContext)
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    // MARK: - RED PHASE TESTS: Enhanced Color Coding

    func testColorCoding_HighConfidence_ShowsGreenColor() {
        // Given
        let transaction = ExtractedTransaction(
            id: "test-4",
            merchant: "Test Store",
            amount: 25.50,
            date: Date(),
            category: "Shopping",
            items: [],
            confidence: 0.95, // High confidence (80-100%)
            rawText: "Test receipt",
            emailSubject: "Your receipt",
            emailSender: "store@test.com",
            status: .needsReview
        )

        // When
        let view = GmailTableRow(
            transaction: transaction,
            viewModel: viewModel,
            expandedID: .constant(nil)
        )

        // Then - This test should FAIL initially as enhanced color coding doesn't exist
        let viewInspector = ViewInspector.host(view)

        // Verify green color for high confidence
        XCTAssertTrue(viewInspector.contains { view in
            // Check for green color indicators
            String(describing: view).contains("green") ||
            String(describing: view).contains("#00FF00") ||
            String(describing: view).contains("Color.green")
        }, "Should show green color for high confidence (80-100%)")
    }

    func testColorCoding_MediumConfidence_ShowsYellowOrangeColor() {
        // Given
        let transaction = ExtractedTransaction(
            id: "test-5",
            merchant: "Test Store",
            amount: 25.50,
            date: Date(),
            category: "Shopping",
            items: [],
            confidence: 0.65, // Medium confidence (50-79%)
            rawText: "Test receipt",
            emailSubject: "Your receipt",
            emailSender: "store@test.com",
            status: .needsReview
        )

        // When
        let view = GmailTableRow(
            transaction: transaction,
            viewModel: viewModel,
            expandedID: .constant(nil)
        )

        // Then - This test should FAIL initially as enhanced color coding doesn't exist
        let viewInspector = ViewInspector.host(view)

        // Verify yellow/orange color for medium confidence
        XCTAssertTrue(viewInspector.contains { view in
            // Check for yellow/orange color indicators
            String(describing: view).contains("yellow") ||
            String(describing: view).contains("orange") ||
            String(describing: view).contains("#FFA500") ||
            String(describing: view).contains("#FFFF00")
        }, "Should show yellow/orange color for medium confidence (50-79%)")
    }

    func testColorCoding_LowConfidence_ShowsRedColor() {
        // Given
        let transaction = ExtractedTransaction(
            id: "test-6",
            merchant: "Test Store",
            amount: 25.50,
            date: Date(),
            category: "Shopping",
            items: [],
            confidence: 0.35, // Low confidence (0-49%)
            rawText: "Test receipt",
            emailSubject: "Your receipt",
            emailSender: "store@test.com",
            status: .needsReview
        )

        // When
        let view = GmailTableRow(
            transaction: transaction,
            viewModel: viewModel,
            expandedID: .constant(nil)
        )

        // Then - This test should FAIL initially as enhanced color coding doesn't exist
        let viewInspector = ViewInspector.host(view)

        // Verify red color for low confidence
        XCTAssertTrue(viewInspector.contains { view in
            // Check for red color indicators
            String(describing: view).contains("red") ||
            String(describing: view).contains("#FF0000") ||
            String(describing: view).contains("Color.red")
        }, "Should show red color for low confidence (0-49%)")
    }
}

// MARK: - Helper Extensions

extension View {
    func host() -> Any {
        UIHostingController(rootView: self).view
    }
}

extension UIView {
    func contains(_ predicate: (UIView) -> Bool) -> Bool {
        if predicate(self) {
            return true
        }
        return subviews.contains { $0.contains(predicate) }
    }
}