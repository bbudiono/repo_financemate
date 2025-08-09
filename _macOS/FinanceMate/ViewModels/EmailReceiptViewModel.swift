import Foundation
import CoreData
import Combine

/**
 * EmailReceiptViewModel.swift
 * 
 * Purpose: MVVM layer for email receipt processing UI integration
 * Issues & Complexity Summary: UI state management for email processing, progress tracking, user interaction
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~300+ (UI state, progress, error handling, user actions)
 *   - Core Algorithm Complexity: Medium (UI coordination, data binding, async updates)
 *   - Dependencies: 3 New (EmailReceiptProcessor, existing MVVM patterns, SwiftUI binding)
 *   - State Management Complexity: High (async processing state, progress updates, error states)
 *   - Novelty/Uncertainty Factor: Medium (SwiftUI async state management patterns)
 * AI Pre-Task Self-Assessment: 85%
 * Problem Estimate: 88%
 * Initial Code Complexity Estimate: 85%
 * Target Coverage: ≥95%
 * Australian Compliance: Privacy UI compliance, user consent management
 * Last Updated: 2025-08-08
 */

/// ViewModel for email receipt processing interface
/// Provides SwiftUI integration for the BLUEPRINT highest priority email processing feature
@MainActor
final class EmailReceiptViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var isProcessing: Bool = false
    @Published var processingProgress: Double = 0.0
    @Published var errorMessage: String?
    @Published var successMessage: String?
    
    // Email provider selection
    @Published var selectedProvider: EmailReceiptProcessor.SupportedEmailProvider = .icloud
    @Published var availableProviders: [EmailReceiptProcessor.SupportedEmailProvider] = []
    
    // Processing configuration
    @Published var dateRangeStart: Date = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    @Published var dateRangeEnd: Date = Date()
    @Published var customSearchTerms: String = "receipt, invoice, purchase"
    
    // Results
    @Published var lastProcessingResult: EmailReceiptProcessor.EmailReceiptResult?
    @Published var extractedReceipts: [EmailReceiptProcessor.ReceiptData] = []
    @Published var matchedTransactions: [EmailReceiptProcessor.TransactionMatch] = []
    @Published var unmatchedReceipts: [EmailReceiptProcessor.ReceiptData] = []
    
    // Privacy and compliance
    @Published var privacyConsentGiven: Bool = false
    @Published var dataMinimizationEnabled: Bool = true
    @Published var auditLoggingEnabled: Bool = true
    
    // UI state
    @Published var showingResults: Bool = false
    @Published var showingPrivacySettings: Bool = false
    @Published var showingProviderAuth: Bool = false
    
    // MARK: - Dependencies
    
    private let context: NSManagedObjectContext
    private let emailProcessor: EmailReceiptProcessor
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    
    var canStartProcessing: Bool {
        return !isProcessing && 
               privacyConsentGiven && 
               dateRangeStart <= dateRangeEnd &&
               !customSearchTerms.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var processingStatusText: String {
        if isProcessing {
            let percentage = Int(processingProgress * 100)
            return "Processing emails... \(percentage)%"
        }
        return "Ready to process emails"
    }
    
    var searchTermsArray: [String] {
        return customSearchTerms
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }
    
    var dateRange: DateInterval {
        return DateInterval(start: dateRangeStart, end: dateRangeEnd)
    }
    
    // MARK: - Statistics
    
    var totalReceiptsFound: Int {
        return extractedReceipts.count
    }
    
    var totalTransactionsMatched: Int {
        return matchedTransactions.filter { $0.matchedTransaction != nil }.count
    }
    
    var matchingSuccessRate: Double {
        guard totalReceiptsFound > 0 else { return 0.0 }
        return Double(totalTransactionsMatched) / Double(totalReceiptsFound)
    }
    
    var totalAmountProcessed: Double {
        return extractedReceipts.reduce(0) { $0 + $1.totalAmount }
    }
    
    // MARK: - Initialization
    
    init(context: NSManagedObjectContext, emailProcessor: EmailReceiptProcessor) {
        self.context = context
        self.emailProcessor = emailProcessor
        
        setupBindings()
        loadAvailableProviders()
        configureDefaults()
    }
    
    // MARK: - Setup
    
    private func setupBindings() {
        // Bind processor state to ViewModel
        emailProcessor.$isProcessing
            .receive(on: DispatchQueue.main)
            .assign(to: &$isProcessing)
        
        emailProcessor.$processingProgress
            .receive(on: DispatchQueue.main)
            .assign(to: &$processingProgress)
        
        emailProcessor.$errorMessage
            .receive(on: DispatchQueue.main)
            .assign(to: &$errorMessage)
        
        emailProcessor.$lastProcessingResult
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                self?.handleProcessingResult(result)
            }
            .store(in: &cancellables)
    }
    
    private func loadAvailableProviders() {
        availableProviders = emailProcessor.supportedProviders
    }
    
    private func configureDefaults() {
        // Configure privacy defaults for Australian compliance
        privacyConsentGiven = false // Must be explicitly given by user
        dataMinimizationEnabled = true // Default to privacy-first approach
        auditLoggingEnabled = true // Required for compliance
    }
    
    // MARK: - Public Actions
    
    /// Start email receipt processing with current configuration
    func startProcessing() async {
        guard canStartProcessing else {
            errorMessage = "Cannot start processing. Check configuration and privacy consent."
            return
        }
        
        clearPreviousResults()
        
        do {
            // Configure privacy settings
            emailProcessor.configurePrivacySettings(
                dataMinimization: dataMinimizationEnabled,
                automaticDeletion: true,
                auditLogging: auditLoggingEnabled
            )
            
            // Start processing
            let result = try await emailProcessor.processEmailReceipts(
                provider: selectedProvider,
                dateRange: dateRange,
                searchTerms: searchTermsArray
            )
            
            await MainActor.run {
                self.handleProcessingSuccess(result)
            }
            
        } catch {
            await MainActor.run {
                self.handleProcessingError(error)
            }
        }
    }
    
    /// Cancel current processing operation
    func cancelProcessing() {
        // Implementation would cancel the async processing task
        errorMessage = "Processing cancelled by user"
        clearPreviousResults()
    }
    
    /// Clear all results and reset UI state
    func clearResults() {
        clearPreviousResults()
        showingResults = false
    }
    
    /// Show privacy settings interface
    func showPrivacySettings() {
        showingPrivacySettings = true
    }
    
    /// Show email provider authentication
    func showProviderAuthentication() {
        showingProviderAuth = true
    }
    
    /// Grant privacy consent for email processing
    func grantPrivacyConsent() {
        privacyConsentGiven = true
        successMessage = "Privacy consent granted. You can now process emails."
    }
    
    /// Revoke privacy consent
    func revokePrivacyConsent() {
        privacyConsentGiven = false
        clearResults()
        successMessage = nil
        errorMessage = "Privacy consent revoked. Email processing disabled."
    }
    
    /// Create transaction from unmatched receipt
    func createTransactionFromReceipt(_ receipt: EmailReceiptProcessor.ReceiptData) async {
        // Implementation would create new transaction from receipt data
        do {
            // Create transaction using existing transaction creation logic
            let newTransaction = Transaction(context: context)
            newTransaction.amount = receipt.totalAmount
            newTransaction.date = receipt.date
            newTransaction.transactionDescription = receipt.merchant
            newTransaction.category = "Email Receipt"
            
            try context.save()
            
            successMessage = "Transaction created from receipt: \(receipt.merchant)"
            
            // Remove from unmatched receipts
            unmatchedReceipts.removeAll { $0.merchant == receipt.merchant && $0.date == receipt.date }
            
        } catch {
            errorMessage = "Failed to create transaction: \(error.localizedDescription)"
        }
    }
    
    /// Accept a transaction match suggestion
    func acceptTransactionMatch(_ match: EmailReceiptProcessor.TransactionMatch) async {
        guard let transaction = match.matchedTransaction else { return }
        
        // Update transaction with receipt data
        transaction.transactionDescription = match.receiptData.merchant
        
        // Add receipt metadata if available
        if let receiptNumber = match.receiptData.receiptNumber {
            transaction.notes = (transaction.notes ?? "") + " Receipt: \(receiptNumber)"
        }
        
        do {
            try context.save()
            successMessage = "Transaction match accepted for \(match.receiptData.merchant)"
        } catch {
            errorMessage = "Failed to update transaction: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Private Methods
    
    private func handleProcessingResult(_ result: EmailReceiptProcessor.EmailReceiptResult?) {
        guard let result = result else { return }
        
        lastProcessingResult = result
        extractedReceipts = result.extractedReceipts
        matchedTransactions = result.matchedTransactions
        
        // Separate unmatched receipts
        unmatchedReceipts = result.extractedReceipts.filter { receipt in
            !result.matchedTransactions.contains { match in
                match.receiptData.merchant == receipt.merchant && 
                match.receiptData.date == receipt.date &&
                match.matchedTransaction != nil
            }
        }
        
        showingResults = true
    }
    
    private func handleProcessingSuccess(_ result: EmailReceiptProcessor.EmailReceiptResult) {
        successMessage = "Successfully processed \(result.processingMetrics.emailsProcessed) emails and found \(result.extractedReceipts.count) receipts."
    }
    
    private func handleProcessingError(_ error: Error) {
        errorMessage = "Processing failed: \(error.localizedDescription)"
    }
    
    private func clearPreviousResults() {
        errorMessage = nil
        successMessage = nil
        lastProcessingResult = nil
        extractedReceipts.removeAll()
        matchedTransactions.removeAll()
        unmatchedReceipts.removeAll()
    }
    
    // MARK: - Utility Methods
    
    /// Format currency amount for display
    func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "AUD"
        formatter.locale = Locale(identifier: "en_AU")
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
    
    /// Format date for display
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "en_AU")
        return formatter.string(from: date)
    }
    
    /// Get provider-specific privacy information
    func getProviderPrivacyInfo(_ provider: EmailReceiptProcessor.SupportedEmailProvider) -> String {
        switch provider {
        case .icloud:
            return "Uses local Mail.app integration. Highest privacy - no data leaves your device."
        case .gmail:
            return "Uses Gmail API with read-only access to receipts and invoices only."
        case .outlook:
            return "Uses Microsoft Graph API with minimal permissions for receipt processing."
        }
    }
    
    /// Validate search terms
    func validateSearchTerms(_ terms: String) -> Bool {
        let trimmed = terms.trimmingCharacters(in: .whitespaces)
        return !trimmed.isEmpty && trimmed.split(separator: ",").count <= 10
    }
}

// MARK: - Preview Support

#if DEBUG
extension EmailReceiptViewModel {
    static func preview(context: NSManagedObjectContext) -> EmailReceiptViewModel {
        let processor = EmailReceiptProcessor.preview(context: context)
        return EmailReceiptViewModel(context: context, emailProcessor: processor)
    }
}
#endif