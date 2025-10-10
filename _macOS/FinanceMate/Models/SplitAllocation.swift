import Foundation
import CoreData

/// Tax category split allocation for line items
/// BLUEPRINT Section 3.1.3: Line Item Splitting & Tax Allocation
@objc(SplitAllocation)
public class SplitAllocation: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var lineItemID: UUID
    @NSManaged public var taxCategory: String
    @NSManaged public var percentage: Double
    @NSManaged public var amount: Double
}

extension SplitAllocation {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<SplitAllocation> {
        return NSFetchRequest<SplitAllocation>(entityName: "SplitAllocation")
    }
}
