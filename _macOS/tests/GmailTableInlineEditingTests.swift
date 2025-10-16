import XCTest
@testable import FinanceMate

/// Test suite to verify REAL Gmail table inline editing with Core Data persistence
/// P0 VIOLATION: Current updateTransactionField() only logs to console, no persistence
final class GmailTableInlineEditingTests: XCTestCase {

    func testInlineEditPersistsToCoreData() async throws {
        // P0 VIOLATION: GmailReceiptsTableView.updateTransactionField() only logs
        // Current implementation: NSLog("[TABLE-EDIT] Updated \(fieldType) for transaction \(transaction.id): \(value)")
        // Reality: No Core Data persistence, users lose edits

        let context = PersistenceController.preview.container.viewContext
        let viewModel = GmailViewModel(context: context)
        let tableView = GmailReceiptsTableView(viewModel: viewModel)

        // Create test transaction
        let testTransaction = ExtractedTransaction(
            id: "test-edit-001",
            merchant: "Original Merchant",
            amount: 100.0,
            date: Date(),
            category: "Original Category",
            items: [],
            confidence: 0.8,
            rawText: "Test transaction",
            emailSubject: "Test Receipt",
            emailSender: "test@example.com"
        )

        viewModel.extractedTransactions = [testTransaction]

        // Attempt to edit merchant field
        tableView.updateTransactionField(testTransaction, fieldType: "merchant", value: "Updated Merchant")

        // P0 VERIFICATION: Edit should persist to Core Data
        // This should fail because current implementation only logs to console
        let updatedTransaction = viewModel.extractedTransactions.first { $0.id == testTransaction.id }
        XCTAssertEqual(updatedTransaction?.merchant, "Updated Merchant", "Edit should persist in memory")

        // P0 VERIFICATION: Edit should be saved to Core Data
        // This should fail because no Core Data persistence exists
        let fetchRequest: NSFetchRequest<TransactionEntity> = TransactionEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", testTransaction.id)
        let coreDataTransactions = try context.fetch(fetchRequest)

        XCTAssertTrue(coreDataTransactions.count > 0, "Transaction should be saved to Core Data")
        XCTAssertEqual(coreDataTransactions.first?.merchant, "Updated Merchant", "Core Data should reflect edit")
    }

    func testExtractionFeedbackCreatedOnEdit() async throws {
        // P0 VIOLATION: No ExtractionFeedback records created on edits
        // Current implementation: TODO comment on line 288: "TODO: Persist to Core Data and create ExtractionFeedback entity"
        // Reality: No audit trail, no feedback records

        let context = PersistenceController.preview.container.viewContext
        let viewModel = GmailViewModel(context: context)
        let tableView = GmailReceiptsTableView(viewModel: viewModel)

        let testTransaction = ExtractedTransaction(
            id: "test-feedback-001",
            merchant: "Test Merchant",
            amount: 50.0,
            date: Date(),
            category: "Test Category",
            items: [],
            confidence: 0.7,
            rawText: "Test",
            emailSubject: "Test",
            emailSender: "test@example.com"
        )

        viewModel.extractedTransactions = [testTransaction]

        // Edit the transaction
        tableView.updateTransactionField(testTransaction, fieldType: "category", value: "Updated Category")

        // P0 VERIFICATION: ExtractionFeedback record should be created
        // This should fail because no ExtractionFeedback creation exists
        let feedbackRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "ExtractionFeedback")
        feedbackRequest.predicate = NSPredicate(format: "emailID == %@", testTransaction.id)
        let feedbackRecords = try context.fetch(feedbackRequest)

        XCTAssertTrue(feedbackRecords.count > 0, "ExtractionFeedback record should be created on edit")
        XCTAssertEqual(feedbackRecords.first?.value(forKey: "feedbackType") as? String, "field_edit", "Should record feedback type as field edit")

        // Extract field change details from comment
        let comment = feedbackRecords.first?.value(forKey: "comment") as? String ?? ""
        XCTAssertTrue(comment.contains("category"), "Should record which field was changed")
        XCTAssertTrue(comment.contains("Test Category"), "Should record original value")
        XCTAssertTrue(comment.contains("Updated Category"), "Should record new value")
    }

    func testTableReflectsPersistedEdit() async throws {
        // P0 VIOLATION: Table doesn't refresh to show persisted changes
        // Current implementation: No UI state update after persistence
        // Reality: Users don't see their edits reflected in the table

        let context = PersistenceController.preview.container.viewContext
        let viewModel = GmailViewModel(context: context)
        let tableView = GmailReceiptsTableView(viewModel: viewModel)

        let testTransaction = ExtractedTransaction(
            id: "test-refresh-001",
            merchant: "Refresh Test",
            amount: 75.0,
            date: Date(),
            category: "Refresh Category",
            items: [],
            confidence: 0.9,
            rawText: "Test",
            emailSubject: "Test",
            emailSender: "test@example.com"
        )

        viewModel.extractedTransactions = [testTransaction]

        // Edit the amount
        tableView.updateTransactionField(testTransaction, fieldType: "amount", value: "150.00")

        // P0 VERIFICATION: Table should immediately reflect the change
        // This should fail because no UI refresh mechanism exists
        let updatedTransaction = viewModel.extractedTransactions.first { $0.id == testTransaction.id }
        XCTAssertEqual(updatedTransaction?.amount, 150.0, "Table should show updated amount immediately")

        // P0 VERIFICATION: Change should be visible in UI without manual refresh
        // This tests that the SwiftUI view updates automatically
        XCTAssertTrue(tableView.body.contains("150.00"), "UI should immediately reflect edit")
    }
}