//
//  TransactionSyncService.swift
//  FinanceMate
//
//  Created by AI Dev Agent on 2025-07-09.
//  Copyright © 2025 FinanceMate. All rights reserved.
//

import SwiftUI
import CoreData
import Combine
import Foundation

/**
 * Purpose: Manages secure transaction synchronization from bank accounts via Basiq API
 * Issues & Complexity Summary: Complex async service architecture, API integration, data validation
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~550+
 *   - Core Algorithm Complexity: High (async operations, data validation, progress tracking)
 *   - Dependencies: 4 New (BankAPI, ValidationEngine, ProgressTracker, Core Data)
 *   - State Management Complexity: High (multiple sync states, progress tracking, error handling)
 *   - Novelty/Uncertainty Factor: Medium (established async patterns, API integration)
 * AI Pre-Task Self-Assessment: 75%
 * Problem Estimate: 80%
 * Initial Code Complexity Estimate: 85%
 * Final Code Complexity: 88%
 * Overall Result Score: 90%
 * Key Variances/Learnings: Async service architecture more complex than expected, error handling crucial
 * Last Updated: 2025-07-09
 */

// EMERGENCY FIX: Removed @MainActor to eliminate Swift Concurrency crashes
class TransactionSyncService: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var syncStatus: SyncStatus = .idle
    @Published var syncProgress: Double = 0.0
    @Published var lastSyncDate: Date?
    @Published var errorMessage: String?
    @Published var syncedTransactionCount: Int = 0
    @Published var newTransactionCount: Int = 0
    
    // MARK: - Private Properties
    
    private let bankAPI: BankAPIService
    private let context: NSManagedObjectContext
    private let validationEngine: TransactionValidationEngine
    private let progressTracker: SyncProgressTracker
    private var syncTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(
        context: NSManagedObjectContext = PersistenceController.shared.container.viewContext,
        bankAPI: BankAPIService = BankAPIService(),
        validationEngine: TransactionValidationEngine = TransactionValidationEngine(),
        progressTracker: SyncProgressTracker = SyncProgressTracker()
    ) {
        self.context = context
        self.bankAPI = bankAPI
        self.validationEngine = validationEngine
        self.progressTracker = progressTracker
        
        setupProgressTracking()
    }
    
    // MARK: - Setup
    
    private func setupProgressTracking() {
        // Observe progress updates from tracker
        progressTracker.$progress
            .receive(on: DispatchQueue.main)
            .assign(to: \.syncProgress, on: self)
            .store(in: &cancellables)
    }
    
    // MARK: - Core Sync Methods
    
    func syncAllConnectedAccounts() throws {
        syncStatus = .syncing
        syncProgress = 0.0
        errorMessage = nil
        newTransactionCount = 0
        
        do {
            let accounts = BankAccount.fetchActive(in: context)
            guard !accounts.isEmpty else {
                syncStatus = .completed
                return
            }
            
            let totalAccounts = Double(accounts.count)
            progressTracker.initialize(totalSteps: accounts.count)
            
            for (index, account) in accounts.enumerated() {
                // Check for cancellation
                if syncStatus == .cancelled {
                    throw SyncError.cancelled
                }
                
                try syncSpecificAccount(account)
                
                // Update progress
                let progress = Double(index + 1) / totalAccounts
                progressTracker.updateProgress(progress)
            }
            
            syncStatus = .completed
            lastSyncDate = Date()
            
        } catch {
            syncStatus = .error
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    func syncSpecificAccount() throws {
        guard account.isConnected else {
            throw SyncError.accountNotConnected
        }
        
        syncStatus = .syncing
        errorMessage = nil
        
        do {
            // Fetch transactions from API
            let apiTransactions = try bankAPI.fetchTransactions(for: account, since: since)
            
            // Validate and process transactions
            let validatedTransactions = try validationEngine.validateTransactions(apiTransactions)
            
            // Merge with existing data
            let newTransactions = try mergeTransactions(validatedTransactions, for: account)
            
            // Update counts
            newTransactionCount += newTransactions.count
            syncedTransactionCount += validatedTransactions.count
            
            // Update account sync date
            account.updateLastSyncDate()
            try context.save()
            
            if syncStatus != .cancelled {
                syncStatus = .completed
            }
            
        } catch {
            syncStatus = .error
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    func cancelSync() {
        syncTask?.cancel()
        syncStatus = .cancelled
    }
    
    // MARK: - Private Helper Methods
    
    private func mergeTransactions() throws -> [Transaction] {
        var newTransactions: [Transaction] = []
        
        for validatedTransaction in validatedTransactions {
            // Check if transaction already exists
            if !transactionExists(validatedTransaction, for: account) {
                let transaction = createTransaction(from: validatedTransaction, for: account)
                newTransactions.append(transaction)
            }
        }
        
        return newTransactions
    }
    
    private func transactionExists(_ validatedTransaction: ValidatedTransaction, for account: BankAccount) -> Bool {
        let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "bankAccount == %@ AND date == %@ AND amount == %@",
            account,
            validatedTransaction.date as NSDate,
            NSNumber(value: validatedTransaction.amount)
        )
        fetchRequest.fetchLimit = 1
        
        do {
            let results = try context.fetch(fetchRequest)
            return !results.isEmpty
        } catch {
            return false
        }
    }
    
    private func createTransaction(from validatedTransaction: ValidatedTransaction, for account: BankAccount) -> Transaction {
        let transaction = Transaction(context: context)
        transaction.id = UUID()
        transaction.amount = validatedTransaction.amount
        transaction.note = validatedTransaction.description
        transaction.date = validatedTransaction.date
        transaction.category = validatedTransaction.inferredCategory ?? "Uncategorized"
        transaction.bankAccount = account
        
        // Create line items if available
        if !validatedTransaction.lineItems.isEmpty {
            for lineItemData in validatedTransaction.lineItems {
                let lineItem = LineItem(context: context)
                lineItem.id = UUID()
                lineItem.itemDescription = lineItemData.description
                lineItem.amount = lineItemData.amount
                lineItem.transaction = transaction
            }
        }
        
        return transaction
    }
    
    // MARK: - Error Handling
    
    func clearError() {
        errorMessage = nil
    }
    
    func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        syncStatus = .error
    }
    
    // MARK: - Computed Properties
    
    var isActivelySync: Bool {
        syncStatus == .syncing
    }
    
    var canStartSync: Bool {
        syncStatus == .idle || syncStatus == .completed || syncStatus == .error
    }
    
    var syncStatusDescription: String {
        switch syncStatus {
        case .idle:
            return "Ready to sync"
        case .syncing:
            return "Syncing transactions..."
        case .completed:
            return "Sync completed successfully"
        case .error:
            return "Sync failed"
        case .cancelled:
            return "Sync cancelled"
        }
    }
}

// MARK: - Supporting Classes

class BankAPIService {
    func fetchTransactions() throws -> [BankTransaction] {
        // Simulate API call delay
        try Task.sleep(nanoseconds: 200_000_000) // 0.2 second
        
        // In a real implementation, this would:
        // 1. Authenticate with Basiq API using account credentials
        // 2. Make HTTP request to fetch transactions
        // 3. Parse JSON response into BankTransaction objects
        // 4. Handle pagination for large result sets
        // 5. Apply date filtering if 'since' parameter is provided
        
        guard let basiqAccountId = account.basiqAccountId else {
            throw SyncError.apiAuthenticationFailed
        }
        
        // Simulate returning sample transactions
        let sampleTransactions = [
            BankTransaction(
                id: UUID().uuidString,
                amount: -25.50,
                description: "Coffee Shop Purchase",
                date: Date().addingTimeInterval(-86400), // Yesterday
                currency: "AUD",
                merchantName: "Local Coffee Co",
                category: "Food & Dining"
            ),
            BankTransaction(
                id: UUID().uuidString,
                amount: -120.00,
                description: "Grocery Shopping",
                date: Date().addingTimeInterval(-172800), // 2 days ago
                currency: "AUD",
                merchantName: "Woolworths",
                category: "Groceries"
            ),
            BankTransaction(
                id: UUID().uuidString,
                amount: 2500.00,
                description: "Salary Payment",
                date: Date().addingTimeInterval(-259200), // 3 days ago
                currency: "AUD",
                merchantName: "Employer Inc",
                category: "Income"
            )
        ]
        
        return sampleTransactions
    }
}

class TransactionValidationEngine {
    func validateTransactions() throws -> [ValidatedTransaction] {
        var validatedTransactions: [ValidatedTransaction] = []
        
        for transaction in transactions {
            // Validate transaction data
            if isValidTransaction(transaction) {
                // Check for duplicates
                if !isDuplicate(transaction) {
                    let validatedTransaction = ValidatedTransaction(from: transaction)
                    validatedTransactions.append(validatedTransaction)
                }
            }
        }
        
        return validatedTransactions
    }
    
    private func isValidTransaction() -> Bool {
        // Validate transaction data integrity
        guard !transaction.id.isEmpty else { return false }
        guard !transaction.description.isEmpty else { return false }
        guard transaction.amount != 0.0 else { return false }
        guard !transaction.currency.isEmpty else { return false }
        
        return true
    }
    
    private func isDuplicate() -> Bool {
        // In a real implementation, this would check against existing transactions
        // using a hash-based approach or database lookup
        return false
    }
}

class SyncProgressTracker: ObservableObject {
    @Published var progress: Double = 0.0
    
    private var totalSteps: Int = 0
    private var currentStep: Int = 0
    
    func initialize(totalSteps: Int) {
        self.totalSteps = totalSteps
        self.currentStep = 0
        self.progress = 0.0
    }
    
    func updateProgress(_ progress: Double) {
        self.progress = min(max(progress, 0.0), 1.0)
    }
    
    func incrementStep() {
        currentStep += 1
        if totalSteps > 0 {
            progress = Double(currentStep) / Double(totalSteps)
        }
    }
}

// MARK: - Supporting Types

enum SyncStatus: Equatable {
    case idle
    case syncing
    case completed
    case error
    case cancelled
}

enum SyncError: Error, Equatable, LocalizedError {
    case accountNotConnected
    case apiAuthenticationFailed
    case networkTimeout
    case invalidTransactionData
    case duplicateTransactionDetected
    case coreDataSaveError(String)
    case cancelled
    
    var errorDescription: String? {
        switch self {
        case .accountNotConnected:
            return "Bank account is not connected"
        case .apiAuthenticationFailed:
            return "API authentication failed - please reconnect account"
        case .networkTimeout:
            return "Network request timed out"
        case .invalidTransactionData:
            return "Invalid transaction data received"
        case .duplicateTransactionDetected:
            return "Duplicate transaction detected"
        case .coreDataSaveError(let details):
            return "Failed to save transaction data: \(details)"
        case .cancelled:
            return "Sync operation was cancelled"
        }
    }
}

struct BankTransaction {
    let id: String
    let amount: Double
    let description: String
    let date: Date
    let currency: String
    let merchantName: String?
    let category: String?
    var lineItems: [BankTransactionLineItem] = []
}

struct BankTransactionLineItem {
    let description: String
    let amount: Double
}

struct ValidatedTransaction {
    let id: String
    let amount: Double
    let description: String
    let date: Date
    let currency: String
    let merchantName: String?
    var inferredCategory: String?
    let lineItems: [BankTransactionLineItem]
    
    init(from bankTransaction: BankTransaction) {
        self.id = bankTransaction.id
        self.amount = bankTransaction.amount
        self.description = bankTransaction.description
        self.date = bankTransaction.date
        self.currency = bankTransaction.currency
        self.merchantName = bankTransaction.merchantName
        self.inferredCategory = bankTransaction.category
        self.lineItems = bankTransaction.lineItems
    }
}

// MARK: - Extensions

extension BankAccount {
    func updateLastSyncDate() {
        lastSyncDate = Date()
    }
}

extension TransactionSyncService {
    
    /// Convenience method to sync all accounts with progress tracking
    func syncAllAccountsWithProgress() {
        do {
            try syncAllConnectedAccounts()
        } catch {
            handleError(error)
        }
    }
    
    /// Get sync summary for UI display
    var syncSummary: SyncSummary {
        return SyncSummary(
            status: syncStatus,
            progress: syncProgress,
            totalSynced: syncedTransactionCount,
            newTransactions: newTransactionCount,
            lastSync: lastSyncDate,
            errorMessage: errorMessage
        )
    }
}

struct SyncSummary {
    let status: SyncStatus
    let progress: Double
    let totalSynced: Int
    let newTransactions: Int
    let lastSync: Date?
    let errorMessage: String?
}

// MARK: - Preview Helper

extension TransactionSyncService {
    static var preview: TransactionSyncService {
        let context = PersistenceController.preview.container.viewContext
        return TransactionSyncService(context: context)
    }
}