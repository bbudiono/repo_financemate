import CoreData
import Foundation

/*
 * Purpose: Transaction model for financial records. Now extended for line item splitting (Phase 2).
 * Issues & Complexity Summary: Adding support for line items and split allocations introduces new relationships and validation logic.
 * Key Complexity Drivers:
   - Logic Scope (Est. LoC): ~100 (with new models)
   - Core Algorithm Complexity: Med-High (split validation, relationships)
   - Dependencies: 2 New (LineItem, SplitAllocation)
   - State Management Complexity: Med
   - Novelty/Uncertainty Factor: Med (multi-level Core Data relationships)
 * AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 80%
 * Problem Estimate (Inherent Problem Difficulty %): 85%
 * Initial Code Complexity Estimate %: 80%
 * Justification for Estimates: Multi-entity relationships, validation, and UI integration
 * Final Code Complexity (Actual %): [TBD]
 * Overall Result Score (Success & Quality %): [TBD]
 * Key Variances/Learnings: [TBD]
 * Last Updated: 2025-07-06
 */

@objc(Transaction)
public class Transaction: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var date: Date
    @NSManaged public var amount: Double
    @NSManaged public var category: String
    @NSManaged public var note: String?
    @NSManaged public var createdAt: Date
    @NSManaged public var lineItems: Set<LineItem>
}

// MARK: - Phase 2: Line Item Splitting Models (Core Data implementation)

/// Represents a single line item within a transaction (e.g., "Laptop", "Mouse").
/// Linked to Transaction and has multiple SplitAllocations.
///
/*
 * Purpose: LineItem model for itemized transaction details and split allocations.
 * Issues & Complexity Summary: Introduces one-to-many relationship with SplitAllocation and many-to-one with Transaction.
 * Key Complexity Drivers:
   - Logic Scope (Est. LoC): ~40
   - Core Algorithm Complexity: Low (model only)
   - Dependencies: SplitAllocation, Transaction
   - State Management Complexity: Med (relationship integrity)
   - Novelty/Uncertainty Factor: Med (multi-level Core Data relationships)
 * AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 60%
 * Problem Estimate (Inherent Problem Difficulty %): 65%
 * Initial Code Complexity Estimate %: 60%
 * Justification for Estimates: Standard Core Data relationships, but new for this codebase
 * Final Code Complexity (Actual %): [TBD]
 * Overall Result Score (Success & Quality %): [TBD]
 * Key Variances/Learnings: [TBD]
 * Last Updated: 2025-07-06
 */
@objc(LineItem)
public class LineItem: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var itemDescription: String
    @NSManaged public var amount: Double
    @NSManaged public var transaction: Transaction
    @NSManaged public var splitAllocations: Set<SplitAllocation>
}

/// Represents a split allocation for a line item (e.g., 70% Business, 30% Personal).
/// Linked to LineItem and references a tax category and percentage.
/*
 * Purpose: SplitAllocation model for assigning a percentage of a line item to a tax category.
 * Issues & Complexity Summary: Enforces sum-to-100% constraint at the business logic layer.
 * Key Complexity Drivers:
   - Logic Scope (Est. LoC): ~30
   - Core Algorithm Complexity: Low (model only)
   - Dependencies: LineItem
   - State Management Complexity: Low
   - Novelty/Uncertainty Factor: Low
 * AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 40%
 * Problem Estimate (Inherent Problem Difficulty %): 45%
 * Initial Code Complexity Estimate %: 40%
 * Justification for Estimates: Simple model, but critical for downstream validation
 * Final Code Complexity (Actual %): [TBD]
 * Overall Result Score (Success & Quality %): [TBD]
 * Key Variances/Learnings: [TBD]
 * Last Updated: 2025-07-06
 */
@objc(SplitAllocation)
public class SplitAllocation: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var percentage: Double
    @NSManaged public var taxCategory: String
    @NSManaged public var lineItem: LineItem
}

// MARK: - Convenience Methods

extension LineItem {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<LineItem> {
        return NSFetchRequest<LineItem>(entityName: "LineItem")
    }

    static func create(
        in context: NSManagedObjectContext,
        itemDescription: String,
        amount: Double,
        transaction: Transaction
    ) -> LineItem {
        let lineItem = LineItem(context: context)
        lineItem.id = UUID()
        lineItem.itemDescription = itemDescription
        lineItem.amount = amount
        lineItem.transaction = transaction
        lineItem.splitAllocations = Set<SplitAllocation>()
        return lineItem
    }
}

extension SplitAllocation {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<SplitAllocation> {
        return NSFetchRequest<SplitAllocation>(entityName: "SplitAllocation")
    }

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
}
