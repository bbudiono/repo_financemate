import SwiftUI

struct ProfileView: View {
    var user: MockUser? = nil
    var onGoogleSignIn: (() -> Void)? = nil
    var onSignOut: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Profile")
                .font(.largeTitle)
                .fontWeight(.bold)
                .accessibilityIdentifier("ProfileTitle")
            if let user = user {
                Text("Welcome, \(user.name)")
                    .font(.title2)
                    .accessibilityIdentifier("ProfileWelcome")
                Text(user.email)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .accessibilityIdentifier("ProfileEmail")
                
                Spacer().frame(height: 20)
                
                // Sign Out Button
                Button(action: {
                    onSignOut?()
                }) {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                        Text("Sign Out")
                            .accessibilityIdentifier("SignOutButtonLabel")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: 200)
                    .background(Color.red)
                    .cornerRadius(8)
                }
                .accessibilityIdentifier("SignOutButton")
            } else {
                Text("Not signed in")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .accessibilityIdentifier("ProfileNotSignedIn")
                
                Button(action: {
                    onGoogleSignIn?()
                }) {
                    HStack {
                        Image(systemName: "globe")
                        Text("Sign in with Google")
                            .accessibilityIdentifier("GoogleSSOButtonLabel")
                    }
                    .font(.title2)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
                .accessibilityIdentifier("GoogleSSOButton")
            }
        }
        .padding()
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ProfileView(user: MockUser(name: "Test User", email: "test@example.com"))
            ProfileView(user: nil)
        }
    }
}

// MockUser struct for preview/testing
struct MockUser {
    let name: String
    let email: String
} 