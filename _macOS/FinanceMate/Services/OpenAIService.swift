import Foundation

/// OpenAI service implementation
/// BLUEPRINT.md 3.1.1.9: Cloud OpenAI integration
class OpenAIService: OpenAIServiceProtocol {

    func fetchAvailableModels() async throws -> [String] {
        // TODO: Implement actual OpenAI API integration
        // For now, return empty array
        return []
    }
}