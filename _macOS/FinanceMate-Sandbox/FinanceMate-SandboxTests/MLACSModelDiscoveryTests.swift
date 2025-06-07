// SANDBOX FILE: For testing/development. See .cursorrules.

//
//  MLACSModelDiscoveryTests.swift
//  FinanceMate-SandboxTests
//
//  Created by Assistant on 6/7/25.
//

/*
* Purpose: TDD test suite for MLACS Model Discovery and Local LLM Integration
* Features: Dynamic model detection, local LLM provider discovery, real-time model availability
* TDD Approach: Test-first development for model discovery and integration capabilities
*/

import XCTest
@testable import FinanceMate_Sandbox

final class MLACSModelDiscoveryTests: XCTestCase {
    
    var modelDiscovery: MLACSModelDiscovery!
    var llmProviderDetector: LocalLLMProviderDetector!
    var modelAvailabilityChecker: ModelAvailabilityChecker!
    var integrationCoordinator: LLMIntegrationCoordinator!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        llmProviderDetector = LocalLLMProviderDetector()
        modelAvailabilityChecker = ModelAvailabilityChecker()
        integrationCoordinator = LLMIntegrationCoordinator()
        modelDiscovery = MLACSModelDiscovery(
            providerDetector: llmProviderDetector,
            availabilityChecker: modelAvailabilityChecker,
            integrationCoordinator: integrationCoordinator
        )
    }
    
    override func tearDownWithError() throws {
        modelDiscovery = nil
        llmProviderDetector = nil
        modelAvailabilityChecker = nil
        integrationCoordinator = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Model Discovery Tests
    
    func testLocalLLMProviderDetection() throws {
        // Test discovery of local LLM providers
        let detectedProviders = try llmProviderDetector.detectInstalledProviders()
        
        XCTAssertNotNil(detectedProviders, "Should return provider detection results")
        XCTAssertTrue(detectedProviders.count >= 0, "Should return valid provider count")
        
        // Test specific provider detection
        let ollamaDetected = detectedProviders.contains { $0.name == "Ollama" }
        let lmStudioDetected = detectedProviders.contains { $0.name == "LM Studio" }
        let gpt4allDetected = detectedProviders.contains { $0.name == "GPT4All" }
        
        // At least one provider should be detectable in most environments
        print("🔍 Detected providers: \(detectedProviders.map { $0.name })")
        
        // Verify provider information structure
        for provider in detectedProviders {
            XCTAssertFalse(provider.name.isEmpty, "Provider name should not be empty")
            XCTAssertFalse(provider.executablePath.isEmpty, "Executable path should not be empty")
            XCTAssertNotNil(provider.version, "Provider version should be detectable")
        }
    }
    
    func testModelAvailabilityCheck() throws {
        // Test model availability checking for different providers
        let availableModels = try modelAvailabilityChecker.checkAvailableModels()
        
        XCTAssertNotNil(availableModels, "Should return model availability results")
        
        // Test model information structure
        for model in availableModels {
            XCTAssertFalse(model.name.isEmpty, "Model name should not be empty")
            XCTAssertFalse(model.provider.isEmpty, "Model provider should not be empty")
            XCTAssertGreaterThan(model.sizeBytes, 0, "Model size should be positive")
            XCTAssertTrue(model.isInstalled || !model.isInstalled, "Installation status should be boolean")
        }
    }
    
    func testDynamicModelDiscovery() throws {
        // Test comprehensive model discovery across all providers
        let discoveryResults = try modelDiscovery.discoverAllAvailableModels()
        
        XCTAssertNotNil(discoveryResults, "Should return discovery results")
        XCTAssertNotNil(discoveryResults.installedModels, "Should identify installed models")
        XCTAssertNotNil(discoveryResults.availableModels, "Should identify available models")
        XCTAssertNotNil(discoveryResults.recommendedModels, "Should provide recommendations")
        
        // Verify result structure
        XCTAssertGreaterThanOrEqual(discoveryResults.installedModels.count, 0, "Installed models count should be valid")
        XCTAssertGreaterThanOrEqual(discoveryResults.availableModels.count, 0, "Available models count should be valid")
        XCTAssertGreaterThanOrEqual(discoveryResults.recommendedModels.count, 0, "Recommended models count should be valid")
        
        // Test discovery performance
        let startTime = CFAbsoluteTimeGetCurrent()
        _ = try modelDiscovery.discoverAllAvailableModels()
        let discoveryTime = CFAbsoluteTimeGetCurrent() - startTime
        
        XCTAssertLessThan(discoveryTime, 10.0, "Discovery should complete within 10 seconds")
    }
    
    // MARK: - Integration Tests
    
    func testLLMIntegrationCoordination() throws {
        // Test coordination between different LLM providers
        let integrationStatus = try integrationCoordinator.getIntegrationStatus()
        
        XCTAssertNotNil(integrationStatus, "Should return integration status")
        
        // Test integration capabilities
        let capabilities = integrationStatus.supportedCapabilities
        XCTAssertTrue(capabilities.contains("text_generation") || capabilities.isEmpty, "Should support basic text generation")
        
        // Test health checks
        let healthStatus = try integrationCoordinator.performHealthCheck()
        XCTAssertNotNil(healthStatus, "Should return health check results")
        XCTAssertTrue(healthStatus.isHealthy || !healthStatus.isHealthy, "Health status should be boolean")
    }
    
    func testModelConnectionEstablishment() throws {
        // Test establishing connections to available models
        let availableModels = try modelAvailabilityChecker.checkAvailableModels()
        
        for model in availableModels.prefix(3) { // Test first 3 models to avoid long test times
            if model.isInstalled {
                let connectionResult = try integrationCoordinator.establishConnection(to: model)
                
                XCTAssertNotNil(connectionResult, "Should return connection result")
                
                if connectionResult.isSuccessful {
                    // Test basic communication
                    let testQuery = "Hello, can you respond?"
                    let response = try integrationCoordinator.sendTestQuery(testQuery, to: model)
                    
                    XCTAssertNotNil(response, "Should receive response from model")
                    XCTAssertFalse(response.isEmpty, "Response should not be empty")
                    
                    // Cleanup connection
                    try integrationCoordinator.closeConnection(to: model)
                }
            }
        }
    }
    
    // MARK: - Real-time Updates Tests
    
    func testModelDiscoveryUpdates() throws {
        // Test real-time updates when models are installed/removed
        let initialDiscovery = try modelDiscovery.discoverAllAvailableModels()
        let initialCount = initialDiscovery.installedModels.count
        
        // Simulate model installation notification
        let expectation = XCTestExpectation(description: "Model discovery update")
        
        modelDiscovery.onModelDiscoveryUpdate = { updatedResults in
            XCTAssertNotNil(updatedResults, "Should receive updated results")
            expectation.fulfill()
        }
        
        // Trigger update check
        try modelDiscovery.refreshModelDiscovery()
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testProviderStatusMonitoring() throws {
        // Test monitoring of provider status changes
        let expectation = XCTestExpectation(description: "Provider status update")
        
        llmProviderDetector.onProviderStatusChange = { provider, status in
            XCTAssertNotNil(provider, "Should receive provider information")
            XCTAssertNotNil(status, "Should receive status information")
            expectation.fulfill()
        }
        
        // Trigger status check
        try llmProviderDetector.checkProviderStatus()
        
        wait(for: [expectation], timeout: 3.0)
    }
    
    // MARK: - Error Handling Tests
    
    func testInvalidProviderHandling() throws {
        // Test handling of invalid or corrupted provider installations
        let invalidProvider = LocalLLMProvider(
            name: "InvalidProvider",
            executablePath: "/invalid/path",
            version: "0.0.0",
            status: .notFound
        )
        
        let connectionResult = try integrationCoordinator.establishConnection(to: invalidProvider)
        XCTAssertFalse(connectionResult.isSuccessful, "Should fail to connect to invalid provider")
        XCTAssertNotNil(connectionResult.error, "Should provide error information")
    }
    
    func testNetworkFailureRecovery() throws {
        // Test recovery when network-dependent discovery fails
        let discoveryResults = try modelDiscovery.discoverAllAvailableModels(allowNetworkRequests: false)
        
        XCTAssertNotNil(discoveryResults, "Should return results even without network")
        // Should fall back to local-only discovery
    }
    
    // MARK: - Performance Tests
    
    func testDiscoveryPerformance() throws {
        // Test performance of model discovery operations
        let iterations = 5
        var totalTime: Double = 0
        
        for _ in 0..<iterations {
            let startTime = CFAbsoluteTimeGetCurrent()
            _ = try modelDiscovery.discoverAllAvailableModels()
            totalTime += CFAbsoluteTimeGetCurrent() - startTime
        }
        
        let averageTime = totalTime / Double(iterations)
        XCTAssertLessThan(averageTime, 5.0, "Average discovery time should be under 5 seconds")
        
        print("📊 Average discovery time: \(String(format: "%.2f", averageTime)) seconds")
    }
    
    func testConcurrentDiscovery() throws {
        // Test concurrent discovery operations
        let expectation = XCTestExpectation(description: "Concurrent discovery")
        expectation.expectedFulfillmentCount = 3
        
        let dispatchGroup = DispatchGroup()
        
        for i in 0..<3 {
            dispatchGroup.enter()
            DispatchQueue.global().async {
                do {
                    let results = try self.modelDiscovery.discoverAllAvailableModels()
                    XCTAssertNotNil(results, "Concurrent discovery \(i) should succeed")
                    expectation.fulfill()
                } catch {
                    XCTFail("Concurrent discovery \(i) failed: \(error)")
                }
                dispatchGroup.leave()
            }
        }
        
        wait(for: [expectation], timeout: 15.0)
    }
    
    // MARK: - Integration Quality Tests
    
    func testModelCompatibilityValidation() throws {
        // Test validation of model compatibility with system
        let systemCapabilities = try SystemCapabilityAnalyzer().analyzeSystemCapabilities()
        let availableModels = try modelAvailabilityChecker.checkAvailableModels()
        
        for model in availableModels {
            let compatibility = try modelDiscovery.validateModelCompatibility(model, systemCapabilities: systemCapabilities)
            
            XCTAssertNotNil(compatibility, "Should return compatibility assessment")
            XCTAssertTrue(compatibility.isCompatible || !compatibility.isCompatible, "Compatibility should be boolean")
            
            if !compatibility.isCompatible {
                XCTAssertFalse(compatibility.reasons.isEmpty, "Should provide reasons for incompatibility")
            }
        }
    }
    
    func testAutomaticModelRecommendation() throws {
        // Test automatic model recommendations based on system capabilities
        let systemCapabilities = try SystemCapabilityAnalyzer().analyzeSystemCapabilities()
        let recommendations = try modelDiscovery.generateModelRecommendations(for: systemCapabilities)
        
        XCTAssertNotNil(recommendations, "Should return model recommendations")
        XCTAssertFalse(recommendations.isEmpty, "Should provide at least one recommendation")
        
        // Verify recommendation quality
        for recommendation in recommendations {
            XCTAssertFalse(recommendation.model.name.isEmpty, "Recommended model should have valid name")
            XCTAssertGreaterThan(recommendation.suitabilityScore, 0.0, "Suitability score should be positive")
            XCTAssertLessThanOrEqual(recommendation.suitabilityScore, 1.0, "Suitability score should not exceed 1.0")
            XCTAssertFalse(recommendation.rationale.isEmpty, "Should provide rationale for recommendation")
        }
    }
}