//
//  CloudConfigurationView.swift
//  FinanceMate
//
//  Created by Assistant on 6/10/25.
//

import SwiftUI

struct CloudConfigurationView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var googleDriveConnected = false
    @State private var dropboxConnected = false
    @State private var oneDriveConnected = false
    @State private var iCloudEnabled = true
    @State private var autoSyncEnabled = false
    @State private var syncFrequency: SyncFrequency = .hourly

    @State private var showingConnectionStatus = false
    @State private var connectionMessage = ""

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "cloud.fill")
                                .font(.title2)
                                .foregroundColor(.blue)

                            Text("Cloud Services")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                        }

                        Text("Connect and configure cloud storage services")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)

                    // Cloud Service Connections
                    VStack(spacing: 16) {
                        cloudServiceSection(
                            title: "Google Drive",
                            description: "Sync financial documents to Google Drive",
                            isConnected: $googleDriveConnected,
                            icon: "globe",
                            color: .blue
                        ) { connectGoogleDrive() }

                        cloudServiceSection(
                            title: "Dropbox",
                            description: "Backup data to Dropbox",
                            isConnected: $dropboxConnected,
                            icon: "square.and.arrow.down",
                            color: .purple
                        ) { connectDropbox() }

                        cloudServiceSection(
                            title: "Microsoft OneDrive",
                            description: "Store documents in OneDrive",
                            isConnected: $oneDriveConnected,
                            icon: "doc.on.doc",
                            color: .orange
                        ) { connectOneDrive() }

                        cloudServiceSection(
                            title: "iCloud",
                            description: "Native macOS cloud storage",
                            isConnected: $iCloudEnabled,
                            icon: "icloud.fill",
                            color: .cyan
                        ) { toggleiCloud() }
                    }
                    .padding(.horizontal)

                    // Sync Settings
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Sync Settings")
                            .font(.headline)
                            .fontWeight(.semibold)

                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .foregroundColor(.green)
                                    .font(.title3)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Auto Sync")
                                        .font(.body)
                                        .fontWeight(.medium)

                                    Text("Automatically sync data across all connected services")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                Toggle("", isOn: $autoSyncEnabled)
                                    .toggleStyle(SwitchToggleStyle())
                            }

                            if autoSyncEnabled {
                                HStack {
                                    Image(systemName: "clock")
                                        .foregroundColor(.blue)
                                        .font(.title3)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Sync Frequency")
                                            .font(.body)
                                            .fontWeight(.medium)

                                        Text("How often to sync data")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }

                                    Spacer()

                                    Picker("Frequency", selection: $syncFrequency) {
                                        ForEach(SyncFrequency.allCases, id: \.self) { frequency in
                                            Text(frequency.displayName).tag(frequency)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .frame(width: 100)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.controlBackgroundColor))
                    .cornerRadius(12)
                    .padding(.horizontal)

                    // Storage Usage (placeholder)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Storage Usage")
                            .font(.headline)
                            .fontWeight(.semibold)

                        VStack(spacing: 8) {
                            storageUsageRow("Documents", "2.3 GB", 0.6)
                            storageUsageRow("Financial Data", "145 MB", 0.3)
                            storageUsageRow("Analytics", "89 MB", 0.2)
                        }
                    }
                    .padding()
                    .background(Color(.controlBackgroundColor))
                    .cornerRadius(12)
                    .padding(.horizontal)

                    // Action Buttons
                    HStack(spacing: 16) {
                        Button("Cancel") {
                            dismiss()
                        }
                        .buttonStyle(.bordered)

                        Button("Save Settings") {
                            saveCloudConfiguration()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                }
            }
            .navigationTitle("Cloud Services")
            // macOS doesn't support navigationBarTitleDisplayMode
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .alert("Connection Status", isPresented: $showingConnectionStatus) {
            Button("OK") { }
        } message: {
            Text(connectionMessage)
        }
        .onAppear {
            loadSavedPreferences()
        }
    }

    private func cloudServiceSection(
        title: String,
        description: String,
        isConnected: Binding<Bool>,
        icon: String,
        color: Color,
        connectAction: @escaping () -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.medium)

                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                HStack(spacing: 8) {
                    if isConnected.wrappedValue {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)

                        Text("Connected")
                            .font(.caption)
                            .foregroundColor(.green)
                            .fontWeight(.medium)
                    }

                    Button(isConnected.wrappedValue ? "Disconnect" : "Connect") {
                        connectAction()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }
        }
        .padding()
        .background(Color(.controlBackgroundColor))
        .cornerRadius(12)
    }

    private func storageUsageRow(_ category: String, _ size: String, _ percentage: Double) -> some View {
        HStack {
            Text(category)
                .font(.body)
                .fontWeight(.medium)

            Spacer()

            Text(size)
                .font(.caption)
                .foregroundColor(.secondary)

            ProgressView(value: percentage)
                .frame(width: 60)
        }
    }

    private func connectGoogleDrive() {
        if googleDriveConnected {
            // Disconnect
            googleDriveConnected = false
            connectionMessage = "⚠️ Google Drive disconnected. Note: This is a demo connection only."
        } else {
            // Connect - in real implementation this would trigger OAuth flow
            connectionMessage = "🚧 Google Drive OAuth integration not yet implemented. This is a demo toggle only.\n\nTo enable real Google Drive sync:\n• Set up Google Drive API credentials\n• Implement OAuth 2.0 flow\n• Add secure token storage"
            // Don't actually toggle connected status for external services
            // googleDriveConnected = true
        }
        showingConnectionStatus = true
    }

    private func connectDropbox() {
        if dropboxConnected {
            // Disconnect
            dropboxConnected = false
            connectionMessage = "⚠️ Dropbox disconnected. Note: This is a demo connection only."
        } else {
            // Connect - in real implementation this would trigger OAuth flow
            connectionMessage = "🚧 Dropbox OAuth integration not yet implemented. This is a demo toggle only.\n\nTo enable real Dropbox sync:\n• Set up Dropbox API app\n• Implement OAuth 2.0 flow\n• Add file upload/download logic"
            // Don't actually toggle connected status for external services
            // dropboxConnected = true
        }
        showingConnectionStatus = true
    }

    private func connectOneDrive() {
        if oneDriveConnected {
            // Disconnect
            oneDriveConnected = false
            connectionMessage = "⚠️ OneDrive disconnected. Note: This is a demo connection only."
        } else {
            // Connect - in real implementation this would trigger OAuth flow
            connectionMessage = "🚧 OneDrive OAuth integration not yet implemented. This is a demo toggle only.\n\nTo enable real OneDrive sync:\n• Set up Microsoft Graph API\n• Implement OAuth 2.0 flow\n• Add Microsoft Graph SDK"
            // Don't actually toggle connected status for external services
            // oneDriveConnected = true
        }
        showingConnectionStatus = true
    }

    private func toggleiCloud() {
        // iCloud is the only one that can actually work with native macOS APIs
        iCloudEnabled.toggle()
        if iCloudEnabled {
            connectionMessage = "✅ iCloud enabled successfully. Documents will sync via CloudKit when API is implemented."
        } else {
            connectionMessage = "⚠️ iCloud disabled. Local storage only."
        }
        showingConnectionStatus = true
    }

    private func loadSavedPreferences() {
        googleDriveConnected = UserDefaults.standard.bool(forKey: "googleDriveConnected")
        dropboxConnected = UserDefaults.standard.bool(forKey: "dropboxConnected")
        oneDriveConnected = UserDefaults.standard.bool(forKey: "oneDriveConnected")
        iCloudEnabled = UserDefaults.standard.bool(forKey: "iCloudEnabled")
        autoSyncEnabled = UserDefaults.standard.bool(forKey: "autoSyncEnabled")

        if let savedFrequency = UserDefaults.standard.object(forKey: "syncFrequency") as? String,
           let frequency = SyncFrequency(rawValue: savedFrequency) {
            syncFrequency = frequency
        }
    }

    private func saveCloudConfiguration() {
        // Save the current settings to UserDefaults
        UserDefaults.standard.set(googleDriveConnected, forKey: "googleDriveConnected")
        UserDefaults.standard.set(dropboxConnected, forKey: "dropboxConnected")
        UserDefaults.standard.set(oneDriveConnected, forKey: "oneDriveConnected")
        UserDefaults.standard.set(iCloudEnabled, forKey: "iCloudEnabled")
        UserDefaults.standard.set(autoSyncEnabled, forKey: "autoSyncEnabled")
        UserDefaults.standard.set(syncFrequency.rawValue, forKey: "syncFrequency")

        connectionMessage = "✅ Cloud configuration saved to preferences.\n\nNote: Real cloud sync requires OAuth implementation for external services."
        showingConnectionStatus = true
    }
}

// MARK: - Supporting Types

enum SyncFrequency: String, CaseIterable {
    case realTime = "realTime"
    case hourly = "hourly"
    case daily = "daily"
    case weekly = "weekly"

    var displayName: String {
        switch self {
        case .realTime: return "Real Time"
        case .hourly: return "Hourly"
        case .daily: return "Daily"
        case .weekly: return "Weekly"
        }
    }
}

struct CloudConfigurationView_Previews: PreviewProvider {
    static var previews: some View {
        CloudConfigurationView()
    }
}
