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
}
