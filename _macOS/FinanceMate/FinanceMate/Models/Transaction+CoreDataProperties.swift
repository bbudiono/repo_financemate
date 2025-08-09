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
        // Enhanced error handling with model debugging
        guard let entity = NSEntityDescription.entity(forEntityName: "Transaction", in: context) else {
            // Debug information about available entities
            let availableEntities = context.persistentStoreCoordinator?.managedObjectModel.entities.map { $0.name ?? "unnamed" } ?? []
            print("❌ Transaction entity not found. Available entities: \(availableEntities)")
            print("❌ Context coordinator: \(String(describing: context.persistentStoreCoordinator))")
            print("❌ Model entities count: \(context.persistentStoreCoordinator?.managedObjectModel.entities.count ?? 0)")
            
            // Try to find entity with different approaches
            if let model = context.persistentStoreCoordinator?.managedObjectModel {
                print("❌ Model entity names: \(model.entities.compactMap(\.name))")
            }
            
            fatalError("Transaction entity not found in the provided context. Available entities: \(availableEntities)")
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
