import SwiftUI
import AuthenticationServices

// TEMPORARY TEST VIEW TO DIAGNOSE SSO BUTTON VISIBILITY ISSUE
struct SSOButtonTestView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("SSO Button Visibility Test")
                .font(.title)
                .padding()
            
            // Test 1: Standalone Apple Sign-In Button
            VStack {
                Text("Test 1: Standalone Apple Sign-In Button")
                    .font(.headline)
                
                SignInWithAppleButton(
                    onRequest: { request in
                        request.requestedScopes = [.fullName, .email]
                        print("🍎 TEST: Apple Sign-In onRequest called")
                    },
                    onCompletion: { result in
                        print("🍎 TEST: Apple Sign-In onCompletion called")
                        switch result {
                        case .success(let authorization):
                            print("🍎 TEST: SUCCESS - \(authorization)")
                        case .failure(let error):
                            print("🍎 TEST: FAILURE - \(error)")
                        }
                    }
                )
                .frame(height: 50)
                .signInWithAppleButtonStyle(.black)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            
            // Test 2: Standalone Google Button
            VStack {
                Text("Test 2: Standalone Google Button")
                    .font(.headline)
                
                Button(action: {
                    print("🔵 TEST: Google button tapped")
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
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            
            // Test 3: Combined OAuth buttons like in LoginView
            VStack {
                Text("Test 3: Combined OAuth buttons (LoginView style)")
                    .font(.headline)
                
                VStack(spacing: 12) {
                    // Sign in with Apple
                    SignInWithAppleButton(
                        onRequest: { request in
                            request.requestedScopes = [.fullName, .email]
                            print("🍎 COMBINED TEST: Apple Sign-In onRequest called")
                        },
                        onCompletion: { result in
                            print("🍎 COMBINED TEST: Apple Sign-In onCompletion called")
                        }
                    )
                    .frame(height: 50)
                    .signInWithAppleButtonStyle(.black)
                    
                    // Sign in with Google
                    Button(action: {
                        print("🔵 COMBINED TEST: Google button tapped")
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
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            
            Spacer()
        }
        .padding()
        .frame(minWidth: 500, minHeight: 700)
    }
}

#Preview {
    SSOButtonTestView()
}