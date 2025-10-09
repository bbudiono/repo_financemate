import Foundation

/// Represents an AI model configuration
/// BLUEPRINT.md 3.1.1.9: LLM-as-a-Judge Architecture
struct AIModel: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let provider: AIProvider
    let type: AIModelType
    var maxTokens: Int?
    var temperature: Double?
    var isEnabled: Bool = true

    init(id: String, name: String, provider: AIProvider, type: AIModelType, maxTokens: Int? = nil, temperature: Double? = nil) {
        self.id = id
        self.name = name
        self.provider = provider
        self.type = type
        self.maxTokens = maxTokens
        self.temperature = temperature
    }

    static func == (lhs: AIModel, rhs: AIModel) -> Bool {
        return lhs.id == rhs.id && lhs.provider == rhs.provider
    }
}

/// Operation Result for model configuration
struct AIModelOperationResult {
    let success: Bool
    let error: Error?

    init(success: Bool, error: Error? = nil) {
        self.success = success
        self.error = error
    }
}