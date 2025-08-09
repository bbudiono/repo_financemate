// SANDBOX FILE: For testing/development. See .cursorrules.

import Foundation

/// Authentication states for the sandbox environment
enum AuthenticationState {
  case unauthenticated
  case authenticating
  case authenticated
}

/// OAuth2 providers imported from main project UserSession.swift

/// Authentication service protocol for sandbox
protocol AuthenticationServiceProtocol {
  func authenticate(email: String, password: String) async -> (
    user: User?, session: UserSession?, error: String?
  )
  func authenticateWithOAuth2(provider: OAuth2Provider) async -> (
    user: User?, session: UserSession?, error: String?
  )
  func signOut() async
}




