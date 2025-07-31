import AuthenticationServices
import CryptoKit
import Foundation

// MARK: - Authentication Service Protocol
protocol AuthenticationServiceProtocol {
  func authenticateWithApple() async throws -> AuthenticationResult
  func authenticateWithGoogle() async throws -> AuthenticationResult
  func authenticateWithBiometrics() async throws -> AuthenticationResult
  func authenticateWithEmail(email: String, password: String) async throws -> AuthenticationResult
  func signOut() async throws
  func getCurrentUser() -> User?
}

// MARK: - Authentication Result
struct AuthenticationResult {
  let success: Bool
  let user: User?
  let error: Error?
  let provider: AuthenticationProvider
}

// MARK: - User Model
struct User {
  let id: String
  let email: String
  let displayName: String
  let provider: AuthenticationProvider
  let isAuthenticated: Bool
}

// MARK: - Authentication Provider
enum AuthenticationProvider: String {
  case apple = "apple"
  case google = "google"
  case biometrics = "biometrics"
  case email = "email"
}

// MARK: - Authentication Service Implementation
class AuthenticationService: NSObject, AuthenticationServiceProtocol,
  ASAuthorizationControllerDelegate,
  ASAuthorizationControllerPresentationContextProviding
{

  // MARK: - Properties
  private let persistenceController = PersistenceController.shared
  private var authenticationContinuation: CheckedContinuation<AuthenticationResult, Error>?

  // MARK: - AuthenticationServiceProtocol Implementation

  func authenticateWithApple() async throws -> AuthenticationResult {
    return try await withCheckedThrowingContinuation { continuation in
      authenticationContinuation = continuation

      let appleIDProvider = ASAuthorizationAppleIDProvider()
      let request = appleIDProvider.createRequest()
      request.requestedScopes = [.fullName, .email]
      request.state = generateNonce()

      let authorizationController = ASAuthorizationController(authorizationRequests: [request])
      authorizationController.delegate = self
      authorizationController.presentationContextProvider = self
      authorizationController.performRequests()
    }
  }

  func authenticateWithGoogle() async throws -> AuthenticationResult {
    // Placeholder for Google OAuth implementation
    // In a production implementation, this would integrate with Google Sign-In SDK
    throw AuthenticationError.notImplemented("Google OAuth implementation pending")
  }

  func authenticateWithBiometrics() async throws -> AuthenticationResult {
    // Placeholder for biometric authentication
    // In a production implementation, this would use LocalAuthentication framework
    throw AuthenticationError.notImplemented("Biometric authentication implementation pending")
  }

  func authenticateWithEmail(email: String, password: String) async throws -> AuthenticationResult {
    // Validate email format
    guard isValidEmail(email) else {
      throw AuthenticationError.invalidEmail("Invalid email format")
    }

    // Validate password
    guard password.count >= 6 else {
      throw AuthenticationError.invalidPassword("Password must be at least 6 characters")
    }

    // Check for suspicious email patterns
    guard !isSuspiciousEmail(email) else {
      throw AuthenticationError.suspiciousEmail("Suspicious email pattern detected")
    }

    // Create user session
    let user = User(
      id: UUID().uuidString,
      email: email,
      displayName: email.components(separatedBy: "@").first ?? "User",
      provider: .email,
      isAuthenticated: true
    )

    // Store authentication session
    storeUserSession(user)

    return AuthenticationResult(
      success: true,
      user: user,
      error: nil,
      provider: .email
    )
  }

  func signOut() async throws {
    // Clear user session
    UserDefaults.standard.removeObject(forKey: "authenticated_user_id")
    UserDefaults.standard.removeObject(forKey: "authenticated_user_email")
    UserDefaults.standard.removeObject(forKey: "authenticated_user_display_name")
    UserDefaults.standard.removeObject(forKey: "authentication_provider")
    UserDefaults.standard.removeObject(forKey: "authenticated_user_login_time")

    print("✅ User signed out successfully")
  }

  func getCurrentUser() -> User? {
    guard let userId = UserDefaults.standard.string(forKey: "authenticated_user_id"),
      let email = UserDefaults.standard.string(forKey: "authenticated_user_email"),
      let displayName = UserDefaults.standard.string(forKey: "authenticated_user_display_name"),
      let providerString = UserDefaults.standard.string(forKey: "authentication_provider"),
      let provider = AuthenticationProvider(rawValue: providerString)
    else {
      return nil
    }

    return User(
      id: userId,
      email: email,
      displayName: displayName,
      provider: provider,
      isAuthenticated: true
    )
  }

  // MARK: - ASAuthorizationControllerDelegate

  func authorizationController(
    controller: ASAuthorizationController,
    didCompleteWithAuthorization authorization: ASAuthorization
  ) {
    guard let continuation = authenticationContinuation else { return }

    do {
      if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
        let result = try handleAppleSignInSuccess(appleIDCredential)
        continuation.resume(returning: result)
      } else {
        let error = AuthenticationError.unknown("Unknown credential type received")
        continuation.resume(throwing: error)
      }
    } catch {
      continuation.resume(throwing: error)
    }

    authenticationContinuation = nil
  }

  func authorizationController(
    controller: ASAuthorizationController, didCompleteWithError error: Error
  ) {
    guard let continuation = authenticationContinuation else { return }

    if let authError = error as? ASAuthorizationError {
      let mappedError = mapAppleSignInError(authError)
      continuation.resume(throwing: mappedError)
    } else {
      continuation.resume(throwing: error)
    }

    authenticationContinuation = nil
  }

  // MARK: - ASAuthorizationControllerPresentationContextProviding

  func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
    return NSApplication.shared.windows.first { $0.isKeyWindow } ?? NSApplication.shared.windows
      .first!
  }

  // MARK: - Private Methods

  private func generateNonce() -> String {
    let length = 32
    var bytes = [UInt8](repeating: 0, count: length)
    let status = SecRandomCopyBytes(kSecRandomDefault, length, &bytes)

    if status != errSecSuccess {
      return UUID().uuidString.replacingOccurrences(of: "-", with: "")
    }

    return Data(bytes).base64EncodedString()
      .replacingOccurrences(of: "=", with: "")
      .replacingOccurrences(of: "+", with: "-")
      .replacingOccurrences(of: "/", with: "_")
  }

  private func handleAppleSignInSuccess(_ credential: ASAuthorizationAppleIDCredential) throws
    -> AuthenticationResult
  {
    let userIdentifier = credential.user
    let email = credential.email ?? "unknown@apple.local"
    let fullName = credential.fullName

    var displayName = "Apple User"
    if let fullName = fullName {
      let nameComponents = [
        fullName.givenName,
        fullName.familyName,
        fullName.middleName,
        fullName.namePrefix,
        fullName.nameSuffix,
      ].compactMap { $0 }.joined(separator: " ")

      if !nameComponents.isEmpty {
        displayName = nameComponents
      }
    }

    // Validate email format
    guard isValidEmail(email) else {
      throw AuthenticationError.invalidEmail("Invalid email format from Apple Sign-In")
    }

    let user = User(
      id: userIdentifier,
      email: email,
      displayName: displayName,
      provider: .apple,
      isAuthenticated: true
    )

    // Store user session
    storeUserSession(user)

    return AuthenticationResult(
      success: true,
      user: user,
      error: nil,
      provider: .apple
    )
  }

  private func storeUserSession(_ user: User) {
    UserDefaults.standard.set(user.id, forKey: "authenticated_user_id")
    UserDefaults.standard.set(user.email, forKey: "authenticated_user_email")
    UserDefaults.standard.set(user.displayName, forKey: "authenticated_user_display_name")
    UserDefaults.standard.set(user.provider.rawValue, forKey: "authentication_provider")
    UserDefaults.standard.set(Date(), forKey: "authenticated_user_login_time")

    print("✅ User session stored for: \(user.displayName) (\(user.email))")
    print("📝 Audit log: Authentication recorded")
  }

  private func isValidEmail(_ email: String) -> Bool {
    let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
    return emailPredicate.evaluate(with: email)
  }

  private func isSuspiciousEmail(_ email: String) -> Bool {
    let suspiciousPatterns = ["test@", "demo@", "fake@", "temp@"]
    return suspiciousPatterns.contains { pattern in
      email.lowercased().contains(pattern)
    }
  }

  private func mapAppleSignInError(_ authError: ASAuthorizationError) -> AuthenticationError {
    switch authError.code {
    case .canceled:
      return .canceled("Apple Sign-In was canceled by user")
    case .failed:
      return .failed("Apple Sign-In failed")
    case .invalidResponse:
      return .invalidResponse("Apple Sign-In received invalid response")
    case .notHandled:
      return .notHandled("Apple Sign-In was not handled")
    case .unknown:
      return .unknown("Apple Sign-In encountered unknown error")
    @unknown default:
      return .unknown("Apple Sign-In encountered unexpected error")
    }
  }
}

// MARK: - Authentication Errors
enum AuthenticationError: Error, LocalizedError {
  case invalidEmail(String)
  case invalidPassword(String)
  case suspiciousEmail(String)
  case canceled(String)
  case failed(String)
  case invalidResponse(String)
  case notHandled(String)
  case unknown(String)
  case notImplemented(String)

  var errorDescription: String? {
    switch self {
    case .invalidEmail(let message):
      return message
    case .invalidPassword(let message):
      return message
    case .suspiciousEmail(let message):
      return message
    case .canceled(let message):
      return message
    case .failed(let message):
      return message
    case .invalidResponse(let message):
      return message
    case .notHandled(let message):
      return message
    case .unknown(let message):
      return message
    case .notImplemented(let message):
      return message
    }
  }
}
