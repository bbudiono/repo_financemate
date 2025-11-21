import CoreData
import os.log

/**
 * Purpose: Handles high-performance batch operations using NSBatchInsertRequest
 * Complexity: Low (Focused single-responsibility service)
 * Usage: Use for inserting large datasets (e.g., >100 items) to avoid O(n) context saves
 */
public struct BatchOperationsService {
    private static let logger = Logger(subsystem: "FinanceMate", category: "BatchOperationsService")

    /// Perform a batch insert for a specific entity
    /// - Parameters:
    ///   - entityName: Name of the entity to insert into
    ///   - objects: Array of dictionaries containing attribute values
    ///   - context: Managed object context to execute request on
    /// - Returns: Result of the batch insert operation
    public static func performBatchInsert(
        entityName: String,
        objects: [[String: Any]],
        in context: NSManagedObjectContext
    ) throws -> NSBatchInsertResult? {
        guard !objects.isEmpty else { return nil }

        logger.info("Starting batch insert for \(entityName) with \(objects.count) items")
        let startTime = CFAbsoluteTimeGetCurrent()

        // Create batch insert request
        let batchInsert = NSBatchInsertRequest(entityName: entityName, objects: objects)
        
        // VALIDATION GATE: Optional validation for Transaction entities
        if entityName == "Transaction" {
            var validObjects = [[String: Any]]()
            for object in objects {
                do {
                    try TransactionValidationService.shared.validateTransaction(object)
                    validObjects.append(object)
                } catch {
                    print("❌ Skipping invalid batch item: \(error.localizedDescription)")
                }
            }
            // Replace with filtered list
            batchInsert.objectsToInsert = validObjects
        }
        
        // Set result type to count or objectIDs depending on need (defaulting to result type for flexibility)
        batchInsert.resultType = .objectIDs

        do {
            // Execute request
            let result = try context.execute(batchInsert) as? NSBatchInsertResult
            
            // Merge changes into context to keep it in sync
            if let objectIDs = result?.result as? [NSManagedObjectID] {
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: [NSInsertedObjectsKey: objectIDs], into: [context])
            }
            
            let duration = CFAbsoluteTimeGetCurrent() - startTime
            logger.info("Batch insert completed in \(String(format: "%.3f", duration))s")
            
            return result
        } catch {
            logger.error("Batch insert failed: \(error.localizedDescription)")
            throw error
        }
    }
}
