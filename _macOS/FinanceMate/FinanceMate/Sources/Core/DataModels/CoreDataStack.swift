// SANDBOX FILE: For testing/development. See .cursorrules.
/*
* Purpose: Core Data stack management for FinanceMate Sandbox environment
* Issues & Complexity Summary: Centralized Core Data stack with persistent storage and memory context
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~150
  - Core Algorithm Complexity: Medium
  - Dependencies: 2 New (CoreData, Foundation)
  - State Management Complexity: Medium
  - Novelty/Uncertainty Factor: Low
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 70%
* Problem Estimate (Inherent Problem Difficulty %): 65%
* Initial Code Complexity Estimate %: 68%
* Justification for Estimates: Standard Core Data stack implementation
* Final Code Complexity (Actual %): TBD
* Overall Result Score (Success & Quality %): TBD
* Key Variances/Learnings: TBD
* Last Updated: 2025-06-03
*/

import Foundation
import CoreData

/// Core Data stack manager for FinanceMate application
/// Provides centralized access to persistent storage and managed object contexts
public class CoreDataStack {
    
    /// Shared singleton instance
    public static let shared = CoreDataStack()
    
    /// The persistent container for the Core Data stack
    public lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "FinanceMateDataModel")
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately
                // In production, you should handle this error gracefully
                fatalError("Failed to load persistent store: \(error), \(error.userInfo)")
            }
            
            // Configure for better performance
            storeDescription.shouldInferMappingModelAutomatically = true
            storeDescription.shouldMigrateStoreAutomatically = true
        }
        
        // Configure merge policy for concurrent access
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        return container
    }()
    
    /// The main managed object context (connected to persistent store coordinator)
    public var mainContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    /// Creates a new background context for concurrent operations
    public func newBackgroundContext() -> NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }
    
    /// Saves the main context
    /// - Throws: Core Data save errors
    public func saveMainContext() throws {
        guard mainContext.hasChanges else { return }
        try mainContext.save()
    }
    
    /// Saves the given context
    /// - Parameter context: The managed object context to save
    /// - Throws: Core Data save errors
    public func save(context: NSManagedObjectContext) throws {
        guard context.hasChanges else { return }
        try context.save()
    }
    
    /// Performs a save operation on the main context asynchronously
    /// - Parameter completion: Completion handler called on main queue
    public func saveMainContextAsync(completion: @escaping (Result<Void, Error>) -> Void) {
        mainContext.perform {
            do {
                try self.saveMainContext()
                DispatchQueue.main.async {
                    completion(.success(()))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    /// Performs a save operation on a background context
    /// - Parameters:
    ///   - changes: Block to perform changes on background context
    ///   - completion: Completion handler called on main queue
    public func performBackgroundTask(
        changes: @escaping (NSManagedObjectContext) -> Void,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let backgroundContext = newBackgroundContext()
        
        backgroundContext.perform {
            changes(backgroundContext)
            
            do {
                try self.save(context: backgroundContext)
                DispatchQueue.main.async {
                    completion(.success(()))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    /// Deletes all data from the persistent store (useful for testing)
    /// - Throws: Core Data errors
    public func deleteAllData() throws {
        let entityNames = ["Document", "FinancialData", "Client", "Category", "Project"]
        
        for entityName in entityNames {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            deleteRequest.resultType = .resultTypeObjectIDs
            
            let result = try mainContext.execute(deleteRequest) as? NSBatchDeleteResult
            let objectIDArray = result?.result as? [NSManagedObjectID]
            let changes = [NSDeletedObjectsKey: objectIDArray ?? []]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [mainContext])
        }
        
        try saveMainContext()
    }
    
    /// Private initializer for singleton
    private init() {}
}

// MARK: - Core Data Model Helper Extensions

extension NSManagedObject {
    
    /// Generic fetch request for any NSManagedObject subclass
    /// - Returns: NSFetchRequest for the specific entity type
    public class func fetchRequest<T: NSManagedObject>() -> NSFetchRequest<T> {
        let entityName = String(describing: self)
        return NSFetchRequest<T>(entityName: entityName)
    }
}

extension NSManagedObjectContext {
    
    /// Convenience method to fetch entities with predicate
    /// - Parameters:
    ///   - entityType: The type of entity to fetch
    ///   - predicate: Optional predicate for filtering
    ///   - sortDescriptors: Optional sort descriptors
    ///   - limit: Optional fetch limit
    /// - Returns: Array of fetched entities
    /// - Throws: Core Data fetch errors
    public func fetch<T: NSManagedObject>(
        _ entityType: T.Type,
        predicate: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor]? = nil,
        limit: Int? = nil
    ) throws -> [T] {
        let request: NSFetchRequest<T> = entityType.fetchRequest()
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        
        if let limit = limit {
            request.fetchLimit = limit
        }
        
        return try fetch(request)
    }
    
    /// Convenience method to count entities with predicate
    /// - Parameters:
    ///   - entityType: The type of entity to count
    ///   - predicate: Optional predicate for filtering
    /// - Returns: Count of entities
    /// - Throws: Core Data count errors
    public func count<T: NSManagedObject>(
        _ entityType: T.Type,
        predicate: NSPredicate? = nil
    ) throws -> Int {
        let request: NSFetchRequest<T> = entityType.fetchRequest()
        request.predicate = predicate
        return try count(for: request)
    }
}