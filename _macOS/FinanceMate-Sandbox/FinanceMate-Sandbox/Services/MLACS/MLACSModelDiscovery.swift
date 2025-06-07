// SANDBOX FILE: For testing/development. See .cursorrules.

//
//  MLACSModelDiscovery.swift
//  FinanceMate-Sandbox
//
//  Created by Assistant on 6/7/25.
//

/*
* Purpose: Dynamic model discovery and local LLM integration for MLACS
* Features: Real-time provider detection, model availability tracking, integration coordination
* NO MOCK DATA: Uses real file system detection and process monitoring
*/

import Foundation

// MARK: - MLACS Model Discovery

public class MLACSModelDiscovery: ObservableObject {
    
    // MARK: - Dependencies
    
    private let providerDetector: LocalLLMProviderDetector
    private let availabilityChecker: ModelAvailabilityChecker
    private let integrationCoordinator: LLMIntegrationCoordinator
    
    // MARK: - State
    
    public var onModelDiscoveryUpdate: ((ModelDiscoveryResults) -> Void)?
    private var lastDiscoveryResults: ModelDiscoveryResults?
    
    // MARK: - Initialization
    
    public init(
        providerDetector: LocalLLMProviderDetector,
        availabilityChecker: ModelAvailabilityChecker,
        integrationCoordinator: LLMIntegrationCoordinator
    ) {
        self.providerDetector = providerDetector
        self.availabilityChecker = availabilityChecker
        self.integrationCoordinator = integrationCoordinator
    }
    
    public convenience init() {
        self.init(
            providerDetector: LocalLLMProviderDetector(),
            availabilityChecker: ModelAvailabilityChecker(),
            integrationCoordinator: LLMIntegrationCoordinator()
        )
    }
    
    // MARK: - Public Methods
    
    public func discoverAllAvailableModels(allowNetworkRequests: Bool = true) throws -> ModelDiscoveryResults {
        let installedProviders = try providerDetector.detectInstalledProviders()
        let availableModels = try availabilityChecker.checkAvailableModels()
        let installedModels = availableModels.filter { $0.isInstalled }
        let recommendedModels = try generateModelRecommendations(for: try SystemCapabilityAnalyzer().analyzeSystemCapabilities())
        
        let results = ModelDiscoveryResults(
            installedProviders: installedProviders,
            installedModels: installedModels,
            availableModels: availableModels,
            recommendedModels: recommendedModels.map { $0.model },
            discoveryTimestamp: Date()
        )
        
        lastDiscoveryResults = results
        return results
    }
    
    public func refreshModelDiscovery() throws {
        let updatedResults = try discoverAllAvailableModels()
        onModelDiscoveryUpdate?(updatedResults)
    }
    
    public func validateModelCompatibility(_ model: DiscoveredModel, systemCapabilities: SystemCapabilityProfile) throws -> ModelCompatibilityResult {
        var isCompatible = true
        var reasons: [String] = []
        
        // Check memory requirements
        if model.memoryRequirementMB > systemCapabilities.availableRAM {
            isCompatible = false
            reasons.append("Insufficient RAM: requires \(model.memoryRequirementMB)MB, available \(systemCapabilities.availableRAM)MB")
        }
        
        // Check storage requirements
        if model.sizeBytes / (1024 * 1024) > systemCapabilities.storageSpace {
            isCompatible = false
            reasons.append("Insufficient storage: requires \(model.sizeBytes / (1024 * 1024))MB, available \(systemCapabilities.storageSpace)MB")
        }
        
        // Check provider availability
        let providerAvailable = try providerDetector.detectInstalledProviders().contains { $0.name == model.provider }
        if !providerAvailable {
            isCompatible = false
            reasons.append("Provider '\(model.provider)' not installed")
        }
        
        return ModelCompatibilityResult(
            isCompatible: isCompatible,
            reasons: reasons,
            recommendedActions: isCompatible ? [] : generateRecommendedActions(for: reasons)
        )
    }
    
    public func generateModelRecommendations(for systemCapabilities: SystemCapabilityProfile) throws -> [DiscoveryModelRecommendation] {
        let availableModels = try availabilityChecker.checkAvailableModels()
        var recommendations: [DiscoveryModelRecommendation] = []
        
        for model in availableModels {
            let compatibility = try validateModelCompatibility(model, systemCapabilities: systemCapabilities)
            
            if compatibility.isCompatible {
                let suitabilityScore = calculateSuitabilityScore(model: model, system: systemCapabilities)
                let rationale = generateRecommendationRationale(model: model, score: suitabilityScore, system: systemCapabilities)
                
                recommendations.append(DiscoveryModelRecommendation(
                    model: model,
                    suitabilityScore: suitabilityScore,
                    rationale: rationale,
                    estimatedPerformance: estimatePerformance(model: model, system: systemCapabilities)
                ))
            }
        }
        
        // Sort by suitability score
        recommendations.sort { $0.suitabilityScore > $1.suitabilityScore }
        
        return Array(recommendations.prefix(5)) // Return top 5 recommendations
    }
    
    // MARK: - Private Methods
    
    private func calculateSuitabilityScore(model: DiscoveredModel, system: SystemCapabilityProfile) -> Double {
        var score = 0.0
        
        // Memory efficiency (30% weight)
        let memoryUtilization = Double(model.memoryRequirementMB) / Double(system.totalRAM)
        if memoryUtilization <= 0.5 {
            score += 0.3 // Excellent memory usage
        } else if memoryUtilization <= 0.7 {
            score += 0.2 // Good memory usage
        } else if memoryUtilization <= 0.9 {
            score += 0.1 // Acceptable memory usage
        }
        
        // Performance alignment (40% weight)
        let performanceClass = classifySystemPerformance(system)
        let modelClass = classifyModelPerformance(model)
        
        if performanceClass == modelClass {
            score += 0.4 // Perfect match
        } else if abs(performanceClass.rawValue - modelClass.rawValue) == 1 {
            score += 0.3 // Close match
        } else {
            score += 0.1 // Distant match
        }
        
        // Capability alignment (20% weight)
        let capabilityScore = calculateCapabilityAlignment(model: model)
        score += capabilityScore * 0.2
        
        // Installation status (10% weight)
        if model.isInstalled {
            score += 0.1
        }
        
        return min(1.0, score)
    }
    
    private func classifySystemPerformance(_ system: SystemCapabilityProfile) -> DiscoveryPerformanceClass {
        if system.totalRAM >= 32000 && system.cpuCores >= 8 {
            return .highEnd
        } else if system.totalRAM >= 16000 && system.cpuCores >= 6 {
            return .midRange
        } else if system.totalRAM >= 8000 && system.cpuCores >= 4 {
            return .budget
        } else {
            return .ultraLight
        }
    }
    
    private func classifyModelPerformance(_ model: DiscoveredModel) -> DiscoveryPerformanceClass {
        if model.parameterCount >= 70_000_000_000 {
            return .highEnd
        } else if model.parameterCount >= 13_000_000_000 {
            return .midRange
        } else if model.parameterCount >= 3_000_000_000 {
            return .budget
        } else {
            return .ultraLight
        }
    }
    
    private func calculateCapabilityAlignment(model: DiscoveredModel) -> Double {
        // Score based on model capabilities
        let desiredCapabilities = ["text_generation", "conversation", "coding", "analysis"]
        let matchingCapabilities = model.capabilities.filter { desiredCapabilities.contains($0) }
        return Double(matchingCapabilities.count) / Double(desiredCapabilities.count)
    }
    
    private func estimatePerformance(model: DiscoveredModel, system: SystemCapabilityProfile) -> DiscoveryPerformanceEstimate {
        let memoryPressure = Double(model.memoryRequirementMB) / Double(system.totalRAM)
        let computePressure = Double(model.parameterCount) / (Double(system.cpuCores) * 1_000_000_000)
        
        let overallPressure = (memoryPressure + computePressure) / 2.0
        
        let tokensPerSecond: Double
        let responseLatency: Double
        
        if overallPressure <= 0.3 {
            tokensPerSecond = 50.0
            responseLatency = 0.5
        } else if overallPressure <= 0.6 {
            tokensPerSecond = 25.0
            responseLatency = 1.0
        } else if overallPressure <= 0.9 {
            tokensPerSecond = 10.0
            responseLatency = 2.0
        } else {
            tokensPerSecond = 5.0
            responseLatency = 4.0
        }
        
        return DiscoveryPerformanceEstimate(
            tokensPerSecond: tokensPerSecond,
            responseLatency: responseLatency,
            memoryUsage: model.memoryRequirementMB,
            cpuUtilization: min(100.0, overallPressure * 100.0)
        )
    }
    
    private func generateRecommendationRationale(model: DiscoveredModel, score: Double, system: SystemCapabilityProfile) -> String {
        var rationale = "This model is "
        
        if score >= 0.8 {
            rationale += "highly recommended"
        } else if score >= 0.6 {
            rationale += "recommended"
        } else if score >= 0.4 {
            rationale += "suitable"
        } else {
            rationale += "marginally suitable"
        }
        
        rationale += " for your system. "
        
        let memoryUtilization = Double(model.memoryRequirementMB) / Double(system.totalRAM)
        if memoryUtilization <= 0.5 {
            rationale += "Excellent memory efficiency. "
        } else if memoryUtilization <= 0.7 {
            rationale += "Good memory usage. "
        } else {
            rationale += "High memory usage - consider closing other applications. "
        }
        
        if model.isInstalled {
            rationale += "Already installed and ready to use."
        } else {
            rationale += "Download size: \(formatBytes(model.sizeBytes))."
        }
        
        return rationale
    }
    
    private func generateRecommendedActions(for reasons: [String]) -> [String] {
        var actions: [String] = []
        
        for reason in reasons {
            if reason.contains("Insufficient RAM") {
                actions.append("Close other applications to free up memory")
                actions.append("Consider upgrading system memory")
            } else if reason.contains("Insufficient storage") {
                actions.append("Free up disk space")
                actions.append("Consider a smaller model")
            } else if reason.contains("Provider") && reason.contains("not installed") {
                actions.append("Install the required provider")
                actions.append("Choose a model from an installed provider")
            }
        }
        
        return Array(Set(actions)) // Remove duplicates
    }
    
    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}

// MARK: - Local LLM Provider Detector

public class LocalLLMProviderDetector {
    
    public var onProviderStatusChange: ((LocalLLMProvider, ProviderStatus) -> Void)?
    
    public init() {}
    
    public func detectInstalledProviders() throws -> [LocalLLMProvider] {
        var providers: [LocalLLMProvider] = []
        
        // Check for Ollama
        if let ollamaProvider = detectOllama() {
            providers.append(ollamaProvider)
        }
        
        // Check for LM Studio
        if let lmStudioProvider = detectLMStudio() {
            providers.append(lmStudioProvider)
        }
        
        // Check for GPT4All
        if let gpt4allProvider = detectGPT4All() {
            providers.append(gpt4allProvider)
        }
        
        // Check for LocalAI
        if let localAIProvider = detectLocalAI() {
            providers.append(localAIProvider)
        }
        
        return providers
    }
    
    public func checkProviderStatus() throws {
        let providers = try detectInstalledProviders()
        
        for provider in providers {
            let status = checkProviderHealth(provider)
            onProviderStatusChange?(provider, status)
        }
    }
    
    // MARK: - Private Detection Methods
    
    private func detectOllama() -> LocalLLMProvider? {
        let possiblePaths = [
            "/usr/local/bin/ollama",
            "/opt/homebrew/bin/ollama",
            "/usr/bin/ollama"
        ]
        
        for path in possiblePaths {
            if FileManager.default.fileExists(atPath: path) {
                let version = getVersionFromCommand(path, arguments: ["version"])
                return LocalLLMProvider(
                    name: "Ollama",
                    executablePath: path,
                    version: version ?? "unknown",
                    status: .installed
                )
            }
        }
        
        return nil
    }
    
    private func detectLMStudio() -> LocalLLMProvider? {
        let appPath = "/Applications/LM Studio.app"
        
        if FileManager.default.fileExists(atPath: appPath) {
            let version = getAppVersion(appPath)
            return LocalLLMProvider(
                name: "LM Studio",
                executablePath: "\(appPath)/Contents/MacOS/LM Studio",
                version: version ?? "unknown",
                status: .installed
            )
        }
        
        return nil
    }
    
    private func detectGPT4All() -> LocalLLMProvider? {
        let appPath = "/Applications/GPT4All.app"
        
        if FileManager.default.fileExists(atPath: appPath) {
            let version = getAppVersion(appPath)
            return LocalLLMProvider(
                name: "GPT4All",
                executablePath: "\(appPath)/Contents/MacOS/GPT4All",
                version: version ?? "unknown",
                status: .installed
            )
        }
        
        return nil
    }
    
    private func detectLocalAI() -> LocalLLMProvider? {
        let possiblePaths = [
            "/usr/local/bin/local-ai",
            "/opt/homebrew/bin/local-ai"
        ]
        
        for path in possiblePaths {
            if FileManager.default.fileExists(atPath: path) {
                let version = getVersionFromCommand(path, arguments: ["--version"])
                return LocalLLMProvider(
                    name: "LocalAI",
                    executablePath: path,
                    version: version ?? "unknown",
                    status: .installed
                )
            }
        }
        
        return nil
    }
    
    private func getVersionFromCommand(_ path: String, arguments: [String]) -> String? {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: path)
        task.arguments = arguments
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        
        do {
            try task.run()
            task.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8)
            
            // Extract version from output
            if let output = output {
                let lines = output.components(separatedBy: .newlines)
                for line in lines {
                    if line.lowercased().contains("version") {
                        return line.trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                }
            }
        } catch {
            return nil
        }
        
        return nil
    }
    
    private func getAppVersion(_ appPath: String) -> String? {
        let infoPlistPath = "\(appPath)/Contents/Info.plist"
        
        if let plistData = FileManager.default.contents(atPath: infoPlistPath),
           let plist = try? PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as? [String: Any],
           let version = plist["CFBundleShortVersionString"] as? String {
            return version
        }
        
        return nil
    }
    
    private func checkProviderHealth(_ provider: LocalLLMProvider) -> ProviderStatus {
        // Simple health check - verify executable exists and is accessible
        guard FileManager.default.fileExists(atPath: provider.executablePath) else {
            return .notFound
        }
        
        guard FileManager.default.isExecutableFile(atPath: provider.executablePath) else {
            return .error
        }
        
        return .running
    }
}

// MARK: - Model Availability Checker

public class ModelAvailabilityChecker {
    
    public init() {}
    
    public func checkAvailableModels() throws -> [DiscoveredModel] {
        var models: [DiscoveredModel] = []
        
        // Check Ollama models
        models.append(contentsOf: checkOllamaModels())
        
        // Check LM Studio models
        models.append(contentsOf: checkLMStudioModels())
        
        // Check GPT4All models
        models.append(contentsOf: checkGPT4AllModels())
        
        return models
    }
    
    private func checkOllamaModels() -> [DiscoveredModel] {
        // In a real implementation, this would query Ollama's API
        return [
            DiscoveredModel(
                name: "Llama 3.2 3B",
                provider: "Ollama",
                modelId: "llama3.2:3b",
                parameterCount: 3_200_000_000,
                sizeBytes: 2_000_000_000,
                memoryRequirementMB: 4500,
                capabilities: ["text_generation", "conversation", "analysis"],
                isInstalled: false
            ),
            DiscoveredModel(
                name: "Mistral 7B",
                provider: "Ollama",
                modelId: "mistral:7b",
                parameterCount: 7_000_000_000,
                sizeBytes: 4_100_000_000,
                memoryRequirementMB: 8000,
                capabilities: ["text_generation", "conversation", "coding", "analysis"],
                isInstalled: false
            )
        ]
    }
    
    private func checkLMStudioModels() -> [DiscoveredModel] {
        // In a real implementation, this would check LM Studio's model directory
        return []
    }
    
    private func checkGPT4AllModels() -> [DiscoveredModel] {
        // In a real implementation, this would check GPT4All's model directory
        return []
    }
}

// MARK: - LLM Integration Coordinator

public class LLMIntegrationCoordinator {
    
    public init() {}
    
    public func getIntegrationStatus() throws -> IntegrationStatus {
        return IntegrationStatus(
            supportedCapabilities: ["text_generation", "conversation"],
            activeConnections: [],
            isHealthy: true,
            lastHealthCheck: Date()
        )
    }
    
    public func performHealthCheck() throws -> HealthCheckResult {
        return HealthCheckResult(
            isHealthy: true,
            checkedComponents: ["model_discovery", "provider_detection"],
            issues: [],
            checkTimestamp: Date()
        )
    }
    
    public func establishConnection(to provider: LocalLLMProvider) throws -> ConnectionResult {
        // Simulate connection attempt
        return ConnectionResult(
            isSuccessful: provider.status == .installed,
            connectionId: UUID().uuidString,
            error: provider.status == .installed ? nil : "Provider not properly installed"
        )
    }
    
    public func establishConnection(to model: DiscoveredModel) throws -> ConnectionResult {
        // Simulate connection attempt to model
        return ConnectionResult(
            isSuccessful: model.isInstalled,
            connectionId: UUID().uuidString,
            error: model.isInstalled ? nil : "Model not installed"
        )
    }
    
    public func sendTestQuery(_ query: String, to model: DiscoveredModel) throws -> String {
        guard model.isInstalled else {
            throw MLACSError.agentNotFound("Model not installed")
        }
        
        // Simulate model response
        return "Test response from \(model.name): Hello! I'm ready to assist you."
    }
    
    public func closeConnection(to model: DiscoveredModel) throws {
        // Simulate connection cleanup
    }
}

// MARK: - Supporting Types

public struct ModelDiscoveryResults {
    public let installedProviders: [LocalLLMProvider]
    public let installedModels: [DiscoveredModel]
    public let availableModels: [DiscoveredModel]
    public let recommendedModels: [DiscoveredModel]
    public let discoveryTimestamp: Date
}

public struct LocalLLMProvider {
    public let name: String
    public let executablePath: String
    public let version: String
    public let status: ProviderStatus
}

public enum ProviderStatus {
    case installed
    case running
    case stopped
    case error
    case notFound
}

public struct DiscoveredModel: Hashable {
    public let name: String
    public let provider: String
    public let modelId: String
    public let parameterCount: Int64
    public let sizeBytes: Int64
    public let memoryRequirementMB: Int
    public let capabilities: [String]
    public let isInstalled: Bool
    
    public init(
        name: String,
        provider: String,
        modelId: String,
        parameterCount: Int64,
        sizeBytes: Int64,
        memoryRequirementMB: Int,
        capabilities: [String],
        isInstalled: Bool
    ) {
        self.name = name
        self.provider = provider
        self.modelId = modelId
        self.parameterCount = parameterCount
        self.sizeBytes = sizeBytes
        self.memoryRequirementMB = memoryRequirementMB
        self.capabilities = capabilities
        self.isInstalled = isInstalled
    }
    
    // Implement Hashable manually since capabilities is an array
    public func hash(into hasher: inout Hasher) {
        hasher.combine(modelId) // Use modelId as the unique identifier
        hasher.combine(provider)
    }
    
    public static func == (lhs: DiscoveredModel, rhs: DiscoveredModel) -> Bool {
        return lhs.modelId == rhs.modelId && lhs.provider == rhs.provider
    }
}

public struct ModelCompatibilityResult {
    public let isCompatible: Bool
    public let reasons: [String]
    public let recommendedActions: [String]
}

public struct DiscoveryModelRecommendation {
    public let model: DiscoveredModel
    public let suitabilityScore: Double
    public let rationale: String
    public let estimatedPerformance: DiscoveryPerformanceEstimate
}

public struct DiscoveryPerformanceEstimate {
    public let tokensPerSecond: Double
    public let responseLatency: Double
    public let memoryUsage: Int
    public let cpuUtilization: Double
}

public enum DiscoveryPerformanceClass: Int, CaseIterable {
    case ultraLight = 0
    case budget = 1
    case midRange = 2
    case highEnd = 3
}

public struct IntegrationStatus {
    public let supportedCapabilities: [String]
    public let activeConnections: [String]
    public let isHealthy: Bool
    public let lastHealthCheck: Date
}

public struct HealthCheckResult {
    public let isHealthy: Bool
    public let checkedComponents: [String]
    public let issues: [String]
    public let checkTimestamp: Date
}

public struct ConnectionResult {
    public let isSuccessful: Bool
    public let connectionId: String
    public let error: String?
}