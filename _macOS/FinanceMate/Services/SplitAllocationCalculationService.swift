import Foundation
import CoreData

/*
 * Purpose: Service for calculating split allocation amounts and formatting
 * Issues & Complexity Summary: Handles percentage-based amount calculations and currency formatting
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~35
 *   - Core Algorithm Complexity: Low (Basic arithmetic calculations)
 *   - Dependencies: Foundation only
 *   - State Management Complexity: Low (Stateless service)
 *   - Novelty/Uncertainty Factor: Low (Standard calculation patterns)
 * AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 20%
 * Problem Estimate (Inherent Problem Difficulty %): 25%
 * Initial Code Complexity Estimate %: 20%
 * Justification for Estimates: Simple arithmetic calculations and formatting
 * Final Code Complexity (Actual %): TBD
 * Overall Result Score (Success & Quality %): TBD
 * Key Variances/Learnings: TBD
 * Last Updated: 2025-10-04
 */

/// Service responsible for calculating split allocation amounts and formatting
final class SplitAllocationCalculationService {

    // MARK: - Constants

    private static let percentageMultiplier = 100.0
    private static let currencyCode = "AUD"
    private static let currencyLocaleIdentifier = "en_AU"

    // MARK: - Public Methods

    /// Calculates the allocated amount for a given percentage of a line item with enhanced precision
    /// - Parameters:
    ///   - percentage: The percentage to calculate
    ///   - lineItem: The line item with amount and quantity
    /// - Returns: The allocated amount with cent-level precision
    func calculateAllocatedAmount(for percentage: Double, of lineItem: LineItem) -> Double {
        let lineItemTotal = Double(lineItem.quantity) * lineItem.price
        let rawAmount = (percentage / Self.percentageMultiplier) * lineItemTotal

        // Round to 2 decimal places (cents) with proper rounding
        return round(rawAmount * 100) / 100.0
    }

    /// Formats a percentage as a string with appropriate precision
    /// - Parameter percentage: The percentage to format
    /// - Returns: Formatted percentage string
    func formatPercentage(_ percentage: Double) -> String {
        return String(format: "%.2f%%", percentage)
    }

    /// Formats a currency amount using Australian locale
    /// - Parameter amount: The amount to format
    /// - Returns: Formatted currency string
    func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: Self.currencyLocaleIdentifier)
        formatter.currencyCode = Self.currencyCode
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }

    /// Calculates total percentage
    /// - Parameter allocations: Split allocations
    /// - Returns: Total percentage
    func calculateTotalPercentage(from allocations: [SplitAllocation]) -> Double {
        return allocations.reduce(0.0) { $0 + $1.percentage }
    }

    /// Calculates remaining percentage
    /// - Parameter allocations: Split allocations
    /// - Returns: Remaining percentage
    func calculateRemainingPercentage(for allocations: [SplitAllocation]) -> Double {
        return 100.0 - calculateTotalPercentage(from: allocations)
    }

    /// Validates that a line item's split allocations total equals the line item amount
    /// - Parameter lineItem: The line item to validate
    /// - Returns: True if allocations match line item total, false otherwise
    func validateLineItemSplitTotal(for lineItem: LineItem) -> Bool {
        guard let allocations = lineItem.splitAllocations?.allObjects as? [SplitAllocation],
              !allocations.isEmpty else {
            return true // No splits means valid
        }

        let totalAllocatedAmount = allocations.reduce(0.0) { total, allocation in
            total + calculateAllocatedAmount(for: allocation.percentage, of: lineItem)
        }

        let lineItemTotal = Double(lineItem.quantity) * lineItem.price
        return abs(totalAllocatedAmount - lineItemTotal) < 0.01 // Allow for floating point precision
    }

    /// Calculates a breakdown of allocated amounts by tax category
    /// - Parameter allocations: Array of split allocations
    /// - Returns: Dictionary mapping tax categories to allocated amounts
    func calculateCategoryBreakdown(from allocations: [SplitAllocation]) -> [String: Double] {
        var breakdown: [String: Double] = [:]

        for allocation in allocations {
            let category = allocation.taxCategory
            let amount = calculateAllocatedAmount(for: allocation.percentage, of: allocation.lineItem)

            if let existingAmount = breakdown[category] {
                breakdown[category] = existingAmount + amount
            } else {
                breakdown[category] = amount
            }
        }

        return breakdown
    }
}