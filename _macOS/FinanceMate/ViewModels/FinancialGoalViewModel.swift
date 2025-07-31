import Combine
import CoreData
import Foundation

/**
 * FinancialGoalViewModel.swift
 *
 * Purpose: Manages financial goal CRUD operations with SMART validation and progress tracking
 * Issues & Complexity Summary: Complex goal management with validation and progress tracking
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~400+
 *   - Core Algorithm Complexity: Medium-High
 *   - Dependencies: 3 (Foundation, CoreData, Combine)
 *   - State Management Complexity: High
 *   - Novelty/Uncertainty Factor: Medium
 * AI Pre-Task Self-Assessment: 89%
 * Problem Estimate: 91%
 * Initial Code Complexity Estimate: 90%
 * Final Code Complexity: 92%
 * Overall Result Score: 91%
 * Key Variances/Learnings: Comprehensive goal management with SMART validation and progress tracking
 * Last Updated: 2025-07-11
 */

class FinancialGoalViewModel: ObservableObject {
  @Published var goals: [FinancialGoal] = []
  @Published var isLoading: Bool = false
  @Published var errorMessage: String?
  @Published var selectedGoal: FinancialGoal?

  private let context: NSManagedObjectContext
  private var cancellables = Set<AnyCancellable>()

  init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
    self.context = context
    loadGoals()
    setupNotifications()
  }

  // MARK: - Goal CRUD Operations

  func createGoal(
    title: String,
    description: String = "",
    targetAmount: Double,
    targetDate: Date,
    category: GoalCategory,
    priority: GoalPriority
  ) -> Result<FinancialGoal, GoalError> {

    // Validate goal parameters
    let validation = validateGoalParameters(
      title: title,
      targetAmount: targetAmount,
      targetDate: targetDate,
      category: category
    )

    switch validation {
    case .failure(let error):
      return .failure(error)
    case .success:
      break
    }

    // Create new goal
    let goal = FinancialGoal(context: context)
    goal.id = UUID()
    goal.title = title
    goal.description_text = description
    goal.targetAmount = targetAmount
    goal.currentAmount = 0.0
    goal.targetDate = targetDate
    goal.category = category.rawValue
    goal.priority = priority.rawValue
    goal.status = GoalStatus.active.rawValue
    goal.createdAt = Date()
    goal.lastModified = Date()
    goal.isCompleted = false
    goal.progressPercentage = 0.0

    // Calculate derived properties
    goal.updateProgressProperties()
    goal.updateSMARTProperties()

    // Save context
    do {
      try context.save()
      goals.append(goal)
      return .success(goal)
    } catch {
      errorMessage = "Failed to create goal: \(error.localizedDescription)"
      return .failure(.saveFailed(error.localizedDescription))
    }
  }

  func updateGoal(
    _ goal: FinancialGoal,
    title: String? = nil,
    description: String? = nil,
    targetAmount: Double? = nil,
    targetDate: Date? = nil,
    category: GoalCategory? = nil,
    priority: GoalPriority? = nil
  ) -> Result<FinancialGoal, GoalError> {

    // Validate parameters if provided
    if let newTitle = title ?? goal.title,
      let newTargetAmount = targetAmount ?? goal.targetAmount,
      let newTargetDate = targetDate ?? goal.targetDate,
      let newCategory = category ?? GoalCategory(rawValue: goal.category)
    {

      let validation = validateGoalParameters(
        title: newTitle,
        targetAmount: newTargetAmount,
        targetDate: newTargetDate,
        category: newCategory
      )

      switch validation {
      case .failure(let error):
        return .failure(error)
      case .success:
        break
      }
    }

    // Update goal properties
    goal.title = title ?? goal.title
    goal.description_text = description ?? goal.description_text
    goal.targetAmount = targetAmount ?? goal.targetAmount
    goal.targetDate = targetDate ?? goal.targetDate
    goal.category = category?.rawValue ?? goal.category
    goal.priority = priority?.rawValue ?? goal.priority
    goal.lastModified = Date()

    // Recalculate derived properties
    goal.updateProgressProperties()
    goal.updateSMARTProperties()

    // Save context
    do {
      try context.save()
      return .success(goal)
    } catch {
      errorMessage = "Failed to update goal: \(error.localizedDescription)"
      return .failure(.saveFailed(error.localizedDescription))
    }
  }

  func deleteGoal(_ goal: FinancialGoal) -> Result<Void, GoalError> {
    context.delete(goal)

    do {
      try context.save()
      goals.removeAll { $0.id == goal.id }
      return .success(())
    } catch {
      errorMessage = "Failed to delete goal: \(error.localizedDescription)"
      return .failure(.saveFailed(error.localizedDescription))
    }
  }

  func addProgressToGoal(_ goal: FinancialGoal, amount: Double, note: String = "") -> Result<
    Void, GoalError
  > {
    guard amount > 0 else {
      return .failure(.invalidAmount("Progress amount must be positive"))
    }

    goal.currentAmount += amount
    goal.lastModified = Date()

    // Update goal properties
    goal.updateProgressProperties()

    // Check if goal is completed
    if goal.currentAmount >= goal.targetAmount {
      goal.isCompleted = true
      goal.completionDate = Date()
      goal.status = GoalStatus.completed.rawValue
    }

    // Save context
    do {
      try context.save()
      return .success(())
    } catch {
      errorMessage = "Failed to add progress: \(error.localizedDescription)"
      return .failure(.saveFailed(error.localizedDescription))
    }
  }

  // MARK: - Goal Filtering and Sorting

  func goalsByCategory(_ category: GoalCategory) -> [FinancialGoal] {
    return goals.filter { $0.category == category.rawValue }
  }

  func goalsByPriority(_ priority: GoalPriority) -> [FinancialGoal] {
    return goals.filter { $0.priority == priority.rawValue }
  }

  func goalsByStatus(_ status: GoalStatus) -> [FinancialGoal] {
    return goals.filter { $0.status == status.rawValue }
  }

  func activeGoals() -> [FinancialGoal] {
    return goalsByStatus(.active)
  }

  func completedGoals() -> [FinancialGoal] {
    return goalsByStatus(.completed)
  }

  func overdueGoals() -> [FinancialGoal] {
    return goals.filter { $0.isOverdue }
  }

  func goalsSortedByPriority() -> [FinancialGoal] {
    return goals.sorted {
      guard let priority1 = GoalPriority(rawValue: $0.priority),
        let priority2 = GoalPriority(rawValue: $1.priority)
      else {
        return false
      }
      return priority1.rawValue < priority2.rawValue
    }
  }

  func goalsSortedByDeadline() -> [FinancialGoal] {
    return goals.sorted { $0.targetDate < $1.targetDate }
  }

  func goalsSortedByProgress() -> [FinancialGoal] {
    return goals.sorted { $0.progressPercentage > $1.progressPercentage }
  }

  // MARK: - Goal Analytics

  func totalTargetAmount() -> Double {
    return goals.reduce(0) { $0 + $1.targetAmount }
  }

  func totalCurrentAmount() -> Double {
    return goals.reduce(0) { $0 + $1.currentAmount }
  }

  func overallProgressPercentage() -> Double {
    let totalTarget = totalTargetAmount()
    guard totalTarget > 0 else { return 0 }
    return (totalCurrentAmount() / totalTarget) * 100
  }

  func goalsCompletedThisMonth() -> Int {
    let calendar = Calendar.current
    let now = Date()
    let monthStart = calendar.dateInterval(of: .month, for: now)?.start ?? now

    return goals.filter { goal in
      guard goal.isCompleted,
        let completionDate = goal.completionDate
      else { return false }
      return completionDate >= monthStart
    }.count
  }

  func averageGoalProgress() -> Double {
    guard !goals.isEmpty else { return 0 }
    return goals.reduce(0) { $0 + $1.progressPercentage } / Double(goals.count)
  }

  func goalDistributionByCategory() -> [GoalCategoryDistribution] {
    let categoryGroups = Dictionary(grouping: goals) { $0.category }

    return categoryGroups.map { category, goals in
      let totalTarget = goals.reduce(0) { $0 + $1.targetAmount }
      let totalCurrent = goals.reduce(0) { $0 + $1.currentAmount }

      return GoalCategoryDistribution(
        category: GoalCategory(rawValue: category) ?? .other,
        goalCount: goals.count,
        totalTargetAmount: totalTarget,
        totalCurrentAmount: totalCurrent,
        progressPercentage: totalTarget > 0 ? (totalCurrent / totalTarget) * 100 : 0
      )
    }.sorted { $0.category.rawValue < $1.category.rawValue }
  }

  // MARK: - SMART Validation

  private func validateGoalParameters(
    title: String,
    targetAmount: Double,
    targetDate: Date,
    category: GoalCategory
  ) -> Result<Void, GoalError> {

    // Validate title (Specific)
    guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
      return .failure(.invalidTitle("Title cannot be empty"))
    }

    guard title.count >= 3 else {
      return .failure(.invalidTitle("Title must be at least 3 characters long"))
    }

    // Validate target amount (Measurable)
    guard targetAmount > 0 else {
      return .failure(.invalidAmount("Target amount must be positive"))
    }

    guard targetAmount <= 10_000_000 else {
      return .failure(.invalidAmount("Target amount cannot exceed $10,000,000 AUD"))
    }

    // Validate target date (Time-bound)
    let now = Date()
    let fiftyYearsFromNow = Calendar.current.date(byAdding: .year, value: 50, to: now) ?? now

    guard targetDate > now else {
      return .failure(.invalidDate("Target date must be in the future"))
    }

    guard targetDate <= fiftyYearsFromNow else {
      return .failure(.invalidDate("Target date cannot be more than 50 years in the future"))
    }

    // Validate category (Relevant)
    switch category {
    case .emergencyFund, .debtRepayment, .homePurchase, .retirement, .education, .travel,
      .investment, .other:
      break  // All valid categories
    }

    return .success(())
  }

  // MARK: - Private Methods

  private func loadGoals() {
    isLoading = true

    let request: NSFetchRequest<FinancialGoal> = FinancialGoal.fetchRequest()
    request.sortDescriptors = [
      NSSortDescriptor(keyPath: \FinancialGoal.createdAt, ascending: false)
    ]

    do {
      goals = try context.fetch(request)
      isLoading = false
    } catch {
      errorMessage = "Failed to load goals: \(error.localizedDescription)"
      isLoading = false
    }
  }

  private func setupNotifications() {
    // Setup notifications for goal deadlines, progress reminders, etc.
    // This would integrate with macOS notification system
  }
}

// MARK: - Supporting Models

enum GoalError: Error, LocalizedError {
  case invalidTitle(String)
  case invalidAmount(String)
  case invalidDate(String)
  case saveFailed(String)

  var errorDescription: String? {
    switch self {
    case .invalidTitle(let message):
      return message
    case .invalidAmount(let message):
      return message
    case .invalidDate(let message):
      return message
    case .saveFailed(let message):
      return message
    }
  }
}

enum GoalCategory: String, CaseIterable {
  case emergencyFund = "emergency_fund"
  case debtRepayment = "debt_repayment"
  case homePurchase = "home_purchase"
  case retirement = "retirement"
  case education = "education"
  case travel = "travel"
  case investment = "investment"
  case other = "other"

  var displayName: String {
    switch self {
    case .emergencyFund: return "Emergency Fund"
    case .debtRepayment: return "Debt Repayment"
    case .homePurchase: return "Home Purchase"
    case .retirement: return "Retirement"
    case .education: return "Education"
    case .travel: return "Travel"
    case .investment: return "Investment"
    case .other: return "Other"
    }
  }

  var icon: String {
    switch self {
    case .emergencyFund: return "shield"
    case .debtRepayment: return "creditcard"
    case .homePurchase: return "house"
    case .retirement: return "person.3"
    case .education: return "book"
    case .travel: return "airplane"
    case .investment: return "chart.line.uptrend.xyaxis"
    case .other: return "star"
    }
  }

  var color: String {
    switch self {
    case .emergencyFund: return "red"
    case .debtRepayment: return "orange"
    case .homePurchase: return "blue"
    case .retirement: return "purple"
    case .education: return "green"
    case .travel: return "teal"
    case .investment: return "indigo"
    case .other: return "gray"
    }
  }
}

enum GoalPriority: String, CaseIterable {
  case low = "low"
  case medium = "medium"
  case high = "high"
  case critical = "critical"

  var displayName: String {
    switch self {
    case .low: return "Low"
    case .medium: return "Medium"
    case .high: return "High"
    case .critical: return "Critical"
    }
  }

  var rawValue: Int {
    switch self {
    case .low: return 1
    case .medium: return 2
    case .high: return 3
    case .critical: return 4
    }
  }
}

enum GoalStatus: String, CaseIterable {
  case active = "active"
  case completed = "completed"
  case paused = "paused"
  case overdue = "overdue"
  case cancelled = "cancelled"

  var displayName: String {
    switch self {
    case .active: return "Active"
    case .completed: return "Completed"
    case .paused: return "Paused"
    case .overdue: return "Overdue"
    case .cancelled: return "Cancelled"
    }
  }

  var icon: String {
    switch self {
    case .active: return "play.circle"
    case .completed: return "checkmark.circle"
    case .paused: return "pause.circle"
    case .overdue: return "exclamationmark.circle"
    case .cancelled: return "xmark.circle"
    }
  }

  var color: String {
    switch self {
    case .active: return "blue"
    case .completed: return "green"
    case .paused: return "orange"
    case .overdue: return "red"
    case .cancelled: return "gray"
    }
  }
}

struct GoalCategoryDistribution: Identifiable {
  let id = UUID()
  let category: GoalCategory
  let goalCount: Int
  let totalTargetAmount: Double
  let totalCurrentAmount: Double
  let progressPercentage: Double
}
