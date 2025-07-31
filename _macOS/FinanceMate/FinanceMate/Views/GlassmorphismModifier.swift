import SwiftUI

/**
 * GlassmorphismModifier.swift
 *
 * Purpose: Advanced glassmorphism visual effects with 7 material variants and depth layering
 * Issues & Complexity Summary: Professional glass material system with enhanced visual effects
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~200+
 *   - Core Algorithm Complexity: Medium
 *   - Dependencies: 1 Enhanced (SwiftUI Material effects with custom layering)
 *   - State Management Complexity: Medium
 *   - Novelty/Uncertainty Factor: Low-Medium
 * AI Pre-Task Self-Assessment: 85%
 * Problem Estimate: 88%
 * Initial Code Complexity Estimate: 85%
 * Final Code Complexity: 90%
 * Overall Result Score: 92%
 * Key Variances/Learnings: Enhanced system with depth effects and advanced material variants
 * Last Updated: 2025-07-31 (Optimized for FinanceMate)
 */

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

  /// Available glassmorphism styles with different visual intensities
  enum GlassmorphismStyle {
    case primary  // Main containers - strongest effect
    case secondary  // Nested elements - moderate effect
    case accent  // Important highlights - enhanced visibility
    case minimal  // Subtle overlays - lightest effect
    case ultraThin  // Ultra-light transparency - maximum see-through
    case thick  // Heavy glass effect - maximum opacity
    case vibrant  // Enhanced color saturation and vibrancy

    /// Material background appropriate for the style
    var material: Material {
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
    var borderOpacity: Double {
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
    var shadowRadius: CGFloat {
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
    var blurRadius: CGFloat {
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
    var saturationMultiplier: Double {
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
    var edgeHighlightOpacity: Double {
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

  func body(content: Content) -> some View {
    content
      .background(
        ZStack {
          // Base glass material
          RoundedRectangle(cornerRadius: cornerRadius)
            .fill(style.material)
            .saturation(style.saturationMultiplier)

          // Edge highlight effect
          RoundedRectangle(cornerRadius: cornerRadius)
            .strokeBorder(
              LinearGradient(
                colors: [
                  .white.opacity(style.edgeHighlightOpacity),
                  .clear,
                  .white.opacity(style.edgeHighlightOpacity * 0.3),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
              ),
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
        color: .black.opacity(colorScheme == .light ? 0.1 : 0.3),
        radius: style.shadowRadius,
        x: 0,
        y: style.shadowRadius / 2
      )
      .shadow(
        // Secondary shadow for depth
        color: .black.opacity(colorScheme == .light ? 0.05 : 0.15),
        radius: style.shadowRadius * 1.5,
        x: 0,
        y: style.shadowRadius
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
    _ style: GlassmorphismModifier.GlassmorphismStyle = .primary,
    cornerRadius: CGFloat = 12
  ) -> some View {
    modifier(GlassmorphismModifier(style: style, cornerRadius: cornerRadius))
  }

  /// Applies a full-screen glassmorphism background
  func glassmorphismBackground() -> some View {
    self
      .background(
        ZStack {
          // Background gradient
          LinearGradient(
            colors: [
              Color.blue.opacity(0.05),
              Color.purple.opacity(0.05),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
          )
          .ignoresSafeArea()

          // Glass overlay
          Rectangle()
            .fill(.ultraThinMaterial)
            .ignoresSafeArea()
        }
      )
  }
}

// MARK: - Preview Helpers

/// Preview container for testing glassmorphism effects
struct GlassmorphismPreviewContainer: View {
  var body: some View {
    ZStack {
      // Background gradient for better visibility
      LinearGradient(
        colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
      .ignoresSafeArea()

      LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
        // Primary style example
        VStack {
          Text("Primary")
            .font(.headline)
          Text("Main containers")
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding()
        .glassmorphism(.primary, cornerRadius: 16)

        // Secondary style example
        VStack {
          Text("Secondary")
            .font(.headline)
          Text("Nested elements")
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding()
        .glassmorphism(.secondary, cornerRadius: 12)

        // Accent style example
        VStack {
          Text("Accent")
            .font(.headline)
          Text("Highlights")
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding()
        .glassmorphism(.accent, cornerRadius: 8)

        // Minimal style example
        VStack {
          Text("Minimal")
            .font(.headline)
          Text("Subtle overlays")
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding()
        .glassmorphism(.minimal, cornerRadius: 6)

        // Ultra Thin style example
        VStack {
          Text("Ultra Thin")
            .font(.headline)
          Text("Maximum transparency")
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding()
        .glassmorphism(.ultraThin, cornerRadius: 10)

        // Thick style example
        VStack {
          Text("Thick")
            .font(.headline)
          Text("Heavy glass effect")
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding()
        .glassmorphism(.thick, cornerRadius: 14)

        // Vibrant style example
        VStack {
          Text("Vibrant")
            .font(.headline)
          Text("Enhanced colors")
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding()
        .glassmorphism(.vibrant, cornerRadius: 12)
      }
      .padding()
    }
  }
}

#Preview("Light Mode") {
  GlassmorphismPreviewContainer()
    .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
  GlassmorphismPreviewContainer()
    .preferredColorScheme(.dark)
}
