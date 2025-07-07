//
// ContextualHelpSystemTests.swift
// FinanceMateTests
//
// Comprehensive test suite for Contextual Help System
// Created: 2025-07-07
// Target: FinanceMateTests
//

/*
 * Purpose: Test suite for intelligent contextual help system with adaptive coaching
 * Issues & Complexity Summary: Context detection, adaptive content selection, multimedia support, offline capabilities
 * Key Complexity Drivers:
   - Logic Scope (Est. LoC): ~400 test LoC
   - Core Algorithm Complexity: Medium-High
   - Dependencies: ContextualHelpSystem, FeatureGatingSystem, UserJourneyTracker, Core Data
   - State Management Complexity: High (context state, help content, user progress)
   - Novelty/Uncertainty Factor: Medium (contextual intelligence, adaptive coaching patterns)
 * AI Pre-Task Self-Assessment: 88%
 * Problem Estimate: 90%
 * Initial Code Complexity Estimate: 85%
 * Final Code Complexity: 87%
 * Overall Result Score: 92%
 * Key Variances/Learnings: Contextual help requires careful balance of intelligence and user control
 * Last Updated: 2025-07-07
 */

import XCTest
import CoreData
@testable import FinanceMate

@MainActor
final class ContextualHelpSystemTests: XCTestCase {
    
    var contextualHelpSystem: ContextualHelpSystem!
    var testContext: NSManagedObjectContext!
    var userJourneyTracker: UserJourneyTracker!
    var featureGatingSystem: FeatureGatingSystem!
    
    override func setUp() async throws {
        try await super.setUp()
        
        // Set up Core Data test context
        testContext = PersistenceController.preview.container.viewContext
        
        // Initialize dependencies
        userJourneyTracker = UserJourneyTracker(context: testContext)
        featureGatingSystem = FeatureGatingSystem(userJourneyTracker: userJourneyTracker)
        
        // Initialize contextual help system
        contextualHelpSystem = ContextualHelpSystem(
            featureGatingSystem: featureGatingSystem,
            userJourneyTracker: userJourneyTracker
        )
    }
    
    override func tearDown() async throws {
        contextualHelpSystem = nil
        featureGatingSystem = nil
        userJourneyTracker = nil
        testContext = nil
        try await super.tearDown()
    }
    
    // MARK: - Context Detection Tests
    
    func testContextDetectionForTransactionEntry() async {
        // Given: User is in transaction entry context
        let context = HelpContext.transactionEntry
        
        // When: Detecting context
        let detectedContext = await contextualHelpSystem.detectCurrentContext(context)
        
        // Then: Should correctly identify transaction entry context
        XCTAssertEqual(detectedContext, .transactionEntry, "Should detect transaction entry context")
    }
    
    func testContextDetectionForSplitAllocation() async {
        // Given: User is in split allocation context
        let context = HelpContext.splitAllocation
        
        // When: Detecting context with user struggle pattern
        userJourneyTracker.trackEvent(.splitAllocationStarted)
        userJourneyTracker.trackEvent(.splitAllocationAbandoned)
        let detectedContext = await contextualHelpSystem.detectCurrentContext(context)
        
        // Then: Should detect split allocation with struggle pattern
        XCTAssertEqual(detectedContext, .splitAllocation, "Should detect split allocation context")
        let helpContent = await contextualHelpSystem.getContextualHelp(for: detectedContext)
        XCTAssertTrue(helpContent.isAdaptedForStruggle, "Should adapt content for user struggle")
    }
    
    func testContextDetectionForReporting() async {
        // Given: User is in reporting context
        let context = HelpContext.reporting
        
        // When: Detecting context
        let detectedContext = await contextualHelpSystem.detectCurrentContext(context)
        
        // Then: Should correctly identify reporting context
        XCTAssertEqual(detectedContext, .reporting, "Should detect reporting context")
    }
    
    // MARK: - Adaptive Coaching Tests
    
    func testAdaptiveCoachingForNoviceUser() async {
        // Given: Novice user in split allocation
        featureGatingSystem.setUserLevel(.novice)
        let context = HelpContext.splitAllocation
        
        // When: Getting contextual help
        let helpContent = await contextualHelpSystem.getContextualHelp(for: context)
        
        // Then: Should provide detailed, step-by-step guidance
        XCTAssertEqual(helpContent.complexity, .simplified, "Novice user should get simplified help")
        XCTAssertTrue(helpContent.includesStepByStepGuidance, "Should include step-by-step guidance")
        XCTAssertTrue(helpContent.includesBasicConcepts, "Should include basic concept explanations")
        XCTAssertFalse(helpContent.includesAdvancedTips, "Should not include advanced tips for novice")
    }
    
    func testAdaptiveCoachingForIntermediateUser() async {
        // Given: Intermediate user in split allocation
        featureGatingSystem.setUserLevel(.intermediate)
        let context = HelpContext.splitAllocation
        
        // When: Getting contextual help
        let helpContent = await contextualHelpSystem.getContextualHelp(for: context)
        
        // Then: Should provide balanced guidance with some advanced tips
        XCTAssertEqual(helpContent.complexity, .balanced, "Intermediate user should get balanced help")
        XCTAssertTrue(helpContent.includesOptimizationTips, "Should include optimization tips")
        XCTAssertTrue(helpContent.includesBestPractices, "Should include best practices")
        XCTAssertFalse(helpContent.includesStepByStepGuidance, "Should not need basic step-by-step for intermediate")
    }
    
    func testAdaptiveCoachingForExpertUser() async {
        // Given: Expert user in split allocation
        featureGatingSystem.setUserLevel(.expert)
        let context = HelpContext.splitAllocation
        
        // When: Getting contextual help
        let helpContent = await contextualHelpSystem.getContextualHelp(for: context)
        
        // Then: Should provide advanced tips and shortcuts
        XCTAssertEqual(helpContent.complexity, .advanced, "Expert user should get advanced help")
        XCTAssertTrue(helpContent.includesAdvancedTips, "Should include advanced tips")
        XCTAssertTrue(helpContent.includesKeyboardShortcuts, "Should include keyboard shortcuts")
        XCTAssertTrue(helpContent.includesExpertModeFeatures, "Should include expert mode features")
        XCTAssertFalse(helpContent.includesBasicConcepts, "Should not include basic concepts for expert")
    }
    
    // MARK: - Just-in-Time Assistance Tests
    
    func testJustInTimeAssistanceForStrugglingUser() async {
        // Given: User struggling with split allocation
        userJourneyTracker.trackEvent(.splitAllocationStarted)
        userJourneyTracker.trackEvent(.splitAllocationError)
        userJourneyTracker.trackEvent(.splitAllocationError)
        userJourneyTracker.trackEvent(.splitAllocationError)
        
        // When: Checking for just-in-time assistance
        let shouldShowHelp = await contextualHelpSystem.shouldShowJustInTimeHelp(for: .splitAllocation)
        
        // Then: Should trigger just-in-time assistance
        XCTAssertTrue(shouldShowHelp, "Should show just-in-time help for struggling user")
        
        let helpContent = await contextualHelpSystem.getJustInTimeHelp(for: .splitAllocation)
        XCTAssertEqual(helpContent.priority, .high, "Struggling user should get high priority help")
        XCTAssertTrue(helpContent.isInterruptive, "Should be interruptive for struggling user")
    }
    
    func testJustInTimeAssistanceForSuccessfulUser() async {
        // Given: User successfully completing tasks
        userJourneyTracker.trackEvent(.splitAllocationStarted)
        userJourneyTracker.trackEvent(.splitAllocationCompleted)
        
        // When: Checking for just-in-time assistance
        let shouldShowHelp = await contextualHelpSystem.shouldShowJustInTimeHelp(for: .splitAllocation)
        
        // Then: Should not trigger intrusive help
        XCTAssertFalse(shouldShowHelp, "Should not show intrusive help for successful user")
    }
    
    // MARK: - Tax Category Best Practices Tests
    
    func testTaxCategoryBestPracticesForBusinessUser() async {
        // Given: User identified as business user
        contextualHelpSystem.setUserProfile(.business)
        let context = HelpContext.taxCategorySelection
        
        // When: Getting tax category help
        let helpContent = await contextualHelpSystem.getContextualHelp(for: context)
        
        // Then: Should provide business-specific tax guidance
        XCTAssertTrue(helpContent.includesBusinessTaxTips, "Should include business tax tips")
        XCTAssertTrue(helpContent.includesAustralianTaxCompliance, "Should include Australian tax compliance")
        XCTAssertTrue(helpContent.includesDeductionGuidance, "Should include deduction guidance")
    }
    
    func testTaxCategoryBestPracticesForPersonalUser() async {
        // Given: User identified as personal user
        contextualHelpSystem.setUserProfile(.personal)
        let context = HelpContext.taxCategorySelection
        
        // When: Getting tax category help
        let helpContent = await contextualHelpSystem.getContextualHelp(for: context)
        
        // Then: Should provide personal tax guidance
        XCTAssertTrue(helpContent.includesPersonalTaxTips, "Should include personal tax tips")
        XCTAssertTrue(helpContent.includesSimplifiedCategories, "Should include simplified categories")
        XCTAssertFalse(helpContent.includesComplexBusinessRules, "Should not include complex business rules")
    }
    
    // MARK: - Interactive Walkthrough Tests
    
    func testInteractiveWalkthroughInitiation() async {
        // Given: User requesting walkthrough for complex workflow
        let workflow = FinancialWorkflow.splitAllocationCreation
        
        // When: Initiating interactive walkthrough
        let walkthrough = await contextualHelpSystem.createInteractiveWalkthrough(for: workflow)
        
        // Then: Should create appropriate walkthrough
        XCTAssertNotNil(walkthrough, "Should create walkthrough")
        XCTAssertEqual(walkthrough?.workflow, workflow, "Should match requested workflow")
        XCTAssertGreaterThan(walkthrough?.steps.count ?? 0, 0, "Should have walkthrough steps")
    }
    
    func testInteractiveWalkthroughProgression() async {
        // Given: User in active walkthrough
        let workflow = FinancialWorkflow.splitAllocationCreation
        let walkthrough = await contextualHelpSystem.createInteractiveWalkthrough(for: workflow)
        
        // When: Progressing through walkthrough steps
        await contextualHelpSystem.advanceWalkthroughStep()
        
        // Then: Should advance to next step
        let currentStep = await contextualHelpSystem.getCurrentWalkthroughStep()
        XCTAssertEqual(currentStep?.stepNumber, 2, "Should advance to step 2")
    }
    
    func testInteractiveWalkthroughCompletion() async {
        // Given: User completing walkthrough
        let workflow = FinancialWorkflow.splitAllocationCreation
        let walkthrough = await contextualHelpSystem.createInteractiveWalkthrough(for: workflow)
        
        // When: Completing all walkthrough steps
        for _ in 0..<(walkthrough?.steps.count ?? 0) {
            await contextualHelpSystem.advanceWalkthroughStep()
        }
        
        // Then: Should mark walkthrough as completed
        let isCompleted = await contextualHelpSystem.isWalkthroughCompleted(workflow)
        XCTAssertTrue(isCompleted, "Should mark walkthrough as completed")
    }
    
    // MARK: - Multimedia Content Tests
    
    func testMultimediaContentDelivery() async {
        // Given: Help content with multimedia support
        let context = HelpContext.splitAllocation
        
        // When: Getting multimedia help content
        let helpContent = await contextualHelpSystem.getContextualHelp(for: context)
        
        // Then: Should include multimedia content
        XCTAssertTrue(helpContent.hasMultimediaContent, "Should have multimedia content")
        XCTAssertNotNil(helpContent.videoContent, "Should have video content")
        XCTAssertNotNil(helpContent.interactiveDemos, "Should have interactive demos")
    }
    
    func testMultimediaContentAccessibility() async {
        // Given: User with accessibility needs
        contextualHelpSystem.enableAccessibilityMode(true)
        let context = HelpContext.splitAllocation
        
        // When: Getting multimedia help content
        let helpContent = await contextualHelpSystem.getContextualHelp(for: context)
        
        // Then: Should provide accessible multimedia alternatives
        XCTAssertTrue(helpContent.hasAudioDescriptions, "Should have audio descriptions")
        XCTAssertTrue(helpContent.hasTextAlternatives, "Should have text alternatives")
        XCTAssertTrue(helpContent.supportsVoiceOver, "Should support VoiceOver")
    }
    
    // MARK: - Offline Capability Tests
    
    func testOfflineContentAvailability() async {
        // Given: Device in offline mode
        contextualHelpSystem.setOfflineMode(true)
        let context = HelpContext.transactionEntry
        
        // When: Getting help content offline
        let helpContent = await contextualHelpSystem.getContextualHelp(for: context)
        
        // Then: Should provide offline content
        XCTAssertNotNil(helpContent, "Should provide offline content")
        XCTAssertTrue(helpContent.isOfflineCapable, "Should be offline capable")
        XCTAssertFalse(helpContent.requiresNetworkConnection, "Should not require network connection")
    }
    
    func testOfflineContentCaching() async {
        // Given: Online content accessed previously
        contextualHelpSystem.setOfflineMode(false)
        let context = HelpContext.splitAllocation
        let _ = await contextualHelpSystem.getContextualHelp(for: context)
        
        // When: Switching to offline mode
        contextualHelpSystem.setOfflineMode(true)
        let offlineContent = await contextualHelpSystem.getContextualHelp(for: context)
        
        // Then: Should serve cached content
        XCTAssertNotNil(offlineContent, "Should serve cached content offline")
        XCTAssertTrue(offlineContent.isFromCache, "Should indicate content is from cache")
    }
    
    // MARK: - Personalization Tests
    
    func testPersonalizationBasedOnUserIndustry() async {
        // Given: User in construction industry
        contextualHelpSystem.setUserIndustry(.construction)
        let context = HelpContext.taxCategorySelection
        
        // When: Getting personalized help
        let helpContent = await contextualHelpSystem.getContextualHelp(for: context)
        
        // Then: Should provide industry-specific guidance
        XCTAssertTrue(helpContent.isPersonalized, "Should be personalized")
        XCTAssertTrue(helpContent.includesIndustrySpecificTips, "Should include industry-specific tips")
        XCTAssertTrue(helpContent.includesConstructionTaxGuidance, "Should include construction tax guidance")
    }
    
    func testPersonalizationBasedOnUsagePatterns() async {
        // Given: User with specific usage patterns
        userJourneyTracker.trackEvent(.splitAllocationStarted)
        userJourneyTracker.trackEvent(.splitAllocationCompleted)
        userJourneyTracker.trackEvent(.reportingViewed)
        userJourneyTracker.trackEvent(.analyticsViewed)
        
        // When: Getting personalized help
        let context = HelpContext.splitAllocation
        let helpContent = await contextualHelpSystem.getContextualHelp(for: context)
        
        // Then: Should adapt to usage patterns
        XCTAssertTrue(helpContent.isAdaptedToUsagePatterns, "Should adapt to usage patterns")
        XCTAssertTrue(helpContent.includesAdvancedFeatureHints, "Should include advanced feature hints")
    }
    
    // MARK: - Performance Tests
    
    func testHelpContentDeliveryPerformance() async {
        // Given: Performance measurement setup
        let context = HelpContext.splitAllocation
        
        // When: Measuring help content delivery time
        let startTime = CFAbsoluteTimeGetCurrent()
        let _ = await contextualHelpSystem.getContextualHelp(for: context)
        let endTime = CFAbsoluteTimeGetCurrent()
        
        // Then: Should deliver content within acceptable time
        let deliveryTime = endTime - startTime
        XCTAssertLessThan(deliveryTime, 0.1, "Help content should be delivered within 100ms")
    }
    
    func testContextDetectionPerformance() async {
        // Given: Performance measurement setup
        let context = HelpContext.transactionEntry
        
        // When: Measuring context detection time
        let startTime = CFAbsoluteTimeGetCurrent()
        let _ = await contextualHelpSystem.detectCurrentContext(context)
        let endTime = CFAbsoluteTimeGetCurrent()
        
        // Then: Should detect context within acceptable time
        let detectionTime = endTime - startTime
        XCTAssertLessThan(detectionTime, 0.05, "Context detection should complete within 50ms")
    }
    
    // MARK: - Integration Tests
    
    func testIntegrationWithFeatureGatingSystem() async {
        // Given: Feature gating system with specific user level
        featureGatingSystem.setUserLevel(.intermediate)
        
        // When: Getting contextual help
        let context = HelpContext.splitAllocation
        let helpContent = await contextualHelpSystem.getContextualHelp(for: context)
        
        // Then: Should integrate with feature gating
        XCTAssertEqual(helpContent.targetUserLevel, .intermediate, "Should match feature gating user level")
        XCTAssertTrue(helpContent.respectsFeatureGating, "Should respect feature gating settings")
    }
    
    func testIntegrationWithUserJourneyTracker() async {
        // Given: User journey with specific patterns
        userJourneyTracker.trackEvent(.onboardingCompleted)
        userJourneyTracker.trackEvent(.firstTransactionCreated)
        userJourneyTracker.trackEvent(.splitAllocationStarted)
        
        // When: Getting contextual help
        let context = HelpContext.splitAllocation
        let helpContent = await contextualHelpSystem.getContextualHelp(for: context)
        
        // Then: Should consider user journey
        XCTAssertTrue(helpContent.considersUserJourney, "Should consider user journey")
        XCTAssertTrue(helpContent.isContextuallyRelevant, "Should be contextually relevant")
    }
}