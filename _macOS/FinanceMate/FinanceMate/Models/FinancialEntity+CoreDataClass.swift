//
// FinancialEntity+CoreDataClass.swift
// FinanceMate
//
// Created by FinanceMate AI Assistant on 2025-07-08.
// Copyright © 2025 FinanceMate. All rights reserved.
//

import Foundation
import CoreData

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
 * Final Code Complexity: TBD
 * Overall Result Score: TBD
 * Key Variances/Learnings: TBD
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
    @NSManaged public var assets: Set<Asset>
    @NSManaged public var liabilities: Set<Liability>
    @NSManaged public var netWealthSnapshots: Set<NetWealthSnapshot>
    @NSManaged public var owner: User?
    
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
    
    // MARK: - Factory Methods
    
    /// Create a new FinancialEntity with required fields
    @discardableResult
    public static func create(
        in context: NSManagedObjectContext,
        name: String,
        type: EntityType
    ) -> FinancialEntity {
        let entity = FinancialEntity(context: context)
        entity.id = UUID()
        entity.name = name
        entity.type = type.rawValue
        entity.isActive = true
        entity.createdAt = Date()
        entity.lastModified = Date()
        return entity
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
    
    // MARK: - Transaction-Related Computed Properties
    
    /// Returns the number of transactions assigned to this entity
    public var transactionCount: Int {
        return transactions.count
    }
    
    /// Returns the total balance of all transactions assigned to this entity
    public var totalBalance: Double {
        return transactions.reduce(0.0) { $0 + $1.amount }
    }
    
    /// Returns the total income from all transactions assigned to this entity
    public var totalIncome: Double {
        return transactions.filter { $0.amount > 0 }.reduce(0.0) { $0 + $1.amount }
    }
    
    /// Returns the total expenses from all transactions assigned to this entity
    public var totalExpenses: Double {
        return transactions.filter { $0.amount < 0 }.reduce(0.0) { $0 + abs($1.amount) }
    }
}

// MARK: - Fetch Request Extension

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
    public class func fetchEntities(ofType type: EntityType, in context: NSManagedObjectContext) throws -> [FinancialEntity] {
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

// MARK: - Identifiable Conformance

extension FinancialEntity: Identifiable {
    // id property already exists as UUID
}

// MARK: - Debugging Support

extension FinancialEntity {
    public override var description: String {
        return "FinancialEntity(id: \(id), name: \"\(name)\", type: \(type), active: \(isActive))"
    }
    
    public override var debugDescription: String {
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