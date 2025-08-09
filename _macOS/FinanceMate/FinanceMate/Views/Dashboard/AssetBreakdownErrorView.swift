//
// AssetBreakdownErrorView.swift
// FinanceMate
//
// Purpose: Modular error state component for asset breakdown display
// Issues & Complexity Summary: Error UI with retry functionality and glassmorphism styling
// Key Complexity Drivers:
//   - Logic Scope (Est. LoC): ~40
//   - Core Algorithm Complexity: Low (error display with retry)
//   - Dependencies: 2 (SwiftUI, GlassmorphismModifier)
//   - State Management Complexity: Low (callback-based retry)
//   - Novelty/Uncertainty Factor: None
// AI Pre-Task Self-Assessment: 95%
// Problem Estimate: 95%
// Initial Code Complexity Estimate: 95%
// Final Code Complexity: 97%
// Overall Result Score: 97%
// Key Variances/Learnings: Simple, focused error component with retry callback
// Last Updated: 2025-08-05

import SwiftUI

/// Error state view for asset breakdown with retry functionality
///
/// This component provides:
/// - Error icon and message display
/// - Retry button with callback
/// - Accessibility support with proper labeling
/// - Glassmorphism-styled container
struct AssetBreakdownErrorView: View {
    
    let message: String
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.title2)
                .foregroundColor(.orange)
            Text("Error loading assets")
                .font(.headline)
                .fontWeight(.medium)
            Text(message)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Button("Retry") {
                onRetry()
            }
            .buttonStyle(.bordered)
            .accessibilityLabel("Retry loading asset data")
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(24)
        .modifier(GlassmorphismModifier(style: .accent, cornerRadius: 16))
    }
}

// MARK: - Preview
struct AssetBreakdownErrorView_Previews: PreviewProvider {
    static var previews: some View {
        AssetBreakdownErrorView(
            message: "Unable to load asset data. Please check your connection.",
            onRetry: { print("Retry tapped") }
        )
        .frame(width: 300, height: 200)
        .background(Color.gray.opacity(0.1))
    }
}