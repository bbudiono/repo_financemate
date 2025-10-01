import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authManager: AuthenticationManager

    var body: some View {
        VStack(spacing: 20) {
            Text("Settings")
                .font(.largeTitle)
                .fontWeight(.bold)

            if let email = authManager.userEmail {
                Text("Signed in as: \(email)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button("Sign Out") {
                signOut()
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
        }
        .padding()
    }

    private func signOut() {
        let _ = try? KeychainHelper.delete(account: "apple_user_id")
        let _ = try? KeychainHelper.delete(account: "gmail_refresh_token")
        let _ = try? KeychainHelper.delete(account: "gmail_access_token")
        authManager.isAuthenticated = false
        authManager.userEmail = nil
    }
}
