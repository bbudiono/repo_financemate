// Purpose: Main content view for SynchroNext app.
// Issues & Complexity: Main UI component with Apple authentication.
// Ranking/Rating: 95% (Code), 92% (Problem) - Main UI component for Apple SSO.

import SwiftUI
import AuthenticationServices

public struct MainContentView: View {
    public init() {}
    
    public var body: some View {
        VStack(spacing: 20) {
            Text("SynchroNext Apple Sign In")
                .font(.largeTitle)
                .padding(.bottom, 30)
            
            AppleSignInView(
                onSignIn: { credential in
                    print("MainContentView: Successfully authenticated with Apple: \(credential.user)")
                },
                onError: { error in
                    print("MainContentView: Apple sign in error: \(error.localizedDescription)")
                }
            )
        }
        .padding(40)
        .frame(width: 400, height: 400)
    }
}

#Preview {
    MainContentView()
} 