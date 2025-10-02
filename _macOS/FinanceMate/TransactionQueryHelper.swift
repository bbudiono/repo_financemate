import Foundation
import CoreData
import os.log

/// Simple Core Data query helper for chatbot financial data access
struct TransactionQueryHelper {

    private static let logger = Logger(subsystem: "FinanceMate", category: "TransactionQueryHelper")

    // MARK: - Balance Queries

    /// Get total balance from all transactions
    static func getTotalBalance(context: NSManagedObjectContext) -> Double {
        logger.debug("Balance query started")
        let request = NSFetchRequest<Transaction>(entityName: "Transaction")

        do {
            let transactions = try context.fetch(request)
            let balance = transactions.reduce(0.0) { $0 + $1.amount }
            logger.debug("Balance query complete: $\(balance) across \(transactions.count) transactions")
            return balance
        } catch {
            logger.error("Balance query failed: \(error.localizedDescription)")
            return 0.0
        }
    }

    // MARK: - Count Queries

    /// Get total transaction count
    static func getTransactionCount(context: NSManagedObjectContext) -> Int {
        let request = NSFetchRequest<Transaction>(entityName: "Transaction")

        do {
            let count = try context.count(for: request)
            logger.debug("Transaction count: \(count)")
            return count
        } catch {
            logger.error("Count query failed: \(error.localizedDescription)")
            return 0
        }
    }

    // MARK: - Transaction Retrieval

    /// Get recent transactions (default: last 5)
    static func getRecentTransactions(context: NSManagedObjectContext, limit: Int = 5) -> [Transaction] {
        logger.debug("Fetching recent \(limit) transactions")
        let request = NSFetchRequest<Transaction>(entityName: "Transaction")
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        request.fetchLimit = limit

        do {
            let transactions = try context.fetch(request)
            logger.debug("Recent transactions: returned \(transactions.count)")
            return transactions
        } catch {
            logger.error("Recent transactions query failed: \(error.localizedDescription)")
            return []
        }
    }

    // MARK: - Category Analysis

    /// Get total spending for a specific category
    static func getCategorySpending(context: NSManagedObjectContext, category: String) -> Double {
        logger.debug("Category spending query: \(category)")
        let request = NSFetchRequest<Transaction>(entityName: "Transaction")
        request.predicate = NSPredicate(format: "category == %@", category)

        do {
            let transactions = try context.fetch(request)
            let spending = transactions.reduce(0.0) { $0 + abs($1.amount) }
            logger.debug("Category \(category): $\(spending) across \(transactions.count) transactions")
            return spending
        } catch {
            logger.error("Category spending failed for \(category): \(error.localizedDescription)")
            return 0.0
        }
    }
}

