import Foundation

/// AI Provider enumeration
/// BLUEPRINT.md 3.1.1.9: Support for multiple AI providers
enum AIProvider: String, CaseIterable, Codable {
    case openai = "OpenAI"
    case anthropic = "Anthropic"
    case ollama = "Ollama"
    case google = "Google"
    case azure = "Azure"

    var isLocal: Bool {
        return self == .ollama
    }

    var baseURL: String {
        switch self {
        case .openai:
            return "https://api.openai.com/v1"
        case .anthropic:
            return "https://api.anthropic.com/v1"
        case .ollama:
            return "http://localhost:11434"
        case .google:
            return "https://generativelanguage.googleapis.com/v1beta"
        case .azure:
            return "https://openai.azure.com"
        }
    }
}

/// AI Model Type enumeration
enum AIModelType: String, CaseIterable, Codable {
    case local = "Local"
    case cloud = "Cloud"
}

/// Model Health Status enumeration
enum ModelHealthStatus: Equatable, Codable {
    case healthy
    case unhealthy(String)
    case checking
    case unknown

    var displayText: String {
        switch self {
        case .healthy:
            return "Healthy"
        case .unhealthy(let message):
            return "Unhealthy: \(message)"
        case .checking:
            return "Checking..."
        case .unknown:
            return "Unknown"
        }
    }

    var color: String {
        switch self {
        case .healthy:
            return "green"
        case .unhealthy:
            return "red"
        case .checking:
            return "orange"
        case .unknown:
            return "gray"
        }
    }
}

/// Ollama model representation
struct OllamaModel: Codable {
    let name: String
    let size: String
    let digest: String?

    init(name: String, size: String, digest: String? = nil) {
        self.name = name
        self.size = size
        self.digest = digest
    }
}