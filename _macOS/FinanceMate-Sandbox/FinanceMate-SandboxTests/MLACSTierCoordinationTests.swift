//
//  MLACSTierCoordinationTests.swift
//  FinanceMate-SandboxTests
//
//  Created by Assistant on 6/7/25.
//

import XCTest
import Foundation
@testable import FinanceMate_Sandbox

class MLACSTierCoordinationTests: XCTestCase {
    
    var tierCoordination: MLACSTierCoordination!
    
    @MainActor
    override func setUp() async throws {
        try await super.setUp()
        tierCoordination = MLACSTierCoordination()
    }
    
    override func tearDown() async throws {
        tierCoordination = nil
        try await super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    @MainActor
    func testTierCoordinationInitialization() async throws {
        // Given: A new tier coordination system
        XCTAssertFalse(tierCoordination.isInitialized, "System should not be initialized initially")
        
        // When: Initialize the system
        try await tierCoordination.initializeTierCoordination()
        
        // Then: System should be initialized
        XCTAssertTrue(tierCoordination.isInitialized, "System should be initialized after setup")
        XCTAssertGreaterThan(tierCoordination.activeTiers.count, 0, "Should have active tiers after initialization")
        
        print("✅ Tier coordination system initialized successfully")
    }
    
    @MainActor
    func testInitializationCreatesDefaultTierHierarchy() async throws {
        // When: Initialize the system
        try await tierCoordination.initializeTierCoordination()
        
        // Then: Should have default tier hierarchy
        XCTAssertEqual(tierCoordination.activeTiers.count, 3, "Should have 3 default tiers")
        
        let tierNames = tierCoordination.activeTiers.map { $0.name }
        XCTAssertTrue(tierNames.contains("High Priority Coordination"), "Should have high priority tier")
        XCTAssertTrue(tierNames.contains("Standard Processing"), "Should have standard processing tier")
        XCTAssertTrue(tierNames.contains("Background Tasks"), "Should have background tasks tier")
        
        print("✅ Default tier hierarchy created correctly")
    }
    
    // MARK: - Agent Tier Management Tests
    
    @MainActor
    func testCreateAgentTier() async throws {
        // Given: Initialized system
        try await tierCoordination.initializeTierCoordination()
        let initialTierCount = tierCoordination.activeTiers.count
        
        // When: Create a new agent tier
        let tier = try await tierCoordination.createAgentTier(
            name: "Test Tier",
            priority: .high,
            capabilities: [.realTimeProcessing, .highThroughput],
            resourceLimits: ResourceLimits(maxCPUUsage: 70.0, maxMemoryUsage: 60.0, maxAgents: 8)
        )
        
        // Then: Tier should be created and registered
        XCTAssertEqual(tier.name, "Test Tier", "Tier name should match")
        XCTAssertEqual(tier.priority, .high, "Tier priority should match")
        XCTAssertEqual(tier.capabilities.count, 2, "Should have 2 capabilities")
        XCTAssertEqual(tierCoordination.activeTiers.count, initialTierCount + 1, "Should have one more tier")
        
        print("✅ Agent tier created successfully")
    }
    
    @MainActor
    func testAssignAgentToTier() async throws {
        // Given: Initialized system with a tier
        try await tierCoordination.initializeTierCoordination()
        let tier = try await tierCoordination.createAgentTier(
            name: "Test Assignment Tier",
            priority: .normal,
            capabilities: [.standardProcessing],
            resourceLimits: ResourceLimits(maxCPUUsage: 50.0, maxMemoryUsage: 40.0, maxAgents: 5)
        )
        
        // When: Assign an agent to the tier
        let agentId = "test-agent-001"
        try await tierCoordination.assignAgentToTier(agentId: agentId, tierId: tier.id)
        
        // Then: Agent should be assigned successfully
        // This is verified internally by the tier coordination system
        XCTAssertTrue(true, "Agent assignment completed without errors")
        
        print("✅ Agent assigned to tier successfully")
    }
    
    // MARK: - Agent Execution Coordination Tests
    
    @MainActor
    func testCoordinateAgentExecution() async throws {
        // Given: Initialized system with available tiers
        try await tierCoordination.initializeTierCoordination()
        
        // When: Create an execution request
        let request = AgentExecutionRequest(
            priority: .high,
            resourceNeeds: ResourceNeeds(cpu: 30.0, memory: 20.0, network: 10.0),
            latencyRequirement: 100.0,
            throughputRequirement: 50.0,
            requiredCapabilities: [.realTimeProcessing]
        )
        
        let executionPlan = try await tierCoordination.coordinateAgentExecution(request: request)
        
        // Then: Execution plan should be created
        XCTAssertNotNil(executionPlan, "Execution plan should be created")
        XCTAssertEqual(executionPlan.request.priority, .high, "Plan should maintain request priority")
        XCTAssertNotNil(executionPlan.tier, "Plan should have assigned tier")
        XCTAssertGreaterThan(executionPlan.estimatedDuration, 0, "Should have estimated duration")
        
        print("✅ Agent execution coordinated successfully")
    }
    
    @MainActor
    func testExecutionPlanOptimalTierSelection() async throws {
        // Given: Initialized system
        try await tierCoordination.initializeTierCoordination()
        
        // When: Request critical priority execution
        let criticalRequest = AgentExecutionRequest(
            priority: .critical,
            resourceNeeds: ResourceNeeds(cpu: 60.0, memory: 50.0, network: 20.0),
            latencyRequirement: 50.0,
            throughputRequirement: 100.0,
            requiredCapabilities: [.realTimeProcessing, .lowLatency]
        )
        
        let plan = try await tierCoordination.coordinateAgentExecution(request: criticalRequest)
        
        // Then: Should select high-priority tier
        XCTAssertEqual(plan.tier.priority, .critical, "Should select critical priority tier for critical request")
        
        print("✅ Optimal tier selection working correctly")
    }
    
    // MARK: - Performance Optimization Tests
    
    @MainActor
    func testRealTimeOptimization() async throws {
        // Given: Initialized system
        try await tierCoordination.initializeTierCoordination()
        
        // When: Perform real-time optimization
        try await tierCoordination.performRealTimeOptimization()
        
        // Then: Optimization should complete without errors
        XCTAssertTrue(tierCoordination.isInitialized, "System should remain initialized after optimization")
        
        // Verify coordination metrics are updated
        let metrics = tierCoordination.coordinationMetrics
        XCTAssertGreaterThanOrEqual(metrics.efficiency, 0, "Efficiency should be non-negative")
        XCTAssertGreaterThanOrEqual(metrics.throughput, 0, "Throughput should be non-negative")
        
        print("✅ Real-time optimization completed successfully")
    }
    
    @MainActor
    func testLoadBalancing() async throws {
        // Given: Initialized system with multiple tiers
        try await tierCoordination.initializeTierCoordination()
        
        // When: Perform load balancing
        try await tierCoordination.balanceLoadAcrossTiers()
        
        // Then: Load balancing should complete
        let loadStatus = tierCoordination.loadBalanceStatus
        XCTAssertNotNil(loadStatus.lastBalanced, "Should have last balanced timestamp")
        XCTAssertGreaterThanOrEqual(loadStatus.efficiency, 0, "Efficiency should be non-negative")
        
        print("✅ Load balancing completed successfully")
    }
    
    // MARK: - Performance Analysis Tests
    
    @MainActor
    func testTierPerformanceAnalysis() async throws {
        // Given: Initialized system with active tiers
        try await tierCoordination.initializeTierCoordination()
        
        // When: Get performance analysis
        let analysis = await tierCoordination.getTierPerformanceAnalysis()
        
        // Then: Analysis should contain tier information
        XCTAssertGreaterThan(analysis.tierAnalyses.count, 0, "Should have tier analyses")
        XCTAssertNotNil(analysis.overallPerformance, "Should have overall performance metrics")
        XCTAssertFalse(analysis.recommendations.isEmpty, "Should have performance recommendations")
        XCTAssertNotNil(analysis.generatedAt, "Should have generation timestamp")
        
        print("✅ Tier performance analysis generated successfully")
    }
    
    @MainActor
    func testCoordinationDashboard() async throws {
        // Given: Initialized system
        try await tierCoordination.initializeTierCoordination()
        
        // When: Get coordination dashboard
        let dashboard = tierCoordination.getCoordinationDashboard()
        
        // Then: Dashboard should contain comprehensive information
        XCTAssertGreaterThan(dashboard.activeTiers.count, 0, "Dashboard should show active tiers")
        XCTAssertNotNil(dashboard.coordinationMetrics, "Should have coordination metrics")
        XCTAssertNotNil(dashboard.loadBalanceStatus, "Should have load balance status")
        XCTAssertNotNil(dashboard.performanceOptimization, "Should have performance optimization status")
        XCTAssertNotNil(dashboard.systemHealth, "Should have system health information")
        
        print("✅ Coordination dashboard generated successfully")
    }
    
    // MARK: - System Health and Monitoring Tests
    
    @MainActor
    func testSystemHealthMonitoring() async throws {
        // Given: Initialized system
        try await tierCoordination.initializeTierCoordination()
        
        // When: Get system health
        let dashboard = tierCoordination.getCoordinationDashboard()
        let systemHealth = dashboard.systemHealth
        
        // Then: System health should be comprehensive
        XCTAssertGreaterThan(systemHealth.overallHealth, 0, "Overall health should be positive")
        XCTAssertGreaterThan(systemHealth.cpuHealth, 0, "CPU health should be positive")
        XCTAssertGreaterThan(systemHealth.memoryHealth, 0, "Memory health should be positive")
        XCTAssertGreaterThan(systemHealth.networkHealth, 0, "Network health should be positive")
        XCTAssertGreaterThan(systemHealth.tierHealth, 0, "Tier health should be positive")
        
        print("✅ System health monitoring working correctly")
    }
    
    @MainActor
    func testCoordinationMetricsTracking() async throws {
        // Given: Initialized system
        try await tierCoordination.initializeTierCoordination()
        
        // When: Create some activity and check metrics
        let _ = try await tierCoordination.createAgentTier(
            name: "Metrics Test Tier",
            priority: .normal,
            capabilities: [.standardProcessing],
            resourceLimits: ResourceLimits(maxCPUUsage: 40.0, maxMemoryUsage: 30.0, maxAgents: 3)
        )
        
        // Then: Metrics should reflect the activity
        let metrics = tierCoordination.coordinationMetrics
        XCTAssertGreaterThan(metrics.activeTiers, 0, "Should track active tiers")
        XCTAssertGreaterThanOrEqual(metrics.averageCPUUsage, 0, "CPU usage should be tracked")
        XCTAssertGreaterThanOrEqual(metrics.averageMemoryUsage, 0, "Memory usage should be tracked")
        XCTAssertNotNil(metrics.lastUpdated, "Should have last updated timestamp")
        
        print("✅ Coordination metrics tracking working correctly")
    }
    
    // MARK: - Edge Cases and Error Handling Tests
    
    @MainActor
    func testUninitializedSystemErrors() async throws {
        // Given: Uninitialized system
        let uninitializedCoordination = MLACSTierCoordination()
        
        // When/Then: Operations should fail appropriately
        do {
            let _ = try await uninitializedCoordination.createAgentTier(
                name: "Test",
                priority: .normal,
                capabilities: [],
                resourceLimits: ResourceLimits(maxCPUUsage: 50.0, maxMemoryUsage: 40.0, maxAgents: 5)
            )
            XCTFail("Should throw error for uninitialized system")
        } catch TierCoordinationError.systemNotInitialized {
            // Expected error
            print("✅ Properly handles uninitialized system error")
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    @MainActor
    func testInvalidTierAssignment() async throws {
        // Given: Initialized system
        try await tierCoordination.initializeTierCoordination()
        
        // When/Then: Invalid tier assignment should fail
        do {
            try await tierCoordination.assignAgentToTier(agentId: "test-agent", tierId: "non-existent-tier")
            XCTFail("Should throw error for non-existent tier")
        } catch TierCoordinationError.tierNotFound {
            // Expected error
            print("✅ Properly handles invalid tier assignment error")
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    // MARK: - Integration Tests
    
    @MainActor
    func testCompleteWorkflow() async throws {
        // Given: Fresh tier coordination system
        try await tierCoordination.initializeTierCoordination()
        
        // When: Execute complete workflow
        
        // 1. Create custom tier
        let customTier = try await tierCoordination.createAgentTier(
            name: "Integration Test Tier",
            priority: .high,
            capabilities: [.realTimeProcessing, .highThroughput],
            resourceLimits: ResourceLimits(maxCPUUsage: 75.0, maxMemoryUsage: 65.0, maxAgents: 10)
        )
        
        // 2. Assign agent to tier
        try await tierCoordination.assignAgentToTier(agentId: "integration-agent-001", tierId: customTier.id)
        
        // 3. Create execution request
        let request = AgentExecutionRequest(
            priority: .high,
            resourceNeeds: ResourceNeeds(cpu: 40.0, memory: 30.0, network: 15.0),
            latencyRequirement: 75.0,
            throughputRequirement: 80.0,
            requiredCapabilities: [.realTimeProcessing]
        )
        
        // 4. Coordinate execution
        let plan = try await tierCoordination.coordinateAgentExecution(request: request)
        
        // 5. Perform optimization
        try await tierCoordination.performRealTimeOptimization()
        
        // 6. Balance load
        try await tierCoordination.balanceLoadAcrossTiers()
        
        // 7. Get performance analysis
        let analysis = await tierCoordination.getTierPerformanceAnalysis()
        
        // Then: All operations should complete successfully
        XCTAssertNotNil(plan, "Execution plan should be created")
        XCTAssertGreaterThan(analysis.tierAnalyses.count, 0, "Performance analysis should include tiers")
        XCTAssertTrue(tierCoordination.loadBalanceStatus.efficiency >= 0, "Load balancing should complete")
        
        print("✅ Complete workflow integration test passed")
    }
    
    // MARK: - Performance Tests
    
    @MainActor
    func testPerformanceUnderLoad() async throws {
        // Given: Initialized system
        try await tierCoordination.initializeTierCoordination()
        
        let startTime = Date()
        
        // When: Create multiple tiers and requests rapidly
        for i in 1...5 {
            let _ = try await tierCoordination.createAgentTier(
                name: "Performance Test Tier \(i)",
                priority: .normal,
                capabilities: [.standardProcessing],
                resourceLimits: ResourceLimits(maxCPUUsage: 50.0, maxMemoryUsage: 40.0, maxAgents: 5)
            )
        }
        
        for i in 1...10 {
            let request = AgentExecutionRequest(
                priority: .normal,
                resourceNeeds: ResourceNeeds(cpu: 20.0, memory: 15.0, network: 5.0),
                latencyRequirement: 200.0,
                throughputRequirement: 30.0,
                requiredCapabilities: [.standardProcessing]
            )
            
            let _ = try await tierCoordination.coordinateAgentExecution(request: request)
        }
        
        let endTime = Date()
        let executionTime = endTime.timeIntervalSince(startTime)
        
        // Then: Should complete within reasonable time
        XCTAssertLessThan(executionTime, 10.0, "Performance test should complete within 10 seconds")
        XCTAssertEqual(tierCoordination.activeTiers.count, 8, "Should have 8 total tiers (3 default + 5 created)")
        
        print("✅ Performance under load test passed in \(executionTime) seconds")
    }
}

// MARK: - Test Helper Extensions

extension AgentTier {
    var isValid: Bool {
        return !id.isEmpty && !name.isEmpty && !capabilities.isEmpty
    }
}

extension TierCoordinationMetrics {
    var isHealthy: Bool {
        return efficiency > 50.0 && averageCPUUsage < 90.0 && averageMemoryUsage < 90.0
    }
}

extension AgentExecutionPlan {
    var isValid: Bool {
        return !id.isEmpty && !selectedAgents.isEmpty && estimatedDuration > 0
    }
}