import Foundation
import CoreData

/// Transaction Core Data entity
/// BLUEPRINT: Simple transaction model for Gmail receipts and manual entry
@objc(Transaction)
public class Transaction: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID?
    @NSManaged public var amount: Double
    @NSManaged public var itemDescription: String?
    @NSManaged public var date: Date?
    @NSManaged public var source: String? // "gmail", "manual", etc.
}
