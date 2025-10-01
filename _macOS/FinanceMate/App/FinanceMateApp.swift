import SwiftUI

/// FinanceMate - Personal Wealth Management
/// BLUEPRINT COMPLIANCE: Clean MVP implementation with KISS principles
@main
struct FinanceMateApp: App {
    let persistenceController = PersistenceController.shared

    init() {
        print(" FinanceMate starting...")
        loadEnvironmentVariables()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }

    /// Load OAuth credentials from .env file
    private func loadEnvironmentVariables() {
        let envPath = FileManager.default.currentDirectoryPath + "/../.env"

        guard let envContent = try? String(contentsOfFile: envPath) else {
            print("️ .env file not found at: \(envPath)")
            return
        }

        // Parse .env file
        envContent.components(separatedBy: .newlines).forEach { line in
            let parts = line.components(separatedBy: "=")
            if parts.count == 2 {
                let key = parts[0].trimmingCharacters(in: .whitespaces).replacingOccurrences(of: "\"", with: "")
                let value = parts[1].trimmingCharacters(in: .whitespaces).replacingOccurrences(of: "\"", with: "")
                setenv(key, value, 1)
            }
        }

        print(" Environment variables loaded from .env")
    }
}
