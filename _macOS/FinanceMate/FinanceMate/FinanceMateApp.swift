import CoreData
import SwiftUI

@main
struct FinanceMateApp: App {
  let persistenceController = PersistenceController.shared
  let authenticationService = AuthenticationService()

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
          LoginView(
            onLoginSuccess: {
              isAuthenticated = authenticationService.getCurrentUser() != nil
            },
            onLoginError: { error in
              alertMessage = error
              showingLoginAlert = true
            }
          )
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

          // Auto-authenticate for testing using secure test session
          if authenticationService.createTestSession() != nil {
            isAuthenticated = authenticationService.getCurrentUser() != nil
            print("✅ Test session created for automated testing")
          }
        } else {
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
    isAuthenticated = authenticationService.getCurrentUser() != nil
    if isAuthenticated {
      print("✅ Existing user session found")
    }
  }
}

// Simple Login View for authentication
struct LoginView: View {
  let onLoginSuccess: () -> Void
  let onLoginError: (String) -> Void

  @State private var email = ""
  @State private var password = ""
  @State private var isLoading = false

  private let authenticationService = AuthenticationService()

  var body: some View {
    VStack(spacing: 20) {
      Text("FinanceMate")
        .font(.largeTitle)
        .fontWeight(.bold)

      Text("Welcome Back")
        .font(.title2)
        .foregroundColor(.secondary)

      TextField("Email", text: $email)
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .autocapitalization(.none)
        .keyboardType(.emailAddress)
        .disableAutocorrection(true)

      SecureField("Password", text: $password)
        .textFieldStyle(RoundedBorderTextFieldStyle())

      Button(action: login) {
        Text("Sign In")
          .frame(maxWidth: .infinity)
      }
      .buttonStyle(.borderedProminent)
      .disabled(isLoading || email.isEmpty || password.isEmpty)

      if isLoading {
        ProgressView()
          .scaleEffect(0.8)
      }
    }
    .padding()
    .frame(width: 300, height: 400)
  }

  private func login() {
    isLoading = true

    Task {
      let result = await authenticationService.signIn(email: email, password: password)

      await MainActor.run {
        isLoading = false

        if result.success {
          onLoginSuccess()
          print("✅ User authenticated successfully: \(email)")
        } else {
          onLoginError(result.error?.localizedDescription ?? "Authentication failed")
          print("❌ Authentication failed for: \(email)")
        }
      }
    }
  }
}
