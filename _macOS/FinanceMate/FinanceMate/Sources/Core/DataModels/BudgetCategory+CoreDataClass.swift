import CoreData
import Foundation
import SwiftUI

@objc(BudgetCategory)
public class BudgetCategory: NSManagedObject {
    // MARK: - Computed Properties

    public var categoryTypeEnum: BudgetCategoryType {
        get {
            BudgetCategoryType(rawValue: categoryType ?? "miscellaneous") ?? .miscellaneous
        }
        set {
            categoryType = newValue.rawValue
        }
    }

    public var spentPercentage: Double {
        let budgeted = budgetedAmount?.doubleValue ?? 0.0
        let spent = spentAmount?.doubleValue ?? 0.0
        guard budgeted > 0 else { return 0.0 }
        return (spent / budgeted) * 100.0
    }

    public var remainingAmount: Double {
        let budgeted = budgetedAmount?.doubleValue ?? 0.0
        let spent = spentAmount?.doubleValue ?? 0.0
        return budgeted - spent
    }

    public var isOverBudget: Bool {
        let budgeted = budgetedAmount?.doubleValue ?? 0.0
        let spent = spentAmount?.doubleValue ?? 0.0
        return spent > budgeted
    }

    public var shouldAlert: Bool {
        spentPercentage >= alertThreshold && !isOverBudget
    }

    public var statusColor: Color {
        if isOverBudget {
            return .red
        } else if shouldAlert {
            return .orange
        } else if spentPercentage > 50 {
            return .yellow
        } else {
            return .green
        }
    }

    public var colorValue: Color {
        if let colorHex = colorHex {
            return Color(hex: colorHex) ?? categoryTypeEnum.defaultColor
        }
        return categoryTypeEnum.defaultColor
    }
}

// MARK: - Budget Category Type Enum

public enum BudgetCategoryType: String, CaseIterable {
    case housing = "housing"
    case food = "food"
    case transportation = "transportation"
    case healthcare = "healthcare"
    case insurance = "insurance"
    case savings = "savings"
    case education = "education"
    case entertainment = "entertainment"
    case shopping = "shopping"
    case utilities = "utilities"
    case miscellaneous = "miscellaneous"

    public var displayName: String {
        switch self {
        case .housing: return "Housing"
        case .food: return "Food & Dining"
        case .transportation: return "Transportation"
        case .healthcare: return "Healthcare"
        case .insurance: return "Insurance"
        case .savings: return "Savings"
        case .education: return "Education"
        case .entertainment: return "Entertainment"
        case .shopping: return "Shopping"
        case .utilities: return "Utilities"
        case .miscellaneous: return "Miscellaneous"
        }
    }

    public var icon: String {
        switch self {
        case .housing: return "house.fill"
        case .food: return "fork.knife"
        case .transportation: return "car.fill"
        case .healthcare: return "cross.case.fill"
        case .insurance: return "shield.lefthalf.filled"
        case .savings: return "banknote.fill"
        case .education: return "graduationcap.fill"
        case .entertainment: return "tv.fill"
        case .shopping: return "bag.fill"
        case .utilities: return "bolt.fill"
        case .miscellaneous: return "ellipsis.circle.fill"
        }
    }

    public var defaultColor: Color {
        switch self {
        case .housing: return .blue
        case .food: return .orange
        case .transportation: return .green
        case .healthcare: return .red
        case .insurance: return .purple
        case .savings: return .mint
        case .education: return .indigo
        case .entertainment: return .pink
        case .shopping: return .brown
        case .utilities: return .yellow
        case .miscellaneous: return .gray
        }
    }
}

// MARK: - Color Extension for Hex Support

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        if hexSanitized.count == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
        } else if hexSanitized.count == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0
        } else {
            return nil
        }

        self.init(red: r, green: g, blue: b, opacity: a)
    }
}
