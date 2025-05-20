// SANDBOX ENVIRONMENT
// Purpose: Main content view for SynchroNext app (Sandbox environment)
// Issues & Complexity: Main UI component with Apple authentication for sandbox.
// Ranking/Rating: 95% (Code), 92% (Problem) - Main UI component for Apple SSO (sandbox).
// SANDBOX FILE: For testing/development. See .cursorrules §5.3.1.

import SwiftUI
import AuthenticationServices // Keep for potential direct use, though AppleSignInViewSandbox handles it

public struct MainContentViewSandbox: View { // Renamed struct
    public init() {}
    
    public var body: some View {
        // Use AppleSignInViewSandbox to get both Apple and Google buttons
        AppleSignInViewSandbox(
            onSignIn: { appleCredential in
                // Handle Apple Sign In success
                print("[MainContentViewSandbox] Apple Sign In Successful. User: \(appleCredential.user)")
                // You might want to navigate or update UI state here
            },
            onError: { error in
                // Handle Apple Sign In error
                print("[MainContentViewSandbox] Apple Sign In Error: \(error.localizedDescription)")
                // You might want to show an alert to the user here
            }
        )
        // The AppleSignInViewSandbox already has its own layout, 
        // so we don't need the VStack and Text from before unless you want to frame it.
        // For simplicity, we'll let AppleSignInViewSandbox define the main content.
    }
}

#Preview {
    MainContentViewSandbox() // Updated preview
} 