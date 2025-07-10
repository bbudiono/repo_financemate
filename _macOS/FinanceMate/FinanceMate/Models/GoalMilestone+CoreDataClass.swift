import Foundation
import CoreData

/*
 * Purpose: Core Data managed object class for GoalMilestone with progress tracking and achievement validation
 * Issues & Complexity Summary: Milestone achievement tracking, percentage calculations, target date validation
 * Key Complexity Drivers:
   - Logic Scope (Est. LoC): ~150
   - Core Algorithm Complexity: Medium (milestone validation, progress tracking)
   - Dependencies: Core Data, Foundation, FinancialGoal relationships
   - State Management Complexity: Medium (milestone-goal relationships, achievement status)
   - Novelty/Uncertainty Factor: Low (standard milestone tracking patterns)
 * AI Pre-Task Self-Assessment: 90%
 * Problem Estimate: 85%
 * Initial Code Complexity Estimate: 80%
 * Final Code Complexity: [TBD]
 * Overall Result Score: [TBD]
 * Key Variances/Learnings: [TBD]
 * Last Updated: 2025-07-11
 */

@objc(GoalMilestone)
public class GoalMilestone: NSManagedObject {
    
    // MARK: - CRUD Operations
    
    static func create(
        in context: NSManagedObjectContext,
        goal: FinancialGoal,
        title: String,
        targetDate: Date,
        targetAmount: Double
    ) -> GoalMilestone {
        guard let entity = NSEntityDescription.entity(forEntityName: "GoalMilestone", in: context) else {
            fatalError("GoalMilestone entity not found in the provided context")
        }
        
        let milestone = GoalMilestone(entity: entity, insertInto: context)
        milestone.id = UUID()
        milestone.title = title
        milestone.targetDate = targetDate
        milestone.targetAmount = targetAmount
        milestone.isAchieved = false
        milestone.createdAt = Date()
        milestone.goal = goal
        
        return milestone
    }
    
    // MARK: - Progress and Achievement
    
    func checkAchievement() -> Bool {
        guard let parentGoal = goal else { return false }
        let achieved = parentGoal.currentAmount >= targetAmount
        
        if achieved && !isAchieved {
            isAchieved = true
            achievedDate = Date()
        }
        
        return achieved
    }
    
    func progressTowardsTarget() -> Double {
        guard let parentGoal = goal, targetAmount > 0 else { return 0.0 }
        let progress = parentGoal.currentAmount / targetAmount
        return min(max(progress, 0.0), 1.0) // Clamp between 0 and 1
    }
    
    func progressPercentage() -> Double {
        return progressTowardsTarget() * 100.0
    }
    
    // MARK: - Validation
    
    func isValidMilestone() -> Bool {
        guard let parentGoal = goal else { return false }
        
        // Milestone should be achievable before the goal's target date
        let isBeforeGoalDate = targetDate <= parentGoal.targetDate
        
        // Target amount should be reasonable (not more than the goal)
        let isReasonableAmount = targetAmount > 0 && targetAmount <= parentGoal.targetAmount
        
        // Should have meaningful title
        let hasMeaningfulTitle = !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        return isBeforeGoalDate && isReasonableAmount && hasMeaningfulTitle
    }
    
    // MARK: - Timeline Status
    
    func timelineStatus() -> MilestoneTimelineStatus {
        if isAchieved {
            return .achieved
        }
        
        let now = Date()
        let daysUntilTarget = Calendar.current.dateComponents([.day], from: now, to: targetDate).day ?? 0
        
        if daysUntilTarget < 0 {
            return .overdue
        } else if daysUntilTarget <= 7 {
            return .urgent
        } else if progressTowardsTarget() >= 0.8 {
            return .onTrack
        } else {
            return .needsAttention
        }
    }
    
    // MARK: - Computed Properties
    
    var formattedTargetAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_AU")
        formatter.currencyCode = "AUD"
        return formatter.string(from: NSNumber(value: targetAmount)) ?? "A$0.00"
    }
    
    var daysUntilTarget: Int {
        let calendar = Calendar.current
        let now = Date()
        let days = calendar.dateComponents([.day], from: now, to: targetDate).day ?? 0
        return max(days, 0)
    }
    
    var goalId: UUID? {
        return goal?.id
    }
    
    var progressDescription: String {
        if isAchieved {
            return "Achieved"
        } else {
            let percentage = Int(progressPercentage())
            return "\(percentage)% complete"
        }
    }
}

// MARK: - Supporting Types

enum MilestoneTimelineStatus {
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