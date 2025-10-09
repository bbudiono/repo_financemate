import Foundation

/// Protocol definitions for AI services
/// BLUEPRINT.md 3.1.1.9: Service abstractions for multiple providers

protocol OllamaServiceProtocol {
    func fetchAvailableModels() async throws -> [OllamaModel]
}

protocol OpenAIServiceProtocol {
    func fetchAvailableModels() async throws -> [String]
}

protocol AnthropicServiceProtocol {
    func fetchAvailableModels() async throws -> [String]
}