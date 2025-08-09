//
// AssetBreakdownLoadingView.swift
// FinanceMate
//
// Purpose: Modular loading state component for asset breakdown display
// Issues & Complexity Summary: Simple loading UI with glassmorphism styling
// Key Complexity Drivers:
//   - Logic Scope (Est. LoC): ~30
//   - Core Algorithm Complexity: Low (static loading UI)
//   - Dependencies: 2 (SwiftUI, GlassmorphismModifier)
//   - State Management Complexity: None (stateless component)
//   - Novelty/Uncertainty Factor: None
// AI Pre-Task Self-Assessment: 95%
// Problem Estimate: 95%
// Initial Code Complexity Estimate: 95%
// Final Code Complexity: 98%
// Overall Result Score: 98%
// Key Variances/Learnings: Simple, focused loading component extracted from parent view
// Last Updated: 2025-08-05

import SwiftUI

/// Simple loading state view for asset breakdown with glassmorphism styling
///
/// This component provides:
/// - Animated progress indicator with accessibility support
/// - Glassmorphism-styled container
/// - Loading message with proper labeling
struct AssetBreakdownLoadingView: View {
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
                .accessibilityLabel("Loading asset data")
            Text("Loading Assets...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(40)
        .modifier(GlassmorphismModifier(style: .minimal, cornerRadius: 12))
    }
}

// MARK: - Preview
struct AssetBreakdownLoadingView_Previews: PreviewProvider {
    static var previews: some View {
        AssetBreakdownLoadingView()
            .frame(width: 300, height: 200)
            .background(Color.gray.opacity(0.1))
    }
}