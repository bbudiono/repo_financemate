import Foundation

enum GmailAPIError: LocalizedError {
    case invalidURL(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL(let url): return "Invalid URL: \(url)"
        }
    }
}

struct GmailAPI {
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

        return GmailEmail(id: messageId, subject: subject, sender: from, date: Date(), snippet: message.snippet)
    }
}
