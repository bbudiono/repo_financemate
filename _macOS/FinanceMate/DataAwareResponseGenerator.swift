import Foundation
import CoreData
import os.log

/// Generates chatbot responses using real user financial data from Core Data
struct DataAwareResponseGenerator {

    private static let logger = Logger(subsystem: "FinanceMate", category: "DataAwareResponseGenerator")

    // MARK: - Main Entry Point

    /// Generate data-aware response if question matches supported patterns
    static func generate(question: String, context: NSManagedObjectContext) -> (content: String, actionType: ActionType, questionType: FinancialQuestionType)? {
        let questionLower = question.lowercased()
        logger.debug("Checking for data-aware patterns: \(questionLower)")

        if questionLower.contains("balance") || questionLower.contains("total") {
            return generateBalanceResponse(context: context)
        }

        if questionLower.contains("spending") || questionLower.contains("spent") {
            return generateSpendingResponse(context: context)
        }

        if questionLower.contains("category") || questionLower.contains("groceries") || questionLower.contains("dining") {
            return generateCategoryResponse(question: questionLower, context: context)
        }

        logger.debug("No data-aware pattern matched")
        return nil
    }

    // MARK: - Response Generators

    private static func generateBalanceResponse(context: NSManagedObjectContext) -> (String, ActionType, FinancialQuestionType) {
        let balance = TransactionQueryHelper.getTotalBalance(context: context)
        let count = TransactionQueryHelper.getTransactionCount(context: context)

        let content = "Your current balance is $\(String(format: "%.2f", balance)) across \(count) transactions. \(balance > 0 ? "You are in a positive position!" : "Consider reviewing your expenses to improve your balance.")"

        logger.info("Balance response: $\(balance) across \(count) transactions")
        return (content, .showDashboard, .financeMateSpecific)
    }

    private static func generateSpendingResponse(context: NSManagedObjectContext) -> (String, ActionType, FinancialQuestionType)? {
        let recent = TransactionQueryHelper.getRecentTransactions(context: context)
        guard !recent.isEmpty else {
            logger.warning("No transactions found for spending query")
            return nil
        }

        let total = recent.reduce(0.0) { $0 + abs($1.amount) }
        let itemDescription = recent.first?.itemDescription ?? "Unknown"
        let mostRecentAmount = recent.first?.amount ?? 0

        let content = "Your recent spending totals $\(String(format: "%.2f", total)) across \(recent.count) transactions. Most recent: \(itemDescription) for $\(String(format: "%.2f", mostRecentAmount))."

        logger.info("Spending response: $\(total) across \(recent.count) transactions")
        return (content, .analyzeExpenses, .personalFinance)
    }

    private static func generateCategoryResponse(question: String, context: NSManagedObjectContext) -> (String, ActionType, FinancialQuestionType)? {
        let categories = ["groceries", "dining", "transport", "utilities", "entertainment"]

        for category in categories {
            if question.contains(category) {
                let spending = TransactionQueryHelper.getCategorySpending(context: context, category: category.capitalized)
                let content = "You've spent $\(String(format: "%.2f", spending)) on \(category.capitalized). \(spending > 0 ? "This is a significant expense category." : "No transactions found in this category yet.")"

                logger.info("Category \(category): $\(spending)")
                return (content, .analyzeExpenses, .personalFinance)
            }
        }

        logger.debug("No matching category in question")
        return nil
    }
}
