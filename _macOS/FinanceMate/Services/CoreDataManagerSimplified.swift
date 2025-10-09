import Foundation
import CoreData

/// Simplified Core Data manager for transaction persistence
/// Focused on essential functionality with reduced complexity
class CoreDataManagerSimplified {
    private let viewContext: NSManagedObjectContext
    private let transactionBuilder: TransactionBuilder

    init(context: NSManagedObjectContext? = nil) {
        // Use provided context or create from persistence controller
        if let context = context {
            self.viewContext = context
        } else {
            let persistenceController = PersistenceController.shared
            self.viewContext = persistenceController.container.viewContext
        }
        self.transactionBuilder = TransactionBuilder(context: self.viewContext)
    }

    /// Save extracted transaction to Core Data
    /// - Parameter extractedTransaction: Extracted transaction to save
    /// - Returns: True if saved successfully, false otherwise
    /// - Throws: CoreDataError on save failure
    func saveTransaction(_ extractedTransaction: ExtractedTransaction) async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            viewContext.perform {
                do {
                    let transaction = self.transactionBuilder.createTransaction(from: extractedTransaction)
                    let success = transaction != nil
                    if success {
                        try self.viewContext.save()
                    }
                    continuation.resume(returning: success)
                } catch {
                    continuation.resume(throwing: CoreDataError.saveFailed(error))
                }
            }
        }
    }

    /// Get all transactions from Core Data
    /// - Returns: Array of Transaction objects
    /// - Throws: CoreDataError on fetch failure
    func getAllTransactions() async throws -> [Transaction] {
        return try await withCheckedThrowingContinuation { continuation in
            viewContext.perform {
                do {
                    let request = NSFetchRequest<Transaction>(entityName: "Transaction")
                    let transactions = try self.viewContext.fetch(request)
                    continuation.resume(returning: transactions)
                } catch {
                    continuation.resume(throwing: CoreDataError.fetchFailed(error))
                }
            }
        }
    }

    /// Get transactions filtered by date range
    /// - Parameters:
    ///   - startDate: Start date for filtering
    ///   - endDate: End date for filtering
    /// - Returns: Array of Transaction objects within date range
    /// - Throws: CoreDataError on fetch failure
    func getTransactions(from startDate: Date, to endDate: Date) async throws -> [Transaction] {
        return try await withCheckedThrowingContinuation { continuation in
            viewContext.perform {
                do {
                    let request = NSFetchRequest<Transaction>(entityName: "Transaction")
                    request.predicate = NSPredicate(format: "date >= %@ AND date <= %@", startDate as NSDate, endDate as NSDate)
                    request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
                    let transactions = try self.viewContext.fetch(request)
                    continuation.resume(returning: transactions)
                } catch {
                    continuation.resume(throwing: CoreDataError.fetchFailed(error))
                }
            }
        }
    }

    /// Delete transaction from Core Data
    /// - Parameter transaction: Transaction to delete
    /// - Returns: True if deleted successfully, false otherwise
    /// - Throws: CoreDataError on delete failure
    func deleteTransaction(_ transaction: Transaction) async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            viewContext.perform {
                do {
                    self.viewContext.delete(transaction)
                    try self.viewContext.save()
                    continuation.resume(returning: true)
                } catch {
                    continuation.resume(throwing: CoreDataError.deleteFailed(error))
                }
            }
        }
    }
}

// MARK: - Supporting Types

enum CoreDataError: Error, LocalizedError {
    case saveFailed(Error)
    case fetchFailed(Error)
    case deleteFailed(Error)
    case contextUnavailable

    var errorDescription: String? {
        switch self {
        case .saveFailed(let error):
            return "Failed to save Core Data: \(error.localizedDescription)"
        case .fetchFailed(let error):
            return "Failed to fetch Core Data: \(error.localizedDescription)"
        case .deleteFailed(let error):
            return "Failed to delete from Core Data: \(error.localizedDescription)"
        case .contextUnavailable:
            return "Core Data context is not available"
        }
    }
}