import CoreData
import Foundation

/*
 * Purpose: Transaction Core Data fetch requests and queries (I-Q-I Protocol Supporting Module)
 * Issues & Complexity Summary: Optimized Core Data queries for transaction retrieval
 * Key Complexity Drivers:
   - Logic Scope (Est. LoC): ~85 (focused query responsibility)
   - Core Algorithm Complexity: Medium (Core Data predicates, sorting, filtering)
   - Dependencies: 3 (CoreData, Foundation, Transaction model)
   - State Management Complexity: Low (stateless query methods)
   - Novelty/Uncertainty Factor: Low (established Core Data patterns)
 * AI Pre-Task Self-Assessment: 95% (well-understood Core Data query patterns)
 * Problem Estimate: 68%
 * Initial Code Complexity Estimate: 65%
 * I-Q-I Quality Target: 8+/10 - Professional enterprise standards with optimized queries
 * Final Code Complexity: [TBD - Post I-Q-I evaluation]
 * Overall Result Score: [TBD - I-Q-I assessment pending]
 * Key Variances/Learnings: [TBD - I-Q-I optimization insights]
 * Last Updated: 2025-08-04
 */

/// Transaction Core Data queries and fetch requests with Australian financial software standards
/// Responsibilities: Optimized queries, efficient filtering, professional sorting
/// I-Q-I Supporting Module: Core Data operations with performance optimization
extension Transaction {
    
    // MARK: - Core Data Fetch Requests (Optimized Queries)
    
    /// Fetch transactions by category for analysis
    /// - Parameters:
    ///   - category: Category to filter by
    ///   - context: NSManagedObjectContext for query execution
    /// - Returns: Array of transactions in the specified category
    /// - Quality: Efficient category-based queries for financial analysis
    public class func fetchTransactions(
        byCategory category: String,
        in context: NSManagedObjectContext
    ) throws -> [Transaction] {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "category == %@", category)
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Transaction.date, ascending: false)
        ]
        return try context.fetch(request)
    }
    
    /// Fetch transactions by type (income, expense, transfer)
    /// - Parameters:
    ///   - type: Transaction type to filter by
    ///   - context: NSManagedObjectContext for query execution
    /// - Returns: Array of transactions of the specified type
    /// - Quality: Efficient type-based queries for transaction analysis
    public class func fetchTransactions(
        byType type: String,
        in context: NSManagedObjectContext
    ) throws -> [Transaction] {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "type == %@", type.lowercased())
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Transaction.date, ascending: false)
        ]
        return try context.fetch(request)
    }
    
    /// Fetch recent transactions for dashboard display
    /// - Parameters:
    ///   - limit: Maximum number of transactions to return
    ///   - context: NSManagedObjectContext for query execution
    /// - Returns: Array of recent transactions
    /// - Quality: Efficient query for dashboard and summary displays
    public class func fetchRecentTransactions(
        limit: Int = 10,
        in context: NSManagedObjectContext
    ) throws -> [Transaction] {
        let request = fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Transaction.date, ascending: false)
        ]
        request.fetchLimit = limit
        return try context.fetch(request)
    }
    
    /// Fetch transactions within date range for reporting
    /// - Parameters:
    ///   - fromDate: Start date for range
    ///   - toDate: End date for range
    ///   - context: NSManagedObjectContext for query execution
    /// - Returns: Array of transactions within date range
    /// - Quality: Date-based queries for period reporting
    public class func fetchTransactions(
        from fromDate: Date,
        to toDate: Date,
        in context: NSManagedObjectContext
    ) throws -> [Transaction] {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@ AND date <= %@", fromDate as NSDate, toDate as NSDate)
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Transaction.date, ascending: false)
        ]
        return try context.fetch(request)
    }
    
    /// Fetch transactions for a specific financial entity
    /// - Parameters:
    ///   - entity: FinancialEntity to filter by
    ///   - context: NSManagedObjectContext for query execution
    /// - Returns: Array of transactions for the specified entity
    /// - Quality: Entity-based queries for account-specific analysis
    public class func fetchTransactions(
        for entity: FinancialEntity,
        in context: NSManagedObjectContext
    ) throws -> [Transaction] {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "assignedEntity == %@", entity)
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Transaction.date, ascending: false)
        ]
        return try context.fetch(request)
    }
}