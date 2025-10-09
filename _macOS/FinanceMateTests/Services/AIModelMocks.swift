import Foundation
@testable import FinanceMate

// MARK: - Mock Classes for AI Model Testing

class MockPersistenceController {
    // Mock implementation for testing
}

class MockOllamaService: OllamaServiceProtocol {
    var mockModels: [OllamaModel] = []

    func fetchAvailableModels() async throws -> [OllamaModel] {
        return mockModels
    }
}

class MockOpenAIService: OpenAIServiceProtocol {
    var mockModels: [String] = []

    func fetchAvailableModels() async throws -> [String] {
        return mockModels
    }
}

class MockAnthropicService: AnthropicServiceProtocol {
    var mockModels: [String] = []

    func fetchAvailableModels() async throws -> [String] {
        return mockModels
    }
}

class MockModelHealthCheckService: ModelHealthCheckServiceProtocol {
    var mockHealthResults: [String: ModelHealthStatus] = [:]

    func checkHealth(of model: AIModel) async -> ModelHealthStatus {
        return mockHealthResults[model.id] ?? .unknown
    }
}