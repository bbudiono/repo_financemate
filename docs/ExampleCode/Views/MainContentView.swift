import SwiftUI
import Foundation
import Combine

/**
 * MainContentView
 *
 * The main entry point for the EduTrackQLD application.
 * This view manages the primary app layout including navigation,
 * content areas, and global UI elements.
 *
 * Version: 0.5.3 (Build 8)
 */
@available(macOS 13.0, *)
struct MainContentView: View {
    /// The selected navigation item
    @AppStorage("sidebarSelection") private var selection = NavigationItemTag.dashboard
    
    /// Global application state
    @StateObject private var appState = AppState()
    
    /// Tracks whether the app has completed initial loading
    @State private var hasCompletedInitialLoad = false
    
    var body: some View {
        ZStack {
            // Main content structure
            VStack(spacing: 0) {
                NavigationSplitView {
                    SidebarView(selection: $selection)
                        .onChange(of: selection) { newValue in
                            // Log navigation change in app state
                            appState.logEvent(category: "Navigation", action: "Change", label: newValue.rawValue)
                        }
                } detail: {
                    // Display content based on selection
                    contentView(for: selection)
                        .frame(minWidth: 600, minHeight: 400)
                }
                .navigationTitle("EduTrackQLD") // Sets the window title
                
                Spacer(minLength: 0)
                
                // Footer with version information
                HStack {
                    Spacer()
                    Text("Version: 0.5.3 (Build 8)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 4)
                    Spacer()
                }
                .background(Color(.windowBackgroundColor).opacity(0.8))
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color.gray.opacity(0.3)),
                    alignment: .top
                )
            }
        }
        .environmentObject(appState)
        .onAppear {
            // Run initial load operations
            performInitialLoad()
        }
    }
    
    /// Returns the appropriate content view based on the selected navigation item
    @ViewBuilder
    private func contentView(for selection: NavigationItemTag) -> some View {
        switch selection {
        case .dashboard:
            DashboardView()
                .transition(.opacity)
        case .students:
            StudentsView()
                .transition(.opacity)
        case .evidenceLocker:
            EvidenceLockerView()
                .transition(.opacity)
        case .curriculumExplorer:
            CurriculumHubView()
                .transition(.opacity)
        case .reports:
            ReportsView()
                .transition(.opacity)
        case .settings:
            SettingsView()
                .transition(.opacity)
        }
    }
    
    /// Performs initial loading operations when the app starts
    private func performInitialLoad() {
        // Simulate some loading operations
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // Set flag to indicate loading is complete
            hasCompletedInitialLoad = true
            
            // Log successful initialization
            appState.logEvent(category: "App", action: "Initialized")
            
            // Update app state with current version
            appState.logEvent(category: "App", action: "Version", label: "0.5.3 (Build 8)")
        }
    }
}

// MARK: - Placeholder Views

struct EvidenceLockerView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "folder.fill")
                .font(.system(size: 48))
                .foregroundColor(.blue)
            
            Text("Evidence Locker")
                .font(.largeTitle)
            
            Text("Store and organize your evidence files here")
                .font(.title3)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ReportsView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.system(size: 48))
                .foregroundColor(.purple)
            
            Text("Reports")
                .font(.largeTitle)
            
            Text("Generate and view analytical reports")
                .font(.title3)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

@available(macOS 13.0, *)
struct SettingsView: View {
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Settings")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Form {
                Section(header: Text("Application")) {
                    Text("Version: 0.5.3")
                    Text("Build: 8")
                    
                    if let lastLogin = appState.lastLoginDate {
                        Text("Last Login: \(lastLogin, formatter: dateFormatter)")
                    }
                }
                
                Section(header: Text("Appearance")) {
                    Picker("Theme", selection: .constant(0)) {
                        Text("Light").tag(0)
                        Text("Dark").tag(1)
                        Text("System").tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    Toggle("High Contrast Mode", isOn: .constant(false))
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
}

// Dashboard View
@available(macOS 13.0, *)
struct DashboardView: View {
    @EnvironmentObject private var appState: AppState
    @State private var isAnimating = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Welcome header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Welcome to")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    
                    Text("EduTrack Dashboard")
                        .font(.system(size: 32, weight: .bold))
                        .padding(.bottom, 4)
                }
                .padding(.bottom, 20)
                .opacity(isAnimating ? 1 : 0)
                .offset(y: isAnimating ? 0 : 20)
                
                // Feature cards
                HStack(spacing: 20) {
                    FeatureCard(
                        icon: "doc.text.magnifyingglass",
                        title: "Document Scanner",
                        description: "Scan and process student documents"
                    )
                    
                    FeatureCard(
                        icon: "chart.bar.xaxis",
                        title: "Analytics",
                        description: "View key performance metrics"
                    )
                    
                    FeatureCard(
                        icon: "person.text.rectangle",
                        title: "Student Records",
                        description: "Manage student information"
                    )
                }
                .padding()
                .opacity(isAnimating ? 1 : 0)
                .offset(y: isAnimating ? 0 : 20)
                
                // KLA section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Key Learning Areas")
                        .font(.headline)
                    
                    LazyVGrid(columns: [
                        GridItem(.adaptive(minimum: 160, maximum: 200), spacing: 16)
                    ], spacing: 16) {
                        ForEach([
                            ("English", "book.fill"),
                            ("Mathematics", "function"),
                            ("Science", "atom"),
                            ("Humanities", "globe"),
                            ("Arts", "paintpalette.fill"),
                            ("Technologies", "desktopcomputer"),
                            ("Health & PE", "heart.fill")
                        ], id: \.0) { item in
                            VStack(alignment: .leading, spacing: 12) {
                                Image(systemName: item.1)
                                    .font(.system(size: 20))
                                    .foregroundColor(.accentColor)
                                
                                Text(item.0)
                                    .font(.headline)
                            }
                            .padding()
                            .frame(height: 100)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.windowBackgroundColor))
                                    .shadow(color: Color.black.opacity(0.05), radius: 5)
                            )
                        }
                    }
                }
                .padding(.top, 8)
                .opacity(isAnimating ? 1 : 0)
                .offset(y: isAnimating ? 0 : 30)
            }
            .padding(24)
            .frame(maxWidth: .infinity)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.7)) {
                isAnimating = true
            }
        }
    }
}

// Feature Card Component
struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(.accentColor)
            
            Text(title)
                .font(.headline)
            
            Text(description)
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(width: 180, height: 150)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.windowBackgroundColor).opacity(0.5))
                .shadow(radius: 2)
        )
    }
}

struct StudentsView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 48))
                .foregroundColor(.green)
            
            Text("Students")
                .font(.largeTitle)
            
            Text("Manage student profiles and records")
                .font(.title3)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                
            Spacer()
                
            EmptyStateView(
                title: "No Students Yet",
                message: "Add your first student to get started",
                buttonText: "Add Student",
                iconName: "person.badge.plus"
            )
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct EmptyStateView: View {
    let title: String
    let message: String
    let buttonText: String
    let iconName: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: iconName)
                .font(.system(size: 60))
                .foregroundColor(.accentColor.opacity(0.8))
            
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(buttonText) {
                // Action would go here
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.top, 10)
        }
        .padding()
        .frame(maxWidth: 400)
    }
}

struct MainContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainContentView()
            .environmentObject(AppState())
    }
}

// Move CurriculumHubView and related navigation views here from CurriculumHubView.swift
