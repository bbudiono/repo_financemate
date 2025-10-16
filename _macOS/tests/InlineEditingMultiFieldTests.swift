import XCTest
@testable import FinanceMate
import CoreData

/// PHASE 2: INLINE EDITING PERSISTENCE - RED (Part 3)
/// Tests missing multi-field updates and field isolation in TransactionFieldEditor
final class InlineEditingMultiFieldTests: XCTestCase {

    func testTransactionFieldEditor_MultipleFieldUpdates_AllPersistCorrectly() async throws {
        // This test should FAIL because multiple field updates in sequence
        // may not all persist correctly due to Core Data context management issues

        let context = PersistenceController.shared.container.viewContext

        let transactionId = "test-transaction-\(UUID().uuidString)"
        try createTestTransaction(id: transactionId, merchant: "Original", amount: "10.00", context: context)

        // Update multiple fields
        try TransactionFieldEditor.updateTransactionField(
            transactionId: transactionId,
            fieldType: "merchant",
            newValue: "Updated Merchant",
            context: context
        )

        try TransactionFieldEditor.updateTransactionField(
            transactionId: transactionId,
            fieldType: "amount",
            newValue: "25.50",
            context: context
        )

        try TransactionFieldEditor.updateTransactionField(
            transactionId: transactionId,
            fieldType: "category",
            newValue: "Entertainment",
            context: context
        )

        // Refresh context and verify all updates persisted
        context.reset()

        let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", UUID(uuidString: transactionId) as CVarArg)

        let result = try context.fetch(fetchRequest)
        guard let transaction = result.first else {
            XCTFail("Transaction not found after updates")
            return
        }

        XCTAssertEqual(transaction.itemDescription, "Updated Merchant")
        XCTAssertEqual(transaction.amount, 25.50)
        XCTAssertEqual(transaction.category, "Entertainment")
    }

    func testTransactionFieldEditor_PreservesOtherFields_OnlyUpdatesTarget() async throws {
        // This test should FAIL because field updates might inadvertently
        // modify or corrupt other transaction fields during the update process

        let context = PersistenceController.shared.container.viewContext

        let transactionId = "test-transaction-\(UUID().uuidString)"
        let originalMerchant = "Original Merchant"
        let originalAmount = "50.00"
        let originalCategory = "Food"

        try createTestTransaction(
            id: transactionId,
            merchant: originalMerchant,
            amount: originalAmount,
            category: originalCategory,
            context: context
        )

        // Update only merchant field
        try TransactionFieldEditor.updateTransactionField(
            transactionId: transactionId,
            fieldType: "merchant",
            newValue: "New Merchant",
            context: context
        )

        // Verify only merchant changed, other fields preserved
        let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", UUID(uuidString: transactionId) as CVarArg)

        let result = try context.fetch(fetchRequest)
        guard let transaction = result.first else {
            XCTFail("Transaction not found after update")
            return
        }

        XCTAssertEqual(transaction.itemDescription, "New Merchant", "Target field should update")
        XCTAssertEqual(transaction.amount, Double(originalAmount) ?? 0.0, "Other fields should be preserved")
        XCTAssertEqual(transaction.category, originalCategory, "Other fields should be preserved")
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