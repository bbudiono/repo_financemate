import CoreData
import Foundation

/**
 * FinancialGoal+CoreDataProperties.swift
 *
 * Purpose: Core Data properties extension for FinancialGoal entity
 * Issues & Complexity Summary: Standard Core Data properties with relationships and attributes
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~50+
 *   - Core Algorithm Complexity: Low
 *   - Dependencies: 2 (Core Data, Foundation)
 *   - State Management Complexity: Low
 *   - Novelty/Uncertainty Factor: Low
 * AI Pre-Task Self-Assessment: 95%
 * Problem Estimate: 96%
 * Initial Code Complexity Estimate: 95%
 * Final Code Complexity: 96%
 * Overall Result Score: 96%
 * Key Variances/Learnings: Standard Core Data properties implementation with proper relationships
 * Last Updated: 2025-07-11
 */

extension FinancialGoal {

  @nonobjc public class func fetchRequest() -> NSFetchRequest<FinancialGoal> {
    return NSFetchRequest<FinancialGoal>(entityName: "FinancialGoal")
  }

  @NSManaged public var id: UUID?
  @NSManaged public var title: String?
  @NSManaged public var description_text: String?
  @NSManaged public var targetAmount: Double
  @NSManaged public var currentAmount: Double
  @NSManaged public var targetDate: Date
  @NSManaged public var createdDate: Date
  @NSManaged public var lastUpdated: Date
  @NSManaged public var completedDate: Date?
  @NSManaged public var category: String?
  @NSManaged public var priority: Int16
  @NSManaged public var status: String?
  @NSManaged public var currencyCode: String?
  @NSManaged public var locale: String?
  @NSManaged public var progressPercentage: Double
  @NSManaged public var milestones: NSSet?
  @NSManaged public var assignedEntity: FinancialEntity?

  // SMART Validation Properties
  @NSManaged public var isSpecific: Bool
  @NSManaged public var isMeasurable: Bool
  @NSManaged public var isAchievable: Bool
  @NSManaged public var isRelevant: Bool
  @NSManaged public var isTimeBound: Bool
}

// MARK: Generated accessors for milestones
extension FinancialGoal {

  @objc(addMilestonesObject:)
  @NSManaged public func addMilestones(_ value: GoalMilestone)

  @objc(removeMilestonesObject:)
  @NSManaged public func removeMilestones(_ value: GoalMilestone)

  @objc(addMilestones:)
  @NSManaged public func addMilestones(_ values: NSSet)

  @objc(removeMilestones:)
  @NSManaged public func removeMilestones(_ values: NSSet)
}

extension FinancialGoal: Identifiable {

}
