//
// DashboardViewModel.swift
// FinanceMate
//
// Purpose: Simplified dashboard ViewModel
// Issues & Complexity Summary: Minimal ViewModel with service coordination
// Key Complexity Drivers:
//   - Logic Scope (Est. LoC): ~50
//   - Core Algorithm Complexity: Low
//   - Dependencies: 4 (SwiftUI, Core Data, Combine, Services)
//   - State Management Complexity: Low
//   - Novelty/Uncertainty Factor: Low
// AI Pre-Task Self-Assessment: 95%
// Problem Estimate: 98%
// Initial Code Complexity Estimate: 50%
// Final Code Complexity: 52%
// Overall Result Score: 94%
// Key Variances/Learnings: Minimal complexity with service delegation
// Last Updated: 2025-01-04

import Foundation
import SwiftUI
import CoreData
import Combine

/// Simplified Dashboard ViewModel
class DashboardViewModel: ObservableObject {

    @Published var totalBalance: Double = 0.0
    @Published var transactionCount: Int = 0
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var recentTransactions: [Transaction] = []

    private var dataService: DashboardDataService
    private var cancellables = Set<AnyCancellable>()

    var isEmpty: Bool {
        transactionCount == 0
    }

    var formattedTotalBalance: String {
        DashboardFormattingService.shared.formatCurrency(totalBalance)
    }

    var transactionCountDescription: String {
        DashboardFormattingService.shared.getTransactionCountDescription(transactionCount)
    }

    var balanceColor: Color {
        DashboardFormattingService.shared.getBalanceColor(totalBalance)
    }

    var balanceIcon: String {
        DashboardFormattingService.shared.getBalanceIcon(totalBalance)
    }

    init(context: NSManagedObjectContext) {
        self.dataService = DashboardDataService(context: context)
        setupNotificationObservers()
    }

    convenience init() {
        let tempContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        self.init(context: tempContext)
    }

    deinit {
        cancellables.removeAll()
    }

    func fetchDashboardData() {
        isLoading = true
        errorMessage = nil

        do {
            let (balance, count, recent) = try dataService.calculateDashboardMetrics()
            DispatchQueue.main.async {
                self.totalBalance = balance
                self.transactionCount = count
                self.recentTransactions = recent
                self.isLoading = false
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to load data: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }

    func refreshData() {
        fetchDashboardData()
    }

    func clearError() {
        errorMessage = nil
    }

    func setPersistenceContext(_ context: NSManagedObjectContext) {
        cancellables.removeAll()
        dataService = DashboardDataService(context: context)
        setupNotificationObservers()
    }

    func addTransaction(amount: Double, category: String, note: String?) {
        isLoading = true
        errorMessage = nil

        do {
            try TransactionValidationService.shared.validateAmount(amount)
            try TransactionValidationService.shared.validateCategory(category)

            let sanitizedCategory = TransactionValidationService.shared.sanitizeCategory(category)
            let sanitizedNote = TransactionValidationService.shared.sanitizeNote(note)

            let transaction = try dataService.createTransaction(
                amount: amount,
                category: sanitizedCategory,
                note: sanitizedNote
            )

            try dataService.save()
            refreshDataAfterChange()
            isLoading = false
        } catch {
            handleError(error)
            isLoading = false
        }
    }

    private func setupNotificationObservers() {
        NotificationCenter.default
            .publisher(for: .NSManagedObjectContextDidSave)
            .compactMap { $0.object as? NSManagedObjectContext }
            .filter { context in
                context == self.dataService.context ||
                context.parent == self.dataService.context ||
                context == self.dataService.context.parent
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.fetchDashboardData()
            }
            .store(in: &cancellables)
    }

    private func refreshDataAfterChange() {
        do {
            let (balance, count, recent) = try dataService.calculateDashboardMetrics()
            totalBalance = balance
            transactionCount = count
            recentTransactions = recent
        } catch {
            handleError(error)
        }
    }

    private func handleError(_ error: Error) {
        errorMessage = "Error: \(error.localizedDescription)"
        print("DashboardViewModel Error: \(error)")
    }
}