import Foundation
import CoreData

/*
 * Purpose: Core Data managed object class for FinancialGoal with SMART validation and Australian compliance
 * Issues & Complexity Summary: SMART goal validation logic, progress calculations, Australian currency formatting
 * Key Complexity Drivers:
   - Logic Scope (Est. LoC): ~250
   - Core Algorithm Complexity: High (SMART validation, progress calculations, currency formatting)
   - Dependencies: Core Data, Foundation, Australian locale formatting
   - State Management Complexity: Medium (goal state tracking, milestone relationships)
   - Novelty/Uncertainty Factor: Medium (SMART validation criteria, behavioral finance patterns)
 * AI Pre-Task Self-Assessment: 85%
 * Problem Estimate: 88%
 * Initial Code Complexity Estimate: 90%
 * Final Code Complexity: [TBD]
 * Overall Result Score: [TBD]
 * Key Variances/Learnings: [TBD]
 * Last Updated: 2025-07-11
 */

@objc(FinancialGoal)
public class FinancialGoal: NSManagedObject {
    
    // MARK: - CRUD Operations
    
    static func create(
        in context: NSManagedObjectContext,
        title: String,
        description: String?,
        targetAmount: Double,
        category: GoalCategory,
        deadline: Date
    ) -> FinancialGoal {
        guard let entity = NSEntityDescription.entity(forEntityName: "FinancialGoal", in: context) else {
            fatalError("FinancialGoal entity not found in the provided context")
        }
        
        let goal = FinancialGoal(entity: entity, insertInto: context)
        goal.id = UUID()
        goal.title = title
        goal.goalDescription = description
        goal.targetAmount = targetAmount
        goal.currentAmount = 0.0
        goal.targetDate = deadline
        goal.category = category.rawValue
        goal.priority = "medium" // Default priority
        goal.createdAt = Date()
        goal.lastModified = Date()
        goal.isAchieved = false
        
        return goal
    }
    
    // MARK: - Progress Calculations
    
    func calculateProgress() -> Double {
        guard targetAmount > 0 else { return 0.0 }
        let progress = currentAmount / targetAmount
        return min(max(progress, 0.0), 1.0) // Clamp between 0 and 1
    }
    
    func progressPercentage() -> Double {
        return calculateProgress() * 100.0
    }
    
    func remainingAmount() -> Double {
        return max(targetAmount - currentAmount, 0.0)
    }
    
    // MARK: - SMART Goal Validation
    
    func isSpecific() -> Bool {
        // A goal is specific if it has:
        // 1. Clear title with meaningful content (not just generic words)
        // 2. Specific target amount (not rounded numbers like 10000, 50000)
        // 3. Detailed description explaining the purpose
        
        guard let title = self.title, !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return false
        }
        
        // Check for specific amount (not just round numbers)
        let isSpecificAmount = !isRoundNumber(targetAmount)
        
        // Check for meaningful title length and content
        let hasMeaningfulTitle = title.count >= 10 && title.lowercased().contains("$") || title.lowercased().contains("save") || title.lowercased().contains("emergency") || title.lowercased().contains("invest")
        
        // Check for description
        let hasDescription = goalDescription != nil && !goalDescription!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        return hasMeaningfulTitle || isSpecificAmount || hasDescription
    }
    
    func isMeasurable() -> Bool {
        // Measurable: Has specific target amount and trackable progress
        return targetAmount > 0
    }
    
    func isAchievable() -> Bool {
        // Achievable: Target amount is reasonable (not impossibly high)
        // For Australian context: reasonable goals under $10M AUD
        return targetAmount > 0 && targetAmount <= 10_000_000
    }
    
    func isRelevant() -> Bool {
        // Relevant: Has appropriate category and reasonable timeframe
        guard let categoryValue = category else { return false }
        let validCategories = GoalCategory.allCases.map { $0.rawValue }
        return validCategories.contains(categoryValue)
    }
    
    func isTimeBound() -> Bool {
        // Time-bound: Has deadline in the future (but not too far)
        let now = Date()
        let maxFutureDate = Calendar.current.date(byAdding: .year, value: 50, to: now) ?? now
        return targetDate > now && targetDate <= maxFutureDate
    }
    
    func validateSMART() -> SMARTValidationResult {
        return SMARTValidationResult(
            specific: isSpecific(),
            measurable: isMeasurable(),
            achievable: isAchievable(),
            relevant: isRelevant(),
            timeBound: isTimeBound()
        )
    }
    
    func isSMARTCompliant() -> Bool {
        let validation = validateSMART()
        return validation.isFullyCompliant
    }
    
    // MARK: - Australian Currency Formatting
    
    func formattedTargetAmount() -> String {
        return formatAustralianCurrency(targetAmount)
    }
    
    func formattedCurrentAmount() -> String {
        return formatAustralianCurrency(currentAmount)
    }
    
    func formattedRemainingAmount() -> String {
        return formatAustralianCurrency(remainingAmount())
    }
    
    private func formatAustralianCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_AU")
        formatter.currencyCode = "AUD"
        
        return formatter.string(from: NSNumber(value: amount)) ?? "A$0.00"
    }
    
    // MARK: - Date and Timeline Calculations
    
    func daysRemaining() -> Int {
        let calendar = Calendar.current
        let now = Date()
        let days = calendar.dateComponents([.day], from: now, to: targetDate).day ?? 0
        return max(days, 0)
    }
    
    func timelineStatus() -> GoalTimelineStatus {
        let days = daysRemaining()
        let progress = calculateProgress()
        
        if isAchieved {
            return .achieved
        } else if days <= 0 {
            return .overdue
        } else if days <= 30 {
            return .urgent
        } else if progress >= 0.8 {
            return .onTrack
        } else {
            return .needsAttention
        }
    }
    
    // MARK: - Helper Methods
    
    private func isRoundNumber(_ amount: Double) -> Bool {
        // Check if amount is a round number (like 10000, 50000, 100000)
        let roundNumbers: [Double] = [1000, 5000, 10000, 20000, 25000, 50000, 75000, 100000, 250000, 500000, 1000000]
        return roundNumbers.contains(amount)
    }
    
    // MARK: - Computed Properties for UI
    
    var displayCategory: String {
        return GoalCategory(rawValue: category ?? "")?.displayName ?? "Unknown"
    }
    
    var isCompleted: Bool {
        return isAchieved || calculateProgress() >= 1.0
    }
    
    var progressDescription: String {
        let percentage = Int(progressPercentage())
        return "\(percentage)% complete"
    }
}

// MARK: - Supporting Types

enum GoalCategory: String, CaseIterable {
    case savings = "savings"
    case investment = "investment"
    case debtReduction = "debt_reduction"
    case emergencyFund = "emergency_fund"
    
    var displayName: String {
        switch self {
        case .savings: return "Savings"
        case .investment: return "Investment"
        case .debtReduction: return "Debt Reduction"
        case .emergencyFund: return "Emergency Fund"
        }
    }
    
    var icon: String {
        switch self {
        case .savings: return "banknote"
        case .investment: return "chart.line.uptrend.xyaxis"
        case .debtReduction: return "creditcard"
        case .emergencyFund: return "shield.fill"
        }
    }
}

enum GoalTimelineStatus {
    case onTrack
    case needsAttention
    case urgent
    case overdue
    case achieved
    
    var color: String {
        switch self {
        case .onTrack: return "green"
        case .needsAttention: return "yellow"
        case .urgent: return "orange"
        case .overdue: return "red"
        case .achieved: return "blue"
        }
    }
    
    var description: String {
        switch self {
        case .onTrack: return "On Track"
        case .needsAttention: return "Needs Attention"
        case .urgent: return "Urgent"
        case .overdue: return "Overdue"
        case .achieved: return "Achieved"
        }
    }
}

struct SMARTValidationResult {
    let specific: Bool
    let measurable: Bool
    let achievable: Bool
    let relevant: Bool
    let timeBound: Bool
    
    var isFullyCompliant: Bool {
        return specific && measurable && achievable && relevant && timeBound
    }
    
    var complianceScore: Double {
        let trueCount = [specific, measurable, achievable, relevant, timeBound].filter { $0 }.count
        return Double(trueCount) / 5.0
    }
    
    var missingCriteria: [String] {
        var missing: [String] = []
        if !specific { missing.append("Specific") }
        if !measurable { missing.append("Measurable") }
        if !achievable { missing.append("Achievable") }
        if !relevant { missing.append("Relevant") }
        if !timeBound { missing.append("Time-bound") }
        return missing
    }
}