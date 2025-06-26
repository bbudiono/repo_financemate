//
//  FinancialInsightsModels.swift
//  FinanceMate
//
//  Created by Assistant on 6/7/25.
//

/*
* Purpose: Core financial insights data models and types
* Contains: FinancialInsightType, EnhancedFinancialInsight, InsightProcessingMethod, and supporting types
* Used by: RealTimeFinancialInsightsView, IntegratedFinancialDocumentInsightsService
*/

import Foundation
import SwiftUI

// MARK: - Core Financial Insight Types

public enum FinancialInsightType: String, CaseIterable {
    case spendingPattern = "spending_pattern"
    case incomeAnalysis = "income_analysis"
    case budgetRecommendation = "budget_recommendation"
    case anomalyDetection = "anomaly_detection"
    case goalProgress = "goal_progress"
    case categoryAnalysis = "category_analysis"
}

public enum InsightPriority: String, CaseIterable {
    case critical = "critical"
    case high = "high"
    case medium = "medium"
    case low = "low"
}

public enum InsightProcessingMethod {
    case traditional
    case aiEnhanced
    case fullyAI
    case hybrid
}

// MARK: - Core Financial Insight

public struct FinancialInsight {
    public let id: UUID
    public let type: FinancialInsightType
    public let title: String
    public let description: String
    public let confidence: Double
    public let actionable: Bool
    public let priority: InsightPriority
    public let metadata: [String: Any]
    public let generatedAt: Date

    public init(id: UUID = UUID(), type: FinancialInsightType, title: String, description: String,
                confidence: Double, actionable: Bool = true, priority: InsightPriority = .medium,
                metadata: [String: Any] = [:], generatedAt: Date = Date()) {
        self.id = id
        self.type = type
        self.title = title
        self.description = description
        self.confidence = confidence
        self.actionable = actionable
        self.priority = priority
        self.metadata = metadata
        self.generatedAt = generatedAt
    }
}

// MARK: - AI Enhancement Models

public struct AIInsightEnhancements {
    public let contextualInformation: String
    public let predictionComponents: [String]
    public let recommendationStrength: Double
    public let riskFactors: [String]
    public let alternativeScenarios: [String]

    public init(contextualInformation: String = "",
                predictionComponents: [String] = [],
                recommendationStrength: Double = 0.0,
                riskFactors: [String] = [],
                alternativeScenarios: [String] = []) {
        self.contextualInformation = contextualInformation
        self.predictionComponents = predictionComponents
        self.recommendationStrength = recommendationStrength
        self.riskFactors = riskFactors
        self.alternativeScenarios = alternativeScenarios
    }
}

// MARK: - Enhanced Financial Insight

public struct EnhancedFinancialInsight {
    public let baseInsight: FinancialInsight
    public let aiEnhancements: AIInsightEnhancements
    public let aiConfidence: Double
    public let processingMethod: InsightProcessingMethod
    public let agentTaskId: String?
    public let generatedAt: Date

    public init(from insight: FinancialInsight,
                aiEnhancements: AIInsightEnhancements = AIInsightEnhancements(),
                aiConfidence: Double = 0.0,
                processingMethod: InsightProcessingMethod = .traditional,
                agentTaskId: String? = nil) {
        self.baseInsight = insight
        self.aiEnhancements = aiEnhancements
        self.aiConfidence = aiConfidence
        self.processingMethod = processingMethod
        self.agentTaskId = agentTaskId
        self.generatedAt = Date()
    }

    public var id: UUID { baseInsight.id }
    public var type: FinancialInsightType { baseInsight.type }
    public var title: String { baseInsight.title }
    public var description: String { baseInsight.description }
    public var confidence: Double { baseInsight.confidence }
    public var priority: InsightPriority { baseInsight.priority }

    public func toFinancialInsight() -> FinancialInsight {
        baseInsight
    }
}

// MARK: - System Status Models

public struct IntegratedSystemStatus {
    public let isHealthy: Bool
    public let documentsInQueue: Int
    public let activeInsights: Int
    public let systemLoad: Double
    public let aiModelsActive: Bool
    public let mlacsConnected: Bool

    public init(isHealthy: Bool = true,
                documentsInQueue: Int = 0,
                activeInsights: Int = 0,
                systemLoad: Double = 0.0,
                aiModelsActive: Bool = false,
                mlacsConnected: Bool = false) {
        self.isHealthy = isHealthy
        self.documentsInQueue = documentsInQueue
        self.activeInsights = activeInsights
        self.systemLoad = systemLoad
        self.aiModelsActive = aiModelsActive
        self.mlacsConnected = mlacsConnected
    }
}

// MARK: - Document Processing Models

public struct DocumentProcessingJob {
    public let id: UUID
    public let documentName: String
    public let status: ProcessingStatus
    public let progress: Double
    public let estimatedCompletion: Date?

    public enum ProcessingStatus {
        case queued
        case processing
        case completed
        case failed
    }

    public init(id: UUID = UUID(), documentName: String, status: ProcessingStatus = .queued,
                progress: Double = 0.0, estimatedCompletion: Date? = nil) {
        self.id = id
        self.documentName = documentName
        self.status = status
        self.progress = progress
        self.estimatedCompletion = estimatedCompletion
    }
}

// MARK: - AI Analytics Models

public struct AIAnalysisResult {
    public let resultId: UUID
    public let analysisType: String
    public let confidence: Double
    public let insights: [FinancialInsight]
    public let processingTime: TimeInterval
    public let generatedAt: Date

    public init(resultId: UUID = UUID(), analysisType: String, confidence: Double,
                insights: [FinancialInsight], processingTime: TimeInterval,
                generatedAt: Date = Date()) {
        self.resultId = resultId
        self.analysisType = analysisType
        self.confidence = confidence
        self.insights = insights
        self.processingTime = processingTime
        self.generatedAt = generatedAt
    }
}

// MARK: - Document Pipeline Models

public struct PipelineProcessedDocument {
    public let documentId: UUID
    public let originalName: String
    public let processedContent: String
    public let extractedData: [String: Any]
    public let confidence: Double
    public let processingMethod: String
    public let generatedAt: Date

    public init(documentId: UUID = UUID(), originalName: String, processedContent: String,
                extractedData: [String: Any] = [:], confidence: Double = 0.0,
                processingMethod: String = "default", generatedAt: Date = Date()) {
        self.documentId = documentId
        self.originalName = originalName
        self.processedContent = processedContent
        self.extractedData = extractedData
        self.confidence = confidence
        self.processingMethod = processingMethod
        self.generatedAt = generatedAt
    }
}
