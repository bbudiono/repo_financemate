//
// UserJourneyOptimizationViewModelTests.swift
// FinanceMateTests
//
// Comprehensive User Journey Optimization Test Suite
// Created: 2025-07-07
// Target: FinanceMateTests
//

/*
 * Purpose: Comprehensive test suite for UserJourneyOptimizationViewModel with journey analytics and performance optimization
 * Issues & Complexity Summary: Complex analytics tracking, performance optimization algorithms, A/B testing framework
 * Key Complexity Drivers:
   - Logic Scope (Est. LoC): ~400
   - Core Algorithm Complexity: Very High
   - Dependencies: UserDefaults, Core Data, analytics systems, A/B testing framework
   - State Management Complexity: Very High (journey state, analytics data, performance metrics, A/B test variants)
   - Novelty/Uncertainty Factor: High (user behavior analytics, conversion optimization, performance analysis)
 * AI Pre-Task Self-Assessment: 90%
 * Problem Estimate: 95%
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
class UserJourneyOptimizationViewModelTests: XCTestCase {
    
    var journeyOptimizationViewModel: UserJourneyOptimizationViewModel!
    var mockUserDefaults: UserDefaults!
    var testContext: NSManagedObjectContext!
    
    override func setUp() async throws {
        try await super.setUp()
        
        // Create isolated UserDefaults for testing
        mockUserDefaults = UserDefaults(suiteName: "UserJourneyOptimizationTests")!
        mockUserDefaults.removePersistentDomain(forName: "UserJourneyOptimizationTests")
        
        // Set up Core Data test context
        testContext = PersistenceController.preview.container.viewContext
        
        // Initialize journey optimization view model
        journeyOptimizationViewModel = UserJourneyOptimizationViewModel(
            context: testContext,
            userDefaults: mockUserDefaults
        )
    }
    
    override func tearDown() async throws {
        // Clean up UserDefaults
        mockUserDefaults.removePersistentDomain(forName: "UserJourneyOptimizationTests")
        
        journeyOptimizationViewModel = nil
        mockUserDefaults = nil
        testContext = nil
        try await super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testUserJourneyOptimizationViewModelInitialization() {
        XCTAssertNotNil(journeyOptimizationViewModel, "UserJourneyOptimizationViewModel should initialize successfully")
        XCTAssertEqual(journeyOptimizationViewModel.currentJourneyState, .notStarted, "Should start with not started state")
        XCTAssertFalse(journeyOptimizationViewModel.isOptimizationEnabled, "Optimization should be disabled initially")
    }
    
    func testJourneyTrackingInitialization() {
        let journeyData = journeyOptimizationViewModel.getCurrentJourneyData()
        XCTAssertNotNil(journeyData, "Should have journey data available")
        XCTAssertEqual(journeyData.currentStep, .welcome, "Should start at welcome step")
        XCTAssertEqual(journeyData.completedSteps.count, 0, "No steps should be completed initially")
    }
    
    // MARK: - User Journey Tracking Tests
    
    func testJourneyStepProgression() async throws {
        // Start journey
        await journeyOptimizationViewModel.startUserJourney()
        XCTAssertEqual(journeyOptimizationViewModel.currentJourneyState, .inProgress, "Journey should be in progress")
        
        // Progress through steps
        await journeyOptimizationViewModel.completeJourneyStep(.welcome)
        let journeyData = journeyOptimizationViewModel.getCurrentJourneyData()
        XCTAssertTrue(journeyData.completedSteps.contains(.welcome), "Welcome step should be completed")
        
        await journeyOptimizationViewModel.completeJourneyStep(.coreFeatures)
        XCTAssertTrue(journeyData.completedSteps.contains(.coreFeatures), "Core features step should be completed")
    }
    
    func testJourneyCompletionTracking() async throws {
        // Complete all journey steps
        await journeyOptimizationViewModel.startUserJourney()
        
        let allSteps: [JourneyStep] = [.welcome, .coreFeatures, .interactiveDemo, .taxEducation, .samplePlayground, .completion]
        for step in allSteps {
            await journeyOptimizationViewModel.completeJourneyStep(step)
        }
        
        XCTAssertEqual(journeyOptimizationViewModel.currentJourneyState, .completed, "Journey should be completed")
        
        let completionRate = await journeyOptimizationViewModel.calculateJourneyCompletionRate()
        XCTAssertEqual(completionRate, 1.0, accuracy: 0.01, "Journey completion rate should be 100%")
    }
    
    func testJourneyAbandonmentTracking() async throws {
        await journeyOptimizationViewModel.startUserJourney()
        await journeyOptimizationViewModel.completeJourneyStep(.welcome)
        await journeyOptimizationViewModel.completeJourneyStep(.coreFeatures)
        
        // Simulate abandonment
        await journeyOptimizationViewModel.recordJourneyAbandonment(.taxEducation, reason: "Complex interface")
        
        let abandonmentData = journeyOptimizationViewModel.getAbandonmentAnalytics()
        XCTAssertGreaterThan(abandonmentData.count, 0, "Should track abandonment data")
        XCTAssertTrue(abandonmentData.contains(where: { $0.step == .taxEducation }), "Should track tax education abandonment")
    }
    
    // MARK: - Performance Optimization Tests
    
    func testPerformanceMetricsTracking() async throws {
        // Track step completion time
        let startTime = Date()
        await journeyOptimizationViewModel.startUserJourney()
        await journeyOptimizationViewModel.trackStepPerformance(.welcome, startTime: startTime, endTime: Date())
        
        let performanceData = journeyOptimizationViewModel.getPerformanceMetrics()
        XCTAssertGreaterThan(performanceData.stepCompletionTimes.count, 0, "Should track step performance")
        XCTAssertNotNil(performanceData.stepCompletionTimes[.welcome], "Should have welcome step timing")
    }
    
    func testPerformanceOptimizationRecommendations() async throws {
        // Simulate slow performance data
        await journeyOptimizationViewModel.trackStepPerformance(.interactiveDemo, startTime: Date(), endTime: Date().addingTimeInterval(30))
        await journeyOptimizationViewModel.trackStepPerformance(.taxEducation, startTime: Date(), endTime: Date().addingTimeInterval(45))
        
        let recommendations = await journeyOptimizationViewModel.generateOptimizationRecommendations()
        XCTAssertGreaterThan(recommendations.count, 0, "Should generate optimization recommendations")
        
        let slowStepRecommendations = recommendations.filter { $0.targetStep == .interactiveDemo || $0.targetStep == .taxEducation }
        XCTAssertGreaterThan(slowStepRecommendations.count, 0, "Should recommend optimizations for slow steps")
    }
    
    func testMemoryUsageOptimization() async throws {
        // Simulate memory-intensive operations
        await journeyOptimizationViewModel.trackMemoryUsage(.samplePlayground, memoryUsage: 120.0) // 120MB
        await journeyOptimizationViewModel.trackMemoryUsage(.interactiveDemo, memoryUsage: 95.0) // 95MB
        
        let memoryOptimizations = await journeyOptimizationViewModel.analyzeMemoryUsage()
        XCTAssertGreaterThan(memoryOptimizations.count, 0, "Should provide memory optimization insights")
        
        let highMemorySteps = memoryOptimizations.filter { $0.memoryUsage > 100.0 }
        XCTAssertGreaterThan(highMemorySteps.count, 0, "Should identify high memory usage steps")
    }
    
    // MARK: - Conversion Funnel Analysis Tests
    
    func testConversionFunnelTracking() async throws {
        // Track conversion funnel
        await journeyOptimizationViewModel.trackFunnelEntry(.onboardingStart)
        await journeyOptimizationViewModel.trackFunnelProgress(.onboardingStart, .firstTransaction)
        await journeyOptimizationViewModel.trackFunnelProgress(.firstTransaction, .firstSplit)
        await journeyOptimizationViewModel.trackFunnelCompletion(.firstSplit, .activeUser)
        
        let funnelData = journeyOptimizationViewModel.getConversionFunnelData()
        XCTAssertGreaterThan(funnelData.entries.count, 0, "Should track funnel entries")
        XCTAssertGreaterThan(funnelData.progressions.count, 0, "Should track funnel progressions")
        XCTAssertGreaterThan(funnelData.completions.count, 0, "Should track funnel completions")
    }
    
    func testConversionRateCalculation() async throws {
        // Track multiple users through funnel
        for i in 1...10 {
            await journeyOptimizationViewModel.trackFunnelEntry(.onboardingStart)
            if i <= 8 { // 80% complete first step
                await journeyOptimizationViewModel.trackFunnelProgress(.onboardingStart, .firstTransaction)
                if i <= 6 { // 60% complete second step
                    await journeyOptimizationViewModel.trackFunnelProgress(.firstTransaction, .firstSplit)
                    if i <= 4 { // 40% complete final step
                        await journeyOptimizationViewModel.trackFunnelCompletion(.firstSplit, .activeUser)
                    }
                }
            }
        }
        
        let conversionRates = await journeyOptimizationViewModel.calculateConversionRates()
        XCTAssertEqual(conversionRates.onboardingToTransaction, 0.8, accuracy: 0.01, "Should calculate 80% conversion rate")
        XCTAssertEqual(conversionRates.transactionToSplit, 0.75, accuracy: 0.01, "Should calculate 75% conversion rate") // 6/8
        XCTAssertEqual(conversionRates.splitToActive, 0.67, accuracy: 0.02, "Should calculate 67% conversion rate") // 4/6
    }
    
    func testFunnelBottleneckIdentification() async throws {
        // Create funnel with bottleneck at tax education
        await journeyOptimizationViewModel.trackFunnelEntry(.onboardingStart)
        await journeyOptimizationViewModel.trackFunnelProgress(.onboardingStart, .firstTransaction)
        // High drop-off at tax education step
        for _ in 1...10 {
            await journeyOptimizationViewModel.trackFunnelEntry(.taxEducationStart)
            // Only 20% complete tax education
            if Int.random(in: 1...10) <= 2 {
                await journeyOptimizationViewModel.trackFunnelCompletion(.taxEducationStart, .taxEducationComplete)
            }
        }
        
        let bottlenecks = await journeyOptimizationViewModel.identifyFunnelBottlenecks()
        XCTAssertGreaterThan(bottlenecks.count, 0, "Should identify funnel bottlenecks")
        
        let taxEducationBottleneck = bottlenecks.first { $0.step == .taxEducationStart }
        XCTAssertNotNil(taxEducationBottleneck, "Should identify tax education as bottleneck")
        XCTAssertLessThan(taxEducationBottleneck!.conversionRate, 0.5, "Tax education should have low conversion rate")
    }
    
    // MARK: - Feature Adoption Rate Tests
    
    func testFeatureAdoptionTracking() async throws {
        // Track feature usage
        await journeyOptimizationViewModel.trackFeatureUsage(.lineItemSplitting, userId: "user1")
        await journeyOptimizationViewModel.trackFeatureUsage(.advancedAnalytics, userId: "user1")
        await journeyOptimizationViewModel.trackFeatureUsage(.lineItemSplitting, userId: "user2")
        
        let adoptionRates = journeyOptimizationViewModel.getFeatureAdoptionRates()
        XCTAssertGreaterThan(adoptionRates.count, 0, "Should track feature adoption rates")
        
        let splittingAdoption = adoptionRates[.lineItemSplitting]
        XCTAssertNotNil(splittingAdoption, "Should track line item splitting adoption")
        XCTAssertEqual(splittingAdoption?.uniqueUsers, 2, "Should track 2 unique users for splitting")
    }
    
    func testFeatureAdoptionOptimization() async throws {
        // Track low adoption feature
        await journeyOptimizationViewModel.trackFeatureUsage(.reportGeneration, userId: "user1")
        // High adoption feature
        for i in 1...10 {
            await journeyOptimizationViewModel.trackFeatureUsage(.basicTransactionManagement, userId: "user\(i)")
        }
        
        let optimizations = await journeyOptimizationViewModel.generateFeatureAdoptionOptimizations()
        XCTAssertGreaterThan(optimizations.count, 0, "Should generate adoption optimizations")
        
        let reportOptimization = optimizations.first { $0.feature == .reportGeneration }
        XCTAssertNotNil(reportOptimization, "Should optimize low-adoption features")
        XCTAssertEqual(reportOptimization?.optimizationType, .discoverabilityImprovement, "Should recommend discoverability improvement")
    }
    
    func testFeatureUsagePatternAnalysis() async throws {
        // Create usage patterns
        let timeOfDay = Calendar.current.component(.hour, from: Date())
        await journeyOptimizationViewModel.trackFeatureUsageWithTime(.lineItemSplitting, userId: "user1", timestamp: Date())
        await journeyOptimizationViewModel.trackFeatureUsageWithTime(.advancedAnalytics, userId: "user1", timestamp: Date().addingTimeInterval(3600))
        
        let patterns = await journeyOptimizationViewModel.analyzeFeatureUsagePatterns()
        XCTAssertGreaterThan(patterns.count, 0, "Should analyze usage patterns")
        
        let timeBasedPattern = patterns.first { $0.patternType == .timeOfDay }
        XCTAssertNotNil(timeBasedPattern, "Should identify time-based usage patterns")
    }
    
    // MARK: - A/B Testing Framework Tests
    
    func testABTestVariantAssignment() async throws {
        // Create A/B test
        let test = ABTest(
            name: "OnboardingFlow",
            variants: ["Control", "Simplified", "Gamified"],
            trafficAllocation: [0.34, 0.33, 0.33]
        )
        
        await journeyOptimizationViewModel.createABTest(test)
        
        // Assign users to variants
        let variant1 = await journeyOptimizationViewModel.assignUserToVariant("OnboardingFlow", userId: "user1")
        let variant2 = await journeyOptimizationViewModel.assignUserToVariant("OnboardingFlow", userId: "user2")
        
        XCTAssertNotNil(variant1, "Should assign user to variant")
        XCTAssertNotNil(variant2, "Should assign user to variant")
        XCTAssertTrue(test.variants.contains(variant1!), "Should assign valid variant")
        XCTAssertTrue(test.variants.contains(variant2!), "Should assign valid variant")
    }
    
    func testABTestResultTracking() async throws {
        let test = ABTest(
            name: "TaxEducationApproach",
            variants: ["Traditional", "Interactive"],
            trafficAllocation: [0.5, 0.5]
        )
        
        await journeyOptimizationViewModel.createABTest(test)
        
        // Track conversions for variants
        await journeyOptimizationViewModel.trackABTestConversion("TaxEducationApproach", variant: "Traditional", userId: "user1", converted: true)
        await journeyOptimizationViewModel.trackABTestConversion("TaxEducationApproach", variant: "Traditional", userId: "user2", converted: false)
        await journeyOptimizationViewModel.trackABTestConversion("TaxEducationApproach", variant: "Interactive", userId: "user3", converted: true)
        await journeyOptimizationViewModel.trackABTestConversion("TaxEducationApproach", variant: "Interactive", userId: "user4", converted: true)
        
        let results = await journeyOptimizationViewModel.getABTestResults("TaxEducationApproach")
        XCTAssertNotNil(results, "Should have A/B test results")
        XCTAssertEqual(results!.variantResults["Traditional"]?.conversionRate, 0.5, accuracy: 0.01, "Traditional should have 50% conversion")
        XCTAssertEqual(results!.variantResults["Interactive"]?.conversionRate, 1.0, accuracy: 0.01, "Interactive should have 100% conversion")
    }
    
    func testABTestStatisticalSignificance() async throws {
        let test = ABTest(
            name: "AnalyticsPresentation",
            variants: ["Charts", "Tables"],
            trafficAllocation: [0.5, 0.5]
        )
        
        await journeyOptimizationViewModel.createABTest(test)
        
        // Generate statistically significant sample
        for i in 1...100 {
            let variant = i <= 50 ? "Charts" : "Tables"
            let converted = variant == "Charts" ? (i % 4 != 0) : (i % 3 != 0) // Charts: 75%, Tables: 67%
            await journeyOptimizationViewModel.trackABTestConversion("AnalyticsPresentation", variant: variant, userId: "user\(i)", converted: converted)
        }
        
        let significance = await journeyOptimizationViewModel.calculateStatisticalSignificance("AnalyticsPresentation")
        XCTAssertNotNil(significance, "Should calculate statistical significance")
        XCTAssertGreaterThan(significance!.confidenceLevel, 0.8, "Should have reasonable confidence level")
    }
    
    // MARK: - Journey Completion Rate Analytics Tests
    
    func testJourneyCompletionRateAnalytics() async throws {
        // Simulate multiple user journeys
        for i in 1...20 {
            await journeyOptimizationViewModel.simulateUserJourney(userId: "user\(i)", completionRate: i <= 15 ? 1.0 : 0.6)
        }
        
        let analytics = await journeyOptimizationViewModel.getJourneyCompletionAnalytics()
        XCTAssertGreaterThanOrEqual(analytics.overallCompletionRate, 0.75, "Should have reasonable completion rate")
        XCTAssertGreaterThan(analytics.stepCompletionRates.count, 0, "Should track step-by-step completion rates")
    }
    
    func testAustralianTaxComplianceJourneyTracking() async throws {
        // Track tax-specific journey elements
        await journeyOptimizationViewModel.trackTaxComplianceJourney(.gstSetup, completed: true)
        await journeyOptimizationViewModel.trackTaxComplianceJourney(.businessCategorySetup, completed: true)
        await journeyOptimizationViewModel.trackTaxComplianceJourney(.investmentCategorySetup, completed: false)
        
        let taxComplianceData = journeyOptimizationViewModel.getTaxComplianceJourneyData()
        XCTAssertNotNil(taxComplianceData, "Should track tax compliance journey")
        XCTAssertEqual(taxComplianceData.completedComponents.count, 2, "Should track completed tax components")
        XCTAssertTrue(taxComplianceData.completedComponents.contains(.gstSetup), "Should track GST setup completion")
    }
    
    func testJourneySegmentationAnalysis() async throws {
        // Create user segments
        await journeyOptimizationViewModel.trackUserSegment("user1", segment: .businessOwner)
        await journeyOptimizationViewModel.trackUserSegment("user2", segment: .investor)
        await journeyOptimizationViewModel.trackUserSegment("user3", segment: .individual)
        
        // Track completion by segment
        await journeyOptimizationViewModel.simulateSegmentedJourney("user1", segment: .businessOwner, completionRate: 0.9)
        await journeyOptimizationViewModel.simulateSegmentedJourney("user2", segment: .investor, completionRate: 0.8)
        await journeyOptimizationViewModel.simulateSegmentedJourney("user3", segment: .individual, completionRate: 0.7)
        
        let segmentAnalysis = await journeyOptimizationViewModel.getSegmentationAnalysis()
        XCTAssertGreaterThan(segmentAnalysis.count, 0, "Should analyze completion by user segment")
        
        let businessOwnerAnalysis = segmentAnalysis[.businessOwner]
        XCTAssertNotNil(businessOwnerAnalysis, "Should have business owner analysis")
        XCTAssertGreaterThan(businessOwnerAnalysis!.completionRate, 0.8, "Business owners should have high completion rate")
    }
    
    // MARK: - Accessibility Optimization Tests
    
    func testAccessibilityOptimizationTracking() async throws {
        // Track accessibility-related journey issues
        await journeyOptimizationViewModel.trackAccessibilityIssue(.voiceOverNavigation, step: .taxEducation, severity: .medium)
        await journeyOptimizationViewModel.trackAccessibilityIssue(.keyboardNavigation, step: .interactiveDemo, severity: .high)
        
        let accessibilityData = journeyOptimizationViewModel.getAccessibilityOptimizationData()
        XCTAssertGreaterThan(accessibilityData.identifiedIssues.count, 0, "Should track accessibility issues")
        
        let highSeverityIssues = accessibilityData.identifiedIssues.filter { $0.severity == .high }
        XCTAssertGreaterThan(highSeverityIssues.count, 0, "Should identify high severity accessibility issues")
    }
    
    func testAccessibilityImprovementRecommendations() async throws {
        // Track accessibility usage patterns
        await journeyOptimizationViewModel.trackAccessibilityFeatureUsage(.voiceOver, enabled: true, completionImpact: 0.2)
        await journeyOptimizationViewModel.trackAccessibilityFeatureUsage(.largeText, enabled: true, completionImpact: 0.1)
        
        let recommendations = await journeyOptimizationViewModel.generateAccessibilityImprovements()
        XCTAssertGreaterThan(recommendations.count, 0, "Should generate accessibility improvement recommendations")
        
        let voiceOverRecommendation = recommendations.first { $0.feature == .voiceOver }
        XCTAssertNotNil(voiceOverRecommendation, "Should recommend VoiceOver improvements")
    }
    
    func testInclusiveDesignMetrics() async throws {
        // Track inclusive design effectiveness
        await journeyOptimizationViewModel.trackInclusiveDesignMetric(.colorContrastCompliance, value: 0.95, step: .dashboard)
        await journeyOptimizationViewModel.trackInclusiveDesignMetric(.keyboardNavigationEfficiency, value: 0.88, step: .transactionEntry)
        
        let inclusiveMetrics = journeyOptimizationViewModel.getInclusiveDesignMetrics()
        XCTAssertGreaterThan(inclusiveMetrics.count, 0, "Should track inclusive design metrics")
        
        let contrastMetric = inclusiveMetrics.first { $0.metricType == .colorContrastCompliance }
        XCTAssertNotNil(contrastMetric, "Should track color contrast compliance")
        XCTAssertGreaterThan(contrastMetric!.value, 0.9, "Should have high contrast compliance")
    }
    
    // MARK: - Performance Monitoring Tests
    
    func testRealTimePerformanceMonitoring() async throws {
        // Simulate real-time performance tracking
        await journeyOptimizationViewModel.startPerformanceMonitoring()
        
        // Track various performance metrics
        await journeyOptimizationViewModel.recordPerformanceMetric(.responseTime, value: 150.0, context: "Dashboard load")
        await journeyOptimizationViewModel.recordPerformanceMetric(.memoryUsage, value: 85.0, context: "Transaction list")
        await journeyOptimizationViewModel.recordPerformanceMetric(.renderTime, value: 16.7, context: "Chart animation")
        
        let performanceData = journeyOptimizationViewModel.getRealTimePerformanceData()
        XCTAssertGreaterThan(performanceData.metrics.count, 0, "Should collect performance metrics")
        
        let responseTimeMetrics = performanceData.metrics.filter { $0.type == .responseTime }
        XCTAssertGreaterThan(responseTimeMetrics.count, 0, "Should track response time metrics")
    }
    
    func testPerformanceAlertGeneration() async throws {
        // Create performance degradation
        await journeyOptimizationViewModel.recordPerformanceMetric(.responseTime, value: 5000.0, context: "Slow analytics load")
        await journeyOptimizationViewModel.recordPerformanceMetric(.memoryUsage, value: 250.0, context: "Memory leak scenario")
        
        let alerts = await journeyOptimizationViewModel.generatePerformanceAlerts()
        XCTAssertGreaterThan(alerts.count, 0, "Should generate performance alerts")
        
        let criticalAlerts = alerts.filter { $0.severity == .critical }
        XCTAssertGreaterThan(criticalAlerts.count, 0, "Should generate critical alerts for severe performance issues")
    }
    
    func testPerformanceTrendAnalysis() async throws {
        // Create performance trend over time
        let baseTime = Date()
        for i in 1...10 {
            let timestamp = baseTime.addingTimeInterval(TimeInterval(i * 60)) // Every minute
            let degradingPerformance = 100.0 + Double(i * 20) // Gradually degrading
            await journeyOptimizationViewModel.recordPerformanceMetricWithTimestamp(.responseTime, value: degradingPerformance, timestamp: timestamp)
        }
        
        let trends = await journeyOptimizationViewModel.analyzePerformanceTrends()
        XCTAssertGreaterThan(trends.count, 0, "Should analyze performance trends")
        
        let responseTimeTrend = trends.first { $0.metricType == .responseTime }
        XCTAssertNotNil(responseTimeTrend, "Should track response time trends")
        XCTAssertEqual(responseTimeTrend!.trendDirection, .degrading, "Should identify degrading performance trend")
    }
    
    // MARK: - Error Handling and Edge Cases Tests
    
    func testInvalidJourneyStateHandling() async throws {
        // Attempt invalid state transitions
        await journeyOptimizationViewModel.completeJourneyStep(.completion) // Complete without starting
        XCTAssertEqual(journeyOptimizationViewModel.currentJourneyState, .notStarted, "Should handle invalid transitions gracefully")
        
        // Start journey and attempt double completion
        await journeyOptimizationViewModel.startUserJourney()
        await journeyOptimizationViewModel.completeJourneyStep(.welcome)
        await journeyOptimizationViewModel.completeJourneyStep(.welcome) // Duplicate completion
        
        let journeyData = journeyOptimizationViewModel.getCurrentJourneyData()
        XCTAssertEqual(journeyData.completedSteps.filter { $0 == .welcome }.count, 1, "Should not duplicate step completions")
    }
    
    func testCorruptedAnalyticsDataHandling() {
        // Test with corrupted UserDefaults data
        mockUserDefaults.set("invalid_json_data", forKey: "journeyAnalyticsData")
        
        let viewModel = UserJourneyOptimizationViewModel(context: testContext, userDefaults: mockUserDefaults)
        let journeyData = viewModel.getCurrentJourneyData()
        
        XCTAssertNotNil(journeyData, "Should handle corrupted data gracefully")
        XCTAssertEqual(journeyData.completedSteps.count, 0, "Should start fresh with corrupted data")
    }
    
    func testHighVolumeDataPerformance() async throws {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // Process high volume of analytics data
        for i in 1...1000 {
            await journeyOptimizationViewModel.trackFeatureUsage(.lineItemSplitting, userId: "user\(i)")
            if i % 100 == 0 {
                await journeyOptimizationViewModel.trackFunnelEntry(.onboardingStart)
            }
        }
        
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        XCTAssertLessThan(timeElapsed, 5.0, "High volume data processing should be performant")
        
        let adoptionRates = journeyOptimizationViewModel.getFeatureAdoptionRates()
        XCTAssertGreaterThan(adoptionRates.count, 0, "Should handle high volume data correctly")
    }
    
    // MARK: - Persistence and State Management Tests
    
    func testJourneyDataPersistence() async throws {
        // Track journey progress
        await journeyOptimizationViewModel.startUserJourney()
        await journeyOptimizationViewModel.completeJourneyStep(.welcome)
        await journeyOptimizationViewModel.completeJourneyStep(.coreFeatures)
        
        // Create new view model to test persistence
        let newViewModel = UserJourneyOptimizationViewModel(context: testContext, userDefaults: mockUserDefaults)
        let persistedData = newViewModel.getCurrentJourneyData()
        
        XCTAssertEqual(persistedData.completedSteps.count, 2, "Journey progress should be persisted")
        XCTAssertTrue(persistedData.completedSteps.contains(.welcome), "Welcome step should be persisted")
        XCTAssertTrue(persistedData.completedSteps.contains(.coreFeatures), "Core features step should be persisted")
    }
    
    func testAnalyticsDataPersistence() async throws {
        // Track analytics data
        await journeyOptimizationViewModel.trackFeatureUsage(.advancedAnalytics, userId: "test_user")
        await journeyOptimizationViewModel.trackFunnelEntry(.onboardingStart)
        
        // Create new view model to test persistence
        let newViewModel = UserJourneyOptimizationViewModel(context: testContext, userDefaults: mockUserDefaults)
        let adoptionRates = newViewModel.getFeatureAdoptionRates()
        let funnelData = newViewModel.getConversionFunnelData()
        
        XCTAssertGreaterThan(adoptionRates.count, 0, "Feature adoption data should be persisted")
        XCTAssertGreaterThan(funnelData.entries.count, 0, "Funnel data should be persisted")
    }
    
    func testDataMigrationHandling() {
        // Test migration from older data format
        let legacyData = ["journey_state": "in_progress", "completed_steps": ["welcome"]]
        mockUserDefaults.set(legacyData, forKey: "legacyJourneyData")
        
        let viewModel = UserJourneyOptimizationViewModel(context: testContext, userDefaults: mockUserDefaults)
        
        // Should handle legacy data gracefully
        XCTAssertNotNil(viewModel, "Should initialize with legacy data")
        XCTAssertNotEqual(viewModel.currentJourneyState, .error, "Should not be in error state with legacy data")
    }
}