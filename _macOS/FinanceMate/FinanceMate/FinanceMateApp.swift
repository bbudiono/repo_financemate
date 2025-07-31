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
        if isAuthenticated {
          ContentView()
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
            .environmentObject(authenticationService)
        } else {
          LoginScreenView(
            isAuthenticated: $isAuthenticated,
            showingLoginAlert: $showingLoginAlert,
            alertMessage: $alertMessage,
            authenticationService: authenticationService
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
        } else {
          // Check for existing authentication session
          checkExistingSession()
        }
      }
    }
    .windowStyle(.hiddenTitleBar)
    .windowResizability(isHeadlessMode ? .contentSize : .contentMinSize)
  }

  private func checkExistingSession() {
    if authenticationService.getCurrentUser() != nil {
      isAuthenticated = true
      print("✅ Existing user session found")
    }
  }
}

// MARK: - Login Screen View

struct LoginScreenView: View {
  @Binding var isAuthenticated: Bool
  @Binding var showingLoginAlert: Bool
  @Binding var alertMessage: String

  @StateObject private var authenticationService: AuthenticationService

  @State private var email = ""
  @State private var password = ""
  @State private var selectedTab = 0
  @State private var isLoading = false

  init(
    isAuthenticated: Binding<Bool>,
    showingLoginAlert: Binding<Bool>,
    alertMessage: Binding<String>,
    authenticationService: AuthenticationService
  ) {
    self._isAuthenticated = isAuthenticated
    self._showingLoginAlert = showingLoginAlert
    self._alertMessage = alertMessage
    self._authenticationService = StateObject(wrappedValue: authenticationService)
  }

  var body: some View {
    VStack(spacing: 30) {
      loginHeader
      loginForm
      privacyNotice
    }
    .frame(maxWidth: 500)
    .padding(40)
    .background(backgroundGradient)
    .alert("Authentication", isPresented: $showingLoginAlert) {
      Button("OK") {}
    } message: {
      Text(alertMessage)
    }
  }

  private var loginHeader: some View {
    VStack(spacing: 16) {
      Image(systemName: "lock.shield")
        .font(.system(size: 64))
        .foregroundColor(.accentColor)

      Text("FinanceMate")
        .font(.system(size: 36, weight: .bold, design: .rounded))
        .foregroundColor(.primary)

      Text("Secure Financial Management")
        .font(.system(size: 16, weight: .medium))
        .foregroundColor(.secondary)
    }
  }

  private var loginForm: some View {
    VStack(spacing: 24) {
      tabSelection
      emailField
      passwordField
      loginButton
      oauthButtons
      biometricButton
    }
    .padding(32)
    .background(Color(.windowBackgroundColor))
    .clipShape(RoundedRectangle(cornerRadius: 16))
    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
  }

  private var tabSelection: some View {
    HStack(spacing: 0) {
      Button("Sign In") {
        selectedTab = 0
      }
      .frame(maxWidth: .infinity)
      .frame(height: 44)
      .background(selectedTab == 0 ? Color.accentColor : Color.clear)
      .foregroundColor(selectedTab == 0 ? .white : .primary)
      .clipShape(RoundedRectangle(cornerRadius: 8))

      Button("Register") {
        selectedTab = 1
      }
      .frame(maxWidth: .infinity)
      .frame(height: 44)
      .background(selectedTab == 1 ? Color.accentColor : Color.clear)
      .foregroundColor(selectedTab == 1 ? .white : .primary)
      .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    .background(Color.secondary.opacity(0.1))
    .clipShape(RoundedRectangle(cornerRadius: 12))
  }

  private var emailField: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Email")
        .font(.system(size: 14, weight: .medium))
        .foregroundColor(.secondary)

      TextField("Enter your email", text: $email)
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .disableAutocorrection(true)
    }
  }

  private var passwordField: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Password")
        .font(.system(size: 14, weight: .medium))
        .foregroundColor(.secondary)

      SecureField("Enter your password", text: $password)
        .textFieldStyle(RoundedBorderTextFieldStyle())
    }
  }

  private var loginButton: some View {
    Button(action: {
      authenticateUser()
    }) {
      HStack {
        if isLoading {
          ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: .white))
            .scaleEffect(0.8)
        }

        Text(selectedTab == 0 ? "Sign In" : "Register")
          .font(.system(size: 16, weight: .semibold))
      }
      .foregroundColor(.white)
      .frame(maxWidth: .infinity)
      .frame(height: 50)
      .background(Color.accentColor)
      .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    .disabled(isLoading || email.isEmpty || password.isEmpty)
  }

  private var oauthButtons: some View {
    VStack(spacing: 12) {
      Button(action: {
        authenticateWithApple()
      }) {
        HStack {
          Image(systemName: "applelogo")
            .font(.system(size: 20))
          Text("Sign in with Apple")
            .font(.system(size: 16, weight: .semibold))
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .frame(height: 50)
        .background(Color.black)
        .clipShape(RoundedRectangle(cornerRadius: 12))
      }

      Button(action: {
        authenticateWithGoogle()
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
    }
  }

  private var biometricButton: some View {
    Button(action: {
      authenticateWithBiometrics()
    }) {
      HStack {
        Image(systemName: "faceid")
          .font(.system(size: 20))
        Text("Sign in with Face ID")
          .font(.system(size: 16, weight: .semibold))
      }
      .foregroundColor(.accentColor)
      .frame(maxWidth: .infinity)
      .frame(height: 50)
      .background(Color.accentColor.opacity(0.1))
      .clipShape(RoundedRectangle(cornerRadius: 12))
      .overlay(
        RoundedRectangle(cornerRadius: 12)
          .stroke(Color.accentColor.opacity(0.3), lineWidth: 1)
      )
    }
  }

  private var privacyNotice: some View {
    VStack(spacing: 8) {
      Text("By signing in, you agree to our Privacy Policy")
        .font(.system(size: 12))
        .foregroundColor(.secondary)

      Text("FinanceMate v1.0.0 - Secure Financial Management")
        .font(.system(size: 12))
        .foregroundColor(.secondary)
    }
  }

  private var backgroundGradient: some View {
    LinearGradient(
      gradient: Gradient(colors: [
        Color.accentColor.opacity(0.1),
        Color.accentColor.opacity(0.05),
      ]),
      startPoint: .topLeading,
      endPoint: .bottomTrailing
    )
  }

  private func authenticateUser() {
    Task {
      isLoading = true

      do {
        let result = try await authenticationService.authenticateWithEmail(
          email: email,
          password: password
        )

        await MainActor.run {
          isLoading = false

          if result.success {
            isAuthenticated = true
            print("✅ User authenticated successfully: \(email)")
          } else {
            alertMessage = result.error?.localizedDescription ?? "Authentication failed"
            showingLoginAlert = true
            print("❌ Authentication failed for: \(email)")
          }
        }
      } catch {
        await MainActor.run {
          isLoading = false
          alertMessage = error.localizedDescription
          showingLoginAlert = true
          print("❌ Authentication error: \(error.localizedDescription)")
        }
      }
    }
  }

  private func authenticateWithApple() {
    Task {
      isLoading = true

      do {
        let result = try await authenticationService.authenticateWithApple()

        await MainActor.run {
          isLoading = false

          if result.success {
            isAuthenticated = true
            print("✅ Apple Sign-In successful")
          } else {
            alertMessage = result.error?.localizedDescription ?? "Apple Sign-In failed"
            showingLoginAlert = true
            print("❌ Apple Sign-In failed")
          }
        }
      } catch {
        await MainActor.run {
          isLoading = false
          alertMessage = error.localizedDescription
          showingLoginAlert = true
          print("❌ Apple Sign-In error: \(error.localizedDescription)")
        }
      }
    }
  }

  private func authenticateWithGoogle() {
    Task {
      isLoading = true

      do {
        let result = try await authenticationService.authenticateWithGoogle()

        await MainActor.run {
          isLoading = false

          if result.success {
            isAuthenticated = true
            print("✅ Google Sign-In successful")
          } else {
            alertMessage = result.error?.localizedDescription ?? "Google Sign-In failed"
            showingLoginAlert = true
            print("❌ Google Sign-In failed")
          }
        }
      } catch {
        await MainActor.run {
          isLoading = false
          alertMessage = error.localizedDescription
          showingLoginAlert = true
          print("❌ Google Sign-In error: \(error.localizedDescription)")
        }
      }
    }
  }

  private func authenticateWithBiometrics() {
    Task {
      isLoading = true

      do {
        let result = try await authenticationService.authenticateWithBiometrics()

        await MainActor.run {
          isLoading = false

          if result.success {
            isAuthenticated = true
            print("✅ Biometric authentication successful")
          } else {
            alertMessage = result.error?.localizedDescription ?? "Biometric authentication failed"
            showingLoginAlert = true
            print("❌ Biometric authentication failed")
          }
        }
      } catch {
        await MainActor.run {
          isLoading = false
          alertMessage = error.localizedDescription
          showingLoginAlert = true
          print("❌ Biometric authentication error: \(error.localizedDescription)")
        }
      }
    }
  }
}
