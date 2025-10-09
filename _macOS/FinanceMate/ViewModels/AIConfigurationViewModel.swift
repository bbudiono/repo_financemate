import SwiftUI
import Combine

/// View model for AI Model Configuration
/// BLUEPRINT.md 3.1.1.9: LLM-as-a-Judge Architecture
@MainActor
class AIConfigurationViewModel: ObservableObject {
    // MARK: - Configuration Manager
    private let configurationManager: AIModelConfigurationManager

    // MARK: - Published Properties
    @Published var isLoadingModels = false
    @Published var showingError = false
    @Published var errorMessage = ""
    @Published var availableLocalModels: [AIModel] = []
    @Published var availableCloudModels: [AIModel] = []

    // MARK: - Initialization
    init(configurationManager: AIModelConfigurationManager) {
        self.configurationManager = configurationManager
    }

    // MARK: - Public Methods

    /// Loads available AI models from all providers
    func loadAvailableModels() async {
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

    /// Selects a judge model
    func selectJudgeModel(_ model: AIModel) -> Bool {
        let result = configurationManager.setJudgeModel(model)
        if result.success {
            availableLocalModels.removeAll { $0.id == model.id }
        } else {
            showError(result.error?.localizedDescription ?? "Failed to select judge model")
        }
        return result.success
    }

    /// Removes the current judge model
    func removeJudgeModel() {
        guard let currentModel = configurationManager.getCurrentJudgeModel() else { return }
        availableLocalModels.append(currentModel)
        configurationManager.configuration.judgeModel = nil
    }

    /// Adds a generator model
    func addGeneratorModel(_ model: AIModel) -> Bool {
        let result = configurationManager.addGeneratorModel(model)
        if result.success {
            availableCloudModels.removeAll { $0.id == model.id }
        } else {
            showError(result.error?.localizedDescription ?? "Failed to add generator model")
        }
        return result.success
    }

    /// Removes a generator model
    func removeGeneratorModel(_ model: AIModel) -> Bool {
        let result = configurationManager.removeGeneratorModel(model)
        if result.success && model.type == .cloud {
            availableCloudModels.append(model)
        }
        return result.success
    }

    /// Saves the current configuration
    func saveConfiguration() -> Bool {
        let result = configurationManager.saveConfiguration()
        if !result.success {
            showError(result.error?.localizedDescription ?? "Failed to save configuration")
        }
        return result.success
    }

    /// Resets configuration to defaults
    func resetConfiguration() -> Bool {
        let result = configurationManager.resetConfiguration()
        if result.success {
            Task {
                await loadAvailableModels()
            }
        } else {
            showError(result.error?.localizedDescription ?? "Failed to reset configuration")
        }
        return result.success
    }

    /// Refreshes available models
    func refreshModels() async {
        await loadAvailableModels()
    }

    // MARK: - Private Methods

    private func showError(_ message: String) {
        errorMessage = message
        showingError = true
    }
}