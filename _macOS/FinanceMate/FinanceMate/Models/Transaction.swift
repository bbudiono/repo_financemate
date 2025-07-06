import Foundation
import CoreData

/*
* Purpose: Transaction model for financial records. Now extended for line item splitting (Phase 2).
* Issues & Complexity Summary: Adding support for line items and split allocations introduces new relationships and validation logic.
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~100 (with new models)
  - Core Algorithm Complexity: Med-High (split validation, relationships)
  - Dependencies: 2 New (LineItem, SplitAllocation)
  - State Management Complexity: Med
  - Novelty/Uncertainty Factor: Med (multi-level Core Data relationships)
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 80%
* Problem Estimate (Inherent Problem Difficulty %): 85%
* Initial Code Complexity Estimate %: 80%
* Justification for Estimates: Multi-entity relationships, validation, and UI integration
* Final Code Complexity (Actual %): [TBD]
* Overall Result Score (Success & Quality %): [TBD]
* Key Variances/Learnings: [TBD]
* Last Updated: 2025-07-06
*/

@objc(Transaction)
public class Transaction: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var date: Date
    @NSManaged public var amount: Double
    @NSManaged public var category: String
    @NSManaged public var note: String?
}

// MARK: - Phase 2: Line Item Splitting Models (TDD placeholder)

/// Represents a single line item within a transaction (e.g., "Laptop", "Mouse").
/// Will be linked to Transaction and have multiple SplitAllocations.
class LineItem: NSManagedObject {
    // Properties and relationships to be implemented
}

/// Represents a split allocation for a line item (e.g., 70% Business, 30% Personal).
/// Will be linked to LineItem and reference a tax category and percentage.
class SplitAllocation: NSManagedObject {
    // Properties and relationships to be implemented
} 