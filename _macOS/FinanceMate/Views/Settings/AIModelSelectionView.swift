import SwiftUI

/// Admin-only AI model configuration interface
/// BLUEPRINT.md 3.1.1.9: LLM-as-a-Judge Architecture Settings
struct AIModelSelectionView: View {
    @StateObject private var configurationManager: AIModelConfigurationManager
    @State private var selectedJudgeModel: AIModel?
    @State private var availableLocalModels: [AIModel] = []
    @State private var availableCloudModels: [AIModel] = []
    @State private var isLoadingModels = false
    @State private var showingError = false
    @State private var errorMessage = ""

    init(configurationManager: AIModelConfigurationManager) {
        _configurationManager = StateObject(wrappedValue: configurationManager)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                AIModelSelectionHeader()

                AIModelJudgeConfigurationSection(
                    configurationManager: configurationManager,
                    availableLocalModels: $availableLocalModels,
                    isLoadingModels: isLoadingModels,
                    onSelectJudgeModel: selectJudgeModel,
                    onRemoveJudgeModel: removeJudgeModel
                )

                AIModelGeneratorConfigurationSection(
                    configurationManager: configurationManager,
                    availableCloudModels: $availableCloudModels,
                    onAddGeneratorModel: addGeneratorModel,
                    onRemoveGeneratorModel: removeGeneratorModel
                )

                AIModelHealthStatusSection(configurationManager: configurationManager)

                AIModelActionButtons(
                    onRefreshModels: {
                        Task { await loadAvailableModels() }
                    },
                    onSaveConfiguration: saveConfiguration,
                    onResetConfiguration: resetConfiguration
                )
            }
            .padding()
        }
        .navigationTitle("AI Model Configuration")
        .navigationBarTitleDisplayMode(.large)
        .alert("Error", isPresented: $showingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .task {
            await loadAvailableModels()
        }
    }

    // MARK: - Helper Methods

    private func loadAvailableModels() async {
        isLoadingModels = true

        let discoveryService = AIModelDiscoveryService()
        async let localModels = discoveryService.discoverLocalModels()
        async let cloudModels = discoveryService.discoverCloudModels()

        let (local, cloud) = await (localModels, cloudModels)

        await MainActor.run {
            availableLocalModels = local.filter { model in
                configurationManager.getCurrentJudgeModel()?.id != model.id
            }
            availableCloudModels = cloud.filter { model in
                !configurationManager.getGeneratorModels().contains(model)
            }
            isLoadingModels = false
        }
    }

    private func selectJudgeModel(_ model: AIModel) {
        let result = configurationManager.setJudgeModel(model)
        if result.success {
            selectedJudgeModel = model
            availableLocalModels.removeAll { $0.id == model.id }
        } else {
            showError(result.error?.localizedDescription ?? "Failed to select judge model")
        }
    }

    private func removeJudgeModel() {
        guard let currentModel = configurationManager.getCurrentJudgeModel() else { return }
        availableLocalModels.append(currentModel)
        configurationManager.configuration.judgeModel = nil
    }

    private func addGeneratorModel(_ model: AIModel) {
        let result = configurationManager.addGeneratorModel(model)
        if result.success {
            availableCloudModels.removeAll { $0.id == model.id }
        } else {
            showError(result.error?.localizedDescription ?? "Failed to add generator model")
        }
    }

    private func removeGeneratorModel(_ model: AIModel) {
        let result = configurationManager.removeGeneratorModel(model)
        if result.success && model.type == .cloud {
            availableCloudModels.append(model)
        }
    }

    private func saveConfiguration() {
        let result = configurationManager.saveConfiguration()
        if !result.success {
            showError(result.error?.localizedDescription ?? "Failed to save configuration")
        }
    }

    private func resetConfiguration() {
        let result = configurationManager.resetConfiguration()
        if result.success {
            Task {
                await loadAvailableModels()
            }
        } else {
            showError(result.error?.localizedDescription ?? "Failed to reset configuration")
        }
    }

    private func showError(_ message: String) {
        errorMessage = message
        showingError = true
    }
}

#Preview {
    NavigationView {
        AIModelSelectionView(
            configurationManager: AIModelConfigurationManager(
                persistenceController: PersistenceController.shared
            )
        )
    }
}