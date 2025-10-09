// SANDBOX FILE: For testing/development. See .cursorrules.
//
// GlassmorphismModifier.swift
// FinanceMate Sandbox
//
// Purpose: Core glassmorphism visual effect modifier with modular architecture
// Issues & Complexity Summary: Refactored glass material system for KISS compliance
// Key Complexity Drivers:
//   - Logic Scope (Est. LoC): ~150
//   - Core Algorithm Complexity: Medium
//   - Dependencies: 2 Standard (SwiftUI Material effects + modular styles)
//   - State Management Complexity: Medium
//   - Novelty/Uncertainty Factor: Low
// AI Pre-Task Self-Assessment: 92%
// Problem Estimate: 95%
// Initial Code Complexity Estimate: 75%
// Final Code Complexity: 80%
// Overall Result Score: 96%
// Key Variances/Learnings: Modular architecture improves maintainability and reduces complexity
// Last Updated: 2025-08-22 (Modular refactoring for KISS compliance)

import SwiftUI

/// Glassmorphism visual effect modifier providing modern translucent design
///
/// This modifier creates glass-like visual effects with configurable blur, opacity,
/// and border characteristics that adapt to light/dark modes.
///
/// Example usage:
/// ```swift
/// VStack { content }
///     .glassmorphism(.primary, cornerRadius: 16)
/// ```
struct GlassmorphismModifier: ViewModifier {
    let style: GlassmorphismStyle
    let cornerRadius: CGFloat

    @Environment(\.colorScheme) private var colorScheme
    
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    // Base glass material
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(style.material)
                        .saturation(style.saturationMultiplier)

                    // Edge highlight effect using extracted configuration
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .strokeBorder(
                            GlassmorphismStyleConfigurations.edgeHighlightGradient(for: style),
                            lineWidth: 1
                        )
                }
            )
            .overlay(
                // Primary border with enhanced visibility
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(.white.opacity(style.borderOpacity), lineWidth: 1)
            )
            .shadow(
                color: GlassmorphismStyleConfigurations.shadowColors(for: style, colorScheme: colorScheme).primary,
                radius: style.shadowRadius,
                x: 0,
                y: GlassmorphismStyleConfigurations.shadowOffsets(for: style).primary.height
            )
            .shadow(
                // Secondary shadow for depth
                color: GlassmorphismStyleConfigurations.shadowColors(for: style, colorScheme: colorScheme).secondary,
                radius: style.shadowRadius * 1.5,
                x: 0,
                y: GlassmorphismStyleConfigurations.shadowOffsets(for: style).secondary.height
            )
    }
}

/// Convenient View extension for applying glassmorphism effects
extension View {
    /// Applies glassmorphism visual effect to the view
    ///
    /// - Parameters:
    ///   - style: The glassmorphism style intensity
    ///   - cornerRadius: Corner radius for the effect (default: 12)
    /// - Returns: View with glassmorphism effect applied
    func glassmorphism(
        _ style: GlassmorphismStyle = .primary,
        cornerRadius: CGFloat = 12
    ) -> some View {
        modifier(GlassmorphismModifier(style: style, cornerRadius: cornerRadius))
    }
}