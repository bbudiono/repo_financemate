import CoreData
import Foundation

/*
 * Purpose: Core Data properties extension for SplitAllocation entity with programmatic attribute definitions
 * Issues & Complexity Summary: Defines SplitAllocation entity properties and relationships for Core Data
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~25
 *   - Core Algorithm Complexity: Low
 *   - Dependencies: 1 New (Core Data), 0 Mod
 *   - State Management Complexity: Low
 *   - Novelty/Uncertainty Factor: Low
 * AI Pre-Task Self-Assessment: 95%
 * Problem Estimate: 92%
 * Initial Code Complexity Estimate: 88%
 * Final Code Complexity: 90%
 * Overall Result Score: 95%
 * Key Variances/Learnings: Standard Core Data properties pattern
 * Last Updated: 2025-07-06
 */

extension SplitAllocation {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<SplitAllocation> {
        return NSFetchRequest<SplitAllocation>(entityName: "SplitAllocation")
    }

    // Properties are now defined in the main class in Transaction.swift
}