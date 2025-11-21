import CoreData
import Foundation

/*
 * Purpose: Helper utilities for split allocation operations
 * Issues & Complexity Summary: Provides utility functions for common split allocation tasks
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~40
 *   - Core Algorithm Complexity: Low (Utility functions)
 *   - Dependencies: Core Data, Foundation
 *   - State Management Complexity: Low (Static utilities)
 *   - Novelty/Uncertainty Factor: Low (Standard utility patterns)
 * AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 15%
 * Problem Estimate (Inherent Problem Difficulty %): 20%
 * Initial Code Complexity Estimate %: 15%
 * Justification for Estimates: Simple utility functions with clear responsibilities
 * Final Code Complexity (Actual %): TBD
 * Overall Result Score (Success & Quality %): TBD
 * Key Variances/Learnings: TBD
 * Last Updated: 2025-10-04
 */

/// Utility functions for split allocation operations
enum SplitAllocationHelpers {

    /// Validates if a new split allocation can be added
    static func validateNewSplit(
        existingAllocations: [SplitAllocation],
        newPercentage: Double,
        validationService: SplitAllocationValidationService
    ) -> SplitAllocationValidationService.ValidationResult {
        return validationService.validateNewSplitAllocation(
            existingAllocations: existingAllocations,
            newPercentage: newPercentage
        )
    }

    /// Prepares category name for storage
    static func prepareCategory(_ category: String, taxCategoryService: SplitAllocationTaxCategoryService) -> String? {
        return taxCategoryService.prepareCategoryName(category)
    }

    /// Adds custom tax category with result handling
    static func addCustomCategory(
        _ categoryName: String,
        to categories: [String],
        taxCategoryService: SplitAllocationTaxCategoryService
    ) -> (isSuccess: Bool, categories: [String]?, errorMessage: String?) {
        let result = taxCategoryService.addCustomCategory(categoryName, to: categories)
        return (result.isSuccess, result.categories, result.errorMessage)
    }

    /// Removes custom tax category with result handling
    static func removeCustomCategory(
        _ categoryName: String,
        from categories: [String],
        taxCategoryService: SplitAllocationTaxCategoryService
    ) -> (isSuccess: Bool, categories: [String]?, errorMessage: String?) {
        let result = taxCategoryService.removeCustomCategory(categoryName, from: categories)
        return (result.isSuccess, result.categories, result.errorMessage)
    }
}

/// Result type for split allocation validation operations
struct SplitValidationResult {
    let isValid: Bool
    let errorMessage: String?
}