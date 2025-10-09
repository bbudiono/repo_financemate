import Foundation
import CoreData

// Service for filtering transactions with various criteria
struct TransactionFilteringService {

    // Apply all filters to transaction list
    static func filter(
        _ transactions: [Transaction],
        searchText: String,
        source: String?,
        category: String?,
        sortOption: TransactionsViewModel.SortOption
    ) -> [Transaction] {
        var result = transactions

        // Apply search filter
        if !searchText.isEmpty {
            result = result.filter { transaction in
                transaction.itemDescription.localizedCaseInsensitiveContains(searchText) ||
                transaction.category.localizedCaseInsensitiveContains(searchText)
            }
        }

        // Apply source filter
        if let source = source {
            result = result.filter { $0.source == source }
        }

        // Apply category filter
        if let category = category {
            result = result.filter { $0.category == category }
        }

        // Apply sorting
        result = TransactionSortingService.sort(result, by: sortOption)

        return result
    }
}