// Purpose: Defines authentication-related types, including AuthUser for SSO identity and profile data.
// Issues & Complexity: Must be cross-module, test-visible, and extensible for multiple SSO providers. Handles user identity, provider, and display info.
// Ranking/Rating: 85% (Code), 80% (Problem) - Moderate complexity due to cross-module visibility and SSO extensibility.
// -- Pre-Coding Assessment --
// Issues & Complexity Summary: Module visibility, testability, extensibility for new providers.
// Key Complexity Drivers (Values/Estimates):
// - Logic Scope (New/Mod LoC Est.): ~50
// - Core Algorithm Complexity: Low (data struct)
// - Dependencies (New/Mod Cnt.): 0 New, 0 Mod
// - State Management Complexity: Low
// - Novelty/Uncertainty Factor: Low
// AI Pre-Task Self-Assessment (Est. Solution Difficulty for AI %): 30%
// Problem Estimate (Inherent Problem Difficulty %): 40%
// Initial Code Complexity Estimate (Est. Code Difficulty %): 35%
// Justification for Estimates: Simple data struct, but must be visible to tests and extensible.
// -- Post-Implementation Update --
// Final Code Complexity (Actual Code Difficulty %): [TBD]
// Overall Result Score (Success & Quality %): [TBD]
// Key Variances/Learnings: [TBD]
// Last Updated: 2025-05-18

import Foundation

/// Represents a user with authentication details
public struct AuthUser: Identifiable, Equatable {
    public let id: String
    public let email: String
    public let displayName: String
    public let firstName: String?
    public let lastName: String?
    public let provider: String
    public let token: String?
    
    public init(id: String, email: String, displayName: String = "", firstName: String? = nil, lastName: String? = nil, provider: String, token: String? = nil) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.firstName = firstName
        self.lastName = lastName
        self.provider = provider
        self.token = token
    }
}

/// Represents the authentication state
public enum AuthState: Equatable {
    case unknown
    case authenticating
    case authenticated
    case signedOut
    case error(AuthError)
    
    public static func == (lhs: AuthState, rhs: AuthState) -> Bool {
        switch (lhs, rhs) {
        case (.unknown, .unknown):
            return true
        case (.authenticating, .authenticating):
            return true
        case (.authenticated, .authenticated):
            return true
        case (.signedOut, .signedOut):
            return true
        case (.error(let lhsError), .error(let rhsError)):
            return lhsError == rhsError
        default:
            return false
        }
    }
}

/// Authentication errors that may occur during the sign-in process
public enum AuthError: Error, Equatable {
    case userCancelled
    case invalidCredential
    case authorizationError(String)
    case tokenError(String)
    case networkError(String)
    case unknown(String)
    case invalidResponse
    case notHandled
    case failed
    case credentialCheckFailed
    case unexpectedCredentialType
    case unknownError
    case invalidState
    
    public var localizedDescription: String {
        switch self {
        case .userCancelled:
            return "Sign in was cancelled"
        case .invalidCredential:
            return "The credentials are invalid"
        case .authorizationError(let message):
            return "Authorization error: \(message)"
        case .tokenError(let message):
            return "Token error: \(message)"
        case .networkError(let message):
            return "Network error: \(message)"
        case .unknown(let message):
            return "Unknown error: \(message)"
        case .invalidResponse:
            return "The authorization server returned an invalid response"
        case .notHandled:
            return "The authorization request was not handled"
        case .failed:
            return "The authorization request failed"
        case .credentialCheckFailed:
            return "Failed to check credential state"
        case .unexpectedCredentialType:
            return "Unexpected credential type received"
        case .unknownError:
            return "An unknown error occurred during authentication"
        case .invalidState:
            return "Invalid state during authentication"
        }
    }
}

/// Keys used for token storage
public struct TokenKeys {
    // Apple token keys
    public static let appleUserID = "apple.user.id"
    public static let appleIdToken = "apple.id.token"
    public static let appleRefreshToken = "apple.refresh.token"
    public static let appleAuthCode = "apple.auth.code"
    public static let appleEmail = "apple.user.email"
    public static let appleFirstName = "apple.user.firstName"
    public static let appleLastName = "apple.user.lastName"
    
    // Google token keys are defined in GoogleAuthProvider.swift
}

/// User information from Apple Sign In
public struct AppleUserInfo: Codable, Equatable {
    public let userId: String
    public let email: String?
    public let firstName: String?
    public let lastName: String?
    public let idToken: String?
    public let authCode: String?
    
    public var fullName: String? {
        if let firstName = firstName, let lastName = lastName, !firstName.isEmpty || !lastName.isEmpty {
            return [firstName, lastName].filter { !($0?.isEmpty ?? true) }.compactMap { $0 }.joined(separator: " ")
        }
        return nil
    }
    
    public init(userId: String, email: String? = nil, firstName: String? = nil, lastName: String? = nil, idToken: String? = nil, authCode: String? = nil) {
        self.userId = userId
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.idToken = idToken
        self.authCode = authCode
    }
}

/// User information from Google Sign In
public struct GoogleUserInfo: Codable, Equatable {
    public let userId: String
    public let email: String?
    public let fullName: String?
    public let givenName: String?
    public let familyName: String?
    public let profilePictureUrl: URL?
    public let idToken: String?
    public let accessToken: String?
    
    public init(userId: String, email: String? = nil, fullName: String? = nil, givenName: String? = nil, 
         familyName: String? = nil, profilePictureUrl: URL? = nil, idToken: String? = nil, accessToken: String? = nil) {
        self.userId = userId
        self.email = email
        self.fullName = fullName
        self.givenName = givenName
        self.familyName = familyName
        self.profilePictureUrl = profilePictureUrl
        self.idToken = idToken
        self.accessToken = accessToken
    }
} 