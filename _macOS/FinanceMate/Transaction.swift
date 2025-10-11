import Foundation
import CoreData

// MARK: - Tax Category Enum (Australian Compliance)

enum TaxCategory: String, CaseIterable {
    case personal = "Personal"
    case business = "Business"
    case investment = "Investment"
    case propertyInvestment = "Property Investment"
    case other = "Other"
}

@objc(Transaction)
public class Transaction: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var amount: Double
    @NSManaged public var itemDescription: String
    @NSManaged public var date: Date
    @NSManaged public var source: String
    @NSManaged public var category: String
    @NSManaged public var taxCategory: String
    @NSManaged public var note: String?
    @NSManaged public var sourceEmailID: String?
    @NSManaged public var contentHash: Int64  // BLUEPRINT Line 151: Email content hash for cache validation
    @NSManaged public var importedDate: Date?
    @NSManaged public var transactionType: String

    public override func awakeFromInsert() {
        super.awakeFromInsert()
        setPrimitiveValue(UUID(), forKey: "id")
        setPrimitiveValue(Date(), forKey: "date")
        setPrimitiveValue("manual", forKey: "source")
        setPrimitiveValue("", forKey: "itemDescription")
        setPrimitiveValue(0.0, forKey: "amount")
        setPrimitiveValue("Other", forKey: "category")
        setPrimitiveValue(TaxCategory.personal.rawValue, forKey: "taxCategory")
        setPrimitiveValue("expense", forKey: "transactionType")
    }
}
