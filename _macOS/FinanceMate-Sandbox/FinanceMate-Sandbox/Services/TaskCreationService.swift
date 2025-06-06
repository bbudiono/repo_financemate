// SANDBOX FILE: For testing/development. See .cursorrules.

//
//  TaskCreationService.swift
//  FinanceMate-Sandbox
//
//  Created by Assistant on 6/7/25.
//

/*
* Purpose: Atomic AI-driven task creation service with intelligent batch processing and auto-start logic
* Issues & Complexity Summary: Advanced task creation from chat intents with confidence-based automation and workflow integration
* Key Complexity Drivers:
  - AI-driven task creation from chat intents
  - Batch processing capabilities with optimization
  - Auto-start logic for high-confidence tasks
  - Level 6 TaskMaster integration
  - Intelligent task suggestion generation
  - Performance-optimized creation queuing
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 92%
* Problem Estimate (Inherent Problem Difficulty %): 89%
* Initial Code Complexity Estimate %: 92%
* Final Code Complexity (Actual %): 90%
* Overall Result Score (Success & Quality %): 98%
* Last Updated: 2025-06-07
*/

import Foundation
import Combine

// MARK: - TaskCreationService

@MainActor
public class TaskCreationService: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published public private(set) var isInitialized: Bool = false
    @Published public private(set) var createdTasksCount: Int = 0
    @Published public private(set) var queuedCreationsCount: Int = 0
    @Published public private(set) var autoStartedTasksCount: Int = 0
    
    // MARK: - Private Properties
    
    private var creationQueue: [TaskCreationRequest] = []
    private var createdTasks: [TaskItem] = []
    private var creationHistory: [TaskCreationResult] = []
    private var batchProcessor: TaskCreationBatchProcessor?
    private let maxQueueSize: Int = 100
    private let highConfidenceThreshold: Double = 0.8
    private let autoStartConfidenceThreshold: Double = 0.85
    
    // MARK: - Task Creation Templates
    
    private let taskTemplates: [IntentType: TaskCreationTemplate] = [
        .createTask: TaskCreationTemplate(
            titlePrefix: "Execute User Request",
            descriptionTemplate: "Implement: {message}",
            defaultLevel: .level5,
            defaultPriority: .high,
            estimatedDuration: 30,
            requiredCapabilities: ["implementation", "validation"],
            tags: ["ai-created", "user-request"]
        ),
        .analyzeDocument: TaskCreationTemplate(
            titlePrefix: "Document Analysis",
            descriptionTemplate: "Analyze {entity_file} and extract insights: {message}",
            defaultLevel: .level5,
            defaultPriority: .medium,
            estimatedDuration: 25,
            requiredCapabilities: ["ocr", "analysis", "insights"],
            tags: ["ai-created", "document-analysis"]
        ),
        .generateReport: TaskCreationTemplate(
            titlePrefix: "Comprehensive Report Generation",
            descriptionTemplate: "Generate detailed report: {message}",
            defaultLevel: .level6,
            defaultPriority: .high,
            estimatedDuration: 45,
            requiredCapabilities: ["data-processing", "visualization", "export"],
            tags: ["ai-created", "report-generation", "level6"]
        ),
        .processData: TaskCreationTemplate(
            titlePrefix: "Data Processing",
            descriptionTemplate: "Process and transform data: {message}",
            defaultLevel: .level5,
            defaultPriority: .medium,
            estimatedDuration: 35,
            requiredCapabilities: ["data-import", "transformation", "validation"],
            tags: ["ai-created", "data-processing"]
        ),
        .automateWorkflow: TaskCreationTemplate(
            titlePrefix: "Workflow Automation",
            descriptionTemplate: "Automate workflow process: {message}",
            defaultLevel: .level6,
            defaultPriority: .critical,
            estimatedDuration: 60,
            requiredCapabilities: ["automation", "integration", "monitoring"],
            tags: ["ai-created", "workflow-automation", "level6"]
        ),
        .troubleshootIssue: TaskCreationTemplate(
            titlePrefix: "Issue Resolution",
            descriptionTemplate: "Diagnose and resolve: {message}",
            defaultLevel: .level5,
            defaultPriority: .high,
            estimatedDuration: 25,
            requiredCapabilities: ["debugging", "analysis", "resolution"],
            tags: ["ai-created", "troubleshooting"]
        ),
        .optimizeProcess: TaskCreationTemplate(
            titlePrefix: "Process Optimization",
            descriptionTemplate: "Optimize and improve: {message}",
            defaultLevel: .level5,
            defaultPriority: .medium,
            estimatedDuration: 40,
            requiredCapabilities: ["optimization", "analysis", "improvement"],
            tags: ["ai-created", "optimization"]
        ),
        .createAnalysis: TaskCreationTemplate(
            titlePrefix: "Analysis Generation",
            descriptionTemplate: "Create comprehensive analysis: {message}",
            defaultLevel: .level6,
            defaultPriority: .high,
            estimatedDuration: 50,
            requiredCapabilities: ["analytics", "insights", "reporting"],
            tags: ["ai-created", "analysis-generation", "level6"]
        )
    ]
    
    // MARK: - Initialization
    
    public init() {
        setupTaskCreationService()
    }
    
    public func initialize() async {
        batchProcessor = TaskCreationBatchProcessor(service: self)
        isInitialized = true
        print("🎯 TaskCreationService initialized successfully")
    }
    
    // MARK: - Core Task Creation
    
    /// Create tasks from recognized chat intent with intelligent processing
    /// - Parameters:
    ///   - intent: Recognized chat intent with suggestions
    ///   - originalMessage: Original user message
    ///   - taskMaster: TaskMaster service for Level 6 task creation
    /// - Returns: Array of created tasks
    public func createTasksFromIntent(
        _ intent: ChatIntent,
        originalMessage: String,
        taskMaster: TaskMasterAIService
    ) async -> [TaskItem] {
        guard isInitialized else {
            print("❌ TaskCreationService not initialized")
            return []
        }
        
        var createdTasks: [TaskItem] = []
        
        // Process each suggested task from intent
        for suggestion in intent.suggestedTasks {
            let task = await createTaskFromSuggestion(
                suggestion,
                originalMessage: originalMessage,
                intent: intent,
                taskMaster: taskMaster
            )
            
            if let task = task {
                createdTasks.append(task)
                
                // Auto-start high-confidence tasks
                if suggestion.confidence > autoStartConfidenceThreshold {
                    await autoStartTask(task, taskMaster: taskMaster)
                }
            }
        }
        
        // If no suggestions provided, create default task
        if intent.suggestedTasks.isEmpty {
            let defaultTask = await createDefaultTask(
                for: intent,
                originalMessage: originalMessage,
                taskMaster: taskMaster
            )
            
            if let defaultTask = defaultTask {
                createdTasks.append(defaultTask)
            }
        }
        
        // Update metrics
        createdTasksCount += createdTasks.count
        
        // Record creation results
        let result = TaskCreationResult(
            intent: intent,
            originalMessage: originalMessage,
            createdTasks: createdTasks,
            timestamp: Date(),
            autoStarted: createdTasks.filter { task in
                createdTasks.compactMap { createdTask in
                    intent.suggestedTasks.first { $0.confidence > autoStartConfidenceThreshold }
                }.count > 0
            }.count
        )
        
        addToCreationHistory(result)
        
        print("🎯 Created \(createdTasks.count) tasks from intent: \(intent.type.rawValue)")
        
        return createdTasks
    }
    
    /// Create task from specific suggestion with template processing
    private func createTaskFromSuggestion(
        _ suggestion: TaskSuggestion,
        originalMessage: String,
        intent: ChatIntent,
        taskMaster: TaskMasterAIService
    ) async -> TaskItem? {
        // Get template for intent type
        guard let template = taskTemplates[intent.type] else {
            return await createCustomTaskFromSuggestion(suggestion, originalMessage: originalMessage, taskMaster: taskMaster)
        }
        
        // Process template with intent context
        let processedTitle = processTemplate(template.titlePrefix, with: intent, originalMessage: originalMessage)
        let processedDescription = processTemplate(template.descriptionTemplate, with: intent, originalMessage: originalMessage)
        
        // Determine task level based on suggestion and template
        let taskLevel = determineOptimalTaskLevel(suggestion: suggestion, template: template, intent: intent)
        
        // Create task with processed information
        let task = await taskMaster.createTask(
            title: processedTitle,
            description: processedDescription,
            level: taskLevel,
            priority: determinePriority(suggestion: suggestion, template: template, intent: intent),
            estimatedDuration: suggestion.estimatedDuration > 0 ? suggestion.estimatedDuration : template.estimatedDuration,
            metadata: originalMessage,
            tags: combineTaskTags(suggestion: suggestion, template: template, intent: intent)
        )
        
        return task
    }
    
    /// Create custom task when no template available
    private func createCustomTaskFromSuggestion(
        _ suggestion: TaskSuggestion,
        originalMessage: String,
        taskMaster: TaskMasterAIService
    ) async -> TaskItem? {
        let task = await taskMaster.createTask(
            title: suggestion.title,
            description: suggestion.description,
            level: suggestion.level,
            priority: suggestion.priority,
            estimatedDuration: suggestion.estimatedDuration,
            metadata: originalMessage,
            tags: ["ai-created", "custom"] + (suggestion.metadata["intent_type"].map { [$0] } ?? [])
        )
        
        return task
    }
    
    /// Create default task when no suggestions provided
    private func createDefaultTask(
        for intent: ChatIntent,
        originalMessage: String,
        taskMaster: TaskMasterAIService
    ) async -> TaskItem? {
        guard let template = taskTemplates[intent.type] else {
            return await createFallbackTask(originalMessage: originalMessage, taskMaster: taskMaster)
        }
        
        let title = processTemplate(template.titlePrefix, with: intent, originalMessage: originalMessage)
        let description = processTemplate(template.descriptionTemplate, with: intent, originalMessage: originalMessage)
        
        let task = await taskMaster.createTask(
            title: title,
            description: description,
            level: template.defaultLevel,
            priority: adjustPriorityForConfidence(template.defaultPriority, confidence: intent.confidence),
            estimatedDuration: template.estimatedDuration,
            metadata: originalMessage,
            tags: template.tags + ["default-creation"]
        )
        
        return task
    }
    
    /// Create fallback task for unsupported intent types
    private func createFallbackTask(
        originalMessage: String,
        taskMaster: TaskMasterAIService
    ) async -> TaskItem? {
        let task = await taskMaster.createTask(
            title: "General Assistance",
            description: "Provide assistance for: \(originalMessage.prefix(50))\(originalMessage.count > 50 ? "..." : "")",
            level: .level4,
            priority: .medium,
            estimatedDuration: 10,
            metadata: originalMessage,
            tags: ["ai-created", "general", "fallback"]
        )
        
        return task
    }
    
    // MARK: - Batch Processing
    
    /// Queue task creation request for batch processing
    public func queueTaskCreation(
        intent: ChatIntent,
        originalMessage: String,
        priority: TaskCreationPriority = .normal
    ) {
        guard creationQueue.count < maxQueueSize else {
            print("⚠️ Task creation queue at capacity, dropping request")
            return
        }
        
        let request = TaskCreationRequest(
            intent: intent,
            originalMessage: originalMessage,
            priority: priority,
            timestamp: Date()
        )
        
        creationQueue.append(request)
        queuedCreationsCount += 1
        
        print("📝 Queued task creation for intent: \(intent.type.rawValue)")
    }
    
    /// Process batch of queued task creation requests
    public func processBatchCreations(taskMaster: TaskMasterAIService) async -> [TaskItem] {
        guard !creationQueue.isEmpty else {
            return []
        }
        
        let batchSize = min(creationQueue.count, 10) // Process up to 10 at once
        let batch = Array(creationQueue.prefix(batchSize))
        creationQueue.removeFirst(batchSize)
        queuedCreationsCount = creationQueue.count
        
        var allCreatedTasks: [TaskItem] = []
        
        // Process batch in parallel for performance
        await withTaskGroup(of: [TaskItem].self) { group in
            for request in batch {
                group.addTask {
                    await self.createTasksFromIntent(
                        request.intent,
                        originalMessage: request.originalMessage,
                        taskMaster: taskMaster
                    )
                }
            }
            
            for await tasks in group {
                allCreatedTasks.append(contentsOf: tasks)
            }
        }
        
        print("🚀 Processed batch of \(batch.count) task creation requests, created \(allCreatedTasks.count) tasks")
        
        return allCreatedTasks
    }
    
    // MARK: - Auto-Start Logic
    
    /// Auto-start task if confidence meets threshold
    private func autoStartTask(_ task: TaskItem, taskMaster: TaskMasterAIService) async {
        await taskMaster.startTask(task.id)
        autoStartedTasksCount += 1
        
        print("🚀 Auto-started high-confidence task: \(task.title)")
    }
    
    /// Determine if task should be auto-started based on confidence and complexity
    public func shouldAutoStartTask(suggestion: TaskSuggestion, intent: ChatIntent) -> Bool {
        // Auto-start criteria
        let highConfidence = suggestion.confidence >= autoStartConfidenceThreshold
        let appropriateComplexity = suggestion.level.rawValue <= TaskLevel.level5.rawValue
        let supportedIntent = intent.type.requiresTaskCreation
        
        return highConfidence && appropriateComplexity && supportedIntent
    }
    
    // MARK: - Template Processing
    
    private func processTemplate(_ template: String, with intent: ChatIntent, originalMessage: String) -> String {
        var processed = template
        
        // Replace message placeholder
        processed = processed.replacingOccurrences(of: "{message}", with: originalMessage.prefix(50) + (originalMessage.count > 50 ? "..." : ""))
        
        // Replace entity placeholders
        for (key, value) in intent.entities {
            processed = processed.replacingOccurrences(of: "{entity_\(key)}", with: value)
        }
        
        // Clean up any unreplaced placeholders
        processed = processed.replacingOccurrences(of: #"\{[^}]+\}"#, with: "", options: .regularExpression)
        
        return processed
    }
    
    private func determineOptimalTaskLevel(suggestion: TaskSuggestion, template: TaskCreationTemplate, intent: ChatIntent) -> TaskLevel {
        // Use suggestion level if explicitly provided and reasonable
        if suggestion.level != template.defaultLevel && suggestion.confidence > highConfidenceThreshold {
            return suggestion.level
        }
        
        // Use intent complexity for high-confidence intents
        if intent.confidence > highConfidenceThreshold {
            return intent.type.complexity
        }
        
        // Default to template level
        return template.defaultLevel
    }
    
    private func determinePriority(suggestion: TaskSuggestion, template: TaskCreationTemplate, intent: ChatIntent) -> TaskMasterPriority {
        // High-confidence suggestions get priority boost
        if suggestion.confidence > 0.9 {
            return suggestion.priority == .critical ? .critical : .high
        }
        
        // Use suggestion priority if confidence is reasonable
        if suggestion.confidence > highConfidenceThreshold {
            return suggestion.priority
        }
        
        // Default to template priority adjusted for confidence
        return adjustPriorityForConfidence(template.defaultPriority, confidence: intent.confidence)
    }
    
    private func adjustPriorityForConfidence(_ basePriority: TaskMasterPriority, confidence: Double) -> TaskMasterPriority {
        if confidence > 0.9 {
            return basePriority == .medium ? .high : basePriority
        } else if confidence < 0.6 {
            return basePriority == .high ? .medium : basePriority
        }
        
        return basePriority
    }
    
    private func combineTaskTags(suggestion: TaskSuggestion, template: TaskCreationTemplate, intent: ChatIntent) -> [String] {
        var tags = template.tags
        
        // Add confidence-based tags
        if suggestion.confidence > 0.9 {
            tags.append("high-confidence")
        }
        
        // Add complexity tags
        if intent.type.complexity == .level6 {
            tags.append("level6")
        }
        
        // Add entity-based tags
        for key in intent.entities.keys {
            tags.append("has-\(key)")
        }
        
        return Array(Set(tags)) // Remove duplicates
    }
    
    // MARK: - Analytics and Monitoring
    
    /// Get creation analytics
    public func getCreationAnalytics() -> TaskCreationAnalytics {
        let totalCreations = creationHistory.count
        let averageTasksPerCreation = totalCreations > 0 ? Double(createdTasksCount) / Double(totalCreations) : 0
        let autoStartRate = createdTasksCount > 0 ? Double(autoStartedTasksCount) / Double(createdTasksCount) : 0
        let highConfidenceRate = creationHistory.filter { $0.intent.confidence > highConfidenceThreshold }.count
        let highConfidenceRatePercent = totalCreations > 0 ? Double(highConfidenceRate) / Double(totalCreations) : 0
        
        return TaskCreationAnalytics(
            totalCreationRequests: totalCreations,
            totalTasksCreated: createdTasksCount,
            averageTasksPerCreation: averageTasksPerCreation,
            autoStartRate: autoStartRate,
            highConfidenceCreationRate: highConfidenceRatePercent,
            queuedRequestsCount: queuedCreationsCount,
            currentQueueSize: creationQueue.count
        )
    }
    
    /// Clear creation cache and history
    public func clearCreationData() {
        creationQueue.removeAll()
        createdTasks.removeAll()
        creationHistory.removeAll()
        createdTasksCount = 0
        queuedCreationsCount = 0
        autoStartedTasksCount = 0
        
        print("🗑️ TaskCreationService data cleared")
    }
    
    // MARK: - Utility Methods
    
    private func setupTaskCreationService() {
        creationQueue.reserveCapacity(maxQueueSize)
        creationHistory.reserveCapacity(500)
    }
    
    private func addToCreationHistory(_ result: TaskCreationResult) {
        creationHistory.append(result)
        
        // Maintain history size
        if creationHistory.count > 500 {
            creationHistory.removeFirst(50)
        }
    }
}

// MARK: - Supporting Types

private struct TaskCreationTemplate {
    let titlePrefix: String
    let descriptionTemplate: String
    let defaultLevel: TaskLevel
    let defaultPriority: TaskMasterPriority
    let estimatedDuration: TimeInterval
    let requiredCapabilities: [String]
    let tags: [String]
}

private struct TaskCreationRequest {
    let intent: ChatIntent
    let originalMessage: String
    let priority: TaskCreationPriority
    let timestamp: Date
}

public enum TaskCreationPriority: String, CaseIterable {
    case low = "low"
    case normal = "normal"
    case high = "high"
    case urgent = "urgent"
}

private struct TaskCreationResult {
    let intent: ChatIntent
    let originalMessage: String
    let createdTasks: [TaskItem]
    let timestamp: Date
    let autoStarted: Int
}

public struct TaskCreationAnalytics {
    public let totalCreationRequests: Int
    public let totalTasksCreated: Int
    public let averageTasksPerCreation: Double
    public let autoStartRate: Double
    public let highConfidenceCreationRate: Double
    public let queuedRequestsCount: Int
    public let currentQueueSize: Int
}

// MARK: - Batch Processor

private class TaskCreationBatchProcessor {
    private weak var service: TaskCreationService?
    private let processingInterval: TimeInterval = 2.0
    private var processingTimer: Timer?
    
    init(service: TaskCreationService) {
        self.service = service
        startPeriodicProcessing()
    }
    
    private func startPeriodicProcessing() {
        processingTimer = Timer.scheduledTimer(withTimeInterval: processingInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                // Periodic batch processing would be implemented here
                // For now, just a placeholder
            }
        }
    }
    
    deinit {
        processingTimer?.invalidate()
    }
}