import Foundation

/// Service for checking health of AI models
/// BLUEPRINT.md 3.1.1.9: Real-time health checks for model availability
class ModelHealthCheckService: ModelHealthCheckServiceProtocol {

    // MARK: - Health Cache
    private var healthCache: [String: ModelHealthStatus] = [:]
    private var lastHealthCheck: [String: Date] = [:]
    private let cacheTimeout: TimeInterval = 60 // 1 minute

    // MARK: - Health Check Protocol

    /// Performs health check on a specific model
    func checkHealth(of model: AIModel) async -> ModelHealthStatus {
        let modelKey = "\(model.provider.rawValue):\(model.id)"

        // Check cache first
        if let cachedStatus = healthCache[modelKey],
           let lastCheck = lastHealthCheck[modelKey],
           Date().timeIntervalSince(lastCheck) < cacheTimeout {
            return cachedStatus
        }

        // Perform actual health check
        let status = await performHealthCheck(model)

        // Update cache
        await MainActor.run {
            healthCache[modelKey] = status
            lastHealthCheck[modelKey] = Date()
        }

        return status
    }

    /// Clears health cache for a specific model
    func clearHealthCache(for model: AIModel) {
        let modelKey = "\(model.provider.rawValue):\(model.id)"
        healthCache.removeValue(forKey: modelKey)
        lastHealthCheck.removeValue(forKey: modelKey)
    }

    /// Clears all health cache
    func clearAllHealthCache() {
        healthCache.removeAll()
        lastHealthCheck.removeAll()
    }

    // MARK: - Private Implementation

    private func performHealthCheck(_ model: AIModel) async -> ModelHealthStatus {
        switch model.provider {
        case .ollama:
            return await OllamaHealthCheckerService().checkHealth(model)
        case .openai:
            return await OpenAIHealthCheckerService().checkHealth(model)
        case .anthropic:
            return await AnthropicHealthCheckerService().checkHealth(model)
        case .google, .azure:
            return .unhealthy("Provider not yet supported")
        }
    }
}

// MARK: - Protocol Definition

protocol ModelHealthCheckServiceProtocol {
    func checkHealth(of model: AIModel) async -> ModelHealthStatus
}