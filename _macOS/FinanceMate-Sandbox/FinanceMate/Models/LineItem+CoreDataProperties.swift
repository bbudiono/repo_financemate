import CoreData
import Foundation

/*
 * Purpose: Core Data properties extension for LineItem entity with programmatic attribute definitions
 * Issues & Complexity Summary: Defines LineItem entity properties and relationships for Core Data
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~30
 *   - Core Algorithm Complexity: Low
 *   - Dependencies: 1 New (Core Data), 0 Mod
 *   - State Management Complexity: Low
 *   - Novelty/Uncertainty Factor: Low
 * AI Pre-Task Self-Assessment: 95%
 * Problem Estimate: 92%
 * Initial Code Complexity Estimate: 88%
 * Final Code Complexity: 90%
 * Overall Result Score: 95%
 * Key Variances/Learnings: Standard Core Data properties pattern
 * Last Updated: 2025-07-06
 */

extension LineItem {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<LineItem> {
        return NSFetchRequest<LineItem>(entityName: "LineItem")
    }

    @NSManaged public var id: UUID
    @NSManaged public var itemDescription: String
    @NSManaged public var amount: Double
    @NSManaged public var transaction: Transaction?
    @NSManaged public var splitAllocations: NSSet?
}

// MARK: Generated accessors for splitAllocations
extension LineItem {
    @objc(addSplitAllocationsObject:)
    @NSManaged public func addToSplitAllocations(_ value: SplitAllocation)

    @objc(removeSplitAllocationsObject:)
    @NSManaged public func removeFromSplitAllocations(_ value: SplitAllocation)

    @objc(addSplitAllocations:)
    @NSManaged public func addToSplitAllocations(_ values: NSSet)

    @objc(removeSplitAllocations:)
    @NSManaged public func removeFromSplitAllocations(_ values: NSSet)
}