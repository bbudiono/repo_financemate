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
                        if let clientID = ProcessInfo.processInfo.environment["GOOGLE_OAUTH_CLIENT_ID"],
                           let url = GmailOAuthHelper.getAuthorizationURL(clientID: clientID) {
                            NSWorkspace.shared.open(url)
                            viewModel.showCodeInput = true
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
                    VStack {
                        HStack {
                            Text("\(viewModel.extractedTransactions.count) transactions found")
                                .font(.headline)
                            Spacer()
                            Button("Create All") {
                                viewModel.createAllTransactions()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding()

                        List {
                            ForEach(viewModel.extractedTransactions, id: \.rawText) { extracted in
                                ExtractedTransactionRow(extracted: extracted) {
                                    viewModel.createTransaction(from: extracted)
                                }
                            }
                        }
                    }
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

// MARK: - Extracted Transaction Row

struct ExtractedTransactionRow: View {
    let extracted: ExtractedTransaction
    let onApprove: () -> Void

    var confidenceColor: Color {
        if extracted.confidence >= 0.8 { return .green }
        if extracted.confidence >= 0.6 { return .orange }
        return .red
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(extracted.merchant)
                        .font(.headline)
                    Text(extracted.category)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(String(format: "$%.2f", extracted.amount))
                        .font(.title3)
                        .fontWeight(.bold)
                    HStack(spacing: 4) {
                        Circle()
                            .fill(confidenceColor)
                            .frame(width: 8, height: 8)
                        Text("\(Int(extracted.confidence * 100))%")
                            .font(.caption)
                            .foregroundColor(confidenceColor)
                    }
                }
            }

            if !extracted.items.isEmpty {
                Text("\(extracted.items.count) line items")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Button("Create Transaction") {
                onApprove()
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
    }
}

