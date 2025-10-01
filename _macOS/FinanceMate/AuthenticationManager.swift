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
        let _ = try? KeychainHelper.delete(account: "gmail_refresh_token")
        let _ = try? KeychainHelper.delete(account: "gmail_access_token")

        isAuthenticated = false
        userEmail = nil
        userName = nil
    }
}
