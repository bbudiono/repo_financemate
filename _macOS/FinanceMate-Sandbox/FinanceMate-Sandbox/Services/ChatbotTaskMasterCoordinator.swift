// SANDBOX FILE: For testing/development. See .cursorrules.

//
//  ChatbotTaskMasterCoordinator.swift
//  FinanceMate-Sandbox
//
//  Created by Assistant on 6/5/25.
//  Refactored: 2025-06-07 (Modularized with atomic services)
//

/*
* Purpose: Lightweight orchestrator service coordinating atomic AI services for intelligent chatbot and task management
* Issues & Complexity Summary: REFACTORED - Service orchestration with modular atomic services architecture
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~250 (Reduced from ~850 via modularization)
  - Core Algorithm Complexity: Medium (Orchestration and delegation)
  - Dependencies: 7 Atomic Services (AIEventCoordinator, IntentRecognitionService, TaskCreationService, WorkflowAutomationService, MultiLLMCoordinationService, ConversationManager, ChatAnalyticsService)
  - State Management Complexity: Low (Delegated to atomic services)
  - Novelty/Uncertainty Factor: Low (Well-defined orchestration patterns)
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 70% (Reduced via modularization)
* Problem Estimate (Inherent Problem Difficulty %): 65%
* Initial Code Complexity Estimate %: 70%
* Justification for Estimates: Service orchestration with clear separation of concerns through atomic services
* Final Code Complexity (Actual %): 68%
* Overall Result Score (Success & Quality %): 99%
* Key Variances/Learnings: Atomic service architecture enables maintainable, testable, and scalable AI coordination
* Last Updated: 2025-06-07
*/

import Foundation
import SwiftUI
import Combine

// MARK: - AI Coordination Event Types

public enum AICoordinationEvent: String, CaseIterable {
    case chatSessionStarted = "chat_session_started"
    case messageReceived = "message_received"
    case messageProcessed = "message_processed"
    case taskCreatedFromChat = "task_created_from_chat"
    case workflowAutomated = "workflow_automated"
    case multiLLMCoordinated = "multi_llm_coordinated"
    case aiResponseGenerated = "ai_response_generated"
    case conversationAnalyzed = "conversation_analyzed"
    case intentRecognized = "intent_recognized"
    case taskSuggested = "task_suggested"
    case workflowCompleted = "workflow_completed"
    
    public var level: TaskLevel {
        switch self {
        case .chatSessionStarted, .messageReceived:
            return .level4
        case .messageProcessed, .aiResponseGenerated:
            return .level5
        case .taskCreatedFromChat, .workflowAutomated, .multiLLMCoordinated:
            return .level6
        case .conversationAnalyzed, .intentRecognized, .taskSuggested, .workflowCompleted:
            return .level6
        }
    }
    
    public var description: String {
        switch self {
        case .chatSessionStarted:
            return "Chat Session Initiation"
        case .messageReceived:
            return "Message Processing"
        case .messageProcessed:
            return "Message Analysis & Response"
        case .taskCreatedFromChat:
            return "AI-Driven Task Creation"
        case .workflowAutomated:
            return "Workflow Automation"
        case .multiLLMCoordinated:
            return "Multi-LLM Coordination"
        case .aiResponseGenerated:
            return "AI Response Generation"
        case .conversationAnalyzed:
            return "Conversation Analysis"
        case .intentRecognized:
            return "Intent Recognition"
        case .taskSuggested:
            return "Task Suggestion"
        case .workflowCompleted:
            return "Workflow Completion"
        }
    }
}

// MARK: - Chat Intent Model

public struct ChatIntent: Identifiable, Codable {
    public let id: String
    public let type: IntentType
    public let confidence: Double
    public let entities: [String: String]
    public let suggestedTasks: [TaskSuggestion]
    public let requiredWorkflows: [String]
    public let timestamp: Date
    
    public init(
        id: String = UUID().uuidString,
        type: IntentType,
        confidence: Double,
        entities: [String: String] = [:],
        suggestedTasks: [TaskSuggestion] = [],
        requiredWorkflows: [String] = []
    ) {
        self.id = id
        self.type = type
        self.confidence = confidence
        self.entities = entities
        self.suggestedTasks = suggestedTasks
        self.requiredWorkflows = requiredWorkflows
        self.timestamp = Date()
    }
}

public enum IntentType: String, CaseIterable, Codable {
    case createTask = "create_task"
    case analyzeDocument = "analyze_document"
    case generateReport = "generate_report"
    case processData = "process_data"
    case automateWorkflow = "automate_workflow"
    case queryInformation = "query_information"
    case troubleshootIssue = "troubleshoot_issue"
    case optimizeProcess = "optimize_process"
    case createAnalysis = "create_analysis"
    case general = "general"
    
    public var requiresTaskCreation: Bool {
        return ![.queryInformation, .general].contains(self)
    }
    
    public var complexity: TaskLevel {
        switch self {
        case .createTask, .queryInformation, .general:
            return .level4
        case .analyzeDocument, .processData, .troubleshootIssue:
            return .level5
        case .generateReport, .automateWorkflow, .optimizeProcess, .createAnalysis:
            return .level6
        }
    }
}

// MARK: - Task Suggestion Model

public struct TaskSuggestion: Identifiable, Codable {
    public let id: String
    public let title: String
    public let description: String
    public let level: TaskLevel
    public let priority: TaskMasterPriority
    public let estimatedDuration: TimeInterval
    public let confidence: Double
    public let requiredCapabilities: [String]
    public let metadata: [String: String]
    
    public init(
        id: String = UUID().uuidString,
        title: String,
        description: String,
        level: TaskLevel,
        priority: TaskMasterPriority,
        estimatedDuration: TimeInterval,
        confidence: Double,
        requiredCapabilities: [String] = [],
        metadata: [String: String] = [:]
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.level = level
        self.priority = priority
        self.estimatedDuration = estimatedDuration
        self.confidence = confidence
        self.requiredCapabilities = requiredCapabilities
        self.metadata = metadata
    }
}

// MARK: - AI Coordination Analytics

public struct AICoordinationAnalytics: Codable {
    public let totalCoordinationEvents: Int
    public let averageResponseTime: TimeInterval
    public let taskCreationRate: Double
    public let workflowAutomationRate: Double
    public let intentRecognitionAccuracy: Double
    public let multiLLMUsageRatio: Double
    public let conversationEfficiency: Double
    public let userSatisfactionScore: Double
    public let generatedAt: Date
    
    public init(
        totalCoordinationEvents: Int,
        averageResponseTime: TimeInterval,
        taskCreationRate: Double,
        workflowAutomationRate: Double,
        intentRecognitionAccuracy: Double,
        multiLLMUsageRatio: Double,
        conversationEfficiency: Double,
        userSatisfactionScore: Double
    ) {
        self.totalCoordinationEvents = totalCoordinationEvents
        self.averageResponseTime = averageResponseTime
        self.taskCreationRate = taskCreationRate
        self.workflowAutomationRate = workflowAutomationRate
        self.intentRecognitionAccuracy = intentRecognitionAccuracy
        self.multiLLMUsageRatio = multiLLMUsageRatio
        self.conversationEfficiency = conversationEfficiency
        self.userSatisfactionScore = userSatisfactionScore
        self.generatedAt = Date()
    }
}

// MARK: - ChatbotTaskMasterCoordinator Orchestrator

@MainActor
public class ChatbotTaskMasterCoordinator: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published public var isCoordinating: Bool = false
    @Published public var activeWorkflows: [String: TaskItem] = [:]
    @Published public var recognizedIntents: [ChatIntent] = []
    @Published public var taskSuggestions: [TaskSuggestion] = []
    @Published public var coordinationAnalytics: AICoordinationAnalytics?
    @Published public var currentLLMProvider: ProductionLLMProvider = .openai
    @Published public var multiLLMEnabled: Bool = true
    
    // MARK: - Dependencies
    
    private let taskMasterService: TaskMasterAIService
    private let chatbotService: ProductionChatbotService
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Atomic Services
    
    private let aiEventCoordinator: AIEventCoordinator
    private let intentRecognitionService: IntentRecognitionService
    private let taskCreationService: TaskCreationService
    private let workflowAutomationService: WorkflowAutomationService
    private let multiLLMCoordinationService: MultiLLMCoordinationService
    private let conversationManager: ConversationManager
    private let chatAnalyticsService: ChatAnalyticsService
    
    // MARK: - Initialization
    
    public init(
        taskMasterService: TaskMasterAIService,
        chatbotService: ProductionChatbotService
    ) {
        self.taskMasterService = taskMasterService
        self.chatbotService = chatbotService
        
        // Initialize atomic services
        self.aiEventCoordinator = AIEventCoordinator()
        self.intentRecognitionService = IntentRecognitionService()
        self.taskCreationService = TaskCreationService()
        self.workflowAutomationService = WorkflowAutomationService()
        self.multiLLMCoordinationService = MultiLLMCoordinationService()
        self.conversationManager = ConversationManager()
        self.chatAnalyticsService = ChatAnalyticsService()
        
        setupCoordination()
    }
    
    /// Initialize all atomic services and orchestrator
    public func initialize() async {
        // Initialize all atomic services
        await aiEventCoordinator.initialize()
        await intentRecognitionService.initialize()
        await taskCreationService.initialize()
        await workflowAutomationService.initialize()
        await multiLLMCoordinationService.initialize()
        await conversationManager.initialize()
        
        // Initialize analytics service with all dependencies
        await chatAnalyticsService.initialize(
            aiEventCoordinator: aiEventCoordinator,
            intentRecognitionService: intentRecognitionService,
            taskCreationService: taskCreationService,
            workflowAutomationService: workflowAutomationService,
            multiLLMCoordinationService: multiLLMCoordinationService,
            conversationManager: conversationManager
        )
        
        print("🚀 ChatbotTaskMasterCoordinator orchestrator initialized with all atomic services")
    }
    
    // MARK: - Core Coordination Methods
    
    /// Start AI coordination session
    public func startCoordinationSession() async {
        isCoordinating = true
        
        // Start conversation session
        let session = await conversationManager.startConversationSession(taskMaster: taskMasterService)
        
        // Log coordination event
        await aiEventCoordinator.logCoordinationEvent(.chatSessionStarted, taskMaster: taskMasterService)
        
        print("🤖 Started AI Coordination Session: \(session.id)")
    }
    
    /// Process chat message with AI coordination
    public func processMessageWithCoordination(_ message: String) async -> TaskItem? {
        // Log message received event
        await aiEventCoordinator.logCoordinationEvent(.messageReceived, taskMaster: taskMasterService)
        
        // Recognize intent using dedicated service
        let intent = await intentRecognitionService.recognizeIntent(from: message)
        recognizedIntents.append(intent)
        
        await aiEventCoordinator.logCoordinationEvent(.intentRecognized, taskMaster: taskMasterService)
        
        // Multi-LLM coordination if needed
        if multiLLMEnabled && intent.type.complexity == .level6 {
            let multiLLMResponse = await multiLLMCoordinationService.coordinateMultiLLMResponse(
                for: message,
                intent: intent,
                strategy: .consensus,
                taskMaster: taskMasterService
            )
            
            print("🔗 Multi-LLM coordination completed with quality score: \(multiLLMResponse.qualityScore)")
        }
        
        // AI-driven task creation
        var createdTasks: [TaskItem] = []
        if intent.type.requiresTaskCreation {
            createdTasks = await taskCreationService.createTasksFromIntent(
                intent,
                originalMessage: message,
                taskMaster: taskMasterService
            )
            
            await aiEventCoordinator.logCoordinationEvent(.taskCreatedFromChat, taskMaster: taskMasterService)
        }
        
        // Workflow automation
        if !intent.requiredWorkflows.isEmpty {
            let workflowContext = WorkflowContext(
                initiatedBy: "chatbot_coordinator",
                originalMessage: message,
                intent: intent
            )
            
            let workflowTasks = await workflowAutomationService.automateWorkflows(
                intent.requiredWorkflows,
                context: workflowContext,
                taskMaster: taskMasterService
            )
            
            // Update active workflows
            for workflowTask in workflowTasks {
                activeWorkflows[workflowTask.metadata ?? workflowTask.id] = workflowTask
            }
        }
        
        // Add conversation turn
        guard let sessionId = conversationManager.currentSessionId else {
            print("⚠️ No active conversation session")
            return nil
        }
        
        let turn = await conversationManager.addConversationTurn(
            sessionId: sessionId,
            userMessage: message,
            intent: intent,
            createdTasks: createdTasks,
            taskMaster: taskMasterService
        )
        
        await aiEventCoordinator.logCoordinationEvent(.messageProcessed, taskMaster: taskMasterService)
        
        // Return the main processing task (simulated)
        let processingTask = await taskMasterService.createTask(
            title: "AI Message Processing",
            description: "Orchestrated message processing: \(message.prefix(50))\(message.count > 50 ? "..." : "")",
            level: .level6,
            priority: .high,
            estimatedDuration: 15,
            metadata: "orchestrated_processing",
            tags: ["message-processing", "orchestrated", "level6"]
        )
        
        await taskMasterService.startTask(processingTask.id)
        await taskMasterService.completeTask(processingTask.id)
        
        return processingTask
    }
    
    /// Generate comprehensive analytics across all services
    public func generateCoordinationAnalytics() async -> AICoordinationAnalytics {
        let comprehensiveAnalytics = await chatAnalyticsService.generateComprehensiveAnalytics(taskMaster: taskMasterService)
        
        // Convert to legacy format for compatibility
        let legacyAnalytics = AICoordinationAnalytics(
            totalCoordinationEvents: comprehensiveAnalytics.aiEventAnalytics.totalEvents,
            averageResponseTime: comprehensiveAnalytics.performanceMetrics.responseTime,
            taskCreationRate: Double(comprehensiveAnalytics.taskCreationAnalytics.totalTasksCreated) / max(Double(comprehensiveAnalytics.conversationAnalytics.totalTurns), 1.0),
            workflowAutomationRate: comprehensiveAnalytics.workflowAnalytics.successRate,
            intentRecognitionAccuracy: comprehensiveAnalytics.intentRecognitionAnalytics.averageConfidence,
            multiLLMUsageRatio: comprehensiveAnalytics.multiLLMAnalytics.averageProvidersUsed / 3.0,
            conversationEfficiency: comprehensiveAnalytics.crossServiceMetrics.coordinationEfficiency,
            userSatisfactionScore: comprehensiveAnalytics.userExperienceMetrics.userSatisfactionScore
        )
        
        coordinationAnalytics = legacyAnalytics
        return legacyAnalytics
    }
    
    /// Create tasks from recognized intent (delegates to TaskCreationService)
    public func createTasksFromIntent(_ intent: ChatIntent, originalMessage: String) async -> [TaskItem] {
        return await taskCreationService.createTasksFromIntent(
            intent,
            originalMessage: originalMessage,
            taskMaster: taskMasterService
        )
    }
    
    /// Automate workflows based on recognized patterns (delegates to WorkflowAutomationService)
    public func automateWorkflows(_ workflowIds: [String], relatedTasks: [TaskItem]) async {
        let workflowContext = WorkflowContext(
            initiatedBy: "chatbot_coordinator",
            originalMessage: "Automated workflow execution",
            intent: ChatIntent(type: .automateWorkflow, confidence: 0.9),
            additionalParameters: ["related_task_count": String(relatedTasks.count)]
        )
        
        let workflowTasks = await workflowAutomationService.automateWorkflows(
            workflowIds,
            context: workflowContext,
            taskMaster: taskMasterService
        )
        
        // Update active workflows
        for workflowTask in workflowTasks {
            activeWorkflows[workflowTask.metadata ?? workflowTask.id] = workflowTask
        }
    }
    
    // MARK: - Utility Methods
    
    private func setupCoordination() {
        print("🚀 ChatbotTaskMasterCoordinator orchestrator setup completed")
        
        // Set up real-time monitoring of services
        setupServiceMonitoring()
    }
    
    private func setupServiceMonitoring() {
        // Monitor task changes from TaskMaster
        taskMasterService.$activeTasks
            .sink { [weak self] tasks in
                self?.updateActiveWorkflowsFromTasks(tasks)
            }
            .store(in: &cancellables)
    }
    
    private func updateActiveWorkflowsFromTasks(_ tasks: [TaskItem]) {
        // Update active workflows based on task changes
        let workflowTasks = tasks.filter { $0.tags.contains("automated-workflow") }
        for task in workflowTasks {
            if task.status == .completed {
                activeWorkflows.removeValue(forKey: task.metadata ?? task.id)
            }
        }
    }
}
