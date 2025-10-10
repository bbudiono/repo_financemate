//
// DashboardViewModel.swift
// FinanceMate
//
// Purpose: Enhanced dashboard ViewModel with proper AUD formatting and trend calculations
// BLUEPRINT Lines 147-160: Enhanced Dashboard Cards, Monetary Amounts, Trend Indicators
// Key Complexity Drivers:
//   - Logic Scope (Est. LoC): ~180
//   - Core Algorithm Complexity: Medium
//   - Dependencies: 3 (SwiftUI, Core Data, Foundation)
//   - State Management Complexity: Medium
//   - Novelty/Uncertainty Factor: Low
// AI Pre-Task Self-Assessment: 92%
// Problem Estimate: 95%
// Initial Code Complexity Estimate: 65%
// Final Code Complexity: 68%
// Overall Result Score: 91%
// Last Updated: 2025-10-09

import Foundation
import SwiftUI
import CoreData

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var transactionCount: Int = 0
    @Published var monthlyTransactionCount: Int = 0
    @Published var formattedTotalBalance: String = "$0.00"
    @Published var formattedMonthlySpending: String = "$0.00"
    @Published var formattedExpenses: String = "$0.00"
    @Published var formattedIncome: String = "$0.00"
    @Published var formattedMonthlyIncome: String = "$0.00"
    @Published var formattedAvgMonthlyExpenses: String = "$0.00"
    @Published var balanceTrend: TrendIndicator = TrendIndicator(direction: .neutral, percentage: 0)
    @Published var transactionTrend: TrendIndicator = TrendIndicator(direction: .neutral, percentage: 0)
    @Published var expensesTrend: TrendIndicator = TrendIndicator(direction: .neutral, percentage: 0)
    @Published var incomeTrend: TrendIndicator = TrendIndicator(direction: .neutral, percentage: 0)
    @Published var categorySpending: [(category: String, amount: Double, color: Color)] = []
    @Published var hasData: Bool = false

    private var viewContext: NSManagedObjectContext
    private var allTransactions: [Transaction] = []

    // BLUEPRINT Line 158: Proper AUD currency formatter
    private let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "AUD"
        formatter.locale = Locale(identifier: "en_AU")
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    init(context: NSManagedObjectContext) {
        self.viewContext = context
    }

    func updateTransactions(_ transactions: [Transaction]) {
        self.allTransactions = transactions
        calculateMetrics()
    }

    private func calculateMetrics() {
        transactionCount = allTransactions.count
        monthlyTransactionCount = currentMonthTransactions.count

        let totalBalance = allTransactions.reduce(0) { $0 + $1.amount }
        let expenses = allTransactions.filter { $0.amount < 0 }.reduce(0) { $0 + abs($1.amount) }
        let income = allTransactions.filter { $0.amount > 0 }.reduce(0) { $0 + $1.amount }
        let monthlySpending = currentMonthTransactions.filter { $0.amount < 0 }.reduce(0) { $0 + abs($1.amount) }
        let monthlyIncome = currentMonthTransactions.filter { $0.amount > 0 }.reduce(0) { $0 + $1.amount }
        let avgMonthlyExpenses = expenses / Double(max(monthCount, 1))

        formattedTotalBalance = format(totalBalance)
        formattedExpenses = format(expenses)
        formattedIncome = format(income)
        formattedMonthlySpending = format(monthlySpending)
        formattedMonthlyIncome = format(monthlyIncome)
        formattedAvgMonthlyExpenses = format(avgMonthlyExpenses)

        balanceTrend = calculateTrend(current: totalBalance, previous: lastMonthBalance)
        transactionTrend = calculateCountTrend(current: monthlyTransactionCount, previous: lastMonthTransactionCount)
        expensesTrend = calculateTrend(current: monthlySpending, previous: lastMonthSpending, inverse: true)
        incomeTrend = calculateTrend(current: monthlyIncome, previous: lastMonthIncome)

        categorySpending = calculateCategorySpending()
        hasData = !allTransactions.isEmpty
    }

    private func format(_ value: Double) -> String {
        currencyFormatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }

    private func calculateTrend(current: Double, previous: Double, inverse: Bool = false) -> TrendIndicator {
        guard previous != 0 else { return TrendIndicator(direction: .neutral, percentage: 0) }
        let percentageChange = ((current - previous) / abs(previous)) * 100
        let actualChange = inverse ? -percentageChange : percentageChange
        let direction: TrendIndicator.Direction = actualChange > 0 ? .up : actualChange < 0 ? .down : .neutral
        return TrendIndicator(direction: direction, percentage: actualChange)
    }

    private func calculateCountTrend(current: Int, previous: Int) -> TrendIndicator {
        guard previous != 0 else { return TrendIndicator(direction: .neutral, percentage: 0) }
        let percentageChange = Double((current - previous)) / Double(previous) * 100
        let direction: TrendIndicator.Direction = percentageChange > 0 ? .up : percentageChange < 0 ? .down : .neutral
        return TrendIndicator(direction: direction, percentage: percentageChange)
    }

    private func calculateCategorySpending() -> [(category: String, amount: Double, color: Color)] {
        let expenses = allTransactions.filter { $0.amount < 0 }
        let grouped = Dictionary(grouping: expenses, by: { $0.category })
        let categoryColors: [String: Color] = [
            "Personal": .blue, "Business": .purple, "Investment": .green,
            "Property Investment": .orange, "Groceries": .teal,
            "Utilities": .indigo, "Entertainment": .pink
        ]
        return grouped.map { (category, transactions) in
            let total = transactions.reduce(0) { $0 + abs($1.amount) }
            return (category: category, amount: total, color: categoryColors[category] ?? .gray)
        }.sorted { $0.amount > $1.amount }.prefix(5).map { $0 }
    }

    private var currentMonthTransactions: [Transaction] {
        let calendar = Calendar.current
        return allTransactions.filter { calendar.isDate($0.date, equalTo: Date(), toGranularity: .month) }
    }

    private var lastMonthTransactions: [Transaction] {
        let calendar = Calendar.current
        guard let lastMonth = calendar.date(byAdding: .month, value: -1, to: Date()) else { return [] }
        return allTransactions.filter { calendar.isDate($0.date, equalTo: lastMonth, toGranularity: .month) }
    }

    private var lastMonthBalance: Double {
        lastMonthTransactions.reduce(0) { $0 + $1.amount }
    }

    private var lastMonthTransactionCount: Int {
        lastMonthTransactions.count
    }

    private var lastMonthSpending: Double {
        lastMonthTransactions.filter { $0.amount < 0 }.reduce(0) { $0 + abs($1.amount) }
    }

    private var lastMonthIncome: Double {
        lastMonthTransactions.filter { $0.amount > 0 }.reduce(0) { $0 + $1.amount }
    }

    private var monthCount: Int {
        let calendar = Calendar.current
        guard let oldest = allTransactions.map(\.date).min(),
              let newest = allTransactions.map(\.date).max() else { return 1 }
        let components = calendar.dateComponents([.month], from: oldest, to: newest)
        return max((components.month ?? 0) + 1, 1)
    }
}