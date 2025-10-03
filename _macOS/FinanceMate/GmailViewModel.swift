import SwiftUI
import CoreData

@MainActor
class GmailViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var emails: [GmailEmail] = []
    @Published var extractedTransactions: [ExtractedTransaction] = []
    @Published var selectedIDs: Set<String> = [] // For table row selection
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showCodeInput = false
    @Published var authCode = ""

    private let viewContext: NSManagedObjectContext
    private let cacheService = EmailCacheService()
    private let paginationManager = PaginationManager(pageSize: 50)
    private let importTracker: ImportTracker
    private let transactionBuilder: TransactionBuilder

    init(context: NSManagedObjectContext) {
        self.viewContext = context
        self.importTracker = ImportTracker(context: context)
        self.transactionBuilder = TransactionBuilder(context: context)
    }

    func checkAuthentication() async {
        if KeychainHelper.get(account: "gmail_refresh_token") != nil {
            await refreshAccessToken()
        }
    }

    func exchangeCode() async {
        guard let clientID = DotEnvLoader.get("GOOGLE_OAUTH_CLIENT_ID"),
              let clientSecret = DotEnvLoader.get("GOOGLE_OAUTH_CLIENT_SECRET") else {
            errorMessage = "OAuth credentials not found"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            _ = try await GmailOAuthHelper.exchangeCodeForToken(
                code: authCode,
                clientID: clientID,
                clientSecret: clientSecret
            )
            isAuthenticated = true
            showCodeInput = false
            await fetchEmails()
        } catch {
            errorMessage = "Failed to exchange code: \(error.localizedDescription)"
        }

        isLoading = false
    }

    private func refreshAccessToken() async {
        guard let refreshToken = KeychainHelper.get(account: "gmail_refresh_token") else {
            errorMessage = "No refresh token found. Configure OAuth first."
            return
        }

        guard let clientID = DotEnvLoader.get("GOOGLE_OAUTH_CLIENT_ID"),
              let clientSecret = DotEnvLoader.get("GOOGLE_OAUTH_CLIENT_SECRET") else {
            errorMessage = "OAuth credentials not found in .env"
            return
        }

        do {
            let token = try await GmailAPI.refreshToken(
                refreshToken: refreshToken,
                clientID: clientID,
                clientSecret: clientSecret
            )

            KeychainHelper.save(value: token.accessToken, account: "gmail_access_token")
            isAuthenticated = true
        } catch {
            errorMessage = "Token refresh failed: \(error.localizedDescription)"
        }
    }

    func fetchEmails() async {
        guard let accessToken = KeychainHelper.get(account: "gmail_access_token") else { return }

        // BLUEPRINT Lines 74, 91: Try cache first
        if let cachedEmails = cacheService.loadCachedEmails() {
            emails = cachedEmails
            await extractTransactionsFromEmails()
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            // BLUEPRINT Line 71: Fetch 5 years of financial emails from "All Mail"
            emails = try await GmailAPI.fetchEmails(accessToken: accessToken, maxResults: 500)
            cacheService.saveEmailsToCache(emails)
            await extractTransactionsFromEmails()
        } catch {
            errorMessage = "Failed to fetch emails: \(error.localizedDescription)"
        }

        isLoading = false
    }

    // MARK: - Transaction Extraction

    var unprocessedEmails: [ExtractedTransaction] {
        importTracker.filterUnprocessed(extractedTransactions)
    }

    var paginatedTransactions: [ExtractedTransaction] {
        paginationManager.paginatedResults(unprocessedEmails)
    }

    var hasMorePages: Bool {
        paginationManager.hasMorePages(totalCount: unprocessedEmails.count)
    }

    func loadNextPage() {
        paginationManager.loadNextPage(totalCount: unprocessedEmails.count)
    }

    func extractTransactionsFromEmails() async {
        NSLog("=== EXTRACTION DEBUG ===")
        NSLog("Total emails fetched: \(emails.count)")

        // Debug: Save email content for analysis
        GmailDebugLogger.saveEmailsForDebug(emails)

        // BLUEPRINT Line 66: Each line item becomes a distinct transaction
        let allExtracted = emails.flatMap { GmailAPI.extractTransactions(from: $0) }
        NSLog("Total transactions extracted (before filter): \(allExtracted.count)")

        extractedTransactions = allExtracted
            .filter { $0.confidence >= 0.6 } // Only show 60%+ confidence
            .sorted { $0.confidence > $1.confidence }

        NSLog("After confidence filter (≥0.6): \(extractedTransactions.count) transactions")
        NSLog("Filtered out: \(allExtracted.count - extractedTransactions.count) low-confidence transactions")

        // Log first few for debugging
        for (index, transaction) in extractedTransactions.prefix(3).enumerated() {
            NSLog("Transaction \(index + 1): \(transaction.merchant) - $\(transaction.amount) (conf: \(transaction.confidence))")
        }
    }

    func createTransaction(from extracted: ExtractedTransaction) {
        if transactionBuilder.createTransaction(from: extracted) == nil {
            errorMessage = "Failed to save transaction"
        }
    }

    func createAllTransactions() {
        extractedTransactions.forEach { createTransaction(from: $0) }
        extractedTransactions.removeAll()
    }
}
