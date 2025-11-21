import SwiftUI
import CoreData

// BLUEPRINT Lines 73-75: ViewModel for managing transaction table state
class TransactionsViewModel: ObservableObject {
    @Published var selectedIDs: Set<UUID> = []
    @Published var searchText: String = ""
    @Published var selectedSource: String? = nil
    @Published var selectedCategory: String? = nil
    @Published var sortOption: SortOption = .dateDescending

    // BLUEPRINT Line 136: Advanced Filtering Controls
    @Published var advancedFilter = AdvancedFilterState()
    @Published var showAdvancedFilters: Bool = false

    private var viewContext: NSManagedObjectContext
    private var allTransactions: [Transaction] = []

    enum SortOption {
        case dateDescending, dateAscending, amountDescending, amountAscending, categoryAZ
    }

    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
    }

    // BLUEPRINT Line 73: Filterable, searchable, sortable
    var filteredTransactions: [Transaction] {
        var result = allTransactions

        // Search
        if !searchText.isEmpty {
            result = result.filter {
                $0.itemDescription.localizedCaseInsensitiveContains(searchText) ||
                $0.category.localizedCaseInsensitiveContains(searchText)
            }
        }

        // Filter by source
        if let source = selectedSource {
            result = result.filter { $0.source == source }
        }

        // Filter by single category (legacy)
        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }

        // BLUEPRINT Line 136: Advanced filtering
        result = applyAdvancedFilters(to: result)

        // Sort
        switch sortOption {
        case .dateDescending: result.sort { $0.date > $1.date }
        case .dateAscending: result.sort { $0.date < $1.date }
        case .amountDescending: result.sort { $0.amount > $1.amount }
        case .amountAscending: result.sort { $0.amount < $1.amount }
        case .categoryAZ: result.sort { $0.category < $1.category }
        }

        return result
    }

    // BLUEPRINT Line 136: Apply advanced filtering rules
    private func applyAdvancedFilters(to transactions: [Transaction]) -> [Transaction] {
        var result = transactions

        // Multi-select categories
        if !advancedFilter.selectedCategories.isEmpty {
            result = result.filter { advancedFilter.selectedCategories.contains($0.category) }
        }

        // Date range
        if let startDate = advancedFilter.startDate {
            result = result.filter { $0.date >= startDate }
        }
        if let endDate = advancedFilter.endDate {
            result = result.filter { $0.date <= endDate }
        }

        // Amount range
        if let minAmount = advancedFilter.minAmount {
            result = result.filter { abs($0.amount) >= minAmount }
        }
        if let maxAmount = advancedFilter.maxAmount {
            result = result.filter { abs($0.amount) <= maxAmount }
        }

        // Quick filters
        if advancedFilter.showOnlyExpenses {
            result = result.filter { $0.amount < 0 }
        }
        if advancedFilter.showOnlyIncome {
            result = result.filter { $0.amount > 0 }
        }

        // Rule-based filters
        for rule in advancedFilter.rules {
            result = applyRule(rule, to: result)
        }

        return result
    }

    private func applyRule(_ rule: FilterRule, to transactions: [Transaction]) -> [Transaction] {
        transactions.filter { transaction in
            let fieldValue: String
            switch rule.field {
            case .merchant: fieldValue = transaction.itemDescription
            case .category: fieldValue = transaction.category
            case .description: fieldValue = transaction.itemDescription
            case .source: fieldValue = transaction.source ?? ""
            case .amount: fieldValue = String(transaction.amount)
            case .date: fieldValue = ISO8601DateFormatter().string(from: transaction.date)
            }

            switch rule.operation {
            case .contains:
                return fieldValue.localizedCaseInsensitiveContains(rule.value)
            case .equals:
                return fieldValue.lowercased() == rule.value.lowercased()
            case .startsWith:
                return fieldValue.lowercased().hasPrefix(rule.value.lowercased())
            case .endsWith:
                return fieldValue.lowercased().hasSuffix(rule.value.lowercased())
            case .greaterThan:
                if let ruleAmount = Double(rule.value) {
                    return abs(transaction.amount) > ruleAmount
                }
                return true
            case .lessThan:
                if let ruleAmount = Double(rule.value) {
                    return abs(transaction.amount) < ruleAmount
                }
                return true
            case .between:
                // Format: "min,max"
                let parts = rule.value.split(separator: ",")
                if parts.count == 2,
                   let min = Double(parts[0]),
                   let max = Double(parts[1]) {
                    let amount = abs(transaction.amount)
                    return amount >= min && amount <= max
                }
                return true
            }
        }
    }

    // BLUEPRINT Line 136: Add filter rule
    func addFilterRule(_ rule: FilterRule) {
        advancedFilter.rules.append(rule)
        objectWillChange.send()
    }

    func removeFilterRule(_ rule: FilterRule) {
        advancedFilter.rules.removeAll { $0.id == rule.id }
        objectWillChange.send()
    }

    func clearAdvancedFilters() {
        advancedFilter.clearAll()
        objectWillChange.send()
    }

    func toggleCategory(_ category: String) {
        if advancedFilter.selectedCategories.contains(category) {
            advancedFilter.selectedCategories.remove(category)
        } else {
            advancedFilter.selectedCategories.insert(category)
        }
        objectWillChange.send()
    }

    func updateTransactions(_ transactions: [Transaction]) {
        self.allTransactions = transactions
        objectWillChange.send()
    }

    func updateSort(_ sortOrder: [KeyPathComparator<Transaction>]) {
        // Handle sort order changes from Table
        objectWillChange.send()
    }

    func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }

    func deleteTransactions(at offsets: IndexSet) {
        for index in offsets {
            let transaction = filteredTransactions[index]
            viewContext.delete(transaction)
        }
        saveContext()
    }

    // Delete single transaction (for quick action button)
    func deleteTransaction(_ transaction: Transaction) {
        viewContext.delete(transaction)
        saveContext()
        objectWillChange.send()
    }
}
