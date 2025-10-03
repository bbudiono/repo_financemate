import Foundation

/// Service for managing paginated display of transactions
/// Handles page size, current page, and pagination logic
class PaginationManager {
    private(set) var currentPage = 1
    let pageSize: Int

    init(pageSize: Int = 50) {
        self.pageSize = pageSize
    }

    /// Get paginated subset of transactions
    /// - Parameter transactions: Full array of transactions
    /// - Returns: Transactions up to current page limit
    func paginatedResults<T>(_ items: [T]) -> [T] {
        return Array(items.prefix(currentPage * pageSize))
    }

    /// Check if more pages are available
    /// - Parameter totalCount: Total number of items
    /// - Returns: True if more pages exist beyond current page
    func hasMorePages(totalCount: Int) -> Bool {
        return currentPage * pageSize < totalCount
    }

    /// Advance to next page if available
    /// - Parameter totalCount: Total number of items
    func loadNextPage(totalCount: Int) {
        guard hasMorePages(totalCount: totalCount) else { return }
        currentPage += 1
    }

    /// Reset pagination to first page
    func reset() {
        currentPage = 1
    }
}
