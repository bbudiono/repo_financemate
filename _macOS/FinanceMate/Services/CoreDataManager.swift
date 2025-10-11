import Foundation
import CoreData

/// Minimal Core Data manager focused on essential functionality
/// Simplified to meet complexity requirements (<75 complexity score)
class CoreDataManager {
    private let viewContext: NSManagedObjectContext

    init(context: NSManagedObjectContext? = nil) {
        self.viewContext = context ?? PersistenceController.shared.container.viewContext
    }

    /// Save transaction to Core Data
    /// - Parameters:
    ///   - extractedTransaction: Extracted transaction to save
    ///   - emailSnippet: Email snippet for content hash (BLUEPRINT Line 151)
    func saveTransaction(_ extractedTransaction: ExtractedTransaction, emailSnippet: String? = nil) async throws -> Bool {
        let transaction = TransactionBuilder(context: viewContext).createTransaction(
            from: extractedTransaction,
            emailSnippet: emailSnippet
        )
        guard transaction != nil else { return false }

        do {
            try viewContext.save()
            return true
        } catch {
            throw CoreDataError.saveFailed(error)
        }
    }

    /// Get all transactions
    func getAllTransactions() async throws -> [Transaction] {
        let request = NSFetchRequest<Transaction>(entityName: "Transaction")
        return try viewContext.fetch(request)
    }

    /// Get transactions by date range
    func getTransactions(from startDate: Date, to endDate: Date) async throws -> [Transaction] {
        let request = NSFetchRequest<Transaction>(entityName: "Transaction")
        request.predicate = NSPredicate(format: "date >= %@ AND date <= %@", startDate as NSDate, endDate as NSDate)
        return try viewContext.fetch(request)
    }

    /// Save multiple transactions
    /// - Parameter transactions: Array of extracted transactions
    /// - Returns: Number of successfully saved transactions
    func saveTransactions(_ transactions: [ExtractedTransaction]) async throws -> Int {
        var savedCount = 0
        for extractedTransaction in transactions {
            if try await saveTransaction(extractedTransaction) {
                savedCount += 1
            }
        }
        return savedCount
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
            return "Save failed: \(error.localizedDescription)"
        case .fetchFailed(let error):
            return "Fetch failed: \(error.localizedDescription)"
        case .deleteFailed(let error):
            return "Delete failed: \(error.localizedDescription)"
        case .contextUnavailable:
            return "Context unavailable"
        }
    }
}