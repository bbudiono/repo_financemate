//
//  BasiqDataParser.swift
//  FinanceMate
//
//  Created by Bernhard Budiono on 8/6/25.
//

import Foundation

/// Parses and transforms Basiq API responses into domain models
final class BasiqDataParser {
    
    // MARK: - Date Formatter
    
    private lazy var dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
    
    // MARK: - Account Parsing
    
    /// Parse Basiq accounts response into BankAccount models
    func parseAccounts(from data: Data) throws -> [BankAccount] {
        let response = try JSONDecoder().decode(BasiqAccountsResponse.self, from: data)
        
        return response.data.compactMap { accountData in
            guard let accountNumber = accountData.accountNo,
                  let balance = accountData.balance?.available ?? accountData.balance?.current else {
                return nil
            }
            
            return BankAccount(
                id: accountData.id,
                accountNumber: accountNumber,
                accountName: accountData.name ?? "Account",
                accountType: mapAccountType(accountData.class?.type),
                balance: balance,
                availableBalance: accountData.balance?.available ?? balance,
                currency: accountData.balance?.currency ?? "AUD",
                institution: accountData.institution ?? "",
                lastUpdated: parseDate(accountData.lastUpdated) ?? Date()
            )
        }
    }
    
    /// Parse single account response
    func parseAccount(from data: Data) throws -> BankAccount? {
        let accountData = try JSONDecoder().decode(BasiqAccountData.self, from: data)
        
        guard let accountNumber = accountData.accountNo,
              let balance = accountData.balance?.available ?? accountData.balance?.current else {
            return nil
        }
        
        return BankAccount(
            id: accountData.id,
            accountNumber: accountNumber,
            accountName: accountData.name ?? "Account",
            accountType: mapAccountType(accountData.class?.type),
            balance: balance,
            availableBalance: accountData.balance?.available ?? balance,
            currency: accountData.balance?.currency ?? "AUD",
            institution: accountData.institution ?? "",
            lastUpdated: parseDate(accountData.lastUpdated) ?? Date()
        )
    }
    
    // MARK: - Transaction Parsing
    
    /// Parse Basiq transactions response into BankTransaction models
    func parseTransactions(from data: Data) throws -> [BankTransaction] {
        let response = try JSONDecoder().decode(BasiqTransactionsResponse.self, from: data)
        
        return response.data.compactMap { transactionData in
            guard let amount = transactionData.amount else {
                return nil
            }
            
            return BankTransaction(
                id: transactionData.id,
                accountId: transactionData.account ?? "",
                amount: abs(amount),
                date: parseDate(transactionData.transactionDate) ?? Date(),
                description: transactionData.description ?? "",
                category: transactionData.subClass?.title,
                merchantName: transactionData.merchant?.name,
                reference: transactionData.reference,
                type: amount >= 0 ? .credit : .debit,
                status: mapTransactionStatus(transactionData.status)
            )
        }
    }
    
    // MARK: - Connection Parsing
    
    /// Parse connection response
    func parseConnection(from data: Data) throws -> ConnectionResult {
        let connection = try JSONDecoder().decode(BasiqConnectionData.self, from: data)
        
        return ConnectionResult(
            sessionId: connection.id,
            userId: connection.userId ?? "",
            institutionId: connection.institution?.id ?? "",
            consentExpiresAt: parseDate(connection.consentExpiresAt),
            lastRefreshed: parseDate(connection.lastUsed) ?? Date()
        )
    }
    
    // MARK: - Private Helpers
    
    private func mapAccountType(_ type: String?) -> BankAccount.AccountType {
        switch type?.uppercased() {
        case "TRANSACTION", "CHECKING":
            return .transaction
        case "SAVINGS":
            return .savings
        case "CREDIT", "CREDIT_CARD":
            return .credit
        case "LOAN", "PERSONAL_LOAN":
            return .loan
        case "INVESTMENT":
            return .investment
        case "MORTGAGE", "HOME_LOAN":
            return .mortgage
        default:
            return .other
        }
    }
    
    private func mapTransactionStatus(_ status: String?) -> BankTransaction.TransactionStatus {
        switch status?.uppercased() {
        case "PENDING":
            return .pending
        case "POSTED", "SETTLED":
            return .posted
        default:
            return .posted
        }
    }
    
    private func parseDate(_ dateString: String?) -> Date? {
        guard let dateString = dateString else { return nil }
        return dateFormatter.date(from: dateString)
    }
}

// MARK: - Basiq Response Models

private struct BasiqAccountsResponse: Codable {
    let data: [BasiqAccountData]
}

private struct BasiqAccountData: Codable {
    let id: String
    let accountNo: String?
    let name: String?
    let `class`: AccountClass?
    let balance: Balance?
    let institution: String?
    let lastUpdated: String?
    
    struct AccountClass: Codable {
        let type: String?
    }
    
    struct Balance: Codable {
        let available: Double?
        let current: Double?
        let currency: String?
    }
}

private struct BasiqTransactionsResponse: Codable {
    let data: [BasiqTransactionData]
}

private struct BasiqTransactionData: Codable {
    let id: String
    let account: String?
    let amount: Double?
    let description: String?
    let transactionDate: String?
    let status: String?
    let reference: String?
    let merchant: Merchant?
    let subClass: SubClass?
    
    struct Merchant: Codable {
        let name: String?
    }
    
    struct SubClass: Codable {
        let title: String?
    }
}

private struct BasiqConnectionData: Codable {
    let id: String
    let userId: String?
    let institution: Institution?
    let consentExpiresAt: String?
    let lastUsed: String?
    
    struct Institution: Codable {
        let id: String
        let name: String?
    }
}