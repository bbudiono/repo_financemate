import Foundation
import CoreData

extension GoalMilestone {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GoalMilestone> {
        return NSFetchRequest<GoalMilestone>(entityName: "GoalMilestone")
    }

    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var targetAmount: Double
    @NSManaged public var targetDate: Date
    @NSManaged public var achievedDate: Date?
    @NSManaged public var isAchieved: Bool
    @NSManaged public var createdAt: Date
    @NSManaged public var goal: FinancialGoal?

}