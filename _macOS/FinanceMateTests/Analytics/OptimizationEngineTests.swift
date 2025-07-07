//
// OptimizationEngineTests.swift
// FinanceMateTests
//
// Comprehensive Optimization Engine Test Suite
// Created: 2025-07-07
// Target: FinanceMateTests
//

/*
 * Purpose: Comprehensive test suite for OptimizationEngine with financial optimization and performance enhancement
 * Issues & Complexity Summary: Complex optimization algorithms, performance monitoring, resource management, financial optimization
 * Key Complexity Drivers:
   - Logic Scope (Est. LoC): ~350
   - Core Algorithm Complexity: Very High
   - Dependencies: Core Data, UserDefaults, optimization algorithms, performance monitoring, financial modeling
   - State Management Complexity: Very High (optimization state, performance metrics, resource tracking, recommendation generation)
   - Novelty/Uncertainty Factor: High (optimization algorithms, performance enhancement, financial modeling, resource efficiency)
 * AI Pre-Task Self-Assessment: 88%
 * Problem Estimate: 90%
 * Initial Code Complexity Estimate: 89%
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
class OptimizationEngineTests: XCTestCase {
    
    var optimizationEngine: OptimizationEngine!
    var testContext: NSManagedObjectContext!
    var mockUserDefaults: UserDefaults!
    
    override func setUp() async throws {
        try await super.setUp()
        
        // Create isolated UserDefaults for testing
        mockUserDefaults = UserDefaults(suiteName: "OptimizationEngineTests")!
        mockUserDefaults.removePersistentDomain(forName: "OptimizationEngineTests")
        
        // Initialize test Core Data context
        testContext = PersistenceController.preview.container.viewContext
        
        // Initialize optimization engine
        optimizationEngine = OptimizationEngine(context: testContext, userDefaults: mockUserDefaults)
        
        // Create sample data for testing
        await createSampleTransactionData()
    }
    
    override func tearDown() async throws {
        // Clean up UserDefaults
        mockUserDefaults.removePersistentDomain(forName: "OptimizationEngineTests")
        
        // Clear test data
        await clearTestData()
        
        optimizationEngine = nil
        testContext = nil
        mockUserDefaults = nil
        try await super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testOptimizationEngineInitialization() {
        XCTAssertNotNil(optimizationEngine, "OptimizationEngine should initialize successfully")
        XCTAssertFalse(optimizationEngine.isOptimizationEnabled, "Optimization should be disabled initially")
        XCTAssertTrue(optimizationEngine.availableOptimizations.isEmpty, "No optimizations should be available initially")
    }
    
    func testOptimizationCapabilities() {
        let capabilities = optimizationEngine.getOptimizationCapabilities()
        XCTAssertGreaterThan(capabilities.count, 5, "Should have multiple optimization capabilities")
        
        // Verify core capabilities exist
        XCTAssertTrue(capabilities.contains(.expenseOptimization), "Should include expense optimization")
        XCTAssertTrue(capabilities.contains(.taxOptimization), "Should include tax optimization")
        XCTAssertTrue(capabilities.contains(.performanceOptimization), "Should include performance optimization")
        XCTAssertTrue(capabilities.contains(.budgetOptimization), "Should include budget optimization")
        XCTAssertTrue(capabilities.contains(.cashFlowOptimization), "Should include cash flow optimization")
    }
    
    func testOptimizationEngineState() {
        XCTAssertEqual(optimizationEngine.optimizationProgress, 0.0, "Initial optimization progress should be zero")
        XCTAssertTrue(optimizationEngine.activeOptimizations.isEmpty, "No active optimizations initially")
    }
    
    // MARK: - Expense Optimization Tests
    
    func testExpenseOptimizationAnalysis() async throws {
        await optimizationEngine.enableOptimization()
        
        let expenseOptimizations = await optimizationEngine.analyzeExpenseOptimizations()
        XCTAssertGreaterThan(expenseOptimizations.count, 0, "Should provide expense optimization recommendations")
        
        for optimization in expenseOptimizations {
            XCTAssertGreaterThan(optimization.potentialSavings, 0.0, "Should suggest positive savings")
            XCTAssertGreaterThan(optimization.confidence, 0.0, "Should have confidence score")
            XCTAssertFalse(optimization.description.isEmpty, "Should have description")
            XCTAssertGreaterThan(optimization.actionSteps.count, 0, "Should have actionable steps")
        }
    }
    
    func testCategorySpecificOptimization() async throws {
        await optimizationEngine.enableOptimization()
        
        let businessOptimizations = await optimizationEngine.optimizeCategory("Business")
        XCTAssertNotNil(businessOptimizations, "Should provide business category optimizations")
        XCTAssertGreaterThan(businessOptimizations!.count, 0, "Should have business optimization recommendations")
        
        let personalOptimizations = await optimizationEngine.optimizeCategory("Personal")
        XCTAssertNotNil(personalOptimizations, "Should provide personal category optimizations")
    }
    
    func testRecurringExpenseOptimization() async throws {
        let recurringOptimizations = await optimizationEngine.optimizeRecurringExpenses()
        XCTAssertGreaterThan(recurringOptimizations.count, 0, "Should identify recurring expense optimizations")
        
        for optimization in recurringOptimizations {
            XCTAssertTrue(optimization.isRecurring, "Should be marked as recurring optimization")
            XCTAssertGreaterThan(optimization.annualizedSavings, 0.0, "Should have annualized savings calculation")
        }
    }
    
    func testSubscriptionOptimization() async throws {
        let subscriptionOptimizations = await optimizationEngine.optimizeSubscriptions()
        XCTAssertNotNil(subscriptionOptimizations, "Should provide subscription optimization analysis")
        
        if let optimizations = subscriptionOptimizations {
            for optimization in optimizations.recommendations {
                XCTAssertTrue(optimization.category.contains("subscription") || optimization.category.contains("recurring"), "Should target subscription-related expenses")
                XCTAssertGreaterThan(optimization.priority, 0, "Should have priority ranking")
            }
        }
    }
    
    // MARK: - Tax Optimization Tests
    
    func testAustralianTaxOptimization() async throws {
        await optimizationEngine.enableOptimization()
        
        let taxOptimizations = await optimizationEngine.optimizeAustralianTaxes()
        XCTAssertGreaterThan(taxOptimizations.count, 0, "Should provide Australian tax optimizations")
        
        let gstOptimization = taxOptimizations.first { $0.taxType == .gst }
        XCTAssertNotNil(gstOptimization, "Should include GST optimization")
        XCTAssertTrue(gstOptimization!.isAustralianCompliant, "Should be Australian tax compliant")
        XCTAssertGreaterThan(gstOptimization!.potentialRefund, 0.0, "Should suggest positive GST refund")
    }
    
    func testBusinessDeductionOptimization() async throws {
        let deductionOptimizations = await optimizationEngine.optimizeBusinessDeductions()
        XCTAssertGreaterThan(deductionOptimizations.count, 0, "Should identify business deduction opportunities")
        
        for optimization in deductionOptimizations {
            XCTAssertTrue(optimization.deductionType != .unknown, "Should have valid deduction type")
            XCTAssertGreaterThan(optimization.potentialDeduction, 0.0, "Should have positive deduction amount")
            XCTAssertTrue(optimization.isATOCompliant, "Should be ATO compliant")
        }
    }
    
    func testTaxCategoryOptimization() async throws {
        let categoryOptimizations = await optimizationEngine.optimizeTaxCategories()
        XCTAssertNotNil(categoryOptimizations, "Should provide tax category optimization suggestions")
        
        if let optimizations = categoryOptimizations {
            for suggestion in optimizations.suggestions {
                XCTAssertFalse(suggestion.fromCategory.isEmpty, "Should specify source category")
                XCTAssertFalse(suggestion.toCategory.isEmpty, "Should specify target category")
                XCTAssertGreaterThan(suggestion.taxBenefit, 0.0, "Should show tax benefit")
                XCTAssertGreaterThan(suggestion.confidence, 0.0, "Should have confidence score")
            }
        }
    }
    
    func testQuarterlyTaxPlanning() async throws {
        let quarterlyPlan = await optimizationEngine.generateQuarterlyTaxPlan()
        XCTAssertNotNil(quarterlyPlan, "Should generate quarterly tax planning recommendations")
        XCTAssertEqual(quarterlyPlan!.quarters.count, 4, "Should plan for all 4 quarters")
        
        for quarter in quarterlyPlan!.quarters {
            XCTAssertGreaterThan(quarter.quarter, 0, "Quarter should be valid")
            XCTAssertLessThanOrEqual(quarter.quarter, 4, "Quarter should be valid")
            XCTAssertNotNil(quarter.recommendedActions, "Should have recommended actions")
        }
    }
    
    // MARK: - Budget Optimization Tests
    
    func testBudgetAllocationOptimization() async throws {
        await optimizationEngine.enableOptimization()
        
        let budgetOptimizations = await optimizationEngine.optimizeBudgetAllocations()
        XCTAssertGreaterThan(budgetOptimizations.count, 0, "Should provide budget allocation optimizations")
        
        for optimization in budgetOptimizations {
            XCTAssertGreaterThan(optimization.currentAllocation, 0.0, "Should have current allocation")
            XCTAssertGreaterThan(optimization.recommendedAllocation, 0.0, "Should have recommended allocation")
            XCTAssertNotEqual(optimization.currentAllocation, optimization.recommendedAllocation, "Should suggest changes")
        }
    }
    
    func testSavingsGoalOptimization() async throws {
        let savingsOptimizations = await optimizationEngine.optimizeSavingsGoals()
        XCTAssertNotNil(savingsOptimizations, "Should provide savings goal optimizations")
        
        if let optimizations = savingsOptimizations {
            XCTAssertGreaterThan(optimizations.recommendedSavingsRate, 0.0, "Should recommend positive savings rate")
            XCTAssertLessThanOrEqual(optimizations.recommendedSavingsRate, 1.0, "Savings rate should be realistic")
            XCTAssertGreaterThan(optimizations.strategies.count, 0, "Should provide savings strategies")
        }
    }
    
    func testEmergencyFundOptimization() async throws {
        let emergencyFundOptimization = await optimizationEngine.optimizeEmergencyFund()
        XCTAssertNotNil(emergencyFundOptimization, "Should provide emergency fund optimization")
        
        if let optimization = emergencyFundOptimization {
            XCTAssertGreaterThan(optimization.recommendedAmount, 0.0, "Should recommend positive emergency fund amount")
            XCTAssertGreaterThan(optimization.monthsOfExpenses, 0.0, "Should specify months of expenses")
            XCTAssertGreaterThan(optimization.contributionPlan.count, 0, "Should have contribution plan")
        }
    }
    
    func testDebtOptimizationStrategies() async throws {
        let debtOptimizations = await optimizationEngine.optimizeDebtPayment()
        XCTAssertNotNil(debtOptimizations, "Should provide debt optimization strategies")
        
        if let optimizations = debtOptimizations {
            for strategy in optimizations.strategies {
                XCTAssertFalse(strategy.strategyName.isEmpty, "Strategy should have name")
                XCTAssertGreaterThan(strategy.potentialSavings, 0.0, "Should show potential savings")
                XCTAssertGreaterThan(strategy.timeToPayoff, 0.0, "Should estimate payoff time")
            }
        }
    }
    
    // MARK: - Cash Flow Optimization Tests
    
    func testCashFlowOptimization() async throws {
        await optimizationEngine.enableOptimization()
        
        let cashFlowOptimizations = await optimizationEngine.optimizeCashFlow()
        XCTAssertGreaterThan(cashFlowOptimizations.count, 0, "Should provide cash flow optimizations")
        
        for optimization in cashFlowOptimizations {
            XCTAssertFalse(optimization.recommendation.isEmpty, "Should have recommendation")
            XCTAssertGreaterThan(optimization.expectedImprovement, 0.0, "Should show expected improvement")
            XCTAssertGreaterThan(optimization.implementationDifficulty, 0.0, "Should assess implementation difficulty")
        }
    }
    
    func testIncomeOptimization() async throws {
        let incomeOptimizations = await optimizationEngine.optimizeIncome()
        XCTAssertNotNil(incomeOptimizations, "Should provide income optimization recommendations")
        
        if let optimizations = incomeOptimizations {
            for recommendation in optimizations.recommendations {
                XCTAssertFalse(recommendation.strategy.isEmpty, "Should have strategy description")
                XCTAssertGreaterThan(recommendation.potentialIncrease, 0.0, "Should show potential income increase")
                XCTAssertGreaterThan(recommendation.feasibility, 0.0, "Should assess feasibility")
            }
        }
    }
    
    func testPaymentTimingOptimization() async throws {
        let timingOptimizations = await optimizationEngine.optimizePaymentTiming()
        XCTAssertGreaterThan(timingOptimizations.count, 0, "Should provide payment timing optimizations")
        
        for optimization in timingOptimizations {
            XCTAssertNotNil(optimization.currentTiming, "Should specify current timing")
            XCTAssertNotNil(optimization.recommendedTiming, "Should recommend new timing")
            XCTAssertGreaterThan(optimization.cashFlowBenefit, 0.0, "Should show cash flow benefit")
        }
    }
    
    func testCashFlowForecastOptimization() async throws {
        let forecastOptimization = await optimizationEngine.optimizeCashFlowForecast()
        XCTAssertNotNil(forecastOptimization, "Should provide cash flow forecast optimization")
        
        if let optimization = forecastOptimization {
            XCTAssertGreaterThan(optimization.forecastAccuracy, 0.0, "Should improve forecast accuracy")
            XCTAssertGreaterThan(optimization.optimizedProjections.count, 0, "Should have optimized projections")
        }
    }
    
    // MARK: - Performance Optimization Tests
    
    func testApplicationPerformanceOptimization() async throws {
        await optimizationEngine.enableOptimization()
        
        let performanceOptimizations = await optimizationEngine.optimizeApplicationPerformance()
        XCTAssertGreaterThan(performanceOptimizations.count, 0, "Should provide performance optimizations")
        
        for optimization in performanceOptimizations {
            XCTAssertFalse(optimization.area.isEmpty, "Should specify optimization area")
            XCTAssertGreaterThan(optimization.expectedImprovement, 0.0, "Should show expected improvement")
            XCTAssertGreaterThan(optimization.implementationEffort, 0.0, "Should assess implementation effort")
        }
    }
    
    func testDatabaseOptimization() async throws {
        let databaseOptimizations = await optimizationEngine.optimizeDatabasePerformance()
        XCTAssertNotNil(databaseOptimizations, "Should provide database optimization recommendations")
        
        if let optimizations = databaseOptimizations {
            for recommendation in optimizations.recommendations {
                XCTAssertFalse(recommendation.operation.isEmpty, "Should specify database operation")
                XCTAssertGreaterThan(recommendation.performanceGain, 0.0, "Should show performance gain")
            }
        }
    }
    
    func testMemoryOptimization() async throws {
        let memoryOptimizations = await optimizationEngine.optimizeMemoryUsage()
        XCTAssertGreaterThan(memoryOptimizations.count, 0, "Should provide memory optimization recommendations")
        
        for optimization in memoryOptimizations {
            XCTAssertGreaterThan(optimization.memoryReduction, 0.0, "Should show memory reduction")
            XCTAssertFalse(optimization.technique.isEmpty, "Should specify optimization technique")
        }
    }
    
    func testUIPerformanceOptimization() async throws {
        let uiOptimizations = await optimizationEngine.optimizeUIPerformance()
        XCTAssertNotNil(uiOptimizations, "Should provide UI performance optimizations")
        
        if let optimizations = uiOptimizations {
            for optimization in optimizations.optimizations {
                XCTAssertFalse(optimization.component.isEmpty, "Should specify UI component")
                XCTAssertGreaterThan(optimization.responseTimeImprovement, 0.0, "Should improve response time")
            }
        }
    }
    
    // MARK: - Optimization Tracking and Analytics Tests
    
    func testOptimizationTracking() async throws {
        await optimizationEngine.enableOptimization()
        
        // Track some optimization implementations
        await optimizationEngine.trackOptimizationImplementation("expense_reduction", impact: 150.0)
        await optimizationEngine.trackOptimizationImplementation("tax_optimization", impact: 75.0)
        
        let trackingData = optimizationEngine.getOptimizationTrackingData()
        XCTAssertGreaterThan(trackingData.count, 0, "Should track optimization implementations")
        
        let totalImpact = trackingData.reduce(0) { $0 + $1.impact }
        XCTAssertEqual(totalImpact, 225.0, "Should track cumulative impact")
    }
    
    func testOptimizationROI() async throws {
        let roi = await optimizationEngine.calculateOptimizationROI()
        XCTAssertNotNil(roi, "Should calculate optimization ROI")
        
        if let roiData = roi {
            XCTAssertGreaterThanOrEqual(roiData.roi, 0.0, "ROI should be non-negative")
            XCTAssertGreaterThan(roiData.totalSavings, 0.0, "Should show total savings")
            XCTAssertGreaterThan(roiData.implementationCost, 0.0, "Should account for implementation cost")
        }
    }
    
    func testOptimizationEffectiveness() async throws {
        let effectiveness = await optimizationEngine.analyzeOptimizationEffectiveness()
        XCTAssertNotNil(effectiveness, "Should analyze optimization effectiveness")
        
        if let analysis = effectiveness {
            XCTAssertGreaterThan(analysis.successRate, 0.0, "Should have success rate")
            XCTAssertLessThanOrEqual(analysis.successRate, 1.0, "Success rate should be valid percentage")
            XCTAssertGreaterThan(analysis.averageImpact, 0.0, "Should show average impact")
        }
    }
    
    func testOptimizationProgress() async throws {
        await optimizationEngine.enableOptimization()
        
        // Simulate some optimization progress
        await optimizationEngine.updateOptimizationProgress(0.3)
        XCTAssertEqual(optimizationEngine.optimizationProgress, 0.3, "Should track optimization progress")
        
        await optimizationEngine.updateOptimizationProgress(0.7)
        XCTAssertEqual(optimizationEngine.optimizationProgress, 0.7, "Should update optimization progress")
    }
    
    // MARK: - Advanced Optimization Tests
    
    func testMultiObjectiveOptimization() async throws {
        let multiObjective = await optimizationEngine.performMultiObjectiveOptimization(
            objectives: [.maximizeSavings, .minimizeTaxLiability, .improvePerformance]
        )
        
        XCTAssertNotNil(multiObjective, "Should perform multi-objective optimization")
        
        if let optimization = multiObjective {
            XCTAssertEqual(optimization.objectives.count, 3, "Should optimize for all objectives")
            XCTAssertGreaterThan(optimization.paretoOptimalSolutions.count, 0, "Should find pareto optimal solutions")
        }
    }
    
    func testDynamicOptimization() async throws {
        await optimizationEngine.enableDynamicOptimization()
        
        let dynamicOptimizations = await optimizationEngine.performDynamicOptimization()
        XCTAssertGreaterThan(dynamicOptimizations.count, 0, "Should provide dynamic optimizations")
        
        for optimization in dynamicOptimizations {
            XCTAssertGreaterThan(optimization.adaptability, 0.0, "Should have adaptability score")
            XCTAssertFalse(optimization.triggerConditions.isEmpty, "Should have trigger conditions")
        }
    }
    
    func testConstraintBasedOptimization() async throws {
        let constraints = OptimizationConstraints(
            maxBudgetChange: 0.1,
            minSavingsRate: 0.15,
            maxRiskLevel: 0.3
        )
        
        let constrainedOptimizations = await optimizationEngine.optimizeWithConstraints(constraints)
        XCTAssertGreaterThan(constrainedOptimizations.count, 0, "Should provide constraint-based optimizations")
        
        for optimization in constrainedOptimizations {
            XCTAssertTrue(optimization.satisfiesConstraints, "Should satisfy all constraints")
            XCTAssertLessThanOrEqual(optimization.riskLevel, 0.3, "Should respect risk constraint")
        }
    }
    
    func testPersonalizedOptimization() async throws {
        let userProfile = OptimizationProfile(
            riskTolerance: .moderate,
            timeHorizon: .longTerm,
            primaryGoals: [.taxEfficiency, .wealthAccumulation]
        )
        
        await optimizationEngine.setOptimizationProfile(userProfile)
        
        let personalizedOptimizations = await optimizationEngine.generatePersonalizedOptimizations()
        XCTAssertGreaterThan(personalizedOptimizations.count, 0, "Should provide personalized optimizations")
        
        for optimization in personalizedOptimizations {
            XCTAssertTrue(optimization.isPersonalized, "Should be personalized optimization")
            XCTAssertTrue(optimization.alignsWithGoals, "Should align with user goals")
        }
    }
    
    // MARK: - Performance Tests
    
    func testOptimizationEnginePerformance() async throws {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // Perform multiple optimization operations
        await optimizationEngine.enableOptimization()
        let _ = await optimizationEngine.analyzeExpenseOptimizations()
        let _ = await optimizationEngine.optimizeAustralianTaxes()
        let _ = await optimizationEngine.optimizeBudgetAllocations()
        
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        XCTAssertLessThan(timeElapsed, 2.0, "Optimization operations should be performant")
    }
    
    func testOptimizationMemoryUsage() async throws {
        let initialMemory = getCurrentMemoryUsage()
        
        // Perform memory-intensive optimization operations
        await optimizationEngine.enableOptimization()
        for _ in 1...10 {
            let _ = await optimizationEngine.analyzeExpenseOptimizations()
        }
        
        let finalMemory = getCurrentMemoryUsage()
        let memoryIncrease = finalMemory - initialMemory
        
        XCTAssertLessThan(memoryIncrease, 50_000_000, "Memory usage should be reasonable") // 50MB limit
    }
    
    func testOptimizationCaching() async throws {
        // First optimization run - should be slower
        let start1 = CFAbsoluteTimeGetCurrent()
        let optimizations1 = await optimizationEngine.analyzeExpenseOptimizations()
        let time1 = CFAbsoluteTimeGetCurrent() - start1
        
        // Second optimization run - should be faster (cached)
        let start2 = CFAbsoluteTimeGetCurrent()
        let optimizations2 = await optimizationEngine.analyzeExpenseOptimizations()
        let time2 = CFAbsoluteTimeGetCurrent() - start2
        
        XCTAssertLessThan(time2, time1, "Cached optimization should be faster")
        XCTAssertEqual(optimizations1.count, optimizations2.count, "Cached results should match")
    }
    
    // MARK: - Error Handling Tests
    
    func testOptimizationWithInvalidData() async throws {
        // Clear all test data to simulate empty state
        await clearTestData()
        
        let optimizations = await optimizationEngine.analyzeExpenseOptimizations()
        XCTAssertTrue(optimizations.isEmpty, "Should handle empty data gracefully")
        
        let taxOptimizations = await optimizationEngine.optimizeAustralianTaxes()
        XCTAssertTrue(taxOptimizations.isEmpty, "Should handle empty data for tax optimizations")
    }
    
    func testOptimizationEngineWithCorruptedSettings() {
        // Test with corrupted optimization settings
        mockUserDefaults.set("invalid_data", forKey: "optimizationSettings")
        
        let engineWithCorruptedData = OptimizationEngine(context: testContext, userDefaults: mockUserDefaults)
        
        XCTAssertNotNil(engineWithCorruptedData, "Should handle corrupted settings gracefully")
        XCTAssertFalse(engineWithCorruptedData.isOptimizationEnabled, "Should start with default state")
    }
    
    func testConcurrentOptimizationOperations() async throws {
        await optimizationEngine.enableOptimization()
        
        // Test concurrent optimization requests
        await withTaskGroup(of: Void.self) { group in
            for i in 1...5 {
                group.addTask {
                    let _ = await self.optimizationEngine.analyzeExpenseOptimizations()
                    let _ = await self.optimizationEngine.optimizeAustralianTaxes()
                }
            }
        }
        
        // Verify engine remains stable
        XCTAssertTrue(optimizationEngine.isOptimizationEnabled, "Optimization engine should remain stable after concurrent access")
    }
    
    // MARK: - Helper Methods
    
    private func createSampleTransactionData() async {
        let sampleTransactions = [
            ("Office rent", 2000.0, "Business"),
            ("Client lunch", 125.0, "Business"),
            ("Groceries", 85.0, "Personal"),
            ("Gas bill", 180.0, "Personal"),
            ("Software license", 99.0, "Business"),
            ("Restaurant dinner", 67.0, "Personal"),
            ("Business insurance", 350.0, "Business"),
            ("Gym membership", 59.0, "Personal"),
            ("Office supplies", 75.0, "Business"),
            ("Internet bill", 89.0, "Personal")
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
    
    private func clearTestData() async {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Transaction.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        try? testContext.execute(deleteRequest)
        try? testContext.save()
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