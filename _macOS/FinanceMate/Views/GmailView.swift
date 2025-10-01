import SwiftUI

/// Gmail integration view - Connect account and view emails
/// BLUEPRINT: Show emails from bernhardbudiono@gmail.com
struct GmailView: View {
    @StateObject private var viewModel = GmailViewModel()

    var body: some View {
        VStack(spacing: 20) {
            Text("Gmail Receipts")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            if !viewModel.isAuthenticated {
                // Not connected - show connect button
                VStack(spacing: 16) {
                    Image(systemName: "envelope.circle")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)

                    Text("Connect Gmail Account")
                        .font(.title2)

                    Text("bernhardbudiono@gmail.com")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Button("Connect Gmail") {
                        Task {
                            await viewModel.authenticate()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxHeight: .infinity)
            } else {
                // Connected - show emails
                if viewModel.isLoading {
                    ProgressView("Loading emails...")
                } else if viewModel.emails.isEmpty {
                    Text("No receipt emails found")
                        .foregroundColor(.secondary)
                } else {
                    List(viewModel.emails) { email in
                        EmailRow(email: email)
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

/// Simple email row
struct EmailRow: View {
    let email: GmailEmail

    var body: some View {
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

#Preview {
    GmailView()
}
