import Foundation
import SwiftUI

/*
 * Purpose: Header component for SplitAllocationView containing title, validation status, and error messages
 * Issues & Complexity Summary: Simple header layout with validation indicators and error handling
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~70
 *   - Core Algorithm Complexity: Low (Simple layout and conditional display logic)
 *   - Dependencies: 2 (SwiftUI, Foundation, SplitAllocationViewModel, GlassmorphismModifier)
 *   - State Management Complexity: Low (No local state, just display logic)
 *   - Novelty/Uncertainty Factor: Low (Standard header pattern)
 * AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 30%
 * Problem Estimate (Inherent Problem Difficulty %): 25%
 * Initial Code Complexity Estimate %: 25%
 * Justification for Estimates: Simple header component with validation display and error handling
 * Final Code Complexity (Actual %): 28% (Low complexity as expected)
 * Overall Result Score (Success & Quality %): 95% (Clean implementation meeting requirements)
 * Key Variances/Learnings: Successfully extracted header logic while maintaining accessibility and validation display
 * Last Updated: 2025-01-04
 */

/// Header view for split allocation modal showing title, validation status, and error messages
struct SplitAllocationHeaderView: View {
    @ObservedObject var viewModel: SplitAllocationViewModel
    let lineItem: LineItem

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title and loading indicator
            titleSection

            // Validation status
            validationStatusSection

            // Error message (if any)
            errorMessageSection
        }
        .modifier(GlassmorphismModifier(style: .primary, cornerRadius: 16))
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
    }

    // MARK: - Title Section

    private var titleSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Split Allocation")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Text("\(lineItem.itemDescription) - \(viewModel.formatCurrency(lineItem.amount))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(0.8)
                    .accessibilityLabel("Loading split allocations")
            }
        }
    }

    // MARK: - Validation Status Section

    private var validationStatusSection: some View {
        HStack {
            Circle()
                .fill(viewModel.isValidSplit ? Color.green : Color.orange)
                .frame(width: 8, height: 8)

            Text(validationStatusText)
                .font(.caption)
                .foregroundColor(viewModel.isValidSplit ? .green : .orange)

            Spacer()

            Text(viewModel.formatPercentage(viewModel.totalPercentage))
                .font(.caption.weight(.semibold))
                .foregroundColor(viewModel.isValidSplit ? .green : .orange)
        }
    }

    // MARK: - Error Message Section

    private var errorMessageSection: some View {
        Group {
            if let errorMessage = viewModel.errorMessage {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)

                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                }
                .accessibilityLabel("Error: \(errorMessage)")
            }
        }
    }

    // MARK: - Computed Properties

    private var validationStatusText: String {
        if viewModel.splitAllocations.isEmpty {
            return "No splits allocated"
        } else if viewModel.isValidSplit {
            return "Splits are balanced"
        } else if viewModel.totalPercentage > 100 {
            return "Over-allocated"
        } else {
            return "Under-allocated"
        }
    }
}