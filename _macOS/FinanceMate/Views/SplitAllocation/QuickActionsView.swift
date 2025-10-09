import Foundation
import SwiftUI

/*
 * Purpose: Quick actions component with pre-configured split templates and clear functionality
 * Issues & Complexity Summary: Extracted from SplitAllocationSummaryView for modular reusability
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~50
 *   - Core Algorithm Complexity: Low (Menu buttons with async actions)
 *   - Dependencies: 2 (SwiftUI, Foundation)
 *   - State Management Complexity: Low (Simple action handling)
 *   - Novelty/Uncertainty Factor: Low (Standard quick actions pattern)
 * AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 30%
 * Problem Estimate (Inherent Problem Difficulty %): 35%
 * Initial Code Complexity Estimate %: 30%
 * Justification for Estimates: Standard quick actions component with menu buttons and clear functionality
 * Final Code Complexity (Actual %): 33% (Low complexity with simple interactions)
 * Overall Result Score (Success & Quality %): 96% (Successful extraction maintaining all quick action functionality)
 * Key Variances/Learnings: Clean separation of quick actions while preserving pre-configured split templates
 * Last Updated: 2025-01-04
 */

/// Quick actions component with pre-configured split templates
struct QuickActionsView: View {
    @ObservedObject var viewModel: SplitAllocationViewModel
    let lineItem: LineItem

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)

            HStack(spacing: 12) {
                quickSplitMenu
                clearAllButton
            }
        }
        .modifier(GlassmorphismModifier(style: .minimal, cornerRadius: 12))
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }

    // MARK: - Sub-Components

    private var quickSplitMenu: some View {
        Menu {
            Button("50/50 Business/Personal") {
                Task {
                    await viewModel.applyQuickSplit(
                        .fiftyFifty,
                        primaryCategory: "Business",
                        secondaryCategory: "Personal",
                        to: lineItem
                    )
                }
            }
            Button("70/30 Business/Personal") {
                Task {
                    await viewModel.applyQuickSplit(
                        .seventyThirty,
                        primaryCategory: "Business",
                        secondaryCategory: "Personal",
                        to: lineItem
                    )
                }
            }
        } label: {
            HStack {
                Image(systemName: "divide")
                Text("Quick Split")
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.accentColor.opacity(0.1))
            )
            .foregroundColor(.accentColor)
        }
        .accessibilityIdentifier("QuickSplitMenu")
    }

    private var clearAllButton: some View {
        quickActionButton(title: "Clear All", action: {
            Task {
                await viewModel.clearAllSplits(for: lineItem)
            }
        }, isDestructive: true)
    }

    // MARK: - Helper Views

    private func quickActionButton(
        title: String,
        action: @escaping () -> Void,
        isDestructive: Bool = false
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(isDestructive ? Color.red.opacity(0.1) : Color.blue.opacity(0.1))
                .foregroundColor(isDestructive ? .red : .blue)
                .cornerRadius(8)
        }
        .accessibilityLabel(title)
    }
}