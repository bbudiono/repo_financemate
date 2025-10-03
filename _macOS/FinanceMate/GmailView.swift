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

// BLUEPRINT Lines 67-68: Information dense, spreadsheet-like table with in-line editing
struct GmailReceiptsTable: View {
    @ObservedObject var viewModel: GmailViewModel
    @State private var sortOrder: [KeyPathComparator<ExtractedTransaction>] = [
        .init(\.date, order: .reverse)
    ]
    @State private var editingID: String?

    var body: some View {
        VStack(spacing: 0) {
            Table(viewModel.extractedTransactions, selection: $viewModel.selectedIDs, sortOrder: $sortOrder) {
                // Confirmation checkbox
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
                    Text(transaction.date, style: .date)
                        .font(.system(.body, design: .monospaced))
                }
                .width(min: 90, ideal: 100, max: 120)

                // Merchant
                TableColumn("Merchant", value: \.merchant) { transaction in
                    Text(transaction.merchant)
                        .lineLimit(1)
                }
                .width(min: 120, ideal: 150)

                // Amount
                TableColumn("Amount", value: \.amount) { transaction in
                    Text(transaction.amount, format: .currency(code: "AUD"))
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(transaction.amount < 0 ? .red : .primary)
                }
                .width(min: 80, ideal: 100)

                // Category
                TableColumn("Category", value: \.category) { transaction in
                    Text(transaction.category)
                        .lineLimit(1)
                }
                .width(min: 100, ideal: 120)

                // Confidence
                TableColumn("Confidence", value: \.confidence) { transaction in
                    HStack {
                        Text("\(Int(transaction.confidence * 100))%")
                            .font(.system(.body, design: .monospaced))
                        Circle()
                            .fill(confidenceColor(transaction.confidence))
                            .frame(width: 8, height: 8)
                    }
                }
                .width(min: 80, ideal: 90)

                // Items count
                TableColumn("Items") { transaction in
                    Text("\(transaction.items.count)")
                        .font(.system(.body, design: .monospaced))
                }
                .width(min: 50, ideal: 60)

                // Source details
                TableColumn("Source") { transaction in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(transaction.emailSender)
                            .font(.caption)
                            .lineLimit(1)
                        Text(transaction.emailSubject)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                .width(min: 150, ideal: 200)
            }
            .onChange(of: sortOrder) { oldValue, newValue in
                viewModel.extractedTransactions.sort(using: newValue)
            }
        }
    }

    private func confidenceColor(_ confidence: Double) -> Color {
        if confidence >= 0.8 { return .green }
        else if confidence >= 0.5 { return .yellow }
        else { return .red }
    }
}
