import Foundation

/// Anthropic service implementation
/// BLUEPRINT.md 3.1.1.9: Cloud Anthropic integration
class AnthropicService: AnthropicServiceProtocol {

    func fetchAvailableModels() async throws -> [String] {
        // TODO: Implement actual Anthropic API integration
        // For now, return empty array
        return []
    }
}