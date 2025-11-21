import Foundation
import CoreData

/// Individual line item from receipt/invoice with tax category assignment
@objc(LineItem)
public class LineItem: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var itemDescription: String
    @NSManaged public var quantity: Int32
    @NSManaged public var price: Double
    @NSManaged public var taxCategory: String
    @NSManaged public var transaction: Transaction?

    public override func awakeFromInsert() {
        super.awakeFromInsert()
        setPrimitiveValue(UUID(), forKey: "id")
        setPrimitiveValue("", forKey: "itemDescription")
        setPrimitiveValue(1, forKey: "quantity")
        setPrimitiveValue(0.0, forKey: "price")
        setPrimitiveValue(TaxCategory.personal.rawValue, forKey: "taxCategory")
    }

    /// Computed total for this line item
    public var total: Double {
        return Double(quantity) * price
    }

    /// BLUEPRINT Line 133: Check if this line item has any split allocations
    /// Used by visual indicator system to show split badge on transactions
    public var hasSplitAllocations: Bool {
        guard let allocations = value(forKey: "splitAllocations") as? NSSet else {
            return false
        }
        return allocations.count > 0
    }

    /// BLUEPRINT Line 133: Get count of split allocations for this line item
    public var splitAllocationCount: Int {
        guard let allocations = value(forKey: "splitAllocations") as? NSSet else {
            return 0
        }
        return allocations.count
    }
}
