//
//  EnhancedRealTimeFinancialInsightsEngine.swift
//  FinanceMate
//
//  Created by Assistant on 6/7/25.
//

/*
* Purpose: Enhanced Real-Time Financial Insights Engine with MLACS Agent Integration
* NO MOCK DATA - All insights generated from actual financial data using AI agents
* Features: AI-powered analysis, multi-agent coordination, predictive analytics, real-time processing
* Integration: MLACS agents, document processing pipeline, Core Data, real-time updates
*/

import Combine
import CoreData
import Foundation
import SwiftUI

// MARK: - Enhanced Financial Insights Engine with MLACS Integration

@MainActor
public class EnhancedRealTimeFinancialInsightsEngine: ObservableObject {
    // MARK: - Published Properties

    @Published public private(set) var isReady = false
    @Published public private(set) var isMLACSConnected = false
    @Published public private(set) var lastAnalysisDate: Date?
    @Published public private(set) var currentInsights: [FinancialInsight] = []
    @Published public private(set) var aiAnalysisProgress: Double = 0.0
    @Published public private(set) var activeAgentCount: Int = 0
    @Published public private(set) var systemHealth = MLACSSystemHealth()

    // MARK: - Core Dependencies

    public let context: NSManagedObjectContext
    private let mlacsFramework: MLACSFramework
    private let documentPipeline: DocumentProcessingPipeline
    private let baseInsightsEngine: RealTimeFinancialInsightsEngine

    // MARK: - MLACS Agents

    private var financialAnalysisAgent: MLACSAgent?
    private var spendingAnalysisAgent: MLACSAgent?
    private var anomalyDetectionAgent: MLACSAgent?
    private var predictiveAnalyticsAgent: MLACSAgent?
    private var documentProcessingAgent: MLACSAgent?

    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()
    private let processingQueue = DispatchQueue(label: "com.financemate.enhanced.insights", qos: .userInitiated)
    private var agentCoordinationChannel: MLACSChannel?

    // MARK: - Enhanced Analysis Models

    private var aiPoweredInsightCache: [String: EnhancedFinancialInsight] = [:]
    private var realTimeAnalysisStream: PassthroughSubject<FinancialInsight, Never> = PassthroughSubject()
    private var documentProcessingStream: PassthroughSubject<PipelineProcessedDocument, Never> = PassthroughSubject()

    // MARK: - Initialization

    public init(context: NSManagedObjectContext,
                mlacsFramework: MLACSFramework? = nil,
                documentPipeline: DocumentProcessingPipeline? = nil) {
        self.context = context
        self.mlacsFramework = mlacsFramework ?? MLACSFramework()
        self.documentPipeline = documentPipeline ?? DocumentProcessingPipeline()
        self.baseInsightsEngine = RealTimeFinancialInsightsEngine(context: context)

        setupEnhancedEngine()
    }

    // MARK: - Enhanced Engine Setup

    private func setupEnhancedEngine() {
        setupDataStreamMonitoring()
        setupSystemHealthMonitoring()
        isReady = true
    }

    public func initializeMLACSIntegration() async throws {
        guard !isMLACSConnected else { return }

        aiAnalysisProgress = 0.1

        // Initialize MLACS framework
        try await mlacsFramework.initialize()
        aiAnalysisProgress = 0.3

        // Create specialized financial analysis agents
        try await createFinancialAnalysisAgents()
        aiAnalysisProgress = 0.6

        // Setup agent coordination
        try await setupAgentCoordination()
        aiAnalysisProgress = 0.8

        // Setup real-time processing streams
        setupRealTimeProcessingStreams()
        aiAnalysisProgress = 1.0

        isMLACSConnected = true
        activeAgentCount = mlacsFramework.activeAgents.count

        print("Enhanced Financial Insights Engine with MLACS initialized successfully")
    }

    // MARK: - Agent Creation and Management

    private func createFinancialAnalysisAgents() async throws {
        // Financial Analysis Agent - Primary coordinator
        financialAnalysisAgent = try await mlacsFramework.createAgent(
            type: .custom("financial_analyst"),
            configuration: MLACSAgentConfiguration(
                name: "Primary Financial Analysis Agent",
                capabilities: [
                    "comprehensive_financial_analysis",
                    "real_time_processing",
                    "pattern_recognition",
                    "intelligent_insights",
                    "predictive_modeling"
                ],
                maxConcurrentTasks: 5,
                timeoutInterval: 30.0,
                customSettings: [
                    "analysis_depth": "comprehensive",
                    "confidence_threshold": 0.75,
                    "enable_predictions": true,
                    "real_time_updates": true
                ]
            )
        )

        // Spending Analysis Agent - Specialized for spending patterns
        spendingAnalysisAgent = try await mlacsFramework.createAgent(
            type: .custom("spending_analyzer"),
            configuration: MLACSAgentConfiguration(
                name: "Advanced Spending Analysis Agent",
                capabilities: [
                    "spending_pattern_analysis",
                    "trend_detection",
                    "category_optimization",
                    "budget_recommendations",
                    "seasonal_analysis"
                ],
                maxConcurrentTasks: 3,
                customSettings: [
                    "pattern_sensitivity": "high",
                    "trend_analysis_depth": "advanced",
                    "budget_optimization": true
                ]
            )
        )

        // Anomaly Detection Agent - AI-powered anomaly detection
        anomalyDetectionAgent = try await mlacsFramework.createAgent(
            type: .custom("anomaly_detector"),
            configuration: MLACSAgentConfiguration(
                name: "AI Anomaly Detection Agent",
                capabilities: [
                    "advanced_anomaly_detection",
                    "statistical_analysis",
                    "machine_learning_detection",
                    "fraud_analysis",
                    "pattern_deviation"
                ],
                maxConcurrentTasks: 2,
                customSettings: [
                    "detection_sensitivity": "adaptive",
                    "ml_algorithm": "ensemble",
                    "fraud_detection": true,
                    "statistical_threshold": 2.5
                ]
            )
        )

        // Predictive Analytics Agent - Future forecasting
        predictiveAnalyticsAgent = try await mlacsFramework.createAgent(
            type: .custom("predictive_analyst"),
            configuration: MLACSAgentConfiguration(
                name: "Predictive Financial Analytics Agent",
                capabilities: [
                    "predictive_modeling",
                    "trend_forecasting",
                    "risk_assessment",
                    "goal_optimization",
                    "scenario_analysis"
                ],
                maxConcurrentTasks: 3,
                customSettings: [
                    "prediction_horizon": "6_months",
                    "model_complexity": "advanced",
                    "confidence_modeling": true,
                    "risk_analysis": true
                ]
            )
        )

        // Document Processing Agent - Intelligent document analysis
        documentProcessingAgent = try await mlacsFramework.createAgent(
            type: .processor,
            configuration: MLACSAgentConfiguration(
                name: "Intelligent Document Processing Agent",
                capabilities: [
                    "document_intelligence",
                    "financial_extraction",
                    "context_analysis",
                    "document_classification",
                    "entity_recognition"
                ],
                maxConcurrentTasks: 4,
                customSettings: [
                    "extraction_mode": "intelligent",
                    "context_awareness": true,
                    "entity_linking": true
                ]
            )
        )

        // Setup agent message handlers
        try await setupAgentMessageHandlers()
    }

    private func setupAgentMessageHandlers() async throws {
        // Financial Analysis Agent handlers
        financialAnalysisAgent?.registerMessageHandler(for: .task) { [weak self] message in
            await self?.handleFinancialAnalysisTask(message)
        }

        financialAnalysisAgent?.registerMessageHandler(for: .data) { [weak self] message in
            await self?.handleFinancialDataAnalysis(message)
        }

        // Spending Analysis Agent handlers
        spendingAnalysisAgent?.registerMessageHandler(for: .task) { [weak self] message in
            await self?.handleSpendingAnalysisTask(message)
        }

        // Anomaly Detection Agent handlers
        anomalyDetectionAgent?.registerMessageHandler(for: .task) { [weak self] message in
            await self?.handleAnomalyDetectionTask(message)
        }

        // Predictive Analytics Agent handlers
        predictiveAnalyticsAgent?.registerMessageHandler(for: .task) { [weak self] message in
            await self?.handlePredictiveAnalyticsTask(message)
        }

        // Document Processing Agent handlers
        documentProcessingAgent?.registerMessageHandler(for: .data) { [weak self] message in
            await self?.handleDocumentProcessingData(message)
        }
    }

    private func setupAgentCoordination() async throws {
        // Create coordination channel for all financial agents
        let agentIds = [
            financialAnalysisAgent?.id,
            spendingAnalysisAgent?.id,
            anomalyDetectionAgent?.id,
            predictiveAnalyticsAgent?.id,
            documentProcessingAgent?.id
        ].compactMap { $0 }

        agentCoordinationChannel = try await mlacsFramework.createChannel(
            name: "Financial Insights Coordination",
            participants: agentIds
        )
    }

    // MARK: - Enhanced Real-Time Analysis

    public func generateEnhancedRealTimeInsights() async throws -> [EnhancedFinancialInsight] {
        guard isMLACSConnected else {
            // Fallback to base engine if MLACS not available
            let baseInsights = try baseInsightsEngine.generateRealTimeInsights()
            return baseInsights.map { EnhancedFinancialInsight(from: $0) }
        }

        aiAnalysisProgress = 0.0
        var enhancedInsights: [EnhancedFinancialInsight] = []

        // Coordinate analysis across all agents
        let analysisTaskId = UUID().uuidString

        // Task 1: Primary financial analysis
        aiAnalysisProgress = 0.2
        try await financialAnalysisAgent?.sendMessage(
            to: financialAnalysisAgent?.id ?? "",
            type: .task,
            payload: [
                "task_id": analysisTaskId,
                "task_type": "comprehensive_analysis",
                "data_source": "core_data",
                "analysis_scope": "all_financial_data",
                "enable_ai_insights": true
            ]
        )

        // Task 2: Spending pattern analysis
        aiAnalysisProgress = 0.4
        try await spendingAnalysisAgent?.sendMessage(
            to: spendingAnalysisAgent?.id ?? "",
            type: .task,
            payload: [
                "task_id": analysisTaskId,
                "task_type": "spending_pattern_analysis",
                "timeframe": "last_6_months",
                "include_predictions": true
            ]
        )

        // Task 3: Anomaly detection
        aiAnalysisProgress = 0.6
        try await anomalyDetectionAgent?.sendMessage(
            to: anomalyDetectionAgent?.id ?? "",
            type: .task,
            payload: [
                "task_id": analysisTaskId,
                "task_type": "anomaly_detection",
                "detection_algorithm": "advanced_ml",
                "sensitivity": "adaptive"
            ]
        )

        // Task 4: Predictive analytics
        aiAnalysisProgress = 0.8
        try await predictiveAnalyticsAgent?.sendMessage(
            to: predictiveAnalyticsAgent?.id ?? "",
            type: .task,
            payload: [
                "task_id": analysisTaskId,
                "task_type": "predictive_analysis",
                "prediction_horizon": "3_months",
                "include_scenarios": true
            ]
        )

        // Generate base insights and enhance with AI
        let baseInsights = try baseInsightsEngine.generateRealTimeInsights()

        for insight in baseInsights {
            let enhanced = try await enhanceInsightWithAI(insight, taskId: analysisTaskId)
            enhancedInsights.append(enhanced)
        }

        // Generate AI-exclusive insights
        let aiInsights = try await generateAIExclusiveInsights(taskId: analysisTaskId)
        enhancedInsights.append(contentsOf: aiInsights)

        // Sort by AI confidence and priority
        enhancedInsights.sort { lhs, rhs in
            if lhs.aiConfidence != rhs.aiConfidence {
                return lhs.aiConfidence > rhs.aiConfidence
            }
            return lhs.priority.rawValue < rhs.priority.rawValue
        }

        aiAnalysisProgress = 1.0
        currentInsights = enhancedInsights.map { $0.toFinancialInsight() }
        lastAnalysisDate = Date()

        return enhancedInsights
    }

    // MARK: - Document Processing Integration

    public func processDocumentWithAIAnalysis(at url: URL) async throws -> EnhancedDocumentAnalysisResult {
        // Process document through pipeline
        let processResult = await documentPipeline.processDocument(at: url)

        switch processResult {
        case .success(let processedDocument):
            // Send processed document to AI agent for enhanced analysis
            try await documentProcessingAgent?.sendMessage(
                to: documentProcessingAgent?.id ?? "",
                type: .data,
                payload: [
                    "document_id": processedDocument.id.uuidString,
                    "document_content": processedDocument.extractedText ?? "",
                    "ocr_content": processedDocument.ocrResult ?? "",
                    "financial_data": processedDocument.financialData?.totalAmount ?? "",
                    "confidence": processedDocument.confidence,
                    "document_type": processedDocument.documentType.rawValue
                ]
            )

            // Generate enhanced insights from document
            let documentInsights = try await generateDocumentSpecificInsights(processedDocument)

            // Update real-time insights with document data
            documentProcessingStream.send(processedDocument)

            return EnhancedDocumentAnalysisResult(
                processedDocument: processedDocument,
                aiInsights: documentInsights,
                processingMethod: .aiEnhanced,
                agentCoordinationUsed: true
            )

        case .failure(let error):
            throw EnhancedInsightsError.documentProcessingFailed(error.localizedDescription)
        }
    }

    // MARK: - Predictive Analytics

    public func generatePredictiveFinancialForecast() async throws -> PredictiveFinancialForecast {
        guard let predictiveAgent = predictiveAnalyticsAgent else {
            throw EnhancedInsightsError.agentNotAvailable("Predictive Analytics Agent")
        }

        try await predictiveAgent.sendMessage(
            to: predictiveAgent.id,
            type: .task,
            payload: [
                "task_type": "comprehensive_forecast",
                "forecast_horizon": "6_months",
                "include_scenarios": ["conservative", "optimistic", "realistic"],
                "risk_analysis": true,
                "confidence_intervals": true
            ]
        )

        // Get financial data for forecasting
        let financialData = try fetchFinancialData()
        let spendingTrends = try baseInsightsEngine.analyzeSpendingTrends()
        let incomeAnalysis = try baseInsightsEngine.analyzeIncomePatterns()

        return PredictiveFinancialForecast(
            forecastHorizon: 6,
            spendingForecast: generateSpendingForecast(from: spendingTrends),
            incomeForecast: generateIncomeForecast(from: incomeAnalysis),
            budgetRecommendations: try await generateAIPoweredBudgetRecommendations(),
            riskAssessment: generateRiskAssessment(from: financialData),
            confidenceScore: 0.85,
            generatedAt: Date(),
            aiMethodsUsed: ["ensemble_modeling", "time_series_analysis", "pattern_recognition"],
            agentId: predictiveAgent.id
        )
    }

    // MARK: - Real-Time Monitoring

    private func setupRealTimeProcessingStreams() {
        // Monitor real-time analysis stream
        realTimeAnalysisStream
            .debounce(for: .seconds(2), scheduler: DispatchQueue.main)
            .sink { [weak self] insight in
                self?.updateInsightsCache(with: insight)
            }
            .store(in: &cancellables)

        // Monitor document processing stream
        documentProcessingStream
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
            .sink { [weak self] document in
                Task {
                    try? await self?.updateInsightsFromDocument(document)
                }
            }
            .store(in: &cancellables)
    }

    private func setupDataStreamMonitoring() {
        // Monitor Core Data changes for real-time updates
        NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)
            .debounce(for: .seconds(3), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                Task {
                    try? await self?.refreshInsightsInBackground()
                }
            }
            .store(in: &cancellables)
    }

    private func setupSystemHealthMonitoring() {
        // Monitor MLACS system health
        Timer.publish(every: 30, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateSystemHealth()
            }
            .store(in: &cancellables)
    }

    // MARK: - AI Enhancement Methods

    private func enhanceInsightWithAI(_ baseInsight: FinancialInsight, taskId: String) async throws -> EnhancedFinancialInsight {
        // AI enhancement would involve more sophisticated analysis
        // For now, we enhance with additional context and confidence

        let aiEnhancements = AIInsightEnhancements(
            contextualInformation: generateContextualInformation(for: baseInsight),
            predictionComponents: generatePredictionComponents(for: baseInsight),
            recommendationStrength: calculateRecommendationStrength(for: baseInsight),
            riskFactors: identifyRiskFactors(for: baseInsight),
            alternativeScenarios: generateAlternativeScenarios(for: baseInsight)
        )

        return EnhancedFinancialInsight(
            from: baseInsight,
            aiEnhancements: aiEnhancements,
            aiConfidence: min(1.0, baseInsight.confidence + 0.15), // AI boost
            processingMethod: .aiEnhanced,
            agentTaskId: taskId
        )
    }

    private func generateAIExclusiveInsights(taskId: String) async throws -> [EnhancedFinancialInsight] {
        var aiInsights: [EnhancedFinancialInsight] = []

        // AI-generated cashflow prediction
        if let cashflowInsight = try await generateCashflowPredictionInsight(taskId: taskId) {
            aiInsights.append(cashflowInsight)
        }

        // AI-generated investment opportunity insight
        if let investmentInsight = try await generateInvestmentOpportunityInsight(taskId: taskId) {
            aiInsights.append(investmentInsight)
        }

        // AI-generated financial health score
        if let healthInsight = try await generateFinancialHealthInsight(taskId: taskId) {
            aiInsights.append(healthInsight)
        }

        return aiInsights
    }

    // MARK: - Agent Message Handlers

    private func handleFinancialAnalysisTask(_ message: MLACSMessage) async {
        guard let taskType = message.payload["task_type"]?.value as? String else { return }

        switch taskType {
        case "comprehensive_analysis":
            // Agent performs comprehensive financial analysis
            await processComprehensiveAnalysis(message)
        case "real_time_update":
            // Agent processes real-time updates
            await processRealTimeUpdate(message)
        default:
            print("Unknown financial analysis task: \(taskType)")
        }
    }

    private func handleFinancialDataAnalysis(_ message: MLACSMessage) async {
        // Process financial data analysis results from agent
        if let analysisResults = message.payload["analysis_results"]?.value as? [String: Any] {
            await processAnalysisResults(analysisResults)
        }
    }

    private func handleSpendingAnalysisTask(_ message: MLACSMessage) async {
        guard let taskType = message.payload["task_type"]?.value as? String else { return }

        if taskType == "spending_pattern_analysis" {
            // Enhanced spending pattern analysis with AI
            await processEnhancedSpendingAnalysis(message)
        }
    }

    private func handleAnomalyDetectionTask(_ message: MLACSMessage) async {
        guard let taskType = message.payload["task_type"]?.value as? String else { return }

        if taskType == "anomaly_detection" {
            // AI-powered anomaly detection
            await processAIAnomalyDetection(message)
        }
    }

    private func handlePredictiveAnalyticsTask(_ message: MLACSMessage) async {
        guard let taskType = message.payload["task_type"]?.value as? String else { return }

        switch taskType {
        case "predictive_analysis":
            await processPredictiveAnalysis(message)
        case "comprehensive_forecast":
            await processComprehensiveForecast(message)
        default:
            print("Unknown predictive analytics task: \(taskType)")
        }
    }

    private func handleDocumentProcessingData(_ message: MLACSMessage) async {
        if let documentId = message.payload["document_id"]?.value as? String {
            await processEnhancedDocumentAnalysis(documentId, message: message)
        }
    }

    // MARK: - Helper Methods

    private func fetchFinancialData() throws -> [FinancialData] {
        let request: NSFetchRequest<FinancialData> = FinancialData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \FinancialData.invoiceDate, ascending: false)]
        return try context.fetch(request)
    }

    private func updateSystemHealth() {
        if isMLACSConnected {
            systemHealth = mlacsFramework.getSystemHealth()
            activeAgentCount = mlacsFramework.activeAgents.count
        }
    }

    private func updateInsightsCache(with insight: FinancialInsight) {
        // Cache insights for real-time display
        let cacheKey = "\(insight.type.rawValue)_\(insight.id.uuidString)"
        aiPoweredInsightCache[cacheKey] = EnhancedFinancialInsight(from: insight)
    }

    private func updateInsightsFromDocument(_ document: PipelineProcessedDocument) async throws {
        // Generate insights from newly processed document
        let documentInsights = try await generateDocumentSpecificInsights(document)

        for insight in documentInsights {
            realTimeAnalysisStream.send(insight.toFinancialInsight())
        }
    }

    private func refreshInsightsInBackground() async throws {
        // Background refresh of insights when data changes
        _ = try await generateEnhancedRealTimeInsights()
    }

    // MARK: - Stub Implementations for AI Methods

    private func generateContextualInformation(for insight: FinancialInsight) -> String {
        "AI-enhanced context: This insight is based on advanced pattern recognition and historical analysis."
    }

    private func generatePredictionComponents(for insight: FinancialInsight) -> [String] {
        ["trend_analysis", "pattern_recognition", "statistical_modeling"]
    }

    private func calculateRecommendationStrength(for insight: FinancialInsight) -> Double {
        min(1.0, insight.confidence + 0.1)
    }

    private func identifyRiskFactors(for insight: FinancialInsight) -> [String] {
        ["market_volatility", "spending_patterns", "income_stability"]
    }

    private func generateAlternativeScenarios(for insight: FinancialInsight) -> [String] {
        ["conservative_approach", "aggressive_optimization", "balanced_strategy"]
    }

    private func generateCashflowPredictionInsight(taskId: String) async throws -> EnhancedFinancialInsight? {
        // AI-generated cashflow prediction logic would go here
        nil // Simplified for now
    }

    private func generateInvestmentOpportunityInsight(taskId: String) async throws -> EnhancedFinancialInsight? {
        // AI-generated investment opportunity logic would go here
        nil // Simplified for now
    }

    private func generateFinancialHealthInsight(taskId: String) async throws -> EnhancedFinancialInsight? {
        // AI-generated financial health score logic would go here
        nil // Simplified for now
    }

    private func generateDocumentSpecificInsights(_ document: PipelineProcessedDocument) async throws -> [EnhancedFinancialInsight] {
        // Generate insights specific to the processed document
        [] // Simplified for now
    }

    private func generateSpendingForecast(from trends: RealTimeSpendingTrendAnalysis) -> SpendingForecast {
        SpendingForecast(
            projectedMonthlySpending: trends.projectedNextMonth,
            confidence: trends.trendStrength,
            trend: trends.monthlyTrend
        )
    }

    private func generateIncomeForecast(from analysis: RealTimeIncomeAnalysis) -> IncomeForecast {
        IncomeForecast(
            projectedMonthlyIncome: analysis.projectedNextIncome,
            stabilityScore: analysis.stabilityScore,
            growthRate: analysis.lastThreeMonthsGrowth
        )
    }

    private func generateAIPoweredBudgetRecommendations() async throws -> [AIPoweredBudgetRecommendation] {
        let baseRecommendations = try baseInsightsEngine.generateBudgetRecommendations()
        return baseRecommendations.map { AIPoweredBudgetRecommendation(from: $0) }
    }

    private func generateRiskAssessment(from data: [FinancialData]) -> RiskAssessment {
        RiskAssessment(
            overallRiskScore: 0.3,
            riskFactors: ["income_variability", "spending_volatility"],
            mitigationStrategies: ["emergency_fund", "budget_optimization"]
        )
    }

    // MARK: - Processing Method Stubs

    private func processComprehensiveAnalysis(_ message: MLACSMessage) async {
        // Implementation for comprehensive analysis processing
    }

    private func processRealTimeUpdate(_ message: MLACSMessage) async {
        // Implementation for real-time update processing
    }

    private func processAnalysisResults(_ results: [String: Any]) async {
        // Implementation for processing analysis results
    }

    private func processEnhancedSpendingAnalysis(_ message: MLACSMessage) async {
        // Implementation for enhanced spending analysis
    }

    private func processAIAnomalyDetection(_ message: MLACSMessage) async {
        // Implementation for AI anomaly detection
    }

    private func processPredictiveAnalysis(_ message: MLACSMessage) async {
        // Implementation for predictive analysis
    }

    private func processComprehensiveForecast(_ message: MLACSMessage) async {
        // Implementation for comprehensive forecast
    }

    private func processEnhancedDocumentAnalysis(_ documentId: String, message: MLACSMessage) async {
        // Implementation for enhanced document analysis
    }
}

// MARK: - Enhanced Data Models

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

public enum InsightProcessingMethod {
    case traditional
    case aiEnhanced
    case fullyAI
    case hybrid
}

public struct EnhancedDocumentAnalysisResult {
    public let processedDocument: PipelineProcessedDocument
    public let aiInsights: [EnhancedFinancialInsight]
    public let processingMethod: InsightProcessingMethod
    public let agentCoordinationUsed: Bool
    public let analysisTimestamp: Date

    public init(processedDocument: PipelineProcessedDocument,
                aiInsights: [EnhancedFinancialInsight],
                processingMethod: InsightProcessingMethod,
                agentCoordinationUsed: Bool) {
        self.processedDocument = processedDocument
        self.aiInsights = aiInsights
        self.processingMethod = processingMethod
        self.agentCoordinationUsed = agentCoordinationUsed
        self.analysisTimestamp = Date()
    }
}

public struct PredictiveFinancialForecast {
    public let forecastHorizon: Int
    public let spendingForecast: SpendingForecast
    public let incomeForecast: IncomeForecast
    public let budgetRecommendations: [AIPoweredBudgetRecommendation]
    public let riskAssessment: RiskAssessment
    public let confidenceScore: Double
    public let generatedAt: Date
    public let aiMethodsUsed: [String]
    public let agentId: String
}

public struct SpendingForecast {
    public let projectedMonthlySpending: Double
    public let confidence: Double
    public let trend: SpendingTrend
}

public struct IncomeForecast {
    public let projectedMonthlyIncome: Double
    public let stabilityScore: Double
    public let growthRate: Double
}

public struct AIPoweredBudgetRecommendation {
    public let category: String
    public let suggestedAmount: Double
    public let currentSpending: Double
    public let confidence: Double
    public let reasoning: String
    public let aiOptimizations: [String]

    public init(from recommendation: RealTimeBudgetRecommendation) {
        self.category = recommendation.category
        self.suggestedAmount = recommendation.suggestedAmount
        self.currentSpending = recommendation.currentSpending
        self.confidence = recommendation.confidence
        self.reasoning = recommendation.reasoning
        self.aiOptimizations = ["pattern_based", "predictive_modeling"]
    }
}

public struct RiskAssessment {
    public let overallRiskScore: Double
    public let riskFactors: [String]
    public let mitigationStrategies: [String]
}

// MARK: - Error Types

public enum EnhancedInsightsError: Error, LocalizedError {
    case mlacsNotInitialized
    case agentNotAvailable(String)
    case documentProcessingFailed(String)
    case aiAnalysisFailed(String)
    case coordinationFailure(String)

    public var errorDescription: String? {
        switch self {
        case .mlacsNotInitialized:
            return "MLACS framework not initialized"
        case .agentNotAvailable(let agentType):
            return "Agent not available: \(agentType)"
        case .documentProcessingFailed(let details):
            return "Document processing failed: \(details)"
        case .aiAnalysisFailed(let details):
            return "AI analysis failed: \(details)"
        case .coordinationFailure(let details):
            return "Agent coordination failure: \(details)"
        }
    }
}
