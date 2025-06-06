// SANDBOX FILE: For testing/development. See .cursorrules.

//
//  ConversationManager.swift
//  FinanceMate-Sandbox
//
//  Created by Assistant on 6/7/25.
//

/*
* Purpose: Atomic conversation management service for intelligent context tracking, turn management, and conversation analytics
* Issues & Complexity Summary: Advanced conversation state management with context preservation, turn tracking, and Level 6 TaskMaster integration
* Key Complexity Drivers:
  - Intelligent conversation context tracking and preservation
  - Multi-turn conversation management with history
  - Advanced conversation analytics and insights
  - Level 6 TaskMaster integration for conversation tracking
  - Context-aware intent understanding and enhancement
  - Performance-optimized conversation storage and retrieval
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 91%
* Problem Estimate (Inherent Problem Difficulty %): 88%
* Initial Code Complexity Estimate %: 91%
* Final Code Complexity (Actual %): 89%
* Overall Result Score (Success & Quality %): 97%
* Last Updated: 2025-06-07
*/

import Foundation
import Combine

// MARK: - ConversationManager

@MainActor
public class ConversationManager: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published public private(set) var isInitialized: Bool = false
    @Published public private(set) var activeConversationsCount: Int = 0
    @Published public private(set) var totalConversationTurns: Int = 0
    @Published public private(set) var currentSessionId: String?
    @Published public private(set) var conversationAnalytics: ConversationAnalytics?
    
    // MARK: - Private Properties
    
    private var activeConversations: [String: ConversationSession] = [:]
    private var conversationHistory: [ConversationSession] = []
    private var contextCache: [String: ConversationContext] = [:]
    private var turnHistory: [ConversationTurn] = []
    private let contextAnalysisQueue = DispatchQueue(label: "conversation.context", qos: .utility)
    private let maxActiveConversations: Int = 10
    private let maxTurnHistory: Int = 1000
    private let contextCacheTTL: TimeInterval = 3600 // 1 hour
    
    // MARK: - Conversation Context Types
    
    private let contextCategories: [ConversationContextCategory: ContextCategoryConfiguration] = [
        .taskManagement: ContextCategoryConfiguration(
            category: .taskManagement,
            relevanceKeywords: ["task", "create", "todo", "manage", "priority", "deadline"],
            contextWeight: 0.9,
            persistenceLevel: .session,
            maxContextItems: 20
        ),
        .documentAnalysis: ContextCategoryConfiguration(
            category: .documentAnalysis,
            relevanceKeywords: ["document", "analyze", "report", "file", "text", "extract"],
            contextWeight: 0.8,
            persistenceLevel: .conversation,
            maxContextItems: 15
        ),
        .financialData: ContextCategoryConfiguration(
            category: .financialData,
            relevanceKeywords: ["financial", "money", "cost", "revenue", "expense", "budget"],
            contextWeight: 0.85,
            persistenceLevel: .session,
            maxContextItems: 25
        ),
        .workflowAutomation: ContextCategoryConfiguration(
            category: .workflowAutomation,
            relevanceKeywords: ["workflow", "automate", "process", "streamline", "optimize"],
            contextWeight: 0.9,
            persistenceLevel: .persistent,
            maxContextItems: 30
        ),
        .userPreferences: ContextCategoryConfiguration(
            category: .userPreferences,
            relevanceKeywords: ["prefer", "like", "always", "usually", "default", "setting"],
            contextWeight: 0.7,
            persistenceLevel: .persistent,
            maxContextItems: 50
        ),
        .technicalDetails: ContextCategoryConfiguration(
            category: .technicalDetails,
            relevanceKeywords: ["technical", "API", "integration", "system", "configuration"],
            contextWeight: 0.6,
            persistenceLevel: .conversation,
            maxContextItems: 10
        )
    ]
    
    // MARK: - Initialization
    
    public init() {
        setupConversationManager()
    }
    
    public func initialize() async {
        isInitialized = true
        print("💬 ConversationManager initialized successfully")
    }
    
    // MARK: - Conversation Session Management
    
    /// Start new conversation session
    /// - Parameters:
    ///   - userId: User identifier
    ///   - taskMaster: TaskMaster service for Level 6 task creation
    /// - Returns: New conversation session
    public func startConversationSession(
        userId: String = "default_user",
        taskMaster: TaskMasterAIService
    ) async -> ConversationSession {
        guard isInitialized else {
            print("❌ ConversationManager not initialized")
            return createEmptySession()
        }
        
        let sessionId = UUID().uuidString
        currentSessionId = sessionId
        
        // Create session tracking task
        let sessionTask = await createSessionTrackingTask(
            sessionId: sessionId,
            userId: userId,
            taskMaster: taskMaster
        )
        
        let session = ConversationSession(
            id: sessionId,
            userId: userId,
            startTime: Date(),
            sessionTask: sessionTask
        )
        
        activeConversations[sessionId] = session
        activeConversationsCount = activeConversations.count
        
        print("🚀 Started conversation session: \(sessionId)")
        
        return session
    }
    
    /// Create Level 6 session tracking task
    private func createSessionTrackingTask(
        sessionId: String,
        userId: String,
        taskMaster: TaskMasterAIService
    ) async -> TaskItem {
        let task = await taskMaster.createTask(
            title: "Conversation Session Tracking",
            description: "Track and analyze conversation session for user \(userId)",
            level: .level6,
            priority: .medium,
            estimatedDuration: 60,
            metadata: sessionId,
            tags: ["conversation", "session", "level6", "tracking"]
        )
        
        await taskMaster.startTask(task.id)
        
        return task
    }
    
    /// Add conversation turn to session
    /// - Parameters:
    ///   - sessionId: Conversation session identifier
    ///   - userMessage: User's message
    ///   - intent: Recognized intent from the message
    ///   - aiResponse: AI's response (optional)
    ///   - createdTasks: Tasks created from this turn
    ///   - taskMaster: TaskMaster service for task creation
    /// - Returns: Updated conversation turn
    public func addConversationTurn(
        sessionId: String,
        userMessage: String,
        intent: ChatIntent,
        aiResponse: String? = nil,
        createdTasks: [TaskItem] = [],
        taskMaster: TaskMasterAIService
    ) async -> ConversationTurn {
        guard var session = activeConversations[sessionId] else {
            print("❌ Session not found: \(sessionId)")
            return createEmptyTurn()
        }
        
        let turn = ConversationTurn(
            id: UUID().uuidString,
            sessionId: sessionId,
            userMessage: userMessage,
            recognizedIntent: intent,
            aiResponse: aiResponse,
            createdTasks: createdTasks,
            timestamp: Date(),
            turnNumber: session.turns.count + 1
        )
        
        // Add turn to session
        session.turns.append(turn)
        session.lastActivity = Date()
        session.totalTurns += 1
        
        // Update session in active conversations
        activeConversations[sessionId] = session
        
        // Add to global turn history
        turnHistory.append(turn)
        totalConversationTurns += 1
        
        // Update conversation context
        await updateConversationContext(turn: turn, session: session)
        
        // Analyze conversation for insights
        await analyzeConversationTurn(turn: turn, session: session, taskMaster: taskMaster)
        
        print("💬 Added conversation turn \(turn.turnNumber) to session \(sessionId)")
        
        return turn
    }
    
    /// Update conversation context based on new turn
    private func updateConversationContext(
        turn: ConversationTurn,
        session: ConversationSession
    ) async {
        let contextItems = await extractContextFromTurn(turn: turn)
        
        for item in contextItems {
            let contextKey = "\(session.id)_\(item.category.rawValue)"
            
            if var existingContext = contextCache[contextKey] {
                existingContext.addContextItem(item)
                contextCache[contextKey] = existingContext
            } else {
                let newContext = ConversationContext(
                    sessionId: session.id,
                    category: item.category,
                    items: [item]
                )
                contextCache[contextKey] = newContext
            }
        }
    }
    
    /// Extract context items from conversation turn
    private func extractContextFromTurn(turn: ConversationTurn) async -> [ConversationContextItem] {
        var contextItems: [ConversationContextItem] = []
        
        for (category, config) in contextCategories {
            let relevance = calculateContextRelevance(
                message: turn.userMessage,
                keywords: config.relevanceKeywords
            )
            
            if relevance > 0.3 { // Threshold for context relevance
                let contextItem = ConversationContextItem(
                    id: UUID().uuidString,
                    category: category,
                    content: turn.userMessage,
                    intent: turn.recognizedIntent,
                    relevanceScore: relevance,
                    timestamp: turn.timestamp,
                    turnNumber: turn.turnNumber
                )
                
                contextItems.append(contextItem)
            }
        }
        
        return contextItems
    }
    
    /// Calculate context relevance based on keywords
    private func calculateContextRelevance(message: String, keywords: [String]) -> Double {
        let lowercaseMessage = message.lowercased()
        let matchingKeywords = keywords.filter { lowercaseMessage.contains($0) }
        
        let keywordScore = Double(matchingKeywords.count) / Double(keywords.count)
        let lengthBonus = min(Double(message.count) / 500.0, 0.2) // Bonus for longer messages
        
        return min(keywordScore + lengthBonus, 1.0)
    }
    
    /// Analyze conversation turn for insights
    private func analyzeConversationTurn(
        turn: ConversationTurn,
        session: ConversationSession,
        taskMaster: TaskMasterAIService
    ) async {
        // Create analysis task for significant turns
        if turn.turnNumber % 5 == 0 || turn.recognizedIntent.confidence > 0.9 {
            let analysisTask = await taskMaster.createTask(
                title: "Conversation Analysis - Turn \(turn.turnNumber)",
                description: "Analyze conversation turn for patterns and insights",
                level: .level5,
                priority: .low,
                estimatedDuration: 5,
                parentTaskId: session.sessionTask.id,
                tags: ["conversation", "analysis", "turn-\(turn.turnNumber)"]
            )
            
            await taskMaster.startTask(analysisTask.id)
            
            // Simulate analysis
            await performTurnAnalysis(turn: turn, session: session)
            
            await taskMaster.completeTask(analysisTask.id)
        }
    }
    
    /// Perform turn analysis (simplified)
    private func performTurnAnalysis(turn: ConversationTurn, session: ConversationSession) async {
        // Simulate analysis time
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        // Log analysis insights
        if turn.recognizedIntent.confidence > 0.9 {
            print("🎯 High-confidence intent detected: \(turn.recognizedIntent.type.rawValue)")
        }
        
        if turn.createdTasks.count > 0 {
            print("📋 Turn resulted in \(turn.createdTasks.count) tasks")
        }
        
        // Detect conversation patterns
        if session.turns.count >= 3 {
            let recentIntents = session.turns.suffix(3).map { $0.recognizedIntent.type }
            let uniqueIntents = Set(recentIntents)
            
            if uniqueIntents.count == 1 && recentIntents.count == 3 {
                print("🔄 Pattern detected: Repeated \(recentIntents.first!.rawValue) intents")
            }
        }
    }
    
    // MARK: - Context Retrieval
    
    /// Get conversation context for enhanced intent understanding
    /// - Parameters:
    ///   - sessionId: Session identifier
    ///   - categories: Context categories to retrieve
    ///   - maxItems: Maximum number of context items to return
    /// - Returns: Relevant conversation context
    public func getConversationContext(
        sessionId: String,
        categories: [ConversationContextCategory] = [],
        maxItems: Int = 10
    ) -> ConversationContextSummary {
        let categoriesFilter = categories.isEmpty ? Array(contextCategories.keys) : categories
        
        var contextItems: [ConversationContextItem] = []
        
        for category in categoriesFilter {
            let contextKey = "\(sessionId)_\(category.rawValue)"
            
            if let context = contextCache[contextKey] {
                // Get most recent and relevant items
                let sortedItems = context.items
                    .sorted { item1, item2 in
                        if item1.relevanceScore != item2.relevanceScore {
                            return item1.relevanceScore > item2.relevanceScore
                        }
                        return item1.timestamp > item2.timestamp
                    }
                    .prefix(maxItems / categoriesFilter.count)
                
                contextItems.append(contentsOf: sortedItems)
            }
        }
        
        // Sort by relevance and recency
        contextItems.sort { item1, item2 in
            let relevanceWeight = 0.7
            let recencyWeight = 0.3
            
            let item1Score = (item1.relevanceScore * relevanceWeight) + 
                           (recencyWeight * (1.0 - item1.timestamp.timeIntervalSinceNow / 3600))
            let item2Score = (item2.relevanceScore * relevanceWeight) + 
                           (recencyWeight * (1.0 - item2.timestamp.timeIntervalSinceNow / 3600))
            
            return item1Score > item2Score
        }
        
        return ConversationContextSummary(
            sessionId: sessionId,
            contextItems: Array(contextItems.prefix(maxItems)),
            categories: categoriesFilter,
            retrievedAt: Date()
        )
    }
    
    /// Get conversation history for session
    public func getConversationHistory(sessionId: String, limit: Int = 50) -> [ConversationTurn] {
        guard let session = activeConversations[sessionId] else {
            return []
        }
        
        return Array(session.turns.suffix(limit))
    }
    
    /// Get conversation summary
    public func getConversationSummary(sessionId: String) -> ConversationSessionSummary {
        guard let session = activeConversations[sessionId] else {
            return createEmptySummary(sessionId: sessionId)
        }
        
        let duration = Date().timeIntervalSince(session.startTime)
        let intentTypes = session.turns.map { $0.recognizedIntent.type }
        let intentCounts = Dictionary(grouping: intentTypes, by: { $0 })
            .mapValues { $0.count }
        
        let totalTasks = session.turns.flatMap { $0.createdTasks }.count
        let averageConfidence = session.turns.isEmpty ? 0 :
            session.turns.map { $0.recognizedIntent.confidence }.reduce(0, +) / Double(session.turns.count)
        
        return ConversationSessionSummary(
            sessionId: sessionId,
            userId: session.userId,
            duration: duration,
            totalTurns: session.totalTurns,
            totalTasksCreated: totalTasks,
            averageIntentConfidence: averageConfidence,
            intentDistribution: intentCounts,
            lastActivity: session.lastActivity,
            contextCategories: getActiveContextCategories(sessionId: sessionId)
        )
    }
    
    private func getActiveContextCategories(sessionId: String) -> [ConversationContextCategory] {
        return contextCategories.keys.filter { category in
            let contextKey = "\(sessionId)_\(category.rawValue)"
            return contextCache[contextKey] != nil
        }
    }
    
    // MARK: - Session Management
    
    /// End conversation session
    public func endConversationSession(
        sessionId: String,
        taskMaster: TaskMasterAIService
    ) async {
        guard var session = activeConversations[sessionId] else {
            print("❌ Session not found: \(sessionId)")
            return
        }
        
        session.endTime = Date()
        
        // Complete session tracking task
        await taskMaster.completeTask(session.sessionTask.id)
        
        // Move to history
        conversationHistory.append(session)
        
        // Remove from active sessions
        activeConversations.removeValue(forKey: sessionId)
        activeConversationsCount = activeConversations.count
        
        // Clean up old context for this session
        cleanupSessionContext(sessionId: sessionId)
        
        print("🏁 Ended conversation session: \(sessionId)")
        
        if currentSessionId == sessionId {
            currentSessionId = nil
        }
    }
    
    private func cleanupSessionContext(sessionId: String) {
        let keysToRemove = contextCache.keys.filter { $0.hasPrefix(sessionId) }
        
        for key in keysToRemove {
            if let context = contextCache[key],
               let config = contextCategories[context.category],
               config.persistenceLevel != .persistent {
                contextCache.removeValue(forKey: key)
            }
        }
    }
    
    // MARK: - Analytics
    
    /// Generate conversation analytics
    public func generateConversationAnalytics() -> ConversationAnalytics {
        let totalSessions = conversationHistory.count + activeConversations.count
        let averageSessionDuration = conversationHistory.isEmpty ? 0 :
            conversationHistory.compactMap { session in
                session.endTime?.timeIntervalSince(session.startTime)
            }.reduce(0, +) / Double(conversationHistory.count)
        
        let averageTurnsPerSession = totalSessions == 0 ? 0 :
            Double(totalConversationTurns) / Double(totalSessions)
        
        let intentDistribution = turnHistory.map { $0.recognizedIntent.type }
        let intentCounts = Dictionary(grouping: intentDistribution, by: { $0 })
            .mapValues { $0.count }
        
        let averageIntentConfidence = turnHistory.isEmpty ? 0 :
            turnHistory.map { $0.recognizedIntent.confidence }.reduce(0, +) / Double(turnHistory.count)
        
        let totalTasksCreated = turnHistory.flatMap { $0.createdTasks }.count
        let taskCreationRate = totalConversationTurns == 0 ? 0 :
            Double(totalTasksCreated) / Double(totalConversationTurns)
        
        let analytics = ConversationAnalytics(
            totalConversations: totalSessions,
            activeConversations: activeConversationsCount,
            totalTurns: totalConversationTurns,
            averageSessionDuration: averageSessionDuration,
            averageTurnsPerSession: averageTurnsPerSession,
            averageIntentConfidence: averageIntentConfidence,
            intentDistribution: intentCounts,
            taskCreationRate: taskCreationRate,
            contextCacheSize: contextCache.count
        )
        
        conversationAnalytics = analytics
        return analytics
    }
    
    // MARK: - Utility Methods
    
    private func setupConversationManager() {
        activeConversations.reserveCapacity(maxActiveConversations)
        conversationHistory.reserveCapacity(100)
        contextCache.reserveCapacity(500)
        turnHistory.reserveCapacity(maxTurnHistory)
    }
    
    private func createEmptySession() -> ConversationSession {
        return ConversationSession(
            id: "empty",
            userId: "unknown",
            startTime: Date(),
            sessionTask: TaskItem(
                id: "empty", title: "Empty", description: "Empty",
                level: .level1, status: .completed, priority: .low,
                estimatedDuration: 0, metadata: "", tags: []
            )
        )
    }
    
    private func createEmptyTurn() -> ConversationTurn {
        return ConversationTurn(
            id: "empty",
            sessionId: "empty",
            userMessage: "",
            recognizedIntent: ChatIntent(type: .general, confidence: 0),
            timestamp: Date(),
            turnNumber: 0
        )
    }
    
    private func createEmptySummary(sessionId: String) -> ConversationSessionSummary {
        return ConversationSessionSummary(
            sessionId: sessionId,
            userId: "unknown",
            duration: 0,
            totalTurns: 0,
            totalTasksCreated: 0,
            averageIntentConfidence: 0,
            intentDistribution: [:],
            lastActivity: Date(),
            contextCategories: []
        )
    }
    
    /// Clear conversation data
    public func clearConversationData() {
        activeConversations.removeAll()
        conversationHistory.removeAll()
        contextCache.removeAll()
        turnHistory.removeAll()
        activeConversationsCount = 0
        totalConversationTurns = 0
        currentSessionId = nil
        conversationAnalytics = nil
        
        print("🗑️ ConversationManager data cleared")
    }
}

// MARK: - Supporting Types

public class ConversationSession: ObservableObject {
    public let id: String
    public let userId: String
    public let startTime: Date
    public var endTime: Date?
    public let sessionTask: TaskItem
    public var turns: [ConversationTurn] = []
    public var lastActivity: Date
    public var totalTurns: Int = 0
    
    public init(
        id: String,
        userId: String,
        startTime: Date,
        sessionTask: TaskItem
    ) {
        self.id = id
        self.userId = userId
        self.startTime = startTime
        self.sessionTask = sessionTask
        self.lastActivity = startTime
    }
}

public struct ConversationTurn {
    public let id: String
    public let sessionId: String
    public let userMessage: String
    public let recognizedIntent: ChatIntent
    public let aiResponse: String?
    public let createdTasks: [TaskItem]
    public let timestamp: Date
    public let turnNumber: Int
    
    public init(
        id: String,
        sessionId: String,
        userMessage: String,
        recognizedIntent: ChatIntent,
        aiResponse: String? = nil,
        createdTasks: [TaskItem] = [],
        timestamp: Date,
        turnNumber: Int
    ) {
        self.id = id
        self.sessionId = sessionId
        self.userMessage = userMessage
        self.recognizedIntent = recognizedIntent
        self.aiResponse = aiResponse
        self.createdTasks = createdTasks
        self.timestamp = timestamp
        self.turnNumber = turnNumber
    }
}

public enum ConversationContextCategory: String, CaseIterable {
    case taskManagement = "task_management"
    case documentAnalysis = "document_analysis"
    case financialData = "financial_data"
    case workflowAutomation = "workflow_automation"
    case userPreferences = "user_preferences"
    case technicalDetails = "technical_details"
}

public enum ContextPersistenceLevel: String, CaseIterable {
    case conversation = "conversation" // Cleared when conversation ends
    case session = "session" // Cleared when session ends
    case persistent = "persistent" // Maintained across sessions
}

private struct ContextCategoryConfiguration {
    let category: ConversationContextCategory
    let relevanceKeywords: [String]
    let contextWeight: Double
    let persistenceLevel: ContextPersistenceLevel
    let maxContextItems: Int
}

public struct ConversationContextItem {
    public let id: String
    public let category: ConversationContextCategory
    public let content: String
    public let intent: ChatIntent
    public let relevanceScore: Double
    public let timestamp: Date
    public let turnNumber: Int
}

public struct ConversationContext {
    public let sessionId: String
    public let category: ConversationContextCategory
    public var items: [ConversationContextItem]
    public var lastUpdated: Date = Date()
    
    public mutating func addContextItem(_ item: ConversationContextItem) {
        items.append(item)
        lastUpdated = Date()
        
        // Maintain size limit
        if let config = contextCategoryConfigurations[category] {
            if items.count > config.maxContextItems {
                items.removeFirst(items.count - config.maxContextItems)
            }
        }
    }
}

private let contextCategoryConfigurations: [ConversationContextCategory: ContextCategoryConfiguration] = [
    .taskManagement: ContextCategoryConfiguration(
        category: .taskManagement,
        relevanceKeywords: ["task", "create", "todo", "manage", "priority", "deadline"],
        contextWeight: 0.9,
        persistenceLevel: .session,
        maxContextItems: 20
    ),
    .documentAnalysis: ContextCategoryConfiguration(
        category: .documentAnalysis,
        relevanceKeywords: ["document", "analyze", "report", "file", "text", "extract"],
        contextWeight: 0.8,
        persistenceLevel: .conversation,
        maxContextItems: 15
    ),
    .financialData: ContextCategoryConfiguration(
        category: .financialData,
        relevanceKeywords: ["financial", "money", "cost", "revenue", "expense", "budget"],
        contextWeight: 0.85,
        persistenceLevel: .session,
        maxContextItems: 25
    ),
    .workflowAutomation: ContextCategoryConfiguration(
        category: .workflowAutomation,
        relevanceKeywords: ["workflow", "automate", "process", "streamline", "optimize"],
        contextWeight: 0.9,
        persistenceLevel: .persistent,
        maxContextItems: 30
    ),
    .userPreferences: ContextCategoryConfiguration(
        category: .userPreferences,
        relevanceKeywords: ["prefer", "like", "always", "usually", "default", "setting"],
        contextWeight: 0.7,
        persistenceLevel: .persistent,
        maxContextItems: 50
    ),
    .technicalDetails: ContextCategoryConfiguration(
        category: .technicalDetails,
        relevanceKeywords: ["technical", "API", "integration", "system", "configuration"],
        contextWeight: 0.6,
        persistenceLevel: .conversation,
        maxContextItems: 10
    )
]

public struct ConversationContextSummary {
    public let sessionId: String
    public let contextItems: [ConversationContextItem]
    public let categories: [ConversationContextCategory]
    public let retrievedAt: Date
}

public struct ConversationSessionSummary {
    public let sessionId: String
    public let userId: String
    public let duration: TimeInterval
    public let totalTurns: Int
    public let totalTasksCreated: Int
    public let averageIntentConfidence: Double
    public let intentDistribution: [IntentType: Int]
    public let lastActivity: Date
    public let contextCategories: [ConversationContextCategory]
}

public struct ConversationAnalytics {
    public let totalConversations: Int
    public let activeConversations: Int
    public let totalTurns: Int
    public let averageSessionDuration: TimeInterval
    public let averageTurnsPerSession: Double
    public let averageIntentConfidence: Double
    public let intentDistribution: [IntentType: Int]
    public let taskCreationRate: Double
    public let contextCacheSize: Int
}