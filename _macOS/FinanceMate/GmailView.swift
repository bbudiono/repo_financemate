import SwiftUI

/// Gmail View with OAuth, email fetching, and ExtractedTransactionRow display
/// Uses List/ForEach for transaction rows, Create Transaction buttons for import
struct GmailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: GmailViewModel
    @AppStorage("gmail_auto_refresh") private var autoRefresh = false
    @State private var capabilities = ExtractionCapabilityDetector.detect()
    @State private var showCacheClearMessage = false
    @State private var showSuccessMessage = false
    @State private var successMessageText = ""

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

            // BLUEPRINT Line 150: Real-time batch extraction progress
            BatchExtractionProgressView(viewModel: viewModel)

            if !viewModel.isAuthenticated {
                VStack(spacing: 16) {
                    Image(systemName: "envelope.circle")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)

                    Text("Connect Gmail Account")
                        .font(.title2)

                    Text("Click \"Connect Gmail\" → Browser opens → Click \"Allow\" → Done!")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("✅ No code copying required - automatic redirect")
                        .font(.caption2)
                        .foregroundColor(.green)

                    Button("Connect Gmail") {
                        NSLog("=== AUTOMATIC OAUTH FLOW STARTING ===")
                        NSLog("LocalOAuthServer will handle callback automatically")
                        viewModel.startAutomaticOAuthFlow()
                    }
                    .buttonStyle(.borderedProminent)

                    // Show loading indicator while OAuth server is running
                    if viewModel.isLoading {
                        ProgressView("Waiting for authentication...")
                            .padding(.top, 8)
                    }
                }
            } else {
                if viewModel.isLoading {
                    ProgressView("Loading emails...")
                } else if viewModel.extractedTransactions.isEmpty {
                    Text("No transactions detected in emails")
                        .foregroundColor(.secondary)
                    Button("Extract & Refresh Emails") {
                        Task {
                            EmailCacheManager.clear()  // Force refresh by clearing cache
                            showCacheClearMessage = true

                            // Auto-dismiss cache clear toast after 2 seconds
                            try? await Task.sleep(nanoseconds: 2_000_000_000)
                            showCacheClearMessage = false

                            await viewModel.fetchEmails()

                            // Show success notification after extraction completes
                            let count = viewModel.extractedTransactions.count
                            successMessageText = "✓ Extracted \(count) transaction\(count == 1 ? "" : "s")"
                            showSuccessMessage = true

                            // Auto-dismiss success toast after 3 seconds
                            try? await Task.sleep(nanoseconds: 3_000_000_000)
                            showSuccessMessage = false
                        }
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
        .overlay(alignment: .top) {
            ZStack {
                if showCacheClearMessage {
                    Text("Cache cleared, refreshing emails...")
                        .padding()
                        .background(Color.blue.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.top, 60)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                if showSuccessMessage {
                    Text(successMessageText)
                        .padding()
                        .background(Color.green.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.top, 60)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
        }
        .animation(.easeInOut, value: showCacheClearMessage)
        .animation(.easeInOut, value: showSuccessMessage)
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
