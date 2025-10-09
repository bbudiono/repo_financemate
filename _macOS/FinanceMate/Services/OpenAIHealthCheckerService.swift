import Foundation

/// Health checker service for OpenAI models
/// BLUEPRINT.md 3.1.1.9: Cloud model health checking
class OpenAIHealthCheckerService {
    private let openaiService: OpenAIServiceProtocol = OpenAIService()

    func checkHealth(_ model: AIModel) async -> ModelHealthStatus {
        do {
            let availableModels = try await openaiService.fetchAvailableModels()
            let isModelAvailable = availableModels.contains(model.id)

            return isModelAvailable ? .healthy : .unhealthy("Model not available in OpenAI")
        } catch {
            return .unhealthy("OpenAI connection failed: \(error.localizedDescription)")
        }
    }
}