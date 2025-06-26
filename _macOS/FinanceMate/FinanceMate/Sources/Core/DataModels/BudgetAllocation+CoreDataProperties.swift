import CoreData
import Foundation

extension BudgetAllocation {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<BudgetAllocation> {
        NSFetchRequest<BudgetAllocation>(entityName: "BudgetAllocation")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var amount: NSDecimalNumber?
    @NSManaged public var percentage: Double
    @NSManaged public var allocationDate: Date?
    @NSManaged public var notes: String?
    @NSManaged public var isActive: Bool
    @NSManaged public var dateCreated: Date?
    @NSManaged public var dateUpdated: Date?
    @NSManaged public var metadata: String?
    @NSManaged public var budget: Budget?
    @NSManaged public var budgetCategory: BudgetCategory?
}

extension BudgetAllocation: Identifiable {
}
