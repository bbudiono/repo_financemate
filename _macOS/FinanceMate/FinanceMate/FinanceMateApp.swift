// Purpose: Main application entry point and lifecycle management for FinanceMate.
// Issues & Complexity: Handles app lifecycle and command group customization for proper force-close functionality.
// -- Pre-Coding Assessment --
// Issues & Complexity Summary: Core SwiftUI App implementation with command group customization.
// Key Complexity Drivers (Values/Estimates):
//   - Logic Scope (New/Mod LoC Est.): ~20
//   - Core Algorithm Complexity: Low (standard App lifecycle)
//   - Dependencies (New/Mod Cnt.): 1 (AppKit for NSApplication)
//   - State Management Complexity: Low (minimal app state)
//   - Novelty/Uncertainty Factor: Low (standard SwiftUI App structure)
// AI Pre-Task Self-Assessment (Est. Solution Difficulty for AI %): 15%
// Problem Estimate (Inherent Problem Difficulty %): 20% (Relative to other problems in `root/` folder)
// Initial Code Complexity Estimate (Est. Code Difficulty %): 15% (Relative to other files in `root/`)
// Justification for Estimates: Standard SwiftUI App with minimal customization for proper CMD+Q functionality.
// -- Post-Implementation Update --
// Final Code Complexity (Actual Code Difficulty %): 15%
// Overall Result Score (Success & Quality %): 90%
// Key Variances/Learnings: Command group customization is essential for proper macOS app behavior.
// Last Updated: 2025-05-20

import SwiftUI
import AppKit

@main
struct FinanceMateApp: App {
    
    init() {
        // Populate sample data on app launch
        SampleDataService.shared.populateSampleDataIfNeeded(context: CoreDataStack.shared.mainContext)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, CoreDataStack.shared.mainContext)
                .frame(minWidth: 800, minHeight: 600)
        }
        .commands {
            // Ensure CMD+Q works properly by replacing the default app termination command
            CommandGroup(replacing: .appTermination) {
                Button("Quit FinanceMate") {
                    NSApplication.shared.terminate(nil)
                }
                .keyboardShortcut("q", modifiers: .command)
            }
        }
    }
}
