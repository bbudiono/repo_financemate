//
// AssetBreakdownEmptyStateView.swift
// FinanceMate
//
// Purpose: Modular empty state component for when no assets are available
// Issues & Complexity Summary: Simple empty state UI with glassmorphism styling
// Key Complexity Drivers:
//   - Logic Scope (Est. LoC): ~35
//   - Core Algorithm Complexity: Low (static empty state UI)
//   - Dependencies: 2 (SwiftUI, GlassmorphismModifier)
//   - State Management Complexity: None (stateless component)
//   - Novelty/Uncertainty Factor: None
// AI Pre-Task Self-Assessment: 95%
// Problem Estimate: 95%
// Initial Code Complexity Estimate: 95%
// Final Code Complexity: 98%
// Overall Result Score: 98%
// Key Variances/Learnings: Simple, focused empty state component with accessibility
// Last Updated: 2025-08-05

import SwiftUI

/// Empty state view for when no assets are available to display
///
/// This component provides:
/// - Empty state icon and messaging
/// - Helpful guidance text for users
/// - Accessibility support with proper labeling
/// - Glassmorphism-styled container
struct AssetBreakdownEmptyStateView: View {
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.pie")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("No Assets Found")
                .font(.title2)
                .fontWeight(.medium)
            Text("Add some assets to see your breakdown")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(40)
        .modifier(GlassmorphismModifier(style: .minimal, cornerRadius: 12))
        .accessibilityLabel("No assets available to display")
    }
}

// MARK: - Preview
struct AssetBreakdownEmptyStateView_Previews: PreviewProvider {
    static var previews: some View {
        AssetBreakdownEmptyStateView()
            .frame(width: 300, height: 200)
            .background(Color.gray.opacity(0.1))
    }
}