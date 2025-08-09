// SANDBOX FILE: For testing/development. See .cursorrules.

import Foundation

/// User session model for sandbox environment
struct UserSession {
  let id: UUID
  let userId: UUID
  let provider: String
  let accessToken: String
  let refreshToken: String?
  let expiresAt: Date
  let createdAt: Date

  init(
    userId: UUID,
    provider: String,
    accessToken: String = "sandbox_token_\(UUID().uuidString)",
    refreshToken: String? = nil,
    expiresAt: Date = Date().addingTimeInterval(3600)  // 1 hour
  ) {
    self.id = UUID()
    self.userId = userId
    self.provider = provider
    self.accessToken = accessToken
    self.refreshToken = refreshToken
    self.expiresAt = expiresAt
    self.createdAt = Date()
  }

  /// Check if the session is valid
  var isValid: Bool {
    return expiresAt > Date()
  }

  /// Check if the session is expired
  var isExpired: Bool {
    return !isValid
  }
}




