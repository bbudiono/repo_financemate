import SwiftUI
import Combine

// MARK: - Settings View Model
// Manages all settings sections: Profile, Security, API Keys, Connections, Automation Rules

@MainActor
class SettingsViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var displayName: String = ""
    @Published var selectedSection: SettingsSection = .profile
    @Published var isSaving = false

    // Security
    @Published var currentPassword: String = ""
    @Published var newPassword: String = ""
    @Published var confirmPassword: String = ""

    // API Keys
    @Published var anthropicAPIKey: String = ""
    @Published var openAIAPIKey: String = ""
    @Published var geminiAPIKey: String = ""

    // Connections
    @Published var connectedAccounts: [ConnectedAccount] = []

    // Automation Rules
    @Published var automationRules: [AutomationRule] = []

    // MARK: - Section Enum
    enum SettingsSection: String, CaseIterable {
        case profile = "Profile"
        case security = "Security"
        case apiKeys = "API Keys"
        case connections = "Connections"
        case automation = "Automation Rules"
        case extractionHealth = "Extraction Health"

        var icon: String {
            switch self {
            case .profile: return "person.circle.fill"
            case .security: return "lock.shield.fill"
            case .apiKeys: return "key.fill"
            case .connections: return "link.circle.fill"
            case .automation: return "gearshape.2.fill"
            case .extractionHealth: return "chart.bar.doc.horizontal.fill"
            }
        }
    }

    // MARK: - Supporting Models
    struct ConnectedAccount: Identifiable {
        let id = UUID()
        let type: String
        let email: String
        let isActive: Bool
    }

    struct AutomationRule: Identifiable {
        let id = UUID()
        let name: String
        let condition: String
        let action: String
        let isEnabled: Bool
    }

    // MARK: - Methods
    func saveProfile() async {
        isSaving = true
        // Simulate save
        try? await Task.sleep(nanoseconds: 500_000_000)
        isSaving = false
    }

    func changePassword() async -> Bool {
        guard newPassword == confirmPassword else { return false }
        isSaving = true
        // Simulate password change
        try? await Task.sleep(nanoseconds: 500_000_000)
        isSaving = false
        return true
    }

    func saveAPIKeys() async {
        isSaving = true
        // Simulate save
        try? await Task.sleep(nanoseconds: 500_000_000)
        isSaving = false
    }

    func disconnectAccount(_ account: ConnectedAccount) {
        connectedAccounts.removeAll { $0.id == account.id }
    }

    func toggleRule(_ rule: AutomationRule) {
        if let index = automationRules.firstIndex(where: { $0.id == rule.id }) {
            let updatedRule = AutomationRule(
                name: rule.name,
                condition: rule.condition,
                action: rule.action,
                isEnabled: !rule.isEnabled
            )
            automationRules[index] = updatedRule
        }
    }
}
