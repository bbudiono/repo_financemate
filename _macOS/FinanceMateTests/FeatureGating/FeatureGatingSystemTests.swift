//
// FeatureGatingSystemTests.swift
// FinanceMateTests
//
// Advanced Feature Gating System Tests
// Created: 2025-07-07
// Target: FinanceMateTests
//

/*
 * Purpose: Comprehensive test suite for intelligent feature gating and progressive disclosure
 * Issues & Complexity Summary: User competency assessment, adaptive UI, feature unlocking algorithms
 * Key Complexity Drivers:
   - Logic Scope (Est. LoC): ~350
   - Core Algorithm Complexity: High
   - Dependencies: UserJourneyTracker, OnboardingViewModel, UI adaptation patterns
   - State Management Complexity: High (competency scoring, feature states, UI adaptation)
   - Novelty/Uncertainty Factor: Medium (adaptive UX patterns, progressive disclosure)
 * AI Pre-Task Self-Assessment: 85%
 * Problem Estimate: 88%
 * Initial Code Complexity Estimate: 90%
 * Final Code Complexity: TBD
 * Overall Result Score: TBD
 * Key Variances/Learnings: TBD
 * Last Updated: 2025-07-07
 */

import XCTest
import CoreData
@testable import FinanceMate

@MainActor
final class FeatureGatingSystemTests: XCTestCase {
    
    // MARK: - Test Properties
    var featureGatingSystem: FeatureGatingSystem!
    var testContext: NSManagedObjectContext!
    var userJourneyTracker: UserJourneyTracker!
    var analyticsEngine: AnalyticsEngine!
    
    override func setUp() {
        super.setUp()
        testContext = PersistenceController.preview.container.viewContext
        analyticsEngine = AnalyticsEngine(context: testContext)
        userJourneyTracker = UserJourneyTracker(context: testContext, analyticsEngine: analyticsEngine, userID: "test_user")
        featureGatingSystem = FeatureGatingSystem(userJourneyTracker: userJourneyTracker)
    }
    
    override func tearDown() {
        featureGatingSystem = nil
        userJourneyTracker = nil
        analyticsEngine = nil
        testContext = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testFeatureGatingSystemInitialization() {
        XCTAssertNotNil(featureGatingSystem, "FeatureGatingSystem should initialize successfully")
        XCTAssertEqual(featureGatingSystem.currentUserLevel, .novice, "Initial user level should be novice")
        XCTAssertTrue(featureGatingSystem.availableFeatures.isEmpty, "Available features should be empty initially")
        XCTAssertFalse(featureGatingSystem.isAdvancedFeaturesUnlocked, "Advanced features should be locked initially")
    }
    
    // MARK: - User Competency Calculation Tests
    
    func testCompetencyCalculationForNoviceUser() {
        // Given: New user with minimal activity
        userJourneyTracker.trackEvent(.onboardingStarted)
        userJourneyTracker.trackEvent(.welcomeScreenViewed)
        
        // When: Calculating competency
        let competencyScore = featureGatingSystem.calculateUserCompetencyScore()
        
        // Then: Should have low competency score
        XCTAssertLessThan(competencyScore, 0.3, "Novice user should have low competency score")
        XCTAssertEqual(featureGatingSystem.currentUserLevel, .novice, "User should remain at novice level")
    }
    
    func testCompetencyCalculationForIntermediateUser() {
        // Given: User with some transaction and split allocation experience
        simulateIntermediateUserActivity()
        
        // When: Calculating competency
        let competencyScore = featureGatingSystem.calculateUserCompetencyScore()
        
        // Then: Should have intermediate competency score
        XCTAssertGreaterThan(competencyScore, 0.3, "Intermediate user should have higher competency")
        XCTAssertLessThan(competencyScore, 0.7, "Intermediate user should not reach expert level")
        XCTAssertEqual(featureGatingSystem.currentUserLevel, .intermediate, "User should be at intermediate level")
    }
    
    func testCompetencyCalculationForExpertUser() {
        // Given: User with extensive feature usage and advanced operations
        simulateExpertUserActivity()
        
        // When: Calculating competency
        let competencyScore = featureGatingSystem.calculateUserCompetencyScore()
        
        // Then: Should have high competency score
        XCTAssertGreaterThan(competencyScore, 0.7, "Expert user should have high competency score")
        XCTAssertEqual(featureGatingSystem.currentUserLevel, .expert, "User should reach expert level")
    }
    
    func testCompetencyScoreFactors() {
        // Given: User with specific activity patterns
        userJourneyTracker.trackEvent(.transactionCreated, metadata: ["complexity": "simple"])
        userJourneyTracker.trackEvent(.splitAllocationUsed, metadata: ["categories": "2", "success": "true"])
        userJourneyTracker.trackEvent(.reportGenerated, metadata: ["type": "basic"])
        
        // When: Analyzing competency factors
        let competencyFactors = featureGatingSystem.analyzeCompetencyFactors()
        
        // Then: Should identify specific competency areas
        XCTAssertGreaterThan(competencyFactors.transactionManagementScore, 0.0, "Should have transaction management competency")
        XCTAssertGreaterThan(competencyFactors.splitAllocationScore, 0.0, "Should have split allocation competency")
        XCTAssertGreaterThan(competencyFactors.reportingScore, 0.0, "Should have reporting competency")
        XCTAssertEqual(competencyFactors.overallScore, featureGatingSystem.calculateUserCompetencyScore(), "Overall score should match calculated competency")
    }
    
    // MARK: - Feature Unlock Progression Tests
    
    func testBasicFeatureUnlockProgression() {
        // Given: Novice user completing onboarding
        userJourneyTracker.trackEvent(.onboardingCompleted)
        
        // When: Updating feature availability
        featureGatingSystem.updateFeatureAvailability()
        
        // Then: Basic features should be unlocked
        XCTAssertTrue(featureGatingSystem.isFeatureAvailable(.basicTransactionEntry), "Basic transaction entry should be available")
        XCTAssertTrue(featureGatingSystem.isFeatureAvailable(.simpleReporting), "Simple reporting should be available")
        XCTAssertFalse(featureGatingSystem.isFeatureAvailable(.advancedSplitAllocation), "Advanced split allocation should remain locked")
        XCTAssertFalse(featureGatingSystem.isFeatureAvailable(.complexTaxCategories), "Complex tax categories should remain locked")
    }
    
    func testIntermediateFeatureUnlockProgression() {
        // Given: User progressing to intermediate level
        simulateIntermediateUserActivity()
        featureGatingSystem.updateFeatureAvailability()
        
        // When: Checking available features
        let availableFeatures = featureGatingSystem.availableFeatures
        
        // Then: Intermediate features should be unlocked
        XCTAssertTrue(availableFeatures.contains(.basicSplitAllocation), "Basic split allocation should be available")
        XCTAssertTrue(availableFeatures.contains(.customTaxCategories), "Custom tax categories should be available")
        XCTAssertTrue(availableFeatures.contains(.advancedReporting), "Advanced reporting should be available")
        XCTAssertFalse(availableFeatures.contains(.mlPoweredSuggestions), "ML suggestions should remain locked")
    }
    
    func testExpertFeatureUnlockProgression() {
        // Given: User reaching expert level
        simulateExpertUserActivity()
        featureGatingSystem.updateFeatureAvailability()
        
        // When: Checking all features
        let allFeatures = FeatureType.allCases
        let availableFeatures = featureGatingSystem.availableFeatures
        
        // Then: All features should be unlocked
        for feature in allFeatures {
            XCTAssertTrue(availableFeatures.contains(feature), "Expert user should have access to \(feature)")
        }
        XCTAssertTrue(featureGatingSystem.isAdvancedFeaturesUnlocked, "All advanced features should be unlocked")
    }
    
    func testMasteryBasedUnlocking() {
        // Given: User mastering specific feature areas
        simulateSplitAllocationMastery()
        
        // When: Checking feature-specific unlocking
        featureGatingSystem.updateFeatureAvailability()
        
        // Then: Related advanced features should unlock
        XCTAssertTrue(featureGatingSystem.isFeatureAvailable(.advancedSplitAllocation), "Advanced split allocation should unlock with mastery")
        XCTAssertTrue(featureGatingSystem.isFeatureAvailable(.complexTaxCategories), "Complex tax categories should unlock with mastery")
        XCTAssertFalse(featureGatingSystem.isFeatureAvailable(.mlPoweredSuggestions), "Unrelated features should remain locked")
    }
    
    // MARK: - Adaptive UI Behavior Tests
    
    func testAdaptiveUIForNoviceUser() {
        // Given: Novice user
        featureGatingSystem.updateFeatureAvailability()
        
        // When: Getting UI configuration
        let uiConfig = featureGatingSystem.getAdaptiveUIConfiguration()
        
        // Then: UI should be simplified
        XCTAssertEqual(uiConfig.complexityLevel, .simplified, "Novice users should get simplified UI")
        XCTAssertTrue(uiConfig.showHelpPrompts, "Help prompts should be visible for novice users")
        XCTAssertFalse(uiConfig.showAdvancedOptions, "Advanced options should be hidden")
        XCTAssertTrue(uiConfig.enableGuidedWorkflows, "Guided workflows should be enabled")
    }
    
    func testAdaptiveUIForIntermediateUser() {
        // Given: Intermediate user
        simulateIntermediateUserActivity()
        featureGatingSystem.updateFeatureAvailability()
        
        // When: Getting UI configuration
        let uiConfig = featureGatingSystem.getAdaptiveUIConfiguration()
        
        // Then: UI should be balanced
        XCTAssertEqual(uiConfig.complexityLevel, .balanced, "Intermediate users should get balanced UI")
        XCTAssertTrue(uiConfig.showOptionalHelpPrompts, "Optional help should be available")
        XCTAssertTrue(uiConfig.showAdvancedOptions, "Some advanced options should be visible")
        XCTAssertFalse(uiConfig.enableGuidedWorkflows, "Guided workflows should be optional")
    }
    
    func testAdaptiveUIForExpertUser() {
        // Given: Expert user
        simulateExpertUserActivity()
        featureGatingSystem.updateFeatureAvailability()
        
        // When: Getting UI configuration
        let uiConfig = featureGatingSystem.getAdaptiveUIConfiguration()
        
        // Then: UI should be full-featured
        XCTAssertEqual(uiConfig.complexityLevel, .advanced, "Expert users should get advanced UI")
        XCTAssertFalse(uiConfig.showHelpPrompts, "Help prompts should be minimal for experts")
        XCTAssertTrue(uiConfig.showAdvancedOptions, "All advanced options should be visible")
        XCTAssertTrue(uiConfig.enableExpertMode, "Expert mode should be available")
    }
    
    func testUIAdaptationBasedOnContextualUsage() {
        // Given: User with context-specific expertise
        simulateReportingExpertise()
        
        // When: Getting context-specific UI configuration
        let reportingUIConfig = featureGatingSystem.getContextualUIConfiguration(for: .reporting)
        let splitUIConfig = featureGatingSystem.getContextualUIConfiguration(for: .splitAllocation)
        
        // Then: UI should adapt to context-specific competency
        XCTAssertEqual(reportingUIConfig.complexityLevel, .advanced, "Reporting UI should be advanced")
        XCTAssertEqual(splitUIConfig.complexityLevel, .simplified, "Split allocation UI should remain simplified")
    }
    
    // MARK: - Smart Defaults Evolution Tests
    
    func testSmartDefaultsForNoviceUser() {
        // Given: Novice user
        featureGatingSystem.updateFeatureAvailability()
        
        // When: Getting smart defaults
        let defaults = featureGatingSystem.getSmartDefaults()
        
        // Then: Defaults should be simplified and safe
        XCTAssertEqual(defaults.defaultSplitStrategy, .simple50_50, "Novice users should get simple 50/50 splits")
        XCTAssertEqual(defaults.defaultTaxCategory, "Personal", "Default tax category should be personal")
        XCTAssertTrue(defaults.enableValidationHelp, "Validation help should be enabled")
        XCTAssertFalse(defaults.enableAdvancedCalculations, "Advanced calculations should be disabled")
    }
    
    func testSmartDefaultsEvolutionWithExperience() {
        // Given: User gaining experience in split allocations
        simulateProgressiveSplitUsage()
        
        // When: Getting evolved smart defaults
        let evolvedDefaults = featureGatingSystem.getSmartDefaults()
        
        // Then: Defaults should adapt to user patterns
        XCTAssertEqual(evolvedDefaults.defaultSplitStrategy, .intelligentSuggestion, "Defaults should evolve to intelligent suggestions")
        XCTAssertTrue(evolvedDefaults.learnFromUserPatterns, "System should learn from user patterns")
        XCTAssertGreaterThan(evolvedDefaults.suggestionConfidence, 0.7, "Suggestion confidence should be high")
    }
    
    func testDefaultsPersonalizationBasedOnUsagePatterns() {
        // Given: User with specific usage patterns (business-focused)
        simulateBusinessUserPatterns()
        
        // When: Getting personalized defaults
        let personalizedDefaults = featureGatingSystem.getSmartDefaults()
        
        // Then: Defaults should reflect user's business focus
        XCTAssertEqual(personalizedDefaults.defaultTaxCategory, "Business", "Default should adapt to business usage")
        XCTAssertEqual(personalizedDefaults.defaultSplitStrategy, .businessOptimized, "Split strategy should be business-optimized")
        XCTAssertTrue(personalizedDefaults.enableBusinessFeatures, "Business features should be prioritized")
    }
    
    // MARK: - Feature Usage Analytics Tests
    
    func testFeatureUsageAnalyticsCollection() {
        // Given: User interacting with various features
        featureGatingSystem.recordFeatureUsage(.basicTransactionEntry, success: true, timeSpent: 30)
        featureGatingSystem.recordFeatureUsage(.basicSplitAllocation, success: false, timeSpent: 120)
        featureGatingSystem.recordFeatureUsage(.simpleReporting, success: true, timeSpent: 45)
        
        // When: Analyzing feature usage
        let usageAnalytics = featureGatingSystem.getFeatureUsageAnalytics()
        
        // Then: Analytics should capture usage patterns
        XCTAssertEqual(usageAnalytics.totalInteractions, 3, "Should track all feature interactions")
        XCTAssertEqual(usageAnalytics.successRate, 2.0/3.0, accuracy: 0.01, "Should calculate correct success rate")
        XCTAssertGreaterThan(usageAnalytics.averageTimeSpent, 0, "Should track time spent on features")
        XCTAssertTrue(usageAnalytics.mostUsedFeatures.contains(.basicTransactionEntry), "Should identify most used features")
    }
    
    func testFeatureUsageInsightsGeneration() {
        // Given: Patterns of feature usage indicating struggle areas
        recordStrugglingUserPattern()
        
        // When: Generating insights
        let insights = featureGatingSystem.generateUsageInsights()
        
        // Then: Should identify areas for improvement
        XCTAssertGreaterThan(insights.count, 0, "Should generate usage insights")
        XCTAssertTrue(insights.contains { $0.type == .strugglingFeature }, "Should identify struggling features")
        XCTAssertTrue(insights.contains { $0.recommendedAction == .provideTutorial }, "Should recommend tutorials for struggling areas")
    }
    
    // MARK: - Rollback Capability Tests
    
    func testUserInitiatedComplexityRollback() {
        // Given: Expert user who wants simplified interface
        simulateExpertUserActivity()
        featureGatingSystem.updateFeatureAvailability()
        
        // When: User requests interface simplification
        featureGatingSystem.requestInterfaceSimplification()
        
        // Then: UI should rollback to simpler configuration
        let simplifiedConfig = featureGatingSystem.getAdaptiveUIConfiguration()
        XCTAssertEqual(simplifiedConfig.complexityLevel, .balanced, "UI should rollback to balanced complexity")
        XCTAssertTrue(simplifiedConfig.showOptionalHelpPrompts, "Help prompts should become available")
        XCTAssertTrue(featureGatingSystem.isRollbackModeActive, "Rollback mode should be active")
    }
    
    func testAutomaticRollbackOnStruggling() {
        // Given: User struggling with advanced features
        simulateStrugglingWithAdvancedFeatures()
        
        // When: System detects struggling pattern
        featureGatingSystem.updateFeatureAvailability()
        
        // Then: System should automatically offer rollback
        XCTAssertTrue(featureGatingSystem.shouldSuggestRollback, "System should suggest rollback for struggling users")
        
        // When: Accepting automatic rollback
        featureGatingSystem.acceptAutomaticRollback()
        
        // Then: Features should be simplified
        let rolledBackConfig = featureGatingSystem.getAdaptiveUIConfiguration()
        XCTAssertEqual(rolledBackConfig.complexityLevel, .simplified, "UI should rollback to simplified")
        XCTAssertTrue(rolledBackConfig.enableGuidedWorkflows, "Guided workflows should be re-enabled")
    }
    
    func testRollbackRecoveryPath() {
        // Given: User in rollback mode who's improving
        featureGatingSystem.requestInterfaceSimplification()
        simulateImprovementAfterRollback()
        
        // When: User demonstrates improved competency
        featureGatingSystem.updateFeatureAvailability()
        
        // Then: System should offer to restore advanced features
        XCTAssertTrue(featureGatingSystem.canOfferAdvancementFromRollback, "Should offer advancement from rollback")
        
        // When: User accepts advancement
        featureGatingSystem.acceptAdvancementFromRollback()
        
        // Then: Advanced features should be restored
        XCTAssertFalse(featureGatingSystem.isRollbackModeActive, "Rollback mode should be deactivated")
        let restoredConfig = featureGatingSystem.getAdaptiveUIConfiguration()
        XCTAssertEqual(restoredConfig.complexityLevel, .balanced, "UI complexity should be restored")
    }
    
    // MARK: - Performance and Edge Case Tests
    
    func testPerformanceWithLargeDataset() {
        // Given: Large amount of user activity data
        simulateLargeDatasetUserActivity()
        
        // When: Calculating competency with performance measurement
        let startTime = Date()
        let competencyScore = featureGatingSystem.calculateUserCompetencyScore()
        let calculationTime = Date().timeIntervalSince(startTime)
        
        // Then: Should maintain good performance
        XCTAssertLessThan(calculationTime, 0.1, "Competency calculation should complete under 100ms")
        XCTAssertGreaterThan(competencyScore, 0.0, "Should calculate valid competency score")
        XCTAssertLessThan(competencyScore, 1.0, "Competency score should be within valid range")
    }
    
    func testEdgeCaseUserBehaviorPatterns() {
        // Given: User with erratic behavior patterns
        simulateErraticUserBehavior()
        
        // When: System processes irregular patterns
        featureGatingSystem.updateFeatureAvailability()
        
        // Then: System should handle gracefully
        XCTAssertNotNil(featureGatingSystem.currentUserLevel, "Should maintain valid user level")
        XCTAssertGreaterThan(featureGatingSystem.availableFeatures.count, 0, "Should provide at least basic features")
        XCTAssertNoThrow(featureGatingSystem.getAdaptiveUIConfiguration(), "Should provide valid UI configuration")
    }
    
    // MARK: - Helper Methods for Test Scenarios
    
    private func simulateIntermediateUserActivity() {
        userJourneyTracker.trackEvent(.onboardingCompleted)
        userJourneyTracker.trackEvent(.transactionCreated, metadata: ["success": "true"])
        userJourneyTracker.trackEvent(.transactionCreated, metadata: ["success": "true"])
        userJourneyTracker.trackEvent(.transactionCreated, metadata: ["success": "true"])
        userJourneyTracker.trackEvent(.splitAllocationUsed, metadata: ["categories": "2", "success": "true"])
        userJourneyTracker.trackEvent(.splitAllocationCompleted, metadata: ["success": "true"])
        userJourneyTracker.trackEvent(.reportGenerated, metadata: ["type": "basic"])
    }
    
    private func simulateExpertUserActivity() {
        simulateIntermediateUserActivity()
        
        // Advanced split allocation usage
        for _ in 1...10 {
            userJourneyTracker.trackEvent(.splitAllocationUsed, metadata: ["categories": "4", "success": "true"])
            userJourneyTracker.trackEvent(.splitAllocationCompleted, metadata: ["success": "true"])
        }
        
        // Advanced reporting
        userJourneyTracker.trackEvent(.reportGenerated, metadata: ["type": "advanced", "categories": "multiple"])
        userJourneyTracker.trackEvent(.reportGenerated, metadata: ["type": "tax_summary", "complexity": "high"])
        
        // Feature exploration
        userJourneyTracker.trackEvent(.featureExplored, metadata: ["feature": "advanced_analytics"])
        userJourneyTracker.trackEvent(.settingsChanged, metadata: ["area": "advanced_preferences"])
    }
    
    private func simulateSplitAllocationMastery() {
        for i in 1...15 {
            let categories = min(i / 3 + 2, 5) // Progressively more complex
            userJourneyTracker.trackEvent(.splitAllocationUsed, metadata: ["categories": "\(categories)", "success": "true"])
            userJourneyTracker.trackEvent(.splitAllocationCompleted, metadata: ["success": "true", "time_spent": "fast"])
        }
    }
    
    private func simulateReportingExpertise() {
        for _ in 1...10 {
            userJourneyTracker.trackEvent(.reportGenerated, metadata: ["type": "advanced", "success": "true"])
        }
    }
    
    private func simulateProgressiveSplitUsage() {
        // Start with simple splits
        userJourneyTracker.trackEvent(.splitAllocationUsed, metadata: ["categories": "2", "pattern": "50-50"])
        userJourneyTracker.trackEvent(.splitAllocationUsed, metadata: ["categories": "2", "pattern": "50-50"])
        
        // Progress to business/personal splits
        userJourneyTracker.trackEvent(.splitAllocationUsed, metadata: ["categories": "2", "pattern": "70-30"])
        userJourneyTracker.trackEvent(.splitAllocationUsed, metadata: ["categories": "2", "pattern": "70-30"])
        userJourneyTracker.trackEvent(.splitAllocationUsed, metadata: ["categories": "2", "pattern": "70-30"])
    }
    
    private func simulateBusinessUserPatterns() {
        for _ in 1...10 {
            userJourneyTracker.trackEvent(.transactionCreated, metadata: ["category": "business", "type": "expense"])
            userJourneyTracker.trackEvent(.splitAllocationUsed, metadata: ["primary_category": "business", "pattern": "business_optimized"])
        }
    }
    
    private func recordStrugglingUserPattern() {
        // Multiple failed attempts at advanced features
        featureGatingSystem.recordFeatureUsage(.advancedSplitAllocation, success: false, timeSpent: 300)
        featureGatingSystem.recordFeatureUsage(.advancedSplitAllocation, success: false, timeSpent: 240)
        featureGatingSystem.recordFeatureUsage(.complexTaxCategories, success: false, timeSpent: 180)
        featureGatingSystem.recordFeatureUsage(.advancedReporting, success: false, timeSpent: 420)
    }
    
    private func simulateStrugglingWithAdvancedFeatures() {
        // User attempts advanced features but fails frequently
        userJourneyTracker.trackEvent(.splitAllocationUsed, metadata: ["categories": "4", "success": "false"])
        userJourneyTracker.trackEvent(.splitAllocationUsed, metadata: ["categories": "4", "success": "false"])
        userJourneyTracker.trackEvent(.splitAllocationUsed, metadata: ["categories": "3", "success": "false"])
        
        // Record struggle patterns in feature gating system
        featureGatingSystem.recordFeatureUsage(.advancedSplitAllocation, success: false, timeSpent: 400)
        featureGatingSystem.recordFeatureUsage(.advancedSplitAllocation, success: false, timeSpent: 350)
    }
    
    private func simulateImprovementAfterRollback() {
        // User shows improvement in simpler interface
        userJourneyTracker.trackEvent(.splitAllocationUsed, metadata: ["categories": "2", "success": "true"])
        userJourneyTracker.trackEvent(.splitAllocationCompleted, metadata: ["success": "true", "time_spent": "efficient"])
        userJourneyTracker.trackEvent(.splitAllocationUsed, metadata: ["categories": "3", "success": "true"])
        userJourneyTracker.trackEvent(.splitAllocationCompleted, metadata: ["success": "true", "time_spent": "efficient"])
        
        featureGatingSystem.recordFeatureUsage(.basicSplitAllocation, success: true, timeSpent: 60)
        featureGatingSystem.recordFeatureUsage(.basicSplitAllocation, success: true, timeSpent: 45)
    }
    
    private func simulateLargeDatasetUserActivity() {
        // Generate large amount of user activity
        for i in 1...1000 {
            let eventType = JourneyEventType.allCases.randomElement()!
            let success = Bool.random()
            userJourneyTracker.trackEvent(eventType, metadata: ["iteration": "\(i)", "success": "\(success)"])
            
            if i % 10 == 0 {
                let feature = FeatureType.allCases.randomElement()!
                featureGatingSystem.recordFeatureUsage(feature, success: success, timeSpent: Double.random(in: 10...300))
            }
        }
    }
    
    private func simulateErraticUserBehavior() {
        // Inconsistent patterns
        userJourneyTracker.trackEvent(.onboardingStarted)
        userJourneyTracker.trackEvent(.splitAllocationUsed, metadata: ["categories": "5", "success": "false"]) // Advanced before basics
        userJourneyTracker.trackEvent(.transactionCreated, metadata: ["success": "true"])
        userJourneyTracker.trackEvent(.reportGenerated, metadata: ["type": "advanced"]) // Advanced report early
        userJourneyTracker.trackEvent(.onboardingCompleted) // Late onboarding completion
        
        // Erratic feature usage
        featureGatingSystem.recordFeatureUsage(.mlPoweredSuggestions, success: false, timeSpent: 5) // Quick failure on advanced feature
        featureGatingSystem.recordFeatureUsage(.basicTransactionEntry, success: true, timeSpent: 300) // Long time on basic feature
    }
}

// MARK: - Test Support Extensions

extension UserJourneyTracker {
    var eventCount: Int {
        return journeyEvents.count
    }
}