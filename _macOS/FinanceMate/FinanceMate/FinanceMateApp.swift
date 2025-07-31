import AuthenticationServices
import CoreData
import SwiftUI

@main
struct FinanceMateApp: App {
  let persistenceController = PersistenceController.shared

  @State private var isAuthenticated = false
  @State private var showingLoginAlert = false
  @State private var alertMessage = ""

  // Check if running in headless mode for testing
  private var isHeadlessMode: Bool {
    ProcessInfo.processInfo.environment["HEADLESS_MODE"] == "1"
      || ProcessInfo.processInfo.environment["UI_TESTING"] == "1"
      || CommandLine.arguments.contains("--headless")
      || CommandLine.arguments.contains("--uitesting")
  }

  var body: some Scene {
    WindowGroup {
      Group {
        if isAuthenticated || isHeadlessMode {
          ContentView()
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
        } else {
          // Use comprehensive LoginView with Apple SSO
          AuthenticationWrapperView { success in
            isAuthenticated = success
          }
        }
      }
      .onAppear {
        if isHeadlessMode {
          // Configure for headless testing
          print("📱 FinanceMate running in headless mode for automated testing")

          // Disable animations and visual effects for faster testing
          #if DEBUG
            UserDefaults.standard.set(true, forKey: "DisableAnimations")
            UserDefaults.standard.set(true, forKey: "HeadlessMode")
          #endif

          // Auto-authenticate for testing
          isAuthenticated = true
          print("✅ Test session created for automated testing")
        } else {
          // Check for existing session
          checkExistingSession()
        }
      }
      .alert("Login Error", isPresented: $showingLoginAlert) {
        Button("OK") {}
      } message: {
        Text(alertMessage)
      }
    }
    .windowStyle(.hiddenTitleBar)
    .windowResizability(isHeadlessMode ? .contentSize : .contentMinSize)
  }

  private func checkExistingSession() {
    // Check for existing authentication session
    if UserDefaults.standard.string(forKey: "authenticated_user_id") != nil {
      isAuthenticated = true
      print("✅ Existing user session found")
    }
  }
}

// MARK: - Authentication Wrapper View

struct AuthenticationWrapperView: View {
  let onAuthenticationSuccess: (Bool) -> Void

  @State private var isLoading = false

  var body: some View {
    VStack(spacing: 30) {
      // Header
      VStack(spacing: 20) {
        Text("FinanceMate")
          .font(.largeTitle)
          .fontWeight(.bold)

        Text("Secure Financial Management")
          .font(.title3)
          .foregroundColor(.secondary)
      }

      Spacer()

      // Apple Sign In Button
      SignInWithAppleButton(.signIn) { request in
        request.requestedScopes = [.fullName, .email]
      } onCompletion: { result in
        handleSignInWithAppleResult(result)
      }
      .signInWithAppleButtonStyle(.black)
      .frame(height: 50)
      .cornerRadius(12)

      if isLoading {
        ProgressView()
          .scaleEffect(0.8)
      }

      Spacer()

      // Footer
      Text("FinanceMate v1.0.0")
        .font(.caption)
        .foregroundColor(.secondary)
    }
    .padding(40)
    .frame(width: 400, height: 500)
  }

  private func handleSignInWithAppleResult(_ result: Result<ASAuthorization, Error>) {
    switch result {
    case .success(let authorization):
      isLoading = true

      // Handle successful authentication
      Task {
        // Simulate authentication delay
        try? await Task.sleep(for: .milliseconds(500))

        await MainActor.run {
          isLoading = false

          // Store session
          UserDefaults.standard.set(UUID().uuidString, forKey: "authenticated_user_id")
          UserDefaults.standard.set("Apple ID User", forKey: "authenticated_user_email")
          UserDefaults.standard.set(Date(), forKey: "authenticated_user_login_time")

          onAuthenticationSuccess(true)
          print("✅ Apple Sign In successful")
        }
      }

    case .failure(let error):
      print("❌ Apple Sign In failed: \(error)")
      isLoading = false
    }
  }
}
