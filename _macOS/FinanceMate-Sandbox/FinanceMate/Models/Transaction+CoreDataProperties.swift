import CoreData
import Foundation

extension Transaction {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Transaction> {
        return NSFetchRequest<Transaction>(entityName: "Transaction")
    }

    static func create(
        in context: NSManagedObjectContext,
        amount: Double,
        category: String,
        note: String? = nil
    ) -> Transaction {
        let transaction = Transaction(context: context)
        transaction.id = UUID()
        transaction.date = Date()
        transaction.createdAt = Date()
        transaction.amount = amount
        transaction.category = category
        transaction.note = note
        return transaction
    }
}
