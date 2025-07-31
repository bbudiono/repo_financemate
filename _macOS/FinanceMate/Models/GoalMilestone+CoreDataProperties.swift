import CoreData
import Foundation

/**
 * GoalMilestone+CoreDataProperties.swift
 *
 * Purpose: Core Data properties for GoalMilestone entity
 * Issues & Complexity Summary: Core Data properties definition
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~50+
 *   - Core Algorithm Complexity: Low
 *   - Dependencies: 2 (Foundation, CoreData)
 *   - State Management Complexity: Low
 *   - Novelty/Uncertainty Factor: Low
 * AI Pre-Task Self-Assessment: 80%
 * Problem Estimate: 82%
 * Initial Code Complexity Estimate: 81%
 * Final Code Complexity: 83%
 * Overall Result Score: 82%
 * Key Variances/Learnings: Standard Core Data properties definition
 * Last Updated: 2025-07-11
 */

extension GoalMilestone {

  @nonobjc public class func fetchRequest() -> NSFetchRequest<GoalMilestone> {
    return NSFetchRequest<GoalMilestone>(entityName: "GoalMilestone")
  }

  @NSManaged public var id: UUID
  @NSManaged public var title: String
  @NSManaged public var description_text: String
  @NSManaged public var targetAmount: Double
  @NSManaged public var targetDate: Date
  @NSManaged public var createdAt: Date
  @NSManaged public var lastModified: Date
  @NSManaged public var goal: FinancialGoal?
}

extension GoalMilestone: Identifiable {

  // MARK: - Fetch Requests

  public static func fetchAll() -> NSFetchRequest<GoalMilestone> {
    let request: NSFetchRequest<GoalMilestone> = GoalMilestone.fetchRequest()
    request.sortDescriptors = [NSSortDescriptor(key: "targetDate", ascending: true)]
    return request
  }

  public static func fetchForGoal(_ goal: FinancialGoal) -> NSFetchRequest<GoalMilestone> {
    let request: NSFetchRequest<GoalMilestone> = GoalMilestone.fetchRequest()
    request.predicate = NSPredicate(format: "goal == %@", goal)
    request.sortDescriptors = [NSSortDescriptor(key: "targetDate", ascending: true)]
    return request
  }

  public static func fetchUpcoming(for goal: FinancialGoal, days: Int = 30) -> NSFetchRequest<
    GoalMilestone
  > {
    let request: NSFetchRequest<GoalMilestone> = GoalMilestone.fetchRequest()
    let calendar = Calendar.current
    let cutoffDate = calendar.date(byAdding: .day, value: days, to: Date()) ?? Date()

    request.predicate = NSPredicate(
      format: "goal == %@ AND targetDate <= %@ AND targetDate >= %@", goal, cutoffDate as NSDate,
      Date() as NSDate)
    request.sortDescriptors = [NSSortDescriptor(key: "targetDate", ascending: true)]
    return request
  }

  public static func fetchOverdue(for goal: FinancialGoal) -> NSFetchRequest<GoalMilestone> {
    let request: NSFetchRequest<GoalMilestone> = GoalMilestone.fetchRequest()
    request.predicate = NSPredicate(
      format: "goal == %@ AND targetDate < %@", goal, Date() as NSDate)
    request.sortDescriptors = [NSSortDescriptor(key: "targetDate", ascending: false)]
    return request
  }

  public static func fetchCompleted(for goal: FinancialGoal) -> NSFetchRequest<GoalMilestone> {
    let request: NSFetchRequest<GoalMilestone> = GoalMilestone.fetchRequest()
    request.predicate = NSPredicate(
      format: "goal == %@ AND targetAmount <= goal.currentAmount", goal)
    request.sortDescriptors = [NSSortDescriptor(key: "targetDate", ascending: false)]
    return request
  }
}
