import SwiftUI

struct SettingsView: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var displayName: String = ""
    @State private var isSaving = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Settings")
                .font(.largeTitle)
                .fontWeight(.bold)

            // User Profile Card
            if authManager.isAuthenticated {
                VStack(spacing: 12) {
                    if let name = authManager.userName {
                        Text(name)
                            .font(.title2)
                            .fontWeight(.semibold)
                    }

                    if let email = authManager.userEmail {
                        Text(email)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    // Display Name TextField
                    HStack {
                        Text("Display Name:")
                            .foregroundColor(.secondary)
                        TextField("Enter display name", text: $displayName)
                            .textFieldStyle(.roundedBorder)
                            .frame(maxWidth: 200)
                    }

                    // Save Button
                    Button("Save") {
                        Task {
                            isSaving = true
                            // Save settings logic here
                            // For now, just simulate saving
                            try? await Task.sleep(nanoseconds: 500_000_000)
                            isSaving = false
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isSaving)

                    if isSaving {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(.ultraThinMaterial))
            }

            Spacer()

            Button("Sign Out") {
                authManager.signOut()
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
        }
        .padding()
    }
}
