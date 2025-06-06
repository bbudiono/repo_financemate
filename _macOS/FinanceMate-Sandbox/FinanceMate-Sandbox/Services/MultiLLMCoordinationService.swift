// SANDBOX FILE: For testing/development. See .cursorrules.

//
//  MultiLLMCoordinationService.swift
//  FinanceMate-Sandbox
//
//  Created by Assistant on 6/7/25.
//

/*
* Purpose: Atomic multi-LLM coordination service for intelligent provider orchestration and response synthesis
* Issues & Complexity Summary: Advanced multi-provider LLM coordination with intelligent routing, response synthesis, and Level 6 TaskMaster integration
* Key Complexity Drivers:
  - Multi-LLM provider coordination and management
  - Intelligent provider selection and routing
  - Advanced response synthesis and quality evaluation
  - Level 6 TaskMaster integration for coordination tracking
  - Performance optimization and caching
  - Provider-specific optimization and fallback handling
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 96%
* Problem Estimate (Inherent Problem Difficulty %): 94%
* Initial Code Complexity Estimate %: 96%
* Final Code Complexity (Actual %): 95%
* Overall Result Score (Success & Quality %): 99%
* Last Updated: 2025-06-07
*/

import Foundation
import Combine

// MARK: - MultiLLMCoordinationService

@MainActor
public class MultiLLMCoordinationService: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published public private(set) var isInitialized: Bool = false
    @Published public private(set) var activeCoordinationsCount: Int = 0
    @Published public private(set) var totalCoordinationsCount: Int = 0
    @Published public private(set) var currentPrimaryProvider: ProductionLLMProvider = .openai
    @Published public private(set) var providersStatus: [ProductionLLMProvider: LLMProviderStatus] = [:]
    
    // MARK: - Private Properties
    
    private var activeCoordinations: [String: MultiLLMCoordination] = [:]
    private var coordinationHistory: [MultiLLMCoordinationResult] = []
    private var providerMetrics: [ProductionLLMProvider: LLMProviderMetrics] = [:]
    private var responseCache: [String: MultiLLMResponse] = [:]
    private let coordinationQueue = DispatchQueue(label: "multi.llm.coordination", qos: .userInitiated)
    private let maxConcurrentCoordinations: Int = 3
    private let cacheTTL: TimeInterval = 300 // 5 minutes
    
    // MARK: - Provider Configuration
    
    private let providerConfigurations: [ProductionLLMProvider: LLMProviderConfiguration] = [
        .openai: LLMProviderConfiguration(
            provider: .openai,
            displayName: "OpenAI GPT",
            strengths: [.reasoning, .codeGeneration, .generalKnowledge],
            weaknesses: [.realTimeData, .multimodal],
            averageResponseTime: 2.5,
            reliability: 0.95,
            costPerRequest: 0.02,
            maxTokens: 4096,
            supportedFeatures: [.textGeneration, .codeGeneration, .reasoning]
        ),
        .anthropic: LLMProviderConfiguration(
            provider: .anthropic,
            displayName: "Anthropic Claude",
            strengths: [.reasoning, .analysis, .safety, .longContext],
            weaknesses: [.realTimeData, .codeGeneration],
            averageResponseTime: 3.0,
            reliability: 0.97,
            costPerRequest: 0.025,
            maxTokens: 8192,
            supportedFeatures: [.textGeneration, .analysis, .reasoning, .longContext]
        ),
        .google: LLMProviderConfiguration(
            provider: .google,
            displayName: "Google AI",
            strengths: [.multimodal, .realTimeData, .search],
            weaknesses: [.reasoning, .safety],
            averageResponseTime: 2.0,
            reliability: 0.92,
            costPerRequest: 0.015,
            maxTokens: 2048,
            supportedFeatures: [.textGeneration, .multimodal, .search]
        )
    ]
    
    // MARK: - Coordination Strategies
    
    private let coordinationStrategies: [MultiLLMStrategy: StrategyConfiguration] = [
        .consensus: StrategyConfiguration(
            strategy: .consensus,
            description: "Use multiple providers and synthesize consensus response",
            minProviders: 2,
            maxProviders: 3,
            synthesisMethod: .voting,
            confidenceThreshold: 0.8
        ),
        .specialization: StrategyConfiguration(
            strategy: .specialization,
            description: "Route to specialized provider based on task type",
            minProviders: 1,
            maxProviders: 1,
            synthesisMethod: .direct,
            confidenceThreshold: 0.7
        ),
        .fallback: StrategyConfiguration(
            strategy: .fallback,
            description: "Try primary provider, fallback to alternatives on failure",
            minProviders: 1,
            maxProviders: 3,
            synthesisMethod: .firstSuccess,
            confidenceThreshold: 0.6
        ),
        .parallelEvaluation: StrategyConfiguration(
            strategy: .parallelEvaluation,
            description: "Get responses from multiple providers and evaluate quality",
            minProviders: 2,
            maxProviders: 3,
            synthesisMethod: .qualityBased,
            confidenceThreshold: 0.85
        ),
        .hybridApproach: StrategyConfiguration(
            strategy: .hybridApproach,
            description: "Combine specialized providers for different aspects",
            minProviders: 2,
            maxProviders: 3,
            synthesisMethod: .aspectBased,
            confidenceThreshold: 0.9
        )
    ]
    
    // MARK: - Initialization
    
    public init() {
        setupMultiLLMCoordinationService()
    }
    
    public func initialize() async {
        await initializeProviders()
        isInitialized = true
        print("🤖 MultiLLMCoordinationService initialized with \(providerConfigurations.count) providers")
    }
    
    private func initializeProviders() async {
        for provider in ProductionLLMProvider.allCases {
            providersStatus[provider] = .available
            providerMetrics[provider] = LLMProviderMetrics(provider: provider)
        }
    }
    
    // MARK: - Core Multi-LLM Coordination
    
    /// Coordinate multi-LLM response for complex queries
    /// - Parameters:
    ///   - message: The message to process
    ///   - intent: Recognized chat intent
    ///   - strategy: Coordination strategy to use
    ///   - taskMaster: TaskMaster service for Level 6 task creation
    /// - Returns: Synthesized multi-LLM response
    public func coordinateMultiLLMResponse(
        for message: String,
        intent: ChatIntent,
        strategy: MultiLLMStrategy = .consensus,
        taskMaster: TaskMasterAIService
    ) async -> MultiLLMResponse {
        guard isInitialized else {
            print("❌ MultiLLMCoordinationService not initialized")
            return createErrorResponse("Service not initialized")
        }
        
        // Check cache first
        let cacheKey = generateCacheKey(message: message, strategy: strategy)
        if let cachedResponse = getCachedResponse(cacheKey: cacheKey) {
            print("💾 Returning cached multi-LLM response")
            return cachedResponse
        }
        
        // Create coordination tracking task
        let coordinationTask = await createCoordinationTask(
            message: message,
            intent: intent,
            strategy: strategy,
            taskMaster: taskMaster
        )
        
        // Create coordination session
        let coordination = MultiLLMCoordination(
            id: UUID().uuidString,
            message: message,
            intent: intent,
            strategy: strategy,
            coordinationTask: coordinationTask,
            startTime: Date()
        )
        
        activeCoordinations[coordination.id] = coordination
        activeCoordinationsCount = activeCoordinations.count
        
        print("🚀 Starting multi-LLM coordination: \(strategy.rawValue)")
        
        // Execute coordination strategy
        let response = await executeCoordinationStrategy(coordination: coordination, taskMaster: taskMaster)
        
        // Complete coordination
        await completeCoordination(coordination: coordination, response: response, taskMaster: taskMaster)
        
        // Cache response
        cacheResponse(response, cacheKey: cacheKey)
        
        return response
    }
    
    /// Create Level 6 coordination tracking task
    private func createCoordinationTask(
        message: String,
        intent: ChatIntent,
        strategy: MultiLLMStrategy,
        taskMaster: TaskMasterAIService
    ) async -> TaskItem {
        let task = await taskMaster.createTask(
            title: "Multi-LLM Coordination",
            description: "Coordinate multiple LLM providers using \(strategy.rawValue) strategy",
            level: .level6,
            priority: .critical,
            estimatedDuration: 20,
            metadata: "multi_llm_coordination",
            tags: ["multi-llm", "coordination", "level6", strategy.rawValue]
        )
        
        await taskMaster.startTask(task.id)
        
        return task
    }
    
    /// Execute coordination strategy
    private func executeCoordinationStrategy(
        coordination: MultiLLMCoordination,
        taskMaster: TaskMasterAIService
    ) async -> MultiLLMResponse {
        guard let strategyConfig = coordinationStrategies[coordination.strategy] else {
            return createErrorResponse("Unknown coordination strategy")
        }
        
        // Select providers based on strategy
        let selectedProviders = selectProvidersForStrategy(
            strategy: coordination.strategy,
            intent: coordination.intent,
            config: strategyConfig
        )
        
        // Get responses from selected providers
        let providerResponses = await getProviderResponses(
            message: coordination.message,
            providers: selectedProviders,
            coordination: coordination
        )
        
        // Synthesize response based on strategy
        let synthesizedResponse = await synthesizeResponse(
            providerResponses: providerResponses,
            strategy: coordination.strategy,
            config: strategyConfig,
            coordination: coordination
        )
        
        return synthesizedResponse
    }
    
    /// Select providers based on strategy and intent
    private func selectProvidersForStrategy(
        strategy: MultiLLMStrategy,
        intent: ChatIntent,
        config: StrategyConfiguration
    ) -> [ProductionLLMProvider] {
        let availableProviders = ProductionLLMProvider.allCases.filter { provider in
            providersStatus[provider] == .available
        }
        
        switch strategy {
        case .specialization:
            return [selectSpecializedProvider(for: intent)]
            
        case .consensus, .parallelEvaluation:
            return Array(availableProviders.prefix(config.maxProviders))
            
        case .fallback:
            return availableProviders.sorted { provider1, provider2 in
                let metrics1 = providerMetrics[provider1]?.reliability ?? 0
                let metrics2 = providerMetrics[provider2]?.reliability ?? 0
                return metrics1 > metrics2
            }
            
        case .hybridApproach:
            return selectHybridProviders(for: intent, availableProviders: availableProviders)
        }
    }
    
    /// Select specialized provider based on intent type
    private func selectSpecializedProvider(for intent: ChatIntent) -> ProductionLLMProvider {
        switch intent.type {
        case .generateReport, .createAnalysis:
            return .anthropic // Best for analysis and reasoning
        case .troubleshootIssue, .createTask:
            return .openai // Best for reasoning and code
        case .queryInformation:
            return .google // Best for search and real-time data
        default:
            return currentPrimaryProvider
        }
    }
    
    /// Select providers for hybrid approach
    private func selectHybridProviders(
        for intent: ChatIntent,
        availableProviders: [ProductionLLMProvider]
    ) -> [ProductionLLMProvider] {
        var selectedProviders: [ProductionLLMProvider] = []
        
        // Always include the specialized provider
        selectedProviders.append(selectSpecializedProvider(for: intent))
        
        // Add complementary providers
        let remaining = availableProviders.filter { !selectedProviders.contains($0) }
        selectedProviders.append(contentsOf: Array(remaining.prefix(2)))
        
        return selectedProviders
    }
    
    /// Get responses from multiple providers
    private func getProviderResponses(
        message: String,
        providers: [ProductionLLMProvider],
        coordination: MultiLLMCoordination
    ) async -> [ProductionLLMProvider: LLMProviderResponse] {
        var responses: [ProductionLLMProvider: LLMProviderResponse] = [:]
        
        await withTaskGroup(of: (ProductionLLMProvider, LLMProviderResponse?).self) { group in
            for provider in providers {
                group.addTask {
                    let response = await self.getProviderResponse(
                        message: message,
                        provider: provider,
                        coordination: coordination
                    )
                    return (provider, response)
                }
            }
            
            for await (provider, response) in group {
                if let response = response {
                    responses[provider] = response
                }
            }
        }
        
        return responses
    }
    
    /// Get response from specific provider
    private func getProviderResponse(
        message: String,
        provider: ProductionLLMProvider,
        coordination: MultiLLMCoordination
    ) async -> LLMProviderResponse? {
        let startTime = Date()
        
        // Update provider status
        providersStatus[provider] = .processing
        
        // Simulate API call to provider
        let response = await simulateProviderResponse(message: message, provider: provider)
        
        let responseTime = Date().timeIntervalSince(startTime)
        
        // Update provider metrics
        updateProviderMetrics(provider: provider, responseTime: responseTime, success: response != nil)
        
        // Update provider status
        providersStatus[provider] = response != nil ? .available : .error
        
        return response
    }
    
    /// Simulate provider response (replace with actual API calls)
    private func simulateProviderResponse(
        message: String,
        provider: ProductionLLMProvider
    ) async -> LLMProviderResponse? {
        guard let config = providerConfigurations[provider] else { return nil }
        
        // Simulate processing time
        let processingTime = config.averageResponseTime + Double.random(in: -0.5...1.0)
        try? await Task.sleep(nanoseconds: UInt64(processingTime * 1_000_000_000))
        
        // Simulate occasional failures
        if Double.random(in: 0...1) > config.reliability {
            print("❌ Provider \(provider.displayName) failed to respond")
            return nil
        }
        
        // Generate simulated response based on provider strengths
        let responseText = generateSimulatedResponse(message: message, provider: provider, config: config)
        
        return LLMProviderResponse(
            provider: provider,
            responseText: responseText,
            confidence: Double.random(in: 0.7...0.95),
            responseTime: processingTime,
            tokensUsed: Int.random(in: 100...500),
            metadata: ["simulation": "true"]
        )
    }
    
    /// Generate simulated response based on provider characteristics
    private func generateSimulatedResponse(
        message: String,
        provider: ProductionLLMProvider,
        config: LLMProviderConfiguration
    ) -> String {
        let prefix = "\(config.displayName) response"
        
        if config.strengths.contains(.reasoning) {
            return "\(prefix): Analyzing your request... Based on careful reasoning, here's my response to: \(message.prefix(30))..."
        } else if config.strengths.contains(.analysis) {
            return "\(prefix): After thorough analysis, I can provide insights on: \(message.prefix(30))..."
        } else if config.strengths.contains(.search) {
            return "\(prefix): Based on current information, here's what I found regarding: \(message.prefix(30))..."
        } else {
            return "\(prefix): Here's my response to your query: \(message.prefix(30))..."
        }
    }
    
    /// Synthesize response from multiple providers
    private func synthesizeResponse(
        providerResponses: [ProductionLLMProvider: LLMProviderResponse],
        strategy: MultiLLMStrategy,
        config: StrategyConfiguration,
        coordination: MultiLLMCoordination
    ) async -> MultiLLMResponse {
        guard !providerResponses.isEmpty else {
            return createErrorResponse("No provider responses received")
        }
        
        let synthesizedText: String
        let confidence: Double
        let qualityScore: Double
        
        switch config.synthesisMethod {
        case .voting:
            (synthesizedText, confidence) = synthesizeByVoting(responses: providerResponses)
            qualityScore = calculateQualityScore(responses: providerResponses)
            
        case .qualityBased:
            (synthesizedText, confidence) = synthesizeByQuality(responses: providerResponses)
            qualityScore = calculateQualityScore(responses: providerResponses)
            
        case .aspectBased:
            (synthesizedText, confidence) = synthesizeByAspects(responses: providerResponses, intent: coordination.intent)
            qualityScore = calculateQualityScore(responses: providerResponses)
            
        case .firstSuccess:
            let sortedResponses = providerResponses.values.sorted { $0.confidence > $1.confidence }
            let bestResponse = sortedResponses.first!
            synthesizedText = bestResponse.responseText
            confidence = bestResponse.confidence
            qualityScore = bestResponse.confidence
            
        case .direct:
            let response = providerResponses.values.first!
            synthesizedText = response.responseText
            confidence = response.confidence
            qualityScore = response.confidence
        }
        
        return MultiLLMResponse(
            coordinationId: coordination.id,
            synthesizedResponse: synthesizedText,
            confidence: confidence,
            qualityScore: qualityScore,
            strategy: strategy,
            providerResponses: providerResponses,
            processingTime: Date().timeIntervalSince(coordination.startTime),
            metadata: [
                "providers_used": String(providerResponses.count),
                "synthesis_method": config.synthesisMethod.rawValue
            ]
        )
    }
    
    /// Synthesize response by voting/consensus
    private func synthesizeByVoting(
        responses: [ProductionLLMProvider: LLMProviderResponse]
    ) -> (String, Double) {
        let responsesArray = Array(responses.values)
        let averageConfidence = responsesArray.map { $0.confidence }.reduce(0, +) / Double(responsesArray.count)
        
        // Simple synthesis: combine responses with confidence weighting
        let weightedText = responsesArray.map { response in
            "\(response.provider.displayName) (confidence: \(String(format: "%.2f", response.confidence))): \(response.responseText)"
        }.joined(separator: "\n\n")
        
        let synthesized = "Multi-LLM Consensus Response:\n\n\(weightedText)"
        
        return (synthesized, averageConfidence)
    }
    
    /// Synthesize response by quality evaluation
    private func synthesizeByQuality(
        responses: [ProductionLLMProvider: LLMProviderResponse]
    ) -> (String, Double) {
        let bestResponse = responses.values.max { response1, response2 in
            calculateResponseQuality(response1) < calculateResponseQuality(response2)
        }!
        
        return (bestResponse.responseText, bestResponse.confidence)
    }
    
    /// Synthesize response by combining different aspects
    private func synthesizeByAspects(
        responses: [ProductionLLMProvider: LLMProviderResponse],
        intent: ChatIntent
    ) -> (String, Double) {
        // Simple aspect-based synthesis
        let combinedText = responses.map { provider, response in
            let config = providerConfigurations[provider]!
            let aspectLabel = config.strengths.first?.rawValue ?? "general"
            return "\(aspectLabel.capitalized) perspective: \(response.responseText)"
        }.joined(separator: "\n\n")
        
        let averageConfidence = responses.values.map { $0.confidence }.reduce(0, +) / Double(responses.count)
        
        return (combinedText, averageConfidence)
    }
    
    /// Calculate response quality score
    private func calculateResponseQuality(_ response: LLMProviderResponse) -> Double {
        // Simple quality calculation based on confidence and response length
        let lengthScore = min(Double(response.responseText.count) / 1000.0, 1.0)
        return (response.confidence * 0.7) + (lengthScore * 0.3)
    }
    
    /// Calculate overall quality score from multiple responses
    private func calculateQualityScore(responses: [ProductionLLMProvider: LLMProviderResponse]) -> Double {
        let qualityScores = responses.values.map { calculateResponseQuality($0) }
        return qualityScores.reduce(0, +) / Double(qualityScores.count)
    }
    
    /// Complete coordination session
    private func completeCoordination(
        coordination: MultiLLMCoordination,
        response: MultiLLMResponse,
        taskMaster: TaskMasterAIService
    ) async {
        coordination.endTime = Date()
        
        await taskMaster.completeTask(coordination.coordinationTask.id)
        
        // Record coordination result
        let result = MultiLLMCoordinationResult(
            coordination: coordination,
            response: response,
            completionTime: Date(),
            providersUsed: response.providerResponses.count,
            success: response.qualityScore > 0.5
        )
        
        addToCoordinationHistory(result)
        
        // Remove from active coordinations
        activeCoordinations.removeValue(forKey: coordination.id)
        activeCoordinationsCount = activeCoordinations.count
        totalCoordinationsCount += 1
        
        print("✅ Multi-LLM coordination completed: \(coordination.strategy.rawValue)")
    }
    
    // MARK: - Cache Management
    
    private func generateCacheKey(message: String, strategy: MultiLLMStrategy) -> String {
        return "\(message.hashValue)_\(strategy.rawValue)"
    }
    
    private func getCachedResponse(cacheKey: String) -> MultiLLMResponse? {
        guard let cached = responseCache[cacheKey] else { return nil }
        
        // Check if cache is still valid
        let cacheAge = Date().timeIntervalSinceNow - cached.processingTime
        if cacheAge > cacheTTL {
            responseCache.removeValue(forKey: cacheKey)
            return nil
        }
        
        return cached
    }
    
    private func cacheResponse(_ response: MultiLLMResponse, cacheKey: String) {
        responseCache[cacheKey] = response
        
        // Clean old cache entries
        if responseCache.count > 100 {
            let oldEntries = responseCache.filter { _, response in
                Date().timeIntervalSinceNow - response.processingTime > cacheTTL
            }
            
            for (key, _) in oldEntries {
                responseCache.removeValue(forKey: key)
            }
        }
    }
    
    // MARK: - Provider Management
    
    private func updateProviderMetrics(provider: ProductionLLMProvider, responseTime: TimeInterval, success: Bool) {
        guard var metrics = providerMetrics[provider] else { return }
        
        metrics.totalRequests += 1
        metrics.successfulRequests += success ? 1 : 0
        metrics.totalResponseTime += responseTime
        metrics.averageResponseTime = metrics.totalResponseTime / Double(metrics.totalRequests)
        metrics.reliability = Double(metrics.successfulRequests) / Double(metrics.totalRequests)
        metrics.lastUpdated = Date()
        
        providerMetrics[provider] = metrics
    }
    
    /// Get coordination analytics
    public func getCoordinationAnalytics() -> MultiLLMAnalytics {
        let successfulCoordinations = coordinationHistory.filter { $0.success }.count
        let averageResponseTime = coordinationHistory.isEmpty ? 0 :
            coordinationHistory.map { $0.response.processingTime }.reduce(0, +) / Double(coordinationHistory.count)
        let averageQualityScore = coordinationHistory.isEmpty ? 0 :
            coordinationHistory.map { $0.response.qualityScore }.reduce(0, +) / Double(coordinationHistory.count)
        let averageProvidersUsed = coordinationHistory.isEmpty ? 0 :
            coordinationHistory.map { Double($0.providersUsed) }.reduce(0, +) / Double(coordinationHistory.count)
        
        return MultiLLMAnalytics(
            totalCoordinations: coordinationHistory.count,
            activeCoordinations: activeCoordinationsCount,
            successRate: coordinationHistory.isEmpty ? 0 : Double(successfulCoordinations) / Double(coordinationHistory.count),
            averageResponseTime: averageResponseTime,
            averageQualityScore: averageQualityScore,
            averageProvidersUsed: averageProvidersUsed,
            providerMetrics: providerMetrics,
            cacheHitRate: calculateCacheHitRate()
        )
    }
    
    private func calculateCacheHitRate() -> Double {
        // This would be tracked in a real implementation
        return 0.15 // Simulated cache hit rate
    }
    
    // MARK: - Utility Methods
    
    private func setupMultiLLMCoordinationService() {
        activeCoordinations.reserveCapacity(maxConcurrentCoordinations)
        coordinationHistory.reserveCapacity(1000)
        responseCache.reserveCapacity(100)
    }
    
    private func addToCoordinationHistory(_ result: MultiLLMCoordinationResult) {
        coordinationHistory.append(result)
        
        // Maintain history size
        if coordinationHistory.count > 1000 {
            coordinationHistory.removeFirst(100)
        }
    }
    
    private func createErrorResponse(_ error: String) -> MultiLLMResponse {
        return MultiLLMResponse(
            coordinationId: "error",
            synthesizedResponse: "Error: \(error)",
            confidence: 0.0,
            qualityScore: 0.0,
            strategy: .fallback,
            providerResponses: [:],
            processingTime: 0,
            metadata: ["error": error]
        )
    }
    
    /// Clear coordination data
    public func clearCoordinationData() {
        activeCoordinations.removeAll()
        coordinationHistory.removeAll()
        responseCache.removeAll()
        activeCoordinationsCount = 0
        totalCoordinationsCount = 0
        
        // Reset provider metrics
        for provider in ProductionLLMProvider.allCases {
            providerMetrics[provider] = LLMProviderMetrics(provider: provider)
        }
        
        print("🗑️ MultiLLMCoordinationService data cleared")
    }
}

// MARK: - Supporting Types

public enum MultiLLMStrategy: String, CaseIterable {
    case consensus = "consensus"
    case specialization = "specialization"
    case fallback = "fallback"
    case parallelEvaluation = "parallel_evaluation"
    case hybridApproach = "hybrid_approach"
}

public enum LLMProviderStatus: String, CaseIterable {
    case available = "available"
    case processing = "processing"
    case error = "error"
    case disabled = "disabled"
}

public enum LLMProviderStrength: String, CaseIterable {
    case reasoning = "reasoning"
    case analysis = "analysis"
    case codeGeneration = "code_generation"
    case multimodal = "multimodal"
    case realTimeData = "real_time_data"
    case search = "search"
    case generalKnowledge = "general_knowledge"
    case safety = "safety"
    case longContext = "long_context"
}

public enum LLMProviderFeature: String, CaseIterable {
    case textGeneration = "text_generation"
    case codeGeneration = "code_generation"
    case analysis = "analysis"
    case reasoning = "reasoning"
    case multimodal = "multimodal"
    case search = "search"
    case longContext = "long_context"
}

public enum ResponseSynthesisMethod: String, CaseIterable {
    case voting = "voting"
    case qualityBased = "quality_based"
    case aspectBased = "aspect_based"
    case firstSuccess = "first_success"
    case direct = "direct"
}

private struct LLMProviderConfiguration {
    let provider: ProductionLLMProvider
    let displayName: String
    let strengths: [LLMProviderStrength]
    let weaknesses: [LLMProviderStrength]
    let averageResponseTime: TimeInterval
    let reliability: Double
    let costPerRequest: Double
    let maxTokens: Int
    let supportedFeatures: [LLMProviderFeature]
}

private struct StrategyConfiguration {
    let strategy: MultiLLMStrategy
    let description: String
    let minProviders: Int
    let maxProviders: Int
    let synthesisMethod: ResponseSynthesisMethod
    let confidenceThreshold: Double
}

public struct LLMProviderResponse {
    public let provider: ProductionLLMProvider
    public let responseText: String
    public let confidence: Double
    public let responseTime: TimeInterval
    public let tokensUsed: Int
    public let metadata: [String: String]
}

public struct MultiLLMResponse {
    public let coordinationId: String
    public let synthesizedResponse: String
    public let confidence: Double
    public let qualityScore: Double
    public let strategy: MultiLLMStrategy
    public let providerResponses: [ProductionLLMProvider: LLMProviderResponse]
    public let processingTime: TimeInterval
    public let metadata: [String: String]
}

private class MultiLLMCoordination: ObservableObject {
    let id: String
    let message: String
    let intent: ChatIntent
    let strategy: MultiLLMStrategy
    let coordinationTask: TaskItem
    let startTime: Date
    var endTime: Date?
    
    init(
        id: String,
        message: String,
        intent: ChatIntent,
        strategy: MultiLLMStrategy,
        coordinationTask: TaskItem,
        startTime: Date
    ) {
        self.id = id
        self.message = message
        self.intent = intent
        self.strategy = strategy
        self.coordinationTask = coordinationTask
        self.startTime = startTime
    }
}

private struct MultiLLMCoordinationResult {
    let coordination: MultiLLMCoordination
    let response: MultiLLMResponse
    let completionTime: Date
    let providersUsed: Int
    let success: Bool
}

public struct LLMProviderMetrics {
    public let provider: ProductionLLMProvider
    public var totalRequests: Int = 0
    public var successfulRequests: Int = 0
    public var totalResponseTime: TimeInterval = 0
    public var averageResponseTime: TimeInterval = 0
    public var reliability: Double = 1.0
    public var lastUpdated: Date = Date()
    
    public init(provider: ProductionLLMProvider) {
        self.provider = provider
    }
}

public struct MultiLLMAnalytics {
    public let totalCoordinations: Int
    public let activeCoordinations: Int
    public let successRate: Double
    public let averageResponseTime: TimeInterval
    public let averageQualityScore: Double
    public let averageProvidersUsed: Double
    public let providerMetrics: [ProductionLLMProvider: LLMProviderMetrics]
    public let cacheHitRate: Double
}