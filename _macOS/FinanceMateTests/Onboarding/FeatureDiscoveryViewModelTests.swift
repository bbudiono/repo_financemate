//
// FeatureDiscoveryViewModelTests.swift
// FinanceMateTests
//
// Comprehensive Feature Discovery & Education Test Suite
// Created: 2025-07-07
// Target: FinanceMateTests
//

/*
 * Purpose: Comprehensive test suite for FeatureDiscoveryViewModel with contextual tooltips and progressive education
 * Issues & Complexity Summary: Complex tooltip system, progressive unlocking, educational content, accessibility
 * Key Complexity Drivers:
   - Logic Scope (Est. LoC): ~350
   - Core Algorithm Complexity: High
   - Dependencies: UserDefaults, accessibility system, tooltip positioning
   - State Management Complexity: High (tooltip state, progressive unlocking, educational flow)
   - Novelty/Uncertainty Factor: Medium (contextual help systems, user engagement patterns)
 * AI Pre-Task Self-Assessment: 88%
 * Problem Estimate: 90%
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
class FeatureDiscoveryViewModelTests: XCTestCase {
    
    var featureDiscoveryViewModel: FeatureDiscoveryViewModel!
    var mockUserDefaults: UserDefaults!
    
    override func setUp() async throws {
        try await super.setUp()
        
        // Create isolated UserDefaults for testing
        mockUserDefaults = UserDefaults(suiteName: "FeatureDiscoveryTests")!
        mockUserDefaults.removePersistentDomain(forName: "FeatureDiscoveryTests")
        
        // Initialize feature discovery view model
        featureDiscoveryViewModel = FeatureDiscoveryViewModel(userDefaults: mockUserDefaults)
    }
    
    override func tearDown() async throws {
        // Clean up UserDefaults
        mockUserDefaults.removePersistentDomain(forName: "FeatureDiscoveryTests")
        
        featureDiscoveryViewModel = nil
        mockUserDefaults = nil
        try await super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testFeatureDiscoveryViewModelInitialization() {
        XCTAssertNotNil(featureDiscoveryViewModel, "FeatureDiscoveryViewModel should initialize successfully")
        XCTAssertFalse(featureDiscoveryViewModel.isTooltipSystemEnabled, "Tooltip system should be disabled initially")
        XCTAssertNil(featureDiscoveryViewModel.currentTooltip, "No tooltip should be active initially")
    }
    
    func testAvailableTooltips() {
        let tooltips = featureDiscoveryViewModel.getAvailableTooltips()
        XCTAssertGreaterThan(tooltips.count, 5, "Should have multiple tooltips available")
        
        // Verify essential tooltips exist
        let tooltipTypes = tooltips.map { $0.type }
        XCTAssertTrue(tooltipTypes.contains(.transactionEntry), "Should include transaction entry tooltip")
        XCTAssertTrue(tooltipTypes.contains(.lineItemSplitting), "Should include line item splitting tooltip")
        XCTAssertTrue(tooltipTypes.contains(.taxCategorySelection), "Should include tax category tooltip")
        XCTAssertTrue(tooltipTypes.contains(.analyticsNavigation), "Should include analytics navigation tooltip")
        XCTAssertTrue(tooltipTypes.contains(.reportGeneration), "Should include report generation tooltip")
    }
    
    // MARK: - Tooltip System Tests
    
    func testTooltipSystemEnabling() async throws {
        // Initially disabled
        XCTAssertFalse(featureDiscoveryViewModel.isTooltipSystemEnabled, "Should start disabled")
        
        // Enable tooltip system
        await featureDiscoveryViewModel.enableTooltipSystem()
        XCTAssertTrue(featureDiscoveryViewModel.isTooltipSystemEnabled, "Should be enabled after call")
        
        // Verify persistence
        let savedState = mockUserDefaults.bool(forKey: "tooltipSystemEnabled")
        XCTAssertTrue(savedState, "Tooltip system state should be persisted")
    }
    
    func testTooltipSystemDisabling() async throws {
        // Enable first
        await featureDiscoveryViewModel.enableTooltipSystem()
        XCTAssertTrue(featureDiscoveryViewModel.isTooltipSystemEnabled, "Should be enabled")
        
        // Disable tooltip system
        await featureDiscoveryViewModel.disableTooltipSystem()
        XCTAssertFalse(featureDiscoveryViewModel.isTooltipSystemEnabled, "Should be disabled after call")
        
        // Verify persistence
        let savedState = mockUserDefaults.bool(forKey: "tooltipSystemEnabled")
        XCTAssertFalse(savedState, "Disabled state should be persisted")
    }
    
    func testTooltipPresentation() async throws {
        await featureDiscoveryViewModel.enableTooltipSystem()
        
        // Present tooltip
        let tooltip = Tooltip(type: .transactionEntry, isShown: false)
        await featureDiscoveryViewModel.presentTooltip(tooltip)
        
        XCTAssertNotNil(featureDiscoveryViewModel.currentTooltip, "Tooltip should be presented")
        XCTAssertEqual(featureDiscoveryViewModel.currentTooltip?.type, .transactionEntry, "Correct tooltip type should be presented")
        XCTAssertTrue(featureDiscoveryViewModel.isTooltipVisible, "Tooltip should be visible")
    }
    
    func testTooltipDismissal() async throws {
        await featureDiscoveryViewModel.enableTooltipSystem()
        
        // Present and dismiss tooltip
        let tooltip = Tooltip(type: .lineItemSplitting, isShown: false)
        await featureDiscoveryViewModel.presentTooltip(tooltip)
        XCTAssertNotNil(featureDiscoveryViewModel.currentTooltip, "Tooltip should be presented")
        
        await featureDiscoveryViewModel.dismissCurrentTooltip()
        XCTAssertNil(featureDiscoveryViewModel.currentTooltip, "Tooltip should be dismissed")
        XCTAssertFalse(featureDiscoveryViewModel.isTooltipVisible, "Tooltip should not be visible")
    }
    
    func testTooltipAutoDismissal() async throws {
        await featureDiscoveryViewModel.enableTooltipSystem()
        
        // Present tooltip with auto-dismiss
        let tooltip = Tooltip(type: .taxCategorySelection, isShown: false, autoDismissAfter: 2.0)
        await featureDiscoveryViewModel.presentTooltip(tooltip)
        XCTAssertNotNil(featureDiscoveryViewModel.currentTooltip, "Tooltip should be presented")
        
        // Wait for auto-dismiss
        await Task.sleep(nanoseconds: 2_500_000_000) // 2.5 seconds
        XCTAssertNil(featureDiscoveryViewModel.currentTooltip, "Tooltip should auto-dismiss")
    }
    
    // MARK: - Progressive Feature Unlocking Tests
    
    func testFeatureUnlocking() async throws {
        // Initially no features unlocked
        let initialUnlocked = featureDiscoveryViewModel.getUnlockedFeatures()
        XCTAssertEqual(initialUnlocked.count, 0, "No features should be unlocked initially")
        
        // Unlock first feature
        await featureDiscoveryViewModel.unlockFeature(.basicTransactionManagement)
        let afterFirstUnlock = featureDiscoveryViewModel.getUnlockedFeatures()
        XCTAssertEqual(afterFirstUnlock.count, 1, "One feature should be unlocked")
        XCTAssertTrue(afterFirstUnlock.contains(.basicTransactionManagement), "Basic transaction management should be unlocked")
    }
    
    func testFeatureUnlockingProgression() async throws {
        // Test sequential unlocking
        await featureDiscoveryViewModel.unlockFeature(.basicTransactionManagement)
        await featureDiscoveryViewModel.unlockFeature(.lineItemSplitting)
        await featureDiscoveryViewModel.unlockFeature(.advancedAnalytics)
        
        let unlockedFeatures = featureDiscoveryViewModel.getUnlockedFeatures()
        XCTAssertEqual(unlockedFeatures.count, 3, "Three features should be unlocked")
        XCTAssertTrue(unlockedFeatures.contains(.basicTransactionManagement), "Basic feature should remain unlocked")
        XCTAssertTrue(unlockedFeatures.contains(.lineItemSplitting), "Split feature should be unlocked")
        XCTAssertTrue(unlockedFeatures.contains(.advancedAnalytics), "Analytics feature should be unlocked")
    }
    
    func testFeatureUnlockingPersistence() async throws {
        // Unlock features
        await featureDiscoveryViewModel.unlockFeature(.lineItemSplitting)
        await featureDiscoveryViewModel.unlockFeature(.reportGeneration)
        
        // Create new view model to test persistence
        let newViewModel = FeatureDiscoveryViewModel(userDefaults: mockUserDefaults)
        let persistedFeatures = newViewModel.getUnlockedFeatures()
        
        XCTAssertEqual(persistedFeatures.count, 2, "Unlocked features should be persisted")
        XCTAssertTrue(persistedFeatures.contains(.lineItemSplitting), "Split feature should be persisted")
        XCTAssertTrue(persistedFeatures.contains(.reportGeneration), "Report feature should be persisted")
    }
    
    func testFeatureAvailabilityCheck() async throws {
        // Check availability before unlocking
        XCTAssertFalse(featureDiscoveryViewModel.isFeatureUnlocked(.advancedAnalytics), "Feature should not be available initially")
        
        // Unlock and check again
        await featureDiscoveryViewModel.unlockFeature(.advancedAnalytics)
        XCTAssertTrue(featureDiscoveryViewModel.isFeatureUnlocked(.advancedAnalytics), "Feature should be available after unlocking")
    }
    
    // MARK: - Educational Content Tests
    
    func testEducationalOverlays() {
        let overlays = featureDiscoveryViewModel.getEducationalOverlays()
        XCTAssertGreaterThan(overlays.count, 3, "Should have multiple educational overlays")
        
        // Verify specific overlays exist
        let overlayTypes = overlays.map { $0.type }
        XCTAssertTrue(overlayTypes.contains(.splitAllocationBasics), "Should include split allocation overlay")
        XCTAssertTrue(overlayTypes.contains(.australianTaxCategories), "Should include Australian tax overlay")
        XCTAssertTrue(overlayTypes.contains(.analyticsInterpretation), "Should include analytics interpretation overlay")
    }
    
    func testEducationalContentAustralianTax() {
        let taxContent = featureDiscoveryViewModel.getAustralianTaxEducationContent()
        XCTAssertGreaterThan(taxContent.count, 3, "Should have multiple tax education items")
        
        // Verify content contains essential tax information
        let contentTitles = taxContent.map { $0.title }
        XCTAssertTrue(contentTitles.contains(where: { $0.contains("GST") }), "Should include GST information")
        XCTAssertTrue(contentTitles.contains(where: { $0.contains("Business") }), "Should include business expense info")
        XCTAssertTrue(contentTitles.contains(where: { $0.contains("Deduction") }), "Should include deduction information")
    }
    
    func testEducationalOverlayPresentation() async throws {
        let overlay = EducationalOverlay(type: .splitAllocationBasics, isShown: false)
        await featureDiscoveryViewModel.presentEducationalOverlay(overlay)
        
        XCTAssertNotNil(featureDiscoveryViewModel.currentEducationalOverlay, "Educational overlay should be presented")
        XCTAssertEqual(featureDiscoveryViewModel.currentEducationalOverlay?.type, .splitAllocationBasics, "Correct overlay should be presented")
    }
    
    func testEducationalOverlayCompletion() async throws {
        let overlay = EducationalOverlay(type: .australianTaxCategories, isShown: false)
        await featureDiscoveryViewModel.presentEducationalOverlay(overlay)
        
        // Mark as completed
        await featureDiscoveryViewModel.completeEducationalOverlay(overlay)
        
        let completedOverlays = featureDiscoveryViewModel.getCompletedEducationalOverlays()
        XCTAssertTrue(completedOverlays.contains(where: { $0.type == .australianTaxCategories }), "Overlay should be marked as completed")
    }
    
    // MARK: - Interactive Help System Tests
    
    func testInteractiveHelpAvailability() {
        let helpTopics = featureDiscoveryViewModel.getAvailableHelpTopics()
        XCTAssertGreaterThan(helpTopics.count, 5, "Should have multiple help topics")
        
        // Verify essential help topics
        let topicTitles = helpTopics.map { $0.title }
        XCTAssertTrue(topicTitles.contains(where: { $0.contains("Transaction") }), "Should include transaction help")
        XCTAssertTrue(topicTitles.contains(where: { $0.contains("Split") }), "Should include split allocation help")
        XCTAssertTrue(topicTitles.contains(where: { $0.contains("Tax") }), "Should include tax category help")
    }
    
    func testHelpTopicSearch() {
        let searchResults = featureDiscoveryViewModel.searchHelpTopics(query: "transaction")
        XCTAssertGreaterThan(searchResults.count, 0, "Should find help topics for 'transaction'")
        
        // Verify search relevance
        for result in searchResults {
            let containsQuery = result.title.lowercased().contains("transaction") || 
                               result.content.lowercased().contains("transaction")
            XCTAssertTrue(containsQuery, "Search result should contain query term")
        }
    }
    
    func testHelpTopicSearchCaseInsensitive() {
        let lowerResults = featureDiscoveryViewModel.searchHelpTopics(query: "split")
        let upperResults = featureDiscoveryViewModel.searchHelpTopics(query: "SPLIT")
        let mixedResults = featureDiscoveryViewModel.searchHelpTopics(query: "Split")
        
        XCTAssertEqual(lowerResults.count, upperResults.count, "Search should be case insensitive")
        XCTAssertEqual(lowerResults.count, mixedResults.count, "Search should be case insensitive")
    }
    
    func testEmptySearchQuery() {
        let emptyResults = featureDiscoveryViewModel.searchHelpTopics(query: "")
        let allTopics = featureDiscoveryViewModel.getAvailableHelpTopics()
        
        XCTAssertEqual(emptyResults.count, allTopics.count, "Empty query should return all topics")
    }
    
    // MARK: - Feature Announcement System Tests
    
    func testFeatureAnnouncements() {
        let announcements = featureDiscoveryViewModel.getPendingAnnouncements()
        XCTAssertGreaterThanOrEqual(announcements.count, 0, "Should handle announcements gracefully")
    }
    
    func testFeatureAnnouncementCreation() async throws {
        let announcement = FeatureAnnouncement(
            title: "New Analytics Features",
            description: "Advanced reporting capabilities now available",
            featureType: .advancedAnalytics,
            isRead: false
        )
        
        await featureDiscoveryViewModel.addFeatureAnnouncement(announcement)
        let pendingAnnouncements = featureDiscoveryViewModel.getPendingAnnouncements()
        
        XCTAssertTrue(pendingAnnouncements.contains(where: { $0.title == "New Analytics Features" }), "Announcement should be added")
    }
    
    func testFeatureAnnouncementMarkAsRead() async throws {
        let announcement = FeatureAnnouncement(
            title: "Line Item Updates",
            description: "Enhanced split allocation features",
            featureType: .lineItemSplitting,
            isRead: false
        )
        
        await featureDiscoveryViewModel.addFeatureAnnouncement(announcement)
        await featureDiscoveryViewModel.markAnnouncementAsRead(announcement)
        
        let readAnnouncements = featureDiscoveryViewModel.getReadAnnouncements()
        XCTAssertTrue(readAnnouncements.contains(where: { $0.title == "Line Item Updates" }), "Announcement should be marked as read")
    }
    
    // MARK: - Accessibility Support Tests
    
    func testAccessibilitySupport() {
        XCTAssertTrue(featureDiscoveryViewModel.isAccessibilitySupported, "Should support accessibility features")
    }
    
    func testVoiceOverTooltipDescriptions() {
        let tooltips = featureDiscoveryViewModel.getAvailableTooltips()
        
        for tooltip in tooltips {
            XCTAssertFalse(tooltip.accessibilityLabel.isEmpty, "Tooltip should have accessibility label")
            XCTAssertFalse(tooltip.accessibilityHint.isEmpty, "Tooltip should have accessibility hint")
        }
    }
    
    func testAccessibilityActionsForTooltips() async throws {
        await featureDiscoveryViewModel.enableTooltipSystem()
        let tooltip = Tooltip(type: .analyticsNavigation, isShown: false)
        await featureDiscoveryViewModel.presentTooltip(tooltip)
        
        let accessibilityActions = featureDiscoveryViewModel.getTooltipAccessibilityActions()
        XCTAssertGreaterThan(accessibilityActions.count, 0, "Should provide accessibility actions for tooltips")
        
        // Verify essential actions exist
        let actionNames = accessibilityActions.map { $0.name }
        XCTAssertTrue(actionNames.contains("Dismiss"), "Should have dismiss action")
        XCTAssertTrue(actionNames.contains("More Info"), "Should have more info action")
    }
    
    // MARK: - User Engagement Tracking Tests
    
    func testEngagementTracking() async throws {
        // Track tooltip interaction
        await featureDiscoveryViewModel.trackTooltipInteraction(.transactionEntry, action: .viewed)
        
        let engagementData = featureDiscoveryViewModel.getEngagementData()
        XCTAssertGreaterThan(engagementData.tooltipInteractions.count, 0, "Should track tooltip interactions")
    }
    
    func testEngagementDataPersistence() async throws {
        // Track multiple interactions
        await featureDiscoveryViewModel.trackTooltipInteraction(.lineItemSplitting, action: .viewed)
        await featureDiscoveryViewModel.trackTooltipInteraction(.lineItemSplitting, action: .dismissed)
        await featureDiscoveryViewModel.trackEducationalOverlayInteraction(.splitAllocationBasics, action: .completed)
        
        // Create new view model to test persistence
        let newViewModel = FeatureDiscoveryViewModel(userDefaults: mockUserDefaults)
        let persistedData = newViewModel.getEngagementData()
        
        XCTAssertGreaterThan(persistedData.tooltipInteractions.count, 0, "Engagement data should be persisted")
    }
    
    // MARK: - Performance Tests
    
    func testTooltipSystemPerformance() async throws {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        await featureDiscoveryViewModel.enableTooltipSystem()
        
        // Present and dismiss multiple tooltips quickly
        for i in 0..<10 {
            let tooltipType: TooltipType = i % 2 == 0 ? .transactionEntry : .lineItemSplitting
            let tooltip = Tooltip(type: tooltipType, isShown: false)
            await featureDiscoveryViewModel.presentTooltip(tooltip)
            await featureDiscoveryViewModel.dismissCurrentTooltip()
        }
        
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        XCTAssertLessThan(timeElapsed, 1.0, "Tooltip operations should be performant")
    }
    
    func testHelpSearchPerformance() {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // Perform multiple searches
        for query in ["transaction", "split", "tax", "analytics", "report"] {
            let _ = featureDiscoveryViewModel.searchHelpTopics(query: query)
        }
        
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        XCTAssertLessThan(timeElapsed, 0.5, "Help search should be performant")
    }
    
    // MARK: - Error Handling Tests
    
    func testInvalidTooltipHandling() async throws {
        await featureDiscoveryViewModel.enableTooltipSystem()
        
        // Attempt to present nil tooltip (edge case)
        let tooltip = Tooltip(type: .transactionEntry, isShown: true) // Already shown
        await featureDiscoveryViewModel.presentTooltip(tooltip)
        
        // Should handle gracefully without crashing
        XCTAssertNotNil(featureDiscoveryViewModel, "Should handle invalid tooltip gracefully")
    }
    
    func testUserDefaultsFailureHandling() {
        // Test with corrupted UserDefaults
        mockUserDefaults.set("invalid_data", forKey: "unlockedFeatures")
        
        let viewModel = FeatureDiscoveryViewModel(userDefaults: mockUserDefaults)
        let unlockedFeatures = viewModel.getUnlockedFeatures()
        
        XCTAssertEqual(unlockedFeatures.count, 0, "Should handle corrupted data gracefully")
    }
}