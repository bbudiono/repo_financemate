import Foundation

/**
 * Purpose: Extract filtering/sorting logic from TransactionsViewModel to reduce complexity
 * BLUEPRINT Lines 73-75, 102-110: Filterable, searchable, sortable transaction management
 * Complexity: Low - Single responsibility service for transaction filtering
 * Last Updated: 2025-10-09
 */

/// Service for filtering and sorting transactions (reduces ViewModel complexity)
class TransactionFilterService {

    /// Apply search filter to transactions
    static func applySearchFilter(_ transactions: [Transaction], searchText: String) -> [Transaction] {
        guard !searchText.isEmpty else { return transactions }
        return transactions.filter {
            $0.itemDescription.localizedCaseInsensitiveContains(searchText) ||
            $0.category.localizedCaseInsensitiveContains(searchText)
        }
    }

    /// Apply source and category filters
    static func applySourceAndCategoryFilters(_ transactions: [Transaction], source: String?, category: String?) -> [Transaction] {
        var result = transactions
        if let source = source {
            result = result.filter { $0.source == source }
        }
        if let category = category {
            result = result.filter { $0.category == category }
        }
        return result
    }

    /// Apply sorting based on sort option
    static func applySorting(_ transactions: [Transaction], sortOption: TransactionSortOption) -> [Transaction] {
        var result = transactions
        switch sortOption {
        case .dateDescending: result.sort { $0.date > $1.date }
        case .dateAscending: result.sort { $0.date < $1.date }
        case .amountDescending: result.sort { $0.amount > $1.amount }
        case .amountAscending: result.sort { $0.amount < $1.amount }
        case .categoryAZ: result.sort { $0.category < $1.category }
        case .invoiceNumber: result = sortByInvoiceNumber(result)
        }
        return result
    }

    /// Sort transactions by invoice/receipt number, then by date
    private static func sortByInvoiceNumber(_ transactions: [Transaction]) -> [Transaction] {
        return transactions.sorted { (t1, t2) in
            let inv1 = extractInvoiceNumber(from: t1.note)
            let inv2 = extractInvoiceNumber(from: t2.note)
            if inv1 == inv2 {
                return t1.date > t2.date  // Within same invoice, sort by date
            }
            return inv1 < inv2
        }
    }

    /// Extract invoice/receipt number from transaction note
    private static func extractInvoiceNumber(from note: String?) -> String {
        guard let note = note else { return "" }
        // Parse note format: "... | Invoice#: XXX | ..."
        let components = note.components(separatedBy: " | ")
        for component in components {
            if component.hasPrefix("Invoice#: ") {
                return component.replacingOccurrences(of: "Invoice#: ", with: "")
            }
        }
        return ""
    }
}

/// Transaction sort options (extracted from ViewModel for reusability)
enum TransactionSortOption {
    case dateDescending, dateAscending, amountDescending, amountAscending, categoryAZ, invoiceNumber
}
