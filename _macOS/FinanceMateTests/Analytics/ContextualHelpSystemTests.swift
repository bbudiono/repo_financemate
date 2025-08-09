//
// ContextualHelpSystemTests.swift
// FinanceMateTests
//
// Comprehensive Contextual Help System Test Suite
// Created: 2025-07-07
// Target: FinanceMateTests
//

/*
 * Purpose: Comprehensive test suite for ContextualHelpSystem with smart assistance and interactive guidance
 * Issues & Complexity Summary: Complex help context analysis, adaptive coaching algorithms, multimedia content delivery
 * Key Complexity Drivers:
   - Logic Scope (Est. LoC): ~300
   - Core Algorithm Complexity: High
   - Dependencies: UserDefaults, context analysis, help content management, personalization
   - State Management Complexity: High (help state, user progress, content delivery, coaching sessions)
   - Novelty/Uncertainty Factor: Medium (contextual help systems, adaptive coaching, personalization algorithms)
 * AI Pre-Task Self-Assessment: 85%
 * Problem Estimate: 88%
 * Initial Code Complexity Estimate: 85%
 * Final Code Complexity: TBD
 * Overall Result Score: TBD
 * Key Variances/Learnings: TBD
 * Last Updated: 2025-07-07
 */

import XCTest
import SwiftUI
@testable import FinanceMate

@MainActor
class ContextualHelpSystemTests: XCTestCase {
    
    var contextualHelpSystem: ContextualHelpSystem!
    var realUserDefaults: UserDefaults!
    
    override func setUp() async throws {
        try await super.setUp()
        
        // Create isolated UserDefaults for testing
        realUserDefaults = UserDefaults(suiteName: "ContextualHelpSystemTests")!
        realUserDefaults.removePersistentDomain(forName: "ContextualHelpSystemTests")
        
        // Initialize contextual help system
        contextualHelpSystem = ContextualHelpSystem(userDefaults: realUserDefaults)
    }
    
    override func tearDown() async throws {
        // Clean up UserDefaults
        realUserDefaults.removePersistentDomain(forName: "ContextualHelpSystemTests")
        
        contextualHelpSystem = nil
        realUserDefaults = nil
        try await super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testContextualHelpSystemInitialization() {
        XCTAssertNotNil(contextualHelpSystem, "ContextualHelpSystem should initialize successfully")
        XCTAssertFalse(contextualHelpSystem.isHelpSystemEnabled, "Help system should be disabled initially")
        XCTAssertNil(contextualHelpSystem.currentHelpSession, "No help session should be active initially")
    }
    
    func testHelpContentAvailability() {
        let availableContent = contextualHelpSystem.getAvailableHelpContent()
        XCTAssertGreaterThan(availableContent.count, 5, "Should have multiple help content items available")
        
        // Verify essential help topics exist
        let contentTitles = availableContent.map { $0.title }
        XCTAssertTrue(contentTitles.contains(where: { $0.contains("Transaction") }), "Should include transaction help")
        XCTAssertTrue(contentTitles.contains(where: { $0.contains("Split") }), "Should include split allocation help")
        XCTAssertTrue(contentTitles.contains(where: { $0.contains("Tax") }), "Should include tax category help")
    }
    
    // MARK: - Smart Help System Tests
    
    func testJustInTimeAssistance() async throws {
        // Enable help system
        await contextualHelpSystem.enableHelpSystem()
        
        // Simulate user struggling with split allocation
        await contextualHelpSystem.trackUserStruggle(.splitAllocation, duration: 60.0, errorCount: 3)
        
        let assistance = await contextualHelpSystem.generateJustInTimeAssistance(.splitAllocation)
        XCTAssertNotNil(assistance, "Should provide just-in-time assistance for struggling users")
        XCTAssertEqual(assistance!.priority, .high, "Assistance should be high priority for struggling users")
        XCTAssertTrue(assistance!.isContextual, "Assistance should be contextual to the current task")
    }
    
    func testContextAwareHelpDelivery() async throws {
        await contextualHelpSystem.setCurrentContext(.transactionEntry)
        
        let contextualHelp = await contextualHelpSystem.getContextualHelp()
        XCTAssertNotNil(contextualHelp, "Should provide contextual help for current context")
        XCTAssertEqual(contextualHelp!.context, .transactionEntry, "Help should match current context")
        XCTAssertGreaterThan(contextualHelp!.relevantTips.count, 0, "Should provide relevant tips")
    }
    
    func testSmartHelpPrioritization() async throws {
        // Track multiple help needs
        await contextualHelpSystem.trackHelpNeed(.basicTransactionHelp, urgency: .medium)
        await contextualHelpSystem.trackHelpNeed(.splitAllocationHelp, urgency: .high)
        await contextualHelpSystem.trackHelpNeed(.taxCategoryHelp, urgency: .low)
        
        let prioritizedHelp = await contextualHelpSystem.getPrioritizedHelpSuggestions()
        XCTAssertGreaterThan(prioritizedHelp.count, 0, "Should provide prioritized help suggestions")
        
        // Verify high priority help comes first
        XCTAssertEqual(prioritizedHelp.first?.type, .splitAllocationHelp, "High priority help should come first")
        XCTAssertEqual(prioritizedHelp.first?.urgency, .high, "First item should have high urgency")
    }
    
    func testAdaptiveHelpFrequency() async throws {
        // Track user expertise level
        await contextualHelpSystem.updateUserExpertise(.splitAllocation, level: .beginner)
        
        let helpFrequency = contextualHelpSystem.getRecommendedHelpFrequency(.splitAllocation)
        XCTAssertEqual(helpFrequency, .frequent, "Beginners should receive frequent help")
        
        // Update to expert level
        await contextualHelpSystem.updateUserExpertise(.splitAllocation, level: .expert)
        
        let expertHelpFrequency = contextualHelpSystem.getRecommendedHelpFrequency(.splitAllocation)
        XCTAssertEqual(expertHelpFrequency, .minimal, "Experts should receive minimal help")
    }
    
    // MARK: - Context-Aware Tips Tests
    
    func testSplitAllocationOptimizationTips() async throws {
        await contextualHelpSystem.setCurrentContext(.splitAllocation)
        
        // Simulate split allocation in progress
        await contextualHelpSystem.trackCurrentSplitAllocation([
            SplitData(category: "Business", percentage: 0.8),
            SplitData(category: "Personal", percentage: 0.2)
        ])
        
        let optimizationTips = await contextualHelpSystem.generateOptimizationTips(.splitAllocation)
        XCTAssertGreaterThan(optimizationTips.count, 0, "Should provide optimization tips for current split")
        
        let businessTip = optimizationTips.first { $0.category == "Business" }
        XCTAssertNotNil(businessTip, "Should provide business-specific optimization tips")
    }
    
    func testAustralianTaxGuidance() async throws {
        let taxGuidance = await contextualHelpSystem.getAustralianTaxGuidance(.gstOptimization)
        XCTAssertNotNil(taxGuidance, "Should provide Australian tax guidance")
        XCTAssertTrue(taxGuidance!.content.contains("GST"), "Should include GST information")
        XCTAssertTrue(taxGuidance!.isAustralianSpecific, "Should be marked as Australian-specific")
    }
    
    func testContextualTaxCategoryBestPractices() async throws {
        await contextualHelpSystem.setCurrentContext(.taxCategorySelection)
        
        let bestPractices = await contextualHelpSystem.getTaxCategoryBestPractices()
        XCTAssertGreaterThan(bestPractices.count, 0, "Should provide tax category best practices")
        
        let businessPractice = bestPractices.first { $0.category == .business }
        XCTAssertNotNil(businessPractice, "Should include business category best practices")
        XCTAssertTrue(businessPractice!.isAustralianCompliant, "Should be Australian tax compliant")
    }
    
    func testDynamicTipGeneration() async throws {
        // Track user transaction patterns
        await contextualHelpSystem.trackTransactionPattern(.businessExpenses, frequency: 0.8)
        await contextualHelpSystem.trackTransactionPattern(.personalExpenses, frequency: 0.2)
        
        let dynamicTips = await contextualHelpSystem.generateDynamicTips()
        XCTAssertGreaterThan(dynamicTips.count, 0, "Should generate dynamic tips based on patterns")
        
        let businessTip = dynamicTips.first { $0.targetArea == .businessExpenses }
        XCTAssertNotNil(businessTip, "Should provide business-focused tips for business-heavy users")
    }
    
    // MARK: - Interactive Walkthrough Tests
    
    func testInteractiveWalkthroughCreation() async throws {
        let walkthrough = await contextualHelpSystem.createInteractiveWalkthrough(.lineItemSplitting)
        XCTAssertNotNil(walkthrough, "Should create interactive walkthrough")
        XCTAssertGreaterThan(walkthrough!.steps.count, 3, "Walkthrough should have multiple steps")
        XCTAssertEqual(walkthrough!.workflowType, .lineItemSplitting, "Should match requested workflow type")
    }
    
    func testWalkthroughStepProgression() async throws {
        let walkthrough = await contextualHelpSystem.createInteractiveWalkthrough(.transactionEntry)
        await contextualHelpSystem.startWalkthrough(walkthrough!)
        
        XCTAssertEqual(contextualHelpSystem.currentWalkthroughStep, 0, "Should start at first step")
        
        await contextualHelpSystem.advanceWalkthroughStep()
        XCTAssertEqual(contextualHelpSystem.currentWalkthroughStep, 1, "Should advance to next step")
        
        // Complete all steps
        while contextualHelpSystem.currentWalkthroughStep < walkthrough!.steps.count - 1 {
            await contextualHelpSystem.advanceWalkthroughStep()
        }
        
        let isCompleted = await contextualHelpSystem.completeWalkthrough()
        XCTAssertTrue(isCompleted, "Walkthrough should be completed successfully")
    }
    
    func testWalkthroughInteractiveElements() async throws {
        let walkthrough = await contextualHelpSystem.createInteractiveWalkthrough(.splitAllocation)
        await contextualHelpSystem.startWalkthrough(walkthrough!)
        
        let currentStep = contextualHelpSystem.getCurrentWalkthroughStep()
        XCTAssertNotNil(currentStep, "Should have current walkthrough step")
        XCTAssertGreaterThan(currentStep!.interactiveElements.count, 0, "Steps should have interactive elements")
        
        // Test element interaction
        let firstElement = currentStep!.interactiveElements.first!
        let interactionResult = await contextualHelpSystem.interactWithElement(firstElement.id)
        XCTAssertTrue(interactionResult, "Should successfully interact with elements")
    }
    
    func testWalkthroughCustomization() async throws {
        // Set user preference for detailed walkthroughs
        await contextualHelpSystem.setWalkthroughPreference(.detailLevel, value: .comprehensive)
        
        let detailedWalkthrough = await contextualHelpSystem.createInteractiveWalkthrough(.transactionEntry)
        XCTAssertGreaterThan(detailedWalkthrough!.steps.count, 5, "Comprehensive walkthrough should have more steps")
        
        // Set preference for quick walkthroughs
        await contextualHelpSystem.setWalkthroughPreference(.detailLevel, value: .quick)
        
        let quickWalkthrough = await contextualHelpSystem.createInteractiveWalkthrough(.transactionEntry)
        XCTAssertLessThan(quickWalkthrough!.steps.count, detailedWalkthrough!.steps.count, "Quick walkthrough should have fewer steps")
    }
    
    // MARK: - Adaptive Coaching System Tests
    
    func testCoachingSessionCreation() async throws {
        let coachingSession = await contextualHelpSystem.createCoachingSession(.taxCategoryOptimization)
        XCTAssertNotNil(coachingSession, "Should create coaching session")
        XCTAssertEqual(coachingSession!.topic, .taxCategoryOptimization, "Should match requested topic")
        XCTAssertGreaterThan(coachingSession!.modules.count, 0, "Should have coaching modules")
    }
    
    func testPersonalizedCoaching() async throws {
        // Set user industry context
        await contextualHelpSystem.setUserIndustryContext(.consulting)
        
        let personalizedCoaching = await contextualHelpSystem.createPersonalizedCoaching(.businessExpenseOptimization)
        XCTAssertNotNil(personalizedCoaching, "Should create personalized coaching")
        XCTAssertTrue(personalizedCoaching!.isIndustrySpecific, "Should be industry-specific")
        XCTAssertEqual(personalizedCoaching!.industryContext, .consulting, "Should match user industry")
    }
    
    func testCoachingProgressTracking() async throws {
        let session = await contextualHelpSystem.createCoachingSession(.taxCategoryOptimization)
        await contextualHelpSystem.startCoachingSession(session!)
        
        // Complete first module
        await contextualHelpSystem.completeCoachingModule(session!.modules.first!.id)
        
        let progress = contextualHelpSystem.getCoachingProgress(session!.id)
        XCTAssertGreaterThan(progress, 0.0, "Should track coaching progress")
        XCTAssertLessThan(progress, 1.0, "Should not be complete after one module")
        
        // Complete all modules
        for module in session!.modules.dropFirst() {
            await contextualHelpSystem.completeCoachingModule(module.id)
        }
        
        let finalProgress = contextualHelpSystem.getCoachingProgress(session!.id)
        XCTAssertEqual(finalProgress, 1.0, accuracy: 0.01, "Should be complete after all modules")
    }
    
    func testAdaptiveCoachingRecommendations() async throws {
        // Track user struggles
        await contextualHelpSystem.trackUserStruggle(.taxCategorySelection, duration: 120.0, errorCount: 5)
        await contextualHelpSystem.trackUserStruggle(.splitAllocation, duration: 90.0, errorCount: 2)
        
        let recommendations = await contextualHelpSystem.generateCoachingRecommendations()
        XCTAssertGreaterThan(recommendations.count, 0, "Should generate coaching recommendations")
        
        // High struggle area should be prioritized
        let topRecommendation = recommendations.first!
        XCTAssertEqual(topRecommendation.targetArea, .taxCategorySelection, "Should prioritize area with most struggle")
        XCTAssertEqual(topRecommendation.urgency, .high, "Should have high urgency for struggling areas")
    }
    
    // MARK: - Help Content Personalization Tests
    
    func testIndustrySpecificContent() async throws {
        await contextualHelpSystem.setUserIndustryContext(.construction)
        
        let industryContent = await contextualHelpSystem.getIndustrySpecificHelpContent()
        XCTAssertGreaterThan(industryContent.count, 0, "Should provide industry-specific content")
        
        let constructionContent = industryContent.first { $0.industryContext == .construction }
        XCTAssertNotNil(constructionContent, "Should include construction-specific content")
        XCTAssertTrue(constructionContent!.content.contains("construction"), "Content should be construction-relevant")
    }
    
    func testUserNeedsBasedPersonalization() async throws {
        // Set user needs
        await contextualHelpSystem.setUserNeeds([.taxOptimization, .businessExpenseTracking])
        
        let personalizedContent = await contextualHelpSystem.getPersonalizedHelpContent()
        XCTAssertGreaterThan(personalizedContent.count, 0, "Should provide personalized content")
        
        let taxContent = personalizedContent.first { $0.addresses == .taxOptimization }
        XCTAssertNotNil(taxContent, "Should include tax optimization content")
    }
    
    func testLearningStyleAdaptation() async throws {
        // Set visual learning preference
        await contextualHelpSystem.setLearningStylePreference(.visual)
        
        let visualContent = await contextualHelpSystem.getAdaptedHelpContent(.splitAllocation)
        XCTAssertNotNil(visualContent, "Should provide learning-style adapted content")
        XCTAssertTrue(visualContent!.hasVisualElements, "Should include visual elements for visual learners")
        XCTAssertGreaterThan(visualContent!.diagrams.count, 0, "Should include diagrams")
    }
    
    func testProgressiveContentDelivery() async throws {
        // Track user competency
        await contextualHelpSystem.updateUserCompetency(.splitAllocation, level: 0.3)
        
        let beginnerContent = await contextualHelpSystem.getProgressiveContent(.splitAllocation)
        XCTAssertEqual(beginnerContent!.difficultyLevel, .beginner, "Should provide beginner content")
        XCTAssertTrue(beginnerContent!.includesBasics, "Should include basic concepts")
        
        // Advance competency
        await contextualHelpSystem.updateUserCompetency(.splitAllocation, level: 0.8)
        
        let advancedContent = await contextualHelpSystem.getProgressiveContent(.splitAllocation)
        XCTAssertEqual(advancedContent!.difficultyLevel, .advanced, "Should provide advanced content")
        XCTAssertFalse(advancedContent!.includesBasics, "Should skip basics for advanced users")
    }
    
    // MARK: - Multimedia Help Content Tests
    
    func testMultimediaContentAvailability() {
        let multimediaContent = contextualHelpSystem.getMultimediaHelpContent()
        XCTAssertGreaterThan(multimediaContent.count, 0, "Should have multimedia content available")
        
        // Verify content types
        let hasVideo = multimediaContent.contains { $0.type == .video }
        let hasInteractiveDemo = multimediaContent.contains { $0.type == .interactiveDemo }
        XCTAssertTrue(hasVideo, "Should include video content")
        XCTAssertTrue(hasInteractiveDemo, "Should include interactive demos")
    }
    
    func testInteractiveDemoCreation() async throws {
        let demo = await contextualHelpSystem.createInteractiveDemo(.lineItemSplitting)
        XCTAssertNotNil(demo, "Should create interactive demo")
        XCTAssertGreaterThan(demo!.interactionPoints.count, 0, "Demo should have interaction points")
        XCTAssertTrue(demo!.isAccessible, "Demo should be accessible")
    }
    
    func testVideoContentIntegration() async throws {
        let videoContent = await contextualHelpSystem.getVideoContent(.transactionEntry)
        XCTAssertNotNil(videoContent, "Should have video content for transaction entry")
        XCTAssertTrue(videoContent!.hasClosedCaptions, "Video should have closed captions")
        XCTAssertTrue(videoContent!.supportsSpeedControl, "Video should support speed control")
    }
    
    func testMultimediaAccessibility() {
        let multimediaContent = contextualHelpSystem.getMultimediaHelpContent()
        
        for content in multimediaContent {
            XCTAssertTrue(content.isAccessible, "All multimedia content should be accessible")
            XCTAssertFalse(content.accessibilityDescription.isEmpty, "Should have accessibility descriptions")
        }
    }
    
    // MARK: - Offline Help Capability Tests
    
    func testOfflineContentCaching() async throws {
        // Cache essential help content
        await contextualHelpSystem.cacheEssentialContent()
        
        let cachedContent = contextualHelpSystem.getCachedHelpContent()
        XCTAssertGreaterThan(cachedContent.count, 5, "Should cache essential help content")
        
        // Verify offline availability
        contextualHelpSystem.setOfflineMode(true)
        let offlineContent = contextualHelpSystem.getAvailableHelpContent()
        XCTAssertEqual(offlineContent.count, cachedContent.count, "Offline content should match cached content")
    }
    
    func testOfflineHelpQuality() {
        contextualHelpSystem.setOfflineMode(true)
        
        let offlineHelp = contextualHelpSystem.getContextualHelp()
        XCTAssertNotNil(offlineHelp, "Should provide help in offline mode")
        XCTAssertFalse(offlineHelp!.requiresInternetConnection, "Offline help should not require internet")
    }
    
    func testOfflineContentSynchronization() async throws {
        // Simulate offline usage
        contextualHelpSystem.setOfflineMode(true)
        await contextualHelpSystem.trackOfflineHelpUsage(.splitAllocation, rating: 4)
        
        // Return online and sync
        contextualHelpSystem.setOfflineMode(false)
        let syncResult = await contextualHelpSystem.synchronizeOfflineData()
        XCTAssertTrue(syncResult, "Should successfully synchronize offline data")
    }
    
    // MARK: - Help System Performance Tests
    
    func testHelpSystemPerformance() async throws {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // Generate help for multiple contexts quickly
        for context in HelpContext.allCases {
            await contextualHelpSystem.setCurrentContext(context)
            let _ = await contextualHelpSystem.getContextualHelp()
        }
        
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        XCTAssertLessThan(timeElapsed, 2.0, "Help generation should be performant")
    }
    
    func testHelpContentSearchPerformance() {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // Perform multiple searches
        let searchTerms = ["transaction", "split", "tax", "category", "business", "GST"]
        for term in searchTerms {
            let _ = contextualHelpSystem.searchHelpContent(term)
        }
        
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        XCTAssertLessThan(timeElapsed, 1.0, "Help search should be performant")
    }
    
    // MARK: - Error Handling and Edge Cases Tests
    
    func testHelpSystemWithCorruptedData() {
        // Test with corrupted user preferences
        realUserDefaults.set("invalid_data", forKey: "helpSystemPreferences")
        
        let systemWithCorruptedData = ContextualHelpSystem(userDefaults: realUserDefaults)
        
        XCTAssertNotNil(systemWithCorruptedData, "Should handle corrupted data gracefully")
        XCTAssertFalse(systemWithCorruptedData.isHelpSystemEnabled, "Should start with default state")
    }
    
    func testHelpSystemConcurrentAccess() async throws {
        await contextualHelpSystem.enableHelpSystem()
        
        // Test concurrent help requests
        await withTaskGroup(of: Void.self) { group in
            for i in 1...5 {
                group.addTask {
                    await self.contextualHelpSystem.setCurrentContext(.transactionEntry)
                    let _ = await self.contextualHelpSystem.getContextualHelp()
                }
            }
        }
        
        // Verify system remains stable
        XCTAssertTrue(contextualHelpSystem.isHelpSystemEnabled, "Help system should remain stable after concurrent access")
    }
    
    func testHelpSystemResourceManagement() async throws {
        // Create multiple coaching sessions and walkthroughs
        for i in 1...10 {
            let _ = await contextualHelpSystem.createCoachingSession(.taxCategoryOptimization)
            let _ = await contextualHelpSystem.createInteractiveWalkthrough(.transactionEntry)
        }
        
        // Test cleanup
        await contextualHelpSystem.cleanupExpiredSessions()
        
        let activeSessions = contextualHelpSystem.getActiveCoachingSessions()
        XCTAssertLessThanOrEqual(activeSessions.count, 5, "Should cleanup expired sessions")
    }
}