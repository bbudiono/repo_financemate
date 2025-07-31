import CoreData
import Foundation

/**
 * ProgressEntry+CoreDataClass.swift
 *
 * Purpose: Core Data model for tracking progress entries towards financial goals
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

@objc(ProgressEntry)
public class ProgressEntry: NSManagedObject {

  // MARK: - Computed Properties

  var formattedAmount: String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.locale = Locale(identifier: "en_AU")
    return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
  }

  var formattedDate: String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    return formatter.string(from: date)
  }

  var shortFormattedDate: String {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .none
    return formatter.string(from: date)
  }

  var daysSinceCreation: Int {
    let calendar = Calendar.current
    let now = Date()
    let components = calendar.dateComponents([.day], from: date, to: now)
    return components.day ?? 0
  }

  var isRecent: Bool {
    return daysSinceCreation <= 7
  }

  // MARK: - Validation

  override public func validateForInsert() throws {
    try super.validateForInsert()
    try validateProgressEntry()
  }

  override public func validateForUpdate() throws {
    try super.validateForUpdate()
    try validateProgressEntry()
  }

  private func validateProgressEntry() throws {
    // Validate amount
    guard amount > 0 else {
      throw NSError(
        domain: "ProgressEntryError", code: 1001,
        userInfo: [NSLocalizedDescriptionKey: "Amount must be positive"])
    }

    guard amount <= 1_000_000 else {
      throw NSError(
        domain: "ProgressEntryError", code: 1002,
        userInfo: [NSLocalizedDescriptionKey: "Amount cannot exceed $1,000,000"])
    }

    // Validate date
    guard date <= Date() else {
      throw NSError(
        domain: "ProgressEntryError", code: 1003,
        userInfo: [NSLocalizedDescriptionKey: "Date cannot be in the future"])
    }

    // Validate goal relationship
    guard goal != nil else {
      throw NSError(
        domain: "ProgressEntryError", code: 1004,
        userInfo: [NSLocalizedDescriptionKey: "Progress entry must be associated with a goal"])
    }
  }

  // MARK: - Helper Methods

  func update(amount: Double, date: Date, note: String) {
    self.amount = amount
    self.date = date
    self.note = note
    self.lastModified = Date()
  }

  static func create(
    in context: NSManagedObjectContext,
    goal: FinancialGoal,
    amount: Double,
    date: Date,
    note: String
  ) -> ProgressEntry {
    let progressEntry = ProgressEntry(context: context)
    progressEntry.id = UUID()
    progressEntry.amount = amount
    progressEntry.date = date
    progressEntry.note = note
    progressEntry.goal = goal
    progressEntry.createdAt = Date()
    progressEntry.lastModified = Date()

    return progressEntry
  }
}
