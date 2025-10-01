import Foundation

struct GmailAPI {
    static func refreshToken(refreshToken: String, clientID: String, clientSecret: String) async throws -> TokenResponse {
        let url = URL(string: "https://oauth2.googleapis.com/token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let body = "client_id=\(clientID)&client_secret=\(clientSecret)&refresh_token=\(refreshToken)&grant_type=refresh_token"
        request.httpBody = body.data(using: .utf8)

        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(TokenResponse.self, from: data)
    }

    static func fetchEmails(accessToken: String, maxResults: Int) async throws -> [GmailEmail] {
        let url = URL(string: "https://gmail.googleapis.com/gmail/v1/users/me/messages?maxResults=\(maxResults)&q=subject:receipt OR subject:invoice")!
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
        let url = URL(string: "https://gmail.googleapis.com/gmail/v1/users/me/messages/\(messageId)")!
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

struct GmailEmail: Identifiable {
    let id: String
    let subject: String
    let sender: String
    let date: Date
    let snippet: String
}

struct TokenResponse: Codable {
    let accessToken: String
    let expiresIn: Int

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expiresIn = "expires_in"
    }
}

struct MessagesResponse: Codable {
    let messages: [MessageStub]
}

struct MessageStub: Codable {
    let id: String
}

struct MessageDetail: Codable {
    let id: String
    let snippet: String
    let payload: Payload
}

struct Payload: Codable {
    let headers: [Header]
}

struct Header: Codable {
    let name: String
    let value: String
}
