import SwiftUI
import AuthenticationServices

@MainActor
class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var userEmail: String?
    @Published var userName: String?
    @Published var errorMessage: String?

    func handleAppleSignIn(result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let auth):
            if let credential = auth.credential as? ASAuthorizationAppleIDCredential {
                // Capture and persist user details
                userEmail = credential.email

                if let fullName = credential.fullName {
                    let components = [fullName.givenName, fullName.familyName].compactMap { $0 }
                    userName = components.joined(separator: " ")
                }

                // Store in Keychain
                KeychainHelper.save(value: credential.user, account: "apple_user_id")
                if let email = credential.email {
                    KeychainHelper.save(value: email, account: "apple_user_email")
                }
                if let name = userName {
                    KeychainHelper.save(value: name, account: "apple_user_name")
                }

                isAuthenticated = true
            }
        case .failure(let error):
            errorMessage = "Apple Sign In failed: \(error.localizedDescription)"
        }
    }

    func checkAuthStatus() {
        if KeychainHelper.get(account: "apple_user_id") != nil {
            isAuthenticated = true
            // Load stored user details
            userEmail = KeychainHelper.get(account: "apple_user_email")
            userName = KeychainHelper.get(account: "apple_user_name")
        }
    }

    func signOut() {
        let _ = try? KeychainHelper.delete(account: "apple_user_id")
        let _ = try? KeychainHelper.delete(account: "apple_user_email")
        let _ = try? KeychainHelper.delete(account: "apple_user_name")
        let _ = try? KeychainHelper.delete(account: "google_user_id")
        let _ = try? KeychainHelper.delete(account: "google_user_email")
        let _ = try? KeychainHelper.delete(account: "google_user_name")
        let _ = try? KeychainHelper.delete(account: "gmail_refresh_token")
        let _ = try? KeychainHelper.delete(account: "gmail_access_token")

        isAuthenticated = false
        userEmail = nil
        userName = nil
    }

    // MARK: - Google Sign In (OAuth 2.0)

    func handleGoogleSignIn(code: String) async {
        guard let clientID = ProcessInfo.processInfo.environment["GOOGLE_OAUTH_CLIENT_ID"],
              let clientSecret = ProcessInfo.processInfo.environment["GOOGLE_OAUTH_CLIENT_SECRET"] else {
            errorMessage = "Google OAuth credentials not found in .env"
            return
        }

        do {
            _ = try await GmailOAuthHelper.exchangeCodeForToken(
                code: code,
                clientID: clientID,
                clientSecret: clientSecret
            )

            // Access token is now in Keychain, fetch user info
            if let accessToken = KeychainHelper.get(account: "gmail_access_token"),
               let userInfo = try? await fetchGoogleUserInfo(accessToken: accessToken) {
                userEmail = userInfo.email
                userName = userInfo.name

                KeychainHelper.save(value: userInfo.id, account: "google_user_id")
                KeychainHelper.save(value: userInfo.email, account: "google_user_email")
                KeychainHelper.save(value: userInfo.name, account: "google_user_name")
            }

            isAuthenticated = true
        } catch {
            errorMessage = "Google Sign In failed: \(error.localizedDescription)"
        }
    }

    private func fetchGoogleUserInfo(accessToken: String) async throws -> GoogleUserInfo {
        guard let url = URL(string: "https://www.googleapis.com/oauth2/v2/userinfo") else {
            throw NSError(domain: "AuthError", code: -1)
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(GoogleUserInfo.self, from: data)
    }

    func checkGoogleAuthStatus() {
        if KeychainHelper.get(account: "google_user_id") != nil {
            isAuthenticated = true
            userEmail = KeychainHelper.get(account: "google_user_email")
            userName = KeychainHelper.get(account: "google_user_name")
        }
    }
}

struct GoogleUserInfo: Codable {
    let id: String
    let email: String
    let name: String
}
