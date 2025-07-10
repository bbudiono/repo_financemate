import Foundation
import CoreData

extension FinancialGoal {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FinancialGoal> {
        return NSFetchRequest<FinancialGoal>(entityName: "FinancialGoal")
    }

    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var goalDescription: String?
    @NSManaged public var targetAmount: Double
    @NSManaged public var currentAmount: Double
    @NSManaged public var targetDate: Date
    @NSManaged public var category: String
    @NSManaged public var priority: String
    @NSManaged public var createdAt: Date
    @NSManaged public var lastModified: Date
    @NSManaged public var isAchieved: Bool
    @NSManaged public var milestones: NSSet?
    @NSManaged public var transactions: NSSet?

}

// MARK: Generated accessors for milestones
extension FinancialGoal {

    @objc(addMilestonesObject:)
    @NSManaged public func addToMilestones(_ value: GoalMilestone)

    @objc(removeMilestonesObject:)
    @NSManaged public func removeFromMilestones(_ value: GoalMilestone)

    @objc(addMilestones:)
    @NSManaged public func addToMilestones(_ values: NSSet)

    @objc(removeMilestones:)
    @NSManaged public func removeFromMilestones(_ values: NSSet)

}

// MARK: Generated accessors for transactions
extension FinancialGoal {

    @objc(addTransactionsObject:)
    @NSManaged public func addToTransactions(_ value: Transaction)

    @objc(removeTransactionsObject:)
    @NSManaged public func removeFromTransactions(_ value: Transaction)

    @objc(addTransactions:)
    @NSManaged public func addToTransactions(_ values: NSSet)

    @objc(removeTransactions:)
    @NSManaged public func removeFromTransactions(_ values: NSSet)

}