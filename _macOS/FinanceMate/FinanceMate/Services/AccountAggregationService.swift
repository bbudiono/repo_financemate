import Foundation
import SwiftUI

// MARK: - Account Aggregation Service

@Observable
public class AccountAggregationService {
    // MARK: - Properties

    public var accounts: [FinancialAccount] = []
    public var isLoading = false
    public var lastSyncTime: Date?
    public var syncProgress: Double = 0.0

    // MARK: - Computed Properties

    public var totalNetWorth: Double {
        accounts.reduce(0) { $0 + $1.balance }
    }

    public var totalAssets: Double {
        accounts.filter { $0.type.isAsset }.reduce(0) { $0 + $1.balance }
    }

    public var totalLiabilities: Double {
        accounts.filter { $0.type.isLiability }.reduce(0) { $0 + abs($1.balance) }
    }

    public var accountsByInstitution: [String: [FinancialAccount]] {
        Dictionary(grouping: accounts) { $0.institutionName }
    }

    public var accountsByType: [AccountType: [FinancialAccount]] {
        Dictionary(grouping: accounts) { $0.type }
    }

    // MARK: - Public Methods

    public func loadAccounts() {
        accounts = generateSampleAccounts()
        lastSyncTime = Date()
    }

    public func addAccount(_ account: FinancialAccount) {
        accounts.append(account)
        sortAccounts()
    }

    public func removeAccount(_ account: FinancialAccount) {
        accounts.removeAll { $0.id == account.id }
    }

    public func updateAccountBalance(accountId: UUID, newBalance: Double) {
        if let index = accounts.firstIndex(where: { $0.id == accountId }) {
            accounts[index].balance = newBalance
            accounts[index].lastUpdated = Date()
        }
    }

    public func syncAllAccounts() async {
        isLoading = true
        syncProgress = 0.0

        for (index, account) in accounts.enumerated() {
            await syncAccount(account)
            syncProgress = Double(index + 1) / Double(accounts.count)
        }

        isLoading = false
        lastSyncTime = Date()
    }

    public func syncAccount(_ account: FinancialAccount) async {
        // Simulate API call delay
        try? await Task.sleep(nanoseconds: 1_000_000_000)

        // Simulate balance updates
        let variation = Double.random(in: -100...100)
        updateAccountBalance(accountId: account.id, newBalance: account.balance + variation)
    }

    public func getAccountPerformance(for account: FinancialAccount, period: TimePeriod) -> AccountPerformance {
        // In a real app, this would calculate actual performance metrics
        let mockChange = Double.random(in: -5...5)
        let mockPercentageChange = mockChange / account.balance * 100

        return AccountPerformance(
            account: account,
            period: period,
            startingBalance: account.balance - mockChange,
            endingBalance: account.balance,
            change: mockChange,
            percentageChange: mockPercentageChange,
            transactions: generateSampleTransactions(for: account)
        )
    }

    public func getNetWorthHistory(period: TimePeriod) -> [NetWorthDataPoint] {
        // Generate sample historical data
        var dataPoints: [NetWorthDataPoint] = []
        let calendar = Calendar.current

        let daysBack = period.daysBack
        let currentNetWorth = totalNetWorth

        for i in (0...daysBack).reversed() {
            let date = calendar.date(byAdding: .day, value: -i, to: Date()) ?? Date()
            let variation = Double.random(in: -1000...1000)
            let netWorth = currentNetWorth + variation

            dataPoints.append(NetWorthDataPoint(
                date: date,
                netWorth: netWorth,
                assets: netWorth * 0.8,
                liabilities: netWorth * 0.2
            ))
        }

        return dataPoints
    }

    public func getCashFlowAnalysis(period: TimePeriod) -> CashFlowAnalysis {
        let totalIncome = accounts.reduce(0) { total, account in
            total + (account.type == .checking ? account.balance * 0.1 : 0)
        }

        let totalExpenses = totalIncome * 0.8
        let netCashFlow = totalIncome - totalExpenses

        return CashFlowAnalysis(
            period: period,
            totalIncome: totalIncome,
            totalExpenses: totalExpenses,
            netCashFlow: netCashFlow,
            incomeByCategory: generateIncomeByCategoryData(),
            expensesByCategory: generateExpensesByCategoryData()
        )
    }

    // MARK: - Private Methods

    private func sortAccounts() {
        accounts.sort { account1, account2 in
            if account1.institutionName != account2.institutionName {
                return account1.institutionName < account2.institutionName
            }
            return account1.balance > account2.balance
        }
    }

    private func generateSampleAccounts() -> [FinancialAccount] {
        [
            // Bank Accounts
            FinancialAccount(
                name: "Primary Checking",
                institutionName: "Chase Bank",
                type: .checking,
                balance: 5420.50,
                accountNumber: "****1234",
                routingNumber: "021000021",
                isActive: true,
                lastUpdated: Date()
            ),
            FinancialAccount(
                name: "High Yield Savings",
                institutionName: "Marcus by Goldman Sachs",
                type: .savings,
                balance: 25_750.00,
                accountNumber: "****5678",
                routingNumber: "124002971",
                isActive: true,
                lastUpdated: Date()
            ),
            FinancialAccount(
                name: "Emergency Fund",
                institutionName: "Ally Bank",
                type: .savings,
                balance: 15_000.00,
                accountNumber: "****9012",
                routingNumber: "124003116",
                isActive: true,
                lastUpdated: Date()
            ),

            // Credit Cards
            FinancialAccount(
                name: "Sapphire Preferred",
                institutionName: "Chase Bank",
                type: .creditCard,
                balance: -2340.25,
                accountNumber: "****3456",
                creditLimit: 15_000.0,
                isActive: true,
                lastUpdated: Date()
            ),
            FinancialAccount(
                name: "Platinum Card",
                institutionName: "American Express",
                type: .creditCard,
                balance: -890.75,
                accountNumber: "****7890",
                creditLimit: 25_000.0,
                isActive: true,
                lastUpdated: Date()
            ),

            // Investment Accounts
            FinancialAccount(
                name: "401(k)",
                institutionName: "Fidelity",
                type: .retirement,
                balance: 125_000.00,
                accountNumber: "****4567",
                isActive: true,
                lastUpdated: Date()
            ),
            FinancialAccount(
                name: "Roth IRA",
                institutionName: "Vanguard",
                type: .investment,
                balance: 45_000.00,
                accountNumber: "****8901",
                isActive: true,
                lastUpdated: Date()
            ),
            FinancialAccount(
                name: "Brokerage Account",
                institutionName: "Charles Schwab",
                type: .investment,
                balance: 32_500.00,
                accountNumber: "****2345",
                isActive: true,
                lastUpdated: Date()
            ),

            // Loans
            FinancialAccount(
                name: "Mortgage",
                institutionName: "Wells Fargo",
                type: .mortgage,
                balance: -285_000.00,
                accountNumber: "****6789",
                isActive: true,
                lastUpdated: Date()
            ),
            FinancialAccount(
                name: "Auto Loan",
                institutionName: "Capital One",
                type: .loan,
                balance: -18_500.00,
                accountNumber: "****0123",
                isActive: true,
                lastUpdated: Date()
            )
        ]
    }

    private func generateSampleTransactions(for account: FinancialAccount) -> [Transaction] {
        var transactions: [Transaction] = []
        let calendar = Calendar.current

        for i in 1...10 {
            let date = calendar.date(byAdding: .day, value: -i, to: Date()) ?? Date()
            let amount = Double.random(in: -500...200)

            transactions.append(Transaction(
                id: UUID(),
                amount: amount,
                description: "Sample Transaction \(i)",
                date: date,
                categoryId: nil
            ))
        }

        return transactions
    }

    private func generateIncomeByCategoryData() -> [CategoryAmount] {
        [
            CategoryAmount(category: "Salary", amount: 8500.0),
            CategoryAmount(category: "Freelance", amount: 1200.0),
            CategoryAmount(category: "Investments", amount: 450.0),
            CategoryAmount(category: "Other", amount: 250.0)
        ]
    }

    private func generateExpensesByCategoryData() -> [CategoryAmount] {
        [
            CategoryAmount(category: "Housing", amount: 2800.0),
            CategoryAmount(category: "Food", amount: 800.0),
            CategoryAmount(category: "Transportation", amount: 600.0),
            CategoryAmount(category: "Utilities", amount: 350.0),
            CategoryAmount(category: "Entertainment", amount: 300.0),
            CategoryAmount(category: "Insurance", amount: 250.0),
            CategoryAmount(category: "Other", amount: 400.0)
        ]
    }
}

// MARK: - Supporting Types

public struct FinancialAccount: Identifiable, Equatable {
    public let id = UUID()
    public let name: String
    public let institutionName: String
    public let type: AccountType
    public var balance: Double
    public let accountNumber: String
    public var routingNumber: String?
    public var creditLimit: Double?
    public let isActive: Bool
    public var lastUpdated: Date

    public var formattedBalance: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: balance)) ?? "$0.00"
    }

    public var accountTypeIcon: String {
        type.icon
    }

    public var accountTypeColor: Color {
        type.color
    }

    public var maskedAccountNumber: String {
        "•••• " + String(accountNumber.suffix(4))
    }

    public var creditUtilization: Double? {
        guard type == .creditCard, let limit = creditLimit, limit > 0 else { return nil }
        return abs(balance) / limit
    }
}

public enum AccountType: String, CaseIterable {
    case checking = "checking"
    case savings = "savings"
    case creditCard = "credit_card"
    case investment = "investment"
    case retirement = "retirement"
    case mortgage = "mortgage"
    case loan = "loan"
    case other = "other"

    public var displayName: String {
        switch self {
        case .checking: return "Checking"
        case .savings: return "Savings"
        case .creditCard: return "Credit Card"
        case .investment: return "Investment"
        case .retirement: return "Retirement"
        case .mortgage: return "Mortgage"
        case .loan: return "Loan"
        case .other: return "Other"
        }
    }

    public var icon: String {
        switch self {
        case .checking: return "dollarsign.circle.fill"
        case .savings: return "banknote.fill"
        case .creditCard: return "creditcard.fill"
        case .investment: return "chart.line.uptrend.xyaxis"
        case .retirement: return "person.crop.circle.badge.clock"
        case .mortgage: return "house.fill"
        case .loan: return "car.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }

    public var color: Color {
        switch self {
        case .checking: return .blue
        case .savings: return .green
        case .creditCard: return .orange
        case .investment: return .purple
        case .retirement: return .indigo
        case .mortgage: return .brown
        case .loan: return .red
        case .other: return .gray
        }
    }

    public var isAsset: Bool {
        switch self {
        case .checking, .savings, .investment, .retirement:
            return true
        case .creditCard, .mortgage, .loan:
            return false
        case .other:
            return true // Default to asset
        }
    }

    public var isLiability: Bool {
        !isAsset
    }
}

public enum TimePeriod: String, CaseIterable {
    case week = "7d"
    case month = "30d"
    case quarter = "90d"
    case year = "365d"

    public var displayName: String {
        switch self {
        case .week: return "7 Days"
        case .month: return "30 Days"
        case .quarter: return "3 Months"
        case .year: return "1 Year"
        }
    }

    public var daysBack: Int {
        switch self {
        case .week: return 7
        case .month: return 30
        case .quarter: return 90
        case .year: return 365
        }
    }
}

public struct AccountPerformance {
    public let account: FinancialAccount
    public let period: TimePeriod
    public let startingBalance: Double
    public let endingBalance: Double
    public let change: Double
    public let percentageChange: Double
    public let transactions: [Transaction]

    public var isPositive: Bool {
        change >= 0
    }
}

public struct NetWorthDataPoint {
    public let date: Date
    public let netWorth: Double
    public let assets: Double
    public let liabilities: Double
}

public struct CashFlowAnalysis {
    public let period: TimePeriod
    public let totalIncome: Double
    public let totalExpenses: Double
    public let netCashFlow: Double
    public let incomeByCategory: [CategoryAmount]
    public let expensesByCategory: [CategoryAmount]

    public var savingsRate: Double {
        guard totalIncome > 0 else { return 0 }
        return netCashFlow / totalIncome
    }
}

public struct CategoryAmount {
    public let category: String
    public let amount: Double
}

public struct Transaction: Identifiable {
    public let id: UUID
    public let amount: Double
    public let description: String
    public let date: Date
    public let categoryId: UUID?
}
