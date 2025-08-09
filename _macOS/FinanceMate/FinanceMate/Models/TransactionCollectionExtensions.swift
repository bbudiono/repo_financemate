import CoreData
import Foundation

/*
 * Purpose: Transaction collection extension utilities (I-Q-I Protocol Supporting Module)
 * Issues & Complexity Summary: Collection operations and transaction analysis utilities
 * Key Complexity Drivers:
   - Logic Scope (Est. LoC): ~95 (focused collection operation responsibility)
   - Core Algorithm Complexity: Medium (aggregation, grouping, filtering operations)
   - Dependencies: 2 (Foundation, Transaction model)
   - State Management Complexity: Low (stateless utility functions)
   - Novelty/Uncertainty Factor: Low (established collection patterns)
 * AI Pre-Task Self-Assessment: 95% (well-understood collection operations)
 * Problem Estimate: 70%
 * Initial Code Complexity Estimate: 68%
 * I-Q-I Quality Target: 8+/10 - Professional enterprise standards with Australian financial context
 * Final Code Complexity: [TBD - Post I-Q-I evaluation]
 * Overall Result Score: [TBD - I-Q-I assessment pending]
 * Key Variances/Learnings: [TBD - I-Q-I optimization insights]
 * Last Updated: 2025-08-04
 */

// MARK: - Extensions for Collection Operations (Professional Transaction Analysis)

extension Collection where Element == Transaction {
    
    /// Calculate total transaction amount across all transactions
    /// - Returns: Sum of all transaction amounts with precision
    /// - Quality: Professional transaction aggregation
    func totalAmount() -> Double {
        return reduce(0.0) { $0 + $1.amount }
    }
    
    /// Calculate total income from transactions
    /// - Returns: Sum of all positive transaction amounts
    /// - Quality: Professional income calculation for financial analysis
    func totalIncome() -> Double {
        return filter { $0.isIncome }.reduce(0.0) { $0 + $1.absoluteAmount }
    }
    
    /// Calculate total expenses from transactions
    /// - Returns: Sum of all negative transaction amounts (as positive)
    /// - Quality: Professional expense calculation for financial analysis
    func totalExpenses() -> Double {
        return filter { $0.isExpense }.reduce(0.0) { $0 + $1.absoluteAmount }
    }
    
    /// Calculate net amount (income - expenses)
    /// - Returns: Net financial impact of all transactions
    /// - Quality: Professional net calculation for financial analysis
    func netAmount() -> Double {
        return totalIncome() - totalExpenses()
    }
    
    /// Group transactions by category for analysis
    /// - Returns: Dictionary of categories to transaction arrays
    /// - Quality: Professional category-based grouping for financial analysis
    func groupedByCategory() -> [String: [Transaction]] {
        var groups: [String: [Transaction]] = [:]
        
        for transaction in self {
            if groups[transaction.category] == nil {
                groups[transaction.category] = []
            }
            groups[transaction.category]?.append(transaction)
        }
        
        return groups
    }
    
    /// Group transactions by type (income, expense, transfer)
    /// - Returns: Dictionary of transaction types to transaction arrays
    /// - Quality: Professional type-based analysis
    func groupedByType() -> [TransactionType: [Transaction]] {
        var groups: [TransactionType: [Transaction]] = [
            .income: [],
            .expense: [],
            .transfer: []
        ]
        
        for transaction in self {
            groups[transaction.getTransactionType()]?.append(transaction)
        }
        
        return groups
    }
    
    /// Filter transactions within date range
    /// - Parameters:
    ///   - fromDate: Start date for filtering
    ///   - toDate: End date for filtering
    /// - Returns: Array of transactions within the specified date range
    /// - Quality: Professional date-based transaction filtering
    func transactionsInRange(from fromDate: Date, to toDate: Date) -> [Transaction] {
        return filter { transaction in
            transaction.date >= fromDate && transaction.date <= toDate
        }
    }
    
    /// Get comprehensive transaction summary for reporting
    /// - Returns: Professional transaction summary string
    /// - Quality: Professional transaction reporting for Australian financial analysis
    func transactionSummary() -> String {
        guard !isEmpty else { return "No transactions recorded" }
        
        let income = totalIncome()
        let expenses = totalExpenses()
        let net = netAmount()
        let categoryGroups = groupedByCategory()
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "AUD"
        formatter.locale = Locale(identifier: "en_AU")
        
        let incomeString = formatter.string(from: NSNumber(value: income)) ?? "A$0.00"
        let expensesString = formatter.string(from: NSNumber(value: expenses)) ?? "A$0.00"
        let netString = formatter.string(from: NSNumber(value: net)) ?? "A$0.00"
        
        let netDescription = net >= 0 ? "💰 Net Income" : "💸 Net Loss"
        
        return "\(count) transactions across \(categoryGroups.count) categories\nIncome: \(incomeString), Expenses: \(expensesString)\n\(netDescription): \(netString)"
    }
}