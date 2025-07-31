import CoreData
import Foundation

/**
 * ProgressEntry+CoreDataProperties.swift
 *
 * Purpose: Core Data properties for ProgressEntry entity
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

extension ProgressEntry {

  @nonobjc public class func fetchRequest() -> NSFetchRequest<ProgressEntry> {
    return NSFetchRequest<ProgressEntry>(entityName: "ProgressEntry")
  }

  @NSManaged public var id: UUID
  @NSManaged public var amount: Double
  @NSManaged public var date: Date
  @NSManaged public var note: String
  @NSManaged public var createdAt: Date
  @NSManaged public var lastModified: Date
  @NSManaged public var goal: FinancialGoal?
}

extension ProgressEntry: Identifiable {

  // MARK: - Fetch Requests

  public static func fetchAll() -> NSFetchRequest<ProgressEntry> {
    let request: NSFetchRequest<ProgressEntry> = ProgressEntry.fetchRequest()
    request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
    return request
  }

  public static func fetchForGoal(_ goal: FinancialGoal) -> NSFetchRequest<ProgressEntry> {
    let request: NSFetchRequest<ProgressEntry> = ProgressEntry.fetchRequest()
    request.predicate = NSPredicate(format: "goal == %@", goal)
    request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
    return request
  }

  public static func fetchRecent(for goal: FinancialGoal, days: Int = 30) -> NSFetchRequest<
    ProgressEntry
  > {
    let request: NSFetchRequest<ProgressEntry> = ProgressEntry.fetchRequest()
    let calendar = Calendar.current
    let cutoffDate = calendar.date(byAdding: .day, value: -days, to: Date()) ?? Date()

    request.predicate = NSPredicate(format: "goal == %@ AND date >= %@", goal, cutoffDate as NSDate)
    request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
    return request
  }

  public static func fetchForDateRange(startDate: Date, endDate: Date) -> NSFetchRequest<
    ProgressEntry
  > {
    let request: NSFetchRequest<ProgressEntry> = ProgressEntry.fetchRequest()
    request.predicate = NSPredicate(
      format: "date >= %@ AND date <= %@", startDate as NSDate, endDate as NSDate)
    request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
    return request
  }
}
