import SwiftUI

/// FinanceMate - Personal Wealth Management Application
/// BLUEPRINT: Clean MVP with KISS principles (<200 lines/file)
@main
struct FinanceMateApp: App {
    /// Shared Core Data persistence controller
    let persistenceController = PersistenceController.shared

    init() {
        // Load OAuth credentials from .env file (BLUEPRINT Line 33: NO secrets in source code)
        DotEnvLoader.load()

        // Verify credentials loaded from .env (MANDATORY: No hardcoded fallback)
        if !DotEnvLoader.verifyOAuthCredentials() {
            NSLog("⚠️ WARNING: OAuth credentials not found in .env file")
            NSLog("   Please add GOOGLE_OAUTH_CLIENT_ID, GOOGLE_OAUTH_CLIENT_SECRET to _macOS/.env")
            NSLog("   Gmail functionality will be disabled until credentials are configured")
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
