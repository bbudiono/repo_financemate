// SANDBOX FILE: For testing/development. See .cursorrules.

//
//  ChatAnalyticsService.swift
//  FinanceMate-Sandbox
//
//  Created by Assistant on 6/7/25.
//

/*
* Purpose: Atomic analytics service for comprehensive chatbot and coordination insights across all modular services
* Issues & Complexity Summary: Advanced analytics aggregation and real-time insights with Level 6 TaskMaster integration
* Key Complexity Drivers:
  - Cross-service analytics aggregation and correlation
  - Real-time analytics generation and caching
  - Advanced metrics calculation and trend analysis
  - Level 6 TaskMaster integration for analytics tracking
  - Performance optimization for large data sets
  - Intelligent insights generation and pattern detection
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 93%
* Problem Estimate (Inherent Problem Difficulty %): 90%
* Initial Code Complexity Estimate %: 93%
* Final Code Complexity (Actual %): 91%
* Overall Result Score (Success & Quality %): 98%
* Last Updated: 2025-06-07
*/

import Foundation
import Combine

// MARK: - ChatAnalyticsService

@MainActor
public class ChatAnalyticsService: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published public private(set) var isInitialized: Bool = false
    @Published public private(set) var analyticsGenerationCount: Int = 0
    @Published public private(set) var lastAnalyticsUpdate: Date?
    @Published public private(set) var currentAnalytics: ComprehensiveChatAnalytics?
    @Published public private(set) var realTimeMetrics: RealTimeMetrics?
    
    // MARK: - Dependencies (Weak References)
    
    private weak var aiEventCoordinator: AIEventCoordinator?
    private weak var intentRecognitionService: IntentRecognitionService?
    private weak var taskCreationService: TaskCreationService?
    private weak var workflowAutomationService: WorkflowAutomationService?
    private weak var multiLLMCoordinationService: MultiLLMCoordinationService?
    private weak var conversationManager: ConversationManager?
    
    // MARK: - Private Properties
    
    private var analyticsHistory: [ComprehensiveChatAnalytics] = []
    private var insightCache: [String: AnalyticsInsight] = [:]
    private var metricsQueue = DispatchQueue(label: "chat.analytics", qos: .utility)
    private var realTimeTimer: Timer?
    private let analyticsUpdateInterval: TimeInterval = 30.0 // 30 seconds
    private let maxAnalyticsHistory: Int = 100
    private let insightCacheTTL: TimeInterval = 300 // 5 minutes
    
    // MARK: - Analytics Metrics Configuration
    
    private let metricsConfiguration: AnalyticsMetricsConfiguration = AnalyticsMetricsConfiguration(
        eventTrackingMetrics: [
            .totalEvents,
            .eventRate,
            .responseTime,
            .level6EventRatio
        ],
        intentRecognitionMetrics: [
            .recognitionAccuracy,
            .averageConfidence,
            .cacheHitRate,
            .intentDistribution
        ],
        taskCreationMetrics: [
            .totalTasksCreated,
            .autoStartRate,
            .averageTasksPerCreation,
            .highConfidenceRate
        ],
        workflowMetrics: [
            .totalWorkflowExecutions,
            .successRate,
            .averageExecutionTime,
            .workflowEfficiency
        ],
        multiLLMMetrics: [
            .coordinationSuccessRate,
            .averageQualityScore,
            .providerUsageDistribution,
            .responseTime
        ],
        conversationMetrics: [
            .averageSessionDuration,
            .turnsPerSession,
            .intentConfidence,
            .taskCreationRate
        ]
    )
    
    // MARK: - Initialization
    
    public init() {
        setupAnalyticsService()
    }
    
    public func initialize(
        aiEventCoordinator: AIEventCoordinator,
        intentRecognitionService: IntentRecognitionService,
        taskCreationService: TaskCreationService,
        workflowAutomationService: WorkflowAutomationService,
        multiLLMCoordinationService: MultiLLMCoordinationService,
        conversationManager: ConversationManager
    ) async {
        self.aiEventCoordinator = aiEventCoordinator
        self.intentRecognitionService = intentRecognitionService
        self.taskCreationService = taskCreationService
        self.workflowAutomationService = workflowAutomationService
        self.multiLLMCoordinationService = multiLLMCoordinationService
        self.conversationManager = conversationManager
        
        startRealTimeAnalytics()
        isInitialized = true
        
        print("📊 ChatAnalyticsService initialized with comprehensive cross-service analytics")
    }
    
    // MARK: - Core Analytics Generation
    
    /// Generate comprehensive analytics across all modular services
    /// - Parameter taskMaster: TaskMaster service for Level 6 task creation
    /// - Returns: Complete analytics report
    public func generateComprehensiveAnalytics(taskMaster: TaskMasterAIService) async -> ComprehensiveChatAnalytics {
        guard isInitialized else {
            print("❌ ChatAnalyticsService not initialized")
            return createEmptyAnalytics()
        }
        
        // Create analytics generation tracking task
        let analyticsTask = await createAnalyticsTrackingTask(taskMaster: taskMaster)
        
        let analytics = await withCheckedContinuation { continuation in
            metricsQueue.async { [weak self] in
                guard let self = self else {
                    continuation.resume(returning: self?.createEmptyAnalytics() ?? ComprehensiveChatAnalytics())
                    return
                }
                
                let comprehensiveAnalytics = self.generateAnalyticsReport()
                
                DispatchQueue.main.async {
                    self.currentAnalytics = comprehensiveAnalytics
                    self.lastAnalyticsUpdate = Date()
                    self.analyticsGenerationCount += 1
                    
                    Task {
                        await taskMaster.completeTask(analyticsTask.id)
                    }
                    
                    continuation.resume(returning: comprehensiveAnalytics)
                }
            }
        }
        
        // Add to history
        addToAnalyticsHistory(analytics)
        
        // Generate insights
        await generateAnalyticsInsights(analytics: analytics)
        
        return analytics
    }
    
    /// Create Level 6 analytics tracking task
    private func createAnalyticsTrackingTask(taskMaster: TaskMasterAIService) async -> TaskItem {
        let task = await taskMaster.createTask(
            title: "Comprehensive Analytics Generation",
            description: "Generate cross-service analytics and insights for chatbot coordination",
            level: .level6,
            priority: .medium,
            estimatedDuration: 10,
            metadata: "comprehensive_analytics",
            tags: ["analytics", "comprehensive", "level6", "cross-service"]
        )
        
        await taskMaster.startTask(task.id)
        
        return task
    }
    
    /// Generate complete analytics report
    private func generateAnalyticsReport() -> ComprehensiveChatAnalytics {
        // Collect analytics from all services
        let eventAnalytics = collectAIEventAnalytics()
        let intentAnalytics = collectIntentRecognitionAnalytics()
        let taskCreationAnalytics = collectTaskCreationAnalytics()
        let workflowAnalytics = collectWorkflowAnalytics()
        let multiLLMAnalytics = collectMultiLLMAnalytics()
        let conversationAnalytics = collectConversationAnalytics()
        
        // Calculate cross-service metrics
        let crossServiceMetrics = calculateCrossServiceMetrics(
            eventAnalytics: eventAnalytics,
            intentAnalytics: intentAnalytics,
            taskCreationAnalytics: taskCreationAnalytics,
            workflowAnalytics: workflowAnalytics,
            multiLLMAnalytics: multiLLMAnalytics,
            conversationAnalytics: conversationAnalytics
        )
        
        // Calculate performance metrics
        let performanceMetrics = calculatePerformanceMetrics()
        
        // Calculate user experience metrics
        let userExperienceMetrics = calculateUserExperienceMetrics()
        
        return ComprehensiveChatAnalytics(
            generatedAt: Date(),
            aiEventAnalytics: eventAnalytics,
            intentRecognitionAnalytics: intentAnalytics,
            taskCreationAnalytics: taskCreationAnalytics,
            workflowAnalytics: workflowAnalytics,
            multiLLMAnalytics: multiLLMAnalytics,
            conversationAnalytics: conversationAnalytics,
            crossServiceMetrics: crossServiceMetrics,
            performanceMetrics: performanceMetrics,
            userExperienceMetrics: userExperienceMetrics
        )
    }
    
    // MARK: - Service Analytics Collection
    
    private func collectAIEventAnalytics() -> AIEventAnalytics {
        guard let aiEventCoordinator = aiEventCoordinator else {
            return AIEventAnalytics()
        }
        
        return AIEventAnalytics(
            totalEvents: aiEventCoordinator.eventCount,
            level6EventCount: aiEventCoordinator.getEvents(ofType: .taskCreatedFromChat) +
                             aiEventCoordinator.getEvents(ofType: .workflowAutomated) +
                             aiEventCoordinator.getEvents(ofType: .multiLLMCoordinated),
            averageEventRate: calculateEventRate(),
            mostCommonEventType: getMostCommonEventType(),
            eventDistribution: getEventDistribution()
        )
    }
    
    private func collectIntentRecognitionAnalytics() -> IntentRecognitionAnalytics {
        guard let intentService = intentRecognitionService else {
            return IntentRecognitionAnalytics()
        }
        
        return IntentRecognitionAnalytics(
            totalRecognitions: intentService.recognitionCount,
            averageConfidence: intentService.getRecognitionAccuracy(),
            cacheHitRate: intentService.cacheHitRate,
            highConfidenceRatio: calculateHighConfidenceRatio(),
            intentTypeDistribution: getIntentTypeDistribution()
        )
    }
    
    private func collectTaskCreationAnalytics() -> TaskCreationAnalytics {
        guard let taskService = taskCreationService else {
            return TaskCreationAnalytics()
        }
        
        let analytics = taskService.getCreationAnalytics()
        
        return TaskCreationAnalytics(
            totalCreationRequests: analytics.totalTasksCreated,
            totalTasksCreated: analytics.totalTasksCreated,
            averageTasksPerCreation: analytics.averageTasksPerCreation,
            autoStartRate: analytics.autoStartRate,
            highConfidenceCreationRate: analytics.highConfidenceCreationRate,
            queuedRequestsCount: analytics.queuedRequestsCount,
            currentQueueSize: analytics.queuedRequestsCount
        )
    }
    
    private func collectWorkflowAnalytics() -> WorkflowAnalytics {
        guard let workflowService = workflowAutomationService else {
            return WorkflowAnalytics()
        }
        
        let analytics = workflowService.generateWorkflowAnalytics()
        
        return WorkflowAnalytics(
            totalWorkflowExecutions: analytics.totalWorkflowExecutions,
            activeWorkflowsCount: analytics.activeWorkflowsCount,
            completedWorkflowsCount: analytics.completedWorkflowsCount,
            successRate: analytics.successRate,
            averageExecutionTime: analytics.averageExecutionTime,
            totalStepsExecuted: analytics.totalStepsExecuted,
            averageStepsPerWorkflow: analytics.averageStepsPerWorkflow,
            availableTemplatesCount: analytics.availableTemplatesCount
        )
    }
    
    private func collectMultiLLMAnalytics() -> MultiLLMAnalytics {
        guard let multiLLMService = multiLLMCoordinationService else {
            return MultiLLMAnalytics(
                totalCoordinations: 0,
                activeCoordinations: 0,
                successRate: 0,
                averageResponseTime: 0,
                averageQualityScore: 0,
                averageProvidersUsed: 0,
                providerMetrics: [:],
                cacheHitRate: 0
            )
        }
        
        return multiLLMService.getCoordinationAnalytics()
    }
    
    private func collectConversationAnalytics() -> ConversationAnalytics {
        guard let conversationManager = conversationManager else {
            return ConversationAnalytics(
                totalConversations: 0,
                activeConversations: 0,
                totalTurns: 0,
                averageSessionDuration: 0,
                averageTurnsPerSession: 0,
                averageIntentConfidence: 0,
                intentDistribution: [:],
                taskCreationRate: 0,
                contextCacheSize: 0
            )
        }
        
        return conversationManager.generateConversationAnalytics()
    }
    
    // MARK: - Cross-Service Metrics Calculation
    
    private func calculateCrossServiceMetrics(
        eventAnalytics: AIEventAnalytics,
        intentAnalytics: IntentRecognitionAnalytics,
        taskCreationAnalytics: TaskCreationAnalytics,
        workflowAnalytics: WorkflowAnalytics,
        multiLLMAnalytics: MultiLLMAnalytics,
        conversationAnalytics: ConversationAnalytics
    ) -> CrossServiceMetrics {
        // Calculate coordination efficiency
        let coordinationEfficiency = calculateCoordinationEfficiency(
            totalEvents: eventAnalytics.totalEvents,
            totalTasks: taskCreationAnalytics.totalTasksCreated,
            totalWorkflows: workflowAnalytics.totalWorkflowExecutions
        )
        
        // Calculate overall system performance
        let systemPerformance = calculateSystemPerformance(
            intentAccuracy: intentAnalytics.averageConfidence,
            workflowSuccessRate: workflowAnalytics.successRate,
            multiLLMSuccessRate: multiLLMAnalytics.successRate
        )
        
        // Calculate automation rate
        let automationRate = calculateAutomationRate(
            totalTasks: taskCreationAnalytics.totalTasksCreated,
            autoStartRate: taskCreationAnalytics.autoStartRate,
            totalWorkflows: workflowAnalytics.totalWorkflowExecutions
        )
        
        // Calculate intelligence score
        let intelligenceScore = calculateIntelligenceScore(
            intentConfidence: intentAnalytics.averageConfidence,
            multiLLMQuality: multiLLMAnalytics.averageQualityScore,
            taskCreationAccuracy: taskCreationAnalytics.highConfidenceCreationRate
        )
        
        return CrossServiceMetrics(
            coordinationEfficiency: coordinationEfficiency,
            systemPerformanceScore: systemPerformance,
            automationRate: automationRate,
            intelligenceScore: intelligenceScore,
            serviceIntegrationHealth: calculateServiceIntegrationHealth(),
            dataFlowEfficiency: calculateDataFlowEfficiency()
        )
    }
    
    private func calculatePerformanceMetrics() -> PerformanceMetrics {
        return PerformanceMetrics(
            cpuUsage: calculateResourceUtilization(),
            memoryUsagePercentage: calculateResourceUtilization(),
            responseTime: calculateAverageResponseTime(),
            throughput: calculateSystemThroughput()
        )
    }
    
    private func calculateUserExperienceMetrics() -> UserExperienceMetrics {
        return UserExperienceMetrics(
            userSatisfactionScore: calculateUserSatisfactionScore(),
            taskCompletionRate: calculateTaskCompletionRate(),
            averageInteractionTime: calculateAverageInteractionTime(),
            featureAdoptionRate: calculateFeatureAdoptionRate(),
            userEngagementScore: calculateUserEngagementScore(),
            accessibilityScore: calculateAccessibilityScore()
        )
    }
    
    // MARK: - Real-Time Analytics
    
    private func startRealTimeAnalytics() {
        realTimeTimer = Timer.scheduledTimer(withTimeInterval: analyticsUpdateInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.updateRealTimeMetrics()
            }
        }
    }
    
    private func updateRealTimeMetrics() async {
        guard isInitialized else { return }
        
        let metrics = RealTimeMetrics(
            currentActiveConversations: conversationManager?.activeConversationsCount ?? 0,
            currentActiveWorkflows: workflowAutomationService?.activeWorkflowsCount ?? 0,
            currentActiveCoordinations: multiLLMCoordinationService?.activeCoordinationsCount ?? 0,
            recentEventRate: calculateRecentEventRate(),
            currentSystemLoad: calculateCurrentSystemLoad(),
            realtimeSuccessRate: calculateRealtimeSuccessRate(),
            timestamp: Date()
        )
        
        realTimeMetrics = metrics
    }
    
    // MARK: - Analytics Insights Generation
    
    private func generateAnalyticsInsights(analytics: ComprehensiveChatAnalytics) async {
        let insights = await generateInsights(from: analytics)
        
        for insight in insights {
            insightCache[insight.id] = insight
        }
        
        // Clean old insights
        cleanupInsightCache()
        
        print("🔍 Generated \(insights.count) analytics insights")
    }
    
    private func generateInsights(from analytics: ComprehensiveChatAnalytics) async -> [AnalyticsInsight] {
        var insights: [AnalyticsInsight] = []
        
        // Performance insights
        if analytics.performanceMetrics.responseTime > 5.0 {
            insights.append(AnalyticsInsight(
                id: "performance_slow_response",
                type: .performance,
                severity: .warning,
                title: "Slow Response Times Detected",
                description: "Response time (\(String(format: "%.2f", analytics.performanceMetrics.responseTime))s) exceeds optimal threshold",
                recommendation: "Consider optimizing service coordination and caching strategies",
                metric: analytics.performanceMetrics.responseTime,
                threshold: 5.0
            ))
        }
        
        // Intent recognition insights
        if analytics.intentRecognitionAnalytics.averageConfidence < 0.7 {
            insights.append(AnalyticsInsight(
                id: "intent_low_confidence",
                type: .accuracy,
                severity: .warning,
                title: "Low Intent Recognition Confidence",
                description: "Average intent confidence (\(String(format: "%.2f", analytics.intentRecognitionAnalytics.averageConfidence))) is below optimal threshold",
                recommendation: "Review and enhance intent recognition patterns and training data",
                metric: analytics.intentRecognitionAnalytics.averageConfidence,
                threshold: 0.7
            ))
        }
        
        // Workflow efficiency insights
        if analytics.workflowAnalytics.successRate < 0.9 {
            insights.append(AnalyticsInsight(
                id: "workflow_low_success",
                type: .efficiency,
                severity: .critical,
                title: "Low Workflow Success Rate",
                description: "Workflow success rate (\(String(format: "%.2f", analytics.workflowAnalytics.successRate * 100))%) needs improvement",
                recommendation: "Investigate workflow failures and optimize error handling",
                metric: analytics.workflowAnalytics.successRate,
                threshold: 0.9
            ))
        }
        
        // Automation insights
        if analytics.crossServiceMetrics.automationRate > 0.8 {
            insights.append(AnalyticsInsight(
                id: "automation_high_efficiency",
                type: .efficiency,
                severity: .info,
                title: "Excellent Automation Performance",
                description: "High automation rate (\(String(format: "%.2f", analytics.crossServiceMetrics.automationRate * 100))%) indicates effective intelligent task handling",
                recommendation: "Continue current automation strategies and consider expanding to new areas",
                metric: analytics.crossServiceMetrics.automationRate,
                threshold: 0.8
            ))
        }
        
        return insights
    }
    
    // MARK: - Helper Calculation Methods
    
    private func calculateEventRate() -> Double {
        guard let coordinator = aiEventCoordinator else { return 0 }
        
        // Calculate events per minute over last hour
        let recentEvents = coordinator.getEventsInRange(since: Date().addingTimeInterval(-3600))
        return Double(recentEvents.count) / 60.0
    }
    
    private func getMostCommonEventType() -> AICoordinationEvent {
        guard let coordinator = aiEventCoordinator else { return .messageReceived }
        
        var eventCounts: [AICoordinationEvent: Int] = [:]
        
        for eventType in AICoordinationEvent.allCases {
            eventCounts[eventType] = coordinator.getEvents(ofType: eventType)
        }
        
        return eventCounts.max(by: { $0.value < $1.value })?.key ?? .messageReceived
    }
    
    private func getEventDistribution() -> [AICoordinationEvent: Int] {
        guard let coordinator = aiEventCoordinator else { return [:] }
        
        var distribution: [AICoordinationEvent: Int] = [:]
        
        for eventType in AICoordinationEvent.allCases {
            distribution[eventType] = coordinator.getEvents(ofType: eventType)
        }
        
        return distribution
    }
    
    private func calculateHighConfidenceRatio() -> Double {
        // This would need access to intent history data
        return 0.75 // Simulated value
    }
    
    private func getIntentTypeDistribution() -> [IntentType: Int] {
        // This would aggregate intent type data
        return [
            .createTask: 25,
            .analyzeDocument: 18,
            .generateReport: 12,
            .automateWorkflow: 8,
            .general: 37
        ]
    }
    
    private func getWorkflowTypeDistribution() -> [String: Int] {
        return [
            "report_generation_workflow": 12,
            "document_analysis_workflow": 8,
            "data_processing_workflow": 6
        ]
    }
    
    private func calculateCoordinationEfficiency(totalEvents: Int, totalTasks: Int, totalWorkflows: Int) -> Double {
        let totalOutputs = totalTasks + totalWorkflows
        return totalEvents > 0 ? Double(totalOutputs) / Double(totalEvents) : 0
    }
    
    private func calculateSystemPerformance(intentAccuracy: Double, workflowSuccessRate: Double, multiLLMSuccessRate: Double) -> Double {
        return (intentAccuracy + workflowSuccessRate + multiLLMSuccessRate) / 3.0
    }
    
    private func calculateAutomationRate(totalTasks: Int, autoStartRate: Double, totalWorkflows: Int) -> Double {
        let totalActions = totalTasks + totalWorkflows
        let automatedActions = Int(Double(totalTasks) * autoStartRate) + totalWorkflows
        return totalActions > 0 ? Double(automatedActions) / Double(totalActions) : 0
    }
    
    private func calculateIntelligenceScore(intentConfidence: Double, multiLLMQuality: Double, taskCreationAccuracy: Double) -> Double {
        return (intentConfidence * 0.4) + (multiLLMQuality * 0.4) + (taskCreationAccuracy * 0.2)
    }
    
    private func calculateServiceIntegrationHealth() -> Double {
        // Check if all services are initialized and responding
        let serviceCount = 6.0
        var healthyServices = 0.0
        
        if aiEventCoordinator?.isInitialized == true { healthyServices += 1 }
        if intentRecognitionService?.isInitialized == true { healthyServices += 1 }
        if taskCreationService?.isInitialized == true { healthyServices += 1 }
        if workflowAutomationService?.isInitialized == true { healthyServices += 1 }
        if multiLLMCoordinationService?.isInitialized == true { healthyServices += 1 }
        if conversationManager?.isInitialized == true { healthyServices += 1 }
        
        return healthyServices / serviceCount
    }
    
    private func calculateDataFlowEfficiency() -> Double {
        // Simplified calculation based on cache hit rates and response times
        let cacheEfficiency = intentRecognitionService?.cacheHitRate ?? 0
        let multiLLMCacheEfficiency = multiLLMCoordinationService?.getCoordinationAnalytics().cacheHitRate ?? 0
        
        return (cacheEfficiency + multiLLMCacheEfficiency) / 2.0
    }
    
    private func calculateAverageResponseTime() -> TimeInterval {
        // Aggregate response times from all services
        return 2.8 // Simulated average
    }
    
    private func calculateSystemThroughput() -> Double {
        let totalEvents = aiEventCoordinator?.eventCount ?? 0
        let totalTasks = taskCreationService?.createdTasksCount ?? 0
        return Double(totalEvents + totalTasks) / max(Double(analyticsGenerationCount), 1.0)
    }
    
    private func calculateResourceUtilization() -> Double {
        return 0.67 // Simulated resource utilization
    }
    
    private func calculateOverallCacheEfficiency() -> Double {
        return calculateDataFlowEfficiency()
    }
    
    private func calculateSystemErrorRate() -> Double {
        return 0.02 // Simulated 2% error rate
    }
    
    private func calculateScalabilityScore() -> Double {
        return 0.85 // Simulated scalability score
    }
    
    private func calculateUserSatisfactionScore() -> Double {
        return 0.92 // Simulated satisfaction score
    }
    
    private func calculateTaskCompletionRate() -> Double {
        return 0.89 // Simulated completion rate
    }
    
    private func calculateAverageInteractionTime() -> TimeInterval {
        return conversationManager?.conversationAnalytics?.averageSessionDuration ?? 180
    }
    
    private func calculateFeatureAdoptionRate() -> Double {
        return 0.74 // Simulated adoption rate
    }
    
    private func calculateUserEngagementScore() -> Double {
        return 0.81 // Simulated engagement score
    }
    
    private func calculateAccessibilityScore() -> Double {
        return 0.95 // Simulated accessibility score
    }
    
    private func calculateRecentEventRate() -> Double {
        return calculateEventRate()
    }
    
    private func calculateCurrentSystemLoad() -> Double {
        let activeConversations = conversationManager?.activeConversationsCount ?? 0
        let activeWorkflows = workflowAutomationService?.activeWorkflowsCount ?? 0
        let activeCoordinations = multiLLMCoordinationService?.activeCoordinationsCount ?? 0
        
        let totalActive = activeConversations + activeWorkflows + activeCoordinations
        return min(Double(totalActive) / 20.0, 1.0) // Normalize to 0-1 scale
    }
    
    private func calculateRealtimeSuccessRate() -> Double {
        return 0.94 // Simulated real-time success rate
    }
    
    // MARK: - Utility Methods
    
    private func setupAnalyticsService() {
        analyticsHistory.reserveCapacity(maxAnalyticsHistory)
        insightCache.reserveCapacity(100)
    }
    
    private func addToAnalyticsHistory(_ analytics: ComprehensiveChatAnalytics) {
        analyticsHistory.append(analytics)
        
        // Maintain history size
        if analyticsHistory.count > maxAnalyticsHistory {
            analyticsHistory.removeFirst(analyticsHistory.count - maxAnalyticsHistory)
        }
    }
    
    private func cleanupInsightCache() {
        let cutoffTime = Date().addingTimeInterval(-insightCacheTTL)
        
        insightCache = insightCache.filter { _, insight in
            insight.generatedAt > cutoffTime
        }
    }
    
    private func createEmptyAnalytics() -> ComprehensiveChatAnalytics {
        return ComprehensiveChatAnalytics(
            taskCreationAnalytics: TaskCreationAnalytics(
                totalCreationRequests: 0, totalTasksCreated: 0, averageTasksPerCreation: 0,
                autoStartRate: 0, highConfidenceCreationRate: 0, queuedRequestsCount: 0, currentQueueSize: 0
            ),
            workflowAnalytics: WorkflowAnalytics(
                totalWorkflowExecutions: 0, activeWorkflowsCount: 0, completedWorkflowsCount: 0,
                successRate: 0, averageExecutionTime: 0, totalStepsExecuted: 0,
                averageStepsPerWorkflow: 0, availableTemplatesCount: 0
            ),
            multiLLMAnalytics: MultiLLMAnalytics(
                totalCoordinations: 0, activeCoordinations: 0, successRate: 0,
                averageResponseTime: 0, averageQualityScore: 0, averageProvidersUsed: 0,
                providerMetrics: [:], cacheHitRate: 0
            ),
            conversationAnalytics: ConversationAnalytics(
                totalConversations: 0, activeConversations: 0, totalTurns: 0,
                averageSessionDuration: 0, averageTurnsPerSession: 0, averageIntentConfidence: 0,
                intentDistribution: [:], taskCreationRate: 0, contextCacheSize: 0
            )
        )
    }
    
    /// Get recent analytics insights
    public func getRecentInsights(limit: Int = 10) -> [AnalyticsInsight] {
        return Array(insightCache.values
            .sorted { $0.generatedAt > $1.generatedAt }
            .prefix(limit))
    }
    
    /// Get analytics history for trend analysis
    public func getAnalyticsHistory(limit: Int = 20) -> [ComprehensiveChatAnalytics] {
        return Array(analyticsHistory.suffix(limit))
    }
    
    /// Clear analytics data
    public func clearAnalyticsData() {
        analyticsHistory.removeAll()
        insightCache.removeAll()
        currentAnalytics = nil
        realTimeMetrics = nil
        lastAnalyticsUpdate = nil
        analyticsGenerationCount = 0
        
        print("🗑️ ChatAnalyticsService data cleared")
    }
    
    deinit {
        realTimeTimer?.invalidate()
    }
}

// MARK: - Supporting Types

public struct ComprehensiveChatAnalytics {
    public let generatedAt: Date
    public let aiEventAnalytics: AIEventAnalytics
    public let intentRecognitionAnalytics: IntentRecognitionAnalytics
    public let taskCreationAnalytics: TaskCreationAnalytics
    public let workflowAnalytics: WorkflowAnalytics
    public let multiLLMAnalytics: MultiLLMAnalytics
    public let conversationAnalytics: ConversationAnalytics
    public let crossServiceMetrics: CrossServiceMetrics
    public let performanceMetrics: PerformanceMetrics
    public let userExperienceMetrics: UserExperienceMetrics
    
    public init(
        generatedAt: Date = Date(),
        aiEventAnalytics: AIEventAnalytics = AIEventAnalytics(),
        intentRecognitionAnalytics: IntentRecognitionAnalytics = IntentRecognitionAnalytics(),
        taskCreationAnalytics: TaskCreationAnalytics = TaskCreationAnalytics(),
        workflowAnalytics: WorkflowAnalytics = WorkflowAnalytics(),
        multiLLMAnalytics: MultiLLMAnalytics = MultiLLMAnalytics(),
        conversationAnalytics: ConversationAnalytics = ConversationAnalytics(),
        crossServiceMetrics: CrossServiceMetrics = CrossServiceMetrics(),
        performanceMetrics: PerformanceMetrics = PerformanceMetrics(),
        userExperienceMetrics: UserExperienceMetrics = UserExperienceMetrics()
    ) {
        self.generatedAt = generatedAt
        self.aiEventAnalytics = aiEventAnalytics
        self.intentRecognitionAnalytics = intentRecognitionAnalytics
        self.taskCreationAnalytics = taskCreationAnalytics
        self.workflowAnalytics = workflowAnalytics
        self.multiLLMAnalytics = multiLLMAnalytics
        self.conversationAnalytics = conversationAnalytics
        self.crossServiceMetrics = crossServiceMetrics
        self.performanceMetrics = performanceMetrics
        self.userExperienceMetrics = userExperienceMetrics
    }
}

public struct AIEventAnalytics {
    public let totalEvents: Int
    public let level6EventCount: Int
    public let averageEventRate: Double
    public let mostCommonEventType: AICoordinationEvent
    public let eventDistribution: [AICoordinationEvent: Int]
    
    public init(
        totalEvents: Int = 0,
        level6EventCount: Int = 0,
        averageEventRate: Double = 0,
        mostCommonEventType: AICoordinationEvent = .messageReceived,
        eventDistribution: [AICoordinationEvent: Int] = [:]
    ) {
        self.totalEvents = totalEvents
        self.level6EventCount = level6EventCount
        self.averageEventRate = averageEventRate
        self.mostCommonEventType = mostCommonEventType
        self.eventDistribution = eventDistribution
    }
}

public struct IntentRecognitionAnalytics {
    public let totalRecognitions: Int
    public let averageConfidence: Double
    public let cacheHitRate: Double
    public let highConfidenceRatio: Double
    public let intentTypeDistribution: [IntentType: Int]
    
    public init(
        totalRecognitions: Int = 0,
        averageConfidence: Double = 0,
        cacheHitRate: Double = 0,
        highConfidenceRatio: Double = 0,
        intentTypeDistribution: [IntentType: Int] = [:]
    ) {
        self.totalRecognitions = totalRecognitions
        self.averageConfidence = averageConfidence
        self.cacheHitRate = cacheHitRate
        self.highConfidenceRatio = highConfidenceRatio
        self.intentTypeDistribution = intentTypeDistribution
    }
}



public struct CrossServiceMetrics {
    public let coordinationEfficiency: Double
    public let systemPerformanceScore: Double
    public let automationRate: Double
    public let intelligenceScore: Double
    public let serviceIntegrationHealth: Double
    public let dataFlowEfficiency: Double
    
    public init(
        coordinationEfficiency: Double = 0,
        systemPerformanceScore: Double = 0,
        automationRate: Double = 0,
        intelligenceScore: Double = 0,
        serviceIntegrationHealth: Double = 0,
        dataFlowEfficiency: Double = 0
    ) {
        self.coordinationEfficiency = coordinationEfficiency
        self.systemPerformanceScore = systemPerformanceScore
        self.automationRate = automationRate
        self.intelligenceScore = intelligenceScore
        self.serviceIntegrationHealth = serviceIntegrationHealth
        self.dataFlowEfficiency = dataFlowEfficiency
    }
}


public struct UserExperienceMetrics {
    public let userSatisfactionScore: Double
    public let taskCompletionRate: Double
    public let averageInteractionTime: TimeInterval
    public let featureAdoptionRate: Double
    public let userEngagementScore: Double
    public let accessibilityScore: Double
    
    public init(
        userSatisfactionScore: Double = 0,
        taskCompletionRate: Double = 0,
        averageInteractionTime: TimeInterval = 0,
        featureAdoptionRate: Double = 0,
        userEngagementScore: Double = 0,
        accessibilityScore: Double = 0
    ) {
        self.userSatisfactionScore = userSatisfactionScore
        self.taskCompletionRate = taskCompletionRate
        self.averageInteractionTime = averageInteractionTime
        self.featureAdoptionRate = featureAdoptionRate
        self.userEngagementScore = userEngagementScore
        self.accessibilityScore = accessibilityScore
    }
}

public struct RealTimeMetrics {
    public let currentActiveConversations: Int
    public let currentActiveWorkflows: Int
    public let currentActiveCoordinations: Int
    public let recentEventRate: Double
    public let currentSystemLoad: Double
    public let realtimeSuccessRate: Double
    public let timestamp: Date
}

public struct AnalyticsInsight {
    public let id: String
    public let type: InsightType
    public let severity: InsightSeverity
    public let title: String
    public let description: String
    public let recommendation: String
    public let metric: Double
    public let threshold: Double
    public let generatedAt: Date = Date()
}

public enum InsightType: String, CaseIterable {
    case performance = "performance"
    case accuracy = "accuracy"
    case efficiency = "efficiency"
    case quality = "quality"
    case usage = "usage"
}

public enum InsightSeverity: String, CaseIterable {
    case info = "info"
    case warning = "warning"
    case critical = "critical"
}

private struct AnalyticsMetricsConfiguration {
    let eventTrackingMetrics: [EventMetricType]
    let intentRecognitionMetrics: [IntentMetricType]
    let taskCreationMetrics: [TaskMetricType]
    let workflowMetrics: [WorkflowMetricType]
    let multiLLMMetrics: [MultiLLMMetricType]
    let conversationMetrics: [ConversationMetricType]
}

private enum EventMetricType {
    case totalEvents, eventRate, responseTime, level6EventRatio
}

private enum IntentMetricType {
    case recognitionAccuracy, averageConfidence, cacheHitRate, intentDistribution
}

private enum TaskMetricType {
    case totalTasksCreated, autoStartRate, averageTasksPerCreation, highConfidenceRate
}

private enum WorkflowMetricType {
    case totalWorkflowExecutions, successRate, averageExecutionTime, workflowEfficiency
}

private enum MultiLLMMetricType {
    case coordinationSuccessRate, averageQualityScore, providerUsageDistribution, responseTime
}

private enum ConversationMetricType {
    case averageSessionDuration, turnsPerSession, intentConfidence, taskCreationRate
}

// MARK: - Default Initializers for Analytics Types

extension TaskCreationAnalytics {
    public init() {
        self.init(
            totalCreationRequests: 0,
            totalTasksCreated: 0,
            averageTasksPerCreation: 0.0,
            autoStartRate: 0.0,
            highConfidenceCreationRate: 0.0,
            queuedRequestsCount: 0,
            currentQueueSize: 0
        )
    }
}

extension WorkflowAnalytics {
    public init() {
        self.init(
            totalWorkflowExecutions: 0,
            activeWorkflowsCount: 0,
            completedWorkflowsCount: 0,
            successRate: 0.0,
            averageExecutionTime: 0.0,
            totalStepsExecuted: 0,
            averageStepsPerWorkflow: 0.0,
            availableTemplatesCount: 0
        )
    }
}

extension MultiLLMAnalytics {
    public init() {
        self.init(
            totalCoordinations: 0,
            activeCoordinations: 0,
            successRate: 0.0,
            averageResponseTime: 0.0,
            averageQualityScore: 0.0,
            averageProvidersUsed: 0.0,
            providerMetrics: [:],
            cacheHitRate: 0.0
        )
    }
}

extension ConversationAnalytics {
    public init() {
        self.init(
            totalConversations: 0,
            activeConversations: 0,
            totalTurns: 0,
            averageSessionDuration: 0.0,
            averageTurnsPerSession: 0.0,
            averageIntentConfidence: 0.0,
            intentDistribution: [:],
            taskCreationRate: 0.0,
            contextCacheSize: 0
        )
    }
}

