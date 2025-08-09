import CoreData
import Foundation

extension Transaction {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Transaction> {
        return NSFetchRequest<Transaction>(entityName: "Transaction")
    }
    
    // Sandbox-local factory helper to ensure the Sandbox target builds independently.
    // Matches the signature used by Sandbox view models.
    static func create(
        in context: NSManagedObjectContext,
        amount: Double,
        category: String,
        note: String? = nil,
        date: Date = Date(),
        type: String = "expense"
    ) -> Transaction {
        guard let entity = NSEntityDescription.entity(forEntityName: "Transaction", in: context) else {
            fatalError("Transaction entity not found in context (Sandbox)")
        }
        let transaction = Transaction(entity: entity, insertInto: context)
        // Core defaults are set in awakeFromInsert(); override explicit fields here
        transaction.amount = amount
        transaction.category = category
        transaction.note = note
        transaction.date = date
        transaction.setValue(type, forKey: "type")
        return transaction
    }
}
