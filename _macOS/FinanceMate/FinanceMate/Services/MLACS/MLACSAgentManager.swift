
//
//  MLACSAgentManager.swift
//  FinanceMate
//
//  Created by Assistant on 6/7/25.
//

/*
* Purpose: MLACS Agent Management and Configuration System
* Features: Agent lifecycle, configuration management, performance monitoring, profile management
* Focus: Custom agent creation, specialization, and real-time performance tracking
*/

import Foundation
import Combine

// MARK: - MLACS Agent Manager

@MainActor
public class MLACSAgentManager: ObservableObject {
    
    // MARK: - Dependencies
    
    private let configurationService: AgentConfigurationService
    private let profileManager: AgentProfileManager
    private let performanceMonitor: AgentPerformanceMonitor
    
    // MARK: - Published Properties
    
    @Published public private(set) var agents: [String: ManagedAgent] = [:]
    @Published public private(set) var activeAgentId: String?
    @Published public private(set) var isLoading = false
    
    // MARK: - Private Properties
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    public init(
        configurationService: AgentConfigurationService,
        profileManager: AgentProfileManager,
        performanceMonitor: AgentPerformanceMonitor
    ) {
        self.configurationService = configurationService
        self.profileManager = profileManager
        self.performanceMonitor = performanceMonitor
        
        setupBindings()
    }
    
    public convenience init() {
        self.init(
            configurationService: AgentConfigurationService(),
            profileManager: AgentProfileManager(),
            performanceMonitor: AgentPerformanceMonitor()
        )
    }
    
    // MARK: - Agent Creation
    
    public func createAgent(
        from model: DiscoveredModel,
        name: String,
        systemCapabilities: SystemCapabilityProfile
    ) throws -> ManagedAgent {
        
        // Validate system requirements
        try validateSystemRequirements(model: model, systemCapabilities: systemCapabilities)
        
        // Create default configuration
        let defaultConfig = AgentConfiguration(
            name: name,
            personality: .professional,
            specialization: .general,
            responseStyle: .balanced,
            creativityLevel: 0.5,
            safetyLevel: .high,
            memoryLimit: min(model.memoryRequirementMB, systemCapabilities.availableRAM),
            contextWindowSize: 4096,
            customInstructions: ""
        )
        
        return try createAgent(from: model, configuration: defaultConfig, systemCapabilities: systemCapabilities)
    }
    
    public func createAgent(
        from model: DiscoveredModel,
        configuration: AgentConfiguration,
        systemCapabilities: SystemCapabilityProfile
    ) throws -> ManagedAgent {
        
        // Validate inputs
        try validateSystemRequirements(model: model, systemCapabilities: systemCapabilities)
        try validateConfiguration(configuration)
        
        // Create managed agent
        let agent = ManagedAgent(
            id: UUID().uuidString,
            name: configuration.name,
            modelId: model.modelId,
            modelName: model.name,
            provider: model.provider,
            capabilities: model.capabilities,
            configuration: configuration,
            systemRequirements: AgentSystemRequirements(
                memoryRequirement: model.memoryRequirementMB,
                storageRequirement: Int(model.sizeBytes / (1024 * 1024)),
                cpuCores: max(1, systemCapabilities.cpuCores / 2)
            ),
            isActive: true,
            isConfigured: true,
            createdDate: Date(),
            lastUsed: Date()
        )
        
        // Store agent
        agents[agent.id] = agent
        
        // Initialize performance monitoring
        performanceMonitor.initializeMonitoring(for: agent.id)
        
        // Set as active if no active agent
        if activeAgentId == nil {
            activeAgentId = agent.id
        }
        
        return agent
    }
    
    // MARK: - Agent Configuration
    
    public func updateAgentConfiguration(agentId: String, configuration: AgentConfiguration) throws {
        guard var agent = agents[agentId] else {
            throw AgentManagementError.agentNotFound(agentId)
        }
        
        try validateConfiguration(configuration)
        
        agent.configuration = configuration
        agent.name = configuration.name
        agent.lastModified = Date()
        
        agents[agentId] = agent
    }
    
    public func getAgent(id: String) throws -> ManagedAgent {
        guard let agent = agents[id] else {
            throw AgentManagementError.agentNotFound(id)
        }
        return agent
    }
    
    public func getAllAgents() throws -> [ManagedAgent] {
        return Array(agents.values).sorted { $0.createdDate > $1.createdDate }
    }
    
    public func getActiveAgents() throws -> [ManagedAgent] {
        return agents.values.filter { $0.isActive }.sorted { $0.lastUsed > $1.lastUsed }
    }
    
    public func getAgentsBySpecialization(_ specialization: AgentSpecialization) throws -> [ManagedAgent] {
        return agents.values.filter { $0.configuration.specialization == specialization }
    }
    
    // MARK: - Agent Lifecycle
    
    public func activateAgent(id: String) throws {
        guard var agent = agents[id] else {
            throw AgentManagementError.agentNotFound(id)
        }
        
        agent.isActive = true
        agent.lastUsed = Date()
        agents[id] = agent
        
        // Set as active agent
        activeAgentId = id
    }
    
    public func deactivateAgent(id: String) throws {
        guard var agent = agents[id] else {
            throw AgentManagementError.agentNotFound(id)
        }
        
        agent.isActive = false
        agents[id] = agent
        
        // Clear active agent if this was it
        if activeAgentId == id {
            activeAgentId = try? getActiveAgents().first?.id
        }
    }
    
    public func deleteAgent(id: String) throws {
        guard agents[id] != nil else {
            throw AgentManagementError.agentNotFound(id)
        }
        
        // Clean up performance monitoring
        performanceMonitor.cleanupMonitoring(for: id)
        
        // Remove agent
        agents.removeValue(forKey: id)
        
        // Clear active agent if this was it
        if activeAgentId == id {
            activeAgentId = try? getActiveAgents().first?.id
        }
    }
    
    // MARK: - Agent Import/Export
    
    public func exportAgentConfiguration(id: String) throws -> Data {
        let agent = try getAgent(id: id)
        
        let exportData = AgentExportData(
            name: agent.name,
            configuration: agent.configuration,
            capabilities: agent.capabilities,
            exportDate: Date(),
            version: "1.0"
        )
        
        return try JSONEncoder().encode(exportData)
    }
    
    public func importAgentConfiguration(
        data: Data,
        model: DiscoveredModel,
        systemCapabilities: SystemCapabilityProfile
    ) throws -> ManagedAgent {
        
        let exportData = try JSONDecoder().decode(AgentExportData.self, from: data)
        
        return try createAgent(
            from: model,
            configuration: exportData.configuration,
            systemCapabilities: systemCapabilities
        )
    }
    
    // MARK: - Validation
    
    private func validateSystemRequirements(model: DiscoveredModel, systemCapabilities: SystemCapabilityProfile) throws {
        
        // Check memory requirements
        if model.memoryRequirementMB > systemCapabilities.availableRAM {
            throw AgentManagementError.insufficientResources(
                "Model requires \(model.memoryRequirementMB)MB RAM, but only \(systemCapabilities.availableRAM)MB available"
            )
        }
        
        // Check storage requirements
        let modelSizeMB = Int(model.sizeBytes / (1024 * 1024))
        if modelSizeMB > systemCapabilities.storageSpace {
            throw AgentManagementError.insufficientResources(
                "Model requires \(modelSizeMB)MB storage, but only \(systemCapabilities.storageSpace)MB available"
            )
        }
        
        // Check if model is installed
        if !model.isInstalled {
            throw AgentManagementError.modelNotInstalled(model.modelId)
        }
    }
    
    private func validateConfiguration(_ configuration: AgentConfiguration) throws {
        
        // Validate name
        if configuration.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw AgentManagementError.invalidConfiguration("Agent name cannot be empty")
        }
        
        // Validate creativity level
        if configuration.creativityLevel < 0.0 || configuration.creativityLevel > 1.0 {
            throw AgentManagementError.invalidConfiguration("Creativity level must be between 0.0 and 1.0")
        }
        
        // Validate memory limit
        if configuration.memoryLimit <= 0 {
            throw AgentManagementError.invalidConfiguration("Memory limit must be positive")
        }
        
        // Validate context window size
        if configuration.contextWindowSize <= 0 {
            throw AgentManagementError.invalidConfiguration("Context window size must be positive")
        }
    }
    
    // MARK: - Private Setup
    
    private func setupBindings() {
        // Monitor performance alerts
        performanceMonitor.alertPublisher
            .sink { [weak self] (alert: MLACSPerformanceAlert) in
                self?.handlePerformanceAlert(alert)
            }
            .store(in: &cancellables)
    }
    
    private func handlePerformanceAlert(_ alert: MLACSPerformanceAlert) {
        // Handle performance alerts (could notify UI, log, etc.)
        print("⚠️ Performance Alert for Agent \(alert.agentId): \(alert.message)")
    }
}

// MARK: - Agent Configuration Service

public class AgentConfigurationService {
    
    public init() {}
    
    public func validateConfiguration(_ configuration: AgentConfiguration) -> Bool {
        return !configuration.name.isEmpty &&
               configuration.creativityLevel >= 0.0 && configuration.creativityLevel <= 1.0 &&
               configuration.memoryLimit > 0 &&
               configuration.contextWindowSize > 0
    }
    
    public func optimizeConfigurationForSystem(_ configuration: AgentConfiguration, systemCapabilities: SystemCapabilityProfile) -> AgentConfiguration {
        
        var optimized = configuration
        
        // Optimize memory limit based on available RAM
        let recommendedMemory = min(configuration.memoryLimit, systemCapabilities.availableRAM * 8 / 10) // Use max 80% of available RAM
        optimized.memoryLimit = recommendedMemory
        
        // Optimize context window based on memory
        if recommendedMemory < 4000 {
            optimized.contextWindowSize = min(configuration.contextWindowSize, 2048)
        } else if recommendedMemory < 8000 {
            optimized.contextWindowSize = min(configuration.contextWindowSize, 4096)
        }
        
        return optimized
    }
}

// MARK: - Agent Profile Manager

public class AgentProfileManager {
    
    private var profiles: [String: AgentProfile] = [:]
    
    public init() {}
    
    public func saveProfile(_ profile: AgentProfile) throws {
        profiles[profile.id] = profile
    }
    
    public func getProfile(id: String) throws -> AgentProfile {
        guard let profile = profiles[id] else {
            throw AgentManagementError.profileNotFound(id)
        }
        return profile
    }
    
    public func getAllProfiles() -> [AgentProfile] {
        return Array(profiles.values).sorted { $0.lastUsed > $1.lastUsed }
    }
    
    public func searchProfiles(tags: [String]? = nil, specialization: AgentSpecialization? = nil, nameContains: String? = nil) throws -> [AgentProfile] {
        
        var filtered = Array(profiles.values)
        
        if let tags = tags {
            filtered = filtered.filter { profile in
                return tags.allSatisfy { tag in profile.tags.contains(tag) }
            }
        }
        
        if let specialization = specialization {
            filtered = filtered.filter { $0.configuration.specialization == specialization }
        }
        
        if let nameContains = nameContains {
            let searchTerm = nameContains.lowercased()
            filtered = filtered.filter { $0.name.lowercased().contains(searchTerm) }
        }
        
        return filtered.sorted { $0.lastUsed > $1.lastUsed }
    }
    
    public func deleteProfile(id: String) throws {
        guard profiles[id] != nil else {
            throw AgentManagementError.profileNotFound(id)
        }
        profiles.removeValue(forKey: id)
    }
}

// MARK: - Agent Performance Monitor

public class AgentPerformanceMonitor: ObservableObject {
    
    private var performanceData: [String: AgentPerformanceData] = [:]
    private var thresholds: [String: MLACSPerformanceThresholds] = [:]
    private var alerts: [String: [MLACSPerformanceAlert]] = [:]
    
    public let alertPublisher = PassthroughSubject<MLACSPerformanceAlert, Never>()
    
    public init() {}
    
    public func initializeMonitoring(for agentId: String) {
        performanceData[agentId] = AgentPerformanceData(
            agentId: agentId,
            totalQueries: 0,
            averageResponseTime: 0.0,
            averageConfidence: 0.0,
            errorCount: 0,
            totalResponseLength: 0,
            startTime: Date(),
            lastQueryTime: Date()
        )
        alerts[agentId] = []
    }
    
    public func recordQueryPerformance(
        agentId: String,
        query: String,
        responseTime: Double,
        responseLength: Int,
        confidence: Double,
        timestamp: Date
    ) {
        
        guard var data = performanceData[agentId] else { return }
        
        // Update metrics
        let newTotal = data.totalQueries + 1
        data.totalQueries = newTotal
        data.averageResponseTime = (data.averageResponseTime * Double(newTotal - 1) + responseTime) / Double(newTotal)
        data.averageConfidence = (data.averageConfidence * Double(newTotal - 1) + confidence) / Double(newTotal)
        data.totalResponseLength += responseLength
        data.lastQueryTime = timestamp
        
        performanceData[agentId] = data
        
        // Check thresholds
        checkPerformanceThresholds(agentId: agentId, responseTime: responseTime, confidence: confidence)
    }
    
    public func getPerformanceMetrics(for agentId: String) -> AgentPerformanceData {
        return performanceData[agentId] ?? AgentPerformanceData(
            agentId: agentId,
            totalQueries: 0,
            averageResponseTime: 0.0,
            averageConfidence: 0.0,
            errorCount: 0,
            totalResponseLength: 0,
            startTime: Date(),
            lastQueryTime: Date()
        )
    }
    
    public func setThresholds(for agentId: String, thresholds: MLACSPerformanceThresholds) {
        self.thresholds[agentId] = thresholds
    }
    
    public func getActiveAlerts(for agentId: String) -> [MLACSPerformanceAlert] {
        return alerts[agentId] ?? []
    }
    
    public func cleanupMonitoring(for agentId: String) {
        performanceData.removeValue(forKey: agentId)
        thresholds.removeValue(forKey: agentId)
        alerts.removeValue(forKey: agentId)
    }
    
    private func checkPerformanceThresholds(agentId: String, responseTime: Double, confidence: Double) {
        guard let thresholds = thresholds[agentId] else { return }
        
        var newAlerts: [MLACSPerformanceAlert] = []
        
        // Check response time
        if responseTime > thresholds.maxResponseTime {
            let alert = MLACSPerformanceAlert(
                id: UUID().uuidString,
                agentId: agentId,
                type: .slowResponse,
                message: "Response time (\(String(format: "%.1f", responseTime))s) exceeds threshold (\(String(format: "%.1f", thresholds.maxResponseTime))s)",
                severity: .warning,
                timestamp: Date()
            )
            newAlerts.append(alert)
        }
        
        // Check confidence
        if confidence < thresholds.minConfidenceScore {
            let alert = MLACSPerformanceAlert(
                id: UUID().uuidString,
                agentId: agentId,
                type: .lowConfidence,
                message: "Confidence score (\(String(format: "%.1f", confidence))) below threshold (\(String(format: "%.1f", thresholds.minConfidenceScore)))",
                severity: .warning,
                timestamp: Date()
            )
            newAlerts.append(alert)
        }
        
        // Store alerts and publish
        if !newAlerts.isEmpty {
            alerts[agentId, default: []].append(contentsOf: newAlerts)
            
            for alert in newAlerts {
                alertPublisher.send(alert)
            }
        }
    }
}

// MARK: - Supporting Types

public struct ManagedAgent {
    public let id: String
    public var name: String
    public let modelId: String
    public let modelName: String
    public let provider: String
    public let capabilities: [String]
    public var configuration: AgentConfiguration
    public let systemRequirements: AgentSystemRequirements
    public var isActive: Bool
    public var isConfigured: Bool
    public let createdDate: Date
    public var lastUsed: Date
    public var lastModified: Date
    
    public init(
        id: String,
        name: String,
        modelId: String,
        modelName: String,
        provider: String,
        capabilities: [String],
        configuration: AgentConfiguration,
        systemRequirements: AgentSystemRequirements,
        isActive: Bool,
        isConfigured: Bool,
        createdDate: Date,
        lastUsed: Date
    ) {
        self.id = id
        self.name = name
        self.modelId = modelId
        self.modelName = modelName
        self.provider = provider
        self.capabilities = capabilities
        self.configuration = configuration
        self.systemRequirements = systemRequirements
        self.isActive = isActive
        self.isConfigured = isConfigured
        self.createdDate = createdDate
        self.lastUsed = lastUsed
        self.lastModified = createdDate
    }
    
    public func getEnhancedCapabilities() -> [String] {
        var enhanced = capabilities
        
        // Add specialization-specific capabilities
        switch configuration.specialization {
        case .financial:
            enhanced.append(contentsOf: ["financial_analysis", "document_processing", "data_extraction"])
        case .creative:
            enhanced.append(contentsOf: ["creative_writing", "storytelling", "ideation"])
        case .coding:
            enhanced.append(contentsOf: ["code_generation", "debugging", "code_review"])
        case .research:
            enhanced.append(contentsOf: ["research", "fact_checking", "citation"])
        case .general:
            break
        }
        
        return Array(Set(enhanced)) // Remove duplicates
    }
    
    public func processQuery(_ query: String) throws -> AgentResponse {
        guard isActive && isConfigured else {
            throw AgentManagementError.agentNotActive(id)
        }
        
        // Simulate query processing based on configuration
        let processingTime = calculateProcessingTime(for: query)
        let confidence = calculateConfidence(for: query)
        let response = generateResponse(for: query)
        
        return AgentResponse(
            content: response,
            responseTime: processingTime,
            confidence: confidence,
            sources: [],
            agent: LocalAIAgent(modelName: modelName, capabilities: capabilities)
        )
    }
    
    private func calculateProcessingTime(for query: String) -> Double {
        let baseTime = 2.0
        let complexityMultiplier = 1.0 + (Double(query.count) / 500.0)
        let creativityMultiplier = 1.0 + configuration.creativityLevel * 0.5
        return baseTime * complexityMultiplier * creativityMultiplier
    }
    
    private func calculateConfidence(for query: String) -> Double {
        let baseConfidence = 0.7
        
        // Adjust for specialization match
        let queryLower = query.lowercased()
        let enhancedCapabilities = getEnhancedCapabilities()
        
        var specializationBonus = 0.0
        for capability in enhancedCapabilities {
            if queryLower.contains(capability.replacingOccurrences(of: "_", with: " ")) {
                specializationBonus += 0.1
            }
        }
        
        return min(1.0, baseConfidence + specializationBonus)
    }
    
    private func generateResponse(for query: String) -> String {
        let prefix = configuration.specialization != .general ? "[\(configuration.specialization.rawValue.capitalized)] " : ""
        return "\(prefix)Simulated response from \(name) for: \(query.prefix(50))..."
    }
}

public struct AgentConfiguration: Codable {
    public let name: String
    public let personality: AgentPersonality
    public let specialization: AgentSpecialization
    public let responseStyle: ResponseStyle
    public let creativityLevel: Double // 0.0 to 1.0
    public let safetyLevel: SafetyLevel
    public var memoryLimit: Int
    public var contextWindowSize: Int
    public let customInstructions: String
    
    public init(
        name: String,
        personality: AgentPersonality,
        specialization: AgentSpecialization,
        responseStyle: ResponseStyle,
        creativityLevel: Double,
        safetyLevel: SafetyLevel,
        memoryLimit: Int,
        contextWindowSize: Int,
        customInstructions: String
    ) {
        self.name = name
        self.personality = personality
        self.specialization = specialization
        self.responseStyle = responseStyle
        self.creativityLevel = creativityLevel
        self.safetyLevel = safetyLevel
        self.memoryLimit = memoryLimit
        self.contextWindowSize = contextWindowSize
        self.customInstructions = customInstructions
    }
}

public enum AgentPersonality: String, Codable, CaseIterable, Hashable {
    case professional = "professional"
    case friendly = "friendly"
    case creative = "creative"
    case technical = "technical"
    case casual = "casual"
}

public enum AgentSpecialization: String, Codable, CaseIterable, Hashable {
    case general = "general"
    case financial = "financial"
    case creative = "creative"
    case coding = "coding"
    case research = "research"
}

public enum ResponseStyle: String, Codable, CaseIterable {
    case concise = "concise"
    case detailed = "detailed"
    case balanced = "balanced"
    case engaging = "engaging"
    case precise = "precise"
}

public enum SafetyLevel: String, Codable, CaseIterable {
    case low = "low"
    case medium = "medium"
    case high = "high"
}

public struct AgentSystemRequirements {
    public let memoryRequirement: Int
    public let storageRequirement: Int
    public let cpuCores: Int
    
    public init(memoryRequirement: Int, storageRequirement: Int, cpuCores: Int) {
        self.memoryRequirement = memoryRequirement
        self.storageRequirement = storageRequirement
        self.cpuCores = cpuCores
    }
}

public struct AgentProfile: Codable {
    public let id: String
    public let name: String
    public let description: String
    public let configuration: AgentConfiguration
    public let tags: [String]
    public let isDefault: Bool
    public let createdDate: Date
    public var lastUsed: Date
    
    public init(
        name: String,
        description: String,
        configuration: AgentConfiguration,
        tags: [String],
        isDefault: Bool,
        createdDate: Date,
        lastUsed: Date
    ) {
        self.id = UUID().uuidString
        self.name = name
        self.description = description
        self.configuration = configuration
        self.tags = tags
        self.isDefault = isDefault
        self.createdDate = createdDate
        self.lastUsed = lastUsed
    }
}

public struct AgentPerformanceData {
    public let agentId: String
    public var totalQueries: Int
    public var averageResponseTime: Double
    public var averageConfidence: Double
    public var errorCount: Int
    public var totalResponseLength: Int
    public let startTime: Date
    public var lastQueryTime: Date
}

public struct MLACSPerformanceThresholds {
    public let maxResponseTime: Double
    public let minConfidenceScore: Double
    public let maxMemoryUsage: Int
    public let maxErrorRate: Double
    
    public init(maxResponseTime: Double, minConfidenceScore: Double, maxMemoryUsage: Int, maxErrorRate: Double) {
        self.maxResponseTime = maxResponseTime
        self.minConfidenceScore = minConfidenceScore
        self.maxMemoryUsage = maxMemoryUsage
        self.maxErrorRate = maxErrorRate
    }
}

public struct MLACSPerformanceAlert {
    public let id: String
    public let agentId: String
    public let type: MLACSPerformanceAlert.AlertType
    public let message: String
    public let severity: MLACSPerformanceAlert.AlertSeverity
    public let timestamp: Date
    
    public enum AlertType {
        case slowResponse
        case lowConfidence
        case highMemoryUsage
        case highErrorRate
    }
    
    public enum AlertSeverity {
        case info
        case warning
        case error
    }
}

public struct AgentExportData: Codable {
    public let name: String
    public let configuration: AgentConfiguration
    public let capabilities: [String]
    public let exportDate: Date
    public let version: String
}

public enum AgentManagementError: Error, LocalizedError {
    case agentNotFound(String)
    case agentNotActive(String)
    case modelNotInstalled(String)
    case insufficientResources(String)
    case invalidConfiguration(String)
    case profileNotFound(String)
    
    public var errorDescription: String? {
        switch self {
        case .agentNotFound(let id):
            return "Agent not found: \(id)"
        case .agentNotActive(let id):
            return "Agent is not active: \(id)"
        case .modelNotInstalled(let modelId):
            return "Model not installed: \(modelId)"
        case .insufficientResources(let message):
            return "Insufficient resources: \(message)"
        case .invalidConfiguration(let message):
            return "Invalid configuration: \(message)"
        case .profileNotFound(let id):
            return "Profile not found: \(id)"
        }
    }
}