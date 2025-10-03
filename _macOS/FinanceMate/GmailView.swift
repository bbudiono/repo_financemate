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
                            ForEach(viewModel.extractedTransactions) { extracted in
                                ExtractedTransactionRow(extracted: extracted) {
                                    NSLog("=== ExtractedTransactionRow onApprove CALLED ===")
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

