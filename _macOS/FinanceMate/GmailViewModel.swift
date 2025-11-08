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
    @Published var showCodeInput = false // Deprecated - kept for compatibility but hidden in UI
    @Published var authCode = ""
    @Published var showArchivedEmails = false // BLUEPRINT Line 102: Toggle for archived items

    // RESTORATION: LocalOAuthServer for automatic OAuth callback handling
    private let oauthServer = LocalOAuthServer()

    // BLUEPRINT Line 150: Batch processing progress
    @Published var isBatchProcessing = false
    @Published var batchProgressProcessed = 0
    @Published var batchProgressTotal = 0
    @Published var batchErrorCount = 0
    @Published var estimatedTimeRemaining: TimeInterval?

    private let viewContext: NSManagedObjectContext
    private let emailRepository: GmailEmailRepository
    private let paginationManager = PaginationManager(pageSize: 50)
    private let importTracker: ImportTracker
    private let transactionBuilder: TransactionBuilder

    init(context: NSManagedObjectContext) {
        self.viewContext = context
        self.emailRepository = GmailEmailRepository(context: context)
        self.importTracker = ImportTracker(context: context)
        self.transactionBuilder = TransactionBuilder(context: context)
    }

    func checkAuthentication() async {
        if KeychainHelper.get(account: "gmail_refresh_token") != nil {
            await refreshAccessToken()
        }
    }

    /// RESTORATION: Start automatic OAuth flow with LocalOAuthServer
    /// This replaces the manual code entry UX - user just clicks "Allow" in browser
    func startAutomaticOAuthFlow() {
        guard let clientID = DotEnvLoader.get("GOOGLE_OAUTH_CLIENT_ID"),
              let clientSecret = DotEnvLoader.get("GOOGLE_OAUTH_CLIENT_SECRET") else {
            errorMessage = "OAuth credentials not found in .env"
            return
        }

        // Start local server to catch OAuth callback
        do {
            try oauthServer.startServer(port: 8080) { [weak self] authCode in
                Task { @MainActor in
                    guard let self = self else { return }

                    NSLog("✅ OAuth callback received automatically - exchanging code for token")
                    self.authCode = authCode

                    // Automatically exchange the code without user intervention
                    await self.exchangeCode()
                }
            }

            // Generate OAuth URL and open in browser
            if let url = GmailOAuthHelper.getAuthorizationURL(clientID: clientID) {
                NSLog("🌐 Opening OAuth URL in browser: \(url.absoluteString)")
                NSLog("🎯 LocalOAuthServer listening on http://localhost:8080")
                NSWorkspace.shared.open(url)
            } else {
                oauthServer.stopServer()
                errorMessage = "Failed to generate OAuth URL"
            }
        } catch {
            errorMessage = "Failed to start OAuth server: \(error.localizedDescription)"
            NSLog("❌ LocalOAuthServer failed to start: \(error)")
        }
    }

    func exchangeCode() async {
        guard let clientID = DotEnvLoader.get("GOOGLE_OAUTH_CLIENT_ID"),
              let clientSecret = DotEnvLoader.get("GOOGLE_OAUTH_CLIENT_SECRET") else {
            errorMessage = "OAuth credentials not found"
            oauthServer.stopServer() // Clean up on error
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
            oauthServer.stopServer() // Stop server after successful auth
            NSLog("✅ OAuth flow complete - server stopped")
            await fetchEmails()
        } catch {
            errorMessage = "Failed to exchange code: \(error.localizedDescription)"
            oauthServer.stopServer() // Clean up on error
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

        // BLUEPRINT Lines 74, 91: Load from permanent Core Data storage (replaces 1-hour cache)
        do {
            // Try loading from Core Data first
            let cachedEmails = try emailRepository.loadAllEmails()
            if !cachedEmails.isEmpty {
                emails = cachedEmails
                NSLog("[GmailViewModel] Loaded \(cachedEmails.count) emails from Core Data (no API call needed)")
                await extractTransactionsFromEmails()
                return
            }
        } catch {
            NSLog("[GmailViewModel] Error loading cached emails: \(error)")
        }

        isLoading = true
        errorMessage = nil

        do {
            // BLUEPRINT Line 71: Fetch 5 years of financial emails from "All Mail"
            // CRITICAL FIX: Use delta sync to only fetch NEW emails (not all 500 every time)
            let apiQuery = emailRepository.buildDeltaSyncQuery()
            emails = try await GmailAPI.fetchEmails(
                accessToken: accessToken,
                maxResults: 500,
                query: apiQuery
            )

            // CRITICAL FIX: Save to Core Data (permanent storage, not 1-hour UserDefaults cache)
            try emailRepository.saveEmails(emails)

            // Reload all emails from repository (existing + new)
            emails = try emailRepository.loadAllEmails()
            NSLog("[GmailViewModel] Synced emails: \(emails.count) total (delta sync applied)")

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

    // BLUEPRINT Line 149: Filter emails by status
    var filteredEmails: [GmailEmail] {
        if showArchivedEmails {
            return emails
        } else {
            return emails.filter { $0.status == .needsReview }
        }
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

    // MARK: - Status Management

    func archiveEmail(id: String) {
        if let index = emails.firstIndex(where: { $0.id == id }) {
            emails[index].status = .archived
        }
    }

    func archiveSelectedEmails() {
        for id in selectedIDs {
            archiveEmail(id: id)
        }
        selectedIDs.removeAll()
    }

    func extractTransactionsFromEmails() async {
        NSLog("=== EXTRACTION START ===")
        NSLog("Total emails: \(emails.count)")
        GmailDebugLogger.saveEmailsForDebug(emails)

        // BLUEPRINT Line 150: Use concurrent batch processing with progress
        isBatchProcessing = true
        batchProgressProcessed = 0
        batchProgressTotal = emails.count
        batchErrorCount = 0

        let startTime = Date()

        let allExtracted = await IntelligentExtractionService.extractBatch(
            emails,
            maxConcurrency: 5
        ) { @Sendable [weak self] processed, total, errors in
            guard let self = self else { return }
            await MainActor.run {
                self.batchProgressProcessed = processed
                self.batchProgressTotal = total
                self.batchErrorCount = errors

                // Calculate estimated time remaining
                let elapsed = Date().timeIntervalSince(startTime)
                if processed > 0 {
                    let avgTimePerEmail = elapsed / Double(processed)
                    let remaining = Double(total - processed) * avgTimePerEmail
                    self.estimatedTimeRemaining = remaining
                }
            }
        }

        isBatchProcessing = false

        NSLog("Extracted: \(allExtracted.count) transactions")

        // FIX: Validate ALL extracted transactions against source emails BEFORE assignment
        var validatedTransactions: [ExtractedTransaction] = []
        var corruptedCount = 0

        for tx in allExtracted {
            // Find source email by ID
            guard let sourceEmail = emails.first(where: { $0.id == tx.id }) else {
                NSLog("[GMAIL-CORRUPTION] CRITICAL - No source email found for transaction ID: \(tx.id)")
                corruptedCount += 1
                continue
            }

            // Validate transaction fields match source email
            guard tx.emailSender == sourceEmail.sender else {
                NSLog("[GMAIL-CORRUPTION] CRITICAL - Sender mismatch | Email: \(sourceEmail.sender) | Transaction: \(tx.emailSender) | Merchant: \(tx.merchant)")
                corruptedCount += 1
                continue
            }

            guard tx.emailSubject == sourceEmail.subject else {
                NSLog("[GMAIL-CORRUPTION] CRITICAL - Subject mismatch | Email: \(sourceEmail.subject) | Transaction: \(tx.emailSubject)")
                corruptedCount += 1
                continue
            }

            // Transaction is valid
            validatedTransactions.append(tx)
        }

        if corruptedCount > 0 {
            NSLog("[GMAIL-CORRUPTION] WARNING - Rejected \(corruptedCount) corrupted transactions out of \(allExtracted.count)")
        }

        extractedTransactions = validatedTransactions
            .filter { $0.confidence >= 0.6 }
            .sorted { $0.confidence > $1.confidence }

        NSLog("After validation & filter (≥0.6): \(extractedTransactions.count)")

        for (i, tx) in extractedTransactions.prefix(3).enumerated() {
            NSLog("\(i+1). \(tx.merchant) $\(tx.amount) (\(Int(tx.confidence*100))%) | From: \(tx.emailSender)")
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

    /// CLAUDE.md Line 77: Re-apply extraction rules to cached emails (don't delete data)
    /// Correct approach: Update merchants using new logic, preserve downloaded emails
    func reApplyExtractionRules() async {
        NSLog("[RE-APPLY-RULES] Starting re-extraction of \(emails.count) cached emails")
        NSLog("[RE-APPLY-RULES] CORRECT: Updating merchants, NOT deleting email cache")

        // Re-run extraction on existing emails with NEW merchant logic
        await extractTransactionsFromEmails()

        NSLog("[RE-APPLY-RULES] Complete: \(extractedTransactions.count) transactions with updated merchants")
    }
}
