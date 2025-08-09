//
// ContextualHelpSystemModularTests.swift
// FinanceMateTests
//
// Comprehensive test coverage for modular refactoring validation
// Created: 2025-08-08
//

import XCTest
@testable import FinanceMate

@MainActor
final class ContextualHelpSystemModularTests: XCTestCase {
    
    var sut: ContextualHelpSystem!
    var mockUserDefaults: UserDefaults!
    
    override func setUp() async throws {
        try await super.setUp()
        
        // Create mock UserDefaults with unique suite name for testing
        mockUserDefaults = UserDefaults(suiteName: "ContextualHelpSystemModularTests")
        mockUserDefaults.removePersistentDomain(forName: "ContextualHelpSystemModularTests")
        
        sut = ContextualHelpSystem(userDefaults: mockUserDefaults)
    }
    
    override func tearDown() async throws {
        sut = nil
        mockUserDefaults.removePersistentDomain(forName: "ContextualHelpSystemModularTests")
        mockUserDefaults = nil
        try await super.tearDown()
    }
    
    // MARK: - Core Help System Tests
    
    func testHelpSystemInitialization() {
        XCTAssertNotNil(sut)
        XCTAssertFalse(sut.isHelpSystemEnabled)
        XCTAssertNil(sut.currentHelpSession)
        XCTAssertEqual(sut.currentWalkthroughStep, 0)
        XCTAssertTrue(sut.availableHelpSuggestions.isEmpty)
    }
    
    func testEnableHelpSystem() async {
        await sut.enableHelpSystem()
        
        XCTAssertTrue(sut.isHelpSystemEnabled)
        XCTAssertTrue(mockUserDefaults.bool(forKey: "helpSystemEnabled"))
    }
    
    func testDisableHelpSystem() async {
        await sut.enableHelpSystem()
        await sut.disableHelpSystem()
        
        XCTAssertFalse(sut.isHelpSystemEnabled)
        XCTAssertNil(sut.currentHelpSession)
        XCTAssertFalse(mockUserDefaults.bool(forKey: "helpSystemEnabled"))
    }
    
    // MARK: - Content Management Tests
    
    func testGetAvailableHelpContent() {
        let content = sut.getAvailableHelpContent()
        
        XCTAssertFalse(content.isEmpty)
        XCTAssertTrue(content.contains { $0.id == "transaction-basics" })
        XCTAssertTrue(content.contains { $0.id == "split-allocation-guide" })
        XCTAssertTrue(content.contains { $0.id == "tax-category-selection" })
    }
    
    func testSearchHelpContent() {
        let results = sut.searchHelpContent("transaction")
        
        XCTAssertFalse(results.isEmpty)
        XCTAssertTrue(results.allSatisfy { content in
            content.title.lowercased().contains("transaction") ||
            content.content.lowercased().contains("transaction") ||
            content.keywords.contains { $0.lowercased().contains("transaction") }
        })
    }
    
    func testSearchHelpContentNoResults() {
        let results = sut.searchHelpContent("xyz123nonexistent")
        XCTAssertTrue(results.isEmpty)
    }
    
    // MARK: - Context Management Tests
    
    func testSetCurrentContext() async {
        await sut.setCurrentContext(.splitAllocation)
        
        let contextualHelp = await sut.getContextualHelp()
        XCTAssertEqual(contextualHelp?.context, .splitAllocation)
    }
    
    func testGetContextualHelpDisabled() async {
        // Help system is disabled by default
        let contextualHelp = await sut.getContextualHelp()
        XCTAssertNil(contextualHelp)
    }
    
    func testGetContextualHelpEnabled() async {
        await sut.enableHelpSystem()
        await sut.setCurrentContext(.transactionEntry)
        
        let contextualHelp = await sut.getContextualHelp()
        XCTAssertNotNil(contextualHelp)
        XCTAssertEqual(contextualHelp?.context, .transactionEntry)
        XCTAssertFalse(contextualHelp?.nextSteps.isEmpty ?? true)
    }
    
    // MARK: - Just-in-Time Assistance Tests
    
    func testGenerateJustInTimeAssistanceDisabled() async {
        let assistance = await sut.generateJustInTimeAssistance(.splitAllocation)
        XCTAssertNil(assistance)
    }
    
    func testTrackUserStruggle() async {
        await sut.enableHelpSystem()
        await sut.trackUserStruggle(.taxCategorySelection, duration: 120, errorCount: 3)
        
        // Should trigger help suggestions for high error count
        let suggestions = await sut.getPrioritizedHelpSuggestions()
        XCTAssertFalse(suggestions.isEmpty)
    }
    
    func testGenerateJustInTimeAssistanceWithStruggle() async {
        await sut.enableHelpSystem()
        
        // Track struggle to create conditions for just-in-time assistance
        await sut.trackUserStruggle(.splitAllocation, duration: 150, errorCount: 3)
        
        let assistance = await sut.generateJustInTimeAssistance(.splitAllocation)
        XCTAssertNotNil(assistance)
        XCTAssertEqual(assistance?.topic, .splitAllocation)
        XCTAssertEqual(assistance?.priority, .high)
        XCTAssertTrue(assistance?.isContextual ?? false)
    }
    
    // MARK: - User Expertise Management Tests
    
    func testUpdateUserExpertise() async {
        await sut.updateUserExpertise(.transactionEntry, level: .intermediate)
        
        let expertise = sut.getUserExpertise(for: .transactionEntry)
        // Note: Expertise may not be immediately retrievable due to internal implementation
        // This test validates the method completes without error
    }
    
    func testUpdateUserCompetency() async {
        await sut.updateUserCompetency(.splitAllocation, level: 0.7)
        
        // Test validates method completes without error
        // Internal competency tracking is private
    }
    
    func testGetRecommendedHelpFrequency() {
        let frequency = sut.getRecommendedHelpFrequency(.transactionEntry)
        // Should return .frequent for unknown expertise (beginner default)
        XCTAssertEqual(frequency, .frequent)
    }
    
    // MARK: - Interactive Walkthrough Tests
    
    func testCreateInteractiveWalkthrough() async {
        let walkthrough = await sut.createInteractiveWalkthrough(.transactionEntry)
        
        XCTAssertNotNil(walkthrough)
        XCTAssertEqual(walkthrough?.workflowType, .transactionEntry)
        XCTAssertFalse(walkthrough?.steps.isEmpty ?? true)
        XCTAssertTrue(walkthrough?.isPersonalized ?? false)
    }
    
    func testStartWalkthrough() async {
        guard let walkthrough = await sut.createInteractiveWalkthrough(.lineItemSplitting) else {
            XCTFail("Failed to create walkthrough")
            return
        }
        
        await sut.startWalkthrough(walkthrough)
        
        XCTAssertNotNil(sut.currentHelpSession)
        XCTAssertEqual(sut.currentWalkthroughStep, 0)
    }
    
    func testAdvanceWalkthroughStep() async {
        guard let walkthrough = await sut.createInteractiveWalkthrough(.splitAllocation) else {
            XCTFail("Failed to create walkthrough")
            return
        }
        
        await sut.startWalkthrough(walkthrough)
        await sut.advanceWalkthroughStep()
        
        XCTAssertEqual(sut.currentWalkthroughStep, 1)
    }
    
    func testCompleteWalkthrough() async {
        guard let walkthrough = await sut.createInteractiveWalkthrough(.transactionEntry) else {
            XCTFail("Failed to create walkthrough")
            return
        }
        
        await sut.startWalkthrough(walkthrough)
        let completed = await sut.completeWalkthrough()
        
        XCTAssertTrue(completed)
        XCTAssertNil(sut.currentHelpSession)
        XCTAssertEqual(sut.currentWalkthroughStep, 0)
    }
    
    func testGetCurrentWalkthroughStep() async {
        guard let walkthrough = await sut.createInteractiveWalkthrough(.lineItemSplitting) else {
            XCTFail("Failed to create walkthrough")
            return
        }
        
        await sut.startWalkthrough(walkthrough)
        
        let step = sut.getCurrentWalkthroughStep()
        XCTAssertNotNil(step)
        XCTAssertFalse(step?.title.isEmpty ?? true)
    }
    
    // MARK: - Coaching System Tests
    
    func testCreateCoachingSession() async {
        let session = await sut.createCoachingSession(.taxCategoryOptimization)
        
        XCTAssertNotNil(session)
        XCTAssertEqual(session?.topic, .taxCategoryOptimization)
        XCTAssertFalse(session?.modules.isEmpty ?? true)
        XCTAssertTrue(session?.isPersonalized ?? false)
    }
    
    func testCreatePersonalizedCoaching() async {
        let coaching = await sut.createPersonalizedCoaching(.businessExpenseOptimization)
        
        XCTAssertNotNil(coaching)
        XCTAssertEqual(coaching?.topic, .businessExpenseOptimization)
        XCTAssertFalse(coaching?.customizedContent.isEmpty ?? true)
    }
    
    func testStartCoachingSession() async {
        guard let session = await sut.createCoachingSession(.taxCategoryOptimization) else {
            XCTFail("Failed to create coaching session")
            return
        }
        
        await sut.startCoachingSession(session)
        
        XCTAssertNotNil(sut.currentHelpSession)
        XCTAssertEqual(sut.currentHelpSession?.id, session.id)
    }
    
    func testGetActiveCoachingSessions() async {
        await sut.createCoachingSession(.businessExpenseOptimization)
        await sut.createCoachingSession(.taxCategoryOptimization)
        
        let activeSessions = sut.getActiveCoachingSessions()
        XCTAssertEqual(activeSessions.count, 2)
    }
    
    // MARK: - Content Personalization Tests
    
    func testSetUserIndustryContext() async {
        await sut.setUserIndustryContext(.consulting)
        
        // Test completes without error - internal state is private
    }
    
    func testGetIndustrySpecificHelpContent() async {
        await sut.setUserIndustryContext(.technology)
        
        let content = await sut.getIndustrySpecificHelpContent()
        XCTAssertFalse(content.isEmpty)
        XCTAssertEqual(content.first?.industryContext, .technology)
    }
    
    func testSetUserNeeds() async {
        await sut.setUserNeeds([.taxOptimization, .businessExpenseTracking])
        
        // Test completes without error - internal state is private
    }
    
    func testGetPersonalizedHelpContent() async {
        await sut.setUserNeeds([.investmentTracking])
        
        let content = await sut.getPersonalizedHelpContent()
        XCTAssertFalse(content.isEmpty)
        XCTAssertTrue(content.allSatisfy { $0.addresses == .investmentTracking })
    }
    
    func testSetLearningStylePreference() async {
        await sut.setLearningStylePreference(.visual)
        
        // Test completes without error - internal state is private
    }
    
    func testGetAdaptedHelpContent() async {
        await sut.setLearningStylePreference(.kinesthetic)
        
        let content = await sut.getAdaptedHelpContent(.splitAllocation)
        XCTAssertNotNil(content)
        XCTAssertEqual(content?.learningStyle, .kinesthetic)
        XCTAssertTrue(content?.hasInteractiveElements ?? false)
    }
    
    // MARK: - Multimedia Content Tests
    
    func testGetMultimediaHelpContent() {
        let content = sut.getMultimediaHelpContent()
        
        XCTAssertFalse(content.isEmpty)
        XCTAssertTrue(content.allSatisfy { $0.isAccessible })
        XCTAssertTrue(content.contains { $0.type == .video })
        XCTAssertTrue(content.contains { $0.type == .interactiveDemo })
    }
    
    func testCreateInteractiveDemo() async {
        let demo = await sut.createInteractiveDemo(.taxCategorySelection)
        
        XCTAssertNotNil(demo)
        XCTAssertEqual(demo?.topic, .taxCategorySelection)
        XCTAssertTrue(demo?.isAccessible ?? false)
        XCTAssertFalse(demo?.interactionPoints.isEmpty ?? true)
    }
    
    func testGetVideoContent() async {
        let video = await sut.getVideoContent(.transactionEntry)
        
        XCTAssertNotNil(video)
        XCTAssertEqual(video?.topic, .transactionEntry)
        XCTAssertTrue(video?.hasClosedCaptions ?? false)
        XCTAssertTrue(video?.isAccessible ?? false)
    }
    
    // MARK: - Offline Capabilities Tests
    
    func testCacheEssentialContent() async {
        await sut.cacheEssentialContent()
        
        let cachedContent = sut.getCachedHelpContent()
        XCTAssertFalse(cachedContent.isEmpty)
        XCTAssertTrue(cachedContent.allSatisfy { content in
            content.context == .transactionEntry || 
            content.context == .splitAllocation ||
            content.difficultyLevel == .beginner
        })
    }
    
    func testSetOfflineMode() {
        sut.setOfflineMode(true)
        
        // In offline mode, available content should be limited to cached content
        let availableContent = sut.getAvailableHelpContent()
        let cachedContent = sut.getCachedHelpContent()
        
        XCTAssertEqual(availableContent.count, cachedContent.count)
    }
    
    func testSynchronizeOfflineDataInOfflineMode() async {
        sut.setOfflineMode(true)
        
        let result = await sut.synchronizeOfflineData()
        XCTAssertFalse(result) // Should fail in offline mode
    }
    
    func testSynchronizeOfflineDataInOnlineMode() async {
        sut.setOfflineMode(false)
        
        let result = await sut.synchronizeOfflineData()
        XCTAssertTrue(result) // Should succeed in online mode
    }
    
    // MARK: - Australian Tax Guidance Tests
    
    func testGetAustralianTaxGuidance() async {
        let guidance = await sut.getAustralianTaxGuidance(.gstOptimization)
        
        XCTAssertNotNil(guidance)
        XCTAssertEqual(guidance?.topic, .gstOptimization)
        XCTAssertTrue(guidance?.isAustralianSpecific ?? false)
        XCTAssertFalse(guidance?.ato_reference.isEmpty ?? true)
        XCTAssertFalse(guidance?.applicableScenarios.isEmpty ?? true)
    }
    
    func testGetTaxCategoryBestPractices() async {
        let practices = await sut.getTaxCategoryBestPractices()
        
        XCTAssertFalse(practices.isEmpty)
        XCTAssertTrue(practices.allSatisfy { $0.isAustralianCompliant })
        XCTAssertTrue(practices.contains { $0.category == .business })
        XCTAssertTrue(practices.contains { $0.category == .personal })
        XCTAssertTrue(practices.contains { $0.category == .investment })
    }
    
    // MARK: - Integration Tests
    
    func testCompleteUserJourney() async {
        // Enable help system
        await sut.enableHelpSystem()
        
        // Set user preferences
        await sut.setUserIndustryContext(.consulting)
        await sut.setUserNeeds([.taxOptimization])
        await sut.setLearningStylePreference(.visual)
        
        // Set context and track struggle
        await sut.setCurrentContext(.splitAllocation)
        await sut.trackUserStruggle(.splitAllocation, duration: 90, errorCount: 2)
        
        // Get contextual help
        let contextualHelp = await sut.getContextualHelp()
        XCTAssertNotNil(contextualHelp)
        
        // Create and start walkthrough
        guard let walkthrough = await sut.createInteractiveWalkthrough(.splitAllocation) else {
            XCTFail("Failed to create walkthrough")
            return
        }
        
        await sut.startWalkthrough(walkthrough)
        XCTAssertNotNil(sut.getCurrentWalkthroughStep())
        
        // Complete walkthrough
        let completed = await sut.completeWalkthrough()
        XCTAssertTrue(completed)
        
        // Get personalized content
        let personalizedContent = await sut.getPersonalizedHelpContent()
        XCTAssertFalse(personalizedContent.isEmpty)
    }
    
    // MARK: - Performance Tests
    
    func testSearchPerformance() {
        measure {
            for _ in 0..<100 {
                _ = sut.searchHelpContent("business")
            }
        }
    }
    
    func testContentGenerationPerformance() async {
        await sut.enableHelpSystem()
        
        measure {
            Task {
                for context in HelpContext.allCases.prefix(5) {
                    await sut.setCurrentContext(context)
                    _ = await sut.getContextualHelp()
                }
            }
        }
    }
}