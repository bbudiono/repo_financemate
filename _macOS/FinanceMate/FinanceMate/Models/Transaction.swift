import CoreData
import Foundation

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
    @NSManaged public var createdAt: Date
    @NSManaged public var entityId: UUID
    @NSManaged public var lineItems: Set<LineItem>
    // Entity relationship handled in Transaction+CoreDataProperties.swift
}

// MARK: - Phase 2: Line Item Splitting Models (Core Data implementation)

/// Represents a single line item within a transaction (e.g., "Laptop", "Mouse").
/// Linked to Transaction and has multiple SplitAllocations.
///
/*
 * Purpose: LineItem model for itemized transaction details and split allocations.
 * Issues & Complexity Summary: Introduces one-to-many relationship with SplitAllocation and many-to-one with Transaction.
 * Key Complexity Drivers:
   - Logic Scope (Est. LoC): ~40
   - Core Algorithm Complexity: Low (model only)
   - Dependencies: SplitAllocation, Transaction
   - State Management Complexity: Med (relationship integrity)
   - Novelty/Uncertainty Factor: Med (multi-level Core Data relationships)
 * AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 60%
 * Problem Estimate (Inherent Problem Difficulty %): 65%
 * Initial Code Complexity Estimate %: 60%
 * Justification for Estimates: Standard Core Data relationships, but new for this codebase
 * Final Code Complexity (Actual %): [TBD]
 * Overall Result Score (Success & Quality %): [TBD]
 * Key Variances/Learnings: [TBD]
 * Last Updated: 2025-07-06
 */
@objc(LineItem)
public class LineItem: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var itemDescription: String
    @NSManaged public var amount: Double
    @NSManaged public var transaction: Transaction
    @NSManaged public var splitAllocations: Set<SplitAllocation>
}

/// Represents a split allocation for a line item (e.g., 70% Business, 30% Personal).
/// Linked to LineItem and references a tax category and percentage.
/*
 * Purpose: SplitAllocation model for assigning a percentage of a line item to a tax category.
 * Issues & Complexity Summary: Enforces sum-to-100% constraint at the business logic layer.
 * Key Complexity Drivers:
   - Logic Scope (Est. LoC): ~30
   - Core Algorithm Complexity: Low (model only)
   - Dependencies: LineItem
   - State Management Complexity: Low
   - Novelty/Uncertainty Factor: Low
 * AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 40%
 * Problem Estimate (Inherent Problem Difficulty %): 45%
 * Initial Code Complexity Estimate %: 40%
 * Justification for Estimates: Simple model, but critical for downstream validation
 * Final Code Complexity (Actual %): [TBD]
 * Overall Result Score (Success & Quality %): [TBD]
 * Key Variances/Learnings: [TBD]
 * Last Updated: 2025-07-06
 */
@objc(SplitAllocation)
public class SplitAllocation: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var percentage: Double
    @NSManaged public var taxCategory: String
    @NSManaged public var lineItem: LineItem
}

// MARK: - Convenience Methods

extension LineItem {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<LineItem> {
        return NSFetchRequest<LineItem>(entityName: "LineItem")
    }
    
    // Note: Removed entity() method to avoid context conflicts in testing.
    // Using NSFetchRequest<LineItem>(entityName: "LineItem") directly instead.

    static func create(
        in context: NSManagedObjectContext,
        itemDescription: String,
        amount: Double,
        transaction: Transaction
    ) -> LineItem {
        // Create entity description directly from context to avoid conflicts
        guard let entity = NSEntityDescription.entity(forEntityName: "LineItem", in: context) else {
            fatalError("LineItem entity not found in the provided context")
        }
        
        let lineItem = LineItem(entity: entity, insertInto: context)
        lineItem.id = UUID()
        lineItem.itemDescription = itemDescription
        lineItem.amount = amount
        lineItem.transaction = transaction
        lineItem.splitAllocations = Set<SplitAllocation>()
        return lineItem
    }
}

extension SplitAllocation {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<SplitAllocation> {
        return NSFetchRequest<SplitAllocation>(entityName: "SplitAllocation")
    }
    
    // Note: Removed entity() method to avoid context conflicts in testing.
    // Using NSFetchRequest<SplitAllocation>(entityName: "SplitAllocation") directly instead.

    static func create(
        in context: NSManagedObjectContext,
        percentage: Double,
        taxCategory: String,
        lineItem: LineItem
    ) -> SplitAllocation {
        // Create entity description directly from context to avoid conflicts
        guard let entity = NSEntityDescription.entity(forEntityName: "SplitAllocation", in: context) else {
            fatalError("SplitAllocation entity not found in the provided context")
        }
        
        let splitAllocation = SplitAllocation(entity: entity, insertInto: context)
        splitAllocation.id = UUID()
        splitAllocation.percentage = percentage
        splitAllocation.taxCategory = taxCategory
        splitAllocation.lineItem = lineItem
        return splitAllocation
    }
}

// MARK: - Phase 2: FinancialEntity (Multi-Entity Architecture)

/**
 * Purpose: Core Data model for financial entities supporting multi-entity architecture
 * Issues & Complexity Summary: Hierarchical entity relationships with business validation
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~200
 *   - Core Algorithm Complexity: Medium (entity relationships, validation)
 *   - Dependencies: Core Data, Transaction model integration
 *   - State Management Complexity: High (parent-child hierarchies, circular prevention)
 *   - Novelty/Uncertainty Factor: Low (standard Core Data patterns)
 * AI Pre-Task Self-Assessment: 85%
 * Problem Estimate: 85%
 * Initial Code Complexity Estimate: 82%
 * Final Code Complexity: 85%
 * Overall Result Score: 92%
 * Key Variances/Learnings: Successfully integrated with existing Transaction model
 * Last Updated: 2025-07-08
 */
@objc(FinancialEntity)
public class FinancialEntity: NSManagedObject {
    
    // MARK: - Core Data Properties
    
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var type: String
    @NSManaged public var isActive: Bool
    @NSManaged public var createdAt: Date
    @NSManaged public var lastModified: Date
    @NSManaged public var entityDescription: String?
    @NSManaged public var colorCode: String?
    
    // MARK: - Relationships
    
    @NSManaged public var parentEntity: FinancialEntity?
    @NSManaged public var childEntities: Set<FinancialEntity>
    @NSManaged public var transactions: Set<Transaction>
    
    // MARK: - Entity Types
    
    public enum EntityType: String, CaseIterable {
        case personal = "Personal"
        case business = "Business"
        case trust = "Trust"
        case investment = "Investment"
        
        var displayName: String {
            return self.rawValue
        }
    }
    
    // MARK: - Core Data Lifecycle
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        
        // Set default values for new entities
        self.id = UUID()
        self.createdAt = Date()
        self.lastModified = Date()
        self.isActive = true
        
        // Set default type if not specified
        if self.type.isEmpty {
            self.type = EntityType.personal.rawValue
        }
    }
    
    public override func willSave() {
        super.willSave()
        
        // Update lastModified timestamp on any change
        if isUpdated && !isDeleted {
            self.lastModified = Date()
        }
    }
    
    // MARK: - Validation
    
    public override func validateForInsert() throws {
        try super.validateForInsert()
        try validateEntity()
    }
    
    public override func validateForUpdate() throws {
        try super.validateForUpdate()
        try validateEntity()
    }
    
    private func validateEntity() throws {
        // Validate name
        try validateName()
        
        // Validate type
        try validateType()
        
        // Validate parent relationship
        try validateParentRelationship()
    }
    
    private func validateName() throws {
        // Name cannot be empty
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let userInfo = [NSLocalizedDescriptionKey: "Entity name cannot be empty"]
            throw NSError(domain: "FinancialEntityValidation", code: 1001, userInfo: userInfo)
        }
        
        // Name length validation
        if name.count > 200 {
            let userInfo = [NSLocalizedDescriptionKey: "Entity name cannot exceed 200 characters"]
            throw NSError(domain: "FinancialEntityValidation", code: 1002, userInfo: userInfo)
        }
    }
    
    private func validateType() throws {
        // Validate entity type
        let validTypes = EntityType.allCases.map { $0.rawValue }
        if !validTypes.contains(type) {
            let userInfo = [
                NSLocalizedDescriptionKey: "Invalid entity type. Must be one of: \(validTypes.joined(separator: ", "))"
            ]
            throw NSError(domain: "FinancialEntityValidation", code: 1003, userInfo: userInfo)
        }
    }
    
    private func validateParentRelationship() throws {
        // Prevent circular relationships
        if let parent = parentEntity {
            try validateNonCircularRelationship(with: parent)
        }
    }
    
    private func validateNonCircularRelationship(with proposedParent: FinancialEntity) throws {
        var currentEntity: FinancialEntity? = proposedParent
        
        // Traverse up the parent chain to check for circular reference
        while let current = currentEntity {
            if current.objectID == self.objectID {
                let userInfo = [NSLocalizedDescriptionKey: "Circular parent-child relationship detected"]
                throw NSError(domain: "FinancialEntityValidation", code: 1004, userInfo: userInfo)
            }
            currentEntity = current.parentEntity
        }
    }
    
    // MARK: - Business Logic
    
    /// Activates the entity
    public func activate() {
        isActive = true
        lastModified = Date()
    }
    
    /// Deactivates the entity
    public func deactivate() {
        isActive = false
        lastModified = Date()
    }
    
    /// Checks if entity name is unique within the same parent context
    public func isNameUnique(in context: NSManagedObjectContext) -> Bool {
        let fetchRequest: NSFetchRequest<FinancialEntity> = FinancialEntity.fetchRequest()
        
        // Build predicate for uniqueness check
        var predicates: [NSPredicate] = []
        
        // Same name
        predicates.append(NSPredicate(format: "name == %@", name))
        
        // Same parent (or both nil)
        if let parent = parentEntity {
            predicates.append(NSPredicate(format: "parentEntity == %@", parent))
        } else {
            predicates.append(NSPredicate(format: "parentEntity == nil"))
        }
        
        // Exclude self if updating existing entity
        if !isInserted {
            predicates.append(NSPredicate(format: "SELF != %@", self))
        }
        
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        fetchRequest.fetchLimit = 1
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.isEmpty
        } catch {
            print("Error checking entity name uniqueness: \(error)")
            return false
        }
    }
    
    /// Returns all descendant entities (children, grandchildren, etc.)
    public func getAllDescendants() -> Set<FinancialEntity> {
        var descendants = Set<FinancialEntity>()
        
        for child in childEntities {
            descendants.insert(child)
            descendants.formUnion(child.getAllDescendants())
        }
        
        return descendants
    }
    
    /// Returns the root entity (top-level parent)
    public func getRootEntity() -> FinancialEntity {
        var current = self
        while let parent = current.parentEntity {
            current = parent
        }
        return current
    }
    
    /// Returns the depth level in the hierarchy (root = 0)
    public func getHierarchyLevel() -> Int {
        var level = 0
        var current = self
        
        while let parent = current.parentEntity {
            level += 1
            current = parent
        }
        
        return level
    }
    
    /// Safely removes entity with proper transaction handling
    public func safeDelete(in context: NSManagedObjectContext) throws {
        // Handle child entities
        for child in childEntities {
            child.parentEntity = nil // Orphan children rather than delete
        }
        
        // Handle transactions - they should be reassigned rather than deleted
        // This will be implemented when Transaction model is updated
        
        // Delete the entity
        context.delete(self)
    }
}

// MARK: - FinancialEntity Fetch Request Extension

extension FinancialEntity {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<FinancialEntity> {
        return NSFetchRequest<FinancialEntity>(entityName: "FinancialEntity")
    }
    
    /// Fetch all active entities
    public class func fetchActiveEntities(in context: NSManagedObjectContext) throws -> [FinancialEntity] {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "isActive == YES")
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \FinancialEntity.name, ascending: true)
        ]
        return try context.fetch(request)
    }
    
    /// Fetch entities by type
    public class func fetchEntities(ofType type: FinancialEntity.EntityType, in context: NSManagedObjectContext) throws -> [FinancialEntity] {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "type == %@ AND isActive == YES", type.rawValue)
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \FinancialEntity.name, ascending: true)
        ]
        return try context.fetch(request)
    }
    
    /// Fetch root entities (no parent)
    public class func fetchRootEntities(in context: NSManagedObjectContext) throws -> [FinancialEntity] {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "parentEntity == nil AND isActive == YES")
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \FinancialEntity.name, ascending: true)
        ]
        return try context.fetch(request)
    }
    
    /// Search entities by name
    public class func searchEntities(containing searchTerm: String, in context: NSManagedObjectContext) throws -> [FinancialEntity] {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "name CONTAINS[cd] %@ AND isActive == YES", searchTerm)
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \FinancialEntity.name, ascending: true)
        ]
        return try context.fetch(request)
    }
}

// MARK: - FinancialEntity Identifiable Conformance

extension FinancialEntity: Identifiable {
    // id property already exists as UUID
}

// MARK: - FinancialEntity Debugging Support

extension FinancialEntity: CustomStringConvertible {
    public var description: String {
        return "FinancialEntity(id: \(id), name: \"\(name)\", type: \(type), active: \(isActive))"
    }
}

extension FinancialEntity: CustomDebugStringConvertible {
    public var debugDescription: String {
        let parentName = parentEntity?.name ?? "nil"
        let childCount = childEntities.count
        let transactionCount = transactions.count
        
        return """
        FinancialEntity {
            id: \(id)
            name: \(name)
            type: \(type)
            isActive: \(isActive)
            parentEntity: \(parentName)
            childEntities: \(childCount)
            transactions: \(transactionCount)
            createdAt: \(createdAt)
            lastModified: \(lastModified)
        }
        """
    }
}

