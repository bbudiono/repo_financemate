import CoreData
import Foundation

/**
 * GoalMilestone+CoreDataClass.swift
 *
 * Purpose: Core Data model for tracking milestones within financial goals
 * Issues & Complexity Summary: Core Data entity with relationships and computed properties
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~150+
 *   - Core Algorithm Complexity: Low
 *   - Dependencies: 2 (Foundation, CoreData)
 *   - State Management Complexity: Medium
 *   - Novelty/Uncertainty Factor: Low
 * AI Pre-Task Self-Assessment: 83%
 * Problem Estimate: 85%
 * Initial Code Complexity Estimate: 84%
 * Final Code Complexity: 86%
 * Overall Result Score: 85%
 * Key Variances/Learnings: Comprehensive Core Data model with validation and computed properties
 * Last Updated: 2025-07-11
 */

@objc(GoalMilestone)
public class GoalMilestone: NSManagedObject {

  // MARK: - Computed Properties

  var formattedTargetAmount: String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.locale = Locale(identifier: "en_AU")
    return formatter.string(from: NSNumber(value: targetAmount)) ?? "$0.00"
  }

  var formattedTargetDate: String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    return formatter.string(from: targetDate)
  }

  var shortFormattedTargetDate: String {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .none
    return formatter.string(from: targetDate)
  }

  var daysUntilTarget: Int {
    let calendar = Calendar.current
    let now = Date()
    let components = calendar.dateComponents([.day], from: now, to: targetDate)
    return components.day ?? 0
  }

  var isOverdue: Bool {
    return daysUntilTarget < 0
  }

  var isCompleted: Bool {
    guard let goal = goal else { return false }
    return goal.currentAmount >= targetAmount
  }

  var progressPercentage: Double {
    guard let goal = goal else { return 0 }
    guard goal.targetAmount > 0 else { return 0 }
    return min((targetAmount / goal.targetAmount) * 100, 100)
  }

  var status: MilestoneStatus {
    if isCompleted {
      return .completed
    } else if isOverdue {
      return .overdue
    } else if daysUntilTarget <= 7 {
      return .upcoming
    } else {
      return .active
    }
  }

  // MARK: - Validation

  override public func validateForInsert() throws {
    try super.validateForInsert()
    try validateMilestone()
  }

  override public func validateForUpdate() throws {
    try super.validateForUpdate()
    try validateMilestone()
  }

  private func validateMilestone() throws {
    // Validate title
    guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
      throw NSError(
        domain: "GoalMilestoneError", code: 1001,
        userInfo: [NSLocalizedDescriptionKey: "Title cannot be empty"])
    }

    guard title.count >= 3 else {
      throw NSError(
        domain: "GoalMilestoneError", code: 1002,
        userInfo: [NSLocalizedDescriptionKey: "Title must be at least 3 characters long"])
    }

    // Validate target amount
    guard targetAmount > 0 else {
      throw NSError(
        domain: "GoalMilestoneError", code: 1003,
        userInfo: [NSLocalizedDescriptionKey: "Target amount must be positive"])
    }

    guard targetAmount <= 10_000_000 else {
      throw NSError(
        domain: "GoalMilestoneError", code: 1004,
        userInfo: [NSLocalizedDescriptionKey: "Target amount cannot exceed $10,000,000"])
    }

    // Validate target date
    let now = Date()
    guard targetDate > now else {
      throw NSError(
        domain: "GoalMilestoneError", code: 1005,
        userInfo: [NSLocalizedDescriptionKey: "Target date must be in the future"])
    }

    // Validate goal relationship
    guard goal != nil else {
      throw NSError(
        domain: "GoalMilestoneError", code: 1006,
        userInfo: [NSLocalizedDescriptionKey: "Milestone must be associated with a goal"])
    }

    // Validate milestone amount doesn't exceed goal target
    if let goal = goal {
      guard targetAmount <= goal.targetAmount else {
        throw NSError(
          domain: "GoalMilestoneError", code: 1007,
          userInfo: [
            NSLocalizedDescriptionKey: "Milestone target amount cannot exceed goal target amount"
          ])
      }

      // Validate milestone date doesn't exceed goal target date
      guard targetDate <= goal.targetDate else {
        throw NSError(
          domain: "GoalMilestoneError", code: 1008,
          userInfo: [
            NSLocalizedDescriptionKey: "Milestone target date cannot exceed goal target date"
          ])
      }
    }
  }

  // MARK: - Helper Methods

  func update(title: String, description: String, targetAmount: Double, targetDate: Date) {
    self.title = title
    self.description_text = description
    self.targetAmount = targetAmount
    self.targetDate = targetDate
    self.lastModified = Date()
  }

  static func create(
    in context: NSManagedObjectContext,
    goal: FinancialGoal,
    title: String,
    description: String,
    targetAmount: Double,
    targetDate: Date
  ) -> GoalMilestone {
    let milestone = GoalMilestone(context: context)
    milestone.id = UUID()
    milestone.title = title
    milestone.description_text = description
    milestone.targetAmount = targetAmount
    milestone.targetDate = targetDate
    milestone.goal = goal
    milestone.createdAt = Date()
    milestone.lastModified = Date()

    return milestone
  }
}

// MARK: - Milestone Status

enum MilestoneStatus: String, CaseIterable {
  case active = "active"
  case upcoming = "upcoming"
  case completed = "completed"
  case overdue = "overdue"

  var displayName: String {
    switch self {
    case .active:
      return "Active"
    case .upcoming:
      return "Upcoming"
    case .completed:
      return "Completed"
    case .overdue:
      return "Overdue"
    }
  }

  var icon: String {
    switch self {
    case .active:
      return "flag.fill"
    case .upcoming:
      return "clock.fill"
    case .completed:
      return "checkmark.circle.fill"
    case .overdue:
      return "exclamationmark.triangle.fill"
    }
  }

  var color: String {
    switch self {
    case .active:
      return "blue"
    case .upcoming:
      return "yellow"
    case .completed:
      return "green"
    case .overdue:
      return "red"
    }
  }
}
