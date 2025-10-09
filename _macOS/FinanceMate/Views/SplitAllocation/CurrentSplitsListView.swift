import Foundation
import SwiftUI

/*
 * Purpose: Current splits list component displaying all existing split allocations with interactive controls
 * Issues & Complexity Summary: Extracted from SplitAllocationControlsView for modular reusability
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~50
 *   - Core Algorithm Complexity: Low (List display with row components)
 *   - Dependencies: 3 (SwiftUI, Foundation, SplitAllocationRowView)
 *   - State Management Complexity: Low (Simple list rendering)
 *   - Novelty/Uncertainty Factor: Low (Standard list component)
 * AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 30%
 * Problem Estimate (Inherent Problem Difficulty %): 35%
 * Initial Code Complexity Estimate %: 30%
 * Justification for Estimates: Standard list component with row delegation and glassmorphism styling
 * Final Code Complexity (Actual %): 33% (Low complexity with row composition)
 * Overall Result Score (Success & Quality %): 95% (Successful extraction maintaining list functionality)
 * Key Variances/Learnings: Clean separation of list logic while preserving interactive row controls
 * Last Updated: 2025-01-04
 */

/// Current splits list component displaying existing split allocations
struct CurrentSplitsListView: View {
    @ObservedObject var viewModel: SplitAllocationViewModel
    let lineItem: LineItem
    @Binding var selectedSplitID: UUID?

    private let pieChartColors: [Color] = [
        .blue, .green, .orange, .purple, .red, .pink,
        .yellow, .indigo, .teal, .mint, .cyan, .brown,
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Current Splits")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)

            LazyVStack(spacing: 12) {
                ForEach(Array(viewModel.splitAllocations.enumerated()), id: \.element.id) { index, split in
                    SplitAllocationRowView(
                        viewModel: viewModel,
                        split: split,
                        lineItem: lineItem,
                        color: pieChartColors[index % pieChartColors.count],
                        selectedSplitID: $selectedSplitID
                    )
                }
            }
        }
        .modifier(GlassmorphismModifier(style: .secondary, cornerRadius: 16))
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
    }
}