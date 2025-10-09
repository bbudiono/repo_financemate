import XCTest
import SwiftUI
@testable import FinanceMate

final class GmailStatusIndicatorTests: XCTestCase {

    var viewModel: GmailViewModel!

    override func setUp() {
        super.setUp()
        viewModel = GmailViewModel(context: PersistenceController.preview.container.viewContext)
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    // MARK: - RED PHASE TESTS: Status Indicators

    func testStatusIndicator_ForNeedsReviewStatus_ShowsProcessingIndicator() {
        // Given
        let transaction = ExtractedTransaction(
            id: "test-1",
            merchant: "Test Store",
            amount: 25.50,
            date: Date(),
            category: "Shopping",
            items: [],
            confidence: 0.85,
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

        // Then - This test should FAIL initially as status indicator doesn't exist
        let viewInspector = ViewInspector.host(view)

        // Verify processing indicator exists for needsReview status
        XCTAssertTrue(viewInspector.contains { view in
            // Check for processing indicator (spinner or loading state)
            String(describing: view).contains("processing") ||
            String(describing: view).contains("spinner") ||
            String(describing: view).contains("loading")
        }, "Should show processing indicator for needsReview status")
    }

    func testStatusIndicator_ForTransactionCreatedStatus_ShowsCompletedIndicator() {
        // Given
        let transaction = ExtractedTransaction(
            id: "test-2",
            merchant: "Test Store",
            amount: 25.50,
            date: Date(),
            category: "Shopping",
            items: [],
            confidence: 0.85,
            rawText: "Test receipt",
            emailSubject: "Your receipt",
            emailSender: "store@test.com",
            status: .transactionCreated
        )

        // When
        let view = GmailTableRow(
            transaction: transaction,
            viewModel: viewModel,
            expandedID: .constant(nil)
        )

        // Then - This test should FAIL initially as completed indicator doesn't exist
        let viewInspector = ViewInspector.host(view)

        // Verify completed indicator exists for transactionCreated status
        XCTAssertTrue(viewInspector.contains { view in
            // Check for completed indicator (checkmark or success state)
            String(describing: view).contains("completed") ||
            String(describing: view).contains("success") ||
            String(describing: view).contains("checkmark")
        }, "Should show completed indicator for transactionCreated status")
    }

    func testStatusIndicator_ForArchivedStatus_ShowsArchivedIndicator() {
        // Given
        let transaction = ExtractedTransaction(
            id: "test-3",
            merchant: "Test Store",
            amount: 25.50,
            date: Date(),
            category: "Shopping",
            items: [],
            confidence: 0.85,
            rawText: "Test receipt",
            emailSubject: "Your receipt",
            emailSender: "store@test.com",
            status: .archived
        )

        // When
        let view = GmailTableRow(
            transaction: transaction,
            viewModel: viewModel,
            expandedID: .constant(nil)
        )

        // Then - This test should FAIL initially as archived indicator doesn't exist
        let viewInspector = ViewInspector.host(view)

        // Verify archived indicator exists for archived status
        XCTAssertTrue(viewInspector.contains { view in
            // Check for archived indicator (archive icon or muted state)
            String(describing: view).contains("archived") ||
            String(describing: view).contains("archive") ||
            String(describing: view).contains("muted")
        }, "Should show archived indicator for archived status")
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