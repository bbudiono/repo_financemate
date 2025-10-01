import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @ObservedObject var authManager: AuthenticationManager

    var body: some View {
        VStack(spacing: 30) {
            Text("FinanceMate")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Personal Wealth Management")
                .font(.title3)
                .foregroundColor(.secondary)

            Spacer()
                .frame(height: 50)

            SignInWithAppleButton(.signIn) { request in
                request.requestedScopes = [.email, .fullName]
            } onCompletion: { result in
                authManager.handleAppleSignIn(result: result)
            }
            .frame(height: 50)
            .frame(maxWidth: 300)

            if let error = authManager.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}
