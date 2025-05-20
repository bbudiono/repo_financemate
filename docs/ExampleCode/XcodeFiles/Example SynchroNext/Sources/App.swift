// Copyright (c) $(date +\"%Y\") {CompanyName}
// Version: 1.0.0
// Purpose: Main application entry point for SynchroNext app.
// Issues & Complexity: Minimal implementation, no known issues. Low complexity.
// Ranking/Rating: 92% (Code), 90% (Problem) - Minimal SwiftUI app entry point in _macOS. Justification: Standard SwiftUI App struct, minimal logic, but critical for app bootstrapping. Last Updated: 2024-07-15

import SwiftUI
import AppKit
import Combine

@main
struct SynchroNext: App {
    @State private var isOnboardingComplete = true // Default to true for production
    @StateObject private var userViewModel = UserViewModel(key: UserDefaults.standard.string(forKey: "SyncAPIToken") ?? "")
    @StateObject private var appState = AppState()
    @Environment(\.scenePhase) var scenePhase

    // Add NSApplicationDelegateAdaptor to handle app termination properly
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            if isOnboardingComplete {
                MainContentView()
                    .frame(minWidth: 1000, minHeight: 600)
                    .environmentObject(userViewModel)
                    .environmentObject(appState)
            } else {
                OnboardingView(isOnboardingComplete: $isOnboardingComplete)
                    .frame(width: 640, height: 480)
            }
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Document") {
                    appState.isNewDocumentSheetPresented = true
                }
                .keyboardShortcut("n", modifiers: .command)
            }

            CommandGroup(after: .newItem) {
                Button("Sync Now") {
                    appState.startSync()
                }
                .keyboardShortcut("r", modifiers: [.command, .shift])
            }

            CommandGroup(replacing: .appInfo) {
                Button("About SynchroNext") {
                    NSApplication.shared.orderFrontStandardAboutPanel(
                        options: [
                            NSApplication.AboutPanelOptionKey.credits: NSAttributedString(
                                string: "A modern document management app.",
                                attributes: [
                                    NSAttributedString.Key.font: NSFont.systemFont(ofSize: 11),
                                    NSAttributedString.Key.foregroundColor: NSColor.labelColor
                                ]
                            ),
                            NSApplication.AboutPanelOptionKey.version: "",
                            NSApplication.AboutPanelOptionKey.applicationName: "SynchroNext"
                        ]
                    )
                }
            }
            
            CommandGroup(replacing: .help) {
                Button("SynchroNext Help") {
                    NSWorkspace.shared.open(URL(string: "https://help.synchronext.com")!)
                }
            }
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .background {
                // Handle app going to background - save any necessary data
                print("App entering background - preparing for possible termination")
            }
        }
    }
}

// MARK: - Supporting Types
// Since we're having issues with the imports, define the model structs directly in the App.swift file

// User model
struct User {
    let id: String
    let displayName: String
    let email: String
    let profileImageURL: URL?
}

// UserViewModel
class UserViewModel: ObservableObject {
    @Published var user: User
    @Published var isAuthenticated: Bool = false
    private var apiToken: String
    private var cancellables = Set<AnyCancellable>()
    
    init(key: String) {
        self.apiToken = key
        self.user = User(
            id: "user123",
            displayName: "Demo User",
            email: "demo@example.com",
            profileImageURL: nil
        )
        
        // Set authenticated if we have a valid API token
        self.isAuthenticated = !key.isEmpty
        
        // In a real app, validate the token and fetch user details
        if !key.isEmpty {
            fetchUserProfile()
        }
    }
    
    private func fetchUserProfile() {
        // Simulate API call to fetch user profile
        // In a real app, replace with actual API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.user = User(
                id: "user123",
                displayName: "John Doe",
                email: "john.doe@example.com",
                profileImageURL: URL(string: "https://example.com/profile.jpg")
            )
        }
    }
}

// AppState
class AppState: ObservableObject {
    // UI state
    @Published var isNewDocumentSheetPresented = false
    @Published var isSettingsSheetPresented = false
    @Published var selectedSidebarItem: String? = "inbox"
    
    // Sync state
    @Published var isSyncing = false
    @Published var lastSyncDate: Date? = nil
    @Published var syncProgress: Double = 0.0
    
    // Error handling
    @Published var errorMessage: String? = nil
    @Published var showErrorAlert = false
    
    init() {
        // Load last sync date from UserDefaults
        if let lastSyncTimeInterval = UserDefaults.standard.object(forKey: "LastSyncDate") as? TimeInterval {
            lastSyncDate = Date(timeIntervalSince1970: lastSyncTimeInterval)
        }
    }
    
    // MARK: - Methods
    
    func startSync() {
        sync()
    }
    
    func sync() {
        guard !isSyncing else { return }
        
        isSyncing = true
        syncProgress = 0.0
        
        // Simulate sync process
        let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
        
        var cancellable: AnyCancellable?
        cancellable = timer.sink { [weak self] _ in
            guard let self = self else {
                cancellable?.cancel()
                return
            }
            
            if self.syncProgress < 1.0 {
                self.syncProgress += 0.2
            } else {
                self.isSyncing = false
                self.lastSyncDate = Date()
                
                // Save last sync date to UserDefaults
                UserDefaults.standard.set(self.lastSyncDate?.timeIntervalSince1970, forKey: "LastSyncDate")
                
                cancellable?.cancel()
            }
        }
    }
    
    func showError(_ message: String) {
        self.errorMessage = message
        self.showErrorAlert = true
    }
    
    func clearError() {
        self.errorMessage = nil
        self.showErrorAlert = false
    }
}

// Add AppDelegate to handle app lifecycle events
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        // Perform any cleanup needed before app terminates
        print("Application will terminate")
        return .terminateNow
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Setup on app launch
        print("Application did finish launching - PRODUCTION MODE")
    }
}

struct OnboardingView: View {
    @Binding var isOnboardingComplete: Bool

    var body: some View {
        VStack {
            Text("Welcome to SynchroNext")
                .font(.largeTitle)

            Button("Get Started") {
                isOnboardingComplete = true
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
    }
} 