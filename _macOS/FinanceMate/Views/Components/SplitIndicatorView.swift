import SwiftUI

/*
 * Purpose: Visual indicator component for transactions with split allocations
 * BLUEPRINT Requirements: Lines 102, 122 - Visual badges/icons for split transactions in lists
 * Issues & Complexity Summary: Simple conditional UI component with glassmorphism styling
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~40
 *   - Core Algorithm Complexity: Low (static UI rendering)
 *   - Dependencies: SwiftUI, GlassmorphismModifier
 *   - State Management Complexity: Low (no internal state)
 *   - Novelty/Uncertainty Factor: Low (standard SwiftUI patterns)
 * AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 25%
 * Problem Estimate (Inherent Problem Difficulty %): 30%
 * Initial Code Complexity Estimate %: 25%
 * Justification for Estimates: Simple SwiftUI view with existing design system integration
 * Final Code Complexity (Actual %): TBD
 * Overall Result Score (Success & Quality %): TBD
 * Key Variances/Learnings: TBD
 * Last Updated: 2025-10-06
 */

/// Visual indicator showing that a transaction has split tax allocations
/// Uses glassmorphism design system for consistent styling
struct SplitIndicatorView: View {
    let hasSplits: Bool
    let size: IndicatorSize

    enum IndicatorSize {
        case small, medium, large

        var iconFont: Font {
            switch self {
            case .small: return .caption2
            case .medium: return .caption
            case .large: return .body
            }
        }

        var textFont: Font {
            switch self {
            case .small: return .caption2
            case .medium: return .caption2
            case .large: return .caption
            }
        }

        var padding: CGFloat {
            switch self {
            case .small: return 2
            case .medium: return 4
            case .large: return 6
            }
        }
    }

    init(hasSplits: Bool, size: IndicatorSize = .medium) {
        self.hasSplits = hasSplits
        self.size = size
    }

    var body: some View {
        if hasSplits {
            HStack(spacing: 2) {
                Image(systemName: "divide.square.fill")
                    .font(size.iconFont)
                    .foregroundColor(.green)

                Text("Split")
                    .font(size.textFont)
                    .fontWeight(.medium)
                    .foregroundColor(.green)
            }
            .padding(.horizontal, size.padding)
            .padding(.vertical, size.padding / 2)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.green.opacity(0.15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.green.opacity(0.3), lineWidth: 0.5)
                    )
            )
            .accessibilityLabel("Tax split allocated")
            .accessibilityHint("This transaction has tax category splits")
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        HStack {
            Text("Small indicator:")
            SplitIndicatorView(hasSplits: true, size: .small)
        }

        HStack {
            Text("Medium indicator:")
            SplitIndicatorView(hasSplits: true, size: .medium)
        }

        HStack {
            Text("Large indicator:")
            SplitIndicatorView(hasSplits: true, size: .large)
        }

        HStack {
            Text("No splits (hidden):")
            SplitIndicatorView(hasSplits: false, size: .medium)
        }
    }
    .padding()
}