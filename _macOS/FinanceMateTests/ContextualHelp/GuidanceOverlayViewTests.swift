//
// GuidanceOverlayViewTests.swift
// FinanceMateTests
//
// Comprehensive test suite for Guidance Overlay View
// Created: 2025-07-07
// Target: FinanceMateTests
//

/*
 * Purpose: Test suite for interactive guidance overlay with adaptive presentation
 * Issues & Complexity Summary: UI interaction testing, overlay presentation, accessibility compliance
 * Key Complexity Drivers:
   - Logic Scope (Est. LoC): ~300 test LoC
   - Core Algorithm Complexity: Medium
   - Dependencies: GuidanceOverlayView, ContextualHelpSystem, SwiftUI, Accessibility
   - State Management Complexity: Medium (overlay state, presentation modes, user interactions)
   - Novelty/Uncertainty Factor: Low (UI testing patterns, established SwiftUI architecture)
 * AI Pre-Task Self-Assessment: 85%
 * Problem Estimate: 87%
 * Initial Code Complexity Estimate: 83%
 * Final Code Complexity: 85%
 * Overall Result Score: 90%
 * Key Variances/Learnings: UI testing requires careful attention to accessibility and interaction patterns
 * Last Updated: 2025-07-07
 */

import XCTest
import SwiftUI
@testable import FinanceMate

@MainActor
final class GuidanceOverlayViewTests: XCTestCase {
    
    var guidanceOverlayView: GuidanceOverlayView!
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
        contextualHelpSystem = ContextualHelpSystem(
            featureGatingSystem: featureGatingSystem,
            userJourneyTracker: userJourneyTracker
        )
        
        // Initialize guidance overlay view
        guidanceOverlayView = GuidanceOverlayView(
            contextualHelpSystem: contextualHelpSystem,
            context: .transactionEntry
        )
    }
    
    override func tearDown() async throws {
        guidanceOverlayView = nil
        contextualHelpSystem = nil
        featureGatingSystem = nil
        userJourneyTracker = nil
        testContext = nil
        try await super.tearDown()
    }
    
    // MARK: - Overlay Presentation Tests
    
    func testOverlayPresentationForNoviceUser() async {
        // Given: Novice user requiring guidance
        featureGatingSystem.setUserLevel(.novice)
        
        // When: Presenting overlay
        await guidanceOverlayView.presentGuidance()
        
        // Then: Should show detailed overlay with step-by-step guidance
        XCTAssertTrue(guidanceOverlayView.isPresented, "Overlay should be presented for novice user")
        XCTAssertEqual(guidanceOverlayView.presentationStyle, .detailed, "Should use detailed presentation style")
        XCTAssertTrue(guidanceOverlayView.showsStepByStepGuidance, "Should show step-by-step guidance")
    }
    
    func testOverlayPresentationForExpertUser() async {
        // Given: Expert user preferring minimal guidance
        featureGatingSystem.setUserLevel(.expert)
        
        // When: Presenting overlay
        await guidanceOverlayView.presentGuidance()
        
        // Then: Should show minimal overlay with quick tips
        XCTAssertTrue(guidanceOverlayView.isPresented, "Overlay should be presented for expert user")
        XCTAssertEqual(guidanceOverlayView.presentationStyle, .minimal, "Should use minimal presentation style")
        XCTAssertTrue(guidanceOverlayView.showsQuickTips, "Should show quick tips")
        XCTAssertFalse(guidanceOverlayView.showsStepByStepGuidance, "Should not show detailed guidance for expert")
    }
    
    func testOverlayDismissal() async {
        // Given: Presented overlay
        await guidanceOverlayView.presentGuidance()
        XCTAssertTrue(guidanceOverlayView.isPresented, "Overlay should be presented initially")
        
        // When: Dismissing overlay
        await guidanceOverlayView.dismissGuidance()
        
        // Then: Should hide overlay
        XCTAssertFalse(guidanceOverlayView.isPresented, "Overlay should be dismissed")
    }
    
    // MARK: - Interactive Element Tests
    
    func testInteractiveHelpButtons() async {
        // Given: Overlay with interactive elements
        await guidanceOverlayView.presentGuidance()
        
        // When: Checking for interactive elements
        let hasHelpButton = guidanceOverlayView.hasHelpButton
        let hasNextButton = guidanceOverlayView.hasNextButton
        let hasPreviousButton = guidanceOverlayView.hasPreviousButton
        
        // Then: Should have appropriate interactive elements
        XCTAssertTrue(hasHelpButton, "Should have help button")
        XCTAssertTrue(hasNextButton, "Should have next button")
        XCTAssertTrue(hasPreviousButton, "Should have previous button")
    }
    
    func testHelpButtonInteraction() async {
        // Given: Overlay with help button
        await guidanceOverlayView.presentGuidance()
        
        // When: Tapping help button
        await guidanceOverlayView.tapHelpButton()
        
        // Then: Should show expanded help content
        XCTAssertTrue(guidanceOverlayView.isShowingExpandedHelp, "Should show expanded help content")
        XCTAssertNotNil(guidanceOverlayView.expandedHelpContent, "Should have expanded help content")
    }
    
    func testNavigationButtonInteractions() async {
        // Given: Multi-step guidance overlay
        let multiStepContext = HelpContext.splitAllocation
        guidanceOverlayView = GuidanceOverlayView(
            contextualHelpSystem: contextualHelpSystem,
            context: multiStepContext
        )
        await guidanceOverlayView.presentGuidance()
        
        // When: Navigating through steps
        await guidanceOverlayView.tapNextButton()
        
        // Then: Should advance to next step
        XCTAssertEqual(guidanceOverlayView.currentStepIndex, 1, "Should advance to step 1")
        
        // When: Going back
        await guidanceOverlayView.tapPreviousButton()
        
        // Then: Should go back to previous step
        XCTAssertEqual(guidanceOverlayView.currentStepIndex, 0, "Should return to step 0")
    }
    
    // MARK: - Accessibility Tests
    
    func testAccessibilityLabels() async {
        // Given: Overlay presented
        await guidanceOverlayView.presentGuidance()
        
        // When: Checking accessibility labels
        let helpButtonLabel = guidanceOverlayView.helpButtonAccessibilityLabel
        let nextButtonLabel = guidanceOverlayView.nextButtonAccessibilityLabel
        let overlayLabel = guidanceOverlayView.overlayAccessibilityLabel
        
        // Then: Should have appropriate accessibility labels
        XCTAssertNotNil(helpButtonLabel, "Help button should have accessibility label")
        XCTAssertNotNil(nextButtonLabel, "Next button should have accessibility label")
        XCTAssertNotNil(overlayLabel, "Overlay should have accessibility label")
        XCTAssertTrue(helpButtonLabel?.contains("Help") ?? false, "Help button label should contain 'Help'")
    }
    
    func testAccessibilityHints() async {
        // Given: Overlay with accessibility enabled
        guidanceOverlayView.enableAccessibilityMode(true)
        await guidanceOverlayView.presentGuidance()
        
        // When: Checking accessibility hints
        let helpButtonHint = guidanceOverlayView.helpButtonAccessibilityHint
        let nextButtonHint = guidanceOverlayView.nextButtonAccessibilityHint
        
        // Then: Should have helpful accessibility hints
        XCTAssertNotNil(helpButtonHint, "Help button should have accessibility hint")
        XCTAssertNotNil(nextButtonHint, "Next button should have accessibility hint")
        XCTAssertTrue(helpButtonHint?.contains("additional guidance") ?? false, "Help button hint should describe function")
    }
    
    func testVoiceOverNavigation() async {
        // Given: VoiceOver enabled overlay
        guidanceOverlayView.enableVoiceOverMode(true)
        await guidanceOverlayView.presentGuidance()
        
        // When: Checking VoiceOver navigation elements
        let voiceOverElements = guidanceOverlayView.voiceOverNavigationElements
        
        // Then: Should have proper VoiceOver navigation
        XCTAssertGreaterThan(voiceOverElements.count, 0, "Should have VoiceOver navigation elements")
        XCTAssertTrue(guidanceOverlayView.supportsVoiceOverNavigation, "Should support VoiceOver navigation")
    }
    
    func testKeyboardNavigation() async {
        // Given: Keyboard navigation enabled
        guidanceOverlayView.enableKeyboardNavigation(true)
        await guidanceOverlayView.presentGuidance()
        
        // When: Testing keyboard navigation
        let supportsTabNavigation = guidanceOverlayView.supportsTabNavigation
        let supportsArrowKeyNavigation = guidanceOverlayView.supportsArrowKeyNavigation
        
        // Then: Should support keyboard navigation
        XCTAssertTrue(supportsTabNavigation, "Should support tab navigation")
        XCTAssertTrue(supportsArrowKeyNavigation, "Should support arrow key navigation")
    }
    
    // MARK: - Adaptive Presentation Tests
    
    func testAdaptivePresentationForLargeScreen() async {
        // Given: Large screen environment
        guidanceOverlayView.setScreenSize(.large)
        
        // When: Presenting overlay
        await guidanceOverlayView.presentGuidance()
        
        // Then: Should use appropriate layout for large screen
        XCTAssertEqual(guidanceOverlayView.layoutMode, .sidebar, "Should use sidebar layout for large screen")
        XCTAssertFalse(guidanceOverlayView.isFullScreen, "Should not be full screen on large display")
    }
    
    func testAdaptivePresentationForSmallScreen() async {
        // Given: Small screen environment
        guidanceOverlayView.setScreenSize(.small)
        
        // When: Presenting overlay
        await guidanceOverlayView.presentGuidance()
        
        // Then: Should use appropriate layout for small screen
        XCTAssertEqual(guidanceOverlayView.layoutMode, .modal, "Should use modal layout for small screen")
        XCTAssertTrue(guidanceOverlayView.isCompactPresentation, "Should use compact presentation")
    }
    
    // MARK: - Animation and Transition Tests
    
    func testPresentationAnimation() async {
        // Given: Overlay ready to present
        let animationExpectation = XCTestExpectation(description: "Presentation animation completes")
        
        // When: Presenting with animation
        await guidanceOverlayView.presentGuidanceWithAnimation()
        
        // Then: Should animate presentation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertTrue(self.guidanceOverlayView.isPresented, "Should be presented after animation")
            XCTAssertTrue(self.guidanceOverlayView.hasCompletedPresentationAnimation, "Should have completed presentation animation")
            animationExpectation.fulfill()
        }
        
        await fulfillment(of: [animationExpectation], timeout: 1.0)
    }
    
    func testDismissalAnimation() async {
        // Given: Presented overlay
        await guidanceOverlayView.presentGuidance()
        XCTAssertTrue(guidanceOverlayView.isPresented, "Should be presented initially")
        
        let animationExpectation = XCTestExpectation(description: "Dismissal animation completes")
        
        // When: Dismissing with animation
        await guidanceOverlayView.dismissGuidanceWithAnimation()
        
        // Then: Should animate dismissal
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertFalse(self.guidanceOverlayView.isPresented, "Should be dismissed after animation")
            XCTAssertTrue(self.guidanceOverlayView.hasCompletedDismissalAnimation, "Should have completed dismissal animation")
            animationExpectation.fulfill()
        }
        
        await fulfillment(of: [animationExpectation], timeout: 1.0)
    }
    
    // MARK: - Content Display Tests
    
    func testHelpContentDisplay() async {
        // Given: Overlay with help content
        await guidanceOverlayView.presentGuidance()
        
        // When: Checking content display
        let hasTitle = guidanceOverlayView.hasTitle
        let hasDescription = guidanceOverlayView.hasDescription
        let hasStepIndicator = guidanceOverlayView.hasStepIndicator
        
        // Then: Should display appropriate content
        XCTAssertTrue(hasTitle, "Should display title")
        XCTAssertTrue(hasDescription, "Should display description")
        XCTAssertTrue(hasStepIndicator, "Should display step indicator")
    }
    
    func testMultimediaContentDisplay() async {
        // Given: Overlay with multimedia content
        contextualHelpSystem.enableMultimediaContent(true)
        await guidanceOverlayView.presentGuidance()
        
        // When: Checking multimedia display
        let hasVideoContent = guidanceOverlayView.hasVideoContent
        let hasInteractiveDemo = guidanceOverlayView.hasInteractiveDemo
        let hasAudioContent = guidanceOverlayView.hasAudioContent
        
        // Then: Should display multimedia content
        XCTAssertTrue(hasVideoContent, "Should display video content")
        XCTAssertTrue(hasInteractiveDemo, "Should display interactive demo")
        XCTAssertTrue(hasAudioContent, "Should display audio content")
    }
    
    // MARK: - User Interaction Tracking Tests
    
    func testInteractionTracking() async {
        // Given: Overlay with interaction tracking
        await guidanceOverlayView.presentGuidance()
        
        // When: User interacts with overlay
        await guidanceOverlayView.tapHelpButton()
        await guidanceOverlayView.tapNextButton()
        
        // Then: Should track interactions
        let interactions = guidanceOverlayView.recordedInteractions
        XCTAssertEqual(interactions.count, 2, "Should record 2 interactions")
        XCTAssertEqual(interactions[0].type, .helpButtonTap, "First interaction should be help button tap")
        XCTAssertEqual(interactions[1].type, .nextButtonTap, "Second interaction should be next button tap")
    }
    
    func testCompletionTracking() async {
        // Given: Multi-step guidance
        let multiStepContext = HelpContext.splitAllocation
        guidanceOverlayView = GuidanceOverlayView(
            contextualHelpSystem: contextualHelpSystem,
            context: multiStepContext
        )
        await guidanceOverlayView.presentGuidance()
        
        // When: Completing all steps
        let stepCount = guidanceOverlayView.totalStepCount
        for _ in 0..<stepCount {
            await guidanceOverlayView.tapNextButton()
        }
        
        // Then: Should track completion
        XCTAssertTrue(guidanceOverlayView.isCompleted, "Should be marked as completed")
        XCTAssertNotNil(guidanceOverlayView.completionTimestamp, "Should have completion timestamp")
    }
    
    // MARK: - Performance Tests
    
    func testOverlayPresentationPerformance() async {
        // Given: Performance measurement setup
        
        // When: Measuring overlay presentation time
        let startTime = CFAbsoluteTimeGetCurrent()
        await guidanceOverlayView.presentGuidance()
        let endTime = CFAbsoluteTimeGetCurrent()
        
        // Then: Should present within acceptable time
        let presentationTime = endTime - startTime
        XCTAssertLessThan(presentationTime, 0.1, "Overlay should present within 100ms")
    }
    
    func testOverlayRenderingPerformance() async {
        // Given: Complex overlay content
        contextualHelpSystem.enableMultimediaContent(true)
        await guidanceOverlayView.presentGuidance()
        
        // When: Measuring rendering performance
        let startTime = CFAbsoluteTimeGetCurrent()
        await guidanceOverlayView.refreshContent()
        let endTime = CFAbsoluteTimeGetCurrent()
        
        // Then: Should render within acceptable time
        let renderingTime = endTime - startTime
        XCTAssertLessThan(renderingTime, 0.05, "Overlay should render content within 50ms")
    }
    
    // MARK: - Integration Tests
    
    func testIntegrationWithContextualHelpSystem() async {
        // Given: Overlay integrated with help system
        await guidanceOverlayView.presentGuidance()
        
        // When: Requesting help content
        let helpContent = await guidanceOverlayView.getCurrentHelpContent()
        
        // Then: Should integrate with help system
        XCTAssertNotNil(helpContent, "Should receive help content from system")
        XCTAssertEqual(helpContent?.context, .transactionEntry, "Should match expected context")
    }
    
    func testIntegrationWithFeatureGatingSystem() async {
        // Given: Feature gating system with specific settings
        featureGatingSystem.setUserLevel(.expert)
        
        // When: Presenting overlay
        await guidanceOverlayView.presentGuidance()
        
        // Then: Should respect feature gating settings
        XCTAssertEqual(guidanceOverlayView.adaptedUserLevel, .expert, "Should adapt to feature gating user level")
        XCTAssertTrue(guidanceOverlayView.respectsFeatureGating, "Should respect feature gating")
    }
    
    // MARK: - Error Handling Tests
    
    func testErrorHandlingForMissingContent() async {
        // Given: Missing help content scenario
        contextualHelpSystem.simulateMissingContent(true)
        
        // When: Presenting overlay
        await guidanceOverlayView.presentGuidance()
        
        // Then: Should handle missing content gracefully
        XCTAssertTrue(guidanceOverlayView.isPresented, "Should still present overlay")
        XCTAssertTrue(guidanceOverlayView.showsPlaceholderContent, "Should show placeholder content")
        XCTAssertFalse(guidanceOverlayView.showsErrorState, "Should not show error state")
    }
    
    func testErrorHandlingForNetworkFailure() async {
        // Given: Network failure scenario
        contextualHelpSystem.simulateNetworkFailure(true)
        
        // When: Attempting to load online content
        await guidanceOverlayView.presentGuidance()
        
        // Then: Should fallback to offline content
        XCTAssertTrue(guidanceOverlayView.isPresented, "Should present overlay")
        XCTAssertTrue(guidanceOverlayView.isUsingOfflineContent, "Should use offline content")
        XCTAssertFalse(guidanceOverlayView.showsNetworkError, "Should not show network error")
    }
}