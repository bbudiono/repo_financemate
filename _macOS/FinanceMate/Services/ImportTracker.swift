import Foundation
import CoreData

/// Service for tracking imported Gmail transactions
/// Prevents duplicate imports by checking Core Data for existing sourceEmailID
class ImportTracker {
    private let viewContext: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.viewContext = context
    }

    /// Check if an email has already been imported as a transaction
    /// - Parameter emailID: The unique email identifier (sourceEmailID)
    /// - Returns: True if a transaction with this email ID exists
    func isAlreadyImported(_ emailID: String) -> Bool {
        let request = NSFetchRequest<Transaction>(entityName: "Transaction")
        request.predicate = NSPredicate(format: "sourceEmailID == %@", emailID)
        return (try? viewContext.count(for: request)) ?? 0 > 0
    }

    /// Filter out already-imported transactions from a list
    /// - Parameter transactions: Array of extracted transactions
    /// - Returns: Only unprocessed transactions
    func filterUnprocessed(_ transactions: [ExtractedTransaction]) -> [ExtractedTransaction] {
        return transactions.filter { !isAlreadyImported($0.id) }
    }
}
