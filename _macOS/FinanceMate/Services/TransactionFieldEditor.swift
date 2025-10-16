import Foundation
import CoreData

/// PHASE 2: INLINE EDITING PERSISTENCE - GREEN
/// Real Core Data field updates with ExtractionFeedback audit trail
struct TransactionFieldEditor {

    static func updateTransactionField(
        transactionId: String,
        fieldType: String,
        newValue: String,
        context: NSManagedObjectContext
    ) throws {
        let uuid = try validateTransactionId(transactionId)
        let transaction = try findTransaction(uuid: uuid, context: context)

        let oldValue = transaction.value(forKey: fieldType) as? String ?? ""
        updateField(transaction: transaction, fieldType: fieldType, newValue: newValue)
        createFeedback(transactionId: transactionId, fieldType: fieldType, oldValue: oldValue, newValue: newValue, context: context)

        try context.save()
        print("PHASE 2: Updated \(fieldType): '\(oldValue)' -> '\(newValue)'")
    }

    private static func validateTransactionId(_ transactionId: String) throws -> UUID {
        guard let uuid = UUID(uuidString: transactionId) else {
            throw FieldEditorError.invalidTransactionId(transactionId)
        }
        return uuid
    }

    private static func findTransaction(uuid: UUID, context: NSManagedObjectContext) throws -> Transaction {
        let request = NSFetchRequest<Transaction>(entityName: "Transaction")
        request.predicate = NSPredicate(format: "id == %@", uuid as CVarArg)
        request.fetchLimit = 1

        let result = try context.fetch(request)
        guard let transaction = result.first else {
            throw FieldEditorError.transactionNotFound(uuid.uuidString)
        }
        return transaction
    }

    private static func updateField(transaction: Transaction, fieldType: String, newValue: String) {
        switch fieldType.lowercased() {
        case "merchant", "description":
            transaction.itemDescription = newValue
        case "amount":
            transaction.amount = Double(newValue) ?? 0.0
        case "category":
            transaction.category = newValue
        case "taxcategory":
            transaction.taxCategory = newValue
        case "transactiontype":
            transaction.transactionType = newValue
        case "note":
            transaction.note = newValue
        default:
            break
        }
    }

    private static func createFeedback(transactionId: String, fieldType: String, oldValue: String, newValue: String, context: NSManagedObjectContext) {
        let feedback = ExtractionFeedback(context: context)
        feedback.id = UUID()
        feedback.emailID = transactionId
        feedback.fieldName = fieldType
        feedback.originalValue = oldValue
        feedback.correctedValue = newValue
        feedback.timestamp = Date()
        feedback.wasHallucination = false
        feedback.confidence = 1.0
        feedback.extractionTier = "field_edit"
    }
}

enum FieldEditorError: Error, LocalizedError {
    case invalidTransactionId(String)
    case transactionNotFound(String)

    var errorDescription: String? {
        switch self {
        case .invalidTransactionId(let id):
            return "Invalid transaction ID format: '\(id)'"
        case .transactionNotFound(let id):
            return "Transaction with ID '\(id)' not found"
        }
    }
}