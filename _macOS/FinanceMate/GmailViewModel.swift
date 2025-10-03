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

    init(context: NSManagedObjectContext) {
        self.viewContext = context
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

        isLoading = true
        errorMessage = nil

        do {
            // BLUEPRINT Line 71: Fetch 5 years of financial emails from "All Mail"
            emails = try await GmailAPI.fetchEmails(accessToken: accessToken, maxResults: 500)
            await extractTransactionsFromEmails()
        } catch {
            errorMessage = "Failed to fetch emails: \(error.localizedDescription)"
        }

        isLoading = false
    }

    // MARK: - Transaction Extraction

    func extractTransactionsFromEmails() async {
        // Debug: Save email content for analysis
        GmailDebugLogger.saveEmailsForDebug(emails)

        // BLUEPRINT Line 66: Each line item becomes a distinct transaction
        extractedTransactions = emails.flatMap { GmailAPI.extractTransactions(from: $0) }
            .filter { $0.confidence >= 0.6 } // Only show 60%+ confidence
            .sorted { $0.confidence > $1.confidence }

        NSLog("Extracted \(extractedTransactions.count) transactions from \(emails.count) emails")
    }

    func createTransaction(from extracted: ExtractedTransaction) {
        NSLog("=== CREATE TRANSACTION CALLED ===")
        NSLog("Merchant: %@", extracted.merchant)
        NSLog("Amount: %.2f", extracted.amount)

        let transaction = Transaction(context: viewContext)
        transaction.id = UUID()
        transaction.amount = extracted.amount
        transaction.itemDescription = extracted.merchant
        transaction.category = extracted.category
        transaction.taxCategory = TaxCategory.personal.rawValue
        transaction.date = extracted.date
        transaction.source = "gmail"

        // Enhanced note with comprehensive expense details
        transaction.note = buildTransactionNote(from: extracted)

        // BLUEPRINT Line 63: Persist each line item with individual tax categories
        NSLog("Creating %d line items", extracted.items.count)
        createLineItems(for: transaction, from: extracted.items)

        saveTransaction()
    }

    private func createLineItems(for transaction: Transaction, from items: [GmailLineItem]) {
        for item in items {
            guard let lineItem = NSEntityDescription.insertNewObject(forEntityName: "LineItem", into: viewContext) as? LineItem else {
                errorMessage = "Failed to create line item entity"
                NSLog("ERROR: Failed to create line item")
                continue
            }
            lineItem.id = UUID()
            lineItem.itemDescription = item.description
            lineItem.quantity = Int32(item.quantity)
            lineItem.price = item.price
            lineItem.taxCategory = TaxCategory.personal.rawValue
            lineItem.transaction = transaction
        }
    }

    private func saveTransaction() {
        do {
            try viewContext.save()
            NSLog(" Transaction saved successfully")
        } catch {
            errorMessage = "Failed to save transaction: \(error.localizedDescription)"
            NSLog(" Save failed: %@", error.localizedDescription)
        }
    }

    func createAllTransactions() {
        extractedTransactions.forEach { createTransaction(from: $0) }
        extractedTransactions.removeAll()
    }

    private func buildTransactionNote(from extracted: ExtractedTransaction) -> String {
        var components = [
            "Email: \(extracted.emailSubject)",
            "From: \(extracted.emailSender)",
            "Confidence: \(Int(extracted.confidence * 100))%"
        ]

        if let gst = extracted.gstAmount {
            components.append("GST: $\(String(format: "%.2f", gst))")
        }
        if let abn = extracted.abn {
            components.append("ABN: \(abn)")
        }
        if let invoice = extracted.invoiceNumber {
            components.append("Invoice#: \(invoice)")
        }
        if let payment = extracted.paymentMethod {
            components.append("Payment: \(payment)")
        }

        return components.joined(separator: " | ")
    }
}
