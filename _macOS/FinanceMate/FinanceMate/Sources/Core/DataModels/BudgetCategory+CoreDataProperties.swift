import CoreData
import Foundation

extension BudgetCategory {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<BudgetCategory> {
        NSFetchRequest<BudgetCategory>(entityName: "BudgetCategory")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var budgetedAmount: NSDecimalNumber?
    @NSManaged public var spentAmount: NSDecimalNumber?
    @NSManaged public var categoryType: String?
    @NSManaged public var colorHex: String?
    @NSManaged public var icon: String?
    @NSManaged public var alertThreshold: Double
    @NSManaged public var isActive: Bool
    @NSManaged public var dateCreated: Date?
    @NSManaged public var dateUpdated: Date?
    @NSManaged public var notes: String?
    @NSManaged public var metadata: String?
    @NSManaged public var budget: Budget?
    @NSManaged public var allocations: NSSet?
}

// MARK: Generated accessors for allocations
extension BudgetCategory {
    @objc(addAllocationsObject:)
    @NSManaged public func addToAllocations(_ value: BudgetAllocation)

    @objc(removeAllocationsObject:)
    @NSManaged public func removeFromAllocations(_ value: BudgetAllocation)

    @objc(addAllocations:)
    @NSManaged public func addToAllocations(_ values: NSSet)

    @objc(removeAllocations:)
    @NSManaged public func removeFromAllocations(_ values: NSSet)
}

extension BudgetCategory: Identifiable {
}
