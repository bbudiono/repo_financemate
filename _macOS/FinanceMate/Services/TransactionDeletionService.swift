import Foundation
import CoreData

// Service for safely deleting transactions with proper Core Data management
struct TransactionDeletionService {

    // Safely delete a transaction with all its relationships
    static func deleteTransaction(_ transaction: Transaction, in context: NSManagedObjectContext) {
        context.perform {
            // Delete associated line items first
            deleteLineItems(for: transaction, in: context)

            // Delete the transaction
            context.delete(transaction)

            // Save changes
            do {
                try context.save()
            } catch {
                print("Failed to delete transaction: \(error)")
            }
        }
    }

    // Delete multiple transactions at specified index set
    static func deleteTransactions(at indices: IndexSet, from transactions: [Transaction], in context: NSManagedObjectContext) {
        for index in indices {
            if index < transactions.count {
                deleteTransaction(transactions[index], in: context)
            }
        }
    }

    // Helper method to delete associated line items
    private static func deleteLineItems(for transaction: Transaction, in context: NSManagedObjectContext) {
        guard let lineItems = transaction.lineItems?.allObjects as? [LineItem] else { return }

        // Also delete any split allocations for line items
        for lineItem in lineItems {
            deleteSplitAllocations(for: lineItem, in: context)
            context.delete(lineItem)
        }
    }

    // Helper method to delete split allocations
    private static func deleteSplitAllocations(for lineItem: LineItem, in context: NSManagedObjectContext) {
        guard let splitAllocations = lineItem.splitAllocations?.allObjects as? [SplitAllocation] else { return }

        for splitAllocation in splitAllocations {
            context.delete(splitAllocation)
        }
    }
}