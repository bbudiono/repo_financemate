import Foundation
import CoreData

// Service for sorting transactions with safe comparison methods
struct TransactionSortingService {

    // Compare transactions by date with safe handling
    static func compareDate(_ transaction1: Transaction, _ transaction2: Transaction, ascending: Bool) -> Bool {
        guard let date1 = transaction1.date,
              let date2 = transaction2.date else {
            return false
        }
        let comparison = date1.compare(date2)
        return ascending ? comparison == .orderedAscending : comparison == .orderedDescending
    }

    // Compare transactions by amount with safe handling
    static func compareAmount(_ transaction1: Transaction, _ transaction2: Transaction, ascending: Bool) -> Bool {
        guard let amount1 = transaction1.amount,
              let amount2 = transaction2.amount else {
            return false
        }
        let comparison = amount1.compare(amount2)
        return ascending ? comparison == .orderedAscending : comparison == .orderedDescending
    }

    // Sort transactions by specified criteria
    static func sort(_ transactions: [Transaction], by option: TransactionsViewModel.SortOption) -> [Transaction] {
        switch option {
        case .dateDescending:
            return transactions.sorted { compareDate($0, $1, ascending: false) }
        case .dateAscending:
            return transactions.sorted { compareDate($0, $1, ascending: true) }
        case .amountDescending:
            return transactions.sorted { compareAmount($0, $1, ascending: false) }
        case .amountAscending:
            return transactions.sorted { compareAmount($0, $1, ascending: true) }
        case .categoryAZ:
            return transactions.sorted { $0.category.localizedCaseInsensitiveCompare($1.category) == .orderedAscending }
        }
    }
}