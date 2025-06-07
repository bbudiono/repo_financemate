
//
//  RealTimeFinancialInsightsEngineTests.swift
//  FinanceMateTests
//
//  Created by Assistant on 6/7/25.
//

/*
* Purpose: TDD test suite for real-time financial insights engine - NO MOCK DATA
* Tests REAL functionality that TestFlight users will interact with
* Validates intelligent financial analysis, spending patterns, and insights generation
*/

import XCTest
import CoreData
@testable import FinanceMate_Sandbox

final class RealTimeFinancialInsightsEngineTests: XCTestCase {
    
    var insightsEngine: RealTimeFinancialInsightsEngine!
    var coreDataStack: CoreDataStack!
    var testContext: NSManagedObjectContext!
    
    override func setUpWithError() throws {
        coreDataStack = CoreDataStack.shared
        testContext = coreDataStack.mainContext
        insightsEngine = RealTimeFinancialInsightsEngine(context: testContext)
        
        // Clear any existing test data
        clearTestData()
    }
    
    override func tearDownWithError() throws {
        clearTestData()
        insightsEngine = nil
        testContext = nil
    }
    
    // MARK: - Engine Initialization Tests
    
    func testFinancialInsightsEngineInitialization() throws {
        XCTAssertNotNil(insightsEngine, "Financial insights engine should initialize")
        XCTAssertNotNil(insightsEngine.context, "Engine should have Core Data context")
        XCTAssertTrue(insightsEngine.isReady, "Engine should be ready for analysis")
    }
    
    // MARK: - Real Data Analysis Tests - NO MOCK DATA
    
    func testAnalyzeRealFinancialDataGeneratesInsights() throws {
        // Create REAL financial data in Core Data
        let testData = createRealTestFinancialData()
        
        // Test real-time analysis
        let insights = try insightsEngine.generateRealTimeInsights()
        
        XCTAssertNotNil(insights, "Should generate insights from real data")
        XCTAssertFalse(insights.isEmpty, "Should have at least one insight")
        
        // Verify insights contain real calculations
        let spendingInsight = insights.first { $0.type == .spendingPattern }
        XCTAssertNotNil(spendingInsight, "Should have spending pattern insight")
        XCTAssertGreaterThan(spendingInsight?.confidence ?? 0, 0.5, "Should have confident analysis")
    }
    
    func testSpendingTrendAnalysisWithRealData() throws {
        // Create real spending data over multiple months
        createRealSpendingTrendData()
        
        let trendAnalysis = try insightsEngine.analyzeSpendingTrends()
        
        XCTAssertNotNil(trendAnalysis, "Should analyze real spending trends")
        XCTAssertNotEqual(trendAnalysis.monthlyTrend, .noData, "Should detect actual trends")
        XCTAssertGreaterThan(trendAnalysis.projectedNextMonth, 0, "Should project realistic spending")
    }
    
    func testIncomeAnalysisWithRealData() throws {
        // Create real income data
        createRealIncomeData()
        
        let incomeAnalysis = try insightsEngine.analyzeIncomePatterns()
        
        XCTAssertNotNil(incomeAnalysis, "Should analyze real income patterns")
        XCTAssertGreaterThan(incomeAnalysis.averageMonthlyIncome, 0, "Should calculate real average")
        XCTAssertNotNil(incomeAnalysis.stabilityScore, "Should assess income stability")
    }
    
    // MARK: - Category Analysis Tests
    
    func testExpenseCategoryAnalysisReal() throws {
        // Create real categorized expenses
        createRealCategorizedExpenses()
        
        let categoryAnalysis = try insightsEngine.analyzeCategorySpending()
        
        XCTAssertFalse(categoryAnalysis.isEmpty, "Should analyze real categories")
        
        // Verify real category calculations
        let topCategory = categoryAnalysis.first
        XCTAssertNotNil(topCategory, "Should identify top spending category")
        XCTAssertGreaterThan(topCategory?.totalAmount ?? 0, 0, "Should have real spending amount")
        XCTAssertGreaterThan(topCategory?.percentageOfTotal ?? 0, 0, "Should calculate real percentage")
    }
    
    func testAnomalyDetectionWithRealTransactions() throws {
        // Create real transaction data with one anomaly
        createRealTransactionDataWithAnomaly()
        
        let anomalies = try insightsEngine.detectSpendingAnomalies()
        
        XCTAssertFalse(anomalies.isEmpty, "Should detect real anomalies")
        
        let anomaly = anomalies.first
        XCTAssertNotNil(anomaly, "Should find the anomalous transaction")
        XCTAssertGreaterThan(anomaly?.deviationScore ?? 0, 2.0, "Should flag significant deviation")
    }
    
    // MARK: - Predictive Analytics Tests
    
    func testBudgetRecommendationsBasedOnRealData() throws {
        // Create 3 months of real spending data
        createRealMultiMonthSpendingData()
        
        let recommendations = try insightsEngine.generateBudgetRecommendations()
        
        XCTAssertFalse(recommendations.isEmpty, "Should generate real budget recommendations")
        
        let recommendation = recommendations.first
        XCTAssertNotNil(recommendation, "Should have at least one recommendation")
        XCTAssertGreaterThan(recommendation?.suggestedAmount ?? 0, 0, "Should suggest realistic amount")
        XCTAssertFalse(recommendation?.category.isEmpty ?? true, "Should specify category")
    }
    
    func testGoalProgressTrackingWithRealData() throws {
        // Create real financial goal
        let goal = createRealFinancialGoal()
        
        let progress = try insightsEngine.trackGoalProgress(goalId: goal.id!)
        
        XCTAssertNotNil(progress, "Should track real goal progress")
        XCTAssertGreaterThanOrEqual(progress.completionPercentage, 0, "Should calculate real progress")
        XCTAssertLessThanOrEqual(progress.completionPercentage, 100, "Progress should be realistic")
    }
    
    // MARK: - Performance Tests for Real-Time Analysis
    
    func testRealTimeAnalysisPerformance() throws {
        // Create substantial real data set
        createLargeRealDataSet()
        
        measure {
            do {
                let insights = try insightsEngine.generateRealTimeInsights()
                XCTAssertFalse(insights.isEmpty, "Should generate insights quickly")
            } catch {
                XCTFail("Real-time analysis should not fail: \(error)")
            }
        }
    }
    
    func testConcurrentAnalysisStability() throws {
        createRealTestFinancialData()
        
        let expectation = XCTestExpectation(description: "Concurrent analysis complete")
        expectation.expectedFulfillmentCount = 3
        
        // Test concurrent analysis requests
        for i in 1...3 {
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let insights = try self.insightsEngine.generateRealTimeInsights()
                    XCTAssertFalse(insights.isEmpty, "Concurrent analysis \(i) should succeed")
                    expectation.fulfill()
                } catch {
                    XCTFail("Concurrent analysis \(i) failed: \(error)")
                }
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - Integration Tests with Core Data
    
    func testInsightsUpdateWhenDataChanges() throws {
        // Initial state
        let initialInsights = try insightsEngine.generateRealTimeInsights()
        
        // Add new real transaction
        createRealTestFinancialData()
        
        // Get updated insights
        let updatedInsights = try insightsEngine.generateRealTimeInsights()
        
        // Should reflect new data
        XCTAssertNotEqual(initialInsights.count, updatedInsights.count, "Insights should update with new data")
    }
    
    func testMemoryManagementWithLargeDataSet() throws {
        // Create large dataset and analyze multiple times
        createLargeRealDataSet()
        
        for _ in 1...10 {
            let insights = try insightsEngine.generateRealTimeInsights()
            XCTAssertFalse(insights.isEmpty, "Should handle large datasets efficiently")
        }
        
        // Engine should still be responsive
        XCTAssertTrue(insightsEngine.isReady, "Engine should remain ready after processing")
    }
    
    // MARK: - Error Handling Tests
    
    func testHandlesEmptyDataGracefully() throws {
        // No financial data in Core Data
        let insights = try insightsEngine.generateRealTimeInsights()
        
        // Should handle gracefully, not crash
        XCTAssertNotNil(insights, "Should handle empty data gracefully")
        // May be empty but should not fail
    }
    
    func testHandlesCorruptedDataGracefully() throws {
        // Create data with missing required fields
        createCorruptedTestData()
        
        let insights = try insightsEngine.generateRealTimeInsights()
        
        XCTAssertNotNil(insights, "Should handle corrupted data gracefully")
        // Should filter out invalid data, not crash
    }
    
    // MARK: - Helper Methods for Creating REAL Test Data
    
    private func createRealTestFinancialData() -> [FinancialData] {
        var data: [FinancialData] = []
        
        // Create realistic financial transactions
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
        
        // 3 months of realistic spending data
        for monthOffset in 0...2 {
            let month = calendar.date(byAdding: .month, value: -monthOffset, to: Date())!
            
            // Simulate realistic monthly spending pattern
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
    
    private func createRealIncomeData() {
        let calendar = Calendar.current
        
        // 6 months of realistic income data
        for monthOffset in 0...5 {
            let month = calendar.date(byAdding: .month, value: -monthOffset, to: Date())!
            
            let financial = FinancialData(context: testContext)
            financial.id = UUID()
            financial.vendorName = "Employer Inc"
            financial.totalAmount = NSDecimalNumber(value: 4200.0)
            financial.invoiceDate = month
            financial.currency = "USD"
            financial.category = "Salary"
            financial.extractionConfidence = 1.0
        }
        
        try! testContext.save()
    }
    
    private func createRealCategorizedExpenses() {
        let categories = [
            ("Food", [-45.0, -85.0, -32.0, -67.0]),
            ("Transportation", [-60.0, -45.0, -30.0]),
            ("Utilities", [-120.0, -115.0, -125.0]),
            ("Entertainment", [-25.0, -40.0, -55.0, -35.0])
        ]
        
        for (category, amounts) in categories {
            for amount in amounts {
                let financial = FinancialData(context: testContext)
                financial.id = UUID()
                financial.vendorName = "\(category) Vendor"
                financial.totalAmount = NSDecimalNumber(value: amount)
                financial.invoiceDate = Date()
                financial.currency = "USD"
                financial.category = category
                financial.extractionConfidence = 0.9
            }
        }
        
        try! testContext.save()
    }
    
    private func createRealTransactionDataWithAnomaly() {
        // Normal transactions
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
        
        // Anomalous transaction
        let anomaly = FinancialData(context: testContext)
        anomaly.id = UUID()
        anomaly.vendorName = "Luxury Purchase"
        anomaly.totalAmount = NSDecimalNumber(value: -2500.0) // Much higher than normal
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
        // Create 1000 realistic transactions
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
    
    private func createCorruptedTestData() {
        // Create data with missing required fields
        let financial = FinancialData(context: testContext)
        financial.id = UUID()
        // Missing vendorName, totalAmount, etc.
        financial.invoiceDate = Date()
        
        try! testContext.save()
    }
    
    private func clearTestData() {
        // Clear FinancialData
        let financialRequest: NSFetchRequest<NSFetchRequestResult> = FinancialData.fetchRequest()
        let financialDeleteRequest = NSBatchDeleteRequest(fetchRequest: financialRequest)
        try? testContext.execute(financialDeleteRequest)
        
        // Clear FinancialGoal
        let goalRequest: NSFetchRequest<NSFetchRequestResult> = FinancialGoal.fetchRequest()
        let goalDeleteRequest = NSBatchDeleteRequest(fetchRequest: goalRequest)
        try? testContext.execute(goalDeleteRequest)
        
        try? testContext.save()
    }
}