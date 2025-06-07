// SANDBOX FILE: For testing/development. See .cursorrules.

//
//  MLACSSingleAgentModeTests.swift
//  FinanceMate-SandboxTests
//
//  Created by Assistant on 6/7/25.
//

/*
* Purpose: TDD tests for MLACS Single Agent Mode implementation
* Features: Hardware analysis, model recommendations, upgrade suggestions, local model setup
* NO MOCK DATA: Tests use real system analysis and model discovery
*/

import XCTest
@testable import FinanceMate_Sandbox

final class MLACSSingleAgentModeTests: XCTestCase {
    
    var singleAgentMode: MLACSSingleAgentMode!
    var systemAnalyzer: SystemCapabilityAnalyzer!
    var modelRecommendationEngine: LocalModelRecommendationEngine!
    var upgradeSubgestionEngine: UpgradeSuggestionEngine!
    
    @MainActor override func setUpWithError() throws {
        try super.setUpWithError()
        systemAnalyzer = SystemCapabilityAnalyzer()
        modelRecommendationEngine = LocalModelRecommendationEngine(systemAnalyzer: systemAnalyzer)
        upgradeSubgestionEngine = UpgradeSuggestionEngine()
        singleAgentMode = MLACSSingleAgentMode(
            systemAnalyzer: systemAnalyzer,
            modelEngine: modelRecommendationEngine,
            upgradeEngine: upgradeSubgestionEngine
        )
    }
    
    @MainActor override func tearDownWithError() throws {
        singleAgentMode = nil
        systemAnalyzer = nil
        modelRecommendationEngine = nil
        upgradeSubgestionEngine = nil
        try super.tearDownWithError()
    }
    
    // MARK: - System Capability Analysis Tests
    
    @MainActor func testSystemCapabilityAnalysis() throws {
        // Given: System analyzer is available
        XCTAssertNotNil(systemAnalyzer, "System analyzer should be initialized")
        
        // When: Analyzing system capabilities
        let capabilities = try systemAnalyzer.analyzeSystemCapabilities()
        
        // Then: Should return valid system profile
        XCTAssertNotNil(capabilities, "Should return system capabilities")
        XCTAssertGreaterThan(capabilities.totalRAM, 0, "Should detect system RAM")
        XCTAssertGreaterThan(capabilities.cpuCores, 0, "Should detect CPU cores")
        XCTAssertNotNil(capabilities.performanceClass, "Should determine performance class")
        XCTAssertTrue(["low", "medium", "high", "extreme"].contains(capabilities.performanceClass.rawValue))
    }
    
    @MainActor func testPerformanceClassClassification() throws {
        // Given: Different RAM configurations
        let lowEndSystem = SystemCapabilityProfile(
            cpuCores: 2, totalRAM: 4000, availableRAM: 2000, gpuMemory: 0,
            storageSpace: 100000, internetSpeed: 10, powerConstraints: .laptop,
            performanceClass: .low
        )
        
        let highEndSystem = SystemCapabilityProfile(
            cpuCores: 12, totalRAM: 32000, availableRAM: 24000, gpuMemory: 16000,
            storageSpace: 1000000, internetSpeed: 1000, powerConstraints: .desktop,
            performanceClass: .high
        )
        
        // When: Getting model recommendations for different systems
        let lowEndRecommendations = try modelRecommendationEngine.recommendOptimalModels(systemProfile: lowEndSystem)
        let highEndRecommendations = try modelRecommendationEngine.recommendOptimalModels(systemProfile: highEndSystem)
        
        // Then: Should provide appropriate recommendations
        XCTAssertFalse(lowEndRecommendations.isEmpty, "Should provide recommendations for low-end system")
        XCTAssertFalse(highEndRecommendations.isEmpty, "Should provide recommendations for high-end system")
        
        // Low-end system should get smaller models
        let lowEndTopModel = lowEndRecommendations.first!
        XCTAssertLessThanOrEqual(lowEndTopModel.model.parameterCount, 7_000_000_000, "Low-end should get smaller models")
        
        // High-end system should get more capable models
        let highEndTopModel = highEndRecommendations.first!
        XCTAssertGreaterThanOrEqual(highEndTopModel.model.parameterCount, 7_000_000_000, "High-end should get larger models")
    }
    
    // MARK: - Model Recommendation Tests
    
    @MainActor func testModelCategorization() throws {
        // Given: Model recommendation engine
        XCTAssertNotNil(modelRecommendationEngine, "Model recommendation engine should be initialized")
        
        // When: Getting categorized models
        let categorizedModels = try modelRecommendationEngine.getCategorizedModels()
        
        // Then: Should have all categories with appropriate models
        XCTAssertFalse(categorizedModels.ultraLight.recommended.isEmpty, "Should have ultra-light models")
        XCTAssertFalse(categorizedModels.lightweight.recommended.isEmpty, "Should have lightweight models")
        XCTAssertFalse(categorizedModels.balanced.recommended.isEmpty, "Should have balanced models")
        XCTAssertFalse(categorizedModels.highPerformance.recommended.isEmpty, "Should have high-performance models")
        
        // Verify parameter count progression
        let ultraLightModel = categorizedModels.ultraLight.recommended.first!
        let lightweightModel = categorizedModels.lightweight.recommended.first!
        let balancedModel = categorizedModels.balanced.recommended.first!
        
        XCTAssertLessThan(ultraLightModel.parameterCount, lightweightModel.parameterCount, "Ultra-light should be smaller than lightweight")
        XCTAssertLessThan(lightweightModel.parameterCount, balancedModel.parameterCount, "Lightweight should be smaller than balanced")
    }
    
    @MainActor func testModelRecommendationForSpecificSystem() throws {
        // Given: Medium-tier system profile
        let mediumSystem = SystemCapabilityProfile(
            cpuCores: 8, totalRAM: 16000, availableRAM: 12000, gpuMemory: 8000,
            storageSpace: 500000, internetSpeed: 100, powerConstraints: .desktop,
            performanceClass: .medium
        )
        
        // When: Getting recommendations
        let recommendations = try modelRecommendationEngine.recommendOptimalModels(systemProfile: mediumSystem)
        
        // Then: Should provide ranked recommendations with details
        XCTAssertGreaterThanOrEqual(recommendations.count, 3, "Should provide multiple recommendations")
        
        let topRecommendation = recommendations.first!
        XCTAssertGreaterThan(topRecommendation.suitabilityScore, 0.7, "Top recommendation should have high suitability")
        XCTAssertNotNil(topRecommendation.expectedPerformance, "Should include performance estimates")
        XCTAssertNotNil(topRecommendation.downloadTime, "Should include download time estimates")
        XCTAssertFalse(topRecommendation.useCases.isEmpty, "Should include use cases")
        XCTAssertFalse(topRecommendation.pros.isEmpty, "Should include pros")
        XCTAssertFalse(topRecommendation.limitations.isEmpty, "Should include limitations")
    }
    
    // MARK: - Upgrade Suggestion Tests
    
    @MainActor func testComplexityAnalysis() throws {
        // Given: Different types of queries
        let simpleQuery = "What is the weather like today?"
        let complexQuery = "Analyze the financial implications of implementing a multi-tier SaaS pricing model with usage-based billing, considering customer acquisition costs, churn rates, and competitive positioning in the enterprise market."
        let researchQuery = "Compare and contrast the effectiveness of transformer architectures versus traditional RNN models for natural language processing tasks, including analysis of computational efficiency, training requirements, and performance benchmarks."
        
        // When: Analyzing query complexity
        let simpleAnalysis = try upgradeSubgestionEngine.analyzeQueryComplexity(userQuery: simpleQuery)
        let complexAnalysis = try upgradeSubgestionEngine.analyzeQueryComplexity(userQuery: complexQuery)
        let researchAnalysis = try upgradeSubgestionEngine.analyzeQueryComplexity(userQuery: researchQuery)
        
        // Then: Should correctly classify complexity
        XCTAssertEqual(simpleAnalysis.complexity, .simple, "Should classify simple query correctly")
        XCTAssertEqual(complexAnalysis.complexity, .complex, "Should classify complex query correctly")
        XCTAssertEqual(researchAnalysis.complexity, .veryComplex, "Should classify research query correctly")
        
        // Complex queries should benefit from multi-agent
        XCTAssertTrue(complexAnalysis.benefitsFromMultiAgent, "Complex query should benefit from multi-agent")
        XCTAssertTrue(researchAnalysis.benefitsFromMultiAgent, "Research query should benefit from multi-agent")
        XCTAssertGreaterThan(complexAnalysis.suggestedAgentCount, 1, "Should suggest multiple agents for complex query")
    }
    
    @MainActor func testUpgradeSuggestionGeneration() throws {
        // Given: Complex query that would benefit from multi-agent
        let complexQuery = "Help me create a comprehensive business plan including market analysis, financial projections, competitive landscape, and implementation strategy for a fintech startup."
        let mockAgent = LocalAIAgent(modelName: "llama-3.2-3b", capabilities: ["general", "writing"])
        
        // When: Generating upgrade suggestion
        let upgradeSuggestion = try upgradeSubgestionEngine.suggestMultiAgentBenefits(
            query: complexQuery,
            currentAgent: mockAgent
        )
        
        // Then: Should suggest upgrade with appropriate messaging
        XCTAssertTrue(upgradeSuggestion.shouldSuggest, "Should suggest upgrade for complex query")
        XCTAssertFalse(upgradeSuggestion.message.isEmpty, "Should provide upgrade message")
        XCTAssertFalse(upgradeSuggestion.benefits.isEmpty, "Should list benefits")
        XCTAssertNotNil(upgradeSuggestion.demonstration, "Should include demonstration")
        XCTAssertTrue(upgradeSuggestion.dismissible, "Should be dismissible")
    }
    
    // MARK: - Local Model Setup Tests
    
    @MainActor func testLocalModelSetupWizardWorkflow() throws {
        // Given: Single agent mode with setup wizard
        XCTAssertNotNil(singleAgentMode.setupWizard, "Should have setup wizard")
        
        // When: Going through setup process
        let setupSteps = singleAgentMode.setupWizard.getSetupSteps()
        
        // Then: Should have proper setup workflow
        XCTAssertGreaterThanOrEqual(setupSteps.count, 5, "Should have comprehensive setup steps")
        
        let stepTitles = setupSteps.map { $0.title }
        XCTAssertTrue(stepTitles.contains("System Analysis"), "Should include system analysis step")
        XCTAssertTrue(stepTitles.contains("Model Recommendation"), "Should include model recommendation step")
        XCTAssertTrue(stepTitles.contains("Download & Install"), "Should include download step")
        XCTAssertTrue(stepTitles.contains("Optimization"), "Should include optimization step")
        XCTAssertTrue(stepTitles.contains("Ready to Use"), "Should include ready-to-use step")
    }
    
    @MainActor func testSetupWizardErrorHandling() throws {
        // Given: Setup wizard with error scenarios
        let setupWizard = singleAgentMode.setupWizard
        
        // When: Testing error handling for common issues
        let downloadError = DownloadError.networkTimeout
        let recoveryPlan = setupWizard.handleDownloadFailure(error: downloadError)
        
        // Then: Should provide recovery options
        XCTAssertNotNil(recoveryPlan, "Should provide recovery plan for download failure")
        XCTAssertFalse(recoveryPlan.steps.isEmpty, "Recovery plan should have steps")
        XCTAssertTrue(recoveryPlan.canRetry, "Should allow retry for network errors")
        
        // Test insufficient resources scenario
        let resourceShortfall = ResourceShortfall.insufficientRAM(required: 16000, available: 8000)
        let alternativePlan = setupWizard.handleInsufficientResources(resources: resourceShortfall)
        
        XCTAssertNotNil(alternativePlan, "Should provide alternative plan")
        XCTAssertFalse(alternativePlan.alternativeModels.isEmpty, "Should suggest alternative models")
        XCTAssertTrue(alternativePlan.alternativeModels.allSatisfy { $0.memoryRequirement <= 8000 }, "Alternatives should fit available memory")
    }
    
    // MARK: - Integration Tests
    
    @MainActor func testFullSingleAgentModeWorkflow() throws {
        // Given: Complete single agent mode setup
        XCTAssertNotNil(singleAgentMode, "Single agent mode should be initialized")
        
        // When: Running full workflow simulation
        let systemProfile = try systemAnalyzer.analyzeSystemCapabilities()
        let recommendations = try modelRecommendationEngine.recommendOptimalModels(systemProfile: systemProfile)
        let selectedModel = recommendations.first!
        
        // Simulate model selection and setup
        let setupResult = try singleAgentMode.simulateModelSetup(model: selectedModel.model)
        
        // Then: Should complete successfully
        XCTAssertTrue(setupResult.success, "Model setup should succeed")
        XCTAssertNotNil(setupResult.configuredAgent, "Should have configured agent")
        XCTAssertGreaterThan(setupResult.performanceScore, 0.5, "Should have decent performance score")
        
        // Test basic interaction
        let testQuery = "Hello, can you help me with a simple question?"
        let response = try setupResult.configuredAgent!.processQuery(query: testQuery)
        
        XCTAssertFalse(response.content.isEmpty, "Should provide response to simple query")
        XCTAssertLessThan(response.responseTime, 30.0, "Response should be within acceptable time")
    }
    
    @MainActor func testUpgradePathTransition() throws {
        // Given: Single agent mode with upgrade triggers
        let complexQuery = "I need help with a multi-faceted analysis involving data processing, visualization, and strategic recommendations."
        
        // When: Processing query that triggers upgrade suggestion
        let queryResult = try singleAgentMode.processQueryWithUpgradeAnalysis(query: complexQuery)
        
        // Then: Should provide response with upgrade suggestion
        XCTAssertNotNil(queryResult.response, "Should provide response")
        XCTAssertNotNil(queryResult.upgradeSuggestion, "Should include upgrade suggestion")
        XCTAssertTrue(queryResult.upgradeSuggestion!.shouldSuggest, "Should suggest upgrade for complex query")
        
        // Upgrade suggestion should be contextual
        let suggestion = queryResult.upgradeSuggestion!
        XCTAssertTrue(suggestion.benefits.contains { $0.contains("specialized") }, "Should mention specialization benefits")
        XCTAssertTrue(suggestion.benefits.contains { $0.contains("collaboration") }, "Should mention collaboration benefits")
    }
    
    // MARK: - Performance Tests
    
    @MainActor func testModelRecommendationPerformance() throws {
        // Given: System analyzer and model engine
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // When: Getting model recommendations (should be fast)
        let systemProfile = try systemAnalyzer.analyzeSystemCapabilities()
        let recommendations = try modelRecommendationEngine.recommendOptimalModels(systemProfile: systemProfile)
        
        let endTime = CFAbsoluteTimeGetCurrent()
        let executionTime = endTime - startTime
        
        // Then: Should complete quickly
        XCTAssertLessThan(executionTime, 2.0, "Model recommendation should complete within 2 seconds")
        XCTAssertFalse(recommendations.isEmpty, "Should provide recommendations")
    }
    
    @MainActor func testSystemAnalysisPerformance() throws {
        // Given: System analyzer
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // When: Analyzing system capabilities
        let capabilities = try systemAnalyzer.analyzeSystemCapabilities()
        
        let endTime = CFAbsoluteTimeGetCurrent()
        let executionTime = endTime - startTime
        
        // Then: Should analyze quickly
        XCTAssertLessThan(executionTime, 1.0, "System analysis should complete within 1 second")
        XCTAssertNotNil(capabilities, "Should return capabilities")
    }
}

// MARK: - Helper Extensions and Types for Testing

extension MLACSSingleAgentModeTests {
    
    func createMockSystemProfile(performanceClass: PerformanceClass) -> SystemCapabilityProfile {
        switch performanceClass {
        case .low:
            return SystemCapabilityProfile(
                cpuCores: 2, totalRAM: 4000, availableRAM: 2000, gpuMemory: 0,
                storageSpace: 100000, internetSpeed: 10, powerConstraints: .laptop,
                performanceClass: .low
            )
        case .medium:
            return SystemCapabilityProfile(
                cpuCores: 8, totalRAM: 16000, availableRAM: 12000, gpuMemory: 4000,
                storageSpace: 500000, internetSpeed: 100, powerConstraints: .desktop,
                performanceClass: .medium
            )
        case .high:
            return SystemCapabilityProfile(
                cpuCores: 12, totalRAM: 32000, availableRAM: 24000, gpuMemory: 16000,
                storageSpace: 1000000, internetSpeed: 1000, powerConstraints: .desktop,
                performanceClass: .high
            )
        case .extreme:
            return SystemCapabilityProfile(
                cpuCores: 24, totalRAM: 128000, availableRAM: 100000, gpuMemory: 32000,
                storageSpace: 5000000, internetSpeed: 1000, powerConstraints: .desktop,
                performanceClass: .extreme
            )
        }
    }
}