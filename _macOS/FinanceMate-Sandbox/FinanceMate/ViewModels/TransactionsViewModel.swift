// SANDBOX FILE: For testing/development. See .cursorrules.
//
// TransactionsViewModel.swift
// FinanceMate Sandbox
//
// Purpose: MVVM ViewModel for managing transactions (Sandbox, atomic TDD)
// Issues & Complexity Summary: ObservableObject, Core Data context, TDD-driven expansion
// Key Complexity Drivers:
//   - Logic Scope (Est. LoC): ~20
//   - Core Algorithm Complexity: Low
//   - Dependencies: 2 (SwiftUI, Core Data)
//   - State Management Complexity: Low
//   - Novelty/Uncertainty Factor: Low
// AI Pre-Task Self-Assessment: 70%
// Problem Estimate: 75%
// Initial Code Complexity Estimate: 70%
// Final Code Complexity: TBD
// Overall Result Score: TBD
// Key Variances/Learnings: TDD for new MVVM module
// Last Updated: 2025-07-05

import Foundation
import CoreData
import SwiftUI
import Combine

/**
 * TransactionsViewModel.swift
 *
 * Purpose: Manages the state and business logic for the TransactionsView.
 * Issues & Complexity Summary: Handles fetching, filtering, and searching of financial transactions.
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~150
 *   - Core Algorithm Complexity: High
 *   - Dependencies: 2 New (CoreData, Combine)
 *   - State Management Complexity: Medium
 *   - Novelty/Uncertainty Factor: Low
 * AI Pre-Task Self-Assessment: 90%
 * Problem Estimate: 70%
 * Initial Code Complexity Estimate: 80%
 * Final Code Complexity: TBD
 * Overall Result Score: TBD
 * Key Variances/Learnings: TBD
 * Last Updated: 2025-07-06
 */

// EMERGENCY FIX: Removed @MainActor to eliminate Swift Concurrency crashes
class TransactionsViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var searchText: String = ""
    @Published var filteredTransactionCount: Int = 0
    @Published var totalTransactionCount: Int = 0
    @Published var selectedCategory: String?
    @Published var startDate: Date?
    @Published var endDate: Date?
    @Published var isLoading: Bool = false

    var filteredTransactions: [Transaction] {
        var filtered = transactions
        
        // Apply search filter (case-insensitive)
        if !searchText.isEmpty {
            filtered = filtered.filter { transaction in
                transaction.category.lowercased().contains(searchText.lowercased()) ||
                transaction.note?.lowercased().contains(searchText.lowercased()) == true
            }
        }
        
        // Apply category filter
        if let selectedCategory = selectedCategory {
            filtered = filtered.filter { $0.category == selectedCategory }
        }
        
        // Apply date range filter
        if let startDate = startDate {
            filtered = filtered.filter { $0.date >= startDate }
        }
        
        if let endDate = endDate {
            filtered = filtered.filter { $0.date <= endDate }
        }
        
        return filtered.sorted { $0.date > $1.date }
    }

    @Published var errorMessage: String? = nil
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func fetchTransactions() {
        isLoading = true
        errorMessage = nil
        
        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)]
        
        do {
            let fetchedTransactions = try context.fetch(request)
            // Synchronous updates for deterministic tests
            self.transactions = fetchedTransactions
            self.totalTransactionCount = fetchedTransactions.count
            self.filteredTransactionCount = self.filteredTransactions.count
            self.isLoading = false
        } catch {
            self.errorMessage = "Failed to fetch transactions: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
    
    func createTransaction(amount: Double, category: String, note: String?) {
        let _ = Transaction.create(
            in: context,
            amount: amount,
            category: category,
            note: note
        )
        
        do {
            try context.save()
            // Refresh the transactions list
            fetchTransactions()
        } catch {
            errorMessage = "Failed to create transaction: \(error.localizedDescription)"
        }
    }

    func formatCurrencyForDisplay(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_AU") // Australian locale
        formatter.currencyCode = "AUD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }

    func resetFilters() {
        searchText = ""
        selectedCategory = nil
        startDate = nil
        endDate = nil
        filteredTransactionCount = filteredTransactions.count
    }

    func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_AU") // Australian locale
        formatter.currencyCode = "AUD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }

    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_AU") // Australian locale
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    // MARK: - Transaction Management
    
    func deleteTransaction(_ transaction: Transaction) {
        context.delete(transaction)
        
        do {
            try context.save()
            fetchTransactions() // Refresh the list
        } catch {
            errorMessage = "Failed to delete transaction: \(error.localizedDescription)"
        }
    }
    
    func deleteTransactions(at offsets: IndexSet) {
        for index in offsets {
            let transaction = filteredTransactions[index]
            deleteTransaction(transaction)
        }
    }
} 