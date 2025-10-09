import Foundation
import SwiftUI

/*
 * Purpose: Validation summary component displaying split allocation metrics and totals
 * Issues & Complexity Summary: Extracted from SplitAllocationSummaryView for modular reusability
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~50
 *   - Core Algorithm Complexity: Low (Display calculations and formatting)
 *   - Dependencies: 2 (SwiftUI, Foundation)
 *   - State Management Complexity: Low (Simple display component)
 *   - Novelty/Uncertainty Factor: Low (Standard summary display pattern)
 * AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 25%
 * Problem Estimate (Inherent Problem Difficulty %): 30%
 * Initial Code Complexity Estimate %: 25%
 * Justification for Estimates: Standard summary display component with calculations and color coding
 * Final Code Complexity (Actual %): 28% (Low complexity with display logic)
 * Overall Result Score (Success & Quality %): 97% (Successful extraction maintaining validation display)
 * Key Variances/Learnings: Clean separation of validation logic while preserving color coding and formatting
 * Last Updated: 2025-01-04
 */

/// Validation summary component displaying split allocation metrics
struct ValidationSummaryView: View {
    @ObservedObject var viewModel: SplitAllocationViewModel
    let lineItem: LineItem

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Summary")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)

            VStack(spacing: 8) {
                summaryRow(
                    label: "Total Allocated",
                    value: viewModel.formatPercentage(viewModel.totalPercentage),
                    isHighlighted: !viewModel.isValidSplit
                )

                summaryRow(
                    label: "Remaining",
                    value: viewModel.formatPercentage(viewModel.remainingPercentage),
                    isRemaining: true
                )

                summaryRow(
                    label: "Line Item Amount",
                    value: viewModel.formatCurrency(lineItem.amount),
                    isTotal: true
                )
            }
        }
        .modifier(GlassmorphismModifier(style: .secondary, cornerRadius: 16))
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
    }

    // MARK: - Helper Views

    private func summaryRow(
        label: String,
        value: String,
        isTotal: Bool = false,
        isHighlighted: Bool = false,
        isRemaining: Bool = false
    ) -> some View {
        HStack {
            Text(label)
                .font(isTotal ? .subheadline.weight(.semibold) : .subheadline)
                .foregroundColor(.primary)

            Spacer()

            Text(value)
                .font(isTotal ? .subheadline.weight(.bold) : .subheadline)
                .foregroundColor(
                    isHighlighted ? .orange :
                        isRemaining ? (viewModel.remainingPercentage < 0 ? .red : .green) :
                        .primary
                )
        }
        .padding(.vertical, 4)
    }
}