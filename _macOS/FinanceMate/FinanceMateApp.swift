import SwiftUI

/// FinanceMate - Personal Wealth Management Application
/// BLUEPRINT: Clean MVP with KISS principles (<200 lines/file)
@main
struct FinanceMateApp: App {
    /// Shared Core Data persistence controller
    let persistenceController = PersistenceController.shared

    init() {
        // Load .env file for standalone app launches (outside Xcode)
        EnvironmentLoader.loadEnvironmentFile()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
