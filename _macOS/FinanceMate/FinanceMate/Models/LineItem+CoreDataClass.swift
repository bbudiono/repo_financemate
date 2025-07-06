import CoreData
import Foundation

/*
 * Purpose: Core Data model class for LineItem entity representing individual line items within transactions
 * Issues & Complexity Summary: Simple entity class for line item data management with Core Data integration
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~40
 *   - Core Algorithm Complexity: Low
 *   - Dependencies: 1 New (Core Data), 0 Mod
 *   - State Management Complexity: Low
 *   - Novelty/Uncertainty Factor: Low
 * AI Pre-Task Self-Assessment: 95%
 * Problem Estimate: 90%
 * Initial Code Complexity Estimate: 85%
 * Final Code Complexity: 88%
 * Overall Result Score: 94%
 * Key Variances/Learnings: Standard Core Data entity pattern
 * Last Updated: 2025-07-06
 */

@objc(LineItem)
public class LineItem: NSManagedObject {
    // MARK: - Convenience Initializers
    
    /// Creates a new LineItem in the specified context
    static func create(
        in context: NSManagedObjectContext,
        itemDescription: String,
        amount: Double
    ) -> LineItem {
        let lineItem = LineItem(context: context)
        lineItem.id = UUID()
        lineItem.itemDescription = itemDescription
        lineItem.amount = amount
        return lineItem
    }
}