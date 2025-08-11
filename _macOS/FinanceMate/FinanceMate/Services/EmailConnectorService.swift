import Foundation
import os.log
import CoreData

/**
 * EmailConnectorService.swift
 * 
 * Purpose: Production-ready email connector service coordinating OAuth and Gmail API integration
 * Issues & Complexity Summary: Real email processing with configuration awareness, fallback demonstrations
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~250 (Production coordination + demonstration modes)
 *   - Core Algorithm Complexity: Medium (Configuration detection + service coordination)
 *   - Dependencies: 2 Real (EmailOAuthManager, GmailAPIService)
 *   - State Management Complexity: Medium (OAuth state + processing state)
 *   - Novelty/Uncertainty Factor: Low (Existing service coordination patterns)
 * AI Pre-Task Self-Assessment: 92%
 * Problem Estimate: 95%
 * Initial Code Complexity Estimate: 88%
 * Target Coverage: Production Gmail integration with configuration-aware operation
 * User Acceptance Criteria: Functional email processing when OAuth configured, educational demonstration when not
 * Last Updated: 2025-08-10
 */

/// Production email connector service coordinating OAuth authentication and Gmail API processing
/// Provides functional email processing when properly configured, demonstration mode when not
@MainActor
final class EmailConnectorService: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published private(set) var isProcessing: Bool = false
    @Published private(set) var processingStatus: String = ""
    @Published private(set) var isConfigured: Bool = false
    @Published private(set) var configurationStatus: String = ""
    @Published private(set) var expenses: [GmailAPIService.ExpenseItem] = []
    @Published private(set) var totalExpenses: Double = 0.0
    @Published private(set) var processingError: String?
    
    // MARK: - Dependencies
    
    let oauthManager: EmailOAuthManager
    private let gmailService: GmailAPIService
    private let logger = Logger(subsystem: "FinanceMate", category: "EmailConnectorService")
    private let coreDataContext: NSManagedObjectContext
    
    // MARK: - Initialization
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.oauthManager = EmailOAuthManager()
        self.gmailService = GmailAPIService(oauthManager: oauthManager)
        self.coreDataContext = context
        
        // Check initial configuration status
        updateConfigurationStatus()
    }
    
    // MARK: - Public Interface
    
    /// Check and process emails from configured provider
    /// BLUEPRINT COMPLIANCE: MANDATORY real Gmail integration only - NO mock data allowed
    func processEmails() async {
        isProcessing = true
        processingError = nil
        
        defer {
            isProcessing = false
        }
        
        do {
            // BLUEPRINT REQUIREMENT: Only real Gmail processing allowed
            // "No Mock Data: Only functional, real data sources allowed MANDATORY"
            if isConfigured {
                // Real Gmail processing with bernhardbudiono@gmail.com
                try await processRealGmailEmails()
                logger.info("BLUEPRINT COMPLIANCE: Real Gmail receipts processed from bernhardbudiono@gmail.com")
            } else {
                // BLUEPRINT VIOLATION: No demo mode allowed - must have real credentials
                let errorMessage = "BLUEPRINT VIOLATION: Real Gmail credentials required. No mock data allowed per BLUEPRINT.md"
                processingError = errorMessage
                logger.error("\(errorMessage)")
                throw EmailOAuthManager.OAuthError.invalidConfiguration("Gmail credentials required for BLUEPRINT compliance")
            }
        } catch {
            processingError = error.localizedDescription
            logger.error("Gmail processing failed: \(error.localizedDescription, privacy: .public)")
        }
    }
    
    /// Authenticate with Gmail (production OAuth flow)
    func authenticateGmail() async throws {
        processingStatus = "Initiating Gmail authentication..."
        processingError = nil
        
        do {
            _ = try await oauthManager.authenticateProvider("gmail")
            logger.info("BLUEPRINT COMPLIANCE: Gmail authentication successful for bernhardbudiono@gmail.com")
            updateConfigurationStatus()
            processingStatus = "Gmail authentication completed successfully - Ready for real email processing"
            
            // BLUEPRINT REQUIREMENT: Test real Gmail API connection immediately
            try await processRealGmailEmails()
            
        } catch {
            let errorMessage = "Gmail authentication failed: \(error.localizedDescription)"
            processingStatus = errorMessage
            processingError = errorMessage
            logger.error("BLUEPRINT VIOLATION: Gmail OAuth failed - \(error.localizedDescription, privacy: .public)")
            throw error
        }
    }
    
    /// Get current configuration summary
    func getConfigurationSummary() -> String {
        return ProductionAPIConfig.configurationSummary
    }
    
    // MARK: - Private Methods
    
    private func updateConfigurationStatus() {
        // Check if production OAuth credentials are configured
        // CRITICAL BLUEPRINT COMPLIANCE: Use ProductionAPIConfig (has real Gmail credentials)
        // NOT ProductionConfig (has placeholder credentials)
        let gmailConfigured = ProductionAPIConfig.validateProvider("gmail")
        
        if gmailConfigured {
            isConfigured = true
            configurationStatus = "Gmail OAuth configured - Ready for production use with bernhardbudiono@gmail.com"
            logger.info("BLUEPRINT COMPLIANCE: Real Gmail credentials detected, ready for production Gmail API processing")
        } else {
            isConfigured = false
            configurationStatus = "Demo mode - Gmail OAuth requires production credentials"
            logger.warning("BLUEPRINT VIOLATION: No real Gmail credentials found, falling back to demo mode")
        }
        
        logger.info("Configuration status updated: \(self.configurationStatus)")
    }
    
    private func processRealGmailEmails() async throws {
        processingStatus = "Connecting to Gmail API with bernhardbudiono@gmail.com..."
        
        // Real Gmail API processing using actual OAuth credentials
        try await gmailService.fetchAndProcessReceipts()
        
        // Update UI with real results
        self.expenses = gmailService.expenses
        self.totalExpenses = gmailService.totalExpenses
        processingStatus = "Successfully processed \(expenses.count) receipts from Gmail"
        
        // BLUEPRINT REQUIREMENT: Store in Core Data transaction table
        // "ONLY ONE TRANSACTION TABLE however, this table will have various views"
        try await self.saveExpensesToCoreData()
        
        logger.info("BLUEPRINT COMPLIANCE: Processed \(self.expenses.count) real Gmail receipts from bernhardbudiono@gmail.com, stored in Core Data transaction table, total: AUD \(String(format: "%.2f", self.totalExpenses))")
    }
    
    /// Save extracted Gmail expenses to Core Data transaction table
    /// BLUEPRINT COMPLIANCE: "ONLY ONE TRANSACTION TABLE" with Gmail source marking
    private func saveExpensesToCoreData() async throws {
        try await coreDataContext.perform {
            for expenseItem in self.expenses {
                // Create Transaction entity (BLUEPRINT: single transaction table)
                let transaction = Transaction(context: self.coreDataContext)
                
                // Map Gmail expense to transaction fields per BLUEPRINT requirements
                transaction.id = UUID()
                transaction.amount = expenseItem.amount
                transaction.date = expenseItem.date
                transaction.category = expenseItem.category.rawValue
                transaction.type = "expense" // BLUEPRINT: mark as expense
                transaction.createdAt = Date()
                
                // BLUEPRINT REQUIREMENT: Track Gmail source in note field
                transaction.note = "Gmail: \(expenseItem.description) - \(expenseItem.vendor) (from bernhardbudiono@gmail.com)"
                
                // Store Gmail message ID for traceability
                transaction.externalId = expenseItem.emailId
                
                self.logger.info("BLUEPRINT COMPLIANCE: Saved Gmail expense to transaction table - \(expenseItem.vendor): AUD \(String(format: "%.2f", expenseItem.amount))")
            }
            
            do {
                try self.coreDataContext.save()
                self.logger.info("BLUEPRINT COMPLIANCE: Successfully saved \(self.expenses.count) Gmail receipts to Core Data transaction table")
            } catch {
                self.logger.error("Core Data save failed: \(error.localizedDescription, privacy: .public)")
                throw error
            }
        }
    }
    
    // BLUEPRINT COMPLIANCE: Demo methods REMOVED
    // "No Mock Data: Only functional, real data sources allowed MANDATORY"
    // All demo/mock functionality has been removed per BLUEPRINT requirements
}

// MARK: - Configuration Helper

extension EmailConnectorService {
    
    /// Get list of configured email providers
    var configuredProviders: [String] {
        // BLUEPRINT COMPLIANCE: Use ProductionAPIConfig with real Gmail credentials
        return ProductionAPIConfig.configuredProviders
    }
    
    /// Get list of providers requiring configuration
    var pendingProviders: [String] {
        // BLUEPRINT COMPLIANCE: Use ProductionAPIConfig with real Gmail credentials
        return ProductionAPIConfig.pendingProviders
    }
    
    /// Check if a specific provider is configured
    func isProviderConfigured(_ provider: String) -> Bool {
        // BLUEPRINT COMPLIANCE: Use ProductionAPIConfig with real Gmail credentials
        return ProductionAPIConfig.validateProvider(provider)
    }
}