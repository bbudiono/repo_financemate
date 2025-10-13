import Foundation

/*
 * Purpose: Basiq API data models for Australian bank account connectivity
 * Issues & Complexity Summary: Codable models for API request/response handling
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~150
 *   - Core Algorithm Complexity: Low (data modeling)
 *   - Dependencies: Foundation only
 *   - State Management Complexity: Low (immutable structs)
 *   - Novelty/Uncertainty Factor: Low (standard Codable patterns)
 * AI Pre-Task Self-Assessment: 95%
 * Problem Estimate: 80%
 * Initial Code Complexity Estimate: 70%
 * Final Code Complexity: 72%
 * Overall Result Score: 96%
 * Key Variances/Learnings: Proper coding keys and optional handling
 * Last Updated: 2025-10-07
 */

// MARK: - Authentication Models

struct BasiqAuthResponse: Codable {
    let accessToken: String
    let refreshToken: String?
    let expiresIn: Int
    let tokenType: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
        case tokenType = "token_type"
    }
}

// MARK: - Institution Models

struct BasiqInstitution: Codable, Identifiable {
    let id: String
    let name: String
    let shortName: String
    let institutionType: String
    let country: String
    let serviceName: String
    let serviceType: String
    let loginIdCaption: String?
    let passwordCaption: String?
    let tier: String
    let authorization: BasiqInstitutionAuth

    enum CodingKeys: String, CodingKey {
        case id, name, country, tier
        case shortName = "short_name"
        case institutionType = "institution_type"
        case serviceName = "service_name"
        case serviceType = "service_type"
        case loginIdCaption = "login_id_caption"
        case passwordCaption = "password_caption"
        case authorization
    }
}

struct BasiqInstitutionAuth: Codable {
    let adr: Bool
    let credentials: [BasiqCredential]
}

struct BasiqCredential: Codable {
    let id: String
    let name: String
    let type: String
    let label: String
    let encrypted: Bool
    let optional: Bool
}

// MARK: - Connection Models

struct BasiqConnection: Codable, Identifiable {
    let id: String
    let status: String
    let lastUsed: String?
    let institution: BasiqInstitution
    let accounts: [BasiqAccount]?
}

struct BasiqAccount: Codable, Identifiable {
    let id: String
    let name: String
    let accountNo: String?
    let balance: String
    let availableBalance: String?
    let type: String
    let subType: String?
    let `class`: String
    let product: String?
    let currency: String
    let lastUpdated: String

    enum CodingKeys: String, CodingKey {
        case id, name, balance, type, currency
        case accountNo = "account_no"
        case availableBalance = "available_balance"
        case subType = "sub_type"
        case `class`
        case product
        case lastUpdated = "last_updated"
    }
}

// MARK: - Transaction Models

struct BasiqTransaction: Codable, Identifiable {
    let id: String
    let status: String
    let description: String
    let amount: String
    let account: String
    let balance: String?
    let direction: String
    let `class`: String
    let institution: String
    let connection: String
    let enrich: BasiqEnrichment?
    let postDate: String
    let transactionDate: String?
    let subClass: BasiqSubClass?

    enum CodingKeys: String, CodingKey {
        case id, status, description, amount, account, balance
        case direction, `class`, institution, connection, enrich
        case postDate = "post_date"
        case transactionDate = "transaction_date"
        case subClass = "sub_class"
    }
}

struct BasiqEnrichment: Codable {
    let merchant: BasiqMerchant?
    let location: BasiqLocation?
    let category: BasiqCategory?
}

struct BasiqMerchant: Codable {
    let businessName: String?
    let website: String?
    let phoneNumber: String?

    enum CodingKeys: String, CodingKey {
        case businessName = "business_name"
        case website
        case phoneNumber = "phone_number"
    }
}

struct BasiqLocation: Codable {
    let latitude: Double?
    let longitude: Double?
    let address: String?
    let suburb: String?
    let state: String?
    let postcode: String?
}

struct BasiqCategory: Codable {
    let anzsic: BasiqANZSIC?
}

struct BasiqANZSIC: Codable {
    let division: String?
    let subdivision: String?
    let group: String?
    let `class`: String?
}

struct BasiqSubClass: Codable {
    let code: String
    let title: String
}

// MARK: - Error Models

struct BasiqError: Codable, Error {
    let correlationId: String?
    let data: [BasiqErrorData]?

    enum CodingKeys: String, CodingKey {
        case correlationId = "correlation_id"
        case data
    }

    struct BasiqErrorData: Codable {
        let code: String
        let title: String
        let detail: String
        let source: BasiqErrorSource?
    }

    struct BasiqErrorSource: Codable {
        let parameter: String?
        let pointer: String?
    }
}

// MARK: - Response Wrapper Models

struct BasiqInstitutionsResponse: Codable {
    let data: [BasiqInstitution]
}

struct BasiqConnectionResponse: Codable {
    let id: String
}

struct BasiqConnectionsResponse: Codable {
    let data: [BasiqConnection]
}

struct BasiqTransactionsResponse: Codable {
    let data: [BasiqTransaction]
}

// MARK: - API Error Types

enum BasiqAPIError: LocalizedError {
    case missingCredentials
    case notAuthenticated
    case invalidResponse
    case authenticationFailed(String)
    case connectionFailed(String)
    case requestFailed(String)
    case tokenExpired
    case institutionNotFound(String)

    var errorDescription: String? {
        switch self {
        case .missingCredentials:
            return "Basiq API credentials are not configured"
        case .notAuthenticated:
            return "Not authenticated with Basiq API"
        case .invalidResponse:
            return "Invalid response from Basiq API"
        case .authenticationFailed(let message):
            return "Authentication failed: \(message)"
        case .connectionFailed(let message):
            return "Connection failed: \(message)"
        case .requestFailed(let message):
            return "Request failed: \(message)"
        case .tokenExpired:
            return "Authentication token has expired"
        case .institutionNotFound(let id):
            return "Institution not found: \(id)"
        }
    }
}

// MARK: - Connection Status

enum BasiqConnectionStatus: Equatable {
    case disconnected
    case connecting
    case connected
    case syncing
    case error(String)

    var displayString: String {
        switch self {
        case .disconnected:
            return "Disconnected"
        case .connecting:
            return "Connecting..."
        case .connected:
            return "Connected"
        case .syncing:
            return "Syncing..."
        case .error(let message):
            return "Error: \(message)"
        }
    }
}