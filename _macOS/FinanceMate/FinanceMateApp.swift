import SwiftUI

/// FinanceMate - Personal Wealth Management Application
/// BLUEPRINT: Clean MVP with KISS principles (<200 lines/file)
@main
struct FinanceMateApp: App {
    /// Shared Core Data persistence controller
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
