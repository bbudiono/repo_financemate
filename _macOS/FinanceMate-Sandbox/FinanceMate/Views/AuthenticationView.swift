//
//  AuthenticationView.swift
//  FinanceMate
//
//  Purpose: Proper authentication view with native Sign In with Apple button
//

import AuthenticationServices
import SwiftUI

struct AuthenticationView: View {
    @ObservedObject var authService: AuthenticationService
    @State private var showingError = false
    @State private var errorMessage = ""

    var body: some View {
        VStack(spacing: 30) {
            // Logo and Welcome
            VStack(spacing: 20) {
                Image(systemName: "dollarsign.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.green.gradient)
                    .shadow(radius: 10)

                Text("Welcome to FinanceMate")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Your AI-powered financial companion")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 40)

            // Sign In Options
            VStack(spacing: 16) {
                // Native Sign In with Apple Button
                SignInWithAppleButton(
                    onRequest: { request in
                        request.requestedScopes = [.fullName, .email]
                    },
                    onCompletion: { result in
                        handleSignInWithAppleResult(result)
                    }
                )
                .signInWithAppleButtonStyle(.whiteOutline)
                .frame(height: 50)
                .frame(maxWidth: 280)

                // Google Sign In Button (styled to match)
                Button(action: signInWithGoogle) {
                    HStack {
                        Image(systemName: "globe")
                            .font(.system(size: 20))
                        Text("Sign in with Google")
                            .font(.system(size: 19, weight: .medium))
                    }
                    .frame(height: 50)
                    .frame(maxWidth: 280)
                    .background(Color(NSColor.controlBackgroundColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(NSColor.separatorColor), lineWidth: 0.5)
                    )
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }

            // Loading indicator
            if authService.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding(.top, 20)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.windowBackgroundColor))
        .alert("Authentication Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }

    // MARK: - Sign In with Apple Handler

    private func handleSignInWithAppleResult(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            handleAuthorization(authorization)
        case .failure(let error):
            errorMessage = "Sign in with Apple failed: \(error.localizedDescription)"
            showingError = true
        }
    }

    private func handleAuthorization(_ authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            errorMessage = "Invalid credential type"
            showingError = true
            return
        }

        Task {
            do {
                // Create authenticated user from Apple credentials
                let email = appleIDCredential.email ?? ""
                let fullName = [
                    appleIDCredential.fullName?.givenName,
                    appleIDCredential.fullName?.familyName
                ]
                .compactMap { $0 }
                .joined(separator: " ")

                // Handle the Apple Sign In through AuthenticationService
                let authData = AppleAuthData(
                    userIdentifier: appleIDCredential.user,
                    email: email,
                    fullName: fullName.isEmpty ? nil : fullName,
                    identityToken: appleIDCredential.identityToken,
                    authorizationCode: appleIDCredential.authorizationCode
                )

                try await authService.handleAppleSignIn(authData: authData)
            } catch {
                errorMessage = error.localizedDescription
                showingError = true
            }
        }
    }

    // MARK: - Google Sign In

    private func signInWithGoogle() {
        Task {
            do {
                _ = try await authService.signInWithGoogle()
            } catch {
                errorMessage = error.localizedDescription
                showingError = true
            }
        }
    }
}

#Preview {
    AuthenticationView(authService: AuthenticationService())
        .frame(width: 600, height: 500)
}
