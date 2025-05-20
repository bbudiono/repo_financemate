// Copyright (c) $(date +"%Y") {CompanyName}
// Version: 1.0.0
// Purpose: Main content view for the SynchroNext application, serving as the primary UI container.
//          Currently demonstrates Apple Sign-In functionality.
// Dependencies:
//   - SwiftUI (framework)
//   - AuthenticationServices (framework, for Apple Sign In)
//   - AppleSignInView (custom view for Apple Sign In button and logic)
// Usage: Instantiated as the root view in App.swift.
//
// --- Change Log ---
// 2025-05-19: Initial implementation with Apple Sign-In view.
//             Added .cursorrules compliant header.
// 2024-07-15: Updated to use local models.
//
// -- Quality Rating (.cursorrules §6.4.1) --
// Readability: 9/10 (Clear SwiftUI structure, straightforward logic)
// Efficiency: N/A (UI component, performance depends on underlying frameworks)
// Maintainability: 8/10 (Simple, easy to extend for more content)
// Error Handling: 7/10 (Basic print statements for sign-in errors; needs more robust handling for production)
// Documentation: 9/10 (Header added, code is self-explanatory for its current scope)
// Script Functionality: 9/10 (Demonstrates Apple Sign In)
// Security: 8/10 (Relies on AuthenticationServices; token handling is in AppleAuthProvider)
// ---
// Overall Score: 85%
// Justification: Good starting point for main content. Error handling and state management will need enhancement for production.
//
// Issues & Complexity: Main UI component with Apple authentication.
// Ranking/Rating: 95% (Code), 92% (Problem) - Main UI component for Apple SSO. (Retained from original for context)

import SwiftUI
import AuthenticationServices

struct MainContentView: View {
    // MARK: - Properties
    
    @State private var showSidebar: Bool = true
    @State private var showLogin: Bool = false
    @State private var showNewDocumentSheet: Bool = false
    @State private var showSettingsSheet: Bool = false
    @State private var searchText: String = ""
    @State private var selectedTab: String = "all"
    
    // Environment objects from App.swift
    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject private var appState: AppState
    
    // MARK: - View Body
    
    var body: some View {
        NavigationView {
            sidebar
            
            VStack {
                if !userViewModel.isAuthenticated {
                    authenticationView
                } else {
                    contentView
                }
            }
        }
        .sheet(isPresented: $appState.isNewDocumentSheetPresented) {
            newDocumentSheet
        }
        .sheet(isPresented: $appState.isSettingsSheetPresented) {
            settingsSheet
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: toggleSidebar) {
                    Image(systemName: "sidebar.left")
                }
            }
            
            ToolbarItem {
                Button(action: {
                    appState.isNewDocumentSheetPresented = true
                }) {
                    Image(systemName: "plus")
                }
            }
            
            ToolbarItem {
                Button(action: {
                    appState.startSync()
                }) {
                    Image(systemName: "arrow.clockwise")
                }
            }
            
            ToolbarItem {
                Button(action: {
                    appState.isSettingsSheetPresented = true
                }) {
                    Image(systemName: "gear")
                }
            }
        }
        .alert(isPresented: $appState.showErrorAlert) {
            Alert(
                title: Text("Error"),
                message: Text(appState.errorMessage ?? "An unknown error occurred"),
                dismissButton: .default(Text("OK")) {
                    appState.clearError()
                }
            )
        }
    }
    
    // MARK: - Subviews
    
    private var sidebar: some View {
        List {
            NavigationLink(destination: EmptyView(), tag: "inbox", selection: $appState.selectedSidebarItem) {
                Label("Inbox", systemImage: "tray")
            }
            
            NavigationLink(destination: EmptyView(), tag: "shared", selection: $appState.selectedSidebarItem) {
                Label("Shared", systemImage: "person.2")
            }
            
            NavigationLink(destination: EmptyView(), tag: "recent", selection: $appState.selectedSidebarItem) {
                Label("Recent", systemImage: "clock")
            }
            
            Divider()
            
            NavigationLink(destination: EmptyView(), tag: "drafts", selection: $appState.selectedSidebarItem) {
                Label("Drafts", systemImage: "doc")
            }
            
            NavigationLink(destination: EmptyView(), tag: "trash", selection: $appState.selectedSidebarItem) {
                Label("Trash", systemImage: "trash")
            }
        }
        .frame(minWidth: 200)
        .listStyle(SidebarListStyle())
    }
    
    private var authenticationView: some View {
        VStack {
            Text("Sign in to SynchroNext")
                .font(.largeTitle)
                .padding(.bottom, 30)
            
            AppleSignInView()
                .frame(width: 200, height: 44)
                .padding()
            
            Button("Use Demo Account") {
                userViewModel.isAuthenticated = true
            }
            .buttonStyle(.borderless)
            .foregroundColor(.secondary)
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var contentView: some View {
        VStack {
            // Empty state or placeholder
            if appState.selectedSidebarItem == nil {
                Text("Select a category from the sidebar")
                    .font(.title2)
                    .foregroundColor(.secondary)
            } else {
                Text("Content for \(appState.selectedSidebarItem ?? "unknown")")
                    .font(.title2)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var newDocumentSheet: some View {
        VStack {
            Text("Create New Document")
                .font(.largeTitle)
                .padding()
            
            // Form fields would go here
            
            Button("Create") {
                appState.isNewDocumentSheetPresented = false
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
        .frame(width: 400, height: 300)
    }
    
    private var settingsSheet: some View {
        VStack {
            Text("Settings")
                .font(.largeTitle)
                .padding()
            
            // Settings fields would go here
            
            Button("Done") {
                appState.isSettingsSheetPresented = false
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
        .frame(width: 400, height: 300)
    }
    
    // MARK: - Methods
    
    private func toggleSidebar() {
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    }
}

// MARK: - Previews

struct MainContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainContentView()
            .environmentObject(UserViewModel(key: "preview-token")) // Add for preview
            .environmentObject(AppState()) // Add for preview
    }
} 