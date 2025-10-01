import SwiftUI

/// Gmail view model - OAuth and email fetching
/// BLUEPRINT: Use stored refresh token, fetch real emails
@MainActor
class GmailViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var emails: [GmailEmail] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    /// Check if OAuth tokens exist and refresh if needed
    func checkAuthentication() async {
        if KeychainHelper.get(account: "gmail_refresh_token") != nil {
            await refreshAccessToken()
        }
    }

    /// Authenticate with Gmail using stored refresh token
    func authenticate() async {
        isLoading = true
        errorMessage = nil
        await refreshAccessToken()

        if isAuthenticated {
            await fetchEmails()
        }
        isLoading = false
    }

    /// Refresh OAuth access token using stored refresh token
    private func refreshAccessToken() async {
        guard let refreshToken = KeychainHelper.get(account: "gmail_refresh_token") else {
            errorMessage = "No refresh token. Please configure OAuth."
            return
        }

        guard let clientID = ProcessInfo.processInfo.environment["GOOGLE_OAUTH_CLIENT_ID"],
              let clientSecret = ProcessInfo.processInfo.environment["GOOGLE_OAUTH_CLIENT_SECRET"] else {
            errorMessage = "OAuth credentials not in .env"
            return
        }

        do {
            let token = try await GmailAPI.refreshToken(
                refreshToken: refreshToken,
                clientID: clientID,
                clientSecret: clientSecret
            )

            KeychainHelper.save(value: token.accessToken, account: "gmail_access_token")

            let expiry = Date().addingTimeInterval(TimeInterval(token.expiresIn))
            KeychainHelper.save(value: ISO8601DateFormatter().string(from: expiry), account: "gmail_token_expiry")

            isAuthenticated = true
            print(" OAuth refreshed")
        } catch {
            errorMessage = "Token refresh failed: \(error.localizedDescription)"
        }
    }

    /// Fetch emails from Gmail API
    func fetchEmails() async {
        guard let accessToken = KeychainHelper.get(account: "gmail_access_token") else { return }

        isLoading = true
        errorMessage = nil

        do {
            emails = try await GmailAPI.fetchEmails(accessToken: accessToken, maxResults: 10)
            print(" Fetched \(emails.count) emails")
        } catch {
            errorMessage = "Failed to fetch emails: \(error.localizedDescription)"
        }

        isLoading = false
    }
}
