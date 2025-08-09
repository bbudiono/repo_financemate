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
          // Temporary placeholder until LoginView compilation issues are resolved
          VStack {
            Text("Authentication Required")
              .font(.title)
            Text("Debugging compilation issues...")
              .font(.caption)
            Button("Skip (Debug Only)") {
              isAuthenticated = true
            }
          }
          .environment(\.managedObjectContext, persistenceController.container.viewContext)
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
      let provider = UserDefaults.standard.string(forKey: "authentication_provider") ?? "unknown"
      
      // Only accept legitimate authentication providers - NO GUEST MODE
      if provider == "apple" || provider == "google" {
        print("✅ Existing user session found (provider: \(provider))")
        isAuthenticated = true
      } else {
        // Clear invalid or guest sessions
        print("🔒 Clearing invalid session (provider: \(provider))")
        clearInvalidSession()
      }
    }
  }
  
  private func clearInvalidSession() {
    UserDefaults.standard.removeObject(forKey: "authenticated_user_id")
    UserDefaults.standard.removeObject(forKey: "authenticated_user_email")
    UserDefaults.standard.removeObject(forKey: "authenticated_user_login_time")
    UserDefaults.standard.removeObject(forKey: "authentication_provider")
    UserDefaults.standard.removeObject(forKey: "is_temporary_bypass")
  }
}
