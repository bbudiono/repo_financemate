// Purpose: Main application entry point for SynchroNext sandbox app.
// Issues & Complexity: Minimal implementation, no known issues. Low complexity.
// Ranking/Rating: 10% (Code), 5% (Problem) - Minimal SwiftUI app entry point in _macOS.
// SANDBOX VERSION: This is a sandbox version of the SynchroNext app.

import SwiftUI

@main
struct SynchroNextSandboxApp: App {
    var body: some Scene {
        WindowGroup {
            MainContentViewSandbox()
                .frame(minWidth: 800, minHeight: 600)
                .onAppear {
                    // Set window properties
                    NSWindow.allowsAutomaticWindowTabbing = false
                    
                    for window in NSApplication.shared.windows {
                        window.title = "SynchroNext SANDBOX"
                        window.titlebarAppearsTransparent = true
                        window.titleVisibility = .hidden
                        window.styleMask.insert(.fullSizeContentView)
                        
                        // Center the window on the screen
                        window.center()
                        
                        // Set minimum size
                        window.minSize = NSSize(width: 800, height: 600)
                    }
                }
        }
        .windowStyle(.hiddenTitleBar)
    }
} 