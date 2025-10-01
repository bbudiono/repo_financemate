import SwiftUI

@MainActor
class GmailViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var emails: [GmailEmail] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func checkAuthentication() async {
        if KeychainHelper.get(account: "gmail_refresh_token") != nil {
            await refreshAccessToken()
        }
    }

    func authenticate() async {
        isLoading = true
        errorMessage = nil
        await refreshAccessToken()

        if isAuthenticated {
            await fetchEmails()
        }
        isLoading = false
    }

    private func refreshAccessToken() async {
        guard let refreshToken = KeychainHelper.get(account: "gmail_refresh_token") else {
            errorMessage = "No refresh token found. Configure OAuth first."
            return
        }

        guard let clientID = ProcessInfo.processInfo.environment["GOOGLE_OAUTH_CLIENT_ID"],
              let clientSecret = ProcessInfo.processInfo.environment["GOOGLE_OAUTH_CLIENT_SECRET"] else {
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
            emails = try await GmailAPI.fetchEmails(accessToken: accessToken, maxResults: 10)
        } catch {
            errorMessage = "Failed to fetch emails: \(error.localizedDescription)"
        }

        isLoading = false
    }
}
