import Foundation

/**
 * Purpose: Gmail pagination management service for transaction lists
 * Issues & Complexity Summary: Handles pagination state and navigation for transaction lists
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~25
 *   - Core Algorithm Complexity: Low (simple pagination logic)
 *   - Dependencies: 1 New (PaginationManager)
 *   - State Management Complexity: Low (pagination state)
 *   - Novelty/Uncertainty Factor: Low (standard pagination patterns)
 * AI Pre-Task Self-Assessment: 95%
 * Problem Estimate: 70%
 * Initial Code Complexity Estimate: 55%
 * Final Code Complexity: 58%
 * Overall Result Score: 95%
 * Key Variances/Learnings: Pagination is straightforward, minimal complexity
 * Last Updated: 2025-10-09
 */

@MainActor
class GmailPaginationManager: ObservableObject {
    private let paginationManager: PaginationManager

    init(pageSize: Int = 50) {
        self.paginationManager = PaginationManager(pageSize: pageSize)
    }

    func paginatedResults<T>(from items: [T]) -> [T] {
        return paginationManager.paginatedResults(items)
    }

    func hasMorePages<T>(totalCount: Int) -> Bool {
        return paginationManager.hasMorePages(totalCount: totalCount)
    }

    func loadNextPage<T>(totalCount: Int) {
        paginationManager.loadNextPage(totalCount: totalCount)
    }

    func resetPagination() {
        paginationManager.resetPagination()
    }

    var currentPage: Int {
        return paginationManager.currentPage
    }

    var pageSize: Int {
        return paginationManager.pageSize
    }
}