import SwiftUI

struct GmailView: View {
    @StateObject private var viewModel = GmailViewModel()

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
                } else if viewModel.emails.isEmpty {
                    Text("No receipt emails found")
                        .foregroundColor(.secondary)
                } else {
                    List(viewModel.emails) { email in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(email.subject)
                                .font(.headline)
                            Text("From: \(email.sender)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(email.date, style: .date)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
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
    }
}
