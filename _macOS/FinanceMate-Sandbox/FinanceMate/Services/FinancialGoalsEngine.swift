import Foundation
import SwiftUI

// MARK: - Financial Goals Engine

@Observable
public class FinancialGoalsEngine {
    // MARK: - Properties

    public var isLoading = false
    public var activeGoals: [FinancialGoal] = []
    public var completedGoals: [FinancialGoal] = []
    public var goalAchievements: [GoalAchievement] = []

    // MARK: - Goal Management

    public func createGoal(
        name: String,
        targetAmount: Double,
        currentAmount: Double = 0,
        targetDate: Date,
        category: GoalCategory
    ) -> FinancialGoal {
        let goal = FinancialGoal(
            id: UUID(),
            name: name,
            targetAmount: targetAmount,
            currentAmount: currentAmount,
            targetDate: targetDate,
            category: category,
            createdDate: Date(),
            milestones: generateMilestones(targetAmount: targetAmount)
        )

        activeGoals.append(goal)
        return goal
    }

    public func updateGoalProgress(_ goalId: UUID, newAmount: Double) {
        guard let index = activeGoals.firstIndex(where: { $0.id == goalId }) else { return }

        let oldAmount = activeGoals[index].currentAmount
        activeGoals[index].currentAmount = newAmount
        activeGoals[index].lastUpdated = Date()

        // Check for milestone achievements
        checkMilestoneAchievements(for: activeGoals[index], oldAmount: oldAmount)

        // Check if goal is completed
        if newAmount >= activeGoals[index].targetAmount {
            completeGoal(goalId)
        }
    }

    public func deleteGoal(_ goalId: UUID) {
        activeGoals.removeAll { $0.id == goalId }
        completedGoals.removeAll { $0.id == goalId }
    }

    // MARK: - Goal Analytics

    public func calculateGoalProgress(_ goal: FinancialGoal) -> GoalProgress {
        let progressPercentage = min(goal.currentAmount / goal.targetAmount * 100, 100)
        let remainingAmount = max(goal.targetAmount - goal.currentAmount, 0)
        let daysRemaining = max(Calendar.current.dateComponents([.day], from: Date(), to: goal.targetDate).day ?? 0, 0)

        let dailySavingsNeeded = daysRemaining > 0 ? remainingAmount / Double(daysRemaining) : 0

        return GoalProgress(
            goalId: goal.id,
            progressPercentage: progressPercentage,
            remainingAmount: remainingAmount,
            daysRemaining: daysRemaining,
            dailySavingsNeeded: dailySavingsNeeded,
            isOnTrack: isGoalOnTrack(goal),
            nextMilestone: getNextMilestone(for: goal)
        )
    }

    public func generateGoalInsights(_ goal: FinancialGoal) -> [GoalInsight] {
        var insights: [GoalInsight] = []
        let progress = calculateGoalProgress(goal)

        // Progress insights
        if progress.progressPercentage >= 75 {
            insights.append(GoalInsight(
                type: .achievement,
                title: "Great Progress!",
                message: "You're \(String(format: "%.1f", progress.progressPercentage))% towards your goal",
                priority: .medium
            ))
        } else if progress.progressPercentage < 25 {
            insights.append(GoalInsight(
                type: .warning,
                title: "Boost Your Savings",
                message: "Consider increasing your monthly contributions to stay on track",
                priority: .high
            ))
        }

        // Time-based insights
        if progress.daysRemaining <= 30 && progress.progressPercentage < 90 {
            insights.append(GoalInsight(
                type: .urgency,
                title: "Goal Deadline Approaching",
                message: "Save $\(String(format: "%.2f", progress.dailySavingsNeeded)) daily to reach your goal",
                priority: .high
            ))
        }

        // Milestone insights
        if let nextMilestone = progress.nextMilestone {
            let amountToMilestone = nextMilestone.targetAmount - goal.currentAmount
            insights.append(GoalInsight(
                type: .milestone,
                title: "Next Milestone",
                message: "Save $\(String(format: "%.2f", amountToMilestone)) to reach \(nextMilestone.name)",
                priority: .medium
            ))
        }

        return insights
    }

    // MARK: - Private Methods

    private func generateMilestones(targetAmount: Double) -> [GoalMilestone] {
        let milestonePercentages = [0.25, 0.5, 0.75, 1.0]
        return milestonePercentages.map { percentage in
            GoalMilestone(
                id: UUID(),
                name: "\(Int(percentage * 100))% Complete",
                targetAmount: targetAmount * percentage,
                isAchieved: false,
                achievedDate: nil
            )
        }
    }

    private func checkMilestoneAchievements(for goal: FinancialGoal, oldAmount: Double) {
        guard let index = activeGoals.firstIndex(where: { $0.id == goal.id }) else { return }

        for milestoneIndex in activeGoals[index].milestones.indices {
            let milestone = activeGoals[index].milestones[milestoneIndex]

            if !milestone.isAchieved &&
               oldAmount < milestone.targetAmount &&
               goal.currentAmount >= milestone.targetAmount {
                // Mark milestone as achieved
                activeGoals[index].milestones[milestoneIndex].isAchieved = true
                activeGoals[index].milestones[milestoneIndex].achievedDate = Date()

                // Create achievement record
                let achievement = GoalAchievement(
                    id: UUID(),
                    goalId: goal.id,
                    goalName: goal.name,
                    type: .milestone,
                    title: milestone.name,
                    description: "Reached $\(String(format: "%.2f", milestone.targetAmount))",
                    achievedDate: Date()
                )

                goalAchievements.append(achievement)
            }
        }
    }

    private func completeGoal(_ goalId: UUID) {
        guard let index = activeGoals.firstIndex(where: { $0.id == goalId }) else { return }

        let completedGoal = activeGoals[index]
        activeGoals.remove(at: index)
        completedGoals.append(completedGoal)

        // Create completion achievement
        let achievement = GoalAchievement(
            id: UUID(),
            goalId: completedGoal.id,
            goalName: completedGoal.name,
            type: .completion,
            title: "Goal Completed!",
            description: "Successfully saved $\(String(format: "%.2f", completedGoal.targetAmount))",
            achievedDate: Date()
        )

        goalAchievements.append(achievement)
    }

    private func isGoalOnTrack(_ goal: FinancialGoal) -> Bool {
        let daysTotal = Calendar.current.dateComponents([.day], from: goal.createdDate, to: goal.targetDate).day ?? 1
        let daysPassed = Calendar.current.dateComponents([.day], from: goal.createdDate, to: Date()).day ?? 0

        let expectedProgress = Double(daysPassed) / Double(daysTotal)
        let actualProgress = goal.currentAmount / goal.targetAmount

        return actualProgress >= expectedProgress * 0.9 // 90% of expected progress
    }

    private func getNextMilestone(for goal: FinancialGoal) -> GoalMilestone? {
        goal.milestones.first { !$0.isAchieved && $0.targetAmount > goal.currentAmount }
    }
}

// MARK: - Supporting Models

public struct FinancialGoal: Identifiable {
    public let id: UUID
    public let name: String
    public let targetAmount: Double
    public var currentAmount: Double
    public let targetDate: Date
    public let category: GoalCategory
    public let createdDate: Date
    public var milestones: [GoalMilestone]
    public var lastUpdated = Date()

    public var progressPercentage: Double {
        min(currentAmount / targetAmount * 100, 100)
    }
}

public struct GoalMilestone: Identifiable {
    public let id: UUID
    public let name: String
    public let targetAmount: Double
    public var isAchieved: Bool
    public var achievedDate: Date?
}

public struct GoalProgress {
    public let goalId: UUID
    public let progressPercentage: Double
    public let remainingAmount: Double
    public let daysRemaining: Int
    public let dailySavingsNeeded: Double
    public let isOnTrack: Bool
    public let nextMilestone: GoalMilestone?
}

public struct GoalAchievement: Identifiable {
    public let id: UUID
    public let goalId: UUID
    public let goalName: String
    public let type: AchievementType
    public let title: String
    public let description: String
    public let achievedDate: Date
}

public struct GoalInsight {
    public let type: InsightType
    public let title: String
    public let message: String
    public let priority: InsightPriority
}

public enum GoalCategory: String, CaseIterable {
    case emergency = "Emergency Fund"
    case vacation = "Vacation"
    case house = "House Down Payment"
    case car = "Car Purchase"
    case education = "Education"
    case retirement = "Retirement"
    case investment = "Investment"
    case other = "Other"

    public var icon: String {
        switch self {
        case .emergency: return "shield.fill"
        case .vacation: return "airplane"
        case .house: return "house.fill"
        case .car: return "car.fill"
        case .education: return "graduationcap.fill"
        case .retirement: return "calendar"
        case .investment: return "chart.line.uptrend.xyaxis"
        case .other: return "target"
        }
    }

    public var color: Color {
        switch self {
        case .emergency: return .red
        case .vacation: return .blue
        case .house: return .green
        case .car: return .orange
        case .education: return .purple
        case .retirement: return .indigo
        case .investment: return .mint
        case .other: return .gray
        }
    }
}

public enum AchievementType {
    case milestone
    case completion
    case streak
}

public enum InsightType {
    case achievement
    case warning
    case urgency
    case milestone
    case suggestion
}

public enum InsightPriority {
    case low
    case medium
    case high
}
