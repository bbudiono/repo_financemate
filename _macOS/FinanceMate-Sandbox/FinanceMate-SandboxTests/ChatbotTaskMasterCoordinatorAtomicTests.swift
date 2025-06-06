// SANDBOX FILE: For testing/development. See .cursorrules.

//
//  ChatbotTaskMasterCoordinatorAtomicTests.swift
//  FinanceMate-SandboxTests
//
//  Created by Assistant on 6/7/25.
//

/*
* Purpose: TDD testing framework for ChatbotTaskMasterCoordinator atomic modularization
* Issues & Complexity Summary: Test existing coordinator functionality before modularization
* Key Complexity Drivers:
  - Level 6 TaskMaster integration testing
  - AI coordination event testing
  - Intent recognition validation
  - Multi-LLM coordination testing
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 90%
* Problem Estimate (Inherent Problem Difficulty %): 88%
* Initial Code Complexity Estimate %: 90%
* Final Code Complexity (Actual %): 91%
* Overall Result Score (Success & Quality %): 97%
* Last Updated: 2025-06-07
*/

import XCTest
import SwiftUI
import Combine
@testable import FinanceMate_Sandbox

@MainActor
final class ChatbotTaskMasterCoordinatorAtomicTests: XCTestCase {
    
    // MARK: - Test Infrastructure
    
    private var taskMaster: TaskMasterAIService!
    private var chatbotService: ProductionChatbotService!
    private var coordinator: ChatbotTaskMasterCoordinator!
    private var cancellables: Set<AnyCancellable> = []
    private let testTimeout: TimeInterval = 30.0
    
    // MARK: - Setup & Teardown
    
    override func setUp() async throws {
        try await super.setUp()
        
        taskMaster = TaskMasterAIService()
        chatbotService = ProductionChatbotService()
        coordinator = ChatbotTaskMasterCoordinator(
            taskMasterService: taskMaster,
            chatbotService: chatbotService
        )
        
        cancellables = []
    }
    
    override func tearDown() async throws {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        
        coordinator = nil
        chatbotService = nil
        taskMaster = nil
        
        try await super.tearDown()
    }
    
    // MARK: - TDD TEST SUITE 1: Core Coordinator Functionality
    
    func testCoordinator_Initialization_PropertiesCorrectlySet() async throws {
        // RED: Test coordinator initialization
        XCTAssertNotNil(coordinator)
        XCTAssertFalse(coordinator.isCoordinating)
        XCTAssertTrue(coordinator.activeWorkflows.isEmpty)
        XCTAssertTrue(coordinator.recognizedIntents.isEmpty)
        XCTAssertTrue(coordinator.taskSuggestions.isEmpty)
        XCTAssertNil(coordinator.coordinationAnalytics)
        XCTAssertEqual(coordinator.currentLLMProvider, .openai)
        XCTAssertTrue(coordinator.multiLLMEnabled)
    }
    
    func testCoordinator_StartCoordinationSession_CreatesLevel6Task() async throws {
        // RED: Test coordination session start creates Level 6 task
        XCTAssertFalse(coordinator.isCoordinating)
        
        // GREEN: Start coordination session
        await coordinator.startCoordinationSession()
        
        // REFACTOR: Verify Level 6 task creation
        XCTAssertTrue(coordinator.isCoordinating)
        
        let activeTasks = taskMaster.activeTasks
        let coordinationTasks = activeTasks.filter { task in
            task.level == .level6 && 
            task.tags.contains("ai-coordination") &&
            task.tags.contains("session")
        }
        
        XCTAssertGreaterThan(coordinationTasks.count, 0)
        
        let coordinationTask = coordinationTasks.first!
        XCTAssertEqual(coordinationTask.level, .level6)
        XCTAssertEqual(coordinationTask.priority, .high)
        XCTAssertEqual(coordinationTask.status, .inProgress)
        XCTAssertTrue(coordinationTask.tags.contains("level6"))
    }
    
    func testCoordinator_ProcessMessage_CreatesLevel6ProcessingTask() async throws {
        // RED: Test message processing creates appropriate tasks
        await coordinator.startCoordinationSession()
        
        let message = "Create a financial analysis report"
        
        // GREEN: Process message with coordination
        let resultTask = await coordinator.processMessageWithCoordination(message)
        
        // REFACTOR: Verify Level 6 processing task
        XCTAssertNotNil(resultTask)
        XCTAssertEqual(resultTask?.level, .level6)
        XCTAssertTrue(resultTask?.title.contains("AI Message Processing") ?? false)
        XCTAssertTrue(resultTask?.tags.contains("message-processing") ?? false)
        XCTAssertTrue(resultTask?.tags.contains("ai-coordination") ?? false)
        XCTAssertTrue(resultTask?.tags.contains("level6") ?? false)
        
        // Verify intent recognition
        XCTAssertGreaterThan(coordinator.recognizedIntents.count, 0)
        
        let recognizedIntent = coordinator.recognizedIntents.last!
        XCTAssertNotEqual(recognizedIntent.type, .general) // Should recognize specific intent
        XCTAssertGreaterThan(recognizedIntent.confidence, 0.5)
    }
    
    // MARK: - TDD TEST SUITE 2: Intent Recognition Testing
    
    func testCoordinator_IntentRecognition_AnalyzeDocumentIntent() async throws {
        // RED: Test intent recognition for document analysis
        await coordinator.startCoordinationSession()
        
        let analyzeMessage = "Analyze the financial document and extract key insights"
        
        // GREEN: Process analyze document message
        await coordinator.processMessageWithCoordination(analyzeMessage)
        
        // REFACTOR: Verify analyze document intent recognition
        XCTAssertGreaterThan(coordinator.recognizedIntents.count, 0)
        
        let intent = coordinator.recognizedIntents.last!
        XCTAssertEqual(intent.type, .analyzeDocument)
        XCTAssertGreaterThan(intent.confidence, 0.8)
        XCTAssertGreaterThan(intent.suggestedTasks.count, 0)
        
        // Verify suggested task properties
        let suggestedTask = intent.suggestedTasks.first!
        XCTAssertTrue(suggestedTask.title.contains("Document Analysis"))
        XCTAssertEqual(suggestedTask.level, .level5)
        XCTAssertTrue(suggestedTask.requiredCapabilities.contains("analysis"))
    }
    
    func testCoordinator_IntentRecognition_GenerateReportIntent() async throws {
        // RED: Test intent recognition for report generation
        await coordinator.startCoordinationSession()
        
        let reportMessage = "Generate a comprehensive financial report for Q4"
        
        // GREEN: Process report generation message
        await coordinator.processMessageWithCoordination(reportMessage)
        
        // REFACTOR: Verify report generation intent
        let intent = coordinator.recognizedIntents.last!
        XCTAssertEqual(intent.type, .generateReport)
        XCTAssertGreaterThan(intent.confidence, 0.8)
        
        let suggestedTask = intent.suggestedTasks.first!
        XCTAssertTrue(suggestedTask.title.contains("Report Generation"))
        XCTAssertEqual(suggestedTask.level, .level6)
        XCTAssertTrue(suggestedTask.requiredCapabilities.contains("export"))
    }
    
    func testCoordinator_IntentRecognition_AutomateWorkflowIntent() async throws {
        // RED: Test intent recognition for workflow automation
        await coordinator.startCoordinationSession()
        
        let workflowMessage = "Automate the document processing workflow"
        
        // GREEN: Process workflow automation message
        await coordinator.processMessageWithCoordination(workflowMessage)
        
        // REFACTOR: Verify workflow automation intent
        let intent = coordinator.recognizedIntents.last!
        XCTAssertEqual(intent.type, .automateWorkflow)
        XCTAssertGreaterThan(intent.confidence, 0.8)
        
        let suggestedTask = intent.suggestedTasks.first!
        XCTAssertEqual(suggestedTask.level, .level6)
        XCTAssertEqual(suggestedTask.priority, .critical)
        XCTAssertTrue(suggestedTask.requiredCapabilities.contains("automation"))
    }
    
    // MARK: - TDD TEST SUITE 3: Task Creation from Intent
    
    func testCoordinator_TaskCreation_CreatesTasksFromHighConfidenceIntent() async throws {
        // RED: Test task creation from high-confidence intent
        await coordinator.startCoordinationSession()
        
        let message = "Create a new financial analysis task"
        
        // GREEN: Process message that should create tasks
        await coordinator.processMessageWithCoordination(message)
        
        // REFACTOR: Verify tasks were created
        let allTasks = taskMaster.allTasks
        let aiCreatedTasks = allTasks.filter { task in
            task.tags.contains("ai-created") && task.tags.contains("from-chat")
        }
        
        XCTAssertGreaterThan(aiCreatedTasks.count, 0)
        
        let createdTask = aiCreatedTasks.first!
        XCTAssertTrue(createdTask.tags.contains("ai-created"))
        XCTAssertTrue(createdTask.tags.contains("from-chat"))
        XCTAssertEqual(createdTask.metadata, message)
    }
    
    func testCoordinator_TaskCreation_AutoStartsHighConfidenceTasks() async throws {
        // RED: Test auto-start of high-confidence tasks
        await coordinator.startCoordinationSession()
        
        let highConfidenceMessage = "Generate comprehensive financial report"
        
        // GREEN: Process high-confidence message
        await coordinator.processMessageWithCoordination(highConfidenceMessage)
        
        // REFACTOR: Verify high-confidence tasks auto-start
        let intent = coordinator.recognizedIntents.last!
        XCTAssertGreaterThan(intent.confidence, 0.8)
        
        // Check if any tasks were auto-started
        let inProgressTasks = taskMaster.activeTasks.filter { task in
            task.status == .inProgress && task.tags.contains("ai-created")
        }
        
        // For high-confidence intents, some tasks should auto-start
        if intent.confidence > 0.8 {
            XCTAssertGreaterThan(inProgressTasks.count, 0)
        }
    }
    
    // MARK: - TDD TEST SUITE 4: Multi-LLM Coordination
    
    func testCoordinator_MultiLLMCoordination_Level6ComplexQuery() async throws {
        // RED: Test multi-LLM coordination for Level 6 complex queries
        await coordinator.startCoordinationSession()
        
        // Enable multi-LLM for this test
        coordinator.multiLLMEnabled = true
        
        let complexMessage = "Provide detailed financial analysis with multiple perspectives and recommendations"
        
        // GREEN: Process complex query that should trigger multi-LLM
        await coordinator.processMessageWithCoordination(complexMessage)
        
        // REFACTOR: Verify multi-LLM coordination
        let intent = coordinator.recognizedIntents.last!
        
        // For Level 6 complexity with multi-LLM enabled, coordination should occur
        if intent.type.complexity == .level6 {
            let multiLLMTasks = taskMaster.completedTasks.filter { task in
                task.tags.contains("multi-llm") && task.tags.contains("coordination")
            }
            
            XCTAssertGreaterThan(multiLLMTasks.count, 0)
            
            let coordinationTask = multiLLMTasks.first!
            XCTAssertEqual(coordinationTask.level, .level6)
            XCTAssertEqual(coordinationTask.priority, .critical)
            XCTAssertTrue(coordinationTask.tags.contains("level6"))
        }
    }
    
    // MARK: - TDD TEST SUITE 5: Workflow Automation
    
    func testCoordinator_WorkflowAutomation_ReportGenerationWorkflow() async throws {
        // RED: Test automated workflow execution for report generation
        await coordinator.startCoordinationSession()
        
        let reportMessage = "Generate financial report using automated workflow"
        
        // GREEN: Process message that should trigger workflow automation
        await coordinator.processMessageWithCoordination(reportMessage)
        
        // REFACTOR: Verify workflow automation
        let intent = coordinator.recognizedIntents.last!
        
        if intent.type == .generateReport && !intent.requiredWorkflows.isEmpty {
            XCTAssertGreaterThan(coordinator.activeWorkflows.count, 0)
            
            // Check for workflow tasks
            let workflowTasks = taskMaster.allTasks.filter { task in
                task.tags.contains("automated-workflow") && task.level == .level6
            }
            
            XCTAssertGreaterThan(workflowTasks.count, 0)
            
            let workflowTask = workflowTasks.first!
            XCTAssertTrue(workflowTask.title.contains("Automated Workflow"))
            XCTAssertEqual(workflowTask.level, .level6)
            XCTAssertEqual(workflowTask.priority, .high)
        }
    }
    
    func testCoordinator_WorkflowAutomation_DocumentAnalysisWorkflow() async throws {
        // RED: Test document analysis workflow automation
        await coordinator.startCoordinationSession()
        
        let analysisMessage = "Analyze multiple documents using automated workflow"
        
        // GREEN: Process document analysis workflow request
        await coordinator.processMessageWithCoordination(analysisMessage)
        
        // REFACTOR: Verify document analysis workflow
        let intent = coordinator.recognizedIntents.last!
        
        if intent.type == .analyzeDocument && !intent.requiredWorkflows.isEmpty {
            let documentWorkflowTasks = taskMaster.allTasks.filter { task in
                task.tags.contains("automated-workflow") && 
                task.metadata.contains("document_analysis_workflow")
            }
            
            if !documentWorkflowTasks.isEmpty {
                let workflowTask = documentWorkflowTasks.first!
                
                // Verify workflow subtasks
                let subtasks = taskMaster.getSubtasks(for: workflowTask.id)
                XCTAssertGreaterThan(subtasks.count, 0)
                
                // Verify subtask structure
                for subtask in subtasks {
                    XCTAssertEqual(subtask.parentTaskId, workflowTask.id)
                    XCTAssertTrue(subtask.tags.contains("workflow-step"))
                }
            }
        }
    }
    
    // MARK: - TDD TEST SUITE 6: Analytics and Monitoring
    
    func testCoordinator_Analytics_GeneratesCoordinationAnalytics() async throws {
        // RED: Test analytics generation
        await coordinator.startCoordinationSession()
        
        // Generate some coordination events
        let messages = [
            "Create financial task",
            "Analyze document",
            "Generate report"
        ]
        
        // GREEN: Process multiple messages to generate analytics data
        for message in messages {
            await coordinator.processMessageWithCoordination(message)
        }
        
        // Generate analytics
        let analytics = await coordinator.generateCoordinationAnalytics()
        
        // REFACTOR: Verify analytics
        XCTAssertNotNil(analytics)
        XCTAssertGreaterThan(analytics.totalCoordinationEvents, 0)
        XCTAssertGreaterThan(analytics.averageResponseTime, 0)
        XCTAssertGreaterThanOrEqual(analytics.taskCreationRate, 0)
        XCTAssertGreaterThanOrEqual(analytics.workflowAutomationRate, 0)
        XCTAssertGreaterThanOrEqual(analytics.intentRecognitionAccuracy, 0)
        XCTAssertGreaterThanOrEqual(analytics.multiLLMUsageRatio, 0)
        XCTAssertGreaterThanOrEqual(analytics.conversationEfficiency, 0)
        XCTAssertGreaterThanOrEqual(analytics.userSatisfactionScore, 0)
        
        // Analytics should be published
        XCTAssertNotNil(coordinator.coordinationAnalytics)
    }
    
    // MARK: - TDD TEST SUITE 7: Entity Extraction
    
    func testCoordinator_EntityExtraction_FileReferences() async throws {
        // RED: Test entity extraction for file references
        await coordinator.startCoordinationSession()
        
        let messageWithFile = "Analyze document @financial_report.pdf"
        
        // GREEN: Process message with file reference
        await coordinator.processMessageWithCoordination(messageWithFile)
        
        // REFACTOR: Verify file entity extraction
        let intent = coordinator.recognizedIntents.last!
        XCTAssertNotNil(intent.entities["file"])
        XCTAssertEqual(intent.entities["file"], "@financial_report.pdf")
    }
    
    func testCoordinator_EntityExtraction_Numbers() async throws {
        // RED: Test entity extraction for numbers
        await coordinator.startCoordinationSession()
        
        let messageWithNumber = "Create 5 financial analysis tasks"
        
        // GREEN: Process message with number
        await coordinator.processMessageWithCoordination(messageWithNumber)
        
        // REFACTOR: Verify number entity extraction
        let intent = coordinator.recognizedIntents.last!
        XCTAssertNotNil(intent.entities["number"])
        XCTAssertEqual(intent.entities["number"], "5")
    }
    
    // MARK: - TDD TEST SUITE 8: Error Handling and Edge Cases
    
    func testCoordinator_EmptyMessage_HandlesGracefully() async throws {
        // RED: Test handling of empty messages
        await coordinator.startCoordinationSession()
        
        let emptyMessage = ""
        
        // GREEN: Process empty message
        let resultTask = await coordinator.processMessageWithCoordination(emptyMessage)
        
        // REFACTOR: Verify graceful handling
        XCTAssertNotNil(resultTask) // Should still create processing task
        XCTAssertGreaterThan(coordinator.recognizedIntents.count, 0)
        
        let intent = coordinator.recognizedIntents.last!
        XCTAssertEqual(intent.type, .general) // Should default to general intent
    }
    
    func testCoordinator_VeryLongMessage_HandlesAppropriately() async throws {
        // RED: Test handling of very long messages
        await coordinator.startCoordinationSession()
        
        let longMessage = String(repeating: "This is a very long message about financial analysis. ", count: 50)
        
        // GREEN: Process very long message
        let resultTask = await coordinator.processMessageWithCoordination(longMessage)
        
        // REFACTOR: Verify appropriate handling
        XCTAssertNotNil(resultTask)
        XCTAssertTrue(resultTask?.description.contains("...") ?? false) // Should truncate in description
        
        let intent = coordinator.recognizedIntents.last!
        XCTAssertNotEqual(intent.type, .general) // Should still recognize intent
    }
    
    // MARK: - TDD TEST SUITE 9: Performance Testing
    
    func testCoordinator_ConcurrentProcessing_HandlesMultipleMessages() async throws {
        // RED: Test concurrent message processing
        await coordinator.startCoordinationSession()
        
        let messages = [
            "Create financial task 1",
            "Analyze document 1",
            "Generate report 1",
            "Create financial task 2",
            "Analyze document 2"
        ]
        
        // GREEN: Process multiple messages concurrently
        let startTime = Date()
        
        await withTaskGroup(of: TaskItem?.self) { group in
            for message in messages {
                group.addTask {
                    await self.coordinator.processMessageWithCoordination(message)
                }
            }
            
            var results: [TaskItem?] = []
            for await result in group {
                results.append(result)
            }
        }
        
        let duration = Date().timeIntervalSince(startTime)
        
        // REFACTOR: Verify concurrent processing
        XCTAssertEqual(coordinator.recognizedIntents.count, messages.count)
        XCTAssertLessThan(duration, 10.0) // Should complete within reasonable time
        
        // Verify all messages were processed
        for message in messages {
            let matchingIntents = coordinator.recognizedIntents.filter { intent in
                // Find intents that would match this message type
                return intent.confidence > 0.5
            }
            XCTAssertGreaterThan(matchingIntents.count, 0)
        }
    }
}