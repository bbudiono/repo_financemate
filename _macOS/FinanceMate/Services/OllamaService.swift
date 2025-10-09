import Foundation

/// Ollama service implementation
/// BLUEPRINT.md 3.1.1.9: Local Ollama integration
class OllamaService: OllamaServiceProtocol {

    func fetchAvailableModels() async throws -> [OllamaModel] {
        // TODO: Implement actual Ollama API integration
        // For now, return empty array
        return []
    }
}