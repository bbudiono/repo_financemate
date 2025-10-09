import Foundation
import SwiftUI

/*
 * Purpose: Interactive pie chart component with animations and tap gestures
 * Issues & Complexity Summary: Extracted from SplitAllocationPieChartView for modular reusability
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~60
 *   - Core Algorithm Complexity: Medium (Animation coordination, gesture handling, angle calculations)
 *   - Dependencies: 2 (SwiftUI, PieSliceShape)
 *   - State Management Complexity: Medium (Animation state, selection tracking)
 *   - Novelty/Uncertainty Factor: Medium (Interactive chart with complex animations)
 * AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 55%
 * Problem Estimate (Inherent Problem Difficulty %): 60%
 * Initial Code Complexity Estimate %: 55%
 * Justification for Estimates: Interactive pie chart with animations requires careful state and animation handling
 * Final Code Complexity (Actual %): 58% (Medium complexity with animation coordination)
 * Overall Result Score (Success & Quality %): 95% (Successful extraction maintaining all interactions and animations)
 * Key Variances/Learnings: Clean separation of interactive chart logic while preserving complex animations
 * Last Updated: 2025-01-04
 */

/// Interactive pie chart component with animations and tap gestures
struct InteractivePieChart: View {
    let splitAllocations: [SplitAllocation]
    let totalPercentage: Double
    let formatPercentage: (Double) -> String
    @Binding var selectedSplitID: UUID?
    @State private var animateChart = false

    private let pieChartColors: [Color] = [
        .blue, .green, .orange, .purple, .red, .pink,
        .yellow, .indigo, .teal, .mint, .cyan, .brown,
    ]

    var body: some View {
        ZStack {
            ForEach(Array(splitAllocations.enumerated()), id: \.element.id) { index, split in
                PieSlice(
                    startAngle: startAngle(for: index),
                    endAngle: endAngle(for: index),
                    color: pieChartColors[index % pieChartColors.count]
                )
                .scaleEffect(animateChart ? 1.0 : 0.0)
                .animation(.easeInOut(duration: 0.8).delay(Double(index) * 0.1), value: animateChart)
                .accessibilityLabel("\(split.taxCategory): \(String(format: "%.1f", split.percentage)) percent")
                .accessibilityHint("Tap to select this tax category split")
                .accessibilityAddTraits(.isButton)
                .onTapGesture {
                    selectedSplitID = split.id
                }
            }

            // Center text
            centerTextOverlay
        }
        .frame(width: 160, height: 160)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Pie chart showing \(splitAllocations.count) tax category splits totaling \(String(format: "%.1f", totalPercentage)) percent")
        .accessibilityHint("Interactive pie chart - tap segments to select tax categories")
        .accessibilityAction(.activate) {
            // VoiceOver double-tap action - select first split
            if let firstSplit = splitAllocations.first {
                selectedSplitID = firstSplit.id
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0)) {
                animateChart = true
            }
        }
    }

    // MARK: - Sub-Components

    private var centerTextOverlay: some View {
        VStack {
            Text(formatPercentage(totalPercentage))
                .font(.headline.weight(.bold))
                .foregroundColor(.primary)
                .accessibilityLabel("\(formatPercentage(totalPercentage)) percent allocated")

            Text("allocated")
                .font(.caption)
                .foregroundColor(.secondary)
                .accessibilityAddTraits(.isStaticText)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Total allocated: \(formatPercentage(totalPercentage)) percent")
        .accessibilityAddTraits(.isSummaryElement)
    }

    // MARK: - Helper Methods

    private func startAngle(for index: Int) -> Double {
        let total = totalPercentage
        guard total > 0 else { return 0 }

        let previousPercentages = splitAllocations.prefix(index).reduce(0.0) { $0 + $1.percentage }
        return (previousPercentages / total) * 360 - 90
    }

    private func endAngle(for index: Int) -> Double {
        let total = totalPercentage
        guard total > 0 else { return 0 }

        let upToCurrentPercentages = splitAllocations.prefix(index + 1).reduce(0.0) { $0 + $1.percentage }
        return (upToCurrentPercentages / total) * 360 - 90
    }
}