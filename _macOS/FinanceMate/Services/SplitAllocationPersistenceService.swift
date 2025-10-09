import CoreData
import Foundation

/*
 * Purpose: Core Data persistence service for split allocation CRUD operations
 * Issues & Complexity Summary: Handles basic Core Data operations with error handling
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~60
 *   - Core Algorithm Complexity: Low (Standard Core Data CRUD)
 *   - Dependencies: Core Data, Foundation
 *   - State Management Complexity: Low (Simple context operations)
 *   - Novelty/Uncertainty Factor: Low (Standard persistence patterns)
 * AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 25%
 * Problem Estimate (Inherent Problem Difficulty %): 30%
 * Initial Code Complexity Estimate %: 25%
 * Justification for Estimates: Basic Core Data operations with proper error handling
 * Final Code Complexity (Actual %): TBD
 * Overall Result Score (Success & Quality %): TBD
 * Key Variances/Learnings: TBD
 * Last Updated: 2025-10-04
 */

/// Service responsible for basic Core Data CRUD operations on split allocations
final class SplitAllocationPersistenceService {

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    // MARK: - CRUD Operations

    /// Creates a new split allocation
    /// - Parameters:
    ///   - percentage: The percentage allocation
    ///   - taxCategory: The tax category
    ///   - lineItem: The line item this allocation belongs to
    /// - Returns: Result containing the created allocation or error
    func createSplitAllocation(
        percentage: Double,
        taxCategory: String,
        lineItem: LineItem
    ) -> SplitAllocationPersistenceResult {
        do {
            let allocation = SplitAllocation.create(
                in: context,
                percentage: percentage,
                taxCategory: taxCategory,
                lineItem: lineItem
            )

            try context.save()
            return .success(allocation)
        } catch {
            return .error("Failed to create split allocation: \(error.localizedDescription)")
        }
    }

    /// Updates an existing split allocation
    /// - Parameter allocation: The allocation to update
    /// - Returns: Result containing success or error
    func updateSplitAllocation(_ allocation: SplitAllocation) -> SplitAllocationPersistenceResult {
        do {
            try context.save()
            return .success(allocation)
        } catch {
            return .error("Failed to update split allocation: \(error.localizedDescription)")
        }
    }

    /// Deletes a split allocation
    /// - Parameter allocation: The allocation to delete
    /// - Returns: Result containing success or error
    func deleteSplitAllocation(_ allocation: SplitAllocation) -> SplitAllocationPersistenceResult {
        do {
            context.delete(allocation)
            try context.save()
            return .success(allocation)
        } catch {
            return .error("Failed to delete split allocation: \(error.localizedDescription)")
        }
    }

    /// Fetches split allocations for a specific line item
    /// - Parameter lineItem: The line item to fetch allocations for
    /// - Returns: Array of split allocations sorted by tax category
    func fetchSplitAllocations(for lineItem: LineItem) -> [SplitAllocation] {
        guard let allocations = lineItem.splitAllocations?.allObjects as? [SplitAllocation] else {
            return []
        }
        return allocations.sorted { $0.taxCategory < $1.taxCategory }
    }

    /// Clears all split allocations for a line item
    /// - Parameter lineItem: The line item to clear allocations for
    /// - Returns: Result containing success or error
    func clearAllSplits(for lineItem: LineItem) -> SplitAllocationPersistenceResult {
        do {
            guard let allocations = lineItem.splitAllocations?.allObjects as? [SplitAllocation] else {
                return .success(nil) // No allocations to clear
            }

            for allocation in allocations {
                context.delete(allocation)
            }

            try context.save()
            return .success(nil)
        } catch {
            return .error("Failed to clear split allocations: \(error.localizedDescription)")
        }
    }
}

// MARK: - Supporting Types

extension SplitAllocationPersistenceService {

    /// Result type for persistence operations
    enum SplitAllocationPersistenceResult {
        case success(SplitAllocation?)
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
            case .error:
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