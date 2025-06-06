//
//  AdvancedFinancialAnalyticsTests.swift
//  FinanceMate-Sandbox
//
//  Created by Assistant on 6/2/25.
//

// SANDBOX FILE: For testing/development. See .cursorrules.

/*
* Purpose: Comprehensive TDD test suite for Advanced Financial Analytics Engine in Sandbox environment
* Issues & Complexity Summary: TDD approach ensuring robust financial analytics functionality
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~800
  - Core Algorithm Complexity: Very High
  - Dependencies: 6 New (analytics engine, trend analysis, forecasting, risk assessment, portfolio analysis, performance metrics)
  - State Management Complexity: High
  - Novelty/Uncertainty Factor: Medium
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 85%
* Problem Estimate (Inherent Problem Difficulty %): 82%
* Initial Code Complexity Estimate %: 84%
* Justification for Estimates: Advanced financial analytics with predictive modeling and comprehensive analysis
* Final Code Complexity (Actual %): TBD - TDD implementation
* Overall Result Score (Success & Quality %): TBD - TDD validation
* Key Variances/Learnings: TDD drives robust financial analytics with comprehensive validation
* Last Updated: 2025-06-02
*/

import XCTest
import Foundation
@testable import FinanceMate_Sandbox

@MainActor
final class AdvancedFinancialAnalyticsTests: XCTestCase {
    
    var analyticsEngine: AdvancedFinancialAnalyticsEngine!
    var sampleTransactions: [AnalyticsTransaction] = []
    var samplePortfolio: FinancialPortfolio!
    
    override func setUp() {
        super.setUp()
        analyticsEngine = AdvancedFinancialAnalyticsEngine()
        sampleTransactions = createSampleTransactions()
        samplePortfolio = createSamplePortfolio()
    }
    
    override func tearDown() {
        analyticsEngine = nil
        sampleTransactions = []
        samplePortfolio = nil
        super.tearDown()
    }
    
    // MARK: - Engine Initialization Tests
    
    func testAnalyticsEngineInitialization() {
        // Given/When: Engine is initialized
        let engine = AdvancedFinancialAnalyticsEngine()
        
        // Then: Should be properly initialized
        XCTAssertNotNil(engine)
        XCTAssertFalse(engine.isAnalyzing)
        XCTAssertTrue(engine.analysisResults.isEmpty)
        XCTAssertNotNil(engine.configuration)
        XCTAssertEqual(engine.analysisCapabilities.count, 8) // Expected analytics capabilities
    }
    
    // MARK: - Trend Analysis Tests
    
    func testSpendingTrendAnalysis() async throws {
        // Given: Sample transactions over multiple months
        let multiMonthTransactions = createMultiMonthTransactions()
        
        // When: Analyzing spending trends
        let trendAnalysis = try await analyticsEngine.analyzeSpendingTrends(
            transactions: multiMonthTransactions,
            timeframe: .sixMonths
        )
        
        // Then: Should provide comprehensive trend analysis
        XCTAssertNotNil(trendAnalysis)
        XCTAssertEqual(trendAnalysis.timeframe, .sixMonths)
        XCTAssertFalse(trendAnalysis.monthlyTrends.isEmpty)
        XCTAssertGreaterThan(trendAnalysis.averageMonthlySpending, 0)
        XCTAssertNotNil(trendAnalysis.growthRate)
        XCTAssertNotNil(trendAnalysis.seasonalPatterns)
        XCTAssertFalse(trendAnalysis.categoryTrends.isEmpty)
    }
    
    func testIncomeTrendAnalysis() async throws {
        // Given: Sample income transactions
        let incomeTransactions = createIncomeTransactions()
        
        // When: Analyzing income trends
        let trendAnalysis = try await analyticsEngine.analyzeIncomeTrends(
            transactions: incomeTransactions,
            timeframe: .oneYear
        )
        
        // Then: Should provide income trend insights
        XCTAssertNotNil(trendAnalysis)
        XCTAssertGreaterThan(trendAnalysis.averageMonthlyIncome, 0)
        XCTAssertNotNil(trendAnalysis.incomeStability)
        XCTAssertNotNil(trendAnalysis.growthProjection)
        XCTAssertFalse(trendAnalysis.sourceBreakdown.isEmpty)
    }
    
    // MARK: - Financial Forecasting Tests
    
    func testExpenseForecastingML() async throws {
        // Given: Historical expense data
        let historicalData = createHistoricalExpenseData()
        
        // When: Generating ML-based expense forecast
        let forecast = try await analyticsEngine.generateExpenseForecast(
            historicalData: historicalData,
            forecastPeriod: .threeMonths,
            model: .machineLearning
        )
        
        // Then: Should provide accurate forecast with confidence intervals
        XCTAssertNotNil(forecast)
        XCTAssertEqual(forecast.forecastPeriod, .threeMonths)
        XCTAssertEqual(forecast.predictions.count, 3) // 3 months
        XCTAssertGreaterThan(forecast.overallConfidence, 0.7) // At least 70% confidence
        XCTAssertNotNil(forecast.confidenceIntervals)
        XCTAssertFalse(forecast.categoryForecasts.isEmpty)
    }
    
    func testCashFlowProjection() async throws {
        // Given: Income and expense patterns
        let cashFlowData = createCashFlowData()
        
        // When: Projecting cash flow
        let projection = try await analyticsEngine.projectCashFlow(
            data: cashFlowData,
            projectionPeriod: .sixMonths
        )
        
        // Then: Should provide detailed cash flow projection
        XCTAssertNotNil(projection)
        XCTAssertEqual(projection.projectionPeriod, .sixMonths)
        XCTAssertEqual(projection.monthlyProjections.count, 6)
        XCTAssertNotNil(projection.riskAssessment)
        XCTAssertNotNil(projection.liquidityAnalysis)
    }
    
    // MARK: - Risk Assessment Tests
    
    func testFinancialRiskAssessment() async throws {
        // Given: Portfolio with various risk factors
        let riskPortfolio = createRiskPortfolio()
        
        // When: Assessing financial risk
        let riskAssessment = try await analyticsEngine.assessFinancialRisk(
            portfolio: riskPortfolio,
            timeframe: .oneYear
        )
        
        // Then: Should provide comprehensive risk analysis
        XCTAssertNotNil(riskAssessment)
        XCTAssertGreaterThanOrEqual(riskAssessment.overallRiskScore, 0.0)
        XCTAssertLessThanOrEqual(riskAssessment.overallRiskScore, 1.0)
        XCTAssertFalse(riskAssessment.riskFactors.isEmpty)
        XCTAssertNotNil(riskAssessment.volatilityMeasures)
        XCTAssertNotNil(riskAssessment.riskMitigationSuggestions)
    }
    
    func testVolatilityAnalysis() async throws {
        // Given: Historical price data with volatility
        let volatileData = createVolatileFinancialData()
        
        // When: Analyzing volatility
        let volatilityAnalysis = try await analyticsEngine.analyzeVolatility(
            data: volatileData,
            period: .oneYear
        )
        
        // Then: Should calculate accurate volatility metrics
        XCTAssertNotNil(volatilityAnalysis)
        XCTAssertGreaterThan(volatilityAnalysis.standardDeviation, 0)
        XCTAssertNotNil(volatilityAnalysis.valueAtRisk)
        XCTAssertNotNil(volatilityAnalysis.conditionalValueAtRisk)
        XCTAssertFalse(volatilityAnalysis.volatilityClusters.isEmpty)
    }
    
    // MARK: - Portfolio Analysis Tests
    
    func testPortfolioPerformanceAnalysis() async throws {
        // Given: Sample portfolio with performance data
        let performancePortfolio = samplePortfolio
        
        // When: Analyzing portfolio performance
        let performanceAnalysis = try await analyticsEngine.analyzePortfolioPerformance(
            portfolio: performancePortfolio,
            benchmarkIndex: .sp500
        )
        
        // Then: Should provide detailed performance metrics
        XCTAssertNotNil(performanceAnalysis)
        XCTAssertNotNil(performanceAnalysis.totalReturn)
        XCTAssertNotNil(performanceAnalysis.annualizedReturn)
        XCTAssertNotNil(performanceAnalysis.sharpeRatio)
        XCTAssertNotNil(performanceAnalysis.betaCoefficient)
        XCTAssertNotNil(performanceAnalysis.alphaGeneration)
        XCTAssertFalse(performanceAnalysis.sectorAllocation.isEmpty)
    }
    
    func testPortfolioOptimization() async throws {
        // Given: Portfolio for optimization
        let unoptimizedPortfolio = createUnoptimizedPortfolio()
        
        // When: Optimizing portfolio
        let optimization = try await analyticsEngine.optimizePortfolio(
            portfolio: unoptimizedPortfolio,
            objective: .maxSharpeRatio,
            constraints: createOptimizationConstraints()
        )
        
        // Then: Should provide optimized allocation
        XCTAssertNotNil(optimization)
        XCTAssertFalse(optimization.recommendedAllocation.isEmpty)
        XCTAssertGreaterThan(optimization.expectedReturn, unoptimizedPortfolio.currentReturn)
        XCTAssertLessThan(optimization.expectedRisk, unoptimizedPortfolio.currentRisk)
        XCTAssertNotNil(optimization.rebalancingSteps)
    }
    
    // MARK: - Advanced Analytics Tests
    
    func testExpenseCategorizationML() async throws {
        // Given: Uncategorized transactions
        let uncategorizedTransactions = createUncategorizedTransactions()
        
        // When: Using ML to categorize expenses
        let categorizedResults = try await analyticsEngine.categorizeExpensesML(
            transactions: uncategorizedTransactions
        )
        
        // Then: Should accurately categorize transactions
        XCTAssertNotNil(categorizedResults)
        XCTAssertEqual(categorizedResults.count, uncategorizedTransactions.count)
        
        for result in categorizedResults {
            XCTAssertNotNil(result.predictedCategory)
            XCTAssertGreaterThan(result.confidence, 0.5) // At least 50% confidence
            XCTAssertFalse(result.reasoning.isEmpty)
        }
    }
    
    func testAnomalyDetection() async throws {
        // Given: Transaction data with anomalies
        let transactionsWithAnomalies = createTransactionsWithAnomalies()
        
        // When: Detecting anomalies
        let anomalies = try await analyticsEngine.detectAnomalies(
            transactions: transactionsWithAnomalies,
            sensitivity: .medium
        )
        
        // Then: Should detect suspicious transactions
        XCTAssertNotNil(anomalies)
        XCTAssertFalse(anomalies.isEmpty)
        XCTAssertGreaterThanOrEqual(anomalies.count, 2) // Expect at least 2 anomalies
        
        for anomaly in anomalies {
            XCTAssertNotNil(anomaly.anomalyType)
            XCTAssertGreaterThan(anomaly.anomalyScore, 0.7) // High anomaly score
            XCTAssertFalse(anomaly.description.isEmpty)
        }
    }
    
    // MARK: - Performance Tests
    
    func testLargeDatasetAnalysisPerformance() async throws {
        // Given: Large dataset
        let largeDataset = createLargeFinancialDataset(transactionCount: 10000)
        
        // When: Measuring analysis performance
        let startTime = Date()
        
        let analysis = try await analyticsEngine.performComprehensiveAnalysis(
            transactions: largeDataset,
            analysisTypes: [.trends, .forecasting, .riskAssessment]
        )
        
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)
        
        // Then: Should complete within reasonable time
        XCTAssertNotNil(analysis)
        XCTAssertLessThan(duration, 30.0, "Large dataset analysis should complete within 30 seconds")
        XCTAssertFalse(analysis.trendAnalysis.isEmpty)
        XCTAssertNotNil(analysis.forecastResults)
        XCTAssertNotNil(analysis.riskMetrics)
    }
    
    func testConcurrentAnalysisPerformance() async throws {
        // Given: Multiple analysis requests
        let datasets = [
            createSampleTransactions(),
            createMultiMonthTransactions(),
            createIncomeTransactions()
        ]
        
        // When: Running concurrent analysis
        let startTime = Date()
        
        try await withThrowingTaskGroup(of: Void.self) { group in
            for (index, dataset) in datasets.enumerated() {
                group.addTask { [weak self] in
                    guard let self = self else { return }
                    _ = try await self.analyticsEngine.analyzeSpendingTrends(
                        transactions: dataset,
                        timeframe: .threeMonths
                    )
                }
            }
            try await group.waitForAll()
        }
        
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)
        
        // Then: Concurrent analysis should be efficient
        XCTAssertLessThan(duration, 15.0, "Concurrent analysis should complete within 15 seconds")
    }
    
    // MARK: - Integration Tests
    
    func testEndToEndAnalyticsWorkflow() async throws {
        // Given: Raw financial data
        let rawData = createRawFinancialData()
        
        // When: Executing complete analytics workflow
        let workflowResult = try await analyticsEngine.executeAnalyticsWorkflow(
            rawData: rawData,
            workflowType: .comprehensive
        )
        
        // Then: Should provide complete financial insights
        XCTAssertNotNil(workflowResult)
        XCTAssertFalse(workflowResult.processedTransactions.isEmpty)
        XCTAssertNotNil(workflowResult.trendAnalysis)
        XCTAssertNotNil(workflowResult.forecastingResults)
        XCTAssertNotNil(workflowResult.riskAssessment)
        XCTAssertNotNil(workflowResult.recommendations)
        XCTAssertGreaterThan(workflowResult.confidenceScore, 0.8)
    }
    
    // MARK: - Helper Methods for Test Data
    
    private func createSampleTransactions() -> [AnalyticsTransaction] {
        return [
            AnalyticsTransaction(
                id: UUID(),
                amount: 1500.00,
                currency: .usd,
                date: Date().addingTimeInterval(-86400 * 30), // 30 days ago
                category: .business,
                description: "Monthly Salary",
                vendor: "Employer Inc",
                transactionType: .income
            ),
            AnalyticsTransaction(
                id: UUID(),
                amount: -250.00,
                currency: .usd,
                date: Date().addingTimeInterval(-86400 * 25),
                category: .groceries,
                description: "Weekly Groceries",
                vendor: "Grocery Store",
                transactionType: .expense
            ),
            AnalyticsTransaction(
                id: UUID(),
                amount: -75.50,
                currency: .usd,
                date: Date().addingTimeInterval(-86400 * 20),
                category: .utilities,
                description: "Electric Bill",
                vendor: "Power Company",
                transactionType: .expense
            )
        ]
    }
    
    private func createMultiMonthTransactions() -> [AnalyticsTransaction] {
        var transactions: [AnalyticsTransaction] = []
        let calendar = Calendar.current
        
        for month in 0..<6 {
            let monthDate = calendar.date(byAdding: .month, value: -month, to: Date()) ?? Date()
            
            transactions.append(AnalyticsTransaction(
                id: UUID(),
                amount: Double.random(in: 1000...2000),
                currency: .usd,
                date: monthDate,
                category: .business,
                description: "Monthly Salary",
                vendor: "Employer Inc",
                transactionType: .income
            ))
            
            // Add various expenses for each month
            let expenseCategories: [ExpenseCategory] = [.groceries, .utilities, .entertainment, .transportation]
            for category in expenseCategories {
                transactions.append(AnalyticsTransaction(
                    id: UUID(),
                    amount: -Double.random(in: 50...300),
                    currency: .usd,
                    date: monthDate,
                    category: category,
                    description: "Monthly \(category.rawValue)",
                    vendor: "\(category.rawValue) Vendor",
                    transactionType: .expense
                ))
            }
        }
        
        return transactions
    }
    
    private func createIncomeTransactions() -> [AnalyticsTransaction] {
        return [
            AnalyticsTransaction(
                id: UUID(),
                amount: 5000.00,
                currency: .usd,
                date: Date().addingTimeInterval(-86400 * 30),
                category: .business,
                description: "Primary Salary",
                vendor: "Tech Corp",
                transactionType: .income
            ),
            AnalyticsTransaction(
                id: UUID(),
                amount: 1200.00,
                currency: .usd,
                date: Date().addingTimeInterval(-86400 * 15),
                category: .consulting,
                description: "Freelance Project",
                vendor: "Client LLC",
                transactionType: .income
            )
        ]
    }
    
    private func createHistoricalExpenseData() -> [AnalyticsTransaction] {
        var transactions: [AnalyticsTransaction] = []
        
        for day in 1...365 {
            if day % 7 == 0 { // Weekly groceries
                transactions.append(AnalyticsTransaction(
                    id: UUID(),
                    amount: -Double.random(in: 80...150),
                    currency: .usd,
                    date: Date().addingTimeInterval(-86400 * Double(day)),
                    category: .groceries,
                    description: "Weekly Groceries",
                    vendor: "Supermarket",
                    transactionType: .expense
                ))
            }
        }
        
        return transactions
    }
    
    private func createCashFlowData() -> CashFlowData {
        return CashFlowData(
            monthlyIncome: 6000.00,
            monthlyExpenses: 4200.00,
            fixedExpenses: 2800.00,
            variableExpenses: 1400.00,
            historicalCashFlow: createMultiMonthTransactions()
        )
    }
    
    private func createSamplePortfolio() -> FinancialPortfolio {
        return FinancialPortfolio(
            id: UUID(),
            name: "Sample Portfolio",
            totalValue: 100000.00,
            holdings: [
                PortfolioHolding(symbol: "AAPL", shares: 100, currentPrice: 150.00),
                PortfolioHolding(symbol: "GOOGL", shares: 50, currentPrice: 120.00),
                PortfolioHolding(symbol: "MSFT", shares: 75, currentPrice: 300.00)
            ],
            currentReturn: 0.08,
            currentRisk: 0.15
        )
    }
    
    private func createRiskPortfolio() -> FinancialPortfolio {
        return FinancialPortfolio(
            id: UUID(),
            name: "High Risk Portfolio",
            totalValue: 50000.00,
            holdings: [
                PortfolioHolding(symbol: "TSLA", shares: 100, currentPrice: 200.00),
                PortfolioHolding(symbol: "NVDA", shares: 50, currentPrice: 400.00)
            ],
            currentReturn: 0.15,
            currentRisk: 0.35
        )
    }
    
    private func createVolatileFinancialData() -> [FinancialDataPoint] {
        var dataPoints: [FinancialDataPoint] = []
        
        for day in 1...365 {
            let volatility = sin(Double(day) * 0.1) * 0.3 + Double.random(in: -0.2...0.2)
            dataPoints.append(FinancialDataPoint(
                date: Date().addingTimeInterval(-86400 * Double(day)),
                value: 100.0 + volatility * 100.0
            ))
        }
        
        return dataPoints
    }
    
    private func createUnoptimizedPortfolio() -> FinancialPortfolio {
        return FinancialPortfolio(
            id: UUID(),
            name: "Unoptimized Portfolio",
            totalValue: 75000.00,
            holdings: [
                PortfolioHolding(symbol: "AAPL", shares: 200, currentPrice: 150.00), // Over-weighted
                PortfolioHolding(symbol: "BOND", shares: 10, currentPrice: 100.00)   // Under-weighted
            ],
            currentReturn: 0.06,
            currentRisk: 0.25
        )
    }
    
    private func createOptimizationConstraints() -> PortfolioOptimizationConstraints {
        return PortfolioOptimizationConstraints(
            maxSingleAssetWeight: 0.3,
            minSingleAssetWeight: 0.05,
            targetRisk: 0.15,
            minimumReturn: 0.08
        )
    }
    
    private func createUncategorizedTransactions() -> [AnalyticsTransaction] {
        return [
            AnalyticsTransaction(
                id: UUID(),
                amount: -45.99,
                currency: .usd,
                date: Date(),
                category: .other, // Uncategorized
                description: "AMZN*MARKETPLACE",
                vendor: "Amazon",
                transactionType: .expense
            ),
            AnalyticsTransaction(
                id: UUID(),
                amount: -89.50,
                currency: .usd,
                date: Date(),
                category: .other, // Uncategorized
                description: "SQ *COFFEE SHOP",
                vendor: "Square Payment",
                transactionType: .expense
            )
        ]
    }
    
    private func createTransactionsWithAnomalies() -> [AnalyticsTransaction] {
        var normal = createSampleTransactions()
        
        // Add anomalous transactions
        normal.append(AnalyticsTransaction(
            id: UUID(),
            amount: -15000.00, // Unusually large expense
            currency: .usd,
            date: Date(),
            category: .other,
            description: "Large Purchase",
            vendor: "Unknown Vendor",
            transactionType: .expense
        ))
        
        normal.append(AnalyticsTransaction(
            id: UUID(),
            amount: -250.00, // Duplicate transaction
            currency: .usd,
            date: Date().addingTimeInterval(-86400 * 25), // Same date as existing
            category: .groceries,
            description: "Weekly Groceries",
            vendor: "Grocery Store",
            transactionType: .expense
        ))
        
        return normal
    }
    
    private func createLargeFinancialDataset(transactionCount: Int) -> [AnalyticsTransaction] {
        var transactions: [AnalyticsTransaction] = []
        
        for i in 0..<transactionCount {
            transactions.append(AnalyticsTransaction(
                id: UUID(),
                amount: Double.random(in: -1000...2000),
                currency: .usd,
                date: Date().addingTimeInterval(-86400 * Double(i % 365)),
                category: ExpenseCategory.allCases.randomElement() ?? .other,
                description: "Transaction \(i)",
                vendor: "Vendor \(i % 100)",
                transactionType: Bool.random() ? .income : .expense
            ))
        }
        
        return transactions
    }
    
    private func createRawFinancialData() -> RawFinancialData {
        return RawFinancialData(
            documentText: """
            Invoice Date: 2025-06-01
            Amount: $1,250.00
            Vendor: Tech Solutions Inc
            Category: Office Equipment
            Description: Laptop purchase for business use
            """,
            metadata: [
                "source": "scanned_document",
                "confidence": "0.95",
                "document_type": "invoice"
            ]
        )
    }
}