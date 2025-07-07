//
// CashFlowForecasterTests.swift
// FinanceMateTests
//
// Comprehensive test suite for ML-powered cash flow forecasting
// Created: 2025-07-07
// Target: FinanceMateTests
//

/*
 * Purpose: Comprehensive test coverage for CashFlowForecaster ML system
 * Issues & Complexity Summary: ML forecasting testing, accuracy validation, seasonal analysis, confidence modeling
 * Key Complexity Drivers:
   - Logic Scope (Est. LoC): ~500
   - Core Algorithm Complexity: High
   - Dependencies: CashFlowForecaster, PredictiveAnalytics, seasonal modeling, confidence intervals
   - State Management Complexity: High (forecasting models, seasonal patterns, confidence calculations)
   - Novelty/Uncertainty Factor: High (cash flow forecasting accuracy, seasonal pattern testing, confidence validation)
 * AI Pre-Task Self-Assessment: 91%
 * Problem Estimate: 93%
 * Initial Code Complexity Estimate: 90%
 * Final Code Complexity: 92%
 * Overall Result Score: 94%
 * Key Variances/Learnings: Cash flow forecasting requires extensive accuracy validation and seasonal pattern testing
 * Last Updated: 2025-07-07
 */

import XCTest
import CoreData
@testable import FinanceMate

@MainActor
final class CashFlowForecasterTests: XCTestCase {
    
    // MARK: - Test Infrastructure
    
    var cashFlowForecaster: CashFlowForecaster!
    var predictiveAnalytics: PredictiveAnalytics!
    var testContext: NSManagedObjectContext!
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
        let splitIntelligenceEngine = SplitIntelligenceEngine(
            context: testContext,
            featureGatingSystem: featureGatingSystem,
            userJourneyTracker: userJourneyTracker,
            analyticsEngine: analyticsEngine
        )
        
        // Initialize predictive analytics and cash flow forecaster
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
        cashFlowForecaster = nil
        predictiveAnalytics = nil
        testFoundation = nil
        testContext = nil
        try await super.tearDown()
    }
    
    // MARK: - Basic Forecasting Tests
    
    func testBasicMonthlyForecast() async throws {
        // Given: Simple monthly income/expense pattern
        let monthlyData = testFoundation.generateStableMonthlyTransactionData(months: 12)
        
        await predictiveAnalytics.trainOnHistoricalData(monthlyData)
        
        // When: Generate 6-month forecast
        let forecast = await cashFlowForecaster.generateCashFlowForecast(
            horizonMonths: 6,
            confidenceLevel: 0.90
        )
        
        // Then: Verify basic forecast structure
        XCTAssertNotNil(forecast)
        XCTAssertEqual(forecast?.forecastPeriods.count, 6)
        XCTAssertGreaterThan(forecast?.overallConfidenceScore ?? 0.0, 0.8)
        
        // Verify each period has required data
        for period in forecast?.forecastPeriods ?? [] {
            XCTAssertGreaterThan(period.expectedValue, 0.0)
            XCTAssertGreaterThan(period.upperBound, period.expectedValue)
            XCTAssertLessThan(period.lowerBound, period.expectedValue)
            XCTAssertGreaterThan(period.confidenceLevel, 0.85)
        }
    }
    
    func testQuarterlyForecast() async throws {
        // Given: Quarterly business pattern data
        let quarterlyData = testFoundation.generateQuarterlyBusinessData(quarters: 8)
        
        await predictiveAnalytics.trainOnHistoricalData(quarterlyData)
        
        // When: Generate quarterly forecast
        let forecast = await cashFlowForecaster.generateQuarterlyForecast(
            horizonQuarters: 4,
            confidenceLevel: 0.95
        )
        
        // Then: Verify quarterly structure
        XCTAssertNotNil(forecast)
        XCTAssertEqual(forecast?.forecastPeriods.count, 4)
        XCTAssertTrue(forecast?.includesQuarterlySeasonality ?? false)
        XCTAssertGreaterThan(forecast?.averageQuarterlyGrowth ?? 0.0, -0.1) // Not declining more than 10%
    }
    
    func testYearlyForecast() async throws {
        // Given: Multi-year historical data
        let yearlyData = testFoundation.generateMultiYearData(years: 3)
        
        await predictiveAnalytics.trainOnHistoricalData(yearlyData)
        
        // When: Generate yearly forecast
        let forecast = await cashFlowForecaster.generateYearlyForecast(
            horizonYears: 2,
            includeInflationAdjustment: true
        )
        
        // Then: Verify yearly forecast
        XCTAssertNotNil(forecast)
        XCTAssertEqual(forecast?.forecastPeriods.count, 2)
        XCTAssertTrue(forecast?.includesInflationAdjustment ?? false)
        XCTAssertGreaterThan(forecast?.projectedAnnualGrowthRate ?? 0.0, -0.2) // Not declining more than 20%
    }
    
    // MARK: - Split-Aware Forecasting Tests
    
    func testSplitAwareCashFlowForecast() async throws {
        // Given: Complex split allocation data
        let splitData = testFoundation.generateComplexSplitAllocationData()
        
        await predictiveAnalytics.trainOnHistoricalData(splitData)
        
        // When: Generate split-aware forecast
        let forecast = await cashFlowForecaster.generateSplitAwareForecast(
            horizonMonths: 12,
            byTaxCategory: true
        )
        
        // Then: Verify split-aware calculations
        XCTAssertNotNil(forecast)
        XCTAssertTrue(forecast?.includesSplitAwareCalculations ?? false)
        XCTAssertNotNil(forecast?.forecastByTaxCategory)
        XCTAssertGreaterThan(forecast?.forecastByTaxCategory.count ?? 0, 1)
        
        // Verify tax category forecasts
        for categoryForecast in forecast?.forecastByTaxCategory ?? [:] {
            XCTAssertGreaterThan(categoryForecast.value.count, 0)
            XCTAssertGreaterThan(categoryForecast.value.first?.expectedValue ?? 0.0, 0.0)
        }
    }
    
    func testBusinessPersonalSeparation() async throws {
        // Given: Mixed business and personal data
        let businessData = testFoundation.generateBusinessTransactionData(count: 100)
        let personalData = testFoundation.generatePersonalTransactionData(count: 80)
        
        await predictiveAnalytics.trainOnHistoricalData(businessData + personalData)
        
        // When: Generate separate forecasts
        let businessForecast = await cashFlowForecaster.generateEntitySpecificForecast(
            entity: .business,
            horizonMonths: 6
        )
        
        let personalForecast = await cashFlowForecaster.generateEntitySpecificForecast(
            entity: .personal,
            horizonMonths: 6
        )
        
        // Then: Verify entity separation
        XCTAssertNotNil(businessForecast)
        XCTAssertNotNil(personalForecast)
        XCTAssertNotEqual(businessForecast?.averageMonthlyFlow, personalForecast?.averageMonthlyFlow)
        
        // Verify business-specific considerations
        XCTAssertTrue(businessForecast?.includesTaxOptimization ?? false)
        XCTAssertNotNil(businessForecast?.taxLiabilityEstimate)
        
        // Verify personal-specific considerations
        XCTAssertNotNil(personalForecast?.discretionarySpendingForecast)
        XCTAssertNotNil(personalForecast?.savingsProjection)
    }
    
    // MARK: - Seasonal Pattern Tests
    
    func testSeasonalPatternDetection() async throws {
        // Given: Data with clear seasonal patterns
        let seasonalData = testFoundation.generateSeasonalPatternData()
        
        await predictiveAnalytics.trainOnHistoricalData(seasonalData)
        
        // When: Detect seasonal patterns
        let patterns = await cashFlowForecaster.detectSeasonalPatterns()
        
        // Then: Verify pattern detection
        XCTAssertNotNil(patterns)
        XCTAssertGreaterThan(patterns?.detectedPatterns.count ?? 0, 0)
        
        // Verify Christmas pattern
        let christmasPattern = patterns?.detectedPatterns.first { $0.name == "December Spending Spike" }
        XCTAssertNotNil(christmasPattern)
        XCTAssertEqual(christmasPattern?.peakMonth, 12)
        XCTAssertGreaterThan(christmasPattern?.intensity ?? 0.0, 1.2)
        
        // Verify tax season pattern
        let taxPattern = patterns?.detectedPatterns.first { $0.name == "Tax Season Activity" }
        XCTAssertNotNil(taxPattern)
        XCTAssertTrue([6, 7].contains(taxPattern?.peakMonth)) // June-July (Australian tax year end)
    }
    
    func testSeasonalForecastAdjustment() async throws {
        // Given: Seasonal data for training
        let seasonalData = testFoundation.generateSeasonalBusinessData()
        
        await predictiveAnalytics.trainOnHistoricalData(seasonalData)
        
        // When: Generate forecast with seasonal adjustment
        let forecastWithSeasonal = await cashFlowForecaster.generateCashFlowForecast(
            horizonMonths: 12,
            confidenceLevel: 0.90,
            includeSeasonalAdjustment: true
        )
        
        let forecastWithoutSeasonal = await cashFlowForecaster.generateCashFlowForecast(
            horizonMonths: 12,
            confidenceLevel: 0.90,
            includeSeasonalAdjustment: false
        )
        
        // Then: Verify seasonal adjustment impact
        XCTAssertNotNil(forecastWithSeasonal)
        XCTAssertNotNil(forecastWithoutSeasonal)
        XCTAssertNotEqual(
            forecastWithSeasonal?.forecastPeriods.last?.expectedValue,
            forecastWithoutSeasonal?.forecastPeriods.last?.expectedValue
        )
        
        // Verify seasonal forecast includes variation
        let seasonalVariation = forecastWithSeasonal?.forecastPeriods.map { $0.expectedValue }
        let maxVariation = (seasonalVariation?.max() ?? 0.0) - (seasonalVariation?.min() ?? 0.0)
        XCTAssertGreaterThan(maxVariation, 0.0)
    }
    
    // MARK: - Confidence Interval Tests
    
    func testConfidenceIntervalCalculation() async throws {
        // Given: Varied historical data
        let variedData = testFoundation.generateVariedHistoricalData()
        
        await predictiveAnalytics.trainOnHistoricalData(variedData)
        
        // When: Generate forecast with different confidence levels
        let forecast90 = await cashFlowForecaster.generateCashFlowForecast(
            horizonMonths: 6,
            confidenceLevel: 0.90
        )
        
        let forecast95 = await cashFlowForecaster.generateCashFlowForecast(
            horizonMonths: 6,
            confidenceLevel: 0.95
        )
        
        // Then: Verify confidence interval behavior
        XCTAssertNotNil(forecast90)
        XCTAssertNotNil(forecast95)
        
        // 95% confidence should have wider intervals than 90%
        for i in 0..<min(6, forecast90?.forecastPeriods.count ?? 0, forecast95?.forecastPeriods.count ?? 0) {
            let interval90 = (forecast90?.forecastPeriods[i].upperBound ?? 0.0) - (forecast90?.forecastPeriods[i].lowerBound ?? 0.0)
            let interval95 = (forecast95?.forecastPeriods[i].upperBound ?? 0.0) - (forecast95?.forecastPeriods[i].lowerBound ?? 0.0)
            XCTAssertGreaterThan(interval95, interval90)
        }
    }
    
    func testConfidenceScoreCalculation() async throws {
        // Given: High-quality vs low-quality data
        let highQualityData = testFoundation.generateHighQualityHistoricalData()
        let lowQualityData = testFoundation.generateLowQualityHistoricalData()
        
        // Train on high-quality data
        await predictiveAnalytics.trainOnHistoricalData(highQualityData)
        let highQualityForecast = await cashFlowForecaster.generateCashFlowForecast(
            horizonMonths: 6,
            confidenceLevel: 0.90
        )
        
        // Reset and train on low-quality data
        await predictiveAnalytics.clearTrainingData()
        await predictiveAnalytics.trainOnHistoricalData(lowQualityData)
        let lowQualityForecast = await cashFlowForecaster.generateCashFlowForecast(
            horizonMonths: 6,
            confidenceLevel: 0.90
        )
        
        // Then: Verify confidence scoring
        XCTAssertNotNil(highQualityForecast)
        XCTAssertNotNil(lowQualityForecast)
        XCTAssertGreaterThan(
            highQualityForecast?.overallConfidenceScore ?? 0.0,
            lowQualityForecast?.overallConfidenceScore ?? 1.0
        )
    }
    
    // MARK: - Performance Tests
    
    func testForecastGenerationPerformance() async throws {
        // Given: Reasonable dataset
        let performanceData = testFoundation.generatePerformanceTestData(transactionCount: 1000)
        
        await predictiveAnalytics.trainOnHistoricalData(performanceData)
        
        // When: Generate multiple forecasts
        let startTime = Date()
        
        for _ in 0..<5 {
            _ = await cashFlowForecaster.generateCashFlowForecast(
                horizonMonths: 12,
                confidenceLevel: 0.90
            )
        }
        
        let totalTime = Date().timeIntervalSince(startTime)
        
        // Then: Verify performance
        XCTAssertLessThan(totalTime, 5.0) // 5 forecasts should complete within 5 seconds
        let averageTimePerForecast = totalTime / 5.0
        XCTAssertLessThan(averageTimePerForecast, 1.0) // Each forecast should take less than 1 second
    }
    
    func testMemoryEfficiencyDuringForecasting() async throws {
        // Given: Memory test scenario
        let memoryTestData = testFoundation.generateMemoryTestData()
        
        await predictiveAnalytics.trainOnHistoricalData(memoryTestData)
        
        let initialMemory = getCurrentMemoryUsage()
        
        // When: Generate many forecasts
        for _ in 0..<20 {
            _ = await cashFlowForecaster.generateCashFlowForecast(
                horizonMonths: 12,
                confidenceLevel: 0.90
            )
        }
        
        let peakMemory = getCurrentMemoryUsage()
        let memoryIncrease = peakMemory - initialMemory
        
        // Then: Verify memory efficiency
        XCTAssertLessThan(memoryIncrease, 50_000_000) // Should use less than 50MB additional memory
    }
    
    // MARK: - Edge Case Tests
    
    func testZeroDataForecast() async throws {
        // Given: No historical data
        // When: Attempt to generate forecast
        let forecast = await cashFlowForecaster.generateCashFlowForecast(
            horizonMonths: 6,
            confidenceLevel: 0.90
        )
        
        // Then: Verify graceful handling
        XCTAssertNotNil(forecast)
        XCTAssertLessThan(forecast?.overallConfidenceScore ?? 1.0, 0.3) // Very low confidence
        XCTAssertTrue(forecast?.includesWarnings ?? false)
        XCTAssertTrue(forecast?.warnings.contains("Limited historical data") ?? false)
    }
    
    func testExtremeVolatilityForecast() async throws {
        // Given: Extremely volatile data
        let volatileData = testFoundation.generateExtremeVolatilityData()
        
        await predictiveAnalytics.trainOnHistoricalData(volatileData)
        
        // When: Generate forecast
        let forecast = await cashFlowForecaster.generateCashFlowForecast(
            horizonMonths: 6,
            confidenceLevel: 0.90
        )
        
        // Then: Verify robustness
        XCTAssertNotNil(forecast)
        XCTAssertLessThan(forecast?.overallConfidenceScore ?? 1.0, 0.6) // Lower confidence for volatile data
        XCTAssertTrue(forecast?.includesVolatilityWarning ?? false)
        
        // Verify wide confidence intervals
        for period in forecast?.forecastPeriods ?? [] {
            let intervalWidth = period.upperBound - period.lowerBound
            let relativeWidth = intervalWidth / abs(period.expectedValue)
            XCTAssertGreaterThan(relativeWidth, 0.5) // Wide intervals for volatile data
        }
    }
    
    func testSingleTransactionForecast() async throws {
        // Given: Only one transaction
        let singleTransactionData = testFoundation.generateSingleTransactionData()
        
        await predictiveAnalytics.trainOnHistoricalData(singleTransactionData)
        
        // When: Generate forecast
        let forecast = await cashFlowForecaster.generateCashFlowForecast(
            horizonMonths: 3,
            confidenceLevel: 0.90
        )
        
        // Then: Verify minimal data handling
        XCTAssertNotNil(forecast)
        XCTAssertLessThan(forecast?.overallConfidenceScore ?? 1.0, 0.4) // Very low confidence
        XCTAssertTrue(forecast?.warnings.contains("Insufficient data") ?? false)
    }
    
    // MARK: - Australian Context Tests
    
    func testAustralianFinancialYearForecasting() async throws {
        // Given: Australian financial year data (July-June)
        let financialYearData = testFoundation.generateAustralianFinancialYearData()
        
        await predictiveAnalytics.trainOnHistoricalData(financialYearData)
        
        // When: Generate financial year forecast
        let forecast = await cashFlowForecaster.generateFinancialYearForecast(
            startMonth: 7, // July
            includesTaxSeasonAdjustment: true
        )
        
        // Then: Verify Australian context
        XCTAssertNotNil(forecast)
        XCTAssertEqual(forecast?.forecastPeriods.count, 12) // Full financial year
        XCTAssertTrue(forecast?.includesAustralianTaxConsiderations ?? false)
        
        // Verify tax season (June-July) adjustment
        let juneIndex = forecast?.forecastPeriods.firstIndex { $0.month == 6 }
        let julyIndex = forecast?.forecastPeriods.firstIndex { $0.month == 7 }
        
        if let juneIdx = juneIndex, let julyIdx = julyIndex {
            // Tax season should show increased activity
            XCTAssertGreaterThan(
                forecast?.forecastPeriods[juneIdx].expectedValue ?? 0.0,
                forecast?.forecastPeriods[(juneIdx + 2) % 12].expectedValue ?? 0.0
            )
        }
    }
    
    func testGSTQuarterlyForecasting() async throws {
        // Given: GST-relevant business data
        let gstData = testFoundation.generateGSTBusinessData()
        
        await predictiveAnalytics.trainOnHistoricalData(gstData)
        
        // When: Generate GST quarterly forecast
        let gstForecast = await cashFlowForecaster.generateGSTQuarterlyForecast(
            quarters: 4
        )
        
        // Then: Verify GST considerations
        XCTAssertNotNil(gstForecast)
        XCTAssertEqual(gstForecast?.quarterlyPeriods.count, 4)
        XCTAssertNotNil(gstForecast?.gstLiabilityEstimates)
        XCTAssertNotNil(gstForecast?.gstRefundProjections)
        
        // Verify GST amounts are reasonable (10% of taxable revenue)
        for period in gstForecast?.quarterlyPeriods ?? [] {
            if let gstLiability = period.gstLiability {
                let impliedRevenue = gstLiability / 0.1 // GST is 10%
                XCTAssertGreaterThan(impliedRevenue, 0.0)
                XCTAssertLessThan(gstLiability / period.totalRevenue, 0.15) // GST shouldn't exceed 15%
            }
        }
    }
    
    // MARK: - Integration Tests
    
    func testPredictiveAnalyticsIntegration() async throws {
        // Given: Integrated system data
        let integrationData = testFoundation.generateIntegrationTestData()
        
        await predictiveAnalytics.trainOnHistoricalData(integrationData)
        
        // When: Generate forecast using predictive analytics insights
        let analyticsInsights = await predictiveAnalytics.generateAnalyticsInsights()
        let forecast = await cashFlowForecaster.generateForecastWithInsights(
            insights: analyticsInsights,
            horizonMonths: 6
        )
        
        // Then: Verify integration
        XCTAssertNotNil(forecast)
        XCTAssertTrue(forecast?.leveragesAnalyticsInsights ?? false)
        XCTAssertNotNil(forecast?.insightBasedAdjustments)
        XCTAssertGreaterThan(forecast?.overallConfidenceScore ?? 0.0, 0.8) // Higher confidence with insights
    }
    
    func testSplitIntelligenceIntegration() async throws {
        // Given: Split intelligence data
        let splitData = testFoundation.generateSplitIntelligenceData()
        
        await predictiveAnalytics.trainOnHistoricalData(splitData)
        
        // When: Generate forecast with split intelligence
        let forecast = await cashFlowForecaster.generateSplitIntelligentForecast(
            horizonMonths: 12,
            includeTaxOptimization: true
        )
        
        // Then: Verify split intelligence integration
        XCTAssertNotNil(forecast)
        XCTAssertTrue(forecast?.includesSplitIntelligence ?? false)
        XCTAssertNotNil(forecast?.taxOptimizationSuggestions)
        XCTAssertGreaterThan(forecast?.taxOptimizationSuggestions.count ?? 0, 0)
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

// MARK: - Additional Test Data Extensions

extension SplitIntelligenceTestFoundation {
    
    func generateStableMonthlyTransactionData(months: Int) -> [(Transaction, [SplitAllocation])] {
        var data: [(Transaction, [SplitAllocation])] = []
        let calendar = Calendar.current
        let now = Date()
        
        for monthOffset in 0..<months {
            guard let monthDate = calendar.date(byAdding: .month, value: -monthOffset, to: now) else { continue }
            
            // Generate stable monthly pattern: consistent income and expenses
            let monthlyIncome = 5000.0 + Double.random(in: -200...200) // Stable income with small variation
            let monthlyExpenses = 3500.0 + Double.random(in: -300...300) // Stable expenses with variation
            
            // Create income transaction
            let incomeTransaction = Transaction(context: managedObjectContext)
            incomeTransaction.id = UUID()
            incomeTransaction.amount = monthlyIncome
            incomeTransaction.category = "Income"
            incomeTransaction.date = monthDate
            incomeTransaction.createdAt = monthDate
            
            let incomeSplit = SplitAllocation(context: managedObjectContext)
            incomeSplit.id = UUID()
            incomeSplit.percentage = 100.0
            incomeSplit.amount = monthlyIncome
            incomeSplit.taxCategory = "Income"
            incomeSplit.createdAt = monthDate
            
            data.append((incomeTransaction, [incomeSplit]))
            
            // Create expense transaction
            let expenseTransaction = Transaction(context: managedObjectContext)
            expenseTransaction.id = UUID()
            expenseTransaction.amount = monthlyExpenses
            expenseTransaction.category = "Expenses"
            expenseTransaction.date = monthDate
            expenseTransaction.createdAt = monthDate
            
            let expenseSplit = SplitAllocation(context: managedObjectContext)
            expenseSplit.id = UUID()
            expenseSplit.percentage = 100.0
            expenseSplit.amount = monthlyExpenses
            expenseSplit.taxCategory = "Business Expense"
            expenseSplit.createdAt = monthDate
            
            data.append((expenseTransaction, [expenseSplit]))
        }
        
        return data
    }
    
    func generateQuarterlyBusinessData(quarters: Int) -> [(Transaction, [SplitAllocation])] {
        var data: [(Transaction, [SplitAllocation])] = []
        let calendar = Calendar.current
        let now = Date()
        
        for quarterOffset in 0..<quarters {
            guard let quarterDate = calendar.date(byAdding: .month, value: -quarterOffset * 3, to: now) else { continue }
            
            // Generate quarterly business revenue spike
            let quarterlyRevenue = 15000.0 + Double.random(in: -2000...3000)
            
            let transaction = Transaction(context: managedObjectContext)
            transaction.id = UUID()
            transaction.amount = quarterlyRevenue
            transaction.category = "Quarterly Revenue"
            transaction.date = quarterDate
            transaction.createdAt = quarterDate
            
            let split = SplitAllocation(context: managedObjectContext)
            split.id = UUID()
            split.percentage = 100.0
            split.amount = quarterlyRevenue
            split.taxCategory = "Business Income"
            split.createdAt = quarterDate
            
            data.append((transaction, [split]))
        }
        
        return data
    }
    
    func generateMultiYearData(years: Int) -> [(Transaction, [SplitAllocation])] {
        var data: [(Transaction, [SplitAllocation])] = []
        let calendar = Calendar.current
        let now = Date()
        
        for year in 0..<years {
            guard let yearDate = calendar.date(byAdding: .year, value: -year, to: now) else { continue }
            
            // Generate annual growth pattern
            let baseAmount = 50000.0 * pow(1.05, Double(years - year)) // 5% annual growth
            let annualAmount = baseAmount + Double.random(in: -5000...5000)
            
            let transaction = Transaction(context: managedObjectContext)
            transaction.id = UUID()
            transaction.amount = annualAmount
            transaction.category = "Annual Summary"
            transaction.date = yearDate
            transaction.createdAt = yearDate
            
            let split = SplitAllocation(context: managedObjectContext)
            split.id = UUID()
            split.percentage = 100.0
            split.amount = annualAmount
            split.taxCategory = "Business Income"
            split.createdAt = yearDate
            
            data.append((transaction, [split]))
        }
        
        return data
    }
}