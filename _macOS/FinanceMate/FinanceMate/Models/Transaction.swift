import Foundation
import CoreData

@objc(Transaction)
public class Transaction: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var date: Date
    @NSManaged public var amount: Double
    @NSManaged public var category: String
    @NSManaged public var note: String?
} 