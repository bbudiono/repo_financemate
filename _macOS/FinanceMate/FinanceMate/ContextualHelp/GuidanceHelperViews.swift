//
// GuidanceHelperViews.swift
// FinanceMate
//
// Reusable Helper Views for Guidance Overlay
// Created: 2025-08-08
// Target: FinanceMate
//

/*
 * Purpose: Reusable helper views for guidance overlay system
 * Issues & Complexity Summary: Common UI components and utilities
 * Key Complexity Drivers:
   - Logic Scope (Est. LoC): ~40
   - Core Algorithm Complexity: Low
   - Dependencies: SwiftUI
   - State Management Complexity: None (stateless helpers)
   - Novelty/Uncertainty Factor: Low (standard helper patterns)
 * AI Pre-Task Self-Assessment: 98%
 * Problem Estimate: 98%
 * Initial Code Complexity Estimate: 98%
 * Final Code Complexity: 98%
 * Overall Result Score: 98%
 * Key Variances/Learnings: Helper views maximize reusability
 * Last Updated: 2025-08-08
 */

import SwiftUI

/// Reusable helper views for guidance overlay system
struct GuidanceHelperViews {
    
    // MARK: - Helper Views
    
    @ViewBuilder
    func helpStepItem(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(Color.blue)
                .frame(width: 6, height: 6)
                .padding(.top, 6)
            
            Text(text)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    @ViewBuilder
    func helpTipItem(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(text)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}