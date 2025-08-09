//
//  FinancialDataProvider.swift
//  FinanceMate
//
//  Created by Bernhard Budiono on 8/6/25.
//

import Foundation

/// Protocol defining the interface for financial data aggregation services
/// Supports multiple providers (Basiq, NAB, etc.) with consistent API
protocol FinancialDataProvider {
    /// Connect to a financial institution
    /// - Parameter institution: Institution identifier (e.g., "AU00000")
    /// - Returns: Connection result with session details
    func connect() throws -> ConnectionResult
    
    /// Fetch all accounts for the connected user
    /// - Returns: Array of bank accounts
    func fetchAccounts() throws -> [BankAccount]
    
    /// Fetch transactions for a specific account
    /// - Parameters:
    ///   - accountId: Unique identifier for the account
    ///   - from: Start date for transaction history (optional)
    ///   - to: End date for transaction history (optional)
    /// - Returns: Array of bank transactions
    func fetchTransactions() throws -> [BankTransaction]
    
    /// Refresh the current connection to update data
    func refreshConnection() throws
    
    /// Disconnect from the financial institution
    func disconnect() throws
}

/// Result of a connection attempt to a financial institution
struct ConnectionResult {
    let sessionId: String
    let userId: String
    let institutionId: String
    let consentExpiresAt: Date?
    let lastRefreshed: Date
    
    var isValid: Bool {
        if let expiresAt = consentExpiresAt {
            return expiresAt > Date()
        }
        return true
    }
}

/// Represents a bank account from a financial institution
struct BankAccount {
    let id: String
    let accountNumber: String
    let accountName: String
    let accountType: AccountType
    let balance: Double
    let availableBalance: Double
    let currency: String
    let institution: String
    let lastUpdated: Date
    
    enum AccountType: String, CaseIterable {
        case transaction = "TRANSACTION"
        case savings = "SAVINGS"
        case credit = "CREDIT"
        case loan = "LOAN"
        case investment = "INVESTMENT"
        case mortgage = "MORTGAGE"
        case other = "OTHER"
    }
}

/// Represents a transaction from a bank account
struct BankTransaction {
    let id: String
    let accountId: String
    let amount: Double
    let date: Date
    let description: String
    let category: String?
    let merchantName: String?
    let reference: String?
    let type: TransactionType
    let status: TransactionStatus
    
    enum TransactionType: String {
        case debit = "DEBIT"
        case credit = "CREDIT"
    }
    
    enum TransactionStatus: String {
        case pending = "PENDING"
        case posted = "POSTED"
    }
    
    /// Calculate the signed amount (positive for credits, negative for debits)
    var signedAmount: Double {
        return type == .credit ? amount : -amount
    }
}

/// Environment configuration for financial services
enum FinancialServiceEnvironment {
    case sandbox
    case production
    
    var baseURL: String {
        switch self {
        case .sandbox:
            return "https://au-api.basiq.io/sandbox"
        case .production:
            return "https://au-api.basiq.io"
        }
    }
}