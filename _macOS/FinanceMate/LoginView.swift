import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @ObservedObject var authManager: AuthenticationManager
    @State private var showGoogleCodeInput = false
    @State private var googleAuthCode = ""
    @State private var isAuthenticating = false

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
                isAuthenticating = true
                authManager.handleAppleSignIn(result: result)
                isAuthenticating = false
            }
            .frame(height: 50)
            .frame(maxWidth: 300)
            .accessibilityLabel("Sign in with Apple")
            .disabled(isAuthenticating)

            Button(action: {
                isAuthenticating = true
                if let clientID = ProcessInfo.processInfo.environment["GOOGLE_OAUTH_CLIENT_ID"],
                   let url = GmailOAuthHelper.getAuthorizationURL(clientID: clientID) {
                    NSWorkspace.shared.open(url)
                    showGoogleCodeInput = true
                }
                isAuthenticating = false
            }) {
                HStack {
                    Image(systemName: "g.circle.fill")
                    Text("Sign in with Google")
                }
                .frame(maxWidth: 300)
                .frame(height: 50)
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
            .accessibilityLabel("Sign in with Google")
            .disabled(isAuthenticating)

            if showGoogleCodeInput {
                VStack(spacing: 12) {
                    TextField("Enter Google authorization code", text: $googleAuthCode)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: 300)

                    Button("Submit Code") {
                        Task {
                            await authManager.handleGoogleSignIn(code: googleAuthCode)
                            showGoogleCodeInput = false
                            googleAuthCode = ""
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            }

            if isAuthenticating {
                ProgressView("Authenticating...")
                    .padding()
            }

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
