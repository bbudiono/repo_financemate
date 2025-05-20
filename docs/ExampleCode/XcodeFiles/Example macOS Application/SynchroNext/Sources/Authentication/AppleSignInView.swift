// Purpose: Apple Sign In view with native Apple authentication button.
// Issues & Complexity: Core UI component with Apple authentication.
// Ranking/Rating: 95% (Code), 92% (Problem) - Essential UI component for Apple SSO.

import SwiftUI
import AuthenticationServices

/// View for Sign in with Apple functionality using native Apple authentication button.
public struct AppleSignInView: View {
    // Callbacks passed from MainContentView or whoever uses this view
    private let onAppleSignInSuccessExt: ((ASAuthorizationAppleIDCredential) -> Void)?
    private let onAppleSignInErrorExt: ((Error) -> Void)?
    
    // Internal state for alerts
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    // For Apple Sign In
    private var appleAuthProvider = AppleAuthProvider()
    
    // For Google Sign In
    private var googleAuthProvider = GoogleAuthProvider()

    public init(
        onSignIn: ((ASAuthorizationAppleIDCredential) -> Void)? = nil,
        onError: ((Error) -> Void)? = nil
    ) {
        self.onAppleSignInSuccessExt = onSignIn
        self.onAppleSignInErrorExt = onError
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            Text("Sign In")
                .font(.largeTitle)
                .padding(.bottom, 20)

            // Apple Sign In Button
            SignInWithAppleButton(
                .signIn,
                onRequest: { request in
                    request.requestedScopes = [.fullName, .email]
                },
                onCompletion: { result in
                    switch result {
                    case .success(let authorization):
                        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                            self.onAppleSignInSuccessExt?(appleIDCredential)
                        }
                    case .failure(let error):
                        self.onAppleSignInErrorExt?(error)
                        if self.appleAuthProvider.onSignInFailure == nil {
                            self.alertTitle = "Apple Sign-In Error"
                            self.alertMessage = error.localizedDescription
                            self.showAlert = true
                        }
                    }
                }
            )
            .signInWithAppleButtonStyle(.black)
            .frame(width: 280, height: 45)
            .onHover { inside in
                if inside {
                    NSCursor.pointingHand.push()
                } else {
                    NSCursor.pop()
                }
            }

            // Google Sign In Button
            Button(action: {
                guard let window = NSApplication.shared.windows.first(where: { $0.isKeyWindow }) ?? NSApplication.shared.windows.first else {
                    self.alertTitle = "Google Sign-In Error"
                    self.alertMessage = "Could not find a window to present the login page."
                    self.showAlert = true
                    return
                }
                googleAuthProvider.signIn(presentingWindow: window)
            }) {
                HStack {
                    Image(systemName: "g.circle.fill")
                        .foregroundColor(.white)
                    Text("Sign in with Google")
                        .foregroundColor(.white)
                }
                .padding()
                .frame(width: 280, height: 45)
                .background(Color.blue)
                .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
            .onHover { inside in
                if inside {
                    NSCursor.pointingHand.push()
                } else {
                    NSCursor.pop()
                }
            }

            Spacer()
        }
        .padding(40)
        .frame(minWidth: 400, minHeight: 300)
        .onAppear {
            appleAuthProvider.onSignInSuccess = { userIdentifier, fullName, email in
                self.alertTitle = "Apple Sign-In Success"
                var successMessage = "User ID: \(userIdentifier)"
                if let name = fullName, !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    successMessage += "\nName: \(name)"
                } else if let mail = email, !mail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    successMessage += "\nEmail: \(mail)"
                }
                self.alertMessage = successMessage
                self.showAlert = true
            }
            appleAuthProvider.onSignInFailure = { errorDetails in
                self.alertTitle = "Apple Sign-In Failed"
                self.alertMessage = errorDetails
                self.showAlert = true
            }

            googleAuthProvider.onSignInSuccess = { idToken, fullName, email in
                self.alertTitle = "Google Sign-In Success"
                var successMessage = "Google User Authenticated!"
                if let name = fullName, !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    successMessage += "\nName: \(name)"
                }
                if let mail = email, !mail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    successMessage += "\nEmail: \(mail)"
                }
                self.alertMessage = successMessage
                self.showAlert = true
            }
            googleAuthProvider.onSignInFailure = { error in
                self.alertTitle = "Google Sign-In Failed"
                self.alertMessage = error.localizedDescription
                self.showAlert = true
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
}

// MARK: - Previews

struct AppleSignInView_Previews: PreviewProvider {
    static var previews: some View {
        AppleSignInView(
            onSignIn: { credential in
                print("Preview: Apple Signed in. User ID: \(credential.user)")
            },
            onError: { error in
                print("Preview: Apple Sign-In Error: \(error.localizedDescription)")
            }
        )
    }
} 
