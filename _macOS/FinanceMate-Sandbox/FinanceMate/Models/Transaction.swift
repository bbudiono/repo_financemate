// SANDBOX FILE: For testing/development. See .cursorrules.
import Foundation
import CoreData

@objc(SandboxTransaction)
public class Transaction: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var date: Date
    @NSManaged public var amount: Double
    @NSManaged public var category: String
    @NSManaged public var note: String?
} 