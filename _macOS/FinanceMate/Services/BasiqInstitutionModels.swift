import Foundation

// MARK: - Basiq Institution & Connection Models
// Bank institutions, accounts, and connection data structures

/// Financial institution (bank) available via Basiq
struct BasiqInstitution: Codable, Identifiable {
    let id: String
    let name: String
    let shortName: String
    let institutionType: String
    let country: String
    let tier: String

    enum CodingKeys: String, CodingKey {
        case id, name, country, tier
        case shortName = "short_name"
        case institutionType = "institution_type"
    }
}

/// Bank account connection via Basiq CDR
struct BasiqConnection: Codable, Identifiable {
    let id: String
    let status: String
    let lastUsed: String?
    let institution: BasiqInstitution
    let accounts: [BasiqAccount]?
}

/// Individual bank account within a connection
struct BasiqAccount: Codable, Identifiable {
    let id: String
    let name: String
    let accountNo: String?
    let balance: String
    let availableBalance: String?
    let type: String
    let `class`: String
    let currency: String

    enum CodingKeys: String, CodingKey {
        case id, name, balance, type, currency
        case accountNo = "account_no"
        case availableBalance = "available_balance"
        case `class`
    }
}

// MARK: - Response Wrappers

/// Wrapper for institutions list response
struct BasiqInstitutionsResponse: Codable {
    let data: [BasiqInstitution]
}

/// Wrapper for connection creation response
struct BasiqConnectionResponse: Codable {
    let id: String
}

/// Wrapper for connections list response
struct BasiqConnectionsResponse: Codable {
    let data: [BasiqConnection]
}
