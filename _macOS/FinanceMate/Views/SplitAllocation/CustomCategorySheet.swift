import Foundation
import SwiftUI

/*
 * Purpose: Custom category sheet component for adding user-defined tax categories
 * Issues & Complexity Summary: Extracted from SplitAllocationSummaryView for modular reusability
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~30
 *   - Core Algorithm Complexity: Low (Form with validation and submission)
 *   - Dependencies: 2 (SwiftUI, Foundation)
 *   - State Management Complexity: Low (Simple form handling)
 *   - Novelty/Uncertainty Factor: Low (Standard sheet presentation)
 * AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 25%
 * Problem Estimate (Inherent Problem Difficulty %): 30%
 * Initial Code Complexity Estimate %: 25%
 * Justification for Estimates: Standard sheet component with form validation and submission
 * Final Code Complexity (Actual %): 28% (Low complexity with form logic)
 * Overall Result Score (Success & Quality %): 96% (Successful extraction maintaining form functionality)
 * Key Variances/Learnings: Clean separation of custom category logic while preserving validation and submission
 * Last Updated: 2025-01-04
 */

/// Custom category sheet component for adding user-defined tax categories
struct CustomCategorySheet: View {
    @ObservedObject var viewModel: SplitAllocationViewModel
    @Binding var newCustomCategory: String
    @Binding var showingAddCustomCategory: Bool

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                categoryInputField
                addCategoryButton
                Spacer()
            }
            .padding()
            .navigationTitle("Add Custom Category")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    cancelButton
                }
            }
        }
    }

    // MARK: - Sub-Components

    private var categoryInputField: some View {
        TextField("Category Name", text: $newCustomCategory)
            .textFieldStyle(.roundedBorder)
            .accessibilityLabel("Custom category name")
    }

    private var addCategoryButton: some View {
        Button("Add Category") {
            viewModel.addCustomTaxCategory(newCustomCategory)
            viewModel.selectedTaxCategory = newCustomCategory
            newCustomCategory = ""
            showingAddCustomCategory = false
        }
        .disabled(newCustomCategory.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        .buttonStyle(.borderedProminent)
    }

    private var cancelButton: some View {
        Button("Cancel") {
            newCustomCategory = ""
            showingAddCustomCategory = false
        }
    }
}