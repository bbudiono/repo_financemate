import Foundation
import CoreData

/*
 * Purpose: Validation service for split allocation percentages and constraints
 * Issues & Complexity Summary: Handles percentage validation, 100% total constraints, and business rule enforcement
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~50
 *   - Core Algorithm Complexity: Medium (Percentage validation with floating point precision)
 *   - Dependencies: Foundation only
 *   - State Management Complexity: Low (Stateless service)
 *   - Novelty/Uncertainty Factor: Low (Standard validation patterns)
 * AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 35%
 * Problem Estimate (Inherent Problem Difficulty %): 40%
 * Initial Code Complexity Estimate %: 35%
 * Justification for Estimates: Standard validation logic with floating point precision handling
 * Final Code Complexity (Actual %): TBD
 * Overall Result Score (Success & Quality %): TBD
 * Key Variances/Learnings: TBD
 * Last Updated: 2025-10-04
 */

/// Service responsible for validating split allocation constraints and business rules
final class SplitAllocationValidationService {

    // MARK: - Constants

    private static let totalPercentageTarget = 100.0
    private static let floatingPointTolerance = 0.01
    private static let minimumPercentage = 0.01
    private static let maximumPercentage = 100.0

    // MARK: - Public Validation Methods

    /// Validates if a single percentage is within acceptable bounds
    /// - Parameter percentage: The percentage to validate
    /// - Returns: True if valid, false otherwise
    func validatePercentage(_ percentage: Double) -> Bool {
        return percentage >= Self.minimumPercentage && percentage <= Self.maximumPercentage
    }

    /// Validates if adding a new percentage would keep total within bounds
    /// - Parameters:
    ///   - currentTotal: Current total percentage of existing allocations
    ///   - additionalPercentage: New percentage to add
    /// - Returns: True if valid, false otherwise
    func validateTotalPercentage(currentTotal: Double, adding additionalPercentage: Double) -> Bool {
        let newTotal = currentTotal + additionalPercentage
        return newTotal <= Self.maximumPercentage + Self.floatingPointTolerance
    }

    /// Validates if the total percentage equals exactly 100% or is empty (0%)
    /// - Parameter total: The total percentage to validate
    /// - Returns: True if valid split configuration, false otherwise
    func isValidSplitTotal(_ total: Double) -> Bool {
        return total == 0.0 || abs(total - Self.totalPercentageTarget) < Self.floatingPointTolerance
    }

    /// Calculates remaining percentage to reach 100%
    /// - Parameter currentTotal: Current total percentage
    /// - Returns: Remaining percentage needed to reach 100%
    func calculateRemainingPercentage(from currentTotal: Double) -> Double {
        return Self.totalPercentageTarget - currentTotal
    }

    /// Validates that split allocations form a complete or empty set
    /// - Parameter allocations: Array of split allocations to validate
    /// - Returns: True if allocations are valid, false otherwise
    func validateSplitAllocations(_ allocations: [SplitAllocation]) -> Bool {
        let total = allocations.reduce(0.0) { $0 + $1.percentage }
        return isValidSplitTotal(total)
    }

    /// Validates if a new split allocation can be added to existing allocations
    /// - Parameters:
    ///   - existingAllocations: Current split allocations
    ///   - newPercentage: Percentage for the new allocation
    /// - Returns: Validation result with error message if invalid
    func validateNewSplitAllocation(existingAllocations: [SplitAllocation], newPercentage: Double) -> ValidationResult {
        guard validatePercentage(newPercentage) else {
            return .invalid("Percentage must be between 0.01% and 100%")
        }

        let currentTotal = existingAllocations.reduce(0.0) { $0 + $1.percentage }
        guard validateTotalPercentage(currentTotal: currentTotal, adding: newPercentage) else {
            let remaining = calculateRemainingPercentage(from: currentTotal)
            return .invalid("Adding this percentage would exceed 100%. Remaining available: \(String(format: "%.2f", remaining))%")
        }

        return .valid
    }
}

// MARK: - Supporting Types

extension SplitAllocationValidationService {

    /// Represents the result of a validation operation
    enum ValidationResult {
        case valid
        case invalid(String)

        var isValid: Bool {
            switch self {
            case .valid:
                return true
            case .invalid:
                return false
            }
        }

        var errorMessage: String? {
            switch self {
            case .valid:
                return nil
            case .invalid(let message):
                return message
            }
        }
    }
}