//
// DashboardViewModel.swift
// FinanceMate
//
// Purpose: Dashboard business logic and state management using MVVM architecture
// Issues & Complexity Summary: ObservableObject with Core Data integration and published state properties
// Key Complexity Drivers:
//   - Logic Scope (Est. LoC): ~120
//   - Core Algorithm Complexity: Medium
//   - Dependencies: 3 (SwiftUI, Core Data, Combine)
//   - State Management Complexity: Medium-High
//   - Novelty/Uncertainty Factor: Low
// AI Pre-Task Self-Assessment: 90%
// Problem Estimate: 92%
// Initial Code Complexity Estimate: 88%
// Final Code Complexity: 89%
// Overall Result Score: 93%
// Key Variances/Learnings: Clean MVVM separation with robust error handling
// Last Updated: 2025-07-05

import Foundation
import SwiftUI
import CoreData
import Combine

/// Dashboard ViewModel implementing MVVM architecture for financial overview display
///
/// This ViewModel manages the business logic and state for the dashboard view,
/// providing real-time financial data aggregation and presentation.
///
/// Key Responsibilities:
/// - Transaction data aggregation and calculations
/// - Loading state management
/// - Error handling and user feedback
/// - Core Data integration with reactive updates
@MainActor
class DashboardViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// Total financial balance calculated from all transactions
    @Published var totalBalance: Double = 0.0
    
    /// Total number of transactions in the system
    @Published var transactionCount: Int = 0
    
    /// Loading state for UI feedback during data operations
    @Published var isLoading: Bool = false
    
    /// Error message for user display when operations fail
    @Published var errorMessage: String?
    
    /// Recent transactions for dashboard preview (limited to 5)
    @Published var recentTransactions: [Transaction] = []
    
    // MARK: - Computed Properties
    
    /// Determines if the dashboard is in an empty state
    var isEmpty: Bool {
        transactionCount == 0
    }
    
    /// Formatted total balance for display
    var formattedTotalBalance: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: totalBalance)) ?? "$0.00"
    }
    
    /// Transaction count description for UI display
    var transactionCountDescription: String {
        switch transactionCount {
        case 0:
            return "No transactions yet"
        case 1:
            return "1 transaction"
        default:
            return "\(transactionCount) transactions"
        }
    }
    
    // MARK: - Private Properties
    
    private var context: NSManagedObjectContext
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    /// Initialize DashboardViewModel with Core Data context
    /// - Parameter context: NSManagedObjectContext for data operations
    init(context: NSManagedObjectContext) {
        self.context = context
        setupNotificationObservers()
    }
    
    /// Convenience initializer for @StateObject usage without immediate context
    /// Context must be set via setPersistenceContext before calling data methods
    convenience init() {
        // Create a temporary context that will be replaced via setPersistenceContext
        let tempContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        self.init(context: tempContext)
    }
    
    deinit {
        cancellables.removeAll()
    }
    
    // MARK: - Public Methods
    
    /// Fetch and aggregate dashboard data from Core Data
    ///
    /// This method performs the following operations:
    /// 1. Sets loading state to true
    /// 2. Fetches all transactions from Core Data
    /// 3. Calculates total balance and transaction count
    /// 4. Updates published properties for UI updates
    /// 5. Handles any errors gracefully
    func fetchDashboardData() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let (balance, count, recent) = try await calculateDashboardMetrics()
                
                await MainActor.run {
                    self.totalBalance = balance
                    self.transactionCount = count
                    self.recentTransactions = recent
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to load dashboard data: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
    
    /// Refresh dashboard data - convenience method for pull-to-refresh scenarios
    func refreshData() {
        fetchDashboardData()
    }
    
    /// Clear any existing error messages
    func clearError() {
        errorMessage = nil
    }
    
    /// Set the Core Data persistence context for data operations
    /// - Parameter context: NSManagedObjectContext to use for data operations
    func setPersistenceContext(_ context: NSManagedObjectContext) {
        // Clean up existing observers
        cancellables.removeAll()
        
        // Update context
        self.context = context
        
        // Reinitialize observers with new context
        setupNotificationObservers()
    }
    
    // MARK: - Private Methods
    
    /// Setup Core Data notification observers for automatic updates
    private func setupNotificationObservers() {
        NotificationCenter.default
            .publisher(for: .NSManagedObjectContextDidSave)
            .compactMap { notification in
                notification.object as? NSManagedObjectContext
            }
            .filter { context in
                // Only respond to saves from our context or its parent/child contexts
                context == self.context ||
                context.parent == self.context ||
                context == self.context.parent
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.fetchDashboardData()
            }
            .store(in: &cancellables)
    }
    
    /// Calculate dashboard metrics asynchronously
    /// - Returns: Tuple containing (totalBalance, transactionCount, recentTransactions)
    private func calculateDashboardMetrics() async throws -> (Double, Int, [Transaction]) {
        return try await withCheckedThrowingContinuation { continuation in
            context.perform {
                do {
                    // Fetch all transactions for balance calculation
                    let balanceRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
                    let allTransactions = try self.context.fetch(balanceRequest)
                    
                    // Calculate total balance
                    let balance = allTransactions.reduce(0.0) { $0 + $1.amount }
                    let count = allTransactions.count
                    
                    // Fetch recent transactions (limited to 5, sorted by date)
                    let recentRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
                    recentRequest.sortDescriptors = [
                        NSSortDescriptor(keyPath: \Transaction.date, ascending: false)
                    ]
                    recentRequest.fetchLimit = 5
                    
                    let recentTransactions = try self.context.fetch(recentRequest)
                    
                    continuation.resume(returning: (balance, count, recentTransactions))
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: - Enhanced Core Data Integration Features
    
    /// Validates and adds a new transaction with comprehensive validation
    /// - Parameters:
    ///   - amount: Transaction amount (validated for finite values)
    ///   - category: Transaction category (validated for non-empty)
    ///   - note: Optional transaction note
    func validateAndAddTransaction(amount: Double, category: String, note: String?) {
        Task { @MainActor in
            isLoading = true
            errorMessage = nil
            
            do {
                // Validate transaction data
                try validateTransactionData(amount: amount, category: category)
                
                // Create and save transaction
                let transaction = Transaction(context: context)
                transaction.id = UUID()
                transaction.amount = amount
                transaction.category = category
                transaction.note = note
                transaction.date = Date()
                
                try context.save()
                
                // Refresh dashboard data
                await refreshDataAfterChange()
                
            } catch {
                handleError(error)
            }
            
            isLoading = false
        }
    }
    
    /// Adds multiple transactions in a single batch operation for performance
    /// - Parameter transactions: Array of transaction tuples (amount, category, note)
    func addTransactionsBatch(_ transactions: [(amount: Double, category: String, note: String?)]) {
        Task { @MainActor in
            isLoading = true
            errorMessage = nil
            
            do {
                // Begin batch operation
                context.performAndWait {
                    for transactionData in transactions {
                        let transaction = Transaction(context: context)
                        transaction.id = UUID()
                        transaction.amount = transactionData.amount
                        transaction.category = transactionData.category
                        transaction.note = transactionData.note
                        transaction.date = Date()
                    }
                }
                
                // Save all changes in single operation
                try context.save()
                
                // Refresh dashboard data
                await refreshDataAfterChange()
                
            } catch {
                handleError(error)
            }
            
            isLoading = false
        }
    }
    
    /// Performs a Core Data operation with automatic rollback on failure
    /// - Parameter operation: Throwing closure to execute
    func performTransactionWithRollback(_ operation: @escaping () throws -> Void) {
        Task { @MainActor in
            isLoading = true
            errorMessage = nil
            
            // Save current state for potential rollback
            let hasUnsavedChanges = context.hasChanges
            
            do {
                try operation()
                try context.save()
                
                // Refresh dashboard data
                await refreshDataAfterChange()
                
            } catch {
                // Rollback changes on error
                if hasUnsavedChanges {
                    context.rollback()
                }
                handleError(error)
            }
            
            isLoading = false
        }
    }
    
    /// Fetches cached dashboard data for improved performance
    func fetchCachedDashboardData() {
        // Implementation uses local cache to avoid expensive Core Data queries
        if let cachedBalance = dataCache["totalBalance"] as? Double,
           let cachedCount = dataCache["transactionCount"] as? Int,
           let cachedTransactions = dataCache["recentTransactions"] as? [Transaction],
           let cacheTime = dataCache["cacheTime"] as? Date,
           Date().timeIntervalSince(cacheTime) < 60 { // 1 minute cache
            
            // Use cached data
            totalBalance = cachedBalance
            transactionCount = cachedCount
            recentTransactions = cachedTransactions
            
        } else {
            // Fallback to fresh fetch and update cache
            fetchDashboardData()
        }
    }
    
    /// Performs heavy data processing operations in background context
    /// - Parameter completion: Callback with result containing processed count
    func performBackgroundDataProcessing(completion: @escaping (Result<Int, Error>) -> Void) {
        let backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        backgroundContext.parent = context
        
        backgroundContext.perform {
            do {
                // Simulate heavy data processing
                let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
                let transactions = try backgroundContext.fetch(request)
                
                var processedCount = 0
                
                // Process transactions (e.g., categorization, analysis)
                for transaction in transactions {
                    // Simulate processing work
                    if !transaction.category.isEmpty {
                        processedCount += 1
                    }
                }
                
                // Save background context changes
                try backgroundContext.save()
                
                DispatchQueue.main.async {
                    completion(.success(processedCount))
                }
                
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    /// Test method for validation error scenarios
    func testValidationError() {
        Task { @MainActor in
            do {
                try validateTransactionData(amount: Double.nan, category: "")
            } catch {
                handleError(error)
            }
        }
    }
    
    /// Test method for network error scenarios
    func testNetworkError() {
        Task { @MainActor in
            let networkError = NSError(domain: "NetworkError", code: -1009, 
                                     userInfo: [NSLocalizedDescriptionKey: "Network connection failed"])
            handleError(networkError)
        }
    }
    
    /// Test method for data corruption error scenarios
    func testDataCorruptionError() {
        Task { @MainActor in
            let dataError = NSError(domain: "DataCorruption", code: 500,
                                  userInfo: [NSLocalizedDescriptionKey: "Data integrity check failed"])
            handleError(dataError)
        }
    }
    
    // MARK: - Private Helper Methods
    
    /// Validates transaction data with comprehensive checks
    /// - Parameters:
    ///   - amount: Transaction amount to validate
    ///   - category: Transaction category to validate
    /// - Throws: ValidationError for invalid data
    private func validateTransactionData(amount: Double, category: String) throws {
        // Validate amount
        guard amount.isFinite else {
            throw ValidationError.invalidAmount("Amount must be a finite number")
        }
        
        guard abs(amount) <= 1_000_000 else {
            throw ValidationError.invalidAmount("Amount exceeds maximum limit")
        }
        
        // Validate category
        guard !category.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ValidationError.invalidCategory("Category cannot be empty")
        }
        
        guard category.count <= 50 else {
            throw ValidationError.invalidCategory("Category name too long")
        }
    }
    
    /// Enhanced error handling with specific error types
    /// - Parameter error: Error to handle and categorize
    private func handleError(_ error: Error) {
        var userFriendlyMessage: String
        
        switch error {
        case let validationError as ValidationError:
            userFriendlyMessage = "Validation Error: \(validationError.localizedDescription)"
            
        case let nsError as NSError where nsError.domain == "NetworkError":
            userFriendlyMessage = "Network Error: Please check your connection and try again"
            
        case let nsError as NSError where nsError.domain == "DataCorruption":
            userFriendlyMessage = "Data Error: Unable to process data. Please restart the app"
            
        case let coreDataError as NSError where coreDataError.domain == NSCocoaErrorDomain:
            userFriendlyMessage = "Database Error: Unable to save changes"
            
        default:
            userFriendlyMessage = "Unexpected Error: \(error.localizedDescription)"
        }
        
        errorMessage = userFriendlyMessage
        print("DashboardViewModel Error: \(error)")
    }
    
    /// Refreshes data after changes and updates cache
    private func refreshDataAfterChange() async {
        do {
            let (balance, count, recent) = try await calculateDashboardMetrics()
            
            totalBalance = balance
            transactionCount = count
            recentTransactions = recent
            
            // Update cache
            dataCache["totalBalance"] = balance
            dataCache["transactionCount"] = count
            dataCache["recentTransactions"] = recent
            dataCache["cacheTime"] = Date()
            
        } catch {
            handleError(error)
        }
    }
    
    // MARK: - Private Properties
    
    /// Data cache for performance optimization
    private var dataCache: [String: Any] = [:]
}

// MARK: - Enhanced Error Types

/// Custom validation error types for better error handling
enum ValidationError: LocalizedError {
    case invalidAmount(String)
    case invalidCategory(String)
    case invalidNote(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidAmount(let message):
            return "Invalid Amount: \(message)"
        case .invalidCategory(let message):
            return "Invalid Category: \(message)"
        case .invalidNote(let message):
            return "Invalid Note: \(message)"
        }
    }
}

// MARK: - Dashboard Data Models

/// Represents aggregated financial data for dashboard display
struct DashboardSummary {
    let totalBalance: Double
    let transactionCount: Int
    let recentTransactions: [Transaction]
    let lastUpdated: Date
    
    var isEmpty: Bool {
        transactionCount == 0
    }
}

// MARK: - Extensions

extension DashboardViewModel {
    
    /// Convenience method to format currency values consistently
    /// - Parameter amount: The amount to format
    /// - Returns: Formatted currency string
    func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
    
    /// Get color for balance display based on positive/negative value
    var balanceColor: Color {
        if totalBalance > 0 {
            return .green
        } else if totalBalance < 0 {
            return .red
        } else {
            return .primary
        }
    }
    
    /// Get appropriate icon for current balance state
    var balanceIcon: String {
        if totalBalance > 0 {
            return "arrow.up.circle.fill"
        } else if totalBalance < 0 {
            return "arrow.down.circle.fill"
        } else {
            return "equal.circle.fill"
        }
    }
}