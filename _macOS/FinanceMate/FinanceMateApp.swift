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

        // TEMPORARY: Hardcode credentials as fallback for testing
        // TODO: Remove this once we fix the .env file loading
        DotEnvLoader.setCredentials([
            "GOOGLE_OAUTH_CLIENT_ID": "REDACTED_CLIENT_ID",
            "GOOGLE_OAUTH_CLIENT_SECRET": "REDACTED_CLIENT_SECRET",
            "GOOGLE_OAUTH_REDIRECT_URI": "http://localhost:8080/callback"
        ])

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
