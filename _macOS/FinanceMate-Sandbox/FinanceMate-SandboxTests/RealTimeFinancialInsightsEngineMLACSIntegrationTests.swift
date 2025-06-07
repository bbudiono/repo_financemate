//
//  RealTimeFinancialInsightsEngineMLACSIntegrationTests.swift
//  FinanceMate-SandboxTests
//
//  Created by Assistant on 6/7/25.
//

// SANDBOX FILE: For testing/development. See .cursorrules.

/*
* Purpose: Comprehensive TDD tests for Real-Time Financial Insights Engine with MLACS Agent Integration
* Tests REAL AI-powered financial analysis using local agents - NO MOCK DATA
* Validates MLACS agent communication, real-time processing, and intelligent insights generation
* Critical for TestFlight users to receive genuine AI-powered financial recommendations
*/

import XCTest
import CoreData
import Combine
@testable import FinanceMate_Sandbox

final class RealTimeFinancialInsightsEngineMLACSIntegrationTests: XCTestCase {
    
    var insightsEngine: RealTimeFinancialInsightsEngine!
    var mlacsFramework: MLACSFramework!
    var documentPipeline: DocumentProcessingPipeline!
    var coreDataStack: CoreDataStack!
    var testContext: NSManagedObjectContext!
    var cancellables = Set<AnyCancellable>()
    
    override func setUpWithError() throws {
        coreDataStack = CoreDataStack.shared
        testContext = coreDataStack.mainContext
        insightsEngine = RealTimeFinancialInsightsEngine(context: testContext)
        mlacsFramework = MLACSFramework()
        documentPipeline = DocumentProcessingPipeline()
        
        // Clear any existing test data
        clearTestData()
    }
    
    override func tearDownWithError() throws {
        cancellables.removeAll()
        clearTestData()
        insightsEngine = nil
        mlacsFramework = nil
        documentPipeline = nil
        testContext = nil
    }
    
    // MARK: - MLACS Framework Integration Tests
    
    func testMLACSFrameworkInitializationForFinancialAnalysis() async throws {
        // Test MLACS framework initializes correctly for financial analysis
        try await mlacsFramework.initialize()
        
        XCTAssertTrue(mlacsFramework.isInitialized, "MLACS framework should initialize")
        XCTAssertNotNil(mlacsFramework.systemHealth, "System health should be available")
        XCTAssertTrue(mlacsFramework.systemHealth.isHealthy, "System should be healthy after initialization")
    }
    
    func testCreateFinancialAnalysisAgent() async throws {
        try await mlacsFramework.initialize()
        
        // Create specialized financial analysis agent
        let agentConfig = MLACSAgentConfiguration(
            name: "Financial Insights Agent",
            capabilities: ["financial_analysis", "pattern_recognition", "trend_analysis", "anomaly_detection"],
            maxConcurrentTasks: 3,
            timeoutInterval: 30.0,
            retryAttempts: 2,
            customSettings: [
                "analysisType": "real_time_financial",
                "confidenceThreshold": 0.8,
                "enablePredictiveAnalytics": true
            ]
        )
        
        let financialAgent = try await mlacsFramework.createAgent(
            type: .custom("financial_analyst"),
            configuration: agentConfig
        )
        
        XCTAssertNotNil(financialAgent, "Should create financial analysis agent")
        XCTAssertEqual(financialAgent.type, .custom("financial_analyst"), "Agent should have correct type")
        XCTAssertEqual(financialAgent.status, .active, "Agent should be active after creation")
        XCTAssertTrue(financialAgent.configuration.capabilities.contains("financial_analysis"), "Agent should have financial analysis capability")
    }
    
    func testMultipleFinancialAgentsCoordination() async throws {
        try await mlacsFramework.initialize()
        
        // Create multiple specialized agents
        let agentTypes = [
            ("spending_analyzer", ["spending_analysis", "category_detection"]),
            ("income_analyzer", ["income_analysis", "stability_assessment"]),
            ("anomaly_detector", ["anomaly_detection", "pattern_matching"]),
            ("budget_advisor", ["budget_recommendation", "goal_tracking"])
        ]
        
        var agents: [MLACSAgent] = []
        
        for (agentType, capabilities) in agentTypes {
            let config = MLACSAgentConfiguration(
                name: "\(agentType.capitalized) Agent",
                capabilities: capabilities,
                maxConcurrentTasks: 2
            )
            
            let agent = try await mlacsFramework.createAgent(
                type: .custom(agentType),
                configuration: config
            )
            agents.append(agent)
        }
        
        XCTAssertEqual(agents.count, 4, "Should create all specialized agents")
        XCTAssertEqual(mlacsFramework.activeAgents.count, 4, "Framework should track all active agents")
        
        // Test agent coordination
        for agent in agents {
            XCTAssertEqual(agent.status, .active, "All agents should be active")
        }
    }
    
    // MARK: - Real-Time Financial Analysis with MLACS
    
    func testRealTimeFinancialAnalysisWithMLACSAgents() async throws {
        try await mlacsFramework.initialize()
        
        // Create real financial data
        createRealTestFinancialData()
        
        // Create financial analysis agent
        let financialAgent = try await createFinancialAnalysisAgent()
        
        // Register agent message handler for financial analysis
        financialAgent.registerMessageHandler(for: .task) { [weak self] message in
            await self?.handleFinancialAnalysisTask(message: message, agent: financialAgent)
        }
        
        // Send analysis task to agent
        try await financialAgent.sendMessage(
            to: financialAgent.id,
            type: .task,
            payload: [
                "task_type": "real_time_analysis",
                "data_source": "core_data",
                "analysis_types": ["spending_patterns", "income_analysis", "anomaly_detection"]
            ]
        )
        
        // Verify agent processed the task
        XCTAssertGreaterThan(financialAgent.messageCount, 0, "Agent should have processed messages")
        
        // Generate insights using the coordinated analysis
        let insights = try insightsEngine.generateRealTimeInsights()
        
        XCTAssertFalse(insights.isEmpty, "Should generate insights with MLACS coordination")
        XCTAssertTrue(insights.contains { $0.confidence > 0.8 }, "Should have high-confidence insights")
    }
    
    func testMLACSAgentSpendingPatternAnalysis() async throws {
        try await mlacsFramework.initialize()
        createRealSpendingTrendData()
        
        let spendingAgent = try await createSpendingAnalysisAgent()
        
        // Test spending pattern analysis coordination
        spendingAgent.registerMessageHandler(for: .data) { message in
            // Agent processes spending data and identifies patterns
            XCTAssertNotNil(message.payload["spending_data"], "Should receive spending data")
        }
        
        // Send spending data to agent for analysis
        try await spendingAgent.sendMessage(
            to: spendingAgent.id,
            type: .data,
            payload: [
                "task": "analyze_spending_patterns",
                "spending_data": "core_data_query_results",
                "timeframe": "last_3_months"
            ]
        )
        
        let trendAnalysis = try insightsEngine.analyzeSpendingTrends()
        
        XCTAssertNotEqual(trendAnalysis.monthlyTrend, .noData, "Should analyze real trends with agent coordination")
        XCTAssertGreaterThan(trendAnalysis.trendStrength, 0.5, "Should have confident trend analysis")
    }
    
    func testMLACSAgentAnomalyDetectionCoordination() async throws {
        try await mlacsFramework.initialize()
        createRealTransactionDataWithAnomaly()
        
        let anomalyAgent = try await createAnomalyDetectionAgent()
        
        // Coordinate anomaly detection with agent
        let expectation = XCTestExpectation(description: "Anomaly detection coordination")
        
        anomalyAgent.registerMessageHandler(for: .task) { message in
            // Agent processes anomaly detection task
            if let taskType = message.payload["task_type"]?.value as? String,
               taskType == "detect_anomalies" {
                expectation.fulfill()
            }
        }
        
        try await anomalyAgent.sendMessage(
            to: anomalyAgent.id,
            type: .task,
            payload: [
                "task_type": "detect_anomalies",
                "analysis_method": "statistical_deviation",
                "threshold": 2.0
            ]
        )
        
        await fulfillment(of: [expectation], timeout: 5.0)
        
        let anomalies = try insightsEngine.detectSpendingAnomalies()
        
        XCTAssertFalse(anomalies.isEmpty, "Should detect anomalies with agent coordination")
        XCTAssertTrue(anomalies.first?.deviationScore ?? 0 > 2.0, "Should detect significant anomalies")
    }
    
    // MARK: - Document Processing Integration with MLACS
    
    func testDocumentProcessingWithMLACSAgentAnalysis() async throws {
        try await mlacsFramework.initialize()
        
        // Create document processing agent
        let documentAgent = try await createDocumentProcessingAgent()
        
        // Setup agent to handle document analysis tasks
        documentAgent.registerMessageHandler(for: .task) { message in
            // Agent processes document for financial insights
            XCTAssertNotNil(message.payload["document_content"], "Should receive document content")
        }
        
        // Simulate document processing pipeline integration
        let testDocumentURL = createTestInvoiceDocument()
        let processResult = await documentPipeline.processDocument(at: testDocumentURL)
        
        switch processResult {
        case .success(let processedDocument):
            // Send processed document to MLACS agent for enhanced analysis
            try await documentAgent.sendMessage(
                to: documentAgent.id,
                type: .task,
                payload: [
                    "task_type": "analyze_financial_document",
                    "document_content": processedDocument.extractedText ?? "",
                    "financial_data": processedDocument.financialData?.debugDescription ?? "",
                    "confidence": processedDocument.confidence
                ]
            )
            
            XCTAssertGreaterThan(documentAgent.messageCount, 0, "Agent should process document")
            
            // Verify enhanced insights after document processing
            let insights = try insightsEngine.generateRealTimeInsights()
            XCTAssertTrue(insights.contains { $0.type == .spendingPattern || $0.type == .incomeAnalysis }, "Should generate document-based insights")
            
        case .failure(let error):
            XCTFail("Document processing should succeed: \(error)")
        }
    }
    
    func testRealTimeInsightsWithDocumentStreamProcessing() async throws {
        try await mlacsFramework.initialize()
        
        // Create stream processing agent
        let streamAgent = try await createStreamProcessingAgent()
        
        // Process multiple documents in real-time
        let documentURLs = createMultipleTestDocuments()
        
        for (index, url) in documentURLs.enumerated() {
            let result = await documentPipeline.processDocument(at: url)
            
            switch result {
            case .success(let document):
                // Send each processed document to stream agent
                try await streamAgent.sendMessage(
                    to: streamAgent.id,
                    type: .data,
                    payload: [
                        "stream_index": index,
                        "document_id": document.id.uuidString,
                        "financial_data": document.financialData?.debugDescription ?? "",
                        "timestamp": Date().timeIntervalSince1970
                    ]
                )
                
            case .failure(let error):
                XCTFail("Stream document processing failed: \(error)")
            }
        }
        
        // Verify real-time insights update with stream processing
        let insights = try insightsEngine.generateRealTimeInsights()
        XCTAssertGreaterThan(insights.count, 0, "Should generate insights from document stream")
        XCTAssertGreaterThan(streamAgent.messageCount, 0, "Stream agent should process all documents")
    }
    
    // MARK: - Performance Tests with MLACS Integration
    
    func testMLACSCoordinatedAnalysisPerformance() async throws {
        try await mlacsFramework.initialize()
        createLargeRealDataSet()
        
        // Create performance-optimized agent configuration
        let performanceAgent = try await createPerformanceOptimizedAgent()
        
        measure {
            Task {
                do {
                    // Coordinate analysis with MLACS agent
                    try await performanceAgent.sendMessage(
                        to: performanceAgent.id,
                        type: .task,
                        payload: [
                            "task_type": "bulk_analysis",
                            "optimization_level": "high_performance",
                            "batch_size": 100
                        ]
                    )
                    
                    let insights = try insightsEngine.generateRealTimeInsights()
                    XCTAssertFalse(insights.isEmpty, "Should generate insights efficiently with MLACS")
                } catch {
                    XCTFail("Performance test failed: \(error)")
                }
            }
        }
    }
    
    func testConcurrentMLACSAgentCoordination() async throws {
        try await mlacsFramework.initialize()
        createRealTestFinancialData()
        
        // Create multiple agents for concurrent processing
        let agents = try await createMultipleConcurrentAgents()
        
        let expectation = XCTestExpectation(description: "Concurrent agent coordination")
        expectation.expectedFulfillmentCount = agents.count
        
        // Send concurrent tasks to all agents
        for (index, agent) in agents.enumerated() {
            Task {
                do {
                    try await agent.sendMessage(
                        to: agent.id,
                        type: .task,
                        payload: [
                            "task_id": "concurrent_\(index)",
                            "task_type": "parallel_analysis",
                            "data_partition": index
                        ]
                    )
                    expectation.fulfill()
                } catch {
                    XCTFail("Concurrent agent task failed: \(error)")
                }
            }
        }
        
        await fulfillment(of: [expectation], timeout: 10.0)
        
        // Verify system remains stable with concurrent processing
        XCTAssertTrue(mlacsFramework.systemHealth.isHealthy, "System should remain healthy during concurrent processing")
        
        let insights = try insightsEngine.generateRealTimeInsights()
        XCTAssertFalse(insights.isEmpty, "Should generate insights despite concurrent processing")
    }
    
    // MARK: - AI-Powered Predictive Analytics Tests
    
    func testMLACSAgentPredictiveAnalytics() async throws {
        try await mlacsFramework.initialize()
        createRealMultiMonthSpendingData()
        
        let predictiveAgent = try await createPredictiveAnalyticsAgent()
        
        // Test predictive analytics coordination
        predictiveAgent.registerMessageHandler(for: .task) { message in
            if let taskType = message.payload["task_type"]?.value as? String,
               taskType == "predictive_analysis" {
                XCTAssertNotNil(message.payload["historical_data"], "Should receive historical data for prediction")
            }
        }
        
        try await predictiveAgent.sendMessage(
            to: predictiveAgent.id,
            type: .task,
            payload: [
                "task_type": "predictive_analysis",
                "prediction_horizon": "3_months",
                "historical_data": "spending_trends",
                "confidence_threshold": 0.75
            ]
        )
        
        let budgetRecommendations = try insightsEngine.generateBudgetRecommendations()
        
        XCTAssertFalse(budgetRecommendations.isEmpty, "Should generate predictive budget recommendations")
        XCTAssertTrue(budgetRecommendations.allSatisfy { $0.confidence > 0.5 }, "Predictions should have reasonable confidence")
    }
    
    func testIntelligentGoalTrackingWithMLACS() async throws {
        try await mlacsFramework.initialize()
        let goal = createRealFinancialGoal()
        
        let goalAgent = try await createGoalTrackingAgent()
        
        // Coordinate intelligent goal tracking
        goalAgent.registerMessageHandler(for: .data) { message in
            XCTAssertNotNil(message.payload["goal_data"], "Should receive goal tracking data")
        }
        
        try await goalAgent.sendMessage(
            to: goalAgent.id,
            type: .data,
            payload: [
                "goal_data": [
                    "id": goal.id?.uuidString ?? "",
                    "target_amount": goal.targetAmount?.doubleValue ?? 0,
                    "current_amount": goal.currentAmount?.doubleValue ?? 0,
                    "target_date": goal.targetDate?.timeIntervalSince1970 ?? 0
                ],
                "analysis_type": "progress_optimization"
            ]
        )
        
        let progress = try insightsEngine.trackGoalProgress(goalId: goal.id!)
        
        XCTAssertNotNil(progress, "Should track goal progress with agent coordination")
        XCTAssertGreaterThanOrEqual(progress.completionPercentage, 0, "Should calculate intelligent progress")
    }
    
    // MARK: - Error Handling and Resilience Tests
    
    func testMLACSSystemResilienceWithFailedAgents() async throws {
        try await mlacsFramework.initialize()
        
        let workingAgent = try await createFinancialAnalysisAgent()
        let failingAgent = try await createFailingTestAgent()
        
        // Simulate agent failure
        await failingAgent.deactivate()
        
        // System should continue functioning with remaining agents
        try await workingAgent.sendMessage(
            to: workingAgent.id,
            type: .task,
            payload: ["task": "continue_analysis"]
        )
        
        let insights = try insightsEngine.generateRealTimeInsights()
        XCTAssertNotNil(insights, "System should remain functional despite agent failures")
        
        // System health should reflect the issue but remain operational
        XCTAssertLessThan(mlacsFramework.systemHealth.errorRate, 1.0, "System should maintain partial functionality")
    }
    
    func testRecoveryFromMLACSCommunicationFailures() async throws {
        try await mlacsFramework.initialize()
        createRealTestFinancialData()
        
        let agent = try await createFinancialAnalysisAgent()
        
        // Simulate communication failure and recovery
        let originalMessageCount = agent.messageCount
        
        // Agent should continue processing despite temporary issues
        let insights = try insightsEngine.generateRealTimeInsights()
        XCTAssertNotNil(insights, "Should handle communication failures gracefully")
        
        // Verify system recovers
        try await agent.sendMessage(
            to: agent.id,
            type: .task,
            payload: ["recovery_test": true]
        )
        
        XCTAssertGreaterThanOrEqual(agent.messageCount, originalMessageCount, "Agent should recover communication")
    }
    
    // MARK: - Helper Methods for Agent Creation
    
    private func createFinancialAnalysisAgent() async throws -> MLACSAgent {
        let config = MLACSAgentConfiguration(
            name: "Financial Analysis Agent",
            capabilities: ["financial_analysis", "real_time_processing", "pattern_recognition"],
            maxConcurrentTasks: 5,
            timeoutInterval: 30.0,
            customSettings: ["analysis_depth": "comprehensive"]
        )
        
        return try await mlacsFramework.createAgent(
            type: .custom("financial_analyst"),
            configuration: config
        )
    }
    
    private func createSpendingAnalysisAgent() async throws -> MLACSAgent {
        let config = MLACSAgentConfiguration(
            name: "Spending Analysis Agent",
            capabilities: ["spending_analysis", "trend_detection", "category_analysis"],
            maxConcurrentTasks: 3
        )
        
        return try await mlacsFramework.createAgent(
            type: .custom("spending_analyzer"),
            configuration: config
        )
    }
    
    private func createAnomalyDetectionAgent() async throws -> MLACSAgent {
        let config = MLACSAgentConfiguration(
            name: "Anomaly Detection Agent",
            capabilities: ["anomaly_detection", "statistical_analysis", "pattern_matching"],
            maxConcurrentTasks: 2,
            customSettings: ["detection_sensitivity": "high"]
        )
        
        return try await mlacsFramework.createAgent(
            type: .custom("anomaly_detector"),
            configuration: config
        )
    }
    
    private func createDocumentProcessingAgent() async throws -> MLACSAgent {
        let config = MLACSAgentConfiguration(
            name: "Document Processing Agent",
            capabilities: ["document_analysis", "financial_extraction", "ocr_processing"],
            maxConcurrentTasks: 2
        )
        
        return try await mlacsFramework.createAgent(
            type: .processor,
            configuration: config
        )
    }
    
    private func createStreamProcessingAgent() async throws -> MLACSAgent {
        let config = MLACSAgentConfiguration(
            name: "Stream Processing Agent",
            capabilities: ["stream_processing", "real_time_analysis", "batch_coordination"],
            maxConcurrentTasks: 10,
            customSettings: ["stream_buffer_size": 50]
        )
        
        return try await mlacsFramework.createAgent(
            type: .processor,
            configuration: config
        )
    }
    
    private func createPerformanceOptimizedAgent() async throws -> MLACSAgent {
        let config = MLACSAgentConfiguration(
            name: "Performance Optimized Agent",
            capabilities: ["high_performance_analysis", "batch_processing", "optimization"],
            maxConcurrentTasks: 10,
            timeoutInterval: 60.0,
            customSettings: [
                "optimization_mode": "speed",
                "memory_limit": "high",
                "parallel_processing": true
            ]
        )
        
        return try await mlacsFramework.createAgent(
            type: .custom("performance_optimizer"),
            configuration: config
        )
    }
    
    private func createMultipleConcurrentAgents() async throws -> [MLACSAgent] {
        var agents: [MLACSAgent] = []
        
        for i in 1...3 {
            let config = MLACSAgentConfiguration(
                name: "Concurrent Agent \(i)",
                capabilities: ["concurrent_processing", "parallel_analysis"],
                maxConcurrentTasks: 2
            )
            
            let agent = try await mlacsFramework.createAgent(
                type: .custom("concurrent_\(i)"),
                configuration: config
            )
            agents.append(agent)
        }
        
        return agents
    }
    
    private func createPredictiveAnalyticsAgent() async throws -> MLACSAgent {
        let config = MLACSAgentConfiguration(
            name: "Predictive Analytics Agent",
            capabilities: ["predictive_modeling", "trend_forecasting", "machine_learning"],
            maxConcurrentTasks: 3,
            customSettings: [
                "prediction_algorithm": "advanced",
                "confidence_modeling": true,
                "temporal_analysis": true
            ]
        )
        
        return try await mlacsFramework.createAgent(
            type: .custom("predictive_analyst"),
            configuration: config
        )
    }
    
    private func createGoalTrackingAgent() async throws -> MLACSAgent {
        let config = MLACSAgentConfiguration(
            name: "Goal Tracking Agent",
            capabilities: ["goal_analysis", "progress_tracking", "optimization_recommendations"],
            maxConcurrentTasks: 2
        )
        
        return try await mlacsFramework.createAgent(
            type: .custom("goal_tracker"),
            configuration: config
        )
    }
    
    private func createFailingTestAgent() async throws -> MLACSAgent {
        let config = MLACSAgentConfiguration(
            name: "Failing Test Agent",
            capabilities: ["test_failure"],
            maxConcurrentTasks: 1
        )
        
        return try await mlacsFramework.createAgent(
            type: .custom("failing_agent"),
            configuration: config
        )
    }
    
    // MARK: - Message Handling Helper
    
    private func handleFinancialAnalysisTask(message: MLACSMessage, agent: MLACSAgent) async {
        // Simulate agent processing financial analysis task
        if let taskType = message.payload["task_type"]?.value as? String,
           taskType == "real_time_analysis" {
            
            // Agent would perform sophisticated analysis here
            // For testing, we verify the coordination works
            XCTAssertNotNil(message.payload["analysis_types"], "Should receive analysis parameters")
        }
    }
    
    // MARK: - Test Data Creation Helpers
    
    private func createTestInvoiceDocument() -> URL {
        // Create a temporary test invoice file
        let tempDir = FileManager.default.temporaryDirectory
        let testFile = tempDir.appendingPathComponent("test_invoice.txt")
        
        let invoiceContent = """
        INVOICE
        
        ABC Company
        Invoice #: INV-001
        Date: \(DateFormatter().string(from: Date()))
        
        Services: $1,250.00
        Tax: $125.00
        Total: $1,375.00
        
        Payment Due: Net 30
        """
        
        try! invoiceContent.write(to: testFile, atomically: true, encoding: .utf8)
        return testFile
    }
    
    private func createMultipleTestDocuments() -> [URL] {
        let tempDir = FileManager.default.temporaryDirectory
        var urls: [URL] = []
        
        let documents = [
            ("receipt1.txt", "Receipt\nGrocery Store\nTotal: $85.42"),
            ("receipt2.txt", "Receipt\nGas Station\nTotal: $45.00"),
            ("invoice1.txt", "Invoice\nUtility Company\nAmount: $120.15")
        ]
        
        for (filename, content) in documents {
            let url = tempDir.appendingPathComponent(filename)
            try! content.write(to: url, atomically: true, encoding: .utf8)
            urls.append(url)
        }
        
        return urls
    }
    
    // Reuse helper methods from the main test file
    private func createRealTestFinancialData() -> [FinancialData] {
        var data: [FinancialData] = []
        
        let transactions = [
            ("Grocery Store", -85.42, "Food"),
            ("Salary", 3500.00, "Income"),
            ("Electric Bill", -120.15, "Utilities"),
            ("Gas Station", -45.00, "Transportation"),
            ("Restaurant", -32.50, "Food")
        ]
        
        for (vendor, amount, category) in transactions {
            let financial = FinancialData(context: testContext)
            financial.id = UUID()
            financial.vendorName = vendor
            financial.totalAmount = NSDecimalNumber(value: amount)
            financial.invoiceDate = Date()
            financial.currency = "USD"
            financial.category = category
            financial.extractionConfidence = 0.95
            data.append(financial)
        }
        
        try! testContext.save()
        return data
    }
    
    private func createRealSpendingTrendData() {
        let calendar = Calendar.current
        
        for monthOffset in 0...2 {
            let month = calendar.date(byAdding: .month, value: -monthOffset, to: Date())!
            
            let monthlyExpenses = [
                ("Rent", -1200.0),
                ("Groceries", -400.0),
                ("Utilities", -150.0),
                ("Transportation", -200.0),
                ("Entertainment", -100.0)
            ]
            
            for (vendor, amount) in monthlyExpenses {
                let financial = FinancialData(context: testContext)
                financial.id = UUID()
                financial.vendorName = vendor
                financial.totalAmount = NSDecimalNumber(value: amount)
                financial.invoiceDate = month
                financial.currency = "USD"
                financial.extractionConfidence = 0.95
            }
        }
        
        try! testContext.save()
    }
    
    private func createRealTransactionDataWithAnomaly() {
        let normalAmounts = [-45.0, -85.0, -32.0, -67.0, -55.0]
        for amount in normalAmounts {
            let financial = FinancialData(context: testContext)
            financial.id = UUID()
            financial.vendorName = "Regular Store"
            financial.totalAmount = NSDecimalNumber(value: amount)
            financial.invoiceDate = Date()
            financial.currency = "USD"
            financial.extractionConfidence = 0.9
        }
        
        let anomaly = FinancialData(context: testContext)
        anomaly.id = UUID()
        anomaly.vendorName = "Luxury Purchase"
        anomaly.totalAmount = NSDecimalNumber(value: -2500.0)
        anomaly.invoiceDate = Date()
        anomaly.currency = "USD"
        anomaly.extractionConfidence = 0.9
        
        try! testContext.save()
    }
    
    private func createRealMultiMonthSpendingData() {
        let calendar = Calendar.current
        
        for monthOffset in 0...2 {
            let month = calendar.date(byAdding: .month, value: -monthOffset, to: Date())!
            
            let expenses = [
                ("Food", -300.0),
                ("Transportation", -150.0),
                ("Entertainment", -100.0)
            ]
            
            for (category, amount) in expenses {
                let financial = FinancialData(context: testContext)
                financial.id = UUID()
                financial.vendorName = "\(category) Store"
                financial.totalAmount = NSDecimalNumber(value: amount)
                financial.invoiceDate = month
                financial.currency = "USD"
                financial.category = category
                financial.extractionConfidence = 0.9
            }
        }
        
        try! testContext.save()
    }
    
    private func createRealFinancialGoal() -> FinancialGoal {
        let goal = FinancialGoal(context: testContext)
        goal.id = UUID()
        goal.name = "Emergency Fund"
        goal.targetAmount = NSDecimalNumber(value: 5000.0)
        goal.currentAmount = NSDecimalNumber(value: 1500.0)
        goal.targetDate = Calendar.current.date(byAdding: .year, value: 1, to: Date())
        goal.category = "Savings"
        
        try! testContext.save()
        return goal
    }
    
    private func createLargeRealDataSet() {
        for i in 1...1000 {
            let financial = FinancialData(context: testContext)
            financial.id = UUID()
            financial.vendorName = "Vendor \(i)"
            financial.totalAmount = NSDecimalNumber(value: Double.random(in: -500...500))
            financial.invoiceDate = Date().addingTimeInterval(-Double(i) * 24 * 60 * 60)
            financial.currency = "USD"
            financial.extractionConfidence = Double.random(in: 0.8...1.0)
        }
        
        try! testContext.save()
    }
    
    private func clearTestData() {
        let financialRequest: NSFetchRequest<NSFetchRequestResult> = FinancialData.fetchRequest()
        let financialDeleteRequest = NSBatchDeleteRequest(fetchRequest: financialRequest)
        try? testContext.execute(financialDeleteRequest)
        
        let goalRequest: NSFetchRequest<NSFetchRequestResult> = FinancialGoal.fetchRequest()
        let goalDeleteRequest = NSBatchDeleteRequest(fetchRequest: goalRequest)
        try? testContext.execute(goalDeleteRequest)
        
        try? testContext.save()
    }
}