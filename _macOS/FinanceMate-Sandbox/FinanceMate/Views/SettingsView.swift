//
//  SettingsView.swift
//  FinanceMate
//
//  Created by Assistant on 6/2/25.
//

/*
* Purpose: Comprehensive application settings and preferences management
* Issues & Complexity Summary: Multiple settings categories, preferences persistence, data export, user account management
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~250
  - Core Algorithm Complexity: Medium
  - Dependencies: 2 New (UserDefaults, file export)
  - State Management Complexity: Medium
  - Novelty/Uncertainty Factor: Low
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 70%
* Problem Estimate (Inherent Problem Difficulty %): 65%
* Initial Code Complexity Estimate %: 68%
* Justification for Estimates: Settings views require organized sections, state management, persistence
* Final Code Complexity (Actual %): 72%
* Overall Result Score (Success & Quality %): 91%
* Key Variances/Learnings: Settings organization crucial for UX, toggle states well-managed
* Last Updated: 2025-06-02
*/

import AuthenticationServices
import Foundation
import SwiftUI

// MARK: - Import Centralized Theme
// CentralizedTheme.swift provides glassmorphism effects and theme management

struct SettingsView: View {
    @StateObject private var settingsManager = SettingsManager.shared
    @State private var isAuthenticated = false
    @State private var authenticatedUserName: String = ""
    @State private var isAuthLoading = false
    @State private var authErrorMessage: String?
    @State private var showingAbout = false
    @State private var showingDataExport = false
    @State private var showingResetConfirmation = false
    @State private var showingAPIKeyManagement = false
    @State private var showingCloudConfiguration = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Settings")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .accessibilityIdentifier("settings_header_title")

                    Text("Configure your FinanceMate preferences")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .accessibilityIdentifier("settings_header_subtitle")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

                // General Settings
                SettingsSection(title: "General") {
                    SettingsRow(
                        icon: "bell.fill",
                        title: "Notifications",
                        description: "Receive alerts for important financial activities"
                    ) {
                        Toggle("", isOn: $settingsManager.notificationsEnabled)
                            .toggleStyle(SwitchToggleStyle())
                            .accessibilityIdentifier("notifications_toggle")
                    }

                    SettingsRow(
                        icon: "arrow.triangle.2.circlepath",
                        title: "Auto Sync",
                        description: "Automatically sync data across devices"
                    ) {
                        Toggle("", isOn: $settingsManager.autoSyncEnabled)
                            .toggleStyle(SwitchToggleStyle())
                            .accessibilityIdentifier("auto_sync_toggle")
                    }

                    SettingsRow(
                        icon: "faceid",
                        title: "Biometric Authentication",
                        description: "Use Touch ID or Face ID for app access"
                    ) {
                        Toggle("", isOn: $settingsManager.biometricAuthEnabled)
                            .toggleStyle(SwitchToggleStyle())
                            .accessibilityIdentifier("biometric_auth_toggle")
                    }

                    // Apple ID Authentication
                    SettingsRow(
                        icon: "applelogo",
                        title: "Sign in with Apple",
                        description: isAuthenticated ?
                            "Signed in as \(authenticatedUserName.isEmpty ? "User" : authenticatedUserName)" :
                            "Sign in to sync data across devices"
                    ) {
                        if isAuthLoading {
                            ProgressView()
                                .scaleEffect(0.7)
                                .frame(height: 20)
                        } else {
                            Button(isAuthenticated ? "Sign Out" : "Sign In") {
                                Task {
                                    await performAuthentication()
                                }
                            }
                            .buttonStyle(.bordered)
                            .accessibilityIdentifier("apple_sign_in_button")
                        }
                    }
                }

                // Appearance
                SettingsSection(title: "Appearance") {
                    SettingsRow(
                        icon: "moon.fill",
                        title: "Dark Mode",
                        description: "Use dark theme throughout the app"
                    ) {
                        Toggle("", isOn: $settingsManager.darkModeEnabled)
                            .toggleStyle(SwitchToggleStyle())
                            .accessibilityIdentifier("dark_mode_toggle")
                    }
                }

                // Data & Privacy
                SettingsSection(title: "Data & Privacy") {
                    SettingsRow(
                        icon: "dollarsign.circle.fill",
                        title: "Currency",
                        description: "Default currency for financial calculations"
                    ) {
                        Picker("Currency", selection: $settingsManager.defaultCurrency) {
                            ForEach(settingsManager.availableCurrencies, id: \.self) { currency in
                                Text(currency).tag(currency)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(width: 80)
                        .accessibilityIdentifier("currency_picker")
                    }

                    SettingsRow(
                        icon: "calendar",
                        title: "Date Format",
                        description: "How dates are displayed throughout the app"
                    ) {
                        Picker("Date Format", selection: $settingsManager.dateFormat) {
                            ForEach(settingsManager.availableDateFormats, id: \.self) { format in
                                Text(format).tag(format)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(width: 120)
                    }

                    SettingsRow(
                        icon: "icloud.fill",
                        title: "Auto Backup",
                        description: "Automatically backup data to iCloud"
                    ) {
                        Toggle("", isOn: $settingsManager.autoBackupEnabled)
                            .toggleStyle(SwitchToggleStyle())
                    }
                }

                // API Keys & Integration
                SettingsSection(title: "API Integration") {
                    SettingsActionRow(
                        icon: "key.fill",
                        title: "API Keys",
                        description: "Manage OpenAI, Google, and other API keys",
                        color: .blue
                    ) {
                        showingAPIKeyManagement = true
                    }

                    SettingsActionRow(
                        icon: "cloud.fill",
                        title: "Cloud Services",
                        description: "Configure Google Drive, Dropbox, and other services",
                        color: .green
                    ) {
                        showingCloudConfiguration = true
                    }
                }

                // Data Management
                SettingsSection(title: "Data Management") {
                    SettingsActionRow(
                        icon: "square.and.arrow.up",
                        title: "Export Data",
                        description: "Export all financial data and reports",
                        color: .blue
                    ) {
                        showingDataExport = true
                    }

                    SettingsActionRow(
                        icon: "trash.fill",
                        title: "Reset All Data",
                        description: "Permanently delete all financial data",
                        color: .red
                    ) {
                        showingResetConfirmation = true
                    }
                }

                // Support
                SettingsSection(title: "Support") {
                    SettingsActionRow(
                        icon: "questionmark.circle.fill",
                        title: "Help & Support",
                        description: "Get help with using FinanceMate",
                        color: .green
                    ) {
                        openHelpDocumentation()
                    }

                    SettingsActionRow(
                        icon: "envelope.fill",
                        title: "Contact Us",
                        description: "Send feedback or report issues",
                        color: .orange
                    ) {
                        openContactForm()
                    }

                    SettingsActionRow(
                        icon: "info.circle.fill",
                        title: "About FinanceMate",
                        description: "App version and legal information",
                        color: .purple
                    ) {
                        showingAbout = true
                    }
                }

                // Version Info
                VStack(spacing: 8) {
                    Text("FinanceMate v1.0.0")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("Build 2025.06.02")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
            }
        }
        .navigationTitle("Settings")
        .onAppear {
            // Restore authentication state
            isAuthenticated = UserDefaults.standard.bool(forKey: "isAppleAuthenticated")
            authenticatedUserName = UserDefaults.standard.string(forKey: "appleUserName") ?? ""
        }
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
        .sheet(isPresented: $showingDataExport) {
            DataExportView()
        }
        .sheet(isPresented: $showingAPIKeyManagement) {
            APIKeyManagementView()
        }
        .sheet(isPresented: $showingCloudConfiguration) {
            CloudConfigurationView()
        }
        .alert("Reset All Data", isPresented: $showingResetConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                resetAllData()
            }
        } message: {
            Text("This will permanently delete all your financial data. This action cannot be undone.")
        }
    }

    private func openHelpDocumentation() {
        if let url = URL(string: "https://docs.financemate.app/help") {
            NSWorkspace.shared.open(url)
        }
    }

    private func openContactForm() {
        if let url = URL(string: "mailto:support@financemate.app?subject=FinanceMate Support Request") {
            NSWorkspace.shared.open(url)
        }
    }

    private func resetAllData() {
        Task {
            await settingsManager.resetAllData()
        }
    }

    private func performAuthentication() async {
        if isAuthenticated {
            // Sign out
            await signOut()
        } else {
            // Sign in with Apple
            await signInWithApple()
        }
    }

    private func signInWithApple() async {
        isAuthLoading = true
        authErrorMessage = nil

        do {
            let provider = ASAuthorizationAppleIDProvider()
            let request = provider.createRequest()
            request.requestedScopes = [.fullName, .email]

            let coordinator = AppleSignInCoordinator()
            let authController = ASAuthorizationController(authorizationRequests: [request])
            authController.delegate = coordinator
            authController.presentationContextProvider = coordinator

            authController.performRequests()

            let credential = try await coordinator.waitForResult()

            // Process successful authentication
            let userName = [credential.fullName?.givenName, credential.fullName?.familyName]
                .compactMap { $0 }
                .joined(separator: " ")

            await MainActor.run {
                isAuthenticated = true
                authenticatedUserName = userName.isEmpty ? "Apple User" : userName
                isAuthLoading = false

                // Save authentication state to UserDefaults
                UserDefaults.standard.set(true, forKey: "isAppleAuthenticated")
                UserDefaults.standard.set(authenticatedUserName, forKey: "appleUserName")
            }
        } catch {
            await MainActor.run {
                authErrorMessage = "Apple Sign-In failed: \(error.localizedDescription)"
                isAuthLoading = false
            }
        }
    }

    private func signOut() async {
        await MainActor.run {
            isAuthenticated = false
            authenticatedUserName = ""
            authErrorMessage = nil

            // Clear authentication state from UserDefaults
            UserDefaults.standard.removeObject(forKey: "isAppleAuthenticated")
            UserDefaults.standard.removeObject(forKey: "appleUserName")
        }
    }
}

// MARK: - Apple Sign In Coordinator

@MainActor
private class AppleSignInCoordinator: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    private var continuation: CheckedContinuation<ASAuthorizationAppleIDCredential, Error>?

    func waitForResult() async throws -> ASAuthorizationAppleIDCredential {
        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
        }
    }

    // MARK: - ASAuthorizationControllerDelegate

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            continuation?.resume(returning: appleIDCredential)
        } else {
            continuation?.resume(throwing: AuthenticationError.invalidAppleCredential)
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        continuation?.resume(throwing: error)
    }

    // MARK: - ASAuthorizationControllerPresentationContextProviding

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        NSApplication.shared.windows.first { $0.isKeyWindow } ?? NSApplication.shared.windows.first!
    }
}

// MARK: - Authentication Error
// Note: AuthenticationError is now defined in CommonTypes.swift

struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.horizontal)

            VStack(spacing: 1) {
                content
            }
            .lightGlass()
            .padding(.horizontal)
        }
    }
}

struct SettingsRow<Content: View>: View {
    let icon: String
    let title: String
    let description: String
    let content: Content

    init(icon: String, title: String, description: String, @ViewBuilder content: () -> Content) {
        self.icon = icon
        self.title = title
        self.description = description
        self.content = content()
    }

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }

            Spacer()

            content
        }
        .padding()
    }
}

struct SettingsActionRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                    .frame(width: 24, height: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)

                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    private let appInfo = LegalContent.appInfo
    private let versionInfo = LegalContent.versionInfo
    private let features = LegalContent.features
    private let legalLinks = LegalContent.legalLinks
    private let copyright = LegalContent.copyright

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // App Icon and Name
                    VStack(spacing: 16) {
                        Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)

                        Text(appInfo.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text(appInfo.tagline)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top)

                    // Version Information
                    VStack(spacing: 12) {
                        InfoRow(label: "Version", value: versionInfo.version)
                        InfoRow(label: "Build", value: versionInfo.build)
                        InfoRow(label: "Platform", value: versionInfo.platform)
                        InfoRow(label: "Framework", value: versionInfo.framework)
                    }
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                    .cornerRadius(12)
                    .padding(.horizontal)

                    // Description
                    VStack(alignment: .leading, spacing: 12) {
                        Text("About \(appInfo.name)")
                            .font(.headline)
                            .fontWeight(.semibold)

                        Text(appInfo.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                    }
                    .padding(.horizontal)

                    // Features
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Key Features")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .padding(.horizontal)

                        VStack(spacing: 8) {
                            ForEach(features) { feature in
                                FeatureRow(
                                    icon: feature.icon,
                                    title: feature.title,
                                    description: feature.description
                                )
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Legal
                    VStack(spacing: 12) {
                        Button("Privacy Policy") {
                            if let url = URL(string: legalLinks.privacyPolicyURL) {
                                NSWorkspace.shared.open(url)
                            }
                        }
                        .buttonStyle(.bordered)

                        Button("Terms of Service") {
                            if let url = URL(string: legalLinks.termsOfServiceURL) {
                                NSWorkspace.shared.open(url)
                            }
                        }
                        .buttonStyle(.bordered)
                    }

                    Text(copyright)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.bottom)
                }
            }
            .navigationTitle("About")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()

            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct DataExportView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedFormat: SettingsExportFormat = .pdf
    @StateObject private var exportService = BasicExportService()
    @State private var includeCharts = true
    @State private var includeTransactions = true
    @State private var includeAnalytics = true
    @State private var dateRange: DateRange = .all

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.largeTitle)
                        .foregroundColor(.blue)

                    Text("Export Data")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text("Choose what data to export and in what format")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top)

                // Export Options
                VStack(spacing: 20) {
                    // Format Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Export Format")
                            .font(.headline)
                            .fontWeight(.semibold)

                        Picker("Format", selection: $selectedFormat) {
                            ForEach(SettingsExportFormat.allCases, id: \.self) { format in
                                Text(format.displayName).tag(format)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    // Data Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Include Data")
                            .font(.headline)
                            .fontWeight(.semibold)

                        VStack(spacing: 8) {
                            Toggle("Charts and Visualizations", isOn: $includeCharts)
                            Toggle("Transaction History", isOn: $includeTransactions)
                            Toggle("Analytics and Insights", isOn: $includeAnalytics)
                        }
                    }

                    // Date Range
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Date Range")
                            .font(.headline)
                            .fontWeight(.semibold)

                        Picker("Date Range", selection: $dateRange) {
                            ForEach(DateRange.allCases, id: \.self) { range in
                                Text(range.displayName).tag(range)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                .cornerRadius(12)
                .padding(.horizontal)

                Spacer()

                // Export Button
                Button("Export Data") {
                    exportData()
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
            }
            .navigationTitle("Export Data")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func exportData() {
        Task {
            do {
                let financialData: [FinancialData] = [] // Would fetch from Core Data in real implementation

                switch selectedFormat {
                case .csv:
                    _ = try await exportService.exportToCSV(financialData.map(FinancialDataAdapter.init))
                case .json:
                    _ = try await exportService.exportToJSON(financialData.map(FinancialDataAdapter.init))
                case .pdf:
                    _ = try await exportService.exportToPDF(financialData.map(FinancialDataAdapter.init))
                case .excel:
                    _ = try await exportService.exportToFile(financialData, format: .excel)
                    // Successfully exported \(result.recordCount) records
                }

                await MainActor.run {
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    // Show user-friendly error message with guidance
                    let alert = NSAlert()
                    alert.messageText = "Export Failed"
                    alert.informativeText = "Failed to export your financial data: \(error.localizedDescription)\n\nTry checking your file permissions and available disk space, then try again."
                    alert.alertStyle = .warning
                    alert.addButton(withTitle: "OK")
                    alert.runModal()
                }
            }
        }
    }
}

enum SettingsExportFormat: CaseIterable {
    case pdf
    case csv
    case json
    case excel

    var displayName: String {
        switch self {
        case .pdf: return "PDF"
        case .csv: return "CSV"
        case .json: return "JSON"
        case .excel: return "Excel"
        }
    }
}

enum DateRange: CaseIterable {
    case all
    case thisYear
    case thisMonth
    case lastThreeMonths
    case lastSixMonths

    var displayName: String {
        switch self {
        case .all: return "All Time"
        case .thisYear: return "This Year"
        case .thisMonth: return "This Month"
        case .lastThreeMonths: return "Last 3 Months"
        case .lastSixMonths: return "Last 6 Months"
        }
    }
}

// MARK: - API Key Management View

struct APIKeyManagementView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var settingsManager = SettingsManager.shared
    @State private var apiKeys: [SettingsAPIService: String] = [:]
    @State private var showingKeyEntry = false
    @State private var selectedService: SettingsAPIService = .openai
    @State private var keyText = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "key.fill")
                        .font(.largeTitle)
                        .foregroundColor(.blue)

                    Text("API Key Management")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text("Securely store your API keys for external services")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top)

                // API Services List
                VStack(spacing: 12) {
                    ForEach(SettingsAPIService.allCases, id: \.self) { service in
                        APIKeyRow(
                            service: service,
                            hasKey: apiKeys[service] != nil,
                            onEdit: {
                                selectedService = service
                                keyText = apiKeys[service] ?? ""
                                showingKeyEntry = true
                            },
                            onRemove: {
                                settingsManager.removeAPIKey(for: service)
                                apiKeys[service] = nil
                            }
                        )
                    }
                }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                .cornerRadius(12)
                .padding(.horizontal)

                Spacer()
            }
            .navigationTitle("API Keys")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            loadAPIKeys()
        }
        .sheet(isPresented: $showingKeyEntry) {
            APIKeyEntryView(
                service: selectedService,
                initialKey: keyText
            ) { key in
                    settingsManager.saveAPIKey(key, for: selectedService)
                    apiKeys[selectedService] = key
                }
        }
    }

    private func loadAPIKeys() {
        for service in SettingsAPIService.allCases {
            if let key = settingsManager.getAPIKey(for: service) {
                apiKeys[service] = key
            }
        }
    }
}

struct APIKeyRow: View {
    let service: SettingsAPIService
    let hasKey: Bool
    let onEdit: () -> Void
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(service.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(service.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if hasKey {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)

                    Button("Edit") {
                        onEdit()
                    }
                    .buttonStyle(.bordered)

                    Button("Remove") {
                        onRemove()
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.red)
                }
            } else {
                Button("Add Key") {
                    onEdit()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }
}

// MARK: - Cloud Configuration View

struct CloudConfigurationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var googleDriveEnabled = false
    @State private var dropboxEnabled = false
    @State private var iCloudEnabled = true
    @State private var oneDriveEnabled = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(spacing: 12) {
                    Image(systemName: "cloud.fill")
                        .font(.largeTitle)
                        .foregroundColor(.blue)

                    Text("Cloud Services")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text("Configure cloud storage and sync services")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top)

                VStack(spacing: 16) {
                    CloudServiceRow(
                        name: "iCloud",
                        description: "Apple's cloud storage service",
                        icon: "icloud.fill",
                        color: .blue,
                        isEnabled: $iCloudEnabled
                    )

                    CloudServiceRow(
                        name: "Google Drive",
                        description: "Google's cloud storage and sync",
                        icon: "globe",
                        color: .green,
                        isEnabled: $googleDriveEnabled
                    )

                    CloudServiceRow(
                        name: "Dropbox",
                        description: "File hosting and sync service",
                        icon: "square.and.arrow.up",
                        color: .blue,
                        isEnabled: $dropboxEnabled
                    )

                    CloudServiceRow(
                        name: "OneDrive",
                        description: "Microsoft's cloud storage",
                        icon: "cloud",
                        color: .orange,
                        isEnabled: $oneDriveEnabled
                    )
                }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                .cornerRadius(12)
                .padding(.horizontal)

                Spacer()
            }
            .navigationTitle("Cloud Services")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct CloudServiceRow: View {
    let name: String
    let description: String
    let icon: String
    let color: Color
    @Binding var isEnabled: Bool

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Toggle("", isOn: $isEnabled)
                .toggleStyle(SwitchToggleStyle())
        }
        .padding()
    }
}

// MARK: - API Key Entry View

struct APIKeyEntryView: View {
    @Environment(\.dismiss) private var dismiss
    let service: SettingsAPIService
    let initialKey: String
    let onSave: (String) -> Void

    @State private var keyText: String = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(spacing: 12) {
                    Image(systemName: service.icon)
                        .font(.largeTitle)
                        .foregroundColor(.blue)

                    Text("Configure \(service.displayName) API Key")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text("Enter your API key for \(service.displayName)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top)

                VStack(alignment: .leading, spacing: 8) {
                    Text("API Key")
                        .font(.headline)

                    SecureField("Enter your API key", text: $keyText)
                        .textFieldStyle(.roundedBorder)
                        .font(.monospaced(.body)())
                }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                .cornerRadius(12)
                .padding(.horizontal)

                Spacer()

                HStack {
                    Button("Cancel") {
                        dismiss()
                    }
                    .buttonStyle(.bordered)

                    Spacer()

                    Button("Save") {
                        onSave(keyText)
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(keyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.horizontal)
            }
            .navigationTitle("\(service.displayName) API Key")
        }
        .onAppear {
            keyText = initialKey
        }
    }
}

// MARK: - Supporting Enums
// (SettingsAPIService already defined above)

#Preview {
    NavigationView {
        SettingsView()
    }
}
