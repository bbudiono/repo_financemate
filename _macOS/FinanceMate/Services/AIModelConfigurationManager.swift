import Foundation
import Combine

/// Manages AI model configuration for LLM-as-a-Judge system
/// BLUEPRINT.md 3.1.1.9: LLM-as-a-Judge Architecture
class AIModelConfigurationManager: ObservableObject {

    // MARK: - Dependencies
    private let persistenceController: PersistenceController
    private let userDefaults: UserDefaults

    // MARK: - Services
    var ollamaService: OllamaServiceProtocol = OllamaService()
    var openaiService: OpenAIServiceProtocol = OpenAIService()
    var anthropicService: AnthropicServiceProtocol = AnthropicService()
    var healthCheckService: ModelHealthCheckServiceProtocol = ModelHealthCheckService()

    // MARK: - Configuration
    @Published var configuration: LLMJudgeConfiguration
    private let configurationKey = "LLMJudgeConfiguration"

    // MARK: - Initialization
    init(persistenceController: PersistenceController) {
        self.persistenceController = persistenceController
        self.userDefaults = UserDefaults.standard
        self.configuration = LLMJudgeConfiguration()
        loadConfiguration()
    }

    // MARK: - Judge Model Management

    /// Sets the judge model (must be a local Ollama model)
    /// BLUEPRINT.md 3.1.1.9: Judge LLM must be local
    func setJudgeModel(_ model: AIModel) -> AIModelOperationResult {
        // Validate that judge model is local
        guard model.type == .local && model.provider == .ollama else {
            let error = ModelConfigurationError.judgeModelMustBeLocal
            return AIModelOperationResult(success: false, error: error)
        }

        configuration.judgeModel = model
        return AIModelOperationResult(success: true)
    }

    /// Gets the current judge model
    func getCurrentJudgeModel() -> AIModel? {
        return configuration.judgeModel
    }

    // MARK: - Generator Model Management

    /// Adds a generator model (up to 3 allowed)
    /// BLUEPRINT.md 3.1.1.9: Maximum 3 generator models
    func addGeneratorModel(_ model: AIModel) -> AIModelOperationResult {
        guard configuration.generatorModels.count < 3 else {
            let error = ModelConfigurationError.maximumGeneratorModelsExceeded
            return AIModelOperationResult(success: false, error: error)
        }

        // Check for duplicates
        guard !configuration.generatorModels.contains(model) else {
            let error = ModelConfigurationError.modelAlreadyExists
            return AIModelOperationResult(success: false, error: error)
        }

        configuration.generatorModels.append(model)
        return AIModelOperationResult(success: true)
    }

    /// Removes a generator model
    func removeGeneratorModel(_ model: AIModel) -> AIModelOperationResult {
        configuration.generatorModels.removeAll { $0.id == model.id }
        return AIModelOperationResult(success: true)
    }

    /// Gets all configured generator models
    func getGeneratorModels() -> [AIModel] {
        return configuration.generatorModels
    }

    // MARK: - Configuration Persistence

    /// Saves current configuration to persistent storage
    func saveConfiguration() -> AIModelOperationResult {
        do {
            let data = try JSONEncoder().encode(configuration)
            userDefaults.set(data, forKey: configurationKey)
            return AIModelOperationResult(success: true)
        } catch {
            return AIModelOperationResult(success: false, error: error)
        }
    }

    /// Loads configuration from persistent storage
    func loadConfiguration() -> AIModelOperationResult {
        guard let data = userDefaults.data(forKey: configurationKey) else {
            // No saved configuration, use defaults
            return AIModelOperationResult(success: true)
        }

        do {
            configuration = try JSONDecoder().decode(LLMJudgeConfiguration.self, from: data)
            return AIModelOperationResult(success: true)
        } catch {
            return AIModelOperationResult(success: false, error: error)
        }
    }

    /// Resets configuration to defaults
    func resetConfiguration() -> AIModelOperationResult {
        configuration = LLMJudgeConfiguration()
        return saveConfiguration()
    }
}

// MARK: - Error Types

enum ModelConfigurationError: LocalizedError {
    case judgeModelMustBeLocal
    case maximumGeneratorModelsExceeded
    case modelAlreadyExists
    case invalidConfiguration

    var errorDescription: String? {
        switch self {
        case .judgeModelMustBeLocal:
            return "Judge LLM must be a local Ollama model"
        case .maximumGeneratorModelsExceeded:
            return "Maximum 3 generator models allowed"
        case .modelAlreadyExists:
            return "Model already exists in configuration"
        case .invalidConfiguration:
            return "Invalid model configuration"
        }
    }
}