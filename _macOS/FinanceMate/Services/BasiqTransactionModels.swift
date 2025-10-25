import Foundation

// MARK: - Basiq Transaction Models
// Transaction data structures with Australian business enrichment (ANZSIC)

/// Bank transaction from Basiq API
struct BasiqTransaction: Codable, Identifiable {
    let id: String
    let status: String
    let description: String
    let amount: String
    let account: String
    let direction: String  // "debit" or "credit"
    let `class`: String
    let institution: String
    let connection: String
    let enrich: BasiqEnrichment?
    let postDate: String

    enum CodingKeys: String, CodingKey {
        case id, status, description, amount, account
        case direction, `class`, institution, connection, enrich
        case postDate = "post_date"
    }
}

/// Transaction enrichment data (merchant, category)
struct BasiqEnrichment: Codable {
    let merchant: BasiqMerchant?
    let category: BasiqCategory?
}

/// Merchant business information
struct BasiqMerchant: Codable {
    let businessName: String?

    enum CodingKeys: String, CodingKey {
        case businessName = "business_name"
    }
}

/// Australian ANZSIC category taxonomy
struct BasiqCategory: Codable {
    let anzsic: BasiqANZSIC?
}

/// Australian and New Zealand Standard Industrial Classification
struct BasiqANZSIC: Codable {
    let division: String?
    let subdivision: String?
}

// MARK: - Response Wrapper

/// Wrapper for transactions list response
struct BasiqTransactionsResponse: Codable {
    let data: [BasiqTransaction]
}
