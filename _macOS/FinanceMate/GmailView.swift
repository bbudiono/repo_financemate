import SwiftUI

/// Gmail View with OAuth, email fetching, and ExtractedTransactionRow display
/// Uses List/ForEach for transaction rows, Create Transaction buttons for import
struct GmailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: GmailViewModel
    @AppStorage("gmail_auto_refresh") private var autoRefresh = false
    @State private var capabilities = ExtractionCapabilityDetector.detect()

    init() {
        // Initialize GmailViewModel with Core Data context
        let context = PersistenceController.shared.container.viewContext
        _viewModel = StateObject(wrappedValue: GmailViewModel(context: context))
    }

    var body: some View {
        VStack(spacing: 20) {
            // BLUEPRINT Line 161: Show capability warning if Foundation Models unavailable
            CapabilityWarningBanner(capabilities: capabilities)


            // Header with auto-refresh and archive toggles
            HStack {
                Text("Gmail Receipts")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
                Toggle("Show Archived", isOn: $viewModel.showArchivedEmails)
                    .toggleStyle(.switch)
                Toggle("Auto-refresh", isOn: $autoRefresh)
                    .toggleStyle(.switch)
            }
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
                    Button("Extract & Refresh Emails") {
                        Task { await viewModel.fetchEmails() }
                    }
                    .accessibilityLabel("Extract transactions from emails")
                } else {
                    // BLUEPRINT Lines 67-69: Expandable table with all invoice data
                    GmailReceiptsTableView(viewModel: viewModel)
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
            if viewModel.isAuthenticated && autoRefresh {
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
