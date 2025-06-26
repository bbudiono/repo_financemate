import CoreData
import Foundation
import SwiftUI

@objc(Budget)
public class Budget: NSManagedObject {
    // MARK: - Computed Properties

    public var budgetTypeEnum: BudgetType {
        get {
            BudgetType(rawValue: budgetType ?? "monthly") ?? .monthly
        }
        set {
            budgetType = newValue.rawValue
        }
    }

    public var totalBudgeted: Double {
        totalAmount?.doubleValue ?? 0.0
    }

    public var totalSpent: Double {
        guard let categories = categories?.allObjects as? [BudgetCategory] else { return 0.0 }
        return categories.reduce(0.0) { total, category in
            total + (category.spentAmount?.doubleValue ?? 0.0)
        }
    }

    public var remainingAmount: Double {
        totalBudgeted - totalSpent
    }

    public var spendingPercentage: Double {
        guard totalBudgeted > 0 else { return 0.0 }
        return (totalSpent / totalBudgeted) * 100.0
    }

    public var isOverBudget: Bool {
        totalSpent > totalBudgeted
    }

    public var progressColor: Color {
        let percentage = spendingPercentage
        if percentage > 100 {
            return .red
        } else if percentage > 80 {
            return .orange
        } else if percentage > 60 {
            return .yellow
        } else {
            return .green
        }
    }

    public var daysRemaining: Int {
        guard let endDate = endDate else { return 0 }
        let calendar = Calendar.current
        return calendar.dateComponents([.day], from: Date(), to: endDate).day ?? 0
    }

    public var isActiveComputed: Bool {
        guard let startDate = startDate, let endDate = endDate else { return false }
        let now = Date()
        return isActive && now >= startDate && now <= endDate
    }
}

// MARK: - Budget Type Enum

public enum BudgetType: String, CaseIterable {
    case weekly = "weekly"
    case monthly = "monthly"
    case yearly = "yearly"
    case custom = "custom"
    case project = "project"

    public var displayName: String {
        switch self {
        case .weekly: return "Weekly"
        case .monthly: return "Monthly"
        case .yearly: return "Yearly"
        case .custom: return "Custom"
        case .project: return "Project"
        }
    }

    public var icon: String {
        switch self {
        case .weekly: return "calendar.day.timeline.left"
        case .monthly: return "calendar"
        case .yearly: return "calendar.badge.plus"
        case .custom: return "slider.horizontal.3"
        case .project: return "folder.badge.gearshape"
        }
    }

    public var defaultDuration: TimeInterval {
        switch self {
        case .weekly: return 7 * 24 * 60 * 60 // 7 days
        case .monthly: return 30 * 24 * 60 * 60 // 30 days
        case .yearly: return 365 * 24 * 60 * 60 // 365 days
        case .custom, .project: return 30 * 24 * 60 * 60 // Default to 30 days
        }
    }
}
