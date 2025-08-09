import CoreData
import Foundation
import SwiftUI

/*
 * Purpose: SplitAllocationViewModel for managing split allocation CRUD operations with real-time percentage validation and tax category management
 * Issues & Complexity Summary: Manages complex percentage validation, tax category system, quick split templates, and real-time validation constraints
 * Key Complexity Drivers:
   - Logic Scope (Est. LoC): ~300
   - Core Algorithm Complexity: High (Real-time percentage validation, split constraint logic)
   - Dependencies: 5 (Core Data, Foundation, SwiftUI, LineItem/SplitAllocation entities, Tax categories)
   - State Management Complexity: High (@Published properties with real-time validation and computed properties)
   - Novelty/Uncertainty Factor: Med-High (Complex percentage validation and Australian tax category management)
 * AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 85%
 * Problem Estimate (Inherent Problem Difficulty %): 90%
 * Initial Code Complexity Estimate %: 85%
 * Justification for Estimates: Complex real-time percentage validation with tax category management and Australian compliance
 * Final Code Complexity (Actual %): TBD
 * Overall Result Score (Success & Quality %): TBD
 * Key Variances/Learnings: TBD
 * Last Updated: 2025-07-07
 */

/// Enumeration for quick split templates
enum QuickSplitType {
    case fiftyFifty
    case seventyThirty
}

/// Data structure for creating new split allocations
struct SplitAllocationData {
    var percentage = 0.0
    var taxCategory = ""
}

/// ViewModel for managing split allocation operations with real-time percentage validation and tax category management
// EMERGENCY FIX: Removed @MainActor to eliminate Swift Concurrency crashes
final class SplitAllocationViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var splitAllocations: [SplitAllocation] = []
    @Published var newSplitPercentage = 0.0
    @Published var selectedTaxCategory = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var customCategories: [String] = []

    // MARK: - Computed Properties

    /// Real-time calculation of total percentage across all split allocations
    var totalPercentage: Double {
        return splitAllocations.reduce(0.0) { $0 + $1.percentage }
    }

    /// Real-time validation of split allocations (must equal 100% or be empty)
    var isValidSplit: Bool {
        let total = totalPercentage
        return total == 0.0 || abs(total - 100.0) < 0.01
    }

    /// Remaining percentage to reach 100%
    var remainingPercentage: Double {
        return 100.0 - totalPercentage
    }

    /// Predefined Australian tax categories
    var predefinedCategories: [String] {
        return [
            "Business",
            "Personal",
            "Investment",
            "Charity",
            "Education",
            "Medical",
            "Travel",
            "Entertainment",
            "Depreciation",
            "Research & Development",
        ]
    }

    /// All available tax categories (predefined + custom)
    var availableTaxCategories: [String] {
        return predefinedCategories + customCategories.sorted()
    }

    // MARK: - Private Properties

    private let context: NSManagedObjectContext

    // MARK: - Initialization

    init(context: NSManagedObjectContext) {
        self.context = context

        // Set default tax category to first predefined category
        if !predefinedCategories.isEmpty {
            selectedTaxCategory = predefinedCategories[0]
        }
    }

    // MARK: - CRUD Operations

    /// Adds a new split allocation to the specified line item
    /// - Parameter lineItem: The line item to add the split allocation to
    func addSplitAllocation() {
        guard validateNewSplitAllocation() else {
            return
        }

        // Check if adding this percentage would exceed 100%
        guard validateTotalPercentage(adding: newSplitPercentage) else {
            errorMessage =
                "Adding this percentage would exceed 100%. Remaining available: \(String(format: "%.2f", remainingPercentage))%"
            return
        }

        do {
            isLoading = true
            errorMessage = nil

            _ = SplitAllocation.create(
                in: context,
                percentage: newSplitPercentage,
                taxCategory: selectedTaxCategory.trimmingCharacters(in: .whitespacesAndNewlines),
                lineItem: lineItem
            )

            try context.save()

            // Reset form data
            newSplitPercentage = 0.0
            // Keep selectedTaxCategory for user convenience

            // Refresh split allocations
            fetchSplitAllocations(for: lineItem)

        } catch {
            errorMessage = "Failed to create split allocation: \(error.localizedDescription)"
        }

        isLoading = false
    }

    /// Updates an existing split allocation
    /// - Parameter splitAllocation: The split allocation to update
    func updateSplitAllocation() {
        do {
            isLoading = true
            errorMessage = nil

            // Validate the updated split allocation
            guard validatePercentage(splitAllocation.percentage) else {
                errorMessage = "Invalid percentage: must be between 0.01 and 100.00"
                isLoading = false
                return
            }

            guard !splitAllocation.taxCategory.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                errorMessage = "Tax category cannot be empty"
                isLoading = false
                return
            }

            // Check total percentage with this update
            let otherSplitsTotal = splitAllocations.filter { $0 != splitAllocation }.reduce(0.0) { $0 + $1.percentage }
            guard (otherSplitsTotal + splitAllocation.percentage) <= 100.01 else {
                errorMessage = "Total percentage cannot exceed 100%"
                isLoading = false
                return
            }

            try context.save()

            // Refresh split allocations to reflect changes
            fetchSplitAllocations(for: splitAllocation.lineItem)

        } catch {
            errorMessage = "Failed to update split allocation: \(error.localizedDescription)"
        }

        isLoading = false
    }

    /// Deletes a split allocation
    /// - Parameter splitAllocation: The split allocation to delete
    func deleteSplitAllocation() {
        do {
            isLoading = true
            errorMessage = nil

            let lineItem = splitAllocation.lineItem
            context.delete(splitAllocation)
            try context.save()

            // Refresh split allocations
            fetchSplitAllocations(for: lineItem)

        } catch {
            errorMessage = "Failed to delete split allocation: \(error.localizedDescription)"
        }

        isLoading = false
    }

    /// Fetches all split allocations for a specific line item
    /// - Parameter lineItem: The line item to fetch split allocations for
    func fetchSplitAllocations() {
        do {
            isLoading = true
            errorMessage = nil

            let request: NSFetchRequest<SplitAllocation> = SplitAllocation.fetchRequest()
            request.predicate = NSPredicate(format: "lineItem == %@", lineItem)
            request.sortDescriptors = [
                NSSortDescriptor(keyPath: \SplitAllocation.percentage, ascending: false),
            ]

            splitAllocations = try context.fetch(request)

        } catch {
            errorMessage = "Failed to fetch split allocations: \(error.localizedDescription)"
            splitAllocations = []
        }

        isLoading = false
    }

    // MARK: - Validation Methods

    /// Validates the new split allocation data
    /// - Returns: True if valid, false otherwise
    private func validateNewSplitAllocation() -> Bool {
        guard validatePercentage(newSplitPercentage) else {
            errorMessage = "Percentage must be between 0.01 and 100.00 with at most 2 decimal places"
            return false
        }

        guard !selectedTaxCategory.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Tax category must be selected"
            return false
        }

        return true
    }

    /// Validates a percentage value
    /// - Parameter percentage: The percentage to validate
    /// - Returns: True if valid, false otherwise
    func validatePercentage(_ percentage: Double) -> Bool {
        guard percentage > 0 && percentage <= 100 else { return false }

        // Check for maximum 2 decimal places
        let rounded = (percentage * 100).rounded() / 100
        return abs(percentage - rounded) < 0.001
    }

    /// Validates that adding a percentage won't exceed 100%
    /// - Parameter additionalPercentage: The percentage being added
    /// - Returns: True if valid, false otherwise
    private func validateTotalPercentage(adding additionalPercentage: Double) -> Bool {
        return (totalPercentage + additionalPercentage) <= 100.01
    }

    // MARK: - Tax Category Management

    /// Adds a custom tax category
    /// - Parameter categoryName: The name of the custom category
    func addCustomTaxCategory(_ categoryName: String) {
        let trimmedName = categoryName.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else { return }
        guard !customCategories.contains(trimmedName) else { return }
        guard !predefinedCategories.contains(trimmedName) else { return }

        customCategories.append(trimmedName)
        customCategories.sort()
    }

    /// Removes a custom tax category
    /// - Parameter categoryName: The name of the custom category to remove
    func removeCustomTaxCategory(_ categoryName: String) {
        customCategories.removeAll { $0 == categoryName }
    }

    // MARK: - Quick Split Templates

    /// Applies a quick split template to a line item
    /// - Parameters:
    ///   - splitType: The type of quick split to apply
    ///   - primaryCategory: The primary tax category
    ///   - secondaryCategory: The secondary tax category
    ///   - lineItem: The line item to apply the split to
    func applyQuickSplit() {
        // Clear existing splits first
        clearAllSplits(for: lineItem)

        let (primaryPercentage, secondaryPercentage) = getQuickSplitPercentages(splitType)

        do {
            isLoading = true
            errorMessage = nil

            // Create primary split
            _ = SplitAllocation.create(
                in: context,
                percentage: primaryPercentage,
                taxCategory: primaryCategory,
                lineItem: lineItem
            )

            // Create secondary split
            _ = SplitAllocation.create(
                in: context,
                percentage: secondaryPercentage,
                taxCategory: secondaryCategory,
                lineItem: lineItem
            )

            try context.save()

            // Refresh split allocations
            fetchSplitAllocations(for: lineItem)

        } catch {
            errorMessage = "Failed to apply quick split: \(error.localizedDescription)"
        }

        isLoading = false
    }

    /// Gets the percentage values for a quick split type
    /// - Parameter splitType: The type of quick split
    /// - Returns: Tuple of (primaryPercentage, secondaryPercentage)
    private func getQuickSplitPercentages(_ splitType: QuickSplitType) -> (Double, Double) {
        switch splitType {
        case .fiftyFifty:
            return (50.0, 50.0)
        case .seventyThirty:
            return (70.0, 30.0)
        }
    }

    /// Clears all split allocations for a line item
    /// - Parameter lineItem: The line item to clear splits for
    func clearAllSplits() {
        do {
            isLoading = true
            errorMessage = nil

            let request: NSFetchRequest<SplitAllocation> = SplitAllocation.fetchRequest()
            request.predicate = NSPredicate(format: "lineItem == %@", lineItem)

            let allSplits = try context.fetch(request)

            for split in allSplits {
                context.delete(split)
            }

            try context.save()

            // Refresh split allocations
            fetchSplitAllocations(for: lineItem)

        } catch {
            errorMessage = "Failed to clear splits: \(error.localizedDescription)"
        }

        isLoading = false
    }

    // MARK: - Utility Methods

    /// Formats a percentage using Australian locale
    /// - Parameter percentage: The percentage to format
    /// - Returns: Formatted percentage string
    func formatPercentage(_ percentage: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.locale = Locale(identifier: "en_AU")
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2

        return formatter.string(from: NSNumber(value: percentage / 100.0)) ?? "0%"
    }

    /// Calculates the amount for a given percentage of a line item
    /// - Parameters:
    ///   - percentage: The percentage
    ///   - lineItem: The line item
    /// - Returns: The calculated amount
    func calculateAmount(for percentage: Double, of lineItem: LineItem) -> Double {
        return (percentage / 100.0) * lineItem.amount
    }

    /// Formats an amount using Australian currency formatting
    /// - Parameter amount: The amount to format
    /// - Returns: Formatted currency string
    func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_AU")
        formatter.currencyCode = "AUD"
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2

        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }

    /// Validates that all splits for a line item total 100%
    /// - Parameter lineItem: The line item to validate
    /// - Returns: True if valid, false otherwise
    func validateLinItemSplitTotal(for lineItem: LineItem) -> Bool {
        let total = Array(lineItem.splitAllocations).reduce(0.0) { $0 + $1.percentage }
        return abs(total - 100.0) < 0.01
    }

    /// Gets usage statistics for tax categories
    /// - Returns: Dictionary of category usage counts
    func getTaxCategoryUsageStats() -> [String: Int] {
        let request: NSFetchRequest<SplitAllocation> = SplitAllocation.fetchRequest()

        do {
            let allSplits = try context.fetch(request)
            var usage: [String: Int] = [:]

            for split in allSplits {
                usage[split.taxCategory, default: 0] += 1
            }

            return usage
        } catch {
            return [:]
        }
    }

    /// Clears any error messages
    func clearError() {
        errorMessage = nil
    }

    /// Resets the new split allocation form
    func resetForm() {
        newSplitPercentage = 0.0
        selectedTaxCategory = predefinedCategories.first ?? ""
        clearError()
    }
}
