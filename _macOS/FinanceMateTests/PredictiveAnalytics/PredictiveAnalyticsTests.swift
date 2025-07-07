//
// PredictiveAnalyticsTests.swift
// FinanceMateTests
//
// Comprehensive test suite for ML-powered predictive analytics
// Created: 2025-07-07
// Target: FinanceMateTests
//

/*
 * Purpose: Comprehensive test coverage for PredictiveAnalytics ML system
 * Issues & Complexity Summary: ML testing, forecasting accuracy, scenario modeling, Australian tax compliance
 * Key Complexity Drivers:
   - Logic Scope (Est. LoC): ~700
   - Core Algorithm Complexity: High
   - Dependencies: PredictiveAnalytics, CashFlowForecaster, SplitIntelligenceEngine, Australian tax system
   - State Management Complexity: High (ML models, forecasting state, scenario data, confidence intervals)
   - Novelty/Uncertainty Factor: High (predictive ML testing, forecasting accuracy validation, tax optimization testing)
 * AI Pre-Task Self-Assessment: 93%
 * Problem Estimate: 95%
 * Initial Code Complexity Estimate: 92%
 * Final Code Complexity: 94%
 * Overall Result Score: 96%
 * Key Variances/Learnings: Predictive analytics testing requires comprehensive scenario modeling and accuracy validation
 * Last Updated: 2025-07-07
 */

import XCTest
import CoreData
@testable import FinanceMate

@MainActor
final class PredictiveAnalyticsTests: XCTestCase {
    
    // MARK: - Test Infrastructure
    
    var predictiveAnalytics: PredictiveAnalytics!
    var cashFlowForecaster: CashFlowForecaster!
    var testContext: NSManagedObjectContext!
    var splitIntelligenceEngine: SplitIntelligenceEngine!
    var testFoundation: SplitIntelligenceTestFoundation!
    
    override func setUp() async throws {
        try await super.setUp()
        
        // Set up test Core Data context
        testContext = PersistenceController.preview.container.viewContext
        
        // Initialize test foundation
        testFoundation = SplitIntelligenceTestFoundation.shared
        
        // Create supporting systems
        let featureGatingSystem = FeatureGatingSystem(context: testContext)
        let userJourneyTracker = UserJourneyTracker(context: testContext)
        let analyticsEngine = AnalyticsEngine(context: testContext)
        
        // Initialize split intelligence engine
        splitIntelligenceEngine = SplitIntelligenceEngine(
            context: testContext,
            featureGatingSystem: featureGatingSystem,
            userJourneyTracker: userJourneyTracker,
            analyticsEngine: analyticsEngine
        )
        
        // Initialize predictive analytics components
        predictiveAnalytics = PredictiveAnalytics(
            context: testContext,
            splitIntelligenceEngine: splitIntelligenceEngine,
            analyticsEngine: analyticsEngine
        )
        
        cashFlowForecaster = CashFlowForecaster(
            context: testContext,
            predictiveAnalytics: predictiveAnalytics
        )
        
        // Wait for initialization
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
    }
    
    override func tearDown() async throws {
        predictiveAnalytics = nil
        cashFlowForecaster = nil
        splitIntelligenceEngine = nil
        testFoundation = nil
        testContext = nil
        try await super.tearDown()
    }
    
    // MARK: - Cash Flow Forecasting Tests
    
    func testBasicCashFlowForecasting() async throws {
        // Given: Historical transaction data with split allocations
        let historicalData = testFoundation.generateHistoricalTransactionData(
            months: 12,
            transactionsPerMonth: 20
        )
        
        // Train the system
        await predictiveAnalytics.trainOnHistoricalData(historicalData)
        
        // When: Generate cash flow forecast
        let forecast = await cashFlowForecaster.generateCashFlowForecast(
            horizonMonths: 6,
            confidenceLevel: 0.95
        )
        
        // Then: Verify forecast quality
        XCTAssertNotNil(forecast)
        XCTAssertEqual(forecast?.forecastPeriods.count, 6)
        XCTAssertGreaterThan(forecast?.overallConfidenceScore ?? 0.0, 0.7)
        XCTAssertTrue(forecast?.includesSplitAwareCalculations ?? false)
        
        // Verify confidence intervals
        for period in forecast?.forecastPeriods ?? [] {
            XCTAssertGreaterThan(period.upperBound, period.expectedValue)
            XCTAssertLessThan(period.lowerBound, period.expectedValue)
            XCTAssertGreaterThan(period.confidenceLevel, 0.8)
        }
    }
    
    func testEntitySpecificCashFlowForecasting() async throws {
        // Given: Business and personal transaction data
        let businessData = testFoundation.generateBusinessTransactionData(count: 100)
        let personalData = testFoundation.generatePersonalTransactionData(count: 80)
        
        await predictiveAnalytics.trainOnHistoricalData(businessData + personalData)
        
        // When: Generate entity-specific forecasts
        let businessForecast = await cashFlowForecaster.generateEntitySpecificForecast(
            entity: .business,
            horizonMonths: 12
        )
        
        let personalForecast = await cashFlowForecaster.generateEntitySpecificForecast(
            entity: .personal,
            horizonMonths: 12
        )
        
        // Then: Verify entity separation
        XCTAssertNotNil(businessForecast)
        XCTAssertNotNil(personalForecast)
        XCTAssertNotEqual(businessForecast?.averageMonthlyFlow, personalForecast?.averageMonthlyFlow)
        
        // Verify business forecast includes tax considerations
        XCTAssertTrue(businessForecast?.includesTaxOptimization ?? false)
        XCTAssertGreaterThan(businessForecast?.taxLiabilityEstimate ?? 0.0, 0.0)
    }
    
    func testSeasonalPatternRecognition() async throws {
        // Given: Seasonal transaction data (Christmas spending, tax season, etc.)
        let seasonalData = testFoundation.generateSeasonalTransactionData()
        
        await predictiveAnalytics.trainOnHistoricalData(seasonalData)
        
        // When: Analyze seasonal patterns
        let patterns = await predictiveAnalytics.identifySeasonalPatterns()
        
        // Then: Verify seasonal recognition
        XCTAssertNotNil(patterns)
        XCTAssertGreaterThan(patterns?.detectedPatterns.count ?? 0, 0)
        
        // Verify Christmas spending pattern
        let christmasPattern = patterns?.detectedPatterns.first { $0.patternType == .seasonalSpending }
        XCTAssertNotNil(christmasPattern)
        XCTAssertEqual(christmasPattern?.peakMonth, 12) // December
        XCTAssertGreaterThan(christmasPattern?.amplificationFactor ?? 0.0, 1.2)
    }
    
    // MARK: - Tax Liability Optimization Tests
    
    func testTaxLiabilityPrediction() async throws {
        // Given: Australian tax scenario data
        let taxScenarios = testFoundation.generateAustralianTaxTestScenarios()
        let relevantTransactions = taxScenarios.flatMap { $0.transactionData }
        
        await predictiveAnalytics.trainOnHistoricalData(relevantTransactions)
        
        // When: Predict tax liability
        let prediction = await predictiveAnalytics.predictTaxLiability(
            financialYear: "2024-25",
            consideringSplitOptimization: true
        )
        
        // Then: Verify prediction accuracy
        XCTAssertNotNil(prediction)
        XCTAssertGreaterThan(prediction?.estimatedTaxLiability ?? 0.0, 0.0)
        XCTAssertGreaterThan(prediction?.confidenceScore ?? 0.0, 0.75)
        XCTAssertTrue(prediction?.includesAustralianCompliance ?? false)
        
        // Verify optimization recommendations
        XCTAssertNotNil(prediction?.optimizationRecommendations)
        XCTAssertGreaterThan(prediction?.optimizationRecommendations.count ?? 0, 0)
    }
    
    func testInvestmentAllocationAdvice() async throws {
        // Given: Investment and income data
        let investmentData = testFoundation.generateInvestmentTransactionData(count: 50)
        
        await predictiveAnalytics.trainOnHistoricalData(investmentData)
        
        // When: Generate investment allocation advice
        let advice = await predictiveAnalytics.generateInvestmentAllocationAdvice(
            riskTolerance: .moderate,
            investmentHorizon: .longTerm,
            currentPortfolioValue: 100000.0
        )
        
        // Then: Verify advice quality
        XCTAssertNotNil(advice)
        XCTAssertGreaterThan(advice?.recommendedAllocations.count ?? 0, 0)
        XCTAssertTrue(advice?.considersTaxEfficiency ?? false)
        XCTAssertGreaterThan(advice?.expectedAnnualReturn ?? 0.0, 0.03) // >3% return
        XCTAssertLessThan(advice?.expectedAnnualReturn ?? 1.0, 0.12) // <12% return (realistic)
    }
    
    // MARK: - Budget Recommendations Tests
    
    func testEntitySpecificBudgetRecommendations() async throws {
        // Given: Comprehensive spending data
        let spendingData = testFoundation.generateComprehensiveSpendingData()
        
        await predictiveAnalytics.trainOnHistoricalData(spendingData)
        
        // When: Generate budget recommendations
        let businessBudget = await predictiveAnalytics.generateBudgetRecommendations(
            entity: .business,
            budgetPeriod: .quarterly
        )
        
        let personalBudget = await predictiveAnalytics.generateBudgetRecommendations(
            entity: .personal,
            budgetPeriod: .monthly
        )
        
        // Then: Verify budget quality
        XCTAssertNotNil(businessBudget)
        XCTAssertNotNil(personalBudget)
        
        // Verify business budget includes tax considerations
        XCTAssertTrue(businessBudget?.includesTaxConsiderations ?? false)
        XCTAssertGreaterThan(businessBudget?.recommendedCategories.count ?? 0, 0)
        
        // Verify personal budget is realistic
        XCTAssertGreaterThan(personalBudget?.totalRecommendedBudget ?? 0.0, 0.0)
        XCTAssertLessThan(personalBudget?.aggressivenessFactor ?? 1.0, 0.9) // Conservative by default
    }
    
    func testSmartCategoryBudgeting() async throws {
        // Given: Category-specific spending patterns
        let categoryData = testFoundation.generateCategoryBasedTransactionData()
        
        await predictiveAnalytics.trainOnHistoricalData(categoryData)
        
        // When: Generate smart category budgets
        let categoryBudgets = await predictiveAnalytics.generateSmartCategoryBudgets(
            categories: ["Business Meals", "Office Supplies", "Professional Development", "Home Office"]
        )
        
        // Then: Verify category budgets
        XCTAssertNotNil(categoryBudgets)
        XCTAssertEqual(categoryBudgets?.count, 4)
        
        // Verify each category has realistic budgets
        for budget in categoryBudgets ?? [] {
            XCTAssertGreaterThan(budget.recommendedAmount, 0.0)
            XCTAssertGreaterThan(budget.confidenceScore, 0.6)
            XCTAssertNotNil(budget.justification)
        }
    }
    
    // MARK: - Scenario Modeling Tests
    
    func testWhatIfScenarioModeling() async throws {
        // Given: Base financial scenario
        let baseData = testFoundation.generateStableFinancialScenario()
        
        await predictiveAnalytics.trainOnHistoricalData(baseData)
        
        // When: Model income increase scenario
        let incomeIncreaseScenario = ScenarioParameters(
            incomeChangePercentage: 20.0,
            expenseChangePercentage: 5.0,
            newBusinessExpenses: 15000.0,
            taxStrategyOptimization: true
        )
        
        let scenario = await predictiveAnalytics.modelScenario(
            parameters: incomeIncreaseScenario,
            timeHorizon: .oneYear
        )
        
        // Then: Verify scenario results
        XCTAssertNotNil(scenario)
        XCTAssertGreaterThan(scenario?.projectedNetIncome ?? 0.0, 0.0)
        XCTAssertGreaterThan(scenario?.improvementScore ?? 0.0, 0.0)
        XCTAssertNotNil(scenario?.keyInsights)
        XCTAssertGreaterThan(scenario?.keyInsights.count ?? 0, 0)
    }
    
    func testBusinessExpansionScenario() async throws {
        // Given: Current business data
        let businessData = testFoundation.generateBusinessTransactionData(count: 200)
        
        await predictiveAnalytics.trainOnHistoricalData(businessData)
        
        // When: Model business expansion
        let expansionScenario = ScenarioParameters(
            incomeChangePercentage: 50.0,
            expenseChangePercentage: 40.0,
            newBusinessExpenses: 75000.0,
            additionalStaffCount: 2,
            newEquipmentCosts: 25000.0,
            taxStrategyOptimization: true
        )
        
        let result = await predictiveAnalytics.modelBusinessExpansionScenario(
            parameters: expansionScenario
        )
        
        // Then: Verify expansion analysis
        XCTAssertNotNil(result)
        XCTAssertGreaterThan(result?.breakEvenMonths ?? 0, 0)
        XCTAssertLessThan(result?.breakEvenMonths ?? 100, 24) // Should break even within 2 years
        XCTAssertTrue(result?.isFinanciallyViable ?? false)
        XCTAssertNotNil(result?.riskFactors)
    }
    
    // MARK: - Confidence Interval Tests
    
    func testConfidenceIntervalAccuracy() async throws {
        // Given: Known outcome data for validation
        let knownOutcomeData = testFoundation.generateKnownOutcomeTestData()
        
        await predictiveAnalytics.trainOnHistoricalData(knownOutcomeData.trainingData)
        
        // When: Make predictions with confidence intervals
        var correctPredictions = 0
        let totalPredictions = knownOutcomeData.testCases.count
        
        for testCase in knownOutcomeData.testCases {
            let prediction = await predictiveAnalytics.predictWithConfidenceInterval(
                scenario: testCase.scenario,
                confidenceLevel: 0.95
            )
            
            if let prediction = prediction,
               testCase.actualOutcome >= prediction.lowerBound &&
               testCase.actualOutcome <= prediction.upperBound {
                correctPredictions += 1
            }
        }
        
        // Then: Verify confidence interval accuracy
        let accuracy = Double(correctPredictions) / Double(totalPredictions)
        XCTAssertGreaterThan(accuracy, 0.90) // 90% of predictions should be within confidence intervals
    }
    
    func testUncertaintyQuantification() async throws {
        // Given: Volatile financial data
        let volatileData = testFoundation.generateVolatileFinancialData()
        
        await predictiveAnalytics.trainOnHistoricalData(volatileData)
        
        // When: Quantify uncertainty
        let uncertainty = await predictiveAnalytics.quantifyPredictionUncertainty()
        
        // Then: Verify uncertainty metrics
        XCTAssertNotNil(uncertainty)
        XCTAssertGreaterThan(uncertainty?.overallUncertaintyScore ?? 0.0, 0.0)
        XCTAssertLessThan(uncertainty?.overallUncertaintyScore ?? 1.0, 1.0)
        XCTAssertNotNil(uncertainty?.uncertaintyFactors)
        XCTAssertGreaterThan(uncertainty?.uncertaintyFactors.count ?? 0, 0)
    }
    
    // MARK: - Performance Tests
    
    func testLargeDatasetsPerformance() async throws {
        // Given: Large historical dataset
        let largeDataset = testFoundation.generateLargeHistoricalDataset(transactionCount: 5000)
        
        let startTime = Date()
        
        // When: Train on large dataset
        await predictiveAnalytics.trainOnHistoricalData(largeDataset)
        
        let trainingTime = Date().timeIntervalSince(startTime)
        
        // Generate forecast
        let forecastStartTime = Date()
        let forecast = await cashFlowForecaster.generateCashFlowForecast(
            horizonMonths: 12,
            confidenceLevel: 0.95
        )
        let forecastTime = Date().timeIntervalSince(forecastStartTime)
        
        // Then: Verify performance
        XCTAssertLessThan(trainingTime, 10.0) // Training should complete within 10 seconds
        XCTAssertLessThan(forecastTime, 2.0) // Forecasting should complete within 2 seconds
        XCTAssertNotNil(forecast)
    }
    
    func testMemoryEfficiency() async throws {
        // Given: Memory-intensive scenario
        let memoryIntensiveData = testFoundation.generateMemoryIntensiveDataset()
        
        let initialMemory = getCurrentMemoryUsage()
        
        // When: Process large amounts of data
        await predictiveAnalytics.trainOnHistoricalData(memoryIntensiveData)
        
        for _ in 0..<10 {
            _ = await cashFlowForecaster.generateCashFlowForecast(
                horizonMonths: 12,
                confidenceLevel: 0.95
            )
        }
        
        let peakMemory = getCurrentMemoryUsage()
        let memoryIncrease = peakMemory - initialMemory
        
        // Then: Verify memory efficiency
        XCTAssertLessThan(memoryIncrease, 100_000_000) // Should use less than 100MB additional memory
    }
    
    // MARK: - Edge Case Tests
    
    func testZeroIncomeScenario() async throws {
        // Given: Zero income scenario
        let zeroIncomeData = testFoundation.generateZeroIncomeScenario()
        
        await predictiveAnalytics.trainOnHistoricalData(zeroIncomeData)
        
        // When: Generate forecast
        let forecast = await cashFlowForecaster.generateCashFlowForecast(
            horizonMonths: 6,
            confidenceLevel: 0.95
        )
        
        // Then: Verify graceful handling
        XCTAssertNotNil(forecast)
        XCTAssertLessThan(forecast?.overallConfidenceScore ?? 1.0, 0.5) // Low confidence expected
        XCTAssertTrue(forecast?.includesWarnings ?? false)
    }
    
    func testExtremeVolatilityScenario() async throws {
        // Given: Extremely volatile financial data
        let volatileData = testFoundation.generateExtremeVolatilityData()
        
        await predictiveAnalytics.trainOnHistoricalData(volatileData)
        
        // When: Generate predictions
        let prediction = await predictiveAnalytics.predictTaxLiability(
            financialYear: "2024-25",
            consideringSplitOptimization: true
        )
        
        // Then: Verify robustness
        XCTAssertNotNil(prediction)
        XCTAssertLessThan(prediction?.confidenceScore ?? 1.0, 0.7) // Lower confidence for volatile data
        XCTAssertTrue(prediction?.includesVolatilityWarning ?? false)
    }
    
    // MARK: - Australian Tax Compliance Tests
    
    func testAustralianFinancialYearCompliance() async throws {
        // Given: Australian financial year data
        let financialYearData = testFoundation.generateAustralianFinancialYearData()
        
        await predictiveAnalytics.trainOnHistoricalData(financialYearData)
        
        // When: Generate financial year predictions
        let prediction = await predictiveAnalytics.predictFinancialYearOutcome(
            year: "2024-25"
        )
        
        // Then: Verify compliance
        XCTAssertNotNil(prediction)
        XCTAssertTrue(prediction?.compliesWithAustralianTaxLaw ?? false)
        XCTAssertNotNil(prediction?.atoComplianceNotes)
        XCTAssertGreaterThan(prediction?.atoComplianceNotes.count ?? 0, 0)
    }
    
    func testGSTImpactModeling() async throws {
        // Given: GST-relevant transaction data
        let gstData = testFoundation.generateGSTRelevantTransactionData()
        
        await predictiveAnalytics.trainOnHistoricalData(gstData)
        
        // When: Model GST impact
        let gstImpact = await predictiveAnalytics.modelGSTImpact(
            registrationThreshold: 75000.0
        )
        
        // Then: Verify GST modeling
        XCTAssertNotNil(gstImpact)
        XCTAssertTrue(gstImpact?.recommendsGSTRegistration != nil)
        XCTAssertNotNil(gstImpact?.quarterlyGSTEstimates)
        XCTAssertEqual(gstImpact?.quarterlyGSTEstimates.count, 4)
    }
    
    // MARK: - Helper Methods
    
    private func getCurrentMemoryUsage() -> Int {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        return kerr == KERN_SUCCESS ? Int(info.resident_size) : 0
    }
}

// MARK: - Test Data Structures

extension SplitIntelligenceTestFoundation {
    
    func generateHistoricalTransactionData(months: Int, transactionsPerMonth: Int) -> [(Transaction, [SplitAllocation])] {
        var data: [(Transaction, [SplitAllocation])] = []
        let calendar = Calendar.current
        let now = Date()
        
        for monthOffset in 0..<months {
            guard let monthDate = calendar.date(byAdding: .month, value: -monthOffset, to: now) else { continue }
            
            for _ in 0..<transactionsPerMonth {
                let transaction = Transaction(context: managedObjectContext)
                transaction.id = UUID()
                transaction.amount = Double.random(in: 50...2000)
                transaction.category = ["Business Meals", "Office Supplies", "Professional Development"].randomElement()
                transaction.date = monthDate
                transaction.createdAt = monthDate
                
                let splits = generateRandomSplitAllocations(for: transaction)
                data.append((transaction, splits))
            }
        }
        
        return data
    }
    
    func generateBusinessTransactionData(count: Int) -> [(Transaction, [SplitAllocation])] {
        return (0..<count).map { _ in
            let transaction = Transaction(context: managedObjectContext)
            transaction.id = UUID()
            transaction.amount = Double.random(in: 100...5000)
            transaction.category = "Business"
            transaction.date = Date().addingTimeInterval(-Double.random(in: 0...31536000)) // Random within last year
            transaction.createdAt = transaction.date
            
            let splits = generateBusinessSplitAllocations(for: transaction)
            return (transaction, splits)
        }
    }
    
    func generatePersonalTransactionData(count: Int) -> [(Transaction, [SplitAllocation])] {
        return (0..<count).map { _ in
            let transaction = Transaction(context: managedObjectContext)
            transaction.id = UUID()
            transaction.amount = Double.random(in: 20...800)
            transaction.category = "Personal"
            transaction.date = Date().addingTimeInterval(-Double.random(in: 0...31536000))
            transaction.createdAt = transaction.date
            
            let splits = generatePersonalSplitAllocations(for: transaction)
            return (transaction, splits)
        }
    }
    
    private func generateRandomSplitAllocations(for transaction: Transaction) -> [SplitAllocation] {
        let split = SplitAllocation(context: managedObjectContext)
        split.id = UUID()
        split.percentage = 100.0
        split.amount = transaction.amount
        split.taxCategory = "Business Expense"
        split.createdAt = Date()
        return [split]
    }
    
    private func generateBusinessSplitAllocations(for transaction: Transaction) -> [SplitAllocation] {
        let split = SplitAllocation(context: managedObjectContext)
        split.id = UUID()
        split.percentage = 100.0
        split.amount = transaction.amount
        split.taxCategory = "Business Expense"
        split.createdAt = Date()
        return [split]
    }
    
    private func generatePersonalSplitAllocations(for transaction: Transaction) -> [SplitAllocation] {
        let split = SplitAllocation(context: managedObjectContext)
        split.id = UUID()
        split.percentage = 100.0
        split.amount = transaction.amount
        split.taxCategory = "Personal"
        split.createdAt = Date()
        return [split]
    }
}