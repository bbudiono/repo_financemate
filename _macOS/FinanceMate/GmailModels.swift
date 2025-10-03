import Foundation

struct GmailEmail: Identifiable, Codable {
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

// BLUEPRINT Lines 67-68: Mutable model for in-line editing support
class ExtractedTransaction: Identifiable, ObservableObject {
    let id: String  // Use email ID as unique identifier
    @Published var merchant: String
    @Published var amount: Double
    let date: Date
    @Published var category: String
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

    init(id: String, merchant: String, amount: Double, date: Date, category: String,
         items: [GmailLineItem], confidence: Double, rawText: String,
         emailSubject: String, emailSender: String, gstAmount: Double? = nil,
         abn: String? = nil, invoiceNumber: String? = nil, paymentMethod: String? = nil) {
        self.id = id
        self.merchant = merchant
        self.amount = amount
        self.date = date
        self.category = category
        self.items = items
        self.confidence = confidence
        self.rawText = rawText
        self.emailSubject = emailSubject
        self.emailSender = emailSender
        self.gstAmount = gstAmount
        self.abn = abn
        self.invoiceNumber = invoiceNumber
        self.paymentMethod = paymentMethod
    }
}

struct GmailLineItem {
    let description: String
    let quantity: Int
    let price: Double
}
