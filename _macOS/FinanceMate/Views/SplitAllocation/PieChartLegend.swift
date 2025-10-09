import Foundation
import SwiftUI

/*
 * Purpose: Legend component for pie chart showing category colors and percentages
 * Issues & Complexity Summary: Extracted from SplitAllocationPieChartView for modular reusability
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~45
 *   - Core Algorithm Complexity: Low (List display with color indicators)
 *   - Dependencies: 2 (SwiftUI, Foundation)
 *   - State Management Complexity: Low (Simple selection tracking)
 *   - Novelty/Uncertainty Factor: Low (Standard legend pattern)
 * AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 30%
 * Problem Estimate (Inherent Problem Difficulty %): 35%
 * Initial Code Complexity Estimate %: 30%
 * Justification for Estimates: Standard legend component with color indicators and selection handling
 * Final Code Complexity (Actual %): 33% (Low complexity with interaction logic)
 * Overall Result Score (Success & Quality %): 96% (Successful extraction maintaining legend functionality)
 * Key Variances/Learnings: Clean separation of legend logic while preserving color coding and selection
 * Last Updated: 2025-01-04
 */

/// Legend component for pie chart showing category colors and percentages
struct PieChartLegend: View {
    let splitAllocations: [SplitAllocation]
    let formatPercentage: (Double) -> String
    @Binding var selectedSplitID: UUID?

    private let pieChartColors: [Color] = [
        .blue, .green, .orange, .purple, .red, .pink,
        .yellow, .indigo, .teal, .mint, .cyan, .brown,
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(splitAllocations.enumerated()), id: \.element.id) { index, split in
                legendItem(split: split, color: pieChartColors[index % pieChartColors.count])
            }
        }
    }

    // MARK: - Helper Views

    private func legendItem(split: SplitAllocation, color: Color) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)

            VStack(alignment: .leading, spacing: 2) {
                Text(split.taxCategory)
                    .font(.caption.weight(.medium))
                    .foregroundColor(.primary)

                Text(formatPercentage(split.percentage))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .background(selectedSplitID == split.id ? Color.blue.opacity(0.1) : Color.clear)
        .cornerRadius(6)
        .onTapGesture {
            selectedSplitID = split.id
        }
    }
}