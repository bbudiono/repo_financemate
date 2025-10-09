import CoreData
import Foundation

/*
 * Purpose: Service for applying quick split templates to line items
 * Issues & Complexity Summary: Handles template-based split creation with proper error handling
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~50
 *   - Core Algorithm Complexity: Low (Template application logic)
 *   - Dependencies: Core Data, Foundation
 *   - State Management Complexity: Low (Simple operations)
 *   - Novelty/Uncertainty Factor: Low (Standard template patterns)
 * AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 20%
 * Problem Estimate (Inherent Problem Difficulty %): 25%
 * Initial Code Complexity Estimate %: 20%
 * Justification for Estimates: Simple template application with proper error handling
 * Final Code Complexity (Actual %): TBD
 * Overall Result Score (Success & Quality %): TBD
 * Key Variances/Learnings: TBD
 * Last Updated: 2025-10-04
 */

/// Service responsible for applying quick split templates to line items
final class SplitAllocationQuickSplitService {

    private let persistenceService: SplitAllocationPersistenceService

    init(persistenceService: SplitAllocationPersistenceService) {
        self.persistenceService = persistenceService
    }

    // MARK: - Quick Split Operations

    /// Applies a quick split template to a line item
    /// - Parameters:
    ///   - splitType: The type of quick split to apply
    ///   - primaryCategory: The primary tax category
    ///   - secondaryCategory: The secondary tax category
    ///   - lineItem: The line item to apply the split to
    /// - Returns: Result containing the created allocations or error
    func applyQuickSplit(
        _ splitType: QuickSplitType,
        primaryCategory: String,
        secondaryCategory: String,
        to lineItem: LineItem
    ) -> SplitAllocationQuickSplitResult {
        // Clear existing splits first
        let clearResult = persistenceService.clearAllSplits(for: lineItem)
        if case .error(let message) = clearResult {
            return .error(message)
        }

        let (primaryPercentage, secondaryPercentage) = getQuickSplitPercentages(splitType)

        // Create new splits using persistence service
        let primaryResult = persistenceService.createSplitAllocation(
            percentage: primaryPercentage,
            taxCategory: primaryCategory,
            lineItem: lineItem
        )

        guard case .success(let primaryAllocation) = primaryResult else {
            if case .error(let message) = primaryResult {
                return .error(message)
            }
            return .error("Failed to create primary allocation")
        }

        let secondaryResult = persistenceService.createSplitAllocation(
            percentage: secondaryPercentage,
            taxCategory: secondaryCategory,
            lineItem: lineItem
        )

        guard case .success(let secondaryAllocation) = secondaryResult else {
            if case .error(let message) = secondaryResult {
                return .error(message)
            }
            return .error("Failed to create secondary allocation")
        }

        return .success([primaryAllocation, secondaryAllocation])
    }

    // MARK: - Private Helper Methods

    /// Gets the percentages for a quick split type
    /// - Parameter splitType: The quick split type
    /// - Returns: Tuple of (primaryPercentage, secondaryPercentage)
    private func getQuickSplitPercentages(_ splitType: QuickSplitType) -> (Double, Double) {
        switch splitType {
        case .fiftyFifty:
            return (50.0, 50.0)
        case .seventyThirty:
            return (70.0, 30.0)
        }
    }
}

// MARK: - Supporting Types

extension SplitAllocationQuickSplitService {

    /// Result type for quick split operations
    enum SplitAllocationQuickSplitResult {
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

        var allocations: [SplitAllocation]? {
            switch self {
            case .success(let allocations):
                return allocations
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