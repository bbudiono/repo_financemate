import Foundation
import CoreData

@objc(Transaction)
public class Transaction: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID?
    @NSManaged public var amount: Double
    @NSManaged public var itemDescription: String?
    @NSManaged public var date: Date?
    @NSManaged public var source: String?
}
