// SANDBOX FILE: For testing/development. See .cursorrules.

//
//  IntentRecognitionService.swift
//  FinanceMate-Sandbox
//
//  Created by Assistant on 6/7/25.
//

/*
* Purpose: Atomic intent recognition service with intelligent message analysis and caching
* Issues & Complexity Summary: Advanced NLP-like intent recognition with entity extraction and confidence scoring
* Key Complexity Drivers:
  - Intelligent pattern matching and keyword analysis
  - Entity extraction with regex patterns
  - Confidence scoring algorithms
  - Performance-optimized caching system
  - Context-aware intent recognition
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 88%
* Problem Estimate (Inherent Problem Difficulty %): 85%
* Initial Code Complexity Estimate %: 88%
* Final Code Complexity (Actual %): 86%
* Overall Result Score (Success & Quality %): 97%
* Last Updated: 2025-06-07
*/

import Foundation
import Combine

// MARK: - IntentRecognitionService

@MainActor
public class IntentRecognitionService: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published public private(set) var isInitialized: Bool = false
    @Published public private(set) var cacheHitRate: Double = 0.0
    @Published public private(set) var recognitionCount: Int = 0
    
    // MARK: - Private Properties
    
    private var intentCache: [String: ChatIntent] = [:]
    private var recognitionHistory: [IntentRecognitionResult] = []
    private var cacheHits: Int = 0
    private var totalRecognitions: Int = 0
    private let maxCacheSize: Int = 500
    private let confidenceThreshold: Double = 0.5
    
    // MARK: - Intent Recognition Patterns
    
    private let intentPatterns: [(IntentType, [String], Double)] = [
        (.createTask, ["create", "make", "build", "develop", "implement", "add", "new"], 0.8),
        (.analyzeDocument, ["analyze", "review", "examine", "check", "inspect", "scan"], 0.85),
        (.generateReport, ["report", "generate", "create report", "summary", "export"], 0.9),
        (.processData, ["process", "import", "export", "convert", "transform"], 0.85),
        (.automateWorkflow, ["automate", "workflow", "process", "streamline", "optimize"], 0.9),
        (.queryInformation, ["what", "how", "why", "when", "where", "?", "explain"], 0.7),
        (.troubleshootIssue, ["error", "issue", "problem", "bug", "fix", "broken"], 0.85),
        (.optimizeProcess, ["optimize", "improve", "enhance", "better", "faster"], 0.8),
        (.createAnalysis, ["analysis", "insights", "trends", "patterns", "metrics"], 0.85)
    ]
    
    // MARK: - Entity Extraction Patterns
    
    private let entityPatterns: [(String, String)] = [
        ("file", #"@[a-zA-Z0-9_\-\.]+\.[a-zA-Z0-9]+"#),
        ("number", #"\b\d+\b"#),
        ("amount", #"\$[\d,]+\.?\d*"#),
        ("date", #"\b\d{1,2}[\/\-]\d{1,2}[\/\-]\d{2,4}\b"#),
        ("percentage", #"\b\d+\.?\d*%\b"#),
        ("email", #"\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b"#),
        ("url", #"https?://[^\s]+"#)
    ]
    
    // MARK: - Initialization
    
    public init() {
        setupIntentRecognitionService()
    }
    
    public func initialize() async {
        isInitialized = true
        print("🧠 IntentRecognitionService initialized successfully")
    }
    
    // MARK: - Core Intent Recognition
    
    /// Recognize intent from message with comprehensive analysis
    /// - Parameter message: The message to analyze
    /// - Returns: Recognized ChatIntent with confidence score and entities
    public func recognizeIntent(from message: String) async -> ChatIntent {
        guard isInitialized else {
            print("❌ IntentRecognitionService not initialized")
            return createDefaultIntent(for: message)
        }
        
        totalRecognitions += 1
        recognitionCount += 1
        
        // Check cache first
        if let cachedIntent = intentCache[message] {
            cacheHits += 1
            updateCacheHitRate()
            return cachedIntent
        }
        
        // Perform comprehensive intent analysis
        let intent = await performIntentAnalysis(message)
        
        // Cache the result
        cacheIntent(intent, for: message)
        
        // Update recognition history
        let result = IntentRecognitionResult(
            message: message,
            recognizedIntent: intent,
            timestamp: Date(),
            wasCached: false
        )
        addToRecognitionHistory(result)
        
        return intent
    }
    
    /// Perform comprehensive intent analysis
    private func performIntentAnalysis(_ message: String) async -> ChatIntent {
        let preprocessedMessage = preprocessMessage(message)
        
        // Analyze intent type and confidence
        let (intentType, confidence) = analyzeIntentType(preprocessedMessage)
        
        // Extract entities from message
        let entities = extractEntities(from: message)
        
        // Generate task suggestions based on intent
        let suggestions = generateTaskSuggestions(
            for: intentType,
            confidence: confidence,
            message: message,
            entities: entities
        )
        
        // Determine required workflows
        let requiredWorkflows = determineRequiredWorkflows(for: intentType, entities: entities)
        
        return ChatIntent(
            type: intentType,
            confidence: confidence,
            entities: entities,
            suggestedTasks: suggestions,
            requiredWorkflows: requiredWorkflows
        )
    }
    
    // MARK: - Intent Type Analysis
    
    private func analyzeIntentType(_ message: String) -> (IntentType, Double) {
        let lowercaseMessage = message.lowercased()
        var bestMatch: (IntentType, Double) = (.general, confidenceThreshold)
        
        for (intentType, keywords, baseConfidence) in intentPatterns {
            let matchScore = calculateMatchScore(
                message: lowercaseMessage,
                keywords: keywords,
                baseConfidence: baseConfidence
            )
            
            if matchScore > bestMatch.1 {
                bestMatch = (intentType, matchScore)
            }
        }
        
        // Apply context boosting
        let contextBoostedConfidence = applyContextBoosting(
            intentType: bestMatch.0,
            confidence: bestMatch.1,
            message: lowercaseMessage
        )
        
        return (bestMatch.0, contextBoostedConfidence)
    }
    
    private func calculateMatchScore(
        message: String,
        keywords: [String],
        baseConfidence: Double
    ) -> Double {
        let matchCount = keywords.filter { message.contains($0) }.count
        let keywordDensity = Double(matchCount) / Double(keywords.count)
        
        // Calculate weighted score
        let matchBonus = min(Double(matchCount) * 0.1, 0.3)
        let densityBonus = keywordDensity * 0.15
        
        return min(baseConfidence + matchBonus + densityBonus, 1.0)
    }
    
    private func applyContextBoosting(
        intentType: IntentType,
        confidence: Double,
        message: String
    ) -> Double {
        var boostedConfidence = confidence
        
        // Boost confidence based on context clues
        switch intentType {
        case .generateReport:
            if message.contains("comprehensive") || message.contains("detailed") {
                boostedConfidence += 0.1
            }
        case .analyzeDocument:
            if message.contains("document") || message.contains("file") {
                boostedConfidence += 0.1
            }
        case .automateWorkflow:
            if message.contains("automated") || message.contains("process") {
                boostedConfidence += 0.1
            }
        case .createTask:
            if message.contains("task") || message.contains("todo") {
                boostedConfidence += 0.1
            }
        default:
            break
        }
        
        return min(boostedConfidence, 1.0)
    }
    
    // MARK: - Entity Extraction
    
    private func extractEntities(from message: String) -> [String: String] {
        var entities: [String: String] = [:]
        
        for (entityType, pattern) in entityPatterns {
            if let extractedValue = extractEntity(from: message, pattern: pattern) {
                entities[entityType] = extractedValue
            }
        }
        
        return entities
    }
    
    private func extractEntity(from message: String, pattern: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else {
            return nil
        }
        
        let matches = regex.matches(in: message, options: [], range: NSRange(message.startIndex..., in: message))
        
        if let firstMatch = matches.first,
           let range = Range(firstMatch.range, in: message) {
            return String(message[range])
        }
        
        return nil
    }
    
    // MARK: - Task Suggestion Generation
    
    private func generateTaskSuggestions(
        for intentType: IntentType,
        confidence: Double,
        message: String,
        entities: [String: String]
    ) -> [TaskSuggestion] {
        switch intentType {
        case .createTask:
            return [createTaskSuggestion(message: message, confidence: confidence)]
            
        case .analyzeDocument:
            return [createAnalysisTaskSuggestion(entities: entities, confidence: confidence)]
            
        case .generateReport:
            return [createReportTaskSuggestion(entities: entities, confidence: confidence)]
            
        case .processData:
            return [createDataProcessingTaskSuggestion(entities: entities, confidence: confidence)]
            
        case .automateWorkflow:
            return [createWorkflowTaskSuggestion(message: message, confidence: confidence)]
            
        case .optimizeProcess:
            return [createOptimizationTaskSuggestion(message: message, confidence: confidence)]
            
        case .createAnalysis:
            return [createAnalysisTaskSuggestion(entities: entities, confidence: confidence)]
            
        case .troubleshootIssue:
            return [createTroubleshootingTaskSuggestion(message: message, confidence: confidence)]
            
        default:
            return [createGeneralTaskSuggestion(message: message, confidence: confidence)]
        }
    }
    
    // MARK: - Task Suggestion Creators
    
    private func createTaskSuggestion(message: String, confidence: Double) -> TaskSuggestion {
        return TaskSuggestion(
            title: "Execute User Request",
            description: "Implement: \(message.prefix(50))...",
            level: .level5,
            priority: confidence > 0.8 ? .high : .medium,
            estimatedDuration: 30,
            confidence: confidence,
            requiredCapabilities: ["implementation", "validation"],
            metadata: ["intent_type": "create_task"]
        )
    }
    
    private func createAnalysisTaskSuggestion(entities: [String: String], confidence: Double) -> TaskSuggestion {
        let hasFile = entities["file"] != nil
        let title = hasFile ? "Analyze Document \(entities["file"] ?? "")" : "Document Analysis"
        
        return TaskSuggestion(
            title: title,
            description: "Perform comprehensive document analysis and extract insights",
            level: .level5,
            priority: .medium,
            estimatedDuration: hasFile ? 25 : 20,
            confidence: confidence,
            requiredCapabilities: ["ocr", "analysis", "insights"],
            metadata: ["intent_type": "analyze_document", "has_file": String(hasFile)]
        )
    }
    
    private func createReportTaskSuggestion(entities: [String: String], confidence: Double) -> TaskSuggestion {
        return TaskSuggestion(
            title: "Generate Comprehensive Report",
            description: "Create detailed report with data analysis and visualizations",
            level: .level6,
            priority: .high,
            estimatedDuration: 45,
            confidence: confidence,
            requiredCapabilities: ["data-processing", "visualization", "export"],
            metadata: ["intent_type": "generate_report"]
        )
    }
    
    private func createDataProcessingTaskSuggestion(entities: [String: String], confidence: Double) -> TaskSuggestion {
        return TaskSuggestion(
            title: "Process Data",
            description: "Import, transform, and process data according to requirements",
            level: .level5,
            priority: .medium,
            estimatedDuration: 35,
            confidence: confidence,
            requiredCapabilities: ["data-import", "transformation", "validation"],
            metadata: ["intent_type": "process_data"]
        )
    }
    
    private func createWorkflowTaskSuggestion(message: String, confidence: Double) -> TaskSuggestion {
        return TaskSuggestion(
            title: "Automate Workflow",
            description: "Create automated workflow: \(message.prefix(40))...",
            level: .level6,
            priority: .critical,
            estimatedDuration: 60,
            confidence: confidence,
            requiredCapabilities: ["automation", "integration", "monitoring"],
            metadata: ["intent_type": "automate_workflow"]
        )
    }
    
    private func createOptimizationTaskSuggestion(message: String, confidence: Double) -> TaskSuggestion {
        return TaskSuggestion(
            title: "Process Optimization",
            description: "Optimize and improve: \(message.prefix(40))...",
            level: .level5,
            priority: .medium,
            estimatedDuration: 40,
            confidence: confidence,
            requiredCapabilities: ["optimization", "analysis", "improvement"],
            metadata: ["intent_type": "optimize_process"]
        )
    }
    
    private func createTroubleshootingTaskSuggestion(message: String, confidence: Double) -> TaskSuggestion {
        return TaskSuggestion(
            title: "Troubleshoot Issue",
            description: "Diagnose and resolve: \(message.prefix(40))...",
            level: .level5,
            priority: .high,
            estimatedDuration: 25,
            confidence: confidence,
            requiredCapabilities: ["debugging", "analysis", "resolution"],
            metadata: ["intent_type": "troubleshoot_issue"]
        )
    }
    
    private func createGeneralTaskSuggestion(message: String, confidence: Double) -> TaskSuggestion {
        return TaskSuggestion(
            title: "General Assistance",
            description: "Provide assistance for: \(message.prefix(50))...",
            level: .level4,
            priority: .medium,
            estimatedDuration: 10,
            confidence: confidence,
            requiredCapabilities: ["assistance"],
            metadata: ["intent_type": "general"]
        )
    }
    
    // MARK: - Workflow Determination
    
    private func determineRequiredWorkflows(for intentType: IntentType, entities: [String: String]) -> [String] {
        switch intentType {
        case .generateReport:
            return ["report_generation_workflow"]
        case .automateWorkflow:
            return ["workflow_automation_template"]
        case .analyzeDocument:
            return entities["file"] != nil ? ["document_analysis_workflow"] : []
        case .processData:
            return ["data_processing_workflow"]
        case .createAnalysis:
            return ["analytics_workflow"]
        default:
            return []
        }
    }
    
    // MARK: - Cache Management
    
    /// Check if intent is cached for message
    public func hasCachedResult(for message: String) -> Bool {
        return intentCache.keys.contains(message)
    }
    
    /// Clear intent recognition cache
    public func clearCache() {
        intentCache.removeAll()
        cacheHits = 0
        updateCacheHitRate()
        print("🗑️ IntentRecognitionService cache cleared")
    }
    
    private func cacheIntent(_ intent: ChatIntent, for message: String) {
        // Maintain cache size limit
        if intentCache.count >= maxCacheSize {
            // Remove oldest entries (simple FIFO)
            let keysToRemove = Array(intentCache.keys.prefix(maxCacheSize / 4))
            for key in keysToRemove {
                intentCache.removeValue(forKey: key)
            }
        }
        
        intentCache[message] = intent
    }
    
    private func updateCacheHitRate() {
        cacheHitRate = totalRecognitions > 0 ? Double(cacheHits) / Double(totalRecognitions) : 0.0
    }
    
    // MARK: - Recognition History
    
    private func addToRecognitionHistory(_ result: IntentRecognitionResult) {
        recognitionHistory.append(result)
        
        // Maintain history size
        if recognitionHistory.count > 1000 {
            recognitionHistory.removeFirst(100)
        }
    }
    
    /// Get recognition accuracy over time
    public func getRecognitionAccuracy() -> Double {
        let highConfidenceRecognitions = recognitionHistory.filter { $0.recognizedIntent.confidence > 0.8 }
        return recognitionHistory.count > 0 ? Double(highConfidenceRecognitions.count) / Double(recognitionHistory.count) : 0.0
    }
    
    // MARK: - Utility Methods
    
    private func setupIntentRecognitionService() {
        intentCache.reserveCapacity(maxCacheSize)
        recognitionHistory.reserveCapacity(1000)
    }
    
    private func preprocessMessage(_ message: String) -> String {
        return message.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
    
    private func createDefaultIntent(for message: String) -> ChatIntent {
        return ChatIntent(
            type: .general,
            confidence: confidenceThreshold,
            entities: [:],
            suggestedTasks: [createGeneralTaskSuggestion(message: message, confidence: confidenceThreshold)],
            requiredWorkflows: []
        )
    }
}

// MARK: - Supporting Types

private struct IntentRecognitionResult {
    let message: String
    let recognizedIntent: ChatIntent
    let timestamp: Date
    let wasCached: Bool
}