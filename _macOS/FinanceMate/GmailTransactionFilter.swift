import Foundation

// MARK: - Filter Enums

enum DateFilter {
    case allTime, today, thisWeek, thisMonth, last3Months, thisYear

    var displayName: String {
        switch self {
        case .allTime: return "All Time"
        case .today: return "Today"
        case .thisWeek: return "This Week"
        case .thisMonth: return "This Month"
        case .last3Months: return "Last 3 Months"
        case .thisYear: return "This Year"
        }
    }
}

enum AmountFilter {
    case any
    case under(Double)
    case range(Double, Double)
    case over(Double)

    var displayName: String {
        switch self {
        case .any: return "Any"
        case .under(let amount): return "Under $\(Int(amount))"
        case .range(let min, let max): return "$\(Int(min))-$\(Int(max))"
        case .over(let amount): return "Over $\(Int(amount))"
        }
    }
}

enum ConfidenceFilter {
    case any, high, medium, low

    var displayName: String {
        switch self {
        case .any: return "Any"
        case .high: return "High (≥80%)"
        case .medium: return "Medium (≥60%)"
        case .low: return "Low (<60%)"
        }
    }
}

// MARK: - Transaction Filtering Logic

struct GmailTransactionFilter {
    static func matches(
        transaction: ExtractedTransaction,
        searchText: String,
        dateFilter: DateFilter,
        merchantFilter: String?,
        categoryFilter: String?,
        amountFilter: AmountFilter,
        confidenceFilter: ConfidenceFilter
    ) -> Bool {
        // Search filter
        if !searchText.isEmpty {
            let matchesSearch = transaction.merchant.localizedCaseInsensitiveContains(searchText) ||
                              transaction.category.localizedCaseInsensitiveContains(searchText) ||
                              transaction.emailSubject.localizedCaseInsensitiveContains(searchText) ||
                              String(format: "%.2f", transaction.amount).contains(searchText)
            if !matchesSearch { return false }
        }

        // Date filter
        if !matchesDateFilter(transaction.date, filter: dateFilter) { return false }

        // Merchant filter
        if let merchant = merchantFilter, transaction.merchant != merchant { return false }

        // Category filter
        if let category = categoryFilter, transaction.category != category { return false }

        // Amount filter
        if !matchesAmountFilter(transaction.amount, filter: amountFilter) { return false }

        // Confidence filter
        if !matchesConfidenceFilter(transaction.confidence, filter: confidenceFilter) { return false }

        return true
    }

    private static func matchesDateFilter(_ date: Date, filter: DateFilter) -> Bool {
        let calendar = Calendar.current
        let now = Date()

        switch filter {
        case .allTime:
            return true
        case .today:
            return calendar.isDateInToday(date)
        case .thisWeek:
            return calendar.isDate(date, equalTo: now, toGranularity: .weekOfYear)
        case .thisMonth:
            return calendar.isDate(date, equalTo: now, toGranularity: .month)
        case .last3Months:
            if let threeMonthsAgo = calendar.date(byAdding: .month, value: -3, to: now) {
                return date >= threeMonthsAgo
            }
            return true
        case .thisYear:
            return calendar.isDate(date, equalTo: now, toGranularity: .year)
        }
    }

    private static func matchesAmountFilter(_ amount: Double, filter: AmountFilter) -> Bool {
        switch filter {
        case .any:
            return true
        case .under(let max):
            return amount < max
        case .range(let min, let max):
            return amount >= min && amount <= max
        case .over(let min):
            return amount > min
        }
    }

    private static func matchesConfidenceFilter(_ confidence: Double, filter: ConfidenceFilter) -> Bool {
        switch filter {
        case .any:
            return true
        case .high:
            return confidence >= 0.8
        case .medium:
            return confidence >= 0.6 && confidence < 0.8
        case .low:
            return confidence < 0.6
        }
    }
}
