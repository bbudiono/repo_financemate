import Foundation

/// Gmail API error types
enum GmailAPIError: LocalizedError {
    case invalidURL(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL(let url): return "Invalid URL: \(url)"
        }
    }
}

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
        let urlString = "https://gmail.googleapis.com/gmail/v1/users/me/messages?maxResults=\(maxResults)"
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
        let urlString = "https://gmail.googleapis.com/gmail/v1/users/me/messages/\(messageId)"
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

        return GmailEmail(id: messageId, subject: subject, sender: from, date: date, snippet: message.snippet)
    }

    // MARK: - Date Parsing

    private static func parseEmailDate(_ dateString: String?) -> Date? {
        guard let dateString = dateString else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, d MMM yyyy HH:mm:ss Z"
        return formatter.date(from: dateString)
    }

    // MARK: - Transaction Extraction

    static func extractTransaction(from email: GmailEmail) -> ExtractedTransaction? {
        guard let merchant = extractMerchant(from: email.subject, sender: email.sender),
              let amount = extractAmount(from: email.snippet) else { return nil }

        let items = extractLineItems(from: email.snippet)
        let confidence = (merchant.isEmpty ? 0.0 : 0.4) + (amount > 0 ? 0.4 : 0.0) + (items.isEmpty ? 0.0 : 0.2)
        let category = inferCategory(from: merchant)

        return ExtractedTransaction(merchant: merchant, amount: amount, date: email.date,
                                   category: category, items: items, confidence: confidence, rawText: email.snippet)
    }

    private static func extractMerchant(from subject: String, sender: String) -> String? {
        if let range = subject.range(of: #"(from|at) ([A-Za-z\s]+)"#, options: .regularExpression) {
            return String(subject[range]).replacingOccurrences(of: "from ", with: "").replacingOccurrences(of: "at ", with: "").trimmingCharacters(in: .whitespaces)
        }
        if let atIndex = sender.firstIndex(of: "@") {
            return sender[sender.index(after: atIndex)...].split(separator: ".").first.map(String.init)?.capitalized
        }
        return nil
    }

    private static func extractAmount(from content: String) -> Double? {
        let patterns = [#"\$(\d+\.?\d{0,2})"#, #"(?:Total|Amount):\s?\$?(\d+\.?\d{0,2})"#, #"AUD\s?(\d+\.?\d{0,2})"#]
        for pattern in patterns {
            if let match = content.range(of: pattern, options: .regularExpression) {
                let nums = String(content[match]).components(separatedBy: CharacterSet.decimalDigits.union(CharacterSet(charactersIn: ".")).inverted).joined()
                if let amount = Double(nums), amount > 0 { return amount }
            }
        }
        return nil
    }

    private static func extractLineItems(from content: String) -> [GmailLineItem] {
        var items: [GmailLineItem] = []
        guard let regex = try? NSRegularExpression(pattern: #"(\d+)x?\s+(.+?)\s+\$(\d+\.?\d{0,2})"#) else { return items }
        regex.enumerateMatches(in: content, range: NSRange(content.startIndex..., in: content)) { match, _, _ in
            guard let match = match, match.numberOfRanges >= 4,
                  let qtyRange = Range(match.range(at: 1), in: content),
                  let descRange = Range(match.range(at: 2), in: content),
                  let priceRange = Range(match.range(at: 3), in: content),
                  let qty = Int(content[qtyRange]),
                  let price = Double(content[priceRange]) else { return }
            items.append(GmailLineItem(description: String(content[descRange]).trimmingCharacters(in: .whitespaces), quantity: qty, price: price))
        }
        return items
    }

    private static func inferCategory(from merchant: String) -> String {
        let m = merchant.lowercased()
        if ["woolworths", "coles", "aldi"].contains(where: { m.contains($0) }) { return "Groceries" }
        if ["uber", "taxi", "petrol"].contains(where: { m.contains($0) }) { return "Transport" }
        if ["restaurant", "cafe"].contains(where: { m.contains($0) }) { return "Dining" }
        return "Other"
    }
}
