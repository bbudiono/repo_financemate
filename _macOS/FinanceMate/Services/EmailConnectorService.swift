import Foundation
import CoreData

/// Consolidated service for Gmail email operations
/// Provides unified interface for email fetching, processing, and management
class EmailConnectorService {
    private let apiService: GmailAPIService
    private let cacheService: EmailCacheService
    private let coreDataManager: CoreDataManager

    init(
        apiService: GmailAPIService = GmailAPIService(),
        cacheService: EmailCacheService = EmailCacheService(),
        coreDataManager: CoreDataManager = CoreDataManager()
    ) {
        self.apiService = apiService
        self.cacheService = cacheService
        self.coreDataManager = coreDataManager
    }

    /// Check authentication status and refresh token if needed
    /// - Returns: True if authenticated, false otherwise
    func checkAuthentication() async -> Bool {
        return await apiService.checkAuthentication()
    }

    /// Complete OAuth flow with authorization code
    /// - Parameter authCode: Authorization code from OAuth callback
    /// - Throws: OAuthError on authentication failure
    func authenticate(with authCode: String) async throws {
        try await apiService.authenticate(with: authCode)
    }

    /// Fetch emails with caching support
    /// - Parameter maxResults: Maximum number of emails to fetch
    /// - Returns: Array of GmailEmail objects
    /// - Throws: GmailAPIError on fetch failure
    func fetchEmails(maxResults: Int = 500) async throws -> [GmailEmail] {
        // Try cache first
        if let cachedEmails = cacheService.loadCachedEmails() {
            return cachedEmails
        }

        // Fetch from API
        let emails = try await apiService.fetchEmails(maxResults: maxResults)

        // Save to cache
        cacheService.saveEmailsToCache(emails)

        return emails
    }

    /// Extract transactions from emails
    /// - Parameter emails: Array of emails to process
    /// - Returns: Array of extracted transactions
    func extractTransactions(from emails: [GmailEmail]) -> [ExtractedTransaction] {
        return emails.flatMap { apiService.extractTransactions(from: $0) }
    }

    /// Save extracted transaction to Core Data
    /// - Parameter transaction: Extracted transaction to save
    /// - Returns: True if saved successfully, false otherwise
    /// - Throws: CoreDataError on save failure
    func saveTransaction(_ transaction: ExtractedTransaction) async throws -> Bool {
        return try await coreDataManager.saveTransaction(transaction)
    }

    /// Save multiple transactions to Core Data
    /// - Parameter transactions: Array of transactions to save
    /// - Returns: Number of successfully saved transactions
    /// - Throws: CoreDataError on save failure
    func saveTransactions(_ transactions: [ExtractedTransaction]) async throws -> Int {
        return try await coreDataManager.saveTransactions(transactions)
    }

    /// Get all transactions from Core Data
    /// - Returns: Array of Transaction objects
    /// - Throws: CoreDataError on fetch failure
    func getAllTransactions() async throws -> [Transaction] {
        return try await coreDataManager.getAllTransactions()
    }

    /// Clear email cache
    func clearCache() {
        cacheService.clearCache()
    }

    /// Get authentication status
    /// - Returns: True if currently authenticated
    var isAuthenticated: Bool {
        return apiService.isAuthenticated
    }
}