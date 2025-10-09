import CoreData
import Foundation

/*
 * Purpose: Facade service for split allocation operations using composition
 * Issues & Complexity Summary: Simplified coordination layer that delegates to specialized services
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~60
 *   - Core Algorithm Complexity: Low (Service delegation pattern)
 *   - Dependencies: Core Data, Foundation, specialized services
 *   - State Management Complexity: Low (Service coordination)
 *   - Novelty/Uncertainty Factor: Low (Standard facade pattern)
 * AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 25%
 * Problem Estimate (Inherent Problem Difficulty %): 30%
 * Initial Code Complexity Estimate %: 25%
 * Justification for Estimates: Simple facade pattern with service delegation
 * Final Code Complexity (Actual %): TBD
 * Overall Result Score (Success & Quality %): TBD
 * Key Variances/Learnings: TBD
 * Last Updated: 2025-10-04
 */

/// Facade service responsible for coordinating split allocation operations
final class SplitAllocationDataService {

    private let persistenceService: SplitAllocationPersistenceService
    private let quickSplitService: SplitAllocationQuickSplitService

    init(context: NSManagedObjectContext) {
        self.persistenceService = SplitAllocationPersistenceService(context: context)
        self.quickSplitService = SplitAllocationQuickSplitService(persistenceService: persistenceService)
    }

    // MARK: - CRUD Operations (Delegated)

    /// Creates a new split allocation
    func createSplitAllocation(
        percentage: Double,
        taxCategory: String,
        lineItem: LineItem
    ) -> SplitAllocationResult {
        let result = persistenceService.createSplitAllocation(
            percentage: percentage,
            taxCategory: taxCategory,
            lineItem: lineItem
        )
        return convertToSplitAllocationResult(result)
    }

    /// Updates an existing split allocation
    func updateSplitAllocation(_ allocation: SplitAllocation) -> SplitAllocationResult {
        let result = persistenceService.updateSplitAllocation(allocation)
        return convertToSplitAllocationResult(result)
    }

    /// Deletes a split allocation
    func deleteSplitAllocation(_ allocation: SplitAllocation) -> SplitAllocationResult {
        let result = persistenceService.deleteSplitAllocation(allocation)
        return convertToSplitAllocationResult(result)
    }

    /// Fetches split allocations for a specific line item
    func fetchSplitAllocations(for lineItem: LineItem) -> [SplitAllocation] {
        return persistenceService.fetchSplitAllocations(for: lineItem)
    }

    /// Clears all split allocations for a line item
    func clearAllSplits(for lineItem: LineItem) -> SplitAllocationResult {
        let result = persistenceService.clearAllSplits(for: lineItem)
        return convertToSplitAllocationResult(result)
    }

    /// Applies a quick split template to a line item
    func applyQuickSplit(
        _ splitType: QuickSplitType,
        primaryCategory: String,
        secondaryCategory: String,
        to lineItem: LineItem
    ) -> SplitAllocationResult {
        let result = quickSplitService.applyQuickSplit(
            splitType,
            primaryCategory: primaryCategory,
            secondaryCategory: secondaryCategory,
            to: lineItem
        )
        return convertToSplitAllocationResult(result)
    }

    // MARK: - Private Helper Methods

    /// Converts persistence service result to data service result
    private func convertToSplitAllocationResult(_ result: SplitAllocationPersistenceService.SplitAllocationPersistenceResult) -> SplitAllocationResult {
        switch result {
        case .success(let allocation):
            return .success(allocation)
        case .error(let message):
            return .error(message)
        }
    }

    /// Converts quick split service result to data service result
    private func convertToSplitAllocationResult(_ result: SplitAllocationQuickSplitService.SplitAllocationQuickSplitResult) -> SplitAllocationResult {
        switch result {
        case .success(let allocations):
            return .success(allocations)
        case .error(let message):
            return .error(message)
        }
    }
}

// MARK: - Supporting Types

extension SplitAllocationDataService {

    /// Result type for split allocation operations
    enum SplitAllocationResult {
        case success(SplitAllocation?)
        case success([SplitAllocation])
        case error(String)

        var isSuccess: Bool {
            switch self {
            case .success:
                return true
            case .error:
                return false
            }
        }

        var allocation: SplitAllocation? {
            switch self {
            case .success(let allocation):
                return allocation
            case .success, .error:
                return nil
            }
        }

        var allocations: [SplitAllocation]? {
            switch self {
            case .success(let allocations):
                return allocations
            case .success, .error:
                return nil
            }
        }

        var errorMessage: String? {
            switch self {
            case .success:
                return nil
            case .error(let message):
                return message
            }
        }
    }
}