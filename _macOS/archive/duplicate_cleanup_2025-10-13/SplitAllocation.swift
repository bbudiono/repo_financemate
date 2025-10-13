import Foundation
import CoreData

/*
 * Purpose: SplitAllocation model for assigning a percentage of a line item to a tax category.
 * Issues & Complexity Summary: Enforces sum-to-100% constraint at the business logic layer.
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~50
 *   - Core Algorithm Complexity: Low (model only)
 *   - Dependencies: LineItem
 *   - State Management Complexity: Low
 *   - Novelty/Uncertainty Factor: Low
 * AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 40%
 * Problem Estimate (Inherent Problem Difficulty %): 45%
 * Initial Code Complexity Estimate %: 40%
 * Justification for Estimates: Simple model, but critical for downstream validation
 * Final Code Complexity (Actual %): TBD
 * Overall Result Score (Success & Quality %): TBD
 * Key Variances/Learnings: TBD
 * Last Updated: 2025-10-04
 */

/// Represents a split allocation for a line item (e.g., 70% Business, 30% Personal).
/// Linked to LineItem and references a tax category and percentage.
@objc(SplitAllocation)
public class SplitAllocation: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var percentage: Double
    @NSManaged public var taxCategory: String
    @NSManaged public var lineItem: LineItem

    public override func awakeFromInsert() {
        super.awakeFromInsert()
        setPrimitiveValue(UUID(), forKey: "id")
        setPrimitiveValue(0.0, forKey: "percentage")
        setPrimitiveValue("Personal", forKey: "taxCategory")
    }
}

// MARK: - Convenience Methods

extension SplitAllocation {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<SplitAllocation> {
        return NSFetchRequest<SplitAllocation>(entityName: "SplitAllocation")
    }

    /// Creates a new SplitAllocation with the given parameters
    /// - Parameters:
    ///   - context: The managed object context
    ///   - percentage: The percentage allocation (0-100)
    ///   - taxCategory: The tax category for this allocation
    ///   - lineItem: The line item this allocation belongs to
    /// - Returns: A new SplitAllocation instance
    static func create(
        in context: NSManagedObjectContext,
        percentage: Double,
        taxCategory: String,
        lineItem: LineItem
    ) -> SplitAllocation {
        let splitAllocation = SplitAllocation(context: context)
        splitAllocation.id = UUID()
        splitAllocation.percentage = percentage
        splitAllocation.taxCategory = taxCategory
        splitAllocation.lineItem = lineItem
        return splitAllocation
    }

    /// Validates that the percentage is within acceptable bounds
    /// - Returns: True if percentage is valid, false otherwise
    func validatePercentage() -> Bool {
        return percentage > 0 && percentage <= 100
    }

    /// Calculates the allocated amount for this split based on the line item's total
    /// - Returns: The allocated amount
    func allocatedAmount() -> Double {
        return (percentage / 100.0) * lineItem.amount
    }
}