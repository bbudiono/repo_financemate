import Foundation

struct GmailEmail: Identifiable {
    let id: String
    let subject: String
    let sender: String
    let date: Date
    let snippet: String
}

struct TokenResponse: Codable {
    let accessToken: String
    let refreshToken: String?
    let expiresIn: Int

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
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
