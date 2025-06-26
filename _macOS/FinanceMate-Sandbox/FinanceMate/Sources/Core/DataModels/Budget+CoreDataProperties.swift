import CoreData
import Foundation

extension Budget {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Budget> {
        NSFetchRequest<Budget>(entityName: "Budget")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var totalAmount: NSDecimalNumber?
    @NSManaged public var budgetType: String?
    @NSManaged public var startDate: Date?
    @NSManaged public var endDate: Date?
    @NSManaged public var isActive: Bool
    @NSManaged public var dateCreated: Date?
    @NSManaged public var dateUpdated: Date?
    @NSManaged public var notes: String?
    @NSManaged public var currency: String?
    @NSManaged public var metadata: String?
    @NSManaged public var categories: NSSet?
    @NSManaged public var allocations: NSSet?
}

// MARK: Generated accessors for categories
extension Budget {
    @objc(addCategoriesObject:)
    @NSManaged public func addToCategories(_ value: BudgetCategory)

    @objc(removeCategoriesObject:)
    @NSManaged public func removeFromCategories(_ value: BudgetCategory)

    @objc(addCategories:)
    @NSManaged public func addToCategories(_ values: NSSet)

    @objc(removeCategories:)
    @NSManaged public func removeFromCategories(_ values: NSSet)
}

// MARK: Generated accessors for allocations
extension Budget {
    @objc(addAllocationsObject:)
    @NSManaged public func addToAllocations(_ value: BudgetAllocation)

    @objc(removeAllocationsObject:)
    @NSManaged public func removeFromAllocations(_ value: BudgetAllocation)

    @objc(addAllocations:)
    @NSManaged public func addToAllocations(_ values: NSSet)

    @objc(removeAllocations:)
    @NSManaged public func removeFromAllocations(_ values: NSSet)
}

extension Budget: Identifiable {
}
