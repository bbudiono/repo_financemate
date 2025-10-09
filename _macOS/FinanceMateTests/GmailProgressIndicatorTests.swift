import XCTest
import SwiftUI
@testable import FinanceMate

final class GmailProgressIndicatorTests: XCTestCase {

    var viewModel: GmailViewModel!

    override func setUp() {
        super.setUp()
        viewModel = GmailViewModel(context: PersistenceController.preview.container.viewContext)
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    // MARK: - RED PHASE TESTS: Progress Indicators

    func testProgressIndicator_WhenLoading_ShowsLoadingSpinner() {
        // Given
        viewModel.isLoading = true

        // When
        let view = GmailReceiptsTableView(viewModel: viewModel)

        // Then - This test should FAIL initially as loading spinner doesn't exist in table view
        let viewInspector = ViewInspector.host(view)

        // Verify loading spinner is present
        XCTAssertTrue(viewInspector.contains { view in
            // Check for loading spinner
            String(describing: view).contains("ProgressView") ||
            String(describing: view).contains("ActivityView") ||
            String(describing: view).contains("spinner") ||
            String(describing: view).contains("loading")
        }, "Should show loading spinner when isLoading is true")
    }

    func testProgressIndicator_WhenFiltering_ShowsFilteringProgress() {
        // Given
        viewModel.searchText = "test search" // Trigger filtering

        // When
        let view = GmailReceiptsTableView(viewModel: viewModel)

        // Then - This test should FAIL initially as filtering progress indicator doesn't exist
        let viewInspector = ViewInspector.host(view)

        // Verify filtering progress indicator is present
        XCTAssertTrue(viewInspector.contains { view in
            // Check for filtering progress
            String(describing: view).contains("filtering") ||
            String(describing: view).contains("searching") ||
            String(describing: view).contains("progress")
        }, "Should show filtering progress when searching")
    }

    func testProgressIndicator_WhenProcessingTransactions_ShowsProcessingState() {
        // Given
        let transaction = ExtractedTransaction(
            id: "test-7",
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
        viewModel.extractedTransactions = [transaction]

        // When
        let view = GmailTableRow(
            transaction: transaction,
            viewModel: viewModel,
            expandedID: .constant(nil)
        )

        // Then - This test should FAIL initially as processing state indicator doesn't exist
        let viewInspector = ViewInspector.host(view)

        // Verify processing state indicator for import actions
        XCTAssertTrue(viewInspector.contains { view in
            // Check for processing state indicators
            String(describing: view).contains("processing") ||
            String(describing: view).contains("importing") ||
            String(describing: view).contains("inProgress")
        }, "Should show processing state when importing transactions")
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