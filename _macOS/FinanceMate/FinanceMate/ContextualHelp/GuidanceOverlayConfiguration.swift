//
// GuidanceOverlayConfiguration.swift
// FinanceMate
//
// Guidance Overlay Configuration and Layout Management
// Created: 2025-08-03
// Target: FinanceMate
//

/*
 * Purpose: Configuration and layout logic for guidance overlay system
 * Issues & Complexity Summary: Layout calculations, responsive design, configuration management
 * Key Complexity Drivers:
   - Logic Scope (Est. LoC): ~80
   - Core Algorithm Complexity: Low-Medium
   - Dependencies: SwiftUI, Foundation
   - State Management Complexity: Medium (configuration state)
   - Novelty/Uncertainty Factor: Low (standard SwiftUI patterns)
 * AI Pre-Task Self-Assessment: 90%
 * Problem Estimate: 90%
 * Initial Code Complexity Estimate: 90%
 * Final Code Complexity: 90%
 * Overall Result Score: 90%
 * Key Variances/Learnings: Layout logic straightforward with clear patterns
 * Last Updated: 2025-08-03
 */

import SwiftUI
import os.log

/// Configuration and layout management for guidance overlay
final class GuidanceOverlayConfiguration: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var presentationStyle: OverlayPresentationStyle = .detailed
    @Published var layoutMode: OverlayLayoutMode = .modal
    @Published var screenSize: ScreenSize = .medium
    @Published var isAccessibilityModeEnabled: Bool = false
    @Published var isVoiceOverModeEnabled: Bool = false
    @Published var isKeyboardNavigationEnabled: Bool = false
    @Published var isFullScreen: Bool = false
    @Published var isCompactPresentation: Bool = false
    
    // MARK: - Private Properties
    
    private let logger = Logger(subsystem: "com.financemate.ui", category: "GuidanceOverlayConfiguration")
    
    // MARK: - Computed Properties
    
    var overlayMaxWidth: CGFloat {
        switch layoutMode {
        case .modal:
            return screenSize == .small ? 300 : 400
        case .sidebar:
            return 350
        case .tooltip:
            return 250
        case .banner:
            return .infinity
        }
    }
    
    var overlayMaxHeight: CGFloat {
        switch layoutMode {
        case .modal:
            return 500
        case .sidebar:
            return .infinity
        case .tooltip:
            return 200
        case .banner:
            return 100
        }
    }
    
    var supportsTabNavigation: Bool { isKeyboardNavigationEnabled }
    var supportsArrowKeyNavigation: Bool { isKeyboardNavigationEnabled }
    var supportsVoiceOverNavigation: Bool { isVoiceOverModeEnabled }
    
    // MARK: - Configuration Methods
    
    func setScreenSize(_ size: ScreenSize) {
        self.screenSize = size
        updateLayoutMode()
        logger.debug("Screen size set to: \(size.rawValue)")
    }
    
    func enableAccessibilityMode(_ enabled: Bool) {
        self.isAccessibilityModeEnabled = enabled
        logger.debug("Accessibility mode \(enabled ? "enabled" : "disabled")")
    }
    
    func enableVoiceOverMode(_ enabled: Bool) {
        self.isVoiceOverModeEnabled = enabled
        logger.debug("VoiceOver mode \(enabled ? "enabled" : "disabled")")
    }
    
    func enableKeyboardNavigation(_ enabled: Bool) {
        self.isKeyboardNavigationEnabled = enabled
        logger.debug("Keyboard navigation \(enabled ? "enabled" : "disabled")")
    }
    
    func getPresentationStyle(for userLevel: UserLevel) -> OverlayPresentationStyle {
        switch userLevel {
        case .novice:
            return .detailed
        case .intermediate:
            return .detailed
        case .expert:
            return .minimal
        }
    }
    
    func updatePresentationStyle(for userLevel: UserLevel) {
        let newStyle = getPresentationStyle(for: userLevel)
        if presentationStyle != newStyle {
            presentationStyle = newStyle
            logger.debug("Presentation style updated to: \(newStyle.rawValue)")
        }
    }
    
    // MARK: - Private Methods
    
    private func updateLayoutMode() {
        let newLayoutMode: OverlayLayoutMode
        let newIsCompactPresentation: Bool
        let newIsFullScreen: Bool
        
        switch screenSize {
        case .small:
            newLayoutMode = .modal
            newIsCompactPresentation = true
            newIsFullScreen = false
        case .medium:
            newLayoutMode = .modal
            newIsCompactPresentation = false
            newIsFullScreen = false
        case .large:
            newLayoutMode = .sidebar
            newIsCompactPresentation = false
            newIsFullScreen = false
        }
        
        if layoutMode != newLayoutMode {
            layoutMode = newLayoutMode
        }
        
        if isCompactPresentation != newIsCompactPresentation {
            isCompactPresentation = newIsCompactPresentation
        }
        
        if isFullScreen != newIsFullScreen {
            isFullScreen = newIsFullScreen
        }
        
        logger.debug("Layout updated - Mode: \(newLayoutMode.rawValue), Compact: \(newIsCompactPresentation)")
    }
}