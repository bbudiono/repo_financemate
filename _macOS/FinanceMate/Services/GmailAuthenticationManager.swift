import Foundation

/**
 * Purpose: Gmail OAuth authentication and token management service
 * Issues & Complexity Summary: Handles OAuth flow, token refresh, and authentication state
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~65
 *   - Core Algorithm Complexity: Low
 *   - Dependencies: 3 New (GmailOAuthHelper, GmailAPI, KeychainHelper)
 *   - State Management Complexity: Medium (authentication state)
 *   - Novelty/Uncertainty Factor: Low (standard OAuth patterns)
 * AI Pre-Task Self-Assessment: 85%
 * Problem Estimate: 80%
 * Initial Code Complexity Estimate: 70%
 * Final Code Complexity: 68%
 * Overall Result Score: 92%
 * Key Variances/Learnings: Authentication logic is straightforward, minimal complexity discovered
 * Last Updated: 2025-10-09
 */

@MainActor
class GmailAuthenticationManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var showCodeInput = false
    @Published var authCode = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let onEmailsFetched: () async -> Void

    init(onEmailsFetched: @escaping () async -> Void) {
        self.onEmailsFetched = onEmailsFetched
    }

    func checkAuthentication() async {
        if KeychainHelper.get(account: "gmail_refresh_token") != nil {
            await refreshAccessToken()
        }
    }

    func exchangeCode() async {
        guard let clientID = DotEnvLoader.get("GOOGLE_OAUTH_CLIENT_ID"),
              let clientSecret = DotEnvLoader.get("GOOGLE_OAUTH_CLIENT_SECRET") else {
            errorMessage = "OAuth credentials not found"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            _ = try await GmailOAuthHelper.exchangeCodeForToken(
                code: authCode,
                clientID: clientID,
                clientSecret: clientSecret
            )
            isAuthenticated = true
            showCodeInput = false
            await onEmailsFetched()
        } catch {
            errorMessage = "Failed to exchange code: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func refreshAccessToken() async {
        guard let refreshToken = KeychainHelper.get(account: "gmail_refresh_token") else {
            errorMessage = "No refresh token found. Configure OAuth first."
            return
        }

        guard let clientID = DotEnvLoader.get("GOOGLE_OAUTH_CLIENT_ID"),
              let clientSecret = DotEnvLoader.get("GOOGLE_OAUTH_CLIENT_SECRET") else {
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

    func clearAuthenticationError() {
        errorMessage = nil
    }
}