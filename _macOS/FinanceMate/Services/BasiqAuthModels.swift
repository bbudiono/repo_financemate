import Foundation

// MARK: - Basiq Authentication Models
// Authentication response and error types for Basiq API OAuth flow

/// Authentication response from Basiq /token endpoint
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

// MARK: - Error Models

/// Basiq API error response structure
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

/// Basiq API error types for Swift error handling
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

/// Bank connection status for UI display
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
