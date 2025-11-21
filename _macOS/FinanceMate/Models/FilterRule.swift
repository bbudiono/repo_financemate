import Foundation

// MARK: - Filter Rule Model
// BLUEPRINT Line 136: Advanced Filtering Controls
// Supports multi-selection, date ranges, and rule-based filtering

struct FilterRule: Identifiable, Equatable {
    let id = UUID()
    var field: FilterField
    var operation: FilterOperation
    var value: String

    enum FilterField: String, CaseIterable {
        case merchant = "Merchant"
        case category = "Category"
        case amount = "Amount"
        case date = "Date"
        case source = "Source"
        case description = "Description"
    }

    enum FilterOperation: String, CaseIterable {
        case contains = "contains"
        case equals = "equals"
        case startsWith = "starts with"
        case endsWith = "ends with"
        case greaterThan = "greater than"
        case lessThan = "less than"
        case between = "between"

        var displayName: String { rawValue }

        static func operations(for field: FilterField) -> [FilterOperation] {
            switch field {
            case .merchant, .category, .source, .description:
                return [.contains, .equals, .startsWith, .endsWith]
            case .amount:
                return [.equals, .greaterThan, .lessThan, .between]
            case .date:
                return [.equals, .greaterThan, .lessThan, .between]
            }
        }
    }
}

// MARK: - Advanced Filter State
// Manages all filter criteria for transactions

struct AdvancedFilterState: Equatable {
    // Multi-select categories
    var selectedCategories: Set<String> = []

    // Date range
    var startDate: Date?
    var endDate: Date?

    // Amount range
    var minAmount: Double?
    var maxAmount: Double?

    // Rule-based filters
    var rules: [FilterRule] = []

    // Quick filters
    var showOnlyExpenses: Bool = false
    var showOnlyIncome: Bool = false

    var hasActiveFilters: Bool {
        !selectedCategories.isEmpty ||
        startDate != nil ||
        endDate != nil ||
        minAmount != nil ||
        maxAmount != nil ||
        !rules.isEmpty ||
        showOnlyExpenses ||
        showOnlyIncome
    }

    mutating func clearAll() {
        selectedCategories = []
        startDate = nil
        endDate = nil
        minAmount = nil
        maxAmount = nil
        rules = []
        showOnlyExpenses = false
        showOnlyIncome = false
    }
}

// MARK: - Predefined Categories
// Australian financial categories

enum TransactionCategory: String, CaseIterable {
    case groceries = "Groceries"
    case retail = "Retail"
    case utilities = "Utilities"
    case transport = "Transport"
    case dining = "Dining"
    case healthcare = "Healthcare"
    case entertainment = "Entertainment"
    case insurance = "Insurance"
    case education = "Education"
    case housing = "Housing"
    case income = "Income"
    case other = "Other"

    var icon: String {
        switch self {
        case .groceries: return "cart.fill"
        case .retail: return "bag.fill"
        case .utilities: return "bolt.fill"
        case .transport: return "car.fill"
        case .dining: return "fork.knife"
        case .healthcare: return "heart.fill"
        case .entertainment: return "film.fill"
        case .insurance: return "shield.fill"
        case .education: return "book.fill"
        case .housing: return "house.fill"
        case .income: return "dollarsign.circle.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }
}
