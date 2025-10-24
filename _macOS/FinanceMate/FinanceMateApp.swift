import SwiftUI

/// FinanceMate - Personal Wealth Management Application
/// BLUEPRINT: Clean MVP with KISS principles (<200 lines/file)
@main
struct FinanceMateApp: App {
    /// Shared Core Data persistence controller
    let persistenceController = PersistenceController.shared

    init() {
        NSLog("🚀 FinanceMateApp.init() STARTING")

        // Load OAuth credentials from .env file (BLUEPRINT Line 33: NO secrets in source code)
        NSLog("📂 Calling DotEnvLoader.load()...")
        DotEnvLoader.load()
        NSLog("✅ DotEnvLoader.load() COMPLETED")

        // CRITICAL: Verify credentials actually loaded (CRASH if not)
        let clientID = DotEnvLoader.get("GOOGLE_OAUTH_CLIENT_ID")
        let clientSecret = DotEnvLoader.get("GOOGLE_OAUTH_CLIENT_SECRET")
        let redirectURI = DotEnvLoader.get("GOOGLE_OAUTH_REDIRECT_URI")

        NSLog("🔍 Verification: CLIENT_ID = \(clientID != nil ? "LOADED" : "NIL")")
        NSLog("🔍 Verification: CLIENT_SECRET = \(clientSecret != nil ? "LOADED" : "NIL")")
        NSLog("🔍 Verification: REDIRECT_URI = \(redirectURI != nil ? "LOADED (\(redirectURI!))" : "NIL")")

        // ASSERT: If credentials not loaded, app WILL CRASH (proves the bug)
        assert(clientID != nil, "FATAL: GOOGLE_OAUTH_CLIENT_ID not loaded from .env")
        assert(clientSecret != nil, "FATAL: GOOGLE_OAUTH_CLIENT_SECRET not loaded from .env")
        assert(redirectURI != nil, "FATAL: GOOGLE_OAUTH_REDIRECT_URI not loaded from .env")

        NSLog("✅ ALL OAUTH CREDENTIALS VERIFIED AND LOADED")

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

        // Persist detection results on first launch (BLUEPRINT Line 161)
        if !ExtractionCapabilityDetector.hasShownCapabilityAlert() {
            ExtractionCapabilityDetector.persistDetectionResults(caps)
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
