//
// FeatureGatingSystemTests.swift
// FinanceMateTests
//
// Comprehensive Feature Gating System Test Suite
// Created: 2025-07-07
// Target: FinanceMateTests
//

/*
 * Purpose: Comprehensive test suite for FeatureGatingSystem with progressive disclosure and competency-based feature access
 * Issues & Complexity Summary: Complex feature gating logic, user competency assessment, progressive UI adaptation
 * Key Complexity Drivers:
   - Logic Scope (Est. LoC): ~350
   - Core Algorithm Complexity: Very High
   - Dependencies: UserDefaults, user competency tracking, progressive UI systems
   - State Management Complexity: Very High (feature states, user levels, UI adaptation, mastery tracking)
   - Novelty/Uncertainty Factor: High (competency assessment algorithms, adaptive UI patterns, progressive complexity)
 * AI Pre-Task Self-Assessment: 88%
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
class FeatureGatingSystemTests: XCTestCase {
    
    var featureGatingSystem: FeatureGatingSystem!
    var realUserDefaults: UserDefaults!
    var testContext: NSManagedObjectContext!
    
    override func setUp() async throws {
        try await super.setUp()
        
        // Create isolated UserDefaults for testing
        realUserDefaults = UserDefaults(suiteName: "FeatureGatingSystemTests")!
        realUserDefaults.removePersistentDomain(forName: "FeatureGatingSystemTests")
        
        // Set up Core Data test context
        testContext = PersistenceController.preview.container.viewContext
        
        // Initialize feature gating system
        featureGatingSystem = FeatureGatingSystem(
            context: testContext,
            userDefaults: realUserDefaults
        )
    }
    
    override func tearDown() async throws {
        // Clean up UserDefaults
        realUserDefaults.removePersistentDomain(forName: "FeatureGatingSystemTests")
        
        featureGatingSystem = nil
        realUserDefaults = nil
        testContext = nil
        try await super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testFeatureGatingSystemInitialization() {
        XCTAssertNotNil(featureGatingSystem, "FeatureGatingSystem should initialize successfully")
        XCTAssertEqual(featureGatingSystem.currentUserLevel, .beginner, "Should start at beginner level")
        XCTAssertFalse(featureGatingSystem.isProgressiveDisclosureEnabled, "Progressive disclosure should be disabled initially")
    }
    
    func testInitialFeatureAccessLevels() {
        // Basic features should be available immediately
        XCTAssertTrue(featureGatingSystem.isFeatureAvailable(.basicTransactionEntry), "Basic transaction entry should be available")
        XCTAssertTrue(featureGatingSystem.isFeatureAvailable(.dashboardOverview), "Dashboard overview should be available")
        
        // Advanced features should be gated
        XCTAssertFalse(featureGatingSystem.isFeatureAvailable(.lineItemSplitting), "Line item splitting should be gated")
        XCTAssertFalse(featureGatingSystem.isFeatureAvailable(.advancedAnalytics), "Advanced analytics should be gated")
        XCTAssertFalse(featureGatingSystem.isFeatureAvailable(.multiEntityManagement), "Multi-entity management should be gated")
    }
    
    // MARK: - User Competency Assessment Tests
    
    func testUserCompetencyTracking() async throws {
        // Track basic competency actions
        await featureGatingSystem.trackUserAction(.transactionCreated, proficiencyGain: 0.1)
        await featureGatingSystem.trackUserAction(.categorySelected, proficiencyGain: 0.05)
        
        let competencyLevel = featureGatingSystem.getUserCompetencyLevel(.basicFinancialManagement)
        XCTAssertGreaterThan(competencyLevel, 0.0, "User should gain competency from actions")
        XCTAssertLessThan(competencyLevel, 1.0, "Competency should not immediately reach maximum")
    }
    
    func testCompetencyLevelProgression() async throws {
        // Simulate multiple actions to increase competency
        for _ in 1...10 {
            await featureGatingSystem.trackUserAction(.transactionCreated, proficiencyGain: 0.15)
        }
        
        let competencyLevel = featureGatingSystem.getUserCompetencyLevel(.basicFinancialManagement)
        XCTAssertGreaterThan(competencyLevel, 0.8, "Multiple actions should significantly increase competency")
        
        // Check if user level advanced
        let userLevel = featureGatingSystem.currentUserLevel
        XCTAssertTrue(userLevel == .intermediate || userLevel == .advanced, "User level should progress with competency")
    }
    
    func testCompetencyBasedFeatureUnlocking() async throws {
        // Initially advanced features should be locked
        XCTAssertFalse(featureGatingSystem.isFeatureAvailable(.lineItemSplitting), "Line item splitting should be locked initially")
        
        // Build up competency in transaction management
        for _ in 1...15 {
            await featureGatingSystem.trackUserAction(.transactionCreated, proficiencyGain: 0.1)
            await featureGatingSystem.trackUserAction(.categorySelected, proficiencyGain: 0.05)
        }
        
        // Check if line item splitting unlocked
        await featureGatingSystem.evaluateFeatureUnlocks()
        XCTAssertTrue(featureGatingSystem.isFeatureAvailable(.lineItemSplitting), "Line item splitting should unlock with sufficient competency")
    }
    
    func testMultipleCompetencyAreas() async throws {
        // Track competency in different areas
        await featureGatingSystem.trackUserAction(.transactionCreated, proficiencyGain: 0.2)
        await featureGatingSystem.trackUserAction(.splitAllocationCompleted, proficiencyGain: 0.3)
        await featureGatingSystem.trackUserAction(.reportGenerated, proficiencyGain: 0.1)
        
        let basicCompetency = featureGatingSystem.getUserCompetencyLevel(.basicFinancialManagement)
        let splitCompetency = featureGatingSystem.getUserCompetencyLevel(.lineItemSplitting)
        let analyticsCompetency = featureGatingSystem.getUserCompetencyLevel(.analyticsAndReporting)
        
        XCTAssertGreaterThan(basicCompetency, 0.15, "Basic competency should increase")
        XCTAssertGreaterThan(splitCompetency, 0.25, "Split competency should increase more from split actions")
        XCTAssertGreaterThan(analyticsCompetency, 0.05, "Analytics competency should increase from report actions")
    }
    
    // MARK: - Progressive Feature Unlocking Tests
    
    func testFeatureUnlockingSequence() async throws {
        // Start with basic features only
        let initialAvailableFeatures = featureGatingSystem.getAvailableFeatures()
        XCTAssertTrue(initialAvailableFeatures.contains(.basicTransactionEntry), "Basic features should be available")
        XCTAssertFalse(initialAvailableFeatures.contains(.lineItemSplitting), "Advanced features should be locked")
        
        // Simulate user progression
        await simulateUserProgression(.intermediate)
        
        let intermediateFeatures = featureGatingSystem.getAvailableFeatures()
        XCTAssertTrue(intermediateFeatures.contains(.lineItemSplitting), "Intermediate features should unlock")
        XCTAssertFalse(intermediateFeatures.contains(.multiEntityManagement), "Advanced features should still be locked")
        
        // Progress to advanced level
        await simulateUserProgression(.advanced)
        
        let advancedFeatures = featureGatingSystem.getAvailableFeatures()
        XCTAssertTrue(advancedFeatures.contains(.multiEntityManagement), "Advanced features should unlock")
    }
    
    func testMasteryBasedUnlocking() async throws {
        // Track mastery-specific actions
        await featureGatingSystem.trackMasteryAchievement(.basicTransactionMastery, evidence: "Created 50+ transactions")
        await featureGatingSystem.trackMasteryAchievement(.categoryMastery, evidence: "Consistently used appropriate tax categories")
        
        let unlockedFeatures = await featureGatingSystem.evaluateMasteryUnlocks()
        XCTAssertGreaterThan(unlockedFeatures.count, 0, "Mastery achievements should unlock new features")
        
        // Check if split allocation features unlocked
        XCTAssertTrue(featureGatingSystem.isFeatureAvailable(.lineItemSplitting), "Split allocation should unlock with transaction mastery")
    }
    
    func testFeatureUnlockingWithPrerequisites() async throws {
        // Test that advanced features require prerequisite mastery
        await featureGatingSystem.attemptFeatureUnlock(.multiEntityManagement)
        XCTAssertFalse(featureGatingSystem.isFeatureAvailable(.multiEntityManagement), "Advanced features should require prerequisites")
        
        // Fulfill prerequisites
        await featureGatingSystem.trackMasteryAchievement(.basicTransactionMastery, evidence: "Prerequisite met")
        await featureGatingSystem.trackMasteryAchievement(.splitAllocationMastery, evidence: "Prerequisite met")
        
        await featureGatingSystem.attemptFeatureUnlock(.multiEntityManagement)
        XCTAssertTrue(featureGatingSystem.isFeatureAvailable(.multiEntityManagement), "Features should unlock when prerequisites are met")
    }
    
    // MARK: - Adaptive UI Controller Tests
    
    func testAdaptiveUIBasedOnUserLevel() {
        // Test UI adaptation for beginner level
        let beginnerUIConfig = featureGatingSystem.getAdaptiveUIConfiguration()
        XCTAssertTrue(beginnerUIConfig.showSimplifiedInterface, "Beginners should see simplified interface")
        XCTAssertFalse(beginnerUIConfig.showAdvancedControls, "Beginners should not see advanced controls")
        XCTAssertTrue(beginnerUIConfig.showGuidanceHints, "Beginners should see guidance hints")
    }
    
    func testUIComplexityProgression() async throws {
        // Progress user to intermediate level
        await simulateUserProgression(.intermediate)
        
        let intermediateUIConfig = featureGatingSystem.getAdaptiveUIConfiguration()
        XCTAssertFalse(intermediateUIConfig.showSimplifiedInterface, "Intermediate users should see standard interface")
        XCTAssertTrue(intermediateUIConfig.showAdvancedControls, "Intermediate users should see some advanced controls")
        XCTAssertFalse(intermediateUIConfig.showGuidanceHints, "Intermediate users should see fewer guidance hints")
        
        // Progress to advanced level
        await simulateUserProgression(.advanced)
        
        let advancedUIConfig = featureGatingSystem.getAdaptiveUIConfiguration()
        XCTAssertTrue(advancedUIConfig.showAllFeatures, "Advanced users should see all features")
        XCTAssertTrue(advancedUIConfig.enableExpertMode, "Advanced users should have expert mode available")
    }
    
    func testContextualUIAdaptation() async throws {
        // Test UI adaptation based on current context
        featureGatingSystem.setCurrentContext(.transactionManagement)
        let transactionUIConfig = featureGatingSystem.getContextualUIConfiguration(.transactionManagement)
        
        XCTAssertTrue(transactionUIConfig.showRelevantFeatures.contains(.basicTransactionEntry), "Should show relevant transaction features")
        XCTAssertTrue(transactionUIConfig.highlightNextSteps, "Should highlight next steps in transaction context")
        
        // Change context and test adaptation
        featureGatingSystem.setCurrentContext(.analytics)
        let analyticsUIConfig = featureGatingSystem.getContextualUIConfiguration(.analytics)
        
        XCTAssertTrue(analyticsUIConfig.showRelevantFeatures.contains(.basicAnalytics), "Should show relevant analytics features")
        XCTAssertFalse(analyticsUIConfig.showRelevantFeatures.contains(.basicTransactionEntry), "Should hide irrelevant features")
    }
    
    func testUICustomizationBasedOnUsagePatterns() async throws {
        // Track usage patterns
        await featureGatingSystem.trackFeatureUsage(.basicTransactionEntry, frequency: .high)
        await featureGatingSystem.trackFeatureUsage(.categorySelection, frequency: .medium)
        await featureGatingSystem.trackFeatureUsage(.reportGeneration, frequency: .low)
        
        let customizedUIConfig = await featureGatingSystem.getUsageBasedUIConfiguration()
        XCTAssertTrue(customizedUIConfig.prominentFeatures.contains(.basicTransactionEntry), "Frequently used features should be prominent")
        XCTAssertFalse(customizedUIConfig.prominentFeatures.contains(.reportGeneration), "Rarely used features should not be prominent")
        XCTAssertTrue(customizedUIConfig.suggestedFeatures.contains(.lineItemSplitting), "Should suggest next logical features")
    }
    
    // MARK: - Smart Defaults Evolution Tests
    
    func testSmartDefaultsEvolution() async throws {
        // Test that defaults evolve with user sophistication
        let initialDefaults = featureGatingSystem.getSmartDefaults(.transactionEntry)
        XCTAssertEqual(initialDefaults.defaultCategory, "Personal", "Beginners should default to Personal category")
        XCTAssertFalse(initialDefaults.enableLineItemSplitting, "Beginners should not default to split allocation")
        
        // Simulate user evolution
        await simulateUserProgression(.intermediate)
        await featureGatingSystem.trackCategoryUsagePattern(.business, frequency: 0.8)
        
        let evolvedDefaults = featureGatingSystem.getSmartDefaults(.transactionEntry)
        XCTAssertEqual(evolvedDefaults.defaultCategory, "Business", "Defaults should evolve based on usage patterns")
        XCTAssertTrue(evolvedDefaults.suggestLineItemSplitting, "Should suggest advanced features to intermediate users")
    }
    
    func testPersonalizedDefaults() async throws {
        // Track user preferences and behavior
        await featureGatingSystem.trackUserPreference(.preferredTaxCategory, value: "Investment")
        await featureGatingSystem.trackUserPreference(.preferredTransactionType, value: "Expense")
        await featureGatingSystem.trackUserPreference(.defaultSplitPercentage, value: "70/30")
        
        let personalizedDefaults = await featureGatingSystem.getPersonalizedDefaults()
        XCTAssertEqual(personalizedDefaults.defaultTaxCategory, "Investment", "Should use user's preferred tax category")
        XCTAssertEqual(personalizedDefaults.defaultTransactionType, "Expense", "Should use user's preferred transaction type")
        XCTAssertTrue(personalizedDefaults.quickSplitOptions.contains("70/30"), "Should include user's preferred split ratios")
    }
    
    func testIntelligentDefaultSuggestions() async throws {
        // Simulate transaction patterns
        await featureGatingSystem.trackTransactionPattern(.businessExpenses, frequency: 0.6)
        await featureGatingSystem.trackTransactionPattern(.investmentPurchases, frequency: 0.3)
        await featureGatingSystem.trackTransactionPattern(.personalExpenses, frequency: 0.1)
        
        let suggestions = await featureGatingSystem.generateIntelligentDefaultSuggestions()
        XCTAssertGreaterThan(suggestions.count, 0, "Should generate default suggestions based on patterns")
        
        let businessSuggestion = suggestions.first { $0.category == "Business" }
        XCTAssertNotNil(businessSuggestion, "Should suggest business defaults for frequent business transactions")
        XCTAssertGreaterThan(businessSuggestion!.confidence, 0.5, "Should have high confidence for dominant patterns")
    }
    
    // MARK: - Feature Usage Analytics Tests
    
    func testFeatureUsageTracking() async throws {
        // Track feature usage over time
        await featureGatingSystem.trackFeatureUsage(.basicTransactionEntry, frequency: .high)
        await featureGatingSystem.trackFeatureUsage(.lineItemSplitting, frequency: .medium)
        
        let usageAnalytics = featureGatingSystem.getFeatureUsageAnalytics()
        XCTAssertGreaterThan(usageAnalytics.count, 0, "Should track feature usage analytics")
        
        let transactionAnalytics = usageAnalytics[.basicTransactionEntry]
        XCTAssertNotNil(transactionAnalytics, "Should have analytics for tracked features")
        XCTAssertEqual(transactionAnalytics?.frequency, .high, "Should correctly track usage frequency")
    }
    
    func testUsagePatternAnalysis() async throws {
        // Create usage patterns over time
        let startDate = Date().addingTimeInterval(-86400 * 7) // 7 days ago
        for i in 0..<7 {
            let date = startDate.addingTimeInterval(Double(i) * 86400)
            await featureGatingSystem.trackFeatureUsageWithDate(.basicTransactionEntry, date: date, duration: 300 + Double(i * 60))
        }
        
        let patterns = await featureGatingSystem.analyzeUsagePatterns()
        XCTAssertGreaterThan(patterns.count, 0, "Should identify usage patterns")
        
        let timePattern = patterns.first { $0.patternType == .timeBasedUsage }
        XCTAssertNotNil(timePattern, "Should identify time-based usage patterns")
    }
    
    func testFeatureOptimizationRecommendations() async throws {
        // Create usage data that suggests optimization opportunities
        await featureGatingSystem.trackFeatureUsage(.reportGeneration, frequency: .low)
        await featureGatingSystem.trackFeatureUsage(.advancedAnalytics, frequency: .low)
        await featureGatingSystem.trackFeatureUsage(.basicTransactionEntry, frequency: .high)
        
        let recommendations = await featureGatingSystem.generateOptimizationRecommendations()
        XCTAssertGreaterThan(recommendations.count, 0, "Should generate optimization recommendations")
        
        let lowUsageRecommendation = recommendations.first { $0.type == .increaseDiscoverability }
        XCTAssertNotNil(lowUsageRecommendation, "Should recommend increasing discoverability for low-usage features")
    }
    
    // MARK: - Rollback Capability Tests
    
    func testUIComplexityRollback() async throws {
        // Progress user to advanced level
        await simulateUserProgression(.advanced)
        XCTAssertEqual(featureGatingSystem.currentUserLevel, .advanced, "User should reach advanced level")
        
        // User requests simpler interface
        await featureGatingSystem.requestInterfaceSimplification()
        
        let rollbackUIConfig = featureGatingSystem.getAdaptiveUIConfiguration()
        XCTAssertTrue(rollbackUIConfig.showSimplifiedInterface, "Should show simplified interface after rollback request")
        XCTAssertFalse(rollbackUIConfig.showAdvancedControls, "Should hide advanced controls after rollback")
    }
    
    func testFeatureRollbackToEarlierState() async throws {
        // Unlock advanced features
        await simulateUserProgression(.advanced)
        XCTAssertTrue(featureGatingSystem.isFeatureAvailable(.multiEntityManagement), "Advanced features should be available")
        
        // Request rollback to intermediate level
        await featureGatingSystem.rollbackToUserLevel(.intermediate)
        
        XCTAssertEqual(featureGatingSystem.currentUserLevel, .intermediate, "Should rollback to intermediate level")
        XCTAssertFalse(featureGatingSystem.isFeatureAvailable(.multiEntityManagement), "Advanced features should be hidden after rollback")
        XCTAssertTrue(featureGatingSystem.isFeatureAvailable(.lineItemSplitting), "Intermediate features should remain available")
    }
    
    func testSelectiveFeatureRollback() async throws {
        // Enable multiple advanced features
        await simulateUserProgression(.advanced)
        
        // Rollback only specific features
        await featureGatingSystem.rollbackFeature(.multiEntityManagement)
        
        XCTAssertFalse(featureGatingSystem.isFeatureAvailable(.multiEntityManagement), "Specific feature should be rolled back")
        XCTAssertTrue(featureGatingSystem.isFeatureAvailable(.advancedAnalytics), "Other advanced features should remain available")
    }
    
    func testRollbackPreferencePersistence() async throws {
        // Set rollback preferences
        await featureGatingSystem.setRollbackPreference(.lineItemSplitting, enabled: false)
        await featureGatingSystem.setRollbackPreference(.advancedAnalytics, enabled: true)
        
        // Restart system to test persistence
        let newSystem = FeatureGatingSystem(context: testContext, userDefaults: realUserDefaults)
        
        XCTAssertFalse(newSystem.isFeatureAvailable(.lineItemSplitting), "Rollback preferences should persist")
        XCTAssertTrue(newSystem.isFeatureAvailable(.advancedAnalytics), "Enabled preferences should persist")
    }
    
    // MARK: - Integration and Edge Case Tests
    
    func testFeatureGatingWithUserSegmentation() async throws {
        // Test feature gating for different user types
        await featureGatingSystem.setUserSegment(.businessOwner)
        
        let businessFeatures = featureGatingSystem.getSegmentSpecificFeatures(.businessOwner)
        XCTAssertTrue(businessFeatures.contains(.multiEntityManagement), "Business owners should have access to entity management")
        XCTAssertTrue(businessFeatures.contains(.advancedTaxCategories), "Business owners should have advanced tax features")
        
        // Switch to individual user
        await featureGatingSystem.setUserSegment(.individual)
        
        let individualFeatures = featureGatingSystem.getSegmentSpecificFeatures(.individual)
        XCTAssertFalse(individualFeatures.contains(.multiEntityManagement), "Individuals should not need entity management")
        XCTAssertTrue(individualFeatures.contains(.personalBudgeting), "Individuals should have personal budgeting features")
    }
    
    func testFeatureGatingPerformanceWithLargeDatasets() async throws {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // Simulate large number of competency tracking events
        for i in 1...1000 {
            await featureGatingSystem.trackUserAction(.transactionCreated, proficiencyGain: 0.01)
            if i % 100 == 0 {
                await featureGatingSystem.evaluateFeatureUnlocks()
            }
        }
        
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        XCTAssertLessThan(timeElapsed, 3.0, "Feature gating should handle large datasets efficiently")
        
        // Verify system still functions correctly
        XCTAssertTrue(featureGatingSystem.isFeatureAvailable(.lineItemSplitting), "Should unlock features with sufficient competency")
    }
    
    func testConcurrentFeatureEvaluation() async throws {
        // Test concurrent access to feature gating system
        await withTaskGroup(of: Void.self) { group in
            for i in 1...10 {
                group.addTask {
                    await self.featureGatingSystem.trackUserAction(.transactionCreated, proficiencyGain: 0.1)
                    await self.featureGatingSystem.evaluateFeatureUnlocks()
                }
            }
        }
        
        // Verify system state is consistent after concurrent operations
        let competencyLevel = featureGatingSystem.getUserCompetencyLevel(.basicFinancialManagement)
        XCTAssertGreaterThan(competencyLevel, 0.8, "Concurrent operations should accumulate competency correctly")
    }
    
    func testFeatureGatingErrorHandling() async throws {
        // Test with corrupted user data
        realUserDefaults.set("invalid_data", forKey: "userCompetencyLevels")
        
        let systemWithCorruptedData = FeatureGatingSystem(context: testContext, userDefaults: realUserDefaults)
        
        XCTAssertEqual(systemWithCorruptedData.currentUserLevel, .beginner, "Should handle corrupted data gracefully")
        XCTAssertTrue(systemWithCorruptedData.isFeatureAvailable(.basicTransactionEntry), "Basic features should still be available")
    }
    
    // MARK: - Helper Methods
    
    private func simulateUserProgression(_ targetLevel: UserLevel) async {
        let actionsNeeded: Int
        switch targetLevel {
        case .beginner:
            actionsNeeded = 0
        case .intermediate:
            actionsNeeded = 20
        case .advanced:
            actionsNeeded = 50
        case .expert:
            actionsNeeded = 100
        }
        
        for i in 1...actionsNeeded {
            let action: UserAction = i % 3 == 0 ? .splitAllocationCompleted : .transactionCreated
            let proficiency: Double = targetLevel == .expert ? 0.05 : 0.1
            await featureGatingSystem.trackUserAction(action, proficiencyGain: proficiency)
            
            if i % 10 == 0 {
                await featureGatingSystem.evaluateFeatureUnlocks()
            }
        }
        
        await featureGatingSystem.evaluateUserLevelProgression()
    }
}