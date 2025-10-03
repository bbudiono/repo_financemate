import SwiftUI

struct GmailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: GmailViewModel

    init() {
        // Initialize GmailViewModel with Core Data context
        let context = PersistenceController.shared.container.viewContext
        _viewModel = StateObject(wrappedValue: GmailViewModel(context: context))
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Gmail Receipts")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            if !viewModel.isAuthenticated {
                VStack(spacing: 16) {
                    Image(systemName: "envelope.circle")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)

                    Text("Connect Gmail Account")
                        .font(.title2)

                    Text("Click button to open browser for OAuth")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Button("Connect Gmail") {
                        // Get credentials from DotEnvLoader (not ProcessInfo - sandboxing issue)
                        let clientID = DotEnvLoader.get("GOOGLE_OAUTH_CLIENT_ID")
                        let clientSecret = DotEnvLoader.get("GOOGLE_OAUTH_CLIENT_SECRET")

                        NSLog("=== GMAIL BUTTON CLICKED ===")
                        NSLog("Client ID: %@", clientID ?? "NOT FOUND")
                        NSLog("Client Secret: %@", clientSecret != nil ? "FOUND" : "NOT FOUND")

                        if let clientID = clientID,
                           let url = GmailOAuthHelper.getAuthorizationURL(clientID: clientID) {
                            NSLog("Generated OAuth URL: %@", url.absoluteString)
                            NSLog("Opening URL in browser...")
                            NSWorkspace.shared.open(url)
                            viewModel.showCodeInput = true
                        } else {
                            NSLog("FAILED: Could not generate OAuth URL")
                            NSLog("Client ID nil: %@", clientID == nil ? "YES" : "NO")
                            viewModel.errorMessage = "OAuth not configured. Check .env file."
                        }
                    }
                    .buttonStyle(.borderedProminent)

                    if viewModel.showCodeInput {
                        TextField("Enter authorization code", text: $viewModel.authCode)
                            .textFieldStyle(.roundedBorder)
                            .frame(maxWidth: 400)

                        Button("Submit Code") {
                            Task {
                                await viewModel.exchangeCode()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            } else {
                if viewModel.isLoading {
                    ProgressView("Loading emails...")
                } else if viewModel.extractedTransactions.isEmpty {
                    Text("No transactions detected in emails")
                        .foregroundColor(.secondary)
                    Button("Refresh Emails") {
                        Task { await viewModel.fetchEmails() }
                    }
                } else {
                    // BLUEPRINT Lines 67-68: Information dense, spreadsheet-like table
                    GmailReceiptsTable(viewModel: viewModel)
                }
            }

            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .task {
            await viewModel.checkAuthentication()
            if viewModel.isAuthenticated {
                await viewModel.fetchEmails()
            }
        }
        .onAppear {
            Task {
                await viewModel.checkAuthentication()
            }
        }
    }
}

// BLUEPRINT Lines 67-68: Gmail Receipts Review Table
// PURPOSE: Show ALL email info for user to REVIEW and CONFIRM before importing
struct GmailReceiptsTable: View {
    @ObservedObject var viewModel: GmailViewModel
    @State private var sortOrder: [KeyPathComparator<ExtractedTransaction>] = [
        .init(\.date, order: .reverse)
    ]

    var body: some View {
        VStack(spacing: 12) {
            // Header with batch actions
            HStack {
                Text("\(viewModel.extractedTransactions.count) emails to review")
                    .font(.headline)
                Spacer()
                if !viewModel.selectedIDs.isEmpty {
                    Text("\(viewModel.selectedIDs.count) selected")
                        .foregroundColor(.secondary)
                    Button("Import Selected") {
                        importSelected()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding(.horizontal)

            // Information-dense review table
            Table(viewModel.extractedTransactions, selection: $viewModel.selectedIDs, sortOrder: $sortOrder) {
                // Checkbox for confirmation
                TableColumn("") { transaction in
                    Toggle("", isOn: Binding(
                        get: { viewModel.selectedIDs.contains(transaction.id) },
                        set: { isSelected in
                            if isSelected {
                                viewModel.selectedIDs.insert(transaction.id)
                            } else {
                                viewModel.selectedIDs.remove(transaction.id)
                            }
                        }
                    ))
                    .toggleStyle(.checkbox)
                    .labelsHidden()
                }
                .width(30)

                // Date
                TableColumn("Date", value: \.date) { transaction in
                    Text(transaction.date, format: .dateTime.month().day())
                        .font(.caption)
                }
                .width(min: 60, ideal: 70)

                // Email Domain (WHO sent it)
                TableColumn("From", value: \.emailSender) { transaction in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(extractDomain(from: transaction.emailSender))
                            .font(.caption)
                            .fontWeight(.semibold)
                        Text(transaction.emailSender)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                .width(min: 140, ideal: 180)

                // Email Subject (WHAT it's about)
                TableColumn("Subject", value: \.emailSubject) { transaction in
                    Text(transaction.emailSubject)
                        .font(.caption)
                        .lineLimit(2)
                }
                .width(min: 200, ideal: 280)

                // Detected Amount
                TableColumn("Amount", value: \.amount) { transaction in
                    Text(transaction.amount, format: .currency(code: "AUD"))
                        .font(.system(.caption, design: .monospaced))
                        .fontWeight(.bold)
                }
                .width(min: 80, ideal: 90)

                // Item Details (WHAT was purchased)
                TableColumn("Items") { transaction in
                    VStack(alignment: .leading, spacing: 1) {
                        ForEach(transaction.items.prefix(2), id: \.description) { item in
                            Text(item.description)
                                .font(.caption2)
                                .lineLimit(1)
                        }
                        if transaction.items.count > 2 {
                            Text("+\(transaction.items.count - 2) more")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .width(min: 180, ideal: 250)

                // Confidence (HOW sure we are)
                TableColumn("Conf", value: \.confidence) { transaction in
                    HStack(spacing: 4) {
                        Circle()
                            .fill(confidenceColor(transaction.confidence))
                            .frame(width: 6, height: 6)
                        Text("\(Int(transaction.confidence * 100))%")
                            .font(.caption2)
                    }
                }
                .width(min: 50, ideal: 60)

                // Quick action
                TableColumn("") { transaction in
                    Button("Import") {
                        viewModel.createTransaction(from: transaction)
                        viewModel.selectedIDs.remove(transaction.id)
                    }
                    .buttonStyle(.borderless)
                    .controlSize(.small)
                }
                .width(60)
            }
            .onChange(of: sortOrder) { oldValue, newValue in
                viewModel.extractedTransactions.sort(using: newValue)
            }
        }
    }

    private func extractDomain(from email: String) -> String {
        guard let atIndex = email.firstIndex(of: "@") else { return email }
        let domain = String(email[email.index(after: atIndex)...])
        let parts = domain.components(separatedBy: ".")
        let skipPrefixes = ["info", "mail", "noreply", "hello", "no-reply"]
        for part in parts where !skipPrefixes.contains(part.lowercased()) && part.lowercased() != "com" && part.lowercased() != "au" {
            return part.capitalized
        }
        return parts.first?.capitalized ?? email
    }

    private func importSelected() {
        for id in viewModel.selectedIDs {
            if let transaction = viewModel.extractedTransactions.first(where: { $0.id == id }) {
                viewModel.createTransaction(from: transaction)
            }
        }
        viewModel.selectedIDs.removeAll()
    }

    private func confidenceColor(_ confidence: Double) -> Color {
        if confidence >= 0.8 { return .green }
        else if confidence >= 0.5 { return .yellow }
        else { return .red }
    }
}
