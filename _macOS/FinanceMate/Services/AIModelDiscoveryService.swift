import Foundation

/// Service for discovering AI models from various providers
/// BLUEPRINT.md 3.1.1.9: Model discovery from multiple providers
class AIModelDiscoveryService {

    // MARK: - Services
    private let ollamaService: OllamaServiceProtocol
    private let openaiService: OpenAIServiceProtocol
    private let anthropicService: AnthropicServiceProtocol

    // MARK: - Initialization
    init(
        ollamaService: OllamaServiceProtocol = OllamaService(),
        openaiService: OpenAIServiceProtocol = OpenAIService(),
        anthropicService: AnthropicServiceProtocol = AnthropicService()
    ) {
        self.ollamaService = ollamaService
        self.openaiService = openaiService
        self.anthropicService = anthropicService
    }

    // MARK: - Model Discovery

    /// Discovers available local Ollama models
    func discoverLocalModels() async -> [AIModel] {
        do {
            let ollamaModels = try await ollamaService.fetchAvailableModels()
            return ollamaModels.map { ollamaModel in
                AIModel(
                    id: ollamaModel.name,
                    name: ollamaModel.name,
                    provider: .ollama,
                    type: .local
                )
            }
        } catch {
            print("Failed to discover local models: \(error)")
            return []
        }
    }

    /// Discovers available cloud models from all providers
    func discoverCloudModels() async -> [AIModel] {
        do {
            async let openaiModels = openaiService.fetchAvailableModels()
            async let anthropicModels = anthropicService.fetchAvailableModels()

            let (openaiResult, anthropicResult) = try await (openaiModels, anthropicModels)

            let openaiAIModels = openaiResult.map { modelName in
                AIModel(
                    id: modelName,
                    name: modelName,
                    provider: .openai,
                    type: .cloud
                )
            }

            let anthropicAIModels = anthropicResult.map { modelName in
                AIModel(
                    id: modelName,
                    name: modelName,
                    provider: .anthropic,
                    type: .cloud
                )
            }

            return openaiAIModels + anthropicAIModels
        } catch {
            print("Failed to discover cloud models: \(error)")
            return []
        }
    }

    /// Discovers all available models from all sources
    func discoverAllModels() async -> [AIModel] {
        async let localModels = discoverLocalModels()
        async let cloudModels = discoverCloudModels()

        let (local, cloud) = await (localModels, cloudModels)
        return local + cloud
    }
}