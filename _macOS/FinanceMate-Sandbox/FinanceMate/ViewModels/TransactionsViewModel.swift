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

@MainActor
class TransactionsViewModel: ObservableObject {
    private let context: NSManagedObjectContext
    
    @Published var transactions: [Transaction] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func fetchTransactions() {
        isLoading = true
        errorMessage = nil
        
        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)]
        
        do {
            transactions = try context.fetch(request)
            isLoading = false
        } catch {
            errorMessage = "Failed to fetch transactions: \(error.localizedDescription)"
            isLoading = false
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
} 