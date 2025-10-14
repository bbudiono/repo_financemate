import Foundation

/// Gmail API client - OAuth authentication and email fetching
/// Security: Uses proper URL encoding to prevent injection attacks
struct GmailAPI {
    /// Refresh OAuth access token using stored refresh token
    /// - Parameters:
    ///   - refreshToken: Long-lived refresh token from initial OAuth flow
    ///   - clientID: Google OAuth client ID from .env
    ///   - clientSecret: Google OAuth client secret from .env
    /// - Returns: New access token with expiry time
    static func refreshToken(refreshToken: String, clientID: String, clientSecret: String) async throws -> TokenResponse {
        guard let url = URL(string: "https://oauth2.googleapis.com/token") else {
            throw GmailAPIError.invalidURL("oauth2.googleapis.com/token")
        }

        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "client_secret", value: clientSecret),
            URLQueryItem(name: "refresh_token", value: refreshToken),
            URLQueryItem(name: "grant_type", value: "refresh_token")
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = components.percentEncodedQuery?.data(using: .utf8)

        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(TokenResponse.self, from: data)
    }

    static func fetchEmails(accessToken: String, maxResults: Int) async throws -> [GmailEmail] {
        // BLUEPRINT Line 72: Search ALL emails (not just Inbox) for 5-year financial history
        let fiveYearsAgo = Calendar.current.date(byAdding: .year, value: -5, to: Date())!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        let afterDate = dateFormatter.string(from: fiveYearsAgo)

        // Gmail query: All Mail + Financial keywords + 5-year range
        let query = "in:anywhere after:\(afterDate) (receipt OR invoice OR payment OR order OR purchase OR cashback)"
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw GmailAPIError.invalidURL("Failed to encode query")
        }

        let urlString = "https://gmail.googleapis.com/gmail/v1/users/me/messages?maxResults=\(maxResults)&q=\(encodedQuery)"

        // DEBUG: Log search parameters
        NSLog("=== GMAIL API SEARCH ===")
        NSLog("Date Range: after:\(afterDate) (5 years from \(Date()))")
        NSLog("Query: \(query)")
        NSLog("URL: \(urlString)")
        NSLog("MaxResults: \(maxResults)")

        guard let url = URL(string: urlString) else {
            throw GmailAPIError.invalidURL(urlString)
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(MessagesResponse.self, from: data)

        var emails: [GmailEmail] = []
        for message in response.messages {
            if let email = try? await fetchEmailDetails(messageId: message.id, accessToken: accessToken) {
                emails.append(email)
            }
        }

        return emails
    }

    private static func fetchEmailDetails(messageId: String, accessToken: String) async throws -> GmailEmail {
        let urlString = "https://gmail.googleapis.com/gmail/v1/users/me/messages/\(messageId)?format=full"
        guard let url = URL(string: urlString) else {
            throw GmailAPIError.invalidURL(urlString)
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let (data, _) = try await URLSession.shared.data(for: request)
        let message = try JSONDecoder().decode(MessageDetail.self, from: data)

        let headers = message.payload.headers
        let subject = headers.first(where: { $0.name == "Subject" })?.value ?? "No Subject"
        let from = headers.first(where: { $0.name == "From" })?.value ?? "Unknown"
        let dateString = headers.first(where: { $0.name == "Date" })?.value
        let date = parseEmailDate(dateString) ?? Date()

        // Extract full email body for better transaction extraction
        let fullBody = GmailEmailFetcher.getEmailText(from: message.payload)

        // Parse attachments (Phase 3.3)
        let attachments = parseAttachments(from: message.payload)

        return GmailEmail(
            id: messageId,
            subject: subject,
            sender: from,
            date: date,
            snippet: fullBody,
            attachments: attachments
        )
    }

    // MARK: - Date Parsing

    private static func parseEmailDate(_ dateString: String?) -> Date? {
        guard let dateString = dateString else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, d MMM yyyy HH:mm:ss Z"
        return formatter.date(from: dateString)
    }

    // MARK: - Transaction Extraction

    /// Extract transactions using intelligent 3-tier pipeline
    /// BLUEPRINT Section 3.1.1.4: Regex → Foundation Models → Manual
    static func extractTransactions(from email: GmailEmail) async -> [ExtractedTransaction] {
        return await IntelligentExtractionService.extract(from: email)
    }

    /// Legacy method - kept for compatibility but delegates to extractTransactions
    @available(*, deprecated, message: "Use extractTransactions for BLUEPRINT Line 66 compliance")
    static func extractTransaction(from email: GmailEmail) async -> ExtractedTransaction? {
        return await extractTransactions(from: email).first
    }
}
