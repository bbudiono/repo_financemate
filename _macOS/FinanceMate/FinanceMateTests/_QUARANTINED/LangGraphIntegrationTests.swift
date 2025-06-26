/**
 * Purpose: Comprehensive tests for LangGraph integration components
 * Issues & Complexity Summary: Complex testing of multi-agent coordination and framework integration
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~800
 *   - Core Algorithm Complexity: High
 *   - Dependencies: 10 New, 6 Mod
 *   - State Management Complexity: High
 *   - Novelty/Uncertainty Factor: Medium
 * AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 80%
 * Problem Estimate (Inherent Problem Difficulty %): 75%
 * Initial Code Complexity Estimate %: 80%
 * Justification for Estimates: Testing complex multi-framework coordination requires comprehensive scenarios
 * Final Code Complexity (Actual %): TBD
 * Overall Result Score (Success & Quality %): TBD
 * Key Variances/Learnings: TBD
 * Last Updated: 2025-06-02
 */

import XCTest
import Foundation
import Combine
@testable import FinanceMate

final class LangGraphIntegrationTests: XCTestCase {

    // MARK: - Test Properties

    private var intelligentCoordinator: IntelligentFrameworkCoordinator!
    private var langGraphSystem: LangGraphMultiAgentSystem!
    private var stateBridge: FrameworkStateBridge!
    private var tierManager: TierBasedFrameworkManager!
    private var systemIntegrator: FinanceMateSystemIntegrator!
    private var decisionEngine: FrameworkDecisionEngine!

    private var cancellables: Set<AnyCancellable>!

    // MARK: - Setup & Teardown

    override func setUp() async throws {
        try await super.setUp()

        // Initialize components for testing
        intelligentCoordinator = IntelligentFrameworkCoordinator(userTier: .pro)
        langGraphSystem = LangGraphMultiAgentSystem(userTier: .pro)
        stateBridge = FrameworkStateBridge()
        tierManager = TierBasedFrameworkManager(userTier: .pro)
        systemIntegrator = FinanceMateSystemIntegrator(userTier: .pro)
        decisionEngine = FrameworkDecisionEngine()

        cancellables = Set<AnyCancellable>()

        // Wait for initialization
        try await Task.sleep(nanoseconds: 500_000_000) // 500ms
    }

    override func tearDown() async throws {
        // Cleanup
        await intelligentCoordinator?.cleanup() ?? ()
        await langGraphSystem?.shutdown()

        cancellables?.removeAll()

        intelligentCoordinator = nil
        langGraphSystem = nil
        stateBridge = nil
        tierManager = nil
        systemIntegrator = nil
        decisionEngine = nil
        cancellables = nil

        try await super.tearDown()
    }

    // MARK: - Intelligent Framework Coordinator Tests

    func testIntelligentFrameworkCoordinatorInitialization() async throws {
        XCTAssertNotNil(intelligentCoordinator)
        XCTAssertEqual(intelligentCoordinator.userTier, .pro)

        // Wait for coordinator to be ready
        let expectation = XCTestExpectation(description: "Coordinator ready")

        intelligentCoordinator.$executionStatus
            .sink { status in
                if case .idle = status {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        await fulfillment(of: [expectation], timeout: 5.0)
    }

    func testFrameworkSelectionForSimpleTask() async throws {
        let simpleTask = createTestTask(complexity: .low, requiresMultiAgent: false)

        let decision = try await intelligentCoordinator.analyzeAndRouteTask(simpleTask)

        XCTAssertNotNil(decision)
        XCTAssertEqual(decision.primaryFramework, .langchain)
        XCTAssertGreaterThan(decision.tierOptimizations.availableFeatures.count, 0)
        XCTAssertTrue(decision.tierOptimizations.availableFeatures.contains("advanced_processing"))
    }

    func testFrameworkSelectionForComplexTask() async throws {
        let complexTask = createTestTask(complexity: .high, requiresMultiAgent: true)

        let decision = try await intelligentCoordinator.analyzeAndRouteTask(complexTask)

        XCTAssertNotNil(decision)
        XCTAssertEqual(decision.primaryFramework, .langgraph)
        XCTAssertGreaterThan(decision.tierOptimizations.availableFeatures.count, 0)
    }

    func testHybridFrameworkSelection() async throws {
        let hybridTask = createTestTask(complexity: .medium, requiresMultiAgent: true, hasConditionalLogic: true)

        let decision = try await intelligentCoordinator.analyzeAndRouteTask(hybridTask)

        XCTAssertNotNil(decision)
        // Should select hybrid or langgraph for medium complexity with multi-agent
        XCTAssertTrue([.hybrid, .langgraph].contains(decision.primaryFramework))
    }

    // MARK: - LangGraph Multi-Agent System Tests

    func testLangGraphSystemInitialization() async throws {
        XCTAssertNotNil(langGraphSystem)
        XCTAssertEqual(langGraphSystem.systemStatus, .idle)
    }

    func testLangGraphWorkflowExecution() async throws {
        let task = createTestTask(complexity: .medium, requiresMultiAgent: true)

        let result = try await langGraphSystem.executeWorkflow(for: task)

        XCTAssertNotNil(result)
        XCTAssertTrue(result.success)
        XCTAssertEqual(result.taskId, task.id)
        XCTAssertGreaterThan(result.executionTime, 0)
    }

    func testLangGraphStateManagement() async throws {
        let task = createTestTask(complexity: .high, requiresMultiAgent: true)

        // Execute workflow and verify state management
        let result = try await langGraphSystem.executeWorkflow(for: task)

        XCTAssertTrue(result.success)
        XCTAssertNotNil(result.result)
    }

    // MARK: - Framework State Bridge Tests

    func testStateBridgeInitialization() async throws {
        XCTAssertNotNil(stateBridge)
        XCTAssertEqual(stateBridge.bridgeStatus, .ready)
    }

    func testLangGraphToLangChainConversion() async throws {
        let originalState = FinanceMateWorkflowState(taskId: "test_conversion")

        let convertedState = try await stateBridge.convertToLangChainFormat(originalState)

        XCTAssertNotNil(convertedState)
        XCTAssertEqual(convertedState.id, originalState.id)
    }

    func testLangChainToLangGraphConversion() async throws {
        let originalState = FinanceMateWorkflowState(taskId: "test_conversion_back")

        // Convert to LangChain format
        let langChainState = try await stateBridge.convertToLangChainFormat(originalState)

        // Convert back to LangGraph format
        let restoredState = try await stateBridge.convertFromLangChainFormat(
            langChainState,
            originalLangGraphState: originalState
        )

        XCTAssertEqual(restoredState.id, originalState.id)
        XCTAssertEqual(restoredState.currentStep, originalState.currentStep)
    }

    func testHybridStateCreation() async throws {
        let langGraphState = FinanceMateWorkflowState(taskId: "hybrid_test")
        let langChainState = LangChainCompatibleState(
            id: langGraphState.id,
            chainResults: [:],
            memory: ChainMemory(conversationHistory: [], context: [:], retrievedDocuments: []),
            toolResults: [],
            metadata: [:],
            lastModified: Date()
        )

        let hybridState = try await stateBridge.createHybridState(
            langGraphState: langGraphState,
            langChainState: langChainState
        )

        XCTAssertEqual(hybridState.langGraphState.id, langGraphState.id)
        XCTAssertEqual(hybridState.langChainState.id, langChainState.id)
        XCTAssertEqual(hybridState.synchronizationStatus, .synchronized)
    }

    // MARK: - Tier-Based Framework Manager Tests

    func testTierManagerInitialization() async throws {
        XCTAssertNotNil(tierManager)
        XCTAssertEqual(tierManager.currentTier, .pro)
        XCTAssertEqual(tierManager.tierStatus, .active)
    }

    func testTierFeatureAvailability() async throws {
        // Pro tier should have advanced features
        XCTAssertTrue(tierManager.isFeatureAvailable(.advancedProcessing))
        XCTAssertTrue(tierManager.isFeatureAvailable(.multiAgentCoordination))
        XCTAssertTrue(tierManager.isFeatureAvailable(.sessionMemory))

        // Pro tier should not have enterprise-only features
        XCTAssertFalse(tierManager.isFeatureAvailable(.longTermMemory))
        XCTAssertFalse(tierManager.isFeatureAvailable(.customAgents))
    }

    func testTierFrameworkAccess() async throws {
        // Pro tier should have access to all frameworks
        XCTAssertTrue(tierManager.canUseFramework(.langchain))
        XCTAssertTrue(tierManager.canUseFramework(.langgraph))
        XCTAssertTrue(tierManager.canUseFramework(.hybrid))
    }

    func testTierAgentAllocation() async throws {
        // Pro tier should allow up to 5 agents
        XCTAssertTrue(tierManager.canAllocateAgents(3))
        XCTAssertTrue(tierManager.canAllocateAgents(5))
        XCTAssertFalse(tierManager.canAllocateAgents(10)) // Over limit
    }

    func testTierUpgrade() async throws {
        await tierManager.upgradeTier(to: .enterprise)

        XCTAssertEqual(tierManager.currentTier, .enterprise)
        XCTAssertTrue(tierManager.isFeatureAvailable(.longTermMemory))
        XCTAssertTrue(tierManager.canAllocateAgents(15))
    }

    // MARK: - System Integration Tests

    func testSystemIntegratorInitialization() async throws {
        XCTAssertNotNil(systemIntegrator)

        // Wait for integration to complete
        let expectation = XCTestExpectation(description: "Integration ready")

        systemIntegrator.$integrationStatus
            .sink { status in
                if case .ready = status {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        await fulfillment(of: [expectation], timeout: 10.0)
    }

    func testDocumentProcessingIntegration() async throws {
        // Wait for system to be ready
        try await waitForSystemReady()

        let testDocument = "Sample invoice content".data(using: .utf8)!
        let options = ProcessingOptions(
            filename: "test_invoice.txt",
            realTimeProcessing: false,
            storeLongTerm: false,
            enableParallelProcessing: true,
            maxExecutionTime: 30.0,
            memoryLimit: 1024 * 1024 * 100,
            priority: .normal,
            enableVectorSearch: false
        )

        let result = try await systemIntegrator.processDocument(
            documentData: testDocument,
            documentType: .invoice,
            processingOptions: options
        )

        XCTAssertNotNil(result)
        XCTAssertTrue(result.success)
        XCTAssertEqual(result.documentType, .invoice)
        XCTAssertGreaterThan(result.processingTime, 0)
    }

    func testBatchDocumentProcessing() async throws {
        try await waitForSystemReady()

        let documents = [
            DocumentBatch(
                id: "batch_1",
                documents: [
                    "Invoice 1".data(using: .utf8)!,
                    "Invoice 2".data(using: .utf8)!
                ],
                documentTypes: [.invoice, .invoice],
                batchOptions: ProcessingOptions(
                    filename: nil,
                    realTimeProcessing: false,
                    storeLongTerm: false,
                    enableParallelProcessing: true,
                    maxExecutionTime: 60.0,
                    memoryLimit: 1024 * 1024 * 200,
                    priority: .normal,
                    enableVectorSearch: false
                )
            )
        ]

        let batchOptions = BatchProcessingOptions(
            maxConcurrentDocuments: 3,
            prioritizeByType: true,
            enableLoadBalancing: true,
            timeoutPerDocument: 30.0
        )

        let result = try await systemIntegrator.processBatchDocuments(
            documents: documents,
            batchOptions: batchOptions
        )

        XCTAssertNotNil(result)
        XCTAssertEqual(result.totalDocuments, 2)
    }

    // MARK: - Agent Tests

    func testOCRAgentInitialization() async throws {
        let ocrAgent = FinanceMateOCRAgent(userTier: .pro)

        XCTAssertEqual(ocrAgent.id, "financemate_ocr_agent")
        XCTAssertEqual(ocrAgent.name, "FinanceMate OCR Agent")
        XCTAssertEqual(ocrAgent.userTier, .pro)
        XCTAssertEqual(ocrAgent.status, .idle)
        XCTAssertTrue(ocrAgent.capabilities.contains("document_ocr"))
    }

    func testValidationAgentInitialization() async throws {
        let validationAgent = FinanceMateValidationAgent(userTier: .pro)

        XCTAssertEqual(validationAgent.id, "financemate_validation_agent")
        XCTAssertEqual(validationAgent.name, "FinanceMate Validation Agent")
        XCTAssertEqual(validationAgent.userTier, .pro)
        XCTAssertTrue(validationAgent.capabilities.contains("data_validation"))
    }

    func testDataExtractionAgentInitialization() async throws {
        let extractionAgent = FinanceMateDataExtractionAgent(userTier: .pro)

        XCTAssertEqual(extractionAgent.id, "financemate_extraction_agent")
        XCTAssertEqual(extractionAgent.name, "FinanceMate Data Extraction Agent")
        XCTAssertEqual(extractionAgent.userTier, .pro)
        XCTAssertTrue(extractionAgent.capabilities.contains("structured_extraction"))
    }

    func testAgentTaskHandling() async throws {
        let ocrAgent = FinanceMateOCRAgent(userTier: .pro)

        let ocrTask = AgentTask(
            id: "ocr_test",
            type: .documentProcessing,
            priority: .normal,
            input: [:],
            requirements: TaskRequirements(
                requiredCapabilities: ["document_ocr"],
                minimumTier: .free,
                resourceLimits: ResourceLimits(
                    maxExecutionTime: 30.0,
                    maxMemoryUsage: 1024 * 1024 * 100,
                    maxConcurrentOperations: 2
                ),
                qualityThresholds: QualityThresholds(
                    minimumAccuracy: 0.8,
                    minimumConfidence: 0.7,
                    minimumCompleteness: 0.9
                )
            ),
            deadline: nil
        )

        XCTAssertTrue(ocrAgent.canHandle(task: ocrTask))

        let validationTask = AgentTask(
            id: "validation_test",
            type: .validation,
            priority: .normal,
            input: [:],
            requirements: TaskRequirements(
                requiredCapabilities: ["data_validation"],
                minimumTier: .free,
                resourceLimits: ResourceLimits(
                    maxExecutionTime: 30.0,
                    maxMemoryUsage: 1024 * 1024 * 50,
                    maxConcurrentOperations: 1
                ),
                qualityThresholds: QualityThresholds(
                    minimumAccuracy: 0.9,
                    minimumConfidence: 0.8,
                    minimumCompleteness: 0.95
                )
            ),
            deadline: nil
        )

        XCTAssertFalse(ocrAgent.canHandle(task: validationTask))
    }

    // MARK: - Decision Engine Tests

    func testDecisionEngineInitialization() async throws {
        XCTAssertNotNil(decisionEngine)
        XCTAssertEqual(decisionEngine.engineStatus, .initializing)

        // Wait for engine to be ready
        let expectation = XCTestExpectation(description: "Engine ready")

        decisionEngine.$engineStatus
            .sink { status in
                if case .ready = status {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        await fulfillment(of: [expectation], timeout: 10.0)
    }

    func testDecisionEngineFrameworkSelection() async throws {
        // Wait for engine to be ready
        try await waitForDecisionEngineReady()

        let decision = try await decisionEngine.selectFramework(
            taskComplexity: .medium,
            stateRequirements: .complex,
            coordinationPatterns: .multiAgent,
            userTier: .pro,
            performanceRequirements: PerformanceRequirement(
                maxExecutionTime: 300.0,
                memoryLimit: 1024 * 1024 * 512,
                requiresRealTime: false,
                priorityLevel: .normal
            ),
            multiAgentRequirements: MultiAgentRequirement(
                agentCount: 3,
                requiresCoordination: true,
                conflictResolutionNeeded: false,
                sharedStateRequired: true,
                dynamicAgentAllocation: false
            )
        )

        XCTAssertNotNil(decision)
        XCTAssertGreaterThan(decision.confidence, 0.5)
        XCTAssertTrue([.langgraph, .hybrid].contains(decision.primaryFramework))
    }

    // MARK: - Performance Tests

    func testFrameworkSelectionPerformance() async throws {
        try await waitForDecisionEngineReady()

        let startTime = Date()
        let iterations = 100

        for i in 0..<iterations {
            _ = try await decisionEngine.selectFramework(
                taskComplexity: .medium,
                stateRequirements: .moderate,
                coordinationPatterns: .sequential,
                userTier: .pro,
                performanceRequirements: PerformanceRequirement(
                    maxExecutionTime: 60.0,
                    memoryLimit: 1024 * 1024 * 256,
                    requiresRealTime: false,
                    priorityLevel: .normal
                ),
                multiAgentRequirements: MultiAgentRequirement(
                    agentCount: 2,
                    requiresCoordination: false,
                    conflictResolutionNeeded: false,
                    sharedStateRequired: false,
                    dynamicAgentAllocation: false
                )
            )
        }

        let executionTime = Date().timeIntervalSince(startTime)
        let averageTime = executionTime / Double(iterations)

        // Average decision time should be less than 100ms
        XCTAssertLessThan(averageTime, 0.1)

        print("Framework selection performance: \(averageTime)s average over \(iterations) iterations")
    }

    func testStateConversionPerformance() async throws {
        let iterations = 50
        let startTime = Date()

        for i in 0..<iterations {
            let state = FinanceMateWorkflowState(taskId: "perf_test_\(i)")
            let langChainState = try await stateBridge.convertToLangChainFormat(state)
            _ = try await stateBridge.convertFromLangChainFormat(langChainState, originalLangGraphState: state)
        }

        let executionTime = Date().timeIntervalSince(startTime)
        let averageTime = executionTime / Double(iterations)

        // Average conversion time should be less than 50ms
        XCTAssertLessThan(averageTime, 0.05)

        print("State conversion performance: \(averageTime)s average over \(iterations) iterations")
    }

    // MARK: - Error Handling Tests

    func testInvalidTaskHandling() async throws {
        let invalidTask = ComplexTask(
            id: "",
            name: "",
            description: "",
            documentTypes: [],
            processingSteps: [],
            requiresMultiAgentCoordination: false,
            hasConditionalLogic: false,
            requiresRealTimeProcessing: false,
            requiresLongTermMemory: false,
            hasComplexStateMachine: false,
            requiresSessionContext: false,
            hasIntermediateStates: false,
            requiresBasicContext: false,
            requiresHierarchicalCoordination: false,
            hasDynamicWorkflow: false,
            hasParallelProcessing: false,
            maxExecutionTime: -1.0, // Invalid
            memoryLimit: 0,
            priority: .normal,
            conditionalBranches: [],
            hasIterativeProcessing: false,
            requiresFeedbackLoops: false,
            estimatedAgentCount: -1, // Invalid
            hasConflictingAgentGoals: false,
            requiresSharedState: false,
            requiresDynamicAgentAllocation: false,
            requiresVectorSearch: false,
            hasCustomMemoryNeeds: false,
            hasVectorOperations: false,
            requiresMachineLearning: false,
            hasLargeDataProcessing: false
        )

        do {
            _ = try await intelligentCoordinator.analyzeAndRouteTask(invalidTask)
            XCTFail("Should have thrown an error for invalid task")
        } catch {
            // Expected error
            XCTAssertNotNil(error)
        }
    }

    // MARK: - Integration Test Helpers

    private func createTestTask(
        complexity: ComplexityLevel,
        requiresMultiAgent: Bool,
        hasConditionalLogic: Bool = false
    ) -> ComplexTask {
        return ComplexTask(
            id: UUID().uuidString,
            name: "Test Task",
            description: "Test task for framework selection",
            documentTypes: [.invoice],
            processingSteps: [
                ComplexTask.ProcessingStep(id: "step1", name: "Process", estimatedDuration: 5.0, dependencies: [])
            ],
            requiresMultiAgentCoordination: requiresMultiAgent,
            hasConditionalLogic: hasConditionalLogic,
            requiresRealTimeProcessing: false,
            requiresLongTermMemory: false,
            hasComplexStateMachine: complexity == .high,
            requiresSessionContext: true,
            hasIntermediateStates: true,
            requiresBasicContext: true,
            requiresHierarchicalCoordination: false,
            hasDynamicWorkflow: complexity == .high,
            hasParallelProcessing: requiresMultiAgent,
            maxExecutionTime: 60.0,
            memoryLimit: 1024 * 1024 * 256,
            priority: .normal,
            conditionalBranches: hasConditionalLogic ? [
                ComplexTask.ConditionalBranch(
                    condition: "test_condition",
                    truePath: ["true_path"],
                    falsePath: ["false_path"]
                )
            ] : [],
            hasIterativeProcessing: complexity == .high,
            requiresFeedbackLoops: complexity == .high,
            estimatedAgentCount: requiresMultiAgent ? 3 : 1,
            hasConflictingAgentGoals: false,
            requiresSharedState: requiresMultiAgent,
            requiresDynamicAgentAllocation: requiresMultiAgent,
            requiresVectorSearch: false,
            hasCustomMemoryNeeds: false,
            hasVectorOperations: complexity == .high,
            requiresMachineLearning: complexity == .high,
            hasLargeDataProcessing: false
        )
    }

    private func waitForSystemReady() async throws {
        let expectation = XCTestExpectation(description: "System ready")

        systemIntegrator.$integrationStatus
            .sink { status in
                if case .ready = status {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        await fulfillment(of: [expectation], timeout: 15.0)
    }

    private func waitForDecisionEngineReady() async throws {
        let expectation = XCTestExpectation(description: "Decision engine ready")

        decisionEngine.$engineStatus
            .sink { status in
                if case .ready = status {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        await fulfillment(of: [expectation], timeout: 10.0)
    }
}

// MARK: - Test Extensions

extension IntelligentFrameworkCoordinator {
    fileprivate func cleanup() async {
        // Cleanup coordinator resources
    }
}
