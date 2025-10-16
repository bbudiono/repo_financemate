import XCTest
@testable import FinanceMate
import CoreData

/// PHASE 2: INLINE EDITING PERSISTENCE - RED (Part 1)
/// Tests missing TransactionFieldEditor Core Data integration and field persistence
final class InlineEditingCoreDataTests: XCTestCase {

    func testTransactionFieldEditor_UpdatesCoreDataField_PersistsAcrossContexts() async throws {
        // This test should FAIL because TransactionFieldEditor doesn't properly persist
        // field updates that survive across Core Data context refreshes

        let context = PersistenceController.shared.container.viewContext

        // Create a test transaction
        let transactionId = "test-transaction-\(UUID().uuidString)"
        let originalMerchant = "Original Merchant"

        // Create transaction in Core Data
        try createTestTransaction(id: transactionId, merchant: originalMerchant, context: context)

        // Update field using TransactionFieldEditor
        let newMerchant = "Updated Merchant Name"
        try TransactionFieldEditor.updateTransactionField(
            transactionId: transactionId,
            fieldType: "merchant",
            newValue: newMerchant,
            context: context
        )

        // Verify update persisted by refreshing context
        context.reset()

        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Transaction")
        fetchRequest.predicate = NSPredicate(format: "id == %@", UUID(uuidString: transactionId)! as CVarArg)
        fetchRequest.fetchLimit = 1

        let result = try context.fetch(fetchRequest)
        guard let transaction = result.first as? Transaction else {
            XCTFail("Transaction not found after update")
            return
        }

        let persistedMerchant = transaction.itemDescription
        XCTAssertEqual(persistedMerchant, newMerchant, "Field update should persist across context refresh")
    }

    func testTransactionFieldEditor_HandlesInvalidTransactionId_ThrowsError() async throws {
        // This test should FAIL because error handling for non-existent transactions
        // is not properly implemented and tested

        let context = PersistenceController.shared.container.viewContext

        let invalidTransactionId = "non-existent-transaction-id"

        // Should throw error for invalid transaction ID
        XCTAssertThrowsError(try TransactionFieldEditor.updateTransactionField(
            transactionId: invalidTransactionId,
            fieldType: "merchant",
            newValue: "Test",
            context: context
        ), "Should throw error for non-existent transaction")

        do {
            try TransactionFieldEditor.updateTransactionField(
                transactionId: invalidTransactionId,
                fieldType: "merchant",
                newValue: "Test",
                context: context
            )
            XCTFail("Expected error to be thrown")
        } catch FieldEditorError.transactionNotFound(let id) {
            XCTAssertEqual(id, invalidTransactionId, "Error should contain correct transaction ID")
        } catch {
            XCTFail("Expected FieldEditorError.transactionNotFound, got \(error)")
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