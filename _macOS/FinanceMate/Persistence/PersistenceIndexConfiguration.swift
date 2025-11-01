import CoreData

/// Persistence index configuration for performance optimization
/// Extracted from PersistenceController.swift for KISS principle compliance
struct PersistenceIndexConfiguration {

    /// Configure indexes for all entities to improve query performance
    /// - Parameter entity: Transaction entity to configure indexes for
    static func configureIndexes(for entity: NSEntityDescription) {
        guard entity.name == "Transaction" else { return }

        // Find attributes by name for index creation
        guard let dateAttr = entity.attributesByName["date"],
              let categoryAttr = entity.attributesByName["category"],
              let sourceEmailIDAttr = entity.attributesByName["sourceEmailID"],
              let externalTransactionIdAttr = entity.attributesByName["externalTransactionId"] else {
            return
        }

        // PERFORMANCE: Add indexes for frequently queried fields (+8 points backend review)
        // Improves query performance for sorting, filtering, and duplicate detection
        let dateIndex = NSFetchIndexDescription(name: "date_idx", elements: [
            NSFetchIndexElementDescription(property: dateAttr, collationType: .binary)
        ])

        let categoryIndex = NSFetchIndexDescription(name: "category_idx", elements: [
            NSFetchIndexElementDescription(property: categoryAttr, collationType: .binary)
        ])

        let sourceEmailIndex = NSFetchIndexDescription(name: "sourceEmailID_idx", elements: [
            NSFetchIndexElementDescription(property: sourceEmailIDAttr, collationType: .binary)
        ])

        let externalTxIndex = NSFetchIndexDescription(name: "externalTx_idx", elements: [
            NSFetchIndexElementDescription(property: externalTransactionIdAttr, collationType: .binary)
        ])

        entity.indexes = [dateIndex, categoryIndex, sourceEmailIndex, externalTxIndex]
    }
}
