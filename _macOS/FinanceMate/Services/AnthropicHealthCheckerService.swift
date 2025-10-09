import Foundation

/// Health checker service for Anthropic models
/// BLUEPRINT.md 3.1.1.9: Cloud model health checking
class AnthropicHealthCheckerService {
    private let anthropicService: AnthropicServiceProtocol = AnthropicService()

    func checkHealth(_ model: AIModel) async -> ModelHealthStatus {
        do {
            let availableModels = try await anthropicService.fetchAvailableModels()
            let isModelAvailable = availableModels.contains(model.id)

            return isModelAvailable ? .healthy : .unhealthy("Model not available in Anthropic")
        } catch {
            return .unhealthy("Anthropic connection failed: \(error.localizedDescription)")
        }
    }
}