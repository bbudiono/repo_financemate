import SwiftUI

struct SettingsView: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var authManager: AuthenticationManager
    @StateObject private var viewModel = SettingsViewModel()

    var body: some View {
        HStack(spacing: 0) {
            // Sidebar Navigation
            VStack(alignment: .leading, spacing: 8) {
                Text("Settings")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.bottom, 8)

                ForEach(SettingsViewModel.SettingsSection.allCases, id: \.self) { section in
                    Button(action: { viewModel.selectedSection = section }) {
                        HStack {
                            Image(systemName: section.icon)
                                .frame(width: 24)
                            Text(section.rawValue)
                            Spacer()
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(viewModel.selectedSection == section ? Color.accentColor.opacity(0.15) : Color.clear)
                        .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }

                Spacer()

                Button("Sign Out") {
                    authManager.signOut()
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
            }
            .frame(width: 200)
            .padding()
            .background(.ultraThinMaterial)

            Divider()

            // Content Area
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    switch viewModel.selectedSection {
                    case .profile:
                        ProfileSection(authManager: authManager, viewModel: viewModel)
                    case .security:
                        SecuritySection(viewModel: viewModel)
                    case .apiKeys:
                        APIKeysSection(viewModel: viewModel)
                    case .connections:
                        ConnectionsSection(viewModel: viewModel)
                    case .automation:
                        AutomationSection(viewModel: viewModel)
                    case .extractionHealth:
                        ExtractionHealthSection()
                    }
                }
                .padding()
            }
        }
    }
}

// MARK: - Profile Section
struct ProfileSection: View {
    let authManager: AuthenticationManager
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Profile")
                .font(.largeTitle)
                .fontWeight(.bold)

            if let name = authManager.userName {
                LabeledContent("Name") {
                    Text(name)
                }
            }

            if let email = authManager.userEmail {
                LabeledContent("Email") {
                    Text(email)
                }
            }

            LabeledContent("Display Name") {
                TextField("Enter display name", text: $viewModel.displayName)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 300)
            }

            Button("Save Changes") {
                Task { await viewModel.saveProfile() }
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isSaving)
        }
    }
}

// MARK: - Security Section
struct SecuritySection: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Security")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Change Password")
                .font(.headline)

            SecureField("Current Password", text: $viewModel.currentPassword)
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: 300)

            SecureField("New Password", text: $viewModel.newPassword)
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: 300)

            SecureField("Confirm Password", text: $viewModel.confirmPassword)
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: 300)

            Button("Update Password") {
                Task {
                    let success = await viewModel.changePassword()
                    if success {
                        viewModel.currentPassword = ""
                        viewModel.newPassword = ""
                        viewModel.confirmPassword = ""
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isSaving)
        }
    }
}

// MARK: - API Keys Section
struct APIKeysSection: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("API Keys")
                .font(.largeTitle)
                .fontWeight(.bold)

            LabeledContent("Anthropic (Claude)") {
                SecureField("API Key", text: $viewModel.anthropicAPIKey)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 400)
            }

            LabeledContent("OpenAI (GPT)") {
                SecureField("API Key", text: $viewModel.openAIAPIKey)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 400)
            }

            LabeledContent("Google (Gemini)") {
                SecureField("API Key", text: $viewModel.geminiAPIKey)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 400)
            }

            Button("Save API Keys") {
                Task { await viewModel.saveAPIKeys() }
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isSaving)
        }
    }
}

// MARK: - Connections Section
struct ConnectionsSection: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Connected Accounts")
                .font(.largeTitle)
                .fontWeight(.bold)

            if viewModel.connectedAccounts.isEmpty {
                Text("No connected accounts")
                    .foregroundColor(.secondary)
            } else {
                ForEach(viewModel.connectedAccounts) { account in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(account.type)
                                .fontWeight(.semibold)
                            Text(account.email)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Button("Disconnect") {
                            viewModel.disconnectAccount(account)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(8)
                }
            }
        }
    }
}

// MARK: - Automation Section
struct AutomationSection: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Automation Rules")
                .font(.largeTitle)
                .fontWeight(.bold)

            if viewModel.automationRules.isEmpty {
                Text("No automation rules configured")
                    .foregroundColor(.secondary)
            } else {
                ForEach(viewModel.automationRules) { rule in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(rule.name)
                                .fontWeight(.semibold)
                            Text("If: \(rule.condition) → Then: \(rule.action)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Toggle("", isOn: .constant(rule.isEnabled))
                            .onChange(of: rule.isEnabled) { _ in
                                viewModel.toggleRule(rule)
                            }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(8)
                }
            }
        }
    }
}

// MARK: - Extraction Health Section
struct ExtractionHealthSection: View {
    @Environment(\.managedObjectContext) private var context
    @StateObject private var analytics: ExtractionHealthViewModel

    init() {
        _analytics = StateObject(wrappedValue: ExtractionHealthViewModel(context: PersistenceController.shared.container.viewContext))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Extraction Health").font(.largeTitle).fontWeight(.bold)
            Text("Foundation Models extraction analytics (macOS 26+)").foregroundColor(.secondary)

            HStack(spacing: 12) {
                StatCard(title: "Auto-Approved", value: "\(Int(analytics.autoApprovedPercent * 100))%", color: .green)
                StatCard(title: "Needs Review", value: "\(Int(analytics.needsReviewPercent * 100))%", color: .yellow)
                StatCard(title: "Manual", value: "\(Int(analytics.manualReviewPercent * 100))%", color: .red)
            }

            LabeledContent("Total Extractions (30 days)") {
                Text("\(analytics.totalExtractions)").fontWeight(.semibold)
            }

            if !analytics.topCorrectedMerchants.isEmpty {
                Text("Most Corrected Merchants").font(.headline)
                ForEach(analytics.topCorrectedMerchants.indices, id: \.self) { i in
                    HStack {
                        Text("\(i + 1). \(analytics.topCorrectedMerchants[i].merchant)")
                        Spacer()
                        Text("\(analytics.topCorrectedMerchants[i].count) corrections").foregroundColor(.secondary)
                    }
                }
            }

            Button("Export Feedback Data") { analytics.exportFeedbackData() }.buttonStyle(.borderedProminent)
        }
        .onAppear { analytics.loadAnalytics() }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.caption).foregroundColor(.secondary)
            Text(value).font(.title2).fontWeight(.bold).foregroundColor(color)
        }
        .padding().frame(maxWidth: .infinity, alignment: .leading).background(.ultraThinMaterial).cornerRadius(8)
    }
}
