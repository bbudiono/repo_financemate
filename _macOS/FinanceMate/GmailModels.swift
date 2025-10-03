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
    let body: EmailBody?
    let parts: [EmailPart]?
}

struct EmailBody: Codable {
    let data: String?
}

struct EmailPart: Codable {
    let mimeType: String
    let body: EmailBody?
    let parts: [EmailPart]?  // Support nested multipart
}

struct Header: Codable {
    let name: String
    let value: String
}

// MARK: - Transaction Extraction Models

struct ExtractedTransaction: Identifiable {
    let id: String  // Use email ID as unique identifier
    let merchant: String
    let amount: Double
    let date: Date
    let category: String
    let items: [GmailLineItem]
    let confidence: Double // 0.0 to 1.0
    let rawText: String

    // Enhanced expense details per BLUEPRINT Line 63
    let emailSubject: String
    let emailSender: String
    let gstAmount: Double?
    let abn: String?
    let invoiceNumber: String?
    let paymentMethod: String?
}

struct GmailLineItem {
    let description: String
    let quantity: Int
    let price: Double
}
