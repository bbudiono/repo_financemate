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
    @NSManaged public var taxCategory: String?
    @NSManaged public var note: String?
    @NSManaged public var sourceEmailID: String?
    @NSManaged public var emailSource: String?  // CRITICAL FIX: Store email sender for merchant extraction
    @NSManaged public var contentHash: Int64  // BLUEPRINT Line 151: Email content hash for cache validation
    @NSManaged public var importedDate: Date?
    @NSManaged public var transactionType: String
    @NSManaged public var externalTransactionId: String?  // Basiq: External transaction ID for duplicate detection

    public override func awakeFromInsert() {
        super.awakeFromInsert()
        setPrimitiveValue(UUID(), forKey: "id")
        setPrimitiveValue(Date(), forKey: "date")
        setPrimitiveValue("manual", forKey: "source")
        setPrimitiveValue("", forKey: "itemDescription")
        setPrimitiveValue(0.0, forKey: "amount")
        setPrimitiveValue("Other", forKey: "category")
        setPrimitiveValue("expense", forKey: "transactionType")
    }

    // MARK: - BLUEPRINT Line 133: Split Visual Indicator Support

    /// Check if this transaction has any split allocations across all line items
    /// Used by TransactionRowView to display split indicator badge
    public var hasSplitAllocations: Bool {
        guard let lineItems = value(forKey: "lineItems") as? NSSet else {
            return false
        }

        for case let lineItem as LineItem in lineItems {
            if lineItem.hasSplitAllocations {
                return true
            }
        }
        return false
    }

    /// Get total count of split allocations across all line items
    /// Used by TransactionRowView to display split count badge
    public var splitAllocationCount: Int {
        guard let lineItems = value(forKey: "lineItems") as? NSSet else {
            return 0
        }

        var totalCount = 0
        for case let lineItem as LineItem in lineItems {
            totalCount += lineItem.splitAllocationCount
        }
        return totalCount
    }
}
