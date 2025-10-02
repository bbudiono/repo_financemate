import SwiftUI
import CoreData

@MainActor
class GmailViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var emails: [GmailEmail] = []
    @Published var extractedTransactions: [ExtractedTransaction] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showCodeInput = false
    @Published var authCode = ""

    private let viewContext: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.viewContext = context
    }

    func checkAuthentication() async {
        if KeychainHelper.get(account: "gmail_refresh_token") != nil {
            await refreshAccessToken()
        }
    }

    func exchangeCode() async {
        guard let clientID = ProcessInfo.processInfo.environment["GOOGLE_OAUTH_CLIENT_ID"],
              let clientSecret = ProcessInfo.processInfo.environment["GOOGLE_OAUTH_CLIENT_SECRET"] else {
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

        guard let clientID = ProcessInfo.processInfo.environment["GOOGLE_OAUTH_CLIENT_ID"],
              let clientSecret = ProcessInfo.processInfo.environment["GOOGLE_OAUTH_CLIENT_SECRET"] else {
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

        isLoading = true
        errorMessage = nil

        do {
            emails = try await GmailAPI.fetchEmails(accessToken: accessToken, maxResults: 10)
            await extractTransactionsFromEmails()
        } catch {
            errorMessage = "Failed to fetch emails: \(error.localizedDescription)"
        }

        isLoading = false
    }

    // MARK: - Transaction Extraction

    func extractTransactionsFromEmails() async {
        extractedTransactions = emails.compactMap { GmailAPI.extractTransaction(from: $0) }
            .filter { $0.confidence >= 0.6 } // Only show 60%+ confidence
            .sorted { $0.confidence > $1.confidence }
    }

    func createTransaction(from extracted: ExtractedTransaction) {
        let transaction = Transaction(context: viewContext)
        transaction.id = UUID()
        transaction.amount = extracted.amount
        transaction.itemDescription = extracted.merchant
        transaction.category = extracted.category
        transaction.taxCategory = TaxCategory.personal.rawValue
        transaction.date = extracted.date
        transaction.source = "gmail"
        transaction.note = "Merchant: \(extracted.merchant) | Confidence: \(Int(extracted.confidence * 100))%"

        // BLUEPRINT Line 63: Persist each line item with individual tax categories
        for item in extracted.items {
            guard let lineItem = NSEntityDescription.insertNewObject(forEntityName: "LineItem", into: viewContext) as? LineItem else {
                errorMessage = "Failed to create line item entity"
                continue
            }
            lineItem.id = UUID()
            lineItem.itemDescription = item.description
            lineItem.quantity = Int32(item.quantity)
            lineItem.price = item.price
            lineItem.taxCategory = TaxCategory.personal.rawValue
            lineItem.transaction = transaction
        }

        do {
            try viewContext.save()
        } catch {
            errorMessage = "Failed to save transaction: \(error.localizedDescription)"
        }
    }

    func createAllTransactions() {
        extractedTransactions.forEach { createTransaction(from: $0) }
        extractedTransactions.removeAll()
    }
}
