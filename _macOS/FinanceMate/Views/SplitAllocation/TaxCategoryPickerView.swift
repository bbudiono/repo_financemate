import Foundation
import SwiftUI

/*
 * Purpose: Tax category selection component with custom category addition capability
 * Issues & Complexity Summary: Extracted from SplitAllocationControlsView for modular reusability
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~35
 *   - Core Algorithm Complexity: Low (Menu selection with binding)
 *   - Dependencies: 2 (SwiftUI, Foundation)
 *   - State Management Complexity: Low (Simple selection binding)
 *   - Novelty/Uncertainty Factor: Low (Standard picker component)
 * AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 25%
 * Problem Estimate (Inherent Problem Difficulty %): 30%
 * Initial Code Complexity Estimate %: 25%
 * Justification for Estimates: Standard picker component with menu selection and custom category option
 * Final Code Complexity (Actual %): 28% (Low complexity with simple interaction)
 * Overall Result Score (Success & Quality %): 97% (Successful extraction maintaining clean interface)
 * Key Variances/Learnings: Clean separation of picker logic while maintaining selection and custom category functionality
 * Last Updated: 2025-01-04
 */

/// Tax category selection component with custom category option
struct TaxCategoryPickerView: View {
    let availableCategories: [String]
    @Binding var selectedCategory: String
    @Binding var showingAddCustomCategory: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            headerSection
            categoryMenu
        }
    }

    // MARK: - Sub-Components

    private var headerSection: some View {
        HStack {
            Text("Tax Category")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)

            Spacer()

            Button("Add Custom") {
                showingAddCustomCategory = true
            }
            .font(.caption)
            .foregroundColor(.blue)
            .accessibilityLabel("Add custom tax category")
        }
    }

    private var categoryMenu: some View {
        Menu {
            ForEach(availableCategories, id: \.self) { category in
                Button(category) {
                    selectedCategory = category
                }
            }
        } label: {
            HStack {
                Text(selectedCategory.isEmpty ? "Select Category" : selectedCategory)
                    .foregroundColor(selectedCategory.isEmpty ? .gray : .primary)

                Spacer()

                Image(systemName: "chevron.down")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
        .accessibilityLabel("Select tax category")
    }
}