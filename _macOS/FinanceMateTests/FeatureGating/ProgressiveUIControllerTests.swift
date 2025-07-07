//
// ProgressiveUIControllerTests.swift
// FinanceMateTests
//
// Progressive UI Controller Tests
// Created: 2025-07-07
// Target: FinanceMateTests
//

/*
 * Purpose: Test suite for adaptive UI management and progressive disclosure
 * Issues & Complexity Summary: UI adaptation logic, progressive disclosure, accessibility compliance
 * Key Complexity Drivers:
   - Logic Scope (Est. LoC): ~250
   - Core Algorithm Complexity: Medium-High
   - Dependencies: FeatureGatingSystem, SwiftUI view adapters, accessibility patterns
   - State Management Complexity: Medium (UI state, adaptation preferences, user context)
   - Novelty/Uncertainty Factor: Medium (adaptive UI patterns, progressive disclosure UX)
 * AI Pre-Task Self-Assessment: 80%
 * Problem Estimate: 85%
 * Initial Code Complexity Estimate: 87%
 * Final Code Complexity: TBD
 * Overall Result Score: TBD
 * Key Variances/Learnings: TBD
 * Last Updated: 2025-07-07
 */

import XCTest
import SwiftUI
@testable import FinanceMate

@MainActor
final class ProgressiveUIControllerTests: XCTestCase {
    
    // MARK: - Test Properties
    var progressiveUIController: ProgressiveUIController!
    var featureGatingSystem: FeatureGatingSystem!
    var userJourneyTracker: UserJourneyTracker!
    var testContext: NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        testContext = PersistenceController.preview.container.viewContext
        let analyticsEngine = AnalyticsEngine(context: testContext)
        userJourneyTracker = UserJourneyTracker(context: testContext, analyticsEngine: analyticsEngine, userID: "test_user")
        featureGatingSystem = FeatureGatingSystem(userJourneyTracker: userJourneyTracker)
        progressiveUIController = ProgressiveUIController(featureGatingSystem: featureGatingSystem)
    }
    
    override func tearDown() {
        progressiveUIController = nil
        featureGatingSystem = nil
        userJourneyTracker = nil
        testContext = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testProgressiveUIControllerInitialization() {
        XCTAssertNotNil(progressiveUIController, "ProgressiveUIController should initialize successfully")
        XCTAssertEqual(progressiveUIController.currentComplexityLevel, .simplified, "Initial complexity should be simplified")
        XCTAssertTrue(progressiveUIController.isAdaptationEnabled, "UI adaptation should be enabled by default")
        XCTAssertFalse(progressiveUIController.isExpertModeActive, "Expert mode should be inactive initially")
    }
    
    // MARK: - UI Adaptation Logic Tests
    
    func testUIAdaptationForNoviceUser() {
        // Given: Novice user with minimal experience
        simulateNoviceUserLevel()
        
        // When: Adapting UI for transaction view
        let transactionViewConfig = progressiveUIController.adaptUIForView(.transactionEntry)
        
        // Then: UI should be simplified with guidance
        XCTAssertEqual(transactionViewConfig.complexityLevel, .simplified, "Transaction UI should be simplified for novice")
        XCTAssertTrue(transactionViewConfig.showFieldLabels, "Field labels should be visible")
        XCTAssertTrue(transactionViewConfig.showHelpText, "Help text should be displayed")
        XCTAssertFalse(transactionViewConfig.showAdvancedFields, "Advanced fields should be hidden")
        XCTAssertTrue(transactionViewConfig.enableValidationHelp, "Validation help should be enabled")
        XCTAssertEqual(transactionViewConfig.suggestedFieldOrder, ["amount", "description", "category"], "Field order should be simplified")
    }
    
    func testUIAdaptationForIntermediateUser() {
        // Given: Intermediate user with some experience
        simulateIntermediateUserLevel()
        
        // When: Adapting UI for split allocation view
        let splitViewConfig = progressiveUIController.adaptUIForView(.splitAllocation)
        
        // Then: UI should be balanced with selective advanced features
        XCTAssertEqual(splitViewConfig.complexityLevel, .balanced, "Split UI should be balanced for intermediate")
        XCTAssertTrue(splitViewConfig.showOptionalFields, "Optional fields should be available")
        XCTAssertTrue(splitViewConfig.showPresetOptions, "Preset options should be visible")
        XCTAssertFalse(splitViewConfig.showExpertControls, "Expert controls should remain hidden")
        XCTAssertTrue(splitViewConfig.enableQuickActions, "Quick actions should be enabled")
    }
    
    func testUIAdaptationForExpertUser() {
        // Given: Expert user with extensive experience
        simulateExpertUserLevel()
        
        // When: Adapting UI for reporting view
        let reportingViewConfig = progressiveUIController.adaptUIForView(.reporting)
        
        // Then: UI should be full-featured with expert controls
        XCTAssertEqual(reportingViewConfig.complexityLevel, .advanced, "Reporting UI should be advanced for expert")
        XCTAssertTrue(reportingViewConfig.showAllFields, "All fields should be visible")
        XCTAssertTrue(reportingViewConfig.showExpertControls, "Expert controls should be available")
        XCTAssertFalse(reportingViewConfig.showBasicGuidance, "Basic guidance should be minimal")
        XCTAssertTrue(reportingViewConfig.enableAdvancedFilters, "Advanced filters should be enabled")
        XCTAssertTrue(reportingViewConfig.showCustomizationOptions, "Customization options should be available")
    }
    
    func testContextualUIAdaptation() {
        // Given: User with varied competency across different features
        simulateVariedCompetencyUser()
        
        // When: Adapting UI for different contexts
        let transactionConfig = progressiveUIController.adaptUIForView(.transactionEntry)
        let analyticsConfig = progressiveUIController.adaptUIForView(.analytics)
        
        // Then: UI should adapt based on context-specific competency
        XCTAssertEqual(transactionConfig.complexityLevel, .advanced, "Transaction UI should be advanced in strong area")
        XCTAssertEqual(analyticsConfig.complexityLevel, .simplified, "Analytics UI should be simplified in weak area")
    }
    
    // MARK: - Progressive Disclosure Tests
    
    func testProgressiveFieldDisclosure() {
        // Given: User progressing through form complexity
        let formController = progressiveUIController.createProgressiveFormController()
        
        // When: Initially displaying form
        var visibleFields = formController.getVisibleFields()
        
        // Then: Should show only essential fields
        XCTAssertEqual(visibleFields.count, 3, "Should initially show only essential fields")
        XCTAssertTrue(visibleFields.contains("amount"), "Amount field should be visible")
        XCTAssertTrue(visibleFields.contains("description"), "Description field should be visible")
        XCTAssertTrue(visibleFields.contains("category"), "Category field should be visible")
        
        // When: User demonstrates competency
        formController.recordSuccessfulInteraction(field: "amount")
        formController.recordSuccessfulInteraction(field: "description")
        formController.recordSuccessfulInteraction(field: "category")
        
        // Then: Additional fields should become available
        visibleFields = formController.getVisibleFields()
        XCTAssertGreaterThan(visibleFields.count, 3, "Should show additional fields after success")
        XCTAssertTrue(formController.canShowAdvancedFields, "Should enable advanced field display")
    }
    
    func testProgressiveOptionDisclosure() {
        // Given: Split allocation view with progressive options
        let splitController = progressiveUIController.createSplitAllocationController()
        
        // When: Initially configuring split options
        var availableOptions = splitController.getAvailableSplitOptions()
        
        // Then: Should show basic split options
        XCTAssertTrue(availableOptions.contains(.fiftyFifty), "50/50 split should be available")
        XCTAssertTrue(availableOptions.contains(.seventyThirty), "70/30 split should be available")
        XCTAssertFalse(availableOptions.contains(.customPercentages), "Custom percentages should be hidden initially")
        XCTAssertFalse(availableOptions.contains(.complexTaxCategories), "Complex tax categories should be hidden")
        
        // When: User demonstrates split allocation competency
        splitController.recordSuccessfulSplit(type: .fiftyFifty, completionTime: 30)
        splitController.recordSuccessfulSplit(type: .seventyThirty, completionTime: 45)
        splitController.recordSuccessfulSplit(type: .seventyThirty, completionTime: 25)
        
        // Then: Advanced options should unlock
        availableOptions = splitController.getAvailableSplitOptions()
        XCTAssertTrue(availableOptions.contains(.customPercentages), "Custom percentages should unlock")
        XCTAssertTrue(splitController.shouldShowAdvancedOptions, "Advanced options should be available")
    }
    
    func testProgressiveNavigationDisclosure() {
        // Given: App navigation that adapts to user level
        let navigationController = progressiveUIController.createAdaptiveNavigationController()
        
        // When: Getting navigation structure for novice user
        simulateNoviceUserLevel()
        var navigationItems = navigationController.getNavigationItems()
        
        // Then: Should show simplified navigation
        XCTAssertEqual(navigationItems.count, 3, "Should show basic navigation items")
        XCTAssertTrue(navigationItems.contains { $0.title == "Transactions" }, "Transactions should be visible")
        XCTAssertTrue(navigationItems.contains { $0.title == "Dashboard" }, "Dashboard should be visible")
        XCTAssertTrue(navigationItems.contains { $0.title == "Settings" }, "Settings should be visible")
        XCTAssertFalse(navigationItems.contains { $0.title == "Advanced Analytics" }, "Advanced Analytics should be hidden")
        
        // When: User progresses to intermediate level
        simulateIntermediateUserLevel()
        navigationItems = navigationController.getNavigationItems()
        
        // Then: Additional navigation items should appear
        XCTAssertGreaterThan(navigationItems.count, 3, "Should show additional navigation items")
        XCTAssertTrue(navigationItems.contains { $0.title == "Reports" }, "Reports should become visible")
    }
    
    // MARK: - Accessibility Adaptation Tests
    
    func testAccessibilityAdaptationForDifferentUserLevels() {
        // Given: Accessibility requirements for different user levels
        
        // When: Getting accessibility configuration for novice user
        simulateNoviceUserLevel()
        let noviceA11yConfig = progressiveUIController.getAccessibilityConfiguration()
        
        // Then: Should provide enhanced accessibility support
        XCTAssertTrue(noviceA11yConfig.enableExtendedDescriptions, "Extended descriptions should be enabled")
        XCTAssertTrue(noviceA11yConfig.enableGuidedNavigation, "Guided navigation should be enabled")
        XCTAssertEqual(noviceA11yConfig.helpPromptVerbosity, .detailed, "Help prompts should be detailed")
        XCTAssertTrue(noviceA11yConfig.enableContextualHints, "Contextual hints should be enabled")
        
        // When: Getting accessibility configuration for expert user
        simulateExpertUserLevel()
        let expertA11yConfig = progressiveUIController.getAccessibilityConfiguration()
        
        // Then: Should provide streamlined accessibility support
        XCTAssertFalse(expertA11yConfig.enableExtendedDescriptions, "Extended descriptions should be minimal")
        XCTAssertFalse(expertA11yConfig.enableGuidedNavigation, "Guided navigation should be disabled")
        XCTAssertEqual(expertA11yConfig.helpPromptVerbosity, .concise, "Help prompts should be concise")
        XCTAssertTrue(expertA11yConfig.enableKeyboardShortcuts, "Keyboard shortcuts should be enabled")
    }
    
    func testVoiceOverAdaptation() {
        // Given: VoiceOver-specific adaptations
        let voiceOverController = progressiveUIController.createVoiceOverController()
        
        // When: Configuring VoiceOver for split allocation (complex feature)
        simulateNoviceUserLevel()
        let noviceVOConfig = voiceOverController.configureForFeature(.splitAllocation)
        
        // Then: Should provide detailed VoiceOver support
        XCTAssertTrue(noviceVOConfig.enableDetailedDescriptions, "Detailed descriptions should be enabled")
        XCTAssertTrue(noviceVOConfig.enableStepByStepGuidance, "Step-by-step guidance should be enabled")
        XCTAssertGreaterThan(noviceVOConfig.customActions.count, 0, "Custom actions should be available")
        XCTAssertTrue(noviceVOConfig.enableProgressAnnouncements, "Progress announcements should be enabled")
        
        // When: Configuring VoiceOver for expert user
        simulateExpertUserLevel()
        let expertVOConfig = voiceOverController.configureForFeature(.splitAllocation)
        
        // Then: Should provide streamlined VoiceOver support
        XCTAssertFalse(expertVOConfig.enableDetailedDescriptions, "Detailed descriptions should be minimal")
        XCTAssertTrue(expertVOConfig.enableQuickActions, "Quick actions should be available")
        XCTAssertTrue(expertVOConfig.enableKeyboardNavigation, "Keyboard navigation should be optimized")
    }
    
    // MARK: - User Preference Integration Tests
    
    func testUserPreferenceOverrides() {
        // Given: User with specific UI preferences
        progressiveUIController.setUserPreference(.alwaysShowAdvancedFields, value: true)
        progressiveUIController.setUserPreference(.minimizeHelpText, value: true)
        
        // When: Adapting UI with preferences
        simulateNoviceUserLevel() // Would normally get simplified UI
        let adaptedConfig = progressiveUIController.adaptUIForView(.transactionEntry)
        
        // Then: User preferences should override automatic adaptation
        XCTAssertTrue(adaptedConfig.showAdvancedFields, "User preference should override automatic hiding")
        XCTAssertFalse(adaptedConfig.showHelpText, "Help text should be minimized per user preference")
        XCTAssertTrue(progressiveUIController.hasActiveUserOverrides, "Should track that overrides are active")
    }
    
    func testAdaptationDisabling() {
        // Given: User who wants to disable adaptive UI
        progressiveUIController.setAdaptationEnabled(false)
        
        // When: Attempting UI adaptation
        simulateNoviceUserLevel()
        let config = progressiveUIController.adaptUIForView(.splitAllocation)
        
        // Then: Should provide full-featured UI regardless of user level
        XCTAssertEqual(config.complexityLevel, .advanced, "Should show advanced UI when adaptation is disabled")
        XCTAssertTrue(config.showAllFields, "All fields should be visible")
        XCTAssertFalse(progressiveUIController.isAdaptationEnabled, "Adaptation should remain disabled")
    }
    
    func testTemporaryComplexityOverride() {
        // Given: User temporarily needs advanced features
        simulateNoviceUserLevel()
        
        // When: User requests temporary access to advanced features
        progressiveUIController.enableTemporaryAdvancedMode(duration: 300) // 5 minutes
        let temporaryConfig = progressiveUIController.adaptUIForView(.reporting)
        
        // Then: Should provide advanced UI temporarily
        XCTAssertEqual(temporaryConfig.complexityLevel, .advanced, "Should temporarily show advanced UI")
        XCTAssertTrue(progressiveUIController.isTemporaryAdvancedModeActive, "Temporary mode should be active")
        
        // When: Temporary mode expires
        progressiveUIController.simulateTimeElapse(seconds: 301)
        let expiredConfig = progressiveUIController.adaptUIForView(.reporting)
        
        // Then: Should return to appropriate complexity level
        XCTAssertEqual(expiredConfig.complexityLevel, .simplified, "Should return to simplified UI after expiry")
        XCTAssertFalse(progressiveUIController.isTemporaryAdvancedModeActive, "Temporary mode should be inactive")
    }
    
    // MARK: - Performance and Edge Case Tests
    
    func testUIAdaptationPerformance() {
        // Given: Performance-sensitive scenario
        simulateIntermediateUserLevel()
        
        // When: Rapidly requesting UI configurations
        let startTime = Date()
        for _ in 1...100 {
            let config = progressiveUIController.adaptUIForView(.transactionEntry)
            XCTAssertNotNil(config, "Should provide valid configuration")
        }
        let adaptationTime = Date().timeIntervalSince(startTime)
        
        // Then: Should maintain good performance
        XCTAssertLessThan(adaptationTime, 0.1, "100 UI adaptations should complete under 100ms")
    }
    
    func testConcurrentUIAdaptation() {
        // Given: Multiple concurrent adaptation requests
        simulateIntermediateUserLevel()
        let expectation = self.expectation(description: "Concurrent adaptations")
        expectation.expectedFulfillmentCount = 5
        
        // When: Making concurrent adaptation requests
        for i in 1...5 {
            DispatchQueue.global().async {
                let config = self.progressiveUIController.adaptUIForView(.splitAllocation)
                XCTAssertNotNil(config, "Should handle concurrent requests")
                expectation.fulfill()
            }
        }
        
        // Then: Should handle concurrency gracefully
        waitForExpectations(timeout: 1.0) { error in
            XCTAssertNil(error, "Concurrent adaptations should complete successfully")
        }
    }
    
    func testEdgeCaseUIConfigurations() {
        // Given: Edge case user progression
        simulateRapidUserProgression()
        
        // When: Adapting UI during rapid progression
        let config = progressiveUIController.adaptUIForView(.analytics)
        
        // Then: Should handle rapid changes gracefully
        XCTAssertNotNil(config, "Should provide valid configuration for edge case")
        XCTAssertTrue([.simplified, .balanced, .advanced].contains(config.complexityLevel), "Should provide valid complexity level")
    }
    
    // MARK: - Helper Methods for Test Scenarios
    
    private func simulateNoviceUserLevel() {
        featureGatingSystem.setUserLevel(.novice)
        progressiveUIController.updateFromFeatureGatingSystem()
    }
    
    private func simulateIntermediateUserLevel() {
        featureGatingSystem.setUserLevel(.intermediate)
        progressiveUIController.updateFromFeatureGatingSystem()
    }
    
    private func simulateExpertUserLevel() {
        featureGatingSystem.setUserLevel(.expert)
        progressiveUIController.updateFromFeatureGatingSystem()
    }
    
    private func simulateVariedCompetencyUser() {
        // High competency in transactions, low in analytics
        featureGatingSystem.setContextualCompetency(.transactionManagement, score: 0.9)
        featureGatingSystem.setContextualCompetency(.analytics, score: 0.2)
        progressiveUIController.updateFromFeatureGatingSystem()
    }
    
    private func simulateRapidUserProgression() {
        // Simulate user rapidly advancing through levels
        featureGatingSystem.setUserLevel(.novice)
        progressiveUIController.updateFromFeatureGatingSystem()
        
        featureGatingSystem.setUserLevel(.intermediate)
        progressiveUIController.updateFromFeatureGatingSystem()
        
        featureGatingSystem.setUserLevel(.expert)
        progressiveUIController.updateFromFeatureGatingSystem()
    }
}

// MARK: - Test Support Classes and Extensions

extension ProgressiveUIController {
    func simulateTimeElapse(seconds: TimeInterval) {
        // Simulate time passing for temporary mode testing
        temporaryAdvancedModeExpiryTime = Date().addingTimeInterval(-1)
        updateTemporaryModeStatus()
    }
    
    func setUserLevel(_ level: UserLevel) {
        // Test helper to directly set user level
        currentUserLevel = level
        updateFromFeatureGatingSystem()
    }
}