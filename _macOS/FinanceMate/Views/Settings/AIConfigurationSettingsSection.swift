import SwiftUI

/// AI Configuration Settings Section
/// BLUEPRINT.md 3.1.1.9: Admin-only AI model configuration settings
struct AIConfigurationSettingsSection: View {
    @StateObject private var configurationManager: AIModelConfigurationManager
    @StateObject private var aiViewModel: AIConfigurationViewModel

    init() {
        let configManager = AIModelConfigurationManager(persistenceController: PersistenceController.shared)
        _configurationManager = StateObject(wrappedValue: configManager)
        _aiViewModel = StateObject(wrappedValue: AIConfigurationViewModel(configurationManager: configManager))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Admin-only notice
            adminNoticeSection

            // AI Model Selection Interface
            AIModelSelectionView(configurationManager: configurationManager)
        }
        .alert("AI Configuration Error", isPresented: $aiViewModel.showingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(aiViewModel.errorMessage)
        }
    }

    // MARK: - Admin Notice Section

    private var adminNoticeSection: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
                .font(.title2)

            VStack(alignment: .leading, spacing: 4) {
                Text("Admin-Only Configuration")
                    .font(.headline)
                    .fontWeight(.semibold)

                Text("AI model configuration requires administrative privileges. Changes here affect all users and AI processing behavior.")
                    .font(.body)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    AIConfigurationSettingsSection()
        .padding()
}