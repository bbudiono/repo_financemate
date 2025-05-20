import SwiftUI

@main
struct DocketMateApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 800, minHeight: 600)
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        .commands {
            // Standard application commands group with Quit option (CMD+Q)
            CommandGroup(replacing: .appInfo) {
                Button("About DocketMate") {
                    // About app action
                }
            }
            
            CommandGroup(replacing: .newItem) {
                Button("New Document") {
                    // Handle new document action
                }
                .keyboardShortcut("n", modifiers: .command)
            }
            
            CommandGroup(after: .newItem) {
                Divider()
                Button("Import...") {
                    // Handle import action
                }
                .keyboardShortcut("i", modifiers: [.command])
            }
            
            // Explicitly add the Quit menu item to ensure CMD+Q works
            CommandGroup(replacing: .appTermination) {
                Button("Quit DocketMate") {
                    NSApplication.shared.terminate(nil)
                }
                .keyboardShortcut("q", modifiers: .command)
            }
        }
    }
} 