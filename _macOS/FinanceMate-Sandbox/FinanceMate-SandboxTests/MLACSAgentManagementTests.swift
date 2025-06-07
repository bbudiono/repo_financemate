// SANDBOX FILE: For testing/development. See .cursorrules.

//
//  MLACSAgentManagementTests.swift
//  FinanceMate-SandboxTests
//
//  Created by Assistant on 6/7/25.
//

/*
* Purpose: TDD test suite for MLACS Agent Management and Configuration System
* Features: Agent creation, configuration, performance monitoring, profile management
* TDD Focus: Test-first development ensuring robust agent lifecycle management
*/

import XCTest
@testable import FinanceMate_Sandbox

final class MLACSAgentManagementTests: XCTestCase {
    
    var agentManager: MLACSAgentManager!
    var agentConfigurationService: AgentConfigurationService!
    var agentProfileManager: AgentProfileManager!
    var agentPerformanceMonitor: AgentPerformanceMonitor!
    var testSystemCapabilities: SystemCapabilityProfile!
    
    @MainActor override func setUpWithError() throws {
        try super.setUpWithError()
        
        agentConfigurationService = AgentConfigurationService()
        agentProfileManager = AgentProfileManager()
        agentPerformanceMonitor = AgentPerformanceMonitor()
        agentManager = MLACSAgentManager(
            configurationService: agentConfigurationService,
            profileManager: agentProfileManager,
            performanceMonitor: agentPerformanceMonitor
        )
        
        // Create test system capabilities
        testSystemCapabilities = SystemCapabilityProfile(
            cpuCores: 8,
            totalRAM: 16000,
            availableRAM: 12000,
            gpuMemory: 8000,
            storageSpace: 100000,
            internetSpeed: 100,
            powerConstraints: .desktop,
            performanceClass: .high
        )
    }
    
    override func tearDownWithError() throws {
        agentManager = nil
        agentConfigurationService = nil
        agentProfileManager = nil
        agentPerformanceMonitor = nil
        testSystemCapabilities = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Agent Creation Tests
    
    @MainActor func testCreateAgentFromModel() throws {
        // Test creating agent from discovered model
        let testModel = DiscoveredModel(
            name: "Test Llama 3.2 3B",
            provider: "Ollama",
            modelId: "llama3.2:3b",
            parameterCount: 3_200_000_000,
            sizeBytes: 2_000_000_000,
            memoryRequirementMB: 4500,
            capabilities: ["text_generation", "conversation", "analysis"],
            isInstalled: true
        )
        
        let agent = try agentManager.createAgent(
            from: testModel,
            name: "Test Assistant",
            systemCapabilities: testSystemCapabilities
        )
        
        XCTAssertNotNil(agent, "Should create agent from model")
        XCTAssertEqual(agent.name, "Test Assistant", "Agent should have specified name")
        XCTAssertEqual(agent.modelId, testModel.modelId, "Agent should reference correct model")
        XCTAssertEqual(agent.capabilities, testModel.capabilities, "Agent should inherit model capabilities")
        XCTAssertTrue(agent.isConfigured, "Agent should be initially configured")
    }
    
    @MainActor func testCreateAgentWithCustomConfiguration() throws {
        // Test creating agent with custom parameters
        let customConfig = AgentConfiguration(
            name: "Custom Financial Assistant",
            personality: .professional,
            specialization: .financial,
            responseStyle: .detailed,
            creativityLevel: 0.7,
            safetyLevel: .high,
            memoryLimit: 8000,
            contextWindowSize: 4096,
            customInstructions: "Focus on financial analysis and provide detailed explanations."
        )
        
        let testModel = DiscoveredModel(
            name: "Mistral 7B",
            provider: "Ollama",
            modelId: "mistral:7b",
            parameterCount: 7_000_000_000,
            sizeBytes: 4_100_000_000,
            memoryRequirementMB: 8000,
            capabilities: ["text_generation", "conversation", "coding", "analysis"],
            isInstalled: true
        )
        
        let agent = try agentManager.createAgent(
            from: testModel,
            configuration: customConfig,
            systemCapabilities: testSystemCapabilities
        )
        
        XCTAssertEqual(agent.name, customConfig.name, "Agent should use custom name")
        XCTAssertEqual(agent.configuration.personality, customConfig.personality, "Agent should use custom personality")
        XCTAssertEqual(agent.configuration.specialization, customConfig.specialization, "Agent should use custom specialization")
        XCTAssertEqual(agent.configuration.customInstructions, customConfig.customInstructions, "Agent should use custom instructions")
    }
    
    @MainActor func testCreateAgentValidatesSystemRequirements() throws {
        // Test that agent creation validates system capabilities
        let highRequirementModel = DiscoveredModel(
            name: "Large Model",
            provider: "Ollama",
            modelId: "large:70b",
            parameterCount: 70_000_000_000,
            sizeBytes: 40_000_000_000,
            memoryRequirementMB: 48000, // Exceeds available RAM
            capabilities: ["text_generation"],
            isInstalled: true
        )
        
        let lowRAMSystem = SystemCapabilityProfile(
            cpuCores: 4,
            totalRAM: 8000,
            availableRAM: 6000, // Insufficient for model
            gpuMemory: 0,
            storageSpace: 50000,
            internetSpeed: 50,
            powerConstraints: .laptop,
            performanceClass: .low
        )
        
        XCTAssertThrowsError(try agentManager.createAgent(
            from: highRequirementModel,
            name: "Test",
            systemCapabilities: lowRAMSystem
        )) { error in
            XCTAssertTrue(error is AgentManagementError, "Should throw AgentManagementError")
            if case AgentManagementError.insufficientResources(let message) = error {
                XCTAssertTrue(message.contains("memory"), "Error should mention memory requirement")
            }
        }
    }
    
    // MARK: - Agent Configuration Tests
    
    @MainActor func testUpdateAgentConfiguration() throws {
        // Test updating existing agent configuration
        let testModel = createTestModel()
        let agent = try agentManager.createAgent(
            from: testModel,
            name: "Test Agent",
            systemCapabilities: testSystemCapabilities
        )
        
        let updatedConfig = AgentConfiguration(
            name: "Updated Assistant",
            personality: .friendly,
            specialization: .general,
            responseStyle: .concise,
            creativityLevel: 0.5,
            safetyLevel: .medium,
            memoryLimit: 6000,
            contextWindowSize: 2048,
            customInstructions: "Be helpful and concise."
        )
        
        try agentManager.updateAgentConfiguration(agentId: agent.id, configuration: updatedConfig)
        
        let updatedAgent = try agentManager.getAgent(id: agent.id)
        XCTAssertEqual(updatedAgent.name, updatedConfig.name, "Agent name should be updated")
        XCTAssertEqual(updatedAgent.configuration.personality, updatedConfig.personality, "Personality should be updated")
        XCTAssertEqual(updatedAgent.configuration.responseStyle, updatedConfig.responseStyle, "Response style should be updated")
    }
    
    @MainActor func testAgentConfigurationValidation() throws {
        // Test configuration parameter validation
        let invalidConfig = AgentConfiguration(
            name: "", // Invalid empty name
            personality: .professional,
            specialization: .general,
            responseStyle: .detailed,
            creativityLevel: 2.0, // Invalid - should be 0.0-1.0
            safetyLevel: .high,
            memoryLimit: -1000, // Invalid negative memory
            contextWindowSize: 0, // Invalid zero context
            customInstructions: ""
        )
        
        let testModel = createTestModel()
        
        XCTAssertThrowsError(try agentManager.createAgent(
            from: testModel,
            configuration: invalidConfig,
            systemCapabilities: testSystemCapabilities
        )) { error in
            XCTAssertTrue(error is AgentManagementError, "Should throw AgentManagementError for invalid config")
        }
    }
    
    @MainActor func testAgentSpecializationCapabilities() throws {
        // Test that specialization affects agent capabilities
        let financialConfig = AgentConfiguration(
            name: "Financial Specialist",
            personality: .professional,
            specialization: .financial,
            responseStyle: .detailed,
            creativityLevel: 0.3,
            safetyLevel: .high,
            memoryLimit: 8000,
            contextWindowSize: 4096,
            customInstructions: "Specialize in financial analysis and reporting."
        )
        
        let testModel = createTestModel()
        let agent = try agentManager.createAgent(
            from: testModel,
            configuration: financialConfig,
            systemCapabilities: testSystemCapabilities
        )
        
        let enhancedCapabilities = agent.getEnhancedCapabilities()
        XCTAssertTrue(enhancedCapabilities.contains("financial_analysis"), "Should have financial analysis capability")
        XCTAssertTrue(enhancedCapabilities.contains("document_processing"), "Should have document processing capability")
        XCTAssertTrue(enhancedCapabilities.contains("data_extraction"), "Should have data extraction capability")
    }
    
    // MARK: - Agent Profile Management Tests
    
    @MainActor func testCreateAgentProfile() throws {
        // Test creating and managing agent profiles
        let profile = AgentProfile(
            name: "Financial Expert Profile",
            description: "Specialized for financial document analysis",
            configuration: AgentConfiguration(
                name: "FinanceBot",
                personality: .professional,
                specialization: .financial,
                responseStyle: .detailed,
                creativityLevel: 0.2,
                safetyLevel: .high,
                memoryLimit: 10000,
                contextWindowSize: 8192,
                customInstructions: "Focus on accuracy and compliance in financial matters."
            ),
            tags: ["finance", "professional", "analysis"],
            isDefault: false,
            createdDate: Date(),
            lastUsed: Date()
        )
        
        try agentProfileManager.saveProfile(profile)
        
        let retrievedProfile = try agentProfileManager.getProfile(id: profile.id)
        XCTAssertEqual(retrievedProfile.name, profile.name, "Profile should be saved and retrieved correctly")
        XCTAssertEqual(retrievedProfile.configuration.specialization, .financial, "Profile configuration should be preserved")
        XCTAssertEqual(retrievedProfile.tags, profile.tags, "Profile tags should be preserved")
    }
    
    @MainActor func testAgentProfileSearch() throws {
        // Test searching and filtering agent profiles
        let profiles = [
            AgentProfile(
                name: "Financial Assistant",
                description: "For financial analysis",
                configuration: createFinancialConfig(),
                tags: ["finance", "professional"],
                isDefault: false,
                createdDate: Date(),
                lastUsed: Date()
            ),
            AgentProfile(
                name: "Creative Writer",
                description: "For creative writing tasks",
                configuration: createCreativeConfig(),
                tags: ["creative", "writing"],
                isDefault: false,
                createdDate: Date(),
                lastUsed: Date()
            ),
            AgentProfile(
                name: "Code Assistant",
                description: "For programming help",
                configuration: createCodingConfig(),
                tags: ["coding", "technical"],
                isDefault: false,
                createdDate: Date(),
                lastUsed: Date()
            )
        ]
        
        for profile in profiles {
            try agentProfileManager.saveProfile(profile)
        }
        
        // Test search by tag
        let financialProfiles = try agentProfileManager.searchProfiles(tags: ["finance"])
        XCTAssertEqual(financialProfiles.count, 1, "Should find one financial profile")
        XCTAssertEqual(financialProfiles.first?.name, "Financial Assistant", "Should find correct financial profile")
        
        // Test search by specialization
        let creativeProfiles = try agentProfileManager.searchProfiles(specialization: .creative)
        XCTAssertEqual(creativeProfiles.count, 1, "Should find one creative profile")
        
        // Test search by name
        let codeProfiles = try agentProfileManager.searchProfiles(nameContains: "Code")
        XCTAssertEqual(codeProfiles.count, 1, "Should find one code profile")
    }
    
    // MARK: - Agent Performance Monitoring Tests
    
    @MainActor func testAgentPerformanceTracking() throws {
        // Test performance monitoring and metrics collection
        let testModel = createTestModel()
        let agent = try agentManager.createAgent(
            from: testModel,
            name: "Performance Test Agent",
            systemCapabilities: testSystemCapabilities
        )
        
        // Simulate agent interactions
        let testQueries = [
            "What is the current market trend?",
            "Analyze this financial document",
            "Calculate the ROI for this investment",
            "Generate a monthly report"
        ]
        
        for query in testQueries {
            let startTime = Date()
            
            // Simulate query processing
            let response = try agent.processQuery(query)
            
            let endTime = Date()
            let responseTime = endTime.timeIntervalSince(startTime)
            
            // Record performance metrics
            agentPerformanceMonitor.recordQueryPerformance(
                agentId: agent.id,
                query: query,
                responseTime: responseTime,
                responseLength: response.content.count,
                confidence: response.confidence,
                timestamp: startTime
            )
        }
        
        // Verify metrics collection
        let metrics = agentPerformanceMonitor.getPerformanceMetrics(for: agent.id)
        XCTAssertEqual(metrics.totalQueries, testQueries.count, "Should track all queries")
        XCTAssertGreaterThan(metrics.averageResponseTime, 0, "Should calculate average response time")
        XCTAssertGreaterThan(metrics.averageConfidence, 0, "Should track confidence scores")
    }
    
    @MainActor func testPerformanceAlerts() throws {
        // Test performance monitoring alerts and thresholds
        let testModel = createTestModel()
        let agent = try agentManager.createAgent(
            from: testModel,
            name: "Alert Test Agent",
            systemCapabilities: testSystemCapabilities
        )
        
        // Configure performance thresholds
        let thresholds = MLACSPerformanceThresholds(
            maxResponseTime: 5.0,
            minConfidenceScore: 0.7,
            maxMemoryUsage: 8000,
            maxErrorRate: 0.05
        )
        
        agentPerformanceMonitor.setThresholds(for: agent.id, thresholds: thresholds)
        
        // Simulate slow response that should trigger alert
        agentPerformanceMonitor.recordQueryPerformance(
            agentId: agent.id,
            query: "Complex analysis query",
            responseTime: 10.0, // Exceeds threshold
            responseLength: 1000,
            confidence: 0.8,
            timestamp: Date()
        )
        
        let alerts = agentPerformanceMonitor.getActiveAlerts(for: agent.id)
        XCTAssertFalse(alerts.isEmpty, "Should generate performance alert")
        XCTAssertTrue(alerts.contains { $0.type == .slowResponse }, "Should have slow response alert")
    }
    
    // MARK: - Agent Lifecycle Management Tests
    
    @MainActor func testAgentActivationDeactivation() throws {
        // Test agent activation and deactivation
        let testModel = createTestModel()
        let agent = try agentManager.createAgent(
            from: testModel,
            name: "Lifecycle Test Agent",
            systemCapabilities: testSystemCapabilities
        )
        
        XCTAssertTrue(agent.isActive, "Agent should be active after creation")
        
        // Deactivate agent
        try agentManager.deactivateAgent(id: agent.id)
        
        let deactivatedAgent = try agentManager.getAgent(id: agent.id)
        XCTAssertFalse(deactivatedAgent.isActive, "Agent should be deactivated")
        
        // Reactivate agent
        try agentManager.activateAgent(id: agent.id)
        
        let reactivatedAgent = try agentManager.getAgent(id: agent.id)
        XCTAssertTrue(reactivatedAgent.isActive, "Agent should be reactivated")
    }
    
    @MainActor func testAgentDeletion() throws {
        // Test agent deletion and cleanup
        let testModel = createTestModel()
        let agent = try agentManager.createAgent(
            from: testModel,
            name: "Delete Test Agent",
            systemCapabilities: testSystemCapabilities
        )
        
        let agentId = agent.id
        
        // Verify agent exists
        XCTAssertNoThrow(try agentManager.getAgent(id: agentId))
        
        // Delete agent
        try agentManager.deleteAgent(id: agentId)
        
        // Verify agent is deleted
        XCTAssertThrowsError(try agentManager.getAgent(id: agentId)) { error in
            XCTAssertTrue(error is AgentManagementError, "Should throw AgentManagementError")
            if case AgentManagementError.agentNotFound = error {
                // Expected error
            } else {
                XCTFail("Should throw agentNotFound error")
            }
        }
        
        // Verify performance data is cleaned up
        let metrics = agentPerformanceMonitor.getPerformanceMetrics(for: agentId)
        XCTAssertEqual(metrics.totalQueries, 0, "Performance data should be cleaned up")
    }
    
    // MARK: - Agent Collection Management Tests
    
    @MainActor func testListAllAgents() throws {
        // Test listing and filtering agents
        let models = [
            createTestModel(name: "Model A", modelId: "model-a"),
            createTestModel(name: "Model B", modelId: "model-b"),
            createTestModel(name: "Model C", modelId: "model-c")
        ]
        
        var createdAgents: [ManagedAgent] = []
        
        for (index, model) in models.enumerated() {
            let agent = try agentManager.createAgent(
                from: model,
                name: "Agent \(index + 1)",
                systemCapabilities: testSystemCapabilities
            )
            createdAgents.append(agent)
        }
        
        // Test get all agents
        let allAgents = try agentManager.getAllAgents()
        XCTAssertEqual(allAgents.count, 3, "Should retrieve all created agents")
        
        // Test get active agents
        try agentManager.deactivateAgent(id: createdAgents[1].id)
        let activeAgents = try agentManager.getActiveAgents()
        XCTAssertEqual(activeAgents.count, 2, "Should retrieve only active agents")
        
        // Test filter by specialization
        let financialConfig = createFinancialConfig()
        let financialAgent = try agentManager.createAgent(
            from: models[0],
            configuration: financialConfig,
            systemCapabilities: testSystemCapabilities
        )
        
        let financialAgents = try agentManager.getAgentsBySpecialization(.financial)
        XCTAssertGreaterThanOrEqual(financialAgents.count, 1, "Should find financial agents")
    }
    
    @MainActor func testAgentExportImport() throws {
        // Test exporting and importing agent configurations
        let testModel = createTestModel()
        let originalAgent = try agentManager.createAgent(
            from: testModel,
            name: "Export Test Agent",
            systemCapabilities: testSystemCapabilities
        )
        
        // Export agent configuration
        let exportedData = try agentManager.exportAgentConfiguration(id: originalAgent.id)
        XCTAssertFalse(exportedData.isEmpty, "Should export agent configuration data")
        
        // Delete original agent
        try agentManager.deleteAgent(id: originalAgent.id)
        
        // Import agent configuration
        let importedAgent = try agentManager.importAgentConfiguration(
            data: exportedData,
            model: testModel,
            systemCapabilities: testSystemCapabilities
        )
        
        XCTAssertEqual(importedAgent.name, originalAgent.name, "Imported agent should have same name")
        XCTAssertEqual(importedAgent.configuration.personality, originalAgent.configuration.personality, "Imported agent should have same configuration")
    }
    
    // MARK: - Error Handling Tests
    
    @MainActor func testInvalidAgentOperations() throws {
        // Test error handling for invalid operations
        let nonexistentId = "nonexistent-agent-id"
        
        // Test get nonexistent agent
        XCTAssertThrowsError(try agentManager.getAgent(id: nonexistentId))
        
        // Test update nonexistent agent
        let testConfig = createFinancialConfig()
        XCTAssertThrowsError(try agentManager.updateAgentConfiguration(agentId: nonexistentId, configuration: testConfig))
        
        // Test delete nonexistent agent
        XCTAssertThrowsError(try agentManager.deleteAgent(id: nonexistentId))
    }
    
    @MainActor func testConcurrentAgentOperations() throws {
        // Test thread safety and concurrent operations
        let testModel = createTestModel()
        let agent = try agentManager.createAgent(
            from: testModel,
            name: "Concurrent Test Agent",
            systemCapabilities: testSystemCapabilities
        )
        
        let expectation = XCTestExpectation(description: "Concurrent operations")
        expectation.expectedFulfillmentCount = 10
        
        let dispatchGroup = DispatchGroup()
        
        // Perform concurrent read operations
        for i in 0..<10 {
            dispatchGroup.enter()
            DispatchQueue.global().async {
                do {
                    let retrievedAgent = try self.agentManager.getAgent(id: agent.id)
                    XCTAssertEqual(retrievedAgent.id, agent.id)
                    expectation.fulfill()
                } catch {
                    XCTFail("Concurrent read operation failed: \(error)")
                }
                dispatchGroup.leave()
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    // MARK: - Helper Methods
    
    private func createTestModel(name: String = "Test Model", modelId: String = "test:model") -> DiscoveredModel {
        return DiscoveredModel(
            name: name,
            provider: "Test Provider",
            modelId: modelId,
            parameterCount: 7_000_000_000,
            sizeBytes: 4_000_000_000,
            memoryRequirementMB: 8000,
            capabilities: ["text_generation", "conversation", "analysis"],
            isInstalled: true
        )
    }
    
    private func createFinancialConfig() -> AgentConfiguration {
        return AgentConfiguration(
            name: "Financial Assistant",
            personality: .professional,
            specialization: .financial,
            responseStyle: .detailed,
            creativityLevel: 0.2,
            safetyLevel: .high,
            memoryLimit: 10000,
            contextWindowSize: 8192,
            customInstructions: "Focus on financial analysis and compliance."
        )
    }
    
    private func createCreativeConfig() -> AgentConfiguration {
        return AgentConfiguration(
            name: "Creative Writer",
            personality: .creative,
            specialization: .creative,
            responseStyle: .engaging,
            creativityLevel: 0.9,
            safetyLevel: .medium,
            memoryLimit: 8000,
            contextWindowSize: 4096,
            customInstructions: "Be imaginative and inspiring in writing tasks."
        )
    }
    
    private func createCodingConfig() -> AgentConfiguration {
        return AgentConfiguration(
            name: "Code Assistant",
            personality: .technical,
            specialization: .coding,
            responseStyle: .precise,
            creativityLevel: 0.4,
            safetyLevel: .high,
            memoryLimit: 12000,
            contextWindowSize: 8192,
            customInstructions: "Provide accurate, well-documented code solutions."
        )
    }
}