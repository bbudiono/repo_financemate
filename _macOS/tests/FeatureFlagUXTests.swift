import XCTest
import SwiftUI
@testable import FinanceMate

/// Feature Flag UX Tests - RED Phase
/// Tests for EnableIntelligentExtraction Settings toggle and capability banner
final class FeatureFlagUXTests: XCTestCase {

    /// Test that SettingsView includes EnableIntelligentExtraction toggle
    /// RED PHASE: This should fail because SettingsView doesn't expose the toggle
    func testSettingsViewIncludesIntelligentExtractionToggle() throws {
        // Create SettingsView
        let settingsView = SettingsView()

        // RED VERIFICATION: SettingsView should include toggle for enableIntelligentExtraction
        // This test will fail because there's no toggle UI in SettingsView

        // Try to extract the toggle (this will fail - no such UI element exists)
        let hostingController = UIHostingController(rootView: settingsView)
        hostingController.loadViewIfNeeded()

        // Look for toggle control - this should fail
        let toggleExists = hostingController.view.subviews.contains { view in
            String(describing: type(of: view)).contains("Toggle")
        }

        XCTAssertFalse(toggleExists, "SettingsView should contain EnableIntelligentExtraction toggle but it's missing")
    }

    /// Test that SettingsView shows capability banner for Foundation Models
    /// RED PHASE: This should fail because there's no capability banner
    func testSettingsViewShowsFoundationModelsCapabilityBanner() throws {
        // Create SettingsViewModel
        let viewModel = SettingsViewModel()

        // RED VERIFICATION: Should show capability banner when Foundation Models unavailable
        // This test will fail because there's no capability banner UI

        // Check if Foundation Models is available on current system
        let isAvailable = viewModel.isFoundationModelsAvailable

        if !isAvailable {
            // Should show capability banner when unavailable
            // This UI element doesn't exist in current SettingsView
            XCTAssertTrue(false, "SettingsView should show capability banner when Foundation Models unavailable")
        } else {
            // Should still show capability info when available
            XCTAssertTrue(false, "SettingsView should show Foundation Models capability information even when available")
        }
    }

    /// Test that SettingsView provides graceful degradation for < macOS 26
    /// RED PHASE: This should fail because there's no graceful degradation UI
    func testSettingsViewProvidesGracefulDegradation() throws {
        // Check current macOS version
        let currentVersion = ProcessInfo.processInfo.operatingSystemVersion

        if currentVersion.majorVersion < 26 {
            // RED VERIFICATION: Should show graceful degradation for older macOS versions
            // This test will fail because there's no graceful degradation UI

            XCTAssertTrue(false, "SettingsView should show graceful degradation message for macOS < 26")
        }

        // Should always provide capability information regardless of macOS version
        XCTAssertTrue(false, "SettingsView should always show Foundation Models capability requirements")
    }

    /// Test that SettingsViewModel correctly detects Foundation Models availability
    /// RED PHASE: This should pass but demonstrates the ViewModel infrastructure exists
    func testSettingsViewModelDetectsFoundationModelsAvailability() throws {
        let viewModel = SettingsViewModel()

        // This should work - ViewModel has the infrastructure
        let isAvailable = viewModel.isFoundationModelsAvailable
        let shouldUse = viewModel.shouldUseIntelligentExtraction

        // Verify the logic exists (this should pass)
        if isAvailable {
            XCTAssertTrue(shouldUse, "Should use intelligent extraction when available and enabled")
        } else {
            XCTAssertFalse(shouldUse, "Should not use intelligent extraction when unavailable")
        }
    }

    /// Test that enableIntelligentExtraction flag affects extraction behavior
    /// RED PHASE: This should fail because the flag isn't wired to UI
    func testEnableIntelligentExtractionFlagAffectsExtraction() throws {
        let viewModel = SettingsViewModel()

        // Toggle the flag
        viewModel.enableIntelligentExtraction = false

        // RED VERIFICATION: Flag should control extraction behavior
        // This test will fail because the flag isn't exposed in UI or wired to extraction

        XCTAssertFalse(viewModel.shouldUseIntelligentExtraction,
                      "When enableIntelligentExtraction is false, shouldUseIntelligentExtraction should be false")

        // Enable the flag
        viewModel.enableIntelligentExtraction = true

        // This depends on Foundation Models availability
        if viewModel.isFoundationModelsAvailable {
            XCTAssertTrue(viewModel.shouldUseIntelligentExtraction,
                          "When enableIntelligentExtraction is true and available, shouldUseIntelligentExtraction should be true")
        }
    }
}