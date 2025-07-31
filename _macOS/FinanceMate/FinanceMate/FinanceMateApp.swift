import CoreData
import SwiftUI

@main
struct FinanceMateApp: App {
  let persistenceController = PersistenceController.shared

  @State private var isAuthenticated = true  // Skip auth for now

  // Check if running in headless mode for testing
  private var isHeadlessMode: Bool {
    ProcessInfo.processInfo.environment["HEADLESS_MODE"] == "1"
      || ProcessInfo.processInfo.environment["UI_TESTING"] == "1"
      || CommandLine.arguments.contains("--headless")
      || CommandLine.arguments.contains("--uitesting")
  }

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environment(\.managedObjectContext, persistenceController.container.viewContext)
        .onAppear {
          if isHeadlessMode {
            // Configure for headless testing
            print("📱 FinanceMate running in headless mode for automated testing")

            // Disable animations and visual effects for faster testing
            #if DEBUG
              UserDefaults.standard.set(true, forKey: "DisableAnimations")
              UserDefaults.standard.set(true, forKey: "HeadlessMode")
            #endif
          }
        }
    }
    .windowStyle(.hiddenTitleBar)
    .windowResizability(isHeadlessMode ? .contentSize : .contentMinSize)
  }
}

// Authentication system temporarily disabled for build stability
// Will be re-enabled after core app is working
