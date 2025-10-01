import SwiftUI
import AuthenticationServices

@MainActor
class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var userEmail: String?
    @Published var errorMessage: String?

    func handleAppleSignIn(result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let auth):
            if let credential = auth.credential as? ASAuthorizationAppleIDCredential {
                userEmail = credential.email
                KeychainHelper.save(value: credential.user, account: "apple_user_id")
                isAuthenticated = true
            }
        case .failure(let error):
            errorMessage = "Apple Sign In failed: \(error.localizedDescription)"
        }
    }

    func checkAuthStatus() {
        if KeychainHelper.get(account: "apple_user_id") != nil {
            isAuthenticated = true
        }
    }
}
