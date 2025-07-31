import CoreData
import Foundation

extension Transaction {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Transaction> {
        return NSFetchRequest<Transaction>(entityName: "Transaction")
    }
    
    // Note: Removed entity() method to avoid context conflicts in testing.
    // Using NSFetchRequest<Transaction>(entityName: "Transaction") directly instead.

    static func create(
        in context: NSManagedObjectContext,
        amount: Double,
        category: String,
        note: String? = nil,
        entityId: UUID = UUID() // Default entity ID for backward compatibility
    ) -> Transaction {
        // Create entity description directly from context to avoid conflicts
        guard let entity = NSEntityDescription.entity(forEntityName: "Transaction", in: context) else {
            fatalError("Transaction entity not found in the provided context")
        }
        
        let transaction = Transaction(entity: entity, insertInto: context)
        transaction.id = UUID()
        transaction.date = Date()
        transaction.createdAt = Date()
        transaction.amount = amount
        transaction.category = category
        transaction.note = note
        transaction.entityId = entityId // Set required entityId property
        transaction.type = "Standard" // Set default transaction type
        return transaction
    }
}
