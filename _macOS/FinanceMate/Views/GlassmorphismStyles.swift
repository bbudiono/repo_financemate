// SANDBOX FILE: For testing/development. See .cursorrules.
//
// GlassmorphismStyles.swift
// FinanceMate Sandbox
//
// Purpose: Glassmorphism style configurations and material definitions
// Issues & Complexity Summary: Style definitions extracted for modular architecture
// Key Complexity Drivers:
//   - Logic Scope (Est. LoC): ~80
//   - Core Algorithm Complexity: Low
//   - Dependencies: 1 Standard (SwiftUI Material effects)
//   - State Management Complexity: Low
//   - Novelty/Uncertainty Factor: Low
// AI Pre-Task Self-Assessment: 90%
// Problem Estimate: 92%
// Initial Code Complexity Estimate: 80%
// Final Code Complexity: 85%
// Overall Result Score: 95%
// Key Variances/Learnings: Modular style system for better maintainability
// Last Updated: 2025-08-22 (Modular refactoring for KISS compliance)

import SwiftUI

/// Glassmorphism style configurations with different visual intensities
///
/// This enum defines 7 distinct glassmorphism styles, each with carefully calibrated
/// visual properties for different UI contexts and hierarchy levels.
public enum GlassmorphismStyle {
    case primary    // Main containers - strongest effect
    case secondary  // Nested elements - moderate effect
    case accent     // Important highlights - enhanced visibility
    case minimal    // Subtle overlays - lightest effect
    case ultraThin  // Ultra-light transparency - maximum see-through
    case thick      // Heavy glass effect - maximum opacity
    case vibrant    // Enhanced color saturation and vibrancy

    /// Material background appropriate for the style
    public var material: Material {
        switch self {
        case .primary:
            return .ultraThinMaterial
        case .secondary:
            return .thinMaterial
        case .accent:
            return .ultraThinMaterial
        case .minimal:
            return .regularMaterial
        case .ultraThin:
            return .ultraThinMaterial
        case .thick:
            return .thickMaterial
        case .vibrant:
            return .ultraThinMaterial
        }
    }

    /// Border opacity based on style
    public var borderOpacity: Double {
        switch self {
        case .primary: return 0.25
        case .secondary: return 0.2
        case .accent: return 0.3
        case .minimal: return 0.15
        case .ultraThin: return 0.1
        case .thick: return 0.4
        case .vibrant: return 0.35
        }
    }

    /// Shadow radius for the style
    public var shadowRadius: CGFloat {
        switch self {
        case .primary: return 10
        case .secondary: return 8
        case .accent: return 12
        case .minimal: return 6
        case .ultraThin: return 4
        case .thick: return 16
        case .vibrant: return 14
        }
    }

    /// Dynamic blur radius for enhanced effects
    public var blurRadius: CGFloat {
        switch self {
        case .primary: return 8
        case .secondary: return 6
        case .accent: return 10
        case .minimal: return 4
        case .ultraThin: return 2
        case .thick: return 20
        case .vibrant: return 12
        }
    }

    /// Saturation multiplier for color effects
    public var saturationMultiplier: Double {
        switch self {
        case .primary: return 1.0
        case .secondary: return 0.9
        case .accent: return 1.3
        case .minimal: return 0.8
        case .ultraThin: return 0.7
        case .thick: return 1.1
        case .vibrant: return 2.0
        }
    }

    /// Edge highlight intensity
    public var edgeHighlightOpacity: Double {
        switch self {
        case .primary: return 0.1
        case .secondary: return 0.08
        case .accent: return 0.15
        case .minimal: return 0.05
        case .ultraThin: return 0.03
        case .thick: return 0.2
        case .vibrant: return 0.18
        }
    }
}

/// Style configuration utilities for glassmorphism effects
public struct GlassmorphismStyleConfigurations {

    /// Creates gradient for edge highlights based on style
    public static func edgeHighlightGradient(for style: GlassmorphismStyle) -> LinearGradient {
        LinearGradient(
            colors: [
                .white.opacity(style.edgeHighlightOpacity),
                .clear,
                .white.opacity(style.edgeHighlightOpacity * 0.3)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Calculates shadow colors based on color scheme and style
    public static func shadowColors(
        for style: GlassmorphismStyle,
        colorScheme: ColorScheme
    ) -> (primary: Color, secondary: Color) {
        let isLight = colorScheme == .light

        let primaryShadow = Color.black.opacity(isLight ? 0.1 : 0.3)
        let secondaryShadow = Color.black.opacity(isLight ? 0.05 : 0.15)

        return (primary: primaryShadow, secondary: secondaryShadow)
    }

    /// Calculates shadow offsets based on style
    public static func shadowOffsets(for style: GlassmorphismStyle) -> (primary: CGSize, secondary: CGSize) {
        let primaryOffset = CGSize(width: 0, height: style.shadowRadius / 2)
        let secondaryOffset = CGSize(width: 0, height: style.shadowRadius)

        return (primary: primaryOffset, secondary: secondaryOffset)
    }
}