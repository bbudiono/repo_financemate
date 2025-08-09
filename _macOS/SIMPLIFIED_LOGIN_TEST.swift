import SwiftUI
import AuthenticationServices

// SIMPLIFIED LOGIN VIEW TO TEST SSO BUTTON VISIBILITY
// This removes all the complex styling and nested views to isolate the SSO button issue

struct SimplifiedLoginTestView: View {
    @StateObject private var authViewModel = AuthenticationViewModel(
        context: PersistenceController.shared.container.viewContext
    )
    
    @State private var email = ""
    @State private var password = ""
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 32) {
            // Header
            Text("FinanceMate Login Test")
                .font(.largeTitle)
                .padding(.bottom, 20)
            
            // Tab selector
            HStack {
                Button("Sign In") { selectedTab = 0 }
                    .foregroundColor(selectedTab == 0 ? .white : .secondary)
                    .padding()
                    .background(selectedTab == 0 ? Color.blue : Color.clear)
                    .cornerRadius(8)
                
                Button("Register") { selectedTab = 1 }
                    .foregroundColor(selectedTab == 1 ? .white : .secondary)
                    .padding()
                    .background(selectedTab == 1 ? Color.blue : Color.clear)
                    .cornerRadius(8)
            }
            
            if selectedTab == 0 {
                // Login form
                VStack(spacing: 16) {
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button("Sign In") {
                        Task {
                            await authViewModel.authenticate(email: email, password: password)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    
                    // OAuth divider
                    HStack {
                        Rectangle().frame(height: 1).foregroundColor(.gray)
                        Text("or").padding(.horizontal)
                        Rectangle().frame(height: 1).foregroundColor(.gray)
                    }
                    
                    // SSO BUTTONS - SIMPLE VERSION TO TEST VISIBILITY
                    VStack(spacing: 12) {
                        // Apple Sign-In Button
                        SignInWithAppleButton(
                            onRequest: { request in
                                request.requestedScopes = [.fullName, .email]
                                print("🍎 SIMPLE TEST: Apple Sign-In onRequest called")
                            },
                            onCompletion: { result in
                                print("🍎 SIMPLE TEST: Apple Sign-In onCompletion called")
                                switch result {
                                case .success(let authorization):
                                    print("🍎 SIMPLE TEST: SUCCESS")
                                    Task {
                                        await authViewModel.processAppleSignInCompletion(authorization)
                                    }
                                case .failure(let error):
                                    print("🍎 SIMPLE TEST: FAILURE - \(error)")
                                }
                            }
                        )
                        .frame(height: 50)
                        .signInWithAppleButtonStyle(.black)
                        
                        // Google Sign-In Button
                        Button(action: {
                            print("🔵 SIMPLE TEST: Google button tapped")
                            Task {
                                await authViewModel.authenticateWithOAuth2(provider: .google)
                            }
                        }) {
                            HStack {
                                Image(systemName: "g.circle.fill")
                                    .font(.system(size: 20))
                                
                                Text("Sign in with Google")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Microsoft Sign-In Button
                        Button(action: {
                            print("🔷 SIMPLE TEST: Microsoft button tapped")
                            Task {
                                await authViewModel.authenticateWithOAuth2(provider: .microsoft)
                            }
                        }) {
                            HStack {
                                Image(systemName: "m.circle.fill")
                                    .font(.system(size: 20))
                                
                                Text("Sign in with Microsoft")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .frame(maxWidth: 400)
            }
            
            Spacer()
        }
        .padding(40)
        .frame(minWidth: 500, minHeight: 600)
        .alert("Authentication Error", isPresented: .constant(authViewModel.errorMessage != nil)) {
            Button("OK") {
                authViewModel.errorMessage = nil
            }
        } message: {
            Text(authViewModel.errorMessage ?? "")
        }
    }
}

#Preview {
    SimplifiedLoginTestView()
}