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
                            color: .blue,
                            connectAction: { connectGoogleDrive() }
                        )
                        
                        cloudServiceSection(
                            title: "Dropbox",
                            description: "Backup data to Dropbox",
                            isConnected: $dropboxConnected,
                            icon: "square.and.arrow.down",
                            color: .purple,
                            connectAction: { connectDropbox() }
                        )
                        
                        cloudServiceSection(
                            title: "Microsoft OneDrive",
                            description: "Store documents in OneDrive",
                            isConnected: $oneDriveConnected,
                            icon: "doc.on.doc",
                            color: .orange,
                            connectAction: { connectOneDrive() }
                        )
                        
                        cloudServiceSection(
                            title: "iCloud",
                            description: "Native macOS cloud storage",
                            isConnected: $iCloudEnabled,
                            icon: "icloud.fill",
                            color: .cyan,
                            connectAction: { toggleiCloud() }
                        )
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
            .navigationBarTitleDisplayMode(.inline)
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
        googleDriveConnected.toggle()
        connectionMessage = googleDriveConnected ? "Successfully connected to Google Drive" : "Disconnected from Google Drive"
        showingConnectionStatus = true
    }
    
    private func connectDropbox() {
        dropboxConnected.toggle()
        connectionMessage = dropboxConnected ? "Successfully connected to Dropbox" : "Disconnected from Dropbox"
        showingConnectionStatus = true
    }
    
    private func connectOneDrive() {
        oneDriveConnected.toggle()
        connectionMessage = oneDriveConnected ? "Successfully connected to OneDrive" : "Disconnected from OneDrive"
        showingConnectionStatus = true
    }
    
    private func toggleiCloud() {
        iCloudEnabled.toggle()
        connectionMessage = iCloudEnabled ? "iCloud enabled" : "iCloud disabled"
        showingConnectionStatus = true
    }
    
    private func saveCloudConfiguration() {
        connectionMessage = "Cloud configuration saved successfully"
        showingConnectionStatus = true
    }
}

// MARK: - Supporting Types

enum SyncFrequency: CaseIterable {
    case realTime
    case hourly
    case daily
    case weekly
    
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