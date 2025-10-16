import XCTest
@testable import FinanceMate
import CoreData

/// PHASE 2: INLINE EDITING PERSISTENCE - RED (Part 2)
/// Tests missing ExtractionFeedback creation for audit trail tracking
final class InlineEditingFeedbackTests: XCTestCase {

    func testTransactionFieldEditor_CreatesExtractionFeedback_Record() async throws {
        // This test should FAIL because ExtractionFeedback creation is not properly verified
        // to track field edit history for audit trail

        let context = PersistenceController.shared.container.viewContext

        let transactionId = "test-transaction-\(UUID().uuidString)"
        try createTestTransaction(id: transactionId, merchant: "Test Merchant", context: context)

        // Update field
        try TransactionFieldEditor.updateTransactionField(
            transactionId: transactionId,
            fieldType: "amount",
            newValue: "99.99",
            context: context
        )

        // Verify ExtractionFeedback record was created
        let feedbackRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "ExtractionFeedback")
        feedbackRequest.predicate = NSPredicate(format: "emailID == %@ AND extractionTier == %@", transactionId, "field_edit")

        let feedbackResults = try context.fetch(feedbackRequest)
        XCTAssertGreaterThan(feedbackResults.count, 0, "Should create ExtractionFeedback record for field edit")

        if let feedback = feedbackResults.first as? ExtractionFeedback {
            XCTAssertEqual(feedback.fieldName, "amount", "Feedback should document field name")
            XCTAssertEqual(feedback.correctedValue, "99.99", "Feedback should contain new value")
        }
    }

    // MARK: - Helper Methods

    private func createTestTransaction(
        id: String,
        merchant: String,
        amount: String = "10.00",
        category: String = "Test",
        context: NSManagedObjectContext
    ) throws {
        let transaction = Transaction(context: context)
        transaction.id = UUID(uuidString: id) ?? UUID()
        transaction.itemDescription = merchant
        transaction.amount = Double(amount) ?? 10.0
        transaction.category = category
        transaction.date = Date()
        transaction.source = "test"
        transaction.transactionType = "expense"

        try context.save()
    }
}