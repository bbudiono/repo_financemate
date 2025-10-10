import SwiftUI

/// FinanceMate - Personal Wealth Management Application
/// BLUEPRINT: Clean MVP with KISS principles (<200 lines/file)
@main
struct FinanceMateApp: App {
    /// Shared Core Data persistence controller
    let persistenceController = PersistenceController.shared

    init() {
        // Load OAuth credentials
        DotEnvLoader.load()

        if !DotEnvLoader.verifyOAuthCredentials() {
            DotEnvLoader.setCredentials([
                "GOOGLE_OAUTH_CLIENT_ID": "REDACTED_CLIENT_ID",
                "GOOGLE_OAUTH_CLIENT_SECRET": "REDACTED_CLIENT_SECRET",
                "GOOGLE_OAUTH_REDIRECT_URI": "http://localhost:8080/callback"
            ])
        }

        // Detect extraction capabilities (BLUEPRINT Section 3.1.1.4)
        detectExtractionCapabilities()
    }

    private func detectExtractionCapabilities() {
        let caps = ExtractionCapabilityDetector.detect()

        NSLog("=== EXTRACTION CAPABILITIES ===")
        NSLog("macOS: \(caps.macOSVersion)")
        NSLog("Chip: \(caps.chipType)")
        NSLog("Apple Intelligence: \(caps.appleIntelligenceEnabled ? "Enabled" : "Disabled")")
        NSLog("Foundation Models: \(caps.foundationModelsAvailable ? "Available" : "Unavailable")")
        NSLog("Strategy: \(caps.strategy.rawValue)")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
