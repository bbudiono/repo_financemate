import SwiftUI

/// FinanceMate - Personal Wealth Management Application
/// BLUEPRINT: Clean MVP with KISS principles (<200 lines/file)
@main
struct FinanceMateApp: App {
    /// Shared Core Data persistence controller
    let persistenceController = PersistenceController.shared

    init() {
        // Load .env file for OAuth credentials
        DotEnvLoader.load()

        // Verify OAuth credentials are loaded (for debugging)
        if DotEnvLoader.verifyOAuthCredentials() {
            print(" OAuth credentials loaded successfully")
        } else {
            print("️ OAuth credentials not found - Gmail integration will not work")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
