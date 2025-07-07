//
// IntelligenceEngineTests.swift
// FinanceMateTests
//
// Comprehensive Intelligence Engine Test Suite
// Created: 2025-07-07
// Target: FinanceMateTests
//

/*
 * Purpose: Comprehensive test suite for IntelligenceEngine with AI-powered financial insights and optimization
 * Issues & Complexity Summary: Complex ML algorithms, predictive analytics, pattern recognition, automated insights
 * Key Complexity Drivers:
   - Logic Scope (Est. LoC): ~400
   - Core Algorithm Complexity: Very High
   - Dependencies: Core Data, UserDefaults, ML algorithms, pattern recognition, predictive analytics
   - State Management Complexity: Very High (intelligence state, learning models, prediction cache, insight generation)
   - Novelty/Uncertainty Factor: High (ML algorithms, predictive analytics, automated insights, pattern recognition)
 * AI Pre-Task Self-Assessment: 90%
 * Problem Estimate: 92%
 * Initial Code Complexity Estimate: 90%
 * Final Code Complexity: TBD
 * Overall Result Score: TBD
 * Key Variances/Learnings: TBD
 * Last Updated: 2025-07-07
 */

import XCTest
import SwiftUI
import CoreData
@testable import FinanceMate

@MainActor
class IntelligenceEngineTests: XCTestCase {
    
    var intelligenceEngine: IntelligenceEngine!
    var testContext: NSManagedObjectContext!
    var mockUserDefaults: UserDefaults!
    
    override func setUp() async throws {
        try await super.setUp()
        
        // Create isolated UserDefaults for testing
        mockUserDefaults = UserDefaults(suiteName: "IntelligenceEngineTests")!
        mockUserDefaults.removePersistentDomain(forName: "IntelligenceEngineTests")
        
        // Initialize test Core Data context
        testContext = PersistenceController.preview.container.viewContext
        
        // Initialize intelligence engine
        intelligenceEngine = IntelligenceEngine(context: testContext, userDefaults: mockUserDefaults)
        
        // Create sample data for testing
        await createSampleTransactionData()
    }
    
    override func tearDown() async throws {
        // Clean up UserDefaults
        mockUserDefaults.removePersistentDomain(forName: "IntelligenceEngineTests")
        
        // Clear test data
        await clearTestData()
        
        intelligenceEngine = nil
        testContext = nil
        mockUserDefaults = nil
        try await super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testIntelligenceEngineInitialization() {
        XCTAssertNotNil(intelligenceEngine, "IntelligenceEngine should initialize successfully")
        XCTAssertFalse(intelligenceEngine.isLearningEnabled, "Learning should be disabled initially")
        XCTAssertTrue(intelligenceEngine.availableInsights.isEmpty, "No insights should be available initially")
    }
    
    func testMLModelInitialization() async throws {
        await intelligenceEngine.initializeMLModels()
        
        let isInitialized = intelligenceEngine.areMLModelsInitialized()
        XCTAssertTrue(isInitialized, "ML models should initialize successfully")
    }
    
    func testIntelligenceCapabilities() {
        let capabilities = intelligenceEngine.getIntelligenceCapabilities()
        XCTAssertGreaterThan(capabilities.count, 5, "Should have multiple intelligence capabilities")
        
        // Verify core capabilities exist
        XCTAssertTrue(capabilities.contains(.expensePatternRecognition), "Should include expense pattern recognition")
        XCTAssertTrue(capabilities.contains(.smartCategorization), "Should include smart categorization")
        XCTAssertTrue(capabilities.contains(.predictiveAnalytics), "Should include predictive analytics")
        XCTAssertTrue(capabilities.contains(.anomalyDetection), "Should include anomaly detection")
        XCTAssertTrue(capabilities.contains(.insightGeneration), "Should include insight generation")
    }
    
    // MARK: - Pattern Recognition Tests
    
    func testExpensePatternRecognition() async throws {
        await intelligenceEngine.enableLearning()
        
        // Train with transaction patterns
        await intelligenceEngine.trainPatternRecognition()
        
        let patterns = await intelligenceEngine.recognizeExpensePatterns()
        XCTAssertGreaterThan(patterns.count, 0, "Should recognize expense patterns")
        
        // Verify pattern quality
        let businessPattern = patterns.first { $0.category == "Business" }
        XCTAssertNotNil(businessPattern, "Should recognize business expense patterns")
        XCTAssertGreaterThan(businessPattern!.confidence, 0.5, "Pattern confidence should be reasonable")
    }
    
    func testSeasonalPatternAnalysis() async throws {
        let seasonalPatterns = await intelligenceEngine.analyzeSeasonalPatterns()
        XCTAssertNotNil(seasonalPatterns, "Should provide seasonal pattern analysis")
        XCTAssertGreaterThan(seasonalPatterns!.patterns.count, 0, "Should identify seasonal patterns")
        
        // Test quarterly patterns
        let quarterlyAnalysis = await intelligenceEngine.analyzeQuarterlySpendingPatterns()
        XCTAssertNotNil(quarterlyAnalysis, "Should provide quarterly analysis")
        XCTAssertEqual(quarterlyAnalysis!.quarters.count, 4, "Should analyze all quarters")
    }
    
    func testRecurringTransactionDetection() async throws {
        let recurringTransactions = await intelligenceEngine.detectRecurringTransactions()
        XCTAssertGreaterThan(recurringTransactions.count, 0, "Should detect recurring transactions")
        
        let subscription = recurringTransactions.first { $0.type == .subscription }
        XCTAssertNotNil(subscription, "Should detect subscription-type recurring transactions")
        XCTAssertGreaterThan(subscription!.confidence, 0.7, "Recurring transaction confidence should be high")
    }
    
    func testSpendingHabitsAnalysis() async throws {
        let spendingHabits = await intelligenceEngine.analyzeSpendingHabits()
        XCTAssertNotNil(spendingHabits, "Should analyze spending habits")
        XCTAssertGreaterThan(spendingHabits!.habits.count, 0, "Should identify spending habits")
        
        // Verify habit analysis quality
        let topHabit = spendingHabits!.habits.first!
        XCTAssertGreaterThan(topHabit.frequency, 0.0, "Top habit should have valid frequency")
        XCTAssertFalse(topHabit.description.isEmpty, "Habit should have description")
    }
    
    // MARK: - Smart Categorization Tests
    
    func testAutomaticCategorization() async throws {
        await intelligenceEngine.enableLearning()
        await intelligenceEngine.trainCategorizationModel()
        
        // Test categorization with sample transaction
        let testTransaction = TransactionData(
            amount: 85.50,
            category: "", // Empty category for testing
            date: Date(),
            note: "Lunch at restaurant with clients"
        )
        
        let suggestedCategory = await intelligenceEngine.suggestCategory(for: testTransaction)
        XCTAssertNotNil(suggestedCategory, "Should suggest a category")
        XCTAssertEqual(suggestedCategory!.category, "Business", "Should categorize business meal correctly")
        XCTAssertGreaterThan(suggestedCategory!.confidence, 0.6, "Categorization confidence should be reasonable")
    }
    
    func testCategoryConfidenceScoring() async throws {
        let testTransactions = [
            TransactionData(amount: 500.0, category: "", date: Date(), note: "Office supplies for work"),
            TransactionData(amount: 25.0, category: "", date: Date(), note: "Coffee"),
            TransactionData(amount: 1200.0, category: "", date: Date(), note: "Rent payment")
        ]
        
        for transaction in testTransactions {
            let suggestion = await intelligenceEngine.suggestCategory(for: transaction)
            XCTAssertNotNil(suggestion, "Should provide category suggestion")
            XCTAssertGreaterThan(suggestion!.confidence, 0.0, "Should have valid confidence score")
            XCTAssertLessThanOrEqual(suggestion!.confidence, 1.0, "Confidence should not exceed 1.0")
        }
    }
    
    func testSmartSplitSuggestions() async throws {
        let mixedTransaction = TransactionData(
            amount: 200.0,
            category: "",
            date: Date(),
            note: "Dinner with clients and groceries"
        )
        
        let splitSuggestions = await intelligenceEngine.suggestSplitAllocation(for: mixedTransaction)
        XCTAssertGreaterThan(splitSuggestions.count, 1, "Should suggest multiple split allocations")
        
        let totalPercentage = splitSuggestions.reduce(0.0) { $0 + $1.percentage }
        XCTAssertEqual(totalPercentage, 1.0, accuracy: 0.01, "Split percentages should sum to 100%")
    }
    
    func testContextualCategorization() async throws {
        // Test with time-based context
        let workHoursTransaction = TransactionData(
            amount: 12.50,
            category: "",
            date: createDate(hour: 12), // Lunch time
            note: "Sandwich"
        )
        
        let suggestion = await intelligenceEngine.suggestCategoryWithContext(for: workHoursTransaction)
        XCTAssertNotNil(suggestion, "Should provide contextual suggestion")
        XCTAssertTrue(suggestion!.reasoningFactors.contains(.timeOfDay), "Should consider time of day")
    }
    
    // MARK: - Predictive Analytics Tests
    
    func testCashFlowPrediction() async throws {
        await intelligenceEngine.enablePredictiveAnalytics()
        
        let cashFlowPrediction = await intelligenceEngine.predictCashFlow(months: 3)
        XCTAssertNotNil(cashFlowPrediction, "Should provide cash flow prediction")
        XCTAssertEqual(cashFlowPrediction!.predictions.count, 3, "Should predict for 3 months")
        
        for prediction in cashFlowPrediction!.predictions {
            XCTAssertGreaterThan(prediction.confidence, 0.0, "Prediction confidence should be positive")
            XCTAssertNotNil(prediction.expectedIncome, "Should predict income")
            XCTAssertNotNil(prediction.expectedExpenses, "Should predict expenses")
        }
    }
    
    func testBudgetOptimizationSuggestions() async throws {
        let optimizationSuggestions = await intelligenceEngine.generateBudgetOptimizations()
        XCTAssertGreaterThan(optimizationSuggestions.count, 0, "Should provide optimization suggestions")
        
        let topSuggestion = optimizationSuggestions.first!
        XCTAssertGreaterThan(topSuggestion.potentialSavings, 0.0, "Should suggest positive savings")
        XCTAssertGreaterThan(topSuggestion.feasibilityScore, 0.0, "Should have feasibility score")
        XCTAssertFalse(topSuggestion.description.isEmpty, "Should have description")
    }
    
    func testExpenseProjections() async throws {
        let projections = await intelligenceEngine.projectExpenses(category: "Business", months: 6)
        XCTAssertNotNil(projections, "Should provide expense projections")
        XCTAssertEqual(projections!.monthlyProjections.count, 6, "Should project for 6 months")
        
        for projection in projections!.monthlyProjections {
            XCTAssertGreaterThan(projection.expectedAmount, 0.0, "Projected amount should be positive")
            XCTAssertGreaterThan(projection.confidence, 0.0, "Projection confidence should be positive")
        }
    }
    
    func testTaxOptimizationRecommendations() async throws {
        let taxRecommendations = await intelligenceEngine.generateTaxOptimizationRecommendations()
        XCTAssertGreaterThan(taxRecommendations.count, 0, "Should provide tax optimization recommendations")
        
        let gstRecommendation = taxRecommendations.first { $0.type == .gstOptimization }
        XCTAssertNotNil(gstRecommendation, "Should include GST optimization recommendations")
        XCTAssertTrue(gstRecommendation!.isAustralianCompliant, "Should be Australian tax compliant")
    }
    
    // MARK: - Anomaly Detection Tests
    
    func testUnusualSpendingDetection() async throws {
        await intelligenceEngine.enableAnomalyDetection()
        
        // Create unusual transaction
        let unusualTransaction = TransactionData(
            amount: 5000.0, // Unusually high amount
            category: "Personal",
            date: Date(),
            note: "Large purchase"
        )
        
        let isAnomaly = await intelligenceEngine.detectAnomaly(transaction: unusualTransaction)
        XCTAssertTrue(isAnomaly, "Should detect unusually high spending as anomaly")
        
        let anomalyDetails = await intelligenceEngine.analyzeAnomaly(transaction: unusualTransaction)
        XCTAssertNotNil(anomalyDetails, "Should provide anomaly analysis")
        XCTAssertGreaterThan(anomalyDetails!.severityScore, 0.7, "High amount should have high severity")
    }
    
    func testFraudDetection() async throws {
        let suspiciousTransactions = [
            TransactionData(amount: 1.0, category: "Personal", date: Date(), note: "Test transaction"),
            TransactionData(amount: 1.0, category: "Personal", date: Date(), note: "Test transaction"),
            TransactionData(amount: 1.0, category: "Personal", date: Date(), note: "Test transaction")
        ]
        
        for transaction in suspiciousTransactions {
            let fraudRisk = await intelligenceEngine.assessFraudRisk(transaction: transaction)
            XCTAssertNotNil(fraudRisk, "Should assess fraud risk")
            XCTAssertGreaterThanOrEqual(fraudRisk!.riskScore, 0.0, "Risk score should be non-negative")
            XCTAssertLessThanOrEqual(fraudRisk!.riskScore, 1.0, "Risk score should not exceed 1.0")
        }
    }
    
    func testBehaviorDeviationAnalysis() async throws {
        let deviationAnalysis = await intelligenceEngine.analyzeBehaviorDeviations()
        XCTAssertNotNil(deviationAnalysis, "Should provide behavior deviation analysis")
        XCTAssertGreaterThanOrEqual(deviationAnalysis!.deviations.count, 0, "Should analyze behavior deviations")
        
        if !deviationAnalysis!.deviations.isEmpty {
            let deviation = deviationAnalysis!.deviations.first!
            XCTAssertGreaterThan(deviation.significanceScore, 0.0, "Deviation should have significance score")
            XCTAssertFalse(deviation.description.isEmpty, "Deviation should have description")
        }
    }
    
    // MARK: - Insight Generation Tests
    
    func testAutomatedInsightGeneration() async throws {
        await intelligenceEngine.enableInsightGeneration()
        
        let insights = await intelligenceEngine.generateFinancialInsights()
        XCTAssertGreaterThan(insights.count, 0, "Should generate financial insights")
        
        for insight in insights {
            XCTAssertGreaterThan(insight.relevanceScore, 0.0, "Insight should have relevance score")
            XCTAssertFalse(insight.title.isEmpty, "Insight should have title")
            XCTAssertFalse(insight.description.isEmpty, "Insight should have description")
            XCTAssertNotNil(insight.actionableRecommendation, "Insight should have actionable recommendation")
        }
    }
    
    func testPersonalizedInsights() async throws {
        // Set user profile for personalization
        await intelligenceEngine.setUserProfile(UserProfile(
            segment: .businessOwner,
            industry: .consulting,
            experienceLevel: .intermediate
        ))
        
        let personalizedInsights = await intelligenceEngine.generatePersonalizedInsights()
        XCTAssertGreaterThan(personalizedInsights.count, 0, "Should generate personalized insights")
        
        let businessInsight = personalizedInsights.first { $0.category == .businessOptimization }
        XCTAssertNotNil(businessInsight, "Should include business optimization insights")
        XCTAssertTrue(businessInsight!.isPersonalized, "Insight should be personalized")
    }
    
    func testTrendAnalysisInsights() async throws {
        let trendInsights = await intelligenceEngine.generateTrendInsights()
        XCTAssertGreaterThan(trendInsights.count, 0, "Should generate trend insights")
        
        for insight in trendInsights {
            XCTAssertTrue(insight.timeframe != .unknown, "Trend insight should have defined timeframe")
            XCTAssertGreaterThan(insight.dataPoints.count, 2, "Trend should have multiple data points")
        }
    }
    
    func testActionableRecommendations() async throws {
        let recommendations = await intelligenceEngine.generateActionableRecommendations()
        XCTAssertGreaterThan(recommendations.count, 0, "Should generate actionable recommendations")
        
        for recommendation in recommendations {
            XCTAssertGreaterThan(recommendation.priority, 0, "Recommendation should have priority")
            XCTAssertGreaterThan(recommendation.estimatedImpact, 0.0, "Should have estimated impact")
            XCTAssertFalse(recommendation.actionSteps.isEmpty, "Should have action steps")
        }
    }
    
    // MARK: - Learning and Adaptation Tests
    
    func testContinuousLearning() async throws {
        await intelligenceEngine.enableContinuousLearning()
        
        // Simulate user feedback
        let feedback = UserFeedback(
            type: .categoryCorrection,
            originalPrediction: "Personal",
            correctedValue: "Business",
            confidence: 0.9
        )
        
        await intelligenceEngine.incorporateFeedback(feedback)
        
        let learningMetrics = intelligenceEngine.getLearningMetrics()
        XCTAssertGreaterThan(learningMetrics.feedbackCount, 0, "Should track feedback count")
        XCTAssertGreaterThan(learningMetrics.accuracyImprovement, 0.0, "Should show accuracy improvement")
    }
    
    func testModelPerformanceTracking() async throws {
        let performanceMetrics = await intelligenceEngine.getModelPerformanceMetrics()
        XCTAssertNotNil(performanceMetrics, "Should provide performance metrics")
        
        for metric in performanceMetrics!.metrics {
            XCTAssertGreaterThan(metric.accuracy, 0.0, "Model accuracy should be positive")
            XCTAssertLessThanOrEqual(metric.accuracy, 1.0, "Model accuracy should not exceed 1.0")
            XCTAssertFalse(metric.modelName.isEmpty, "Should have model name")
        }
    }
    
    func testAdaptiveModelUpdates() async throws {
        let initialAccuracy = await intelligenceEngine.getCategorizationAccuracy()
        
        // Simulate training with new data
        await intelligenceEngine.performAdaptiveModelUpdate()
        
        let updatedAccuracy = await intelligenceEngine.getCategorizationAccuracy()
        XCTAssertGreaterThanOrEqual(updatedAccuracy, initialAccuracy, "Accuracy should not decrease after updates")
    }
    
    // MARK: - Performance and Optimization Tests
    
    func testIntelligenceEnginePerformance() async throws {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // Generate multiple insights quickly
        let insights = await intelligenceEngine.generateFinancialInsights()
        let patterns = await intelligenceEngine.recognizeExpensePatterns()
        let predictions = await intelligenceEngine.predictCashFlow(months: 1)
        
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        XCTAssertLessThan(timeElapsed, 3.0, "Intelligence operations should be performant")
        
        // Verify results quality
        XCTAssertGreaterThan(insights.count, 0, "Should generate insights")
        XCTAssertGreaterThan(patterns.count, 0, "Should recognize patterns")
        XCTAssertNotNil(predictions, "Should provide predictions")
    }
    
    func testMemoryOptimization() async throws {
        // Test with large dataset
        await createLargeTestDataset(transactionCount: 100)
        
        let initialMemory = getCurrentMemoryUsage()
        
        // Perform intensive intelligence operations
        await intelligenceEngine.trainPatternRecognition()
        await intelligenceEngine.generateFinancialInsights()
        
        let finalMemory = getCurrentMemoryUsage()
        let memoryIncrease = finalMemory - initialMemory
        
        XCTAssertLessThan(memoryIncrease, 100_000_000, "Memory usage should be reasonable") // 100MB limit
    }
    
    func testCacheEfficiency() async throws {
        // First request - should be slow
        let start1 = CFAbsoluteTimeGetCurrent()
        let insights1 = await intelligenceEngine.generateFinancialInsights()
        let time1 = CFAbsoluteTimeGetCurrent() - start1
        
        // Second request - should be faster (cached)
        let start2 = CFAbsoluteTimeGetCurrent()
        let insights2 = await intelligenceEngine.generateFinancialInsights()
        let time2 = CFAbsoluteTimeGetCurrent() - start2
        
        XCTAssertLessThan(time2, time1, "Cached requests should be faster")
        XCTAssertEqual(insights1.count, insights2.count, "Cached results should match")
    }
    
    // MARK: - Error Handling and Edge Cases Tests
    
    func testIntelligenceEngineWithNoData() async throws {
        // Clear all test data
        await clearTestData()
        
        let insights = await intelligenceEngine.generateFinancialInsights()
        XCTAssertTrue(insights.isEmpty, "Should handle empty data gracefully")
        
        let patterns = await intelligenceEngine.recognizeExpensePatterns()
        XCTAssertTrue(patterns.isEmpty, "Should handle empty data for pattern recognition")
    }
    
    func testIntelligenceEngineWithCorruptedData() async throws {
        // Test with corrupted user preferences
        mockUserDefaults.set("invalid_data", forKey: "intelligencePreferences")
        
        let engineWithCorruptedData = IntelligenceEngine(context: testContext, userDefaults: mockUserDefaults)
        
        XCTAssertNotNil(engineWithCorruptedData, "Should handle corrupted data gracefully")
        XCTAssertFalse(engineWithCorruptedData.isLearningEnabled, "Should start with default state")
    }
    
    func testConcurrentIntelligenceOperations() async throws {
        await intelligenceEngine.enableLearning()
        
        // Test concurrent intelligence requests
        await withTaskGroup(of: Void.self) { group in
            for i in 1...5 {
                group.addTask {
                    let _ = await self.intelligenceEngine.generateFinancialInsights()
                    let _ = await self.intelligenceEngine.recognizeExpensePatterns()
                }
            }
        }
        
        // Verify engine remains stable
        XCTAssertTrue(intelligenceEngine.isLearningEnabled, "Intelligence engine should remain stable after concurrent access")
    }
    
    // MARK: - Helper Methods
    
    private func createSampleTransactionData() async {
        let sampleTransactions = [
            ("Office supplies", 250.0, "Business"),
            ("Lunch with team", 85.50, "Business"),
            ("Groceries", 120.0, "Personal"),
            ("Gas station", 60.0, "Personal"),
            ("Software subscription", 29.99, "Business"),
            ("Dinner out", 75.0, "Personal"),
            ("Client dinner", 150.0, "Business"),
            ("Gym membership", 45.0, "Personal")
        ]
        
        for (note, amount, category) in sampleTransactions {
            let transaction = Transaction(context: testContext)
            transaction.id = UUID()
            transaction.amount = amount
            transaction.note = note
            transaction.category = category
            transaction.date = Date().addingTimeInterval(-Double.random(in: 0...2592000)) // Random date within last 30 days
            transaction.createdAt = Date()
        }
        
        try? testContext.save()
    }
    
    private func createLargeTestDataset(transactionCount: Int) async {
        let categories = ["Business", "Personal", "Investment"]
        let notes = ["Purchase", "Payment", "Expense", "Income", "Transfer"]
        
        for i in 0..<transactionCount {
            let transaction = Transaction(context: testContext)
            transaction.id = UUID()
            transaction.amount = Double.random(in: 10...1000)
            transaction.note = notes.randomElement()! + " \(i)"
            transaction.category = categories.randomElement()!
            transaction.date = Date().addingTimeInterval(-Double(i * 86400)) // One transaction per day
            transaction.createdAt = Date()
        }
        
        try? testContext.save()
    }
    
    private func clearTestData() async {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Transaction.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        try? testContext.execute(deleteRequest)
        try? testContext.save()
    }
    
    private func createDate(hour: Int) -> Date {
        let calendar = Calendar.current
        let components = DateComponents(hour: hour)
        return calendar.date(byAdding: components, to: Date()) ?? Date()
    }
    
    private func getCurrentMemoryUsage() -> Int {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            return Int(info.resident_size)
        } else {
            return 0
        }
    }
}