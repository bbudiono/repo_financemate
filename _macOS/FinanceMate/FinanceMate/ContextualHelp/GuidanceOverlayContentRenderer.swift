//
// GuidanceOverlayContentRenderer.swift
// FinanceMate
//
// MODULAR Content Rendering Coordinator for Guidance Overlay
// Created: 2025-08-08
// Target: FinanceMate
//

/*
 * Purpose: MODULAR content rendering coordinator for guidance overlay system
 * Issues & Complexity Summary: Lightweight coordinator delegating to modular components
 * Key Complexity Drivers:
   - Logic Scope (Est. LoC): ~60
   - Core Algorithm Complexity: Low (delegation pattern)
   - Dependencies: SwiftUI, Modular Components
   - State Management Complexity: Low (coordination only)
   - Novelty/Uncertainty Factor: Low (standard delegation patterns)
 * AI Pre-Task Self-Assessment: 96%
 * Problem Estimate: 96%
 * Initial Code Complexity Estimate: 96%
 * Final Code Complexity: 96%
 * Overall Result Score: 96%
 * Key Variances/Learnings: MODULAR architecture dramatically improves maintainability
 * Last Updated: 2025-08-08
 */

import SwiftUI

/// MODULAR content rendering coordinator for guidance overlay system
/// Delegates to focused modular components for improved maintainability
struct GuidanceOverlayContentRenderer {
    
    // MARK: - Properties
    
    let helpContent: HelpContent?
    let expandedHelpContent: HelpContent?
    let presentationStyle: OverlayPresentationStyle
    let isShowingExpandedHelp: Bool
    
    // MARK: - Computed Properties
    
    var hasTitle: Bool { helpContent?.title != nil }
    var hasDescription: Bool { helpContent?.description != nil }
    var hasVideoContent: Bool { helpContent?.hasMultimediaContent ?? false }
    var hasInteractiveDemo: Bool { !(helpContent?.interactiveDemos.isEmpty ?? true) }
    
    // MARK: - MODULAR Content Rendering
    
    @ViewBuilder
    func headerSection() -> some View {
        GuidanceContentRenderer(
            helpContent: helpContent,
            expandedHelpContent: expandedHelpContent,
            presentationStyle: presentationStyle,
            isShowingExpandedHelp: isShowingExpandedHelp
        ).headerSection()
    }
    
    @ViewBuilder
    func contentSection() -> some View {
        GuidanceContentRenderer(
            helpContent: helpContent,
            expandedHelpContent: expandedHelpContent,
            presentationStyle: presentationStyle,
            isShowingExpandedHelp: isShowingExpandedHelp
        ).contentSection()
    }
}