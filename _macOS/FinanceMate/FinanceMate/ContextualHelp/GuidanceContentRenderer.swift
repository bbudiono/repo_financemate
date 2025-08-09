//
// GuidanceContentRenderer.swift
// FinanceMate
//
// Core Content Rendering for Guidance Overlay
// Created: 2025-08-08
// Target: FinanceMate
//

/*
 * Purpose: Core content rendering logic for guidance overlay system
 * Issues & Complexity Summary: Main content coordination and layout
 * Key Complexity Drivers:
   - Logic Scope (Est. LoC): ~80
   - Core Algorithm Complexity: Medium
   - Dependencies: SwiftUI, ContextualHelpSystem
   - State Management Complexity: Medium (content state, presentation modes)
   - Novelty/Uncertainty Factor: Low (standard SwiftUI patterns)
 * AI Pre-Task Self-Assessment: 92%
 * Problem Estimate: 92%
 * Initial Code Complexity Estimate: 92%
 * Final Code Complexity: 92%
 * Overall Result Score: 92%
 * Key Variances/Learnings: Focused core rendering improves maintainability
 * Last Updated: 2025-08-08
 */

import SwiftUI

/// Core content rendering for guidance overlay system
struct GuidanceContentRenderer {
    
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
    
    // MARK: - Main Content Views
    
    @ViewBuilder
    func headerSection() -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                if let title = helpContent?.title {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .accessibilityAddTraits(.isHeader)
                }
                
                if presentationStyle == .detailed, let description = helpContent?.description {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
    }
    
    @ViewBuilder
    func contentSection() -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                if isShowingExpandedHelp {
                    GuidanceContentSections(
                        helpContent: helpContent,
                        expandedHelpContent: expandedHelpContent
                    ).expandedContentView()
                } else {
                    GuidanceContentSections(
                        helpContent: helpContent,
                        expandedHelpContent: expandedHelpContent
                    ).standardContentView()
                }
                
                if hasVideoContent || hasInteractiveDemo {
                    GuidanceMultimediaViews(
                        hasVideoContent: hasVideoContent,
                        hasInteractiveDemo: hasInteractiveDemo
                    ).multimediaSection()
                }
            }
        }
        .frame(maxHeight: 300)
    }
}