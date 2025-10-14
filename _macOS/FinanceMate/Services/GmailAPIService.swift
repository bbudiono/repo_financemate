import Foundation

/// Gmail API service for OAuth and email operations
/// Handles authentication, email fetching, and transaction extraction
class GmailAPIService {
    private let oauthHelper: GmailOAuthHelper.Type
    private let keychainHelper: KeychainHelper.Type
    private let dotEnvLoader: DotEnvLoader.Type

    init(
        oauthHelper: GmailOAuthHelper.Type = GmailOAuthHelper.self,
        keychainHelper: KeychainHelper.Type = KeychainHelper.self,
        dotEnvLoader: DotEnvLoader.Type = DotEnvLoader.self
    ) {
        self.oauthHelper = oauthHelper
        self.keychainHelper = keychainHelper
        self.dotEnvLoader = dotEnvLoader
    }

    /// Check authentication status and refresh access token if needed
    /// - Returns: True if authenticated, false otherwise
    func checkAuthentication() async -> Bool {
        guard keychainHelper.get(account: "gmail_refresh_token") != nil else {
            return false
        }

        do {
            try await refreshAccessToken()
            return true
        } catch {
            return false
        }
    }

    /// Complete OAuth flow with authorization code
    /// - Parameter authCode: Authorization code from OAuth callback
    /// - Throws: OAuthError on authentication failure
    func authenticate(with authCode: String) async throws {
        guard let clientID = dotEnvLoader.get("GOOGLE_OAUTH_CLIENT_ID"),
              let clientSecret = dotEnvLoader.get("GOOGLE_OAUTH_CLIENT_SECRET") else {
            throw OAuthError.missingCredentials
        }

        let token = try await oauthHelper.exchangeCodeForToken(
            code: authCode,
            clientID: clientID,
            clientSecret: clientSecret
        )

        keychainHelper.save(value: token.accessToken, account: "gmail_access_token")
        keychainHelper.save(value: token.refreshToken, account: "gmail_refresh_token")
    }

    /// Refresh OAuth access token
    /// - Throws: OAuthError on refresh failure
    private func refreshAccessToken() async throws {
        guard let refreshToken = keychainHelper.get(account: "gmail_refresh_token") else {
            throw OAuthError.noRefreshToken
        }

        guard let clientID = dotEnvLoader.get("GOOGLE_OAUTH_CLIENT_ID"),
              let clientSecret = dotEnvLoader.get("GOOGLE_OAUTH_CLIENT_SECRET") else {
            throw OAuthError.missingCredentials
        }

        let token = try await GmailAPI.refreshToken(
            refreshToken: refreshToken,
            clientID: clientID,
            clientSecret: clientSecret
        )

        keychainHelper.save(value: token.accessToken, account: "gmail_access_token")
    }

    /// Fetch emails from Gmail API with rate limiting
    /// - Parameter maxResults: Maximum number of emails to fetch
    /// - Returns: Array of GmailEmail objects
    /// - Throws: GmailAPIError on fetch failure
    func fetchEmails(maxResults: Int = 500) async throws -> [GmailEmail] {
        // Check rate limiting before making API call
        guard GmailRateLimitService.shared.shouldAllowCall() else {
            throw GmailAPIError.rateLimitExceeded
        }

        guard let accessToken = keychainHelper.get(account: "gmail_access_token") else {
            throw GmailAPIError.notAuthenticated
        }

        return try await GmailAPI.fetchEmails(accessToken: accessToken, maxResults: maxResults)
    }

    /// Fetch emails with pagination support for large datasets
    /// - Parameters:
    ///   - pageSize: Number of emails per page (max 100 per Gmail API)
    ///   - maxResults: Maximum total emails to fetch
    /// - Returns: Array of GmailEmail objects
    /// - Throws: GmailAPIError on fetch failure
    func fetchEmailsWithPagination(pageSize: Int = 100, maxResults: Int = 1500) async throws -> [GmailEmail] {
        return try await GmailPaginationService.shared.fetchEmailsWithPagination(
            accessToken: keychainHelper.get(account: "gmail_access_token") ?? "",
            pageSize: pageSize,
            maxResults: maxResults
        )
    }

    /// Extract transactions from email
    /// - Parameter email: GmailEmail to extract transactions from
    /// - Returns: Array of extracted transactions
    func extractTransactions(from email: GmailEmail) -> [ExtractedTransaction] {
        return GmailAPI.extractTransactions(from: email)
    }

    /// Get current authentication status
    var isAuthenticated: Bool {
        return keychainHelper.get(account: "gmail_access_token") != nil &&
               keychainHelper.get(account: "gmail_refresh_token") != nil
    }
}


extension GmailAPIError {
    static let notAuthenticated = GmailAPIError.invalidURL("No access token available")
    static func networkError(_ message: String) -> GmailAPIError {
        return .invalidURL("Network error: \(message)")
    }
    static func apiError(_ statusCode: Int, _ message: String) -> GmailAPIError {
        return .invalidURL("API error (\(statusCode)): \(message)")
    }
    static func invalidData(_ message: String) -> GmailAPIError {
        return .invalidURL("Invalid data: \(message)")
    }
}