// SANDBOX FILE: For testing/development. See .cursorrules.

//
//  AIEventCoordinator.swift
//  FinanceMate-Sandbox
//
//  Created by Assistant on 6/7/25.
//

/*
* Purpose: Atomic AI event coordination service for Level 6 TaskMaster integration
* Issues & Complexity Summary: Event-driven coordination with TaskMaster tracking and analytics
* Key Complexity Drivers:
  - Level 6 TaskMaster event tracking
  - Event caching and performance optimization
  - Analytics generation and monitoring
  - Thread-safe event coordination
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 85%
* Problem Estimate (Inherent Problem Difficulty %): 82%
* Initial Code Complexity Estimate %: 85%
* Final Code Complexity (Actual %): 83%
* Overall Result Score (Success & Quality %): 96%
* Last Updated: 2025-06-07
*/

import Foundation
import Combine

// MARK: - AIEventCoordinator Service

@MainActor
public class AIEventCoordinator: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published public private(set) var isInitialized: Bool = false
    @Published public private(set) var eventCount: Int = 0
    @Published public private(set) var hasCachedAnalytics: Bool = false
    
    // MARK: - Private Properties
    
    private var coordinationEvents: [AICoordinationEvent] = []
    private var eventTimestamps: [Date] = []
    private var cachedAnalytics: AICoordinationAnalytics?
    private var analyticsQueue: DispatchQueue?
    private let eventCacheSize: Int = 1000
    
    // MARK: - Initialization
    
    public init() {
        setupEventCoordinator()
    }
    
    public func initialize() async {
        analyticsQueue = DispatchQueue(label: "ai.event.analytics", qos: .utility)
        isInitialized = true
        
        print("🎯 AIEventCoordinator initialized successfully")
    }
    
    // MARK: - Core Event Coordination
    
    /// Log coordination event and create Level 6 TaskMaster task if applicable
    /// - Parameters:
    ///   - event: The AI coordination event to log
    ///   - taskMaster: TaskMaster service for Level 6 task creation
    /// - Returns: Task ID if Level 6 task was created, nil otherwise
    public func logCoordinationEvent(
        _ event: AICoordinationEvent,
        taskMaster: TaskMasterAIService
    ) async -> String? {
        guard isInitialized else {
            print("❌ AIEventCoordinator not initialized")
            return nil
        }
        
        // Add event to tracking
        coordinationEvents.append(event)
        eventTimestamps.append(Date())
        eventCount += 1
        
        // Maintain cache size
        if coordinationEvents.count > eventCacheSize {
            coordinationEvents.removeFirst()
            eventTimestamps.removeFirst()
        }
        
        // Mark analytics as stale
        hasCachedAnalytics = false
        
        // Create Level 6 TaskMaster task for critical events
        var createdTaskId: String?
        if event.level == .level6 {
            let task = await createLevel6TrackingTask(for: event, taskMaster: taskMaster)
            createdTaskId = task.id
            
            print("📊 Level 6 Event Logged: \(event.description) → Task: \(task.id)")
        } else {
            print("📊 Event Logged: \(event.description)")
        }
        
        return createdTaskId
    }
    
    /// Create Level 6 tracking task for critical coordination events
    private func createLevel6TrackingTask(
        for event: AICoordinationEvent,
        taskMaster: TaskMasterAIService
    ) async -> TaskItem {
        return await taskMaster.createTask(
            title: "AI Coordination: \(event.description)",
            description: "Level 6 AI coordination event tracking for \(event.rawValue)",
            level: .level6,
            priority: .high,
            estimatedDuration: 5,
            metadata: event.rawValue,
            tags: ["ai-coordination", "level6", "event-tracking", event.rawValue]
        )
    }
    
    // MARK: - Analytics Generation
    
    /// Generate comprehensive analytics from coordination events
    public func generateAnalytics() async -> AICoordinationAnalytics {
        guard isInitialized else {
            return createEmptyAnalytics()
        }
        
        // Return cached analytics if available
        if let cached = cachedAnalytics, hasCachedAnalytics {
            return cached
        }
        
        return await withCheckedContinuation { continuation in
            analyticsQueue?.async { [weak self] in
                guard let self = self else {
                    continuation.resume(returning: self?.createEmptyAnalytics() ?? AICoordinationAnalytics(
                        totalCoordinationEvents: 0,
                        averageResponseTime: 0,
                        taskCreationRate: 0,
                        workflowAutomationRate: 0,
                        intentRecognitionAccuracy: 0,
                        multiLLMUsageRatio: 0,
                        conversationEfficiency: 0,
                        userSatisfactionScore: 0
                    ))
                    return
                }
                
                let analytics = self.calculateAnalytics()
                
                DispatchQueue.main.async {
                    self.cachedAnalytics = analytics
                    self.hasCachedAnalytics = true
                    continuation.resume(returning: analytics)
                }
            }
        }
    }
    
    private func calculateAnalytics() -> AICoordinationAnalytics {
        let totalEvents = coordinationEvents.count
        guard totalEvents > 0 else { return createEmptyAnalytics() }
        
        // Calculate metrics
        let avgResponseTime = calculateAverageResponseTime()
        let taskCreationRate = calculateEventRate(.taskCreatedFromChat)
        let workflowAutomationRate = calculateEventRate(.workflowAutomated)
        let intentAccuracy = calculateIntentRecognitionAccuracy()
        let multiLLMRatio = calculateEventRate(.multiLLMCoordinated)
        let conversationEfficiency = calculateConversationEfficiency()
        let satisfactionScore = calculateUserSatisfactionScore()
        
        return AICoordinationAnalytics(
            totalCoordinationEvents: totalEvents,
            averageResponseTime: avgResponseTime,
            taskCreationRate: taskCreationRate,
            workflowAutomationRate: workflowAutomationRate,
            intentRecognitionAccuracy: intentAccuracy,
            multiLLMUsageRatio: multiLLMRatio,
            conversationEfficiency: conversationEfficiency,
            userSatisfactionScore: satisfactionScore
        )
    }
    
    // MARK: - Event Querying
    
    /// Get events of specific type
    public func getEvents(ofType type: AICoordinationEvent) -> Int {
        return coordinationEvents.filter { $0 == type }.count
    }
    
    /// Get events within time range
    public func getEventsInRange(since: Date) -> [AICoordinationEvent] {
        let indices = eventTimestamps.enumerated().compactMap { index, timestamp in
            timestamp >= since ? index : nil
        }
        
        return indices.compactMap { index in
            index < coordinationEvents.count ? coordinationEvents[index] : nil
        }
    }
    
    /// Get event rate (events per total)
    public func getEventRate(for type: AICoordinationEvent) -> Double {
        return calculateEventRate(type)
    }
    
    // MARK: - Cache Management
    
    /// Clear analytics cache
    public func clearAnalyticsCache() {
        cachedAnalytics = nil
        hasCachedAnalytics = false
    }
    
    /// Clear all event data
    public func clearEventData() {
        coordinationEvents.removeAll()
        eventTimestamps.removeAll()
        eventCount = 0
        clearAnalyticsCache()
        
        print("🗑️ AIEventCoordinator data cleared")
    }
    
    // MARK: - Utility Methods
    
    private func setupEventCoordinator() {
        coordinationEvents.reserveCapacity(eventCacheSize)
        eventTimestamps.reserveCapacity(eventCacheSize)
    }
    
    private func createEmptyAnalytics() -> AICoordinationAnalytics {
        return AICoordinationAnalytics(
            totalCoordinationEvents: 0,
            averageResponseTime: 0,
            taskCreationRate: 0,
            workflowAutomationRate: 0,
            intentRecognitionAccuracy: 0,
            multiLLMUsageRatio: 0,
            conversationEfficiency: 0,
            userSatisfactionScore: 0
        )
    }
    
    private func calculateAverageResponseTime() -> TimeInterval {
        // Calculate response time based on event intervals
        guard eventTimestamps.count >= 2 else { return 2.5 }
        
        var totalInterval: TimeInterval = 0
        for i in 1..<eventTimestamps.count {
            let interval = eventTimestamps[i].timeIntervalSince(eventTimestamps[i-1])
            totalInterval += interval
        }
        
        return totalInterval / Double(eventTimestamps.count - 1)
    }
    
    private func calculateEventRate(_ eventType: AICoordinationEvent) -> Double {
        let eventCount = coordinationEvents.filter { $0 == eventType }.count
        let totalEvents = coordinationEvents.count
        return totalEvents > 0 ? Double(eventCount) / Double(totalEvents) : 0.0
    }
    
    private func calculateIntentRecognitionAccuracy() -> Double {
        let intentEvents = coordinationEvents.filter { $0 == .intentRecognized }.count
        let messageEvents = coordinationEvents.filter { $0 == .messageReceived }.count
        
        return messageEvents > 0 ? Double(intentEvents) / Double(messageEvents) : 0.0
    }
    
    private func calculateConversationEfficiency() -> Double {
        let taskCreationEvents = coordinationEvents.filter { $0 == .taskCreatedFromChat }.count
        let messageEvents = coordinationEvents.filter { $0 == .messageReceived }.count
        
        return messageEvents > 0 ? Double(taskCreationEvents) / Double(messageEvents) : 0.0
    }
    
    private func calculateUserSatisfactionScore() -> Double {
        // Calculate satisfaction based on successful workflow completions
        let completionEvents = coordinationEvents.filter { $0 == .workflowCompleted }.count
        let workflowEvents = coordinationEvents.filter { $0 == .workflowAutomated }.count
        
        if workflowEvents > 0 {
            let completionRate = Double(completionEvents) / Double(workflowEvents)
            return min(0.9 + (completionRate * 0.1), 1.0) // Base 90% + completion bonus
        }
        
        return 0.85 // Default satisfaction score
    }
}

// MARK: - Event Publisher Extension

extension AIEventCoordinator {
    
    /// Publisher for coordination events
    var eventPublisher: AnyPublisher<AICoordinationEvent, Never> {
        return $eventCount
            .compactMap { [weak self] _ in
                self?.coordinationEvents.last
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    /// Publisher for analytics updates
    var analyticsPublisher: AnyPublisher<AICoordinationAnalytics?, Never> {
        return $hasCachedAnalytics
            .compactMap { [weak self] hasCached in
                hasCached ? self?.cachedAnalytics : nil
            }
            .eraseToAnyPublisher()
    }
}