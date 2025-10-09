import Foundation
import SwiftUI

/*
 * Purpose: State management component for split allocation UI state
 * Issues & Complexity Summary: Manages published properties and UI state transitions
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~50
 *   - Core Algorithm Complexity: Low (State management)
 *   - Dependencies: Foundation, SwiftUI
 *   - State Management Complexity: Medium (Published properties)
 *   - Novelty/Uncertainty Factor: Low (Standard ObservableObject pattern)
 * AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 20%
 * Problem Estimate (Inherent Problem Difficulty %): 25%
 * Initial Code Complexity Estimate %: 20%
 * Justification for Estimates: Simple state management with published properties
 * Final Code Complexity (Actual %): TBD
 * Overall Result Score (Success & Quality %): TBD
 * Key Variances/Learnings: TBD
 * Last Updated: 2025-10-04
 */

/// State manager for split allocation UI properties
final class SplitAllocationStateManager: ObservableObject {

    // MARK: - Published Properties

    @Published var splitAllocations: [SplitAllocation] = []
    @Published var newSplitPercentage = 0.0
    @Published var selectedTaxCategory = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var customCategories: [String] = []

    // MARK: - State Management Methods

    /// Sets loading state and clears error
    func setLoading(_ loading: Bool) {
        isLoading = loading
        if loading {
            errorMessage = nil
        }
    }

    /// Sets error message and clears loading state
    func setError(_ message: String) {
        errorMessage = message
        isLoading = false
    }

    /// Clears error message
    func clearError() {
        errorMessage = nil
    }

    /// Resets form fields for new split allocation
    func resetForm() {
        newSplitPercentage = 0.0
        clearError()
    }

    /// Updates split allocations and clears loading state
    func updateSplitAllocations(_ allocations: [SplitAllocation]) {
        splitAllocations = allocations
        isLoading = false
    }

    /// Updates custom categories
    func updateCustomCategories(_ categories: [String]) {
        customCategories = categories
    }

    /// Sets selected tax category
    func setSelectedTaxCategory(_ category: String) {
        selectedTaxCategory = category
    }
}