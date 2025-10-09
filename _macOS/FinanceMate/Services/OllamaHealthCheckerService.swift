import Foundation

/// Health checker service for Ollama models
/// BLUEPRINT.md 3.1.1.9: Local model health checking
class OllamaHealthCheckerService {
    private let ollamaService: OllamaServiceProtocol = OllamaService()

    func checkHealth(_ model: AIModel) async -> ModelHealthStatus {
        do {
            let availableModels = try await ollamaService.fetchAvailableModels()
            let isModelAvailable = availableModels.contains { $0.name == model.id }

            return isModelAvailable ? .healthy : .unhealthy("Model not found in Ollama")
        } catch {
            return .unhealthy("Ollama connection failed: \(error.localizedDescription)")
        }
    }
}