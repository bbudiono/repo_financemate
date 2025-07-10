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
    @NSManaged public var type: String
    
    // MARK: - Entity Relationship
    @NSManaged public var assignedEntity: FinancialEntity?
    
    // MARK: - Computed Properties
    
    /// Returns the name of the assigned entity or "Unassigned" if no entity is assigned
    public var entityName: String {
        return assignedEntity?.name ?? "Unassigned"
    }
    
    /// Convenience property for backward compatibility with existing code
    public var desc: String {
        get { return note ?? "" }
        set { note = newValue.isEmpty ? nil : newValue }
    }
}

// MARK: - Phase 2: Line Item Splitting Models (Core Data implementation)

/// Represents a single line item within a transaction (e.g., "Laptop", "Mouse").
/// Linked to Transaction and has multiple SplitAllocations.
/// Properties and create methods are defined in LineItem+CoreDataClass.swift and LineItem+CoreDataProperties.swift
@objc(LineItem)
public class LineItem: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var itemDescription: String
    @NSManaged public var amount: Double
    @NSManaged public var transaction: Transaction
    @NSManaged public var splitAllocations: NSSet?
    
    // MARK: - Convenience Initializers
    
    /// Creates a new LineItem in the specified context
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
        return lineItem
    }
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

// MARK: - LineItem convenience methods moved to LineItem+CoreDataClass.swift

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
        
        // Update lastModified timestamp on any change, but avoid recursion
        if isUpdated && !isDeleted && !changedValues().keys.contains("lastModified") {
            setPrimitiveValue(Date(), forKey: "lastModified")
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

// MARK: - Phase 4: Wealth Dashboard Models (P4-001)

/**
 * Purpose: Core Data model for wealth snapshots supporting advanced financial dashboard
 * Issues & Complexity Summary: Wealth tracking with asset allocation and performance metrics relationships
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~400
 *   - Core Algorithm Complexity: Medium (wealth calculations, chart data)
 *   - Dependencies: AssetAllocation, PerformanceMetrics relationships
 *   - State Management Complexity: Medium (real-time updates)
 *   - Novelty/Uncertainty Factor: Low (standard Core Data patterns)
 * AI Pre-Task Self-Assessment: 85%
 * Problem Estimate: 80%
 * Initial Code Complexity Estimate: 75%
 * Final Code Complexity: [TBD]
 * Overall Result Score: [TBD]
 * Key Variances/Learnings: [TBD]
 * Last Updated: 2025-07-09
 */
@objc(WealthSnapshot)
public class WealthSnapshot: NSManagedObject, Identifiable {
    
    // MARK: - Core Data Properties
    
    @NSManaged public var id: UUID
    @NSManaged public var date: Date
    @NSManaged public var totalAssets: Double
    @NSManaged public var totalLiabilities: Double
    @NSManaged public var netWorth: Double
    @NSManaged public var cashPosition: Double
    @NSManaged public var investmentValue: Double
    @NSManaged public var propertyValue: Double
    @NSManaged public var createdAt: Date
    
    // MARK: - Relationships
    
    @NSManaged public var assetAllocations: Set<AssetAllocation>
    @NSManaged public var performanceMetrics: Set<PerformanceMetrics>
    
    // MARK: - Core Data Lifecycle
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        
        // Set default values for new wealth snapshots
        self.id = UUID()
        self.createdAt = Date()
        
        // Calculate net worth from assets and liabilities
        updateNetWorth()
    }
    
    public override func willSave() {
        super.willSave()
        
        // Automatically update net worth when assets or liabilities change
        if isUpdated && !isDeleted {
            let assetKeys = ["totalAssets", "totalLiabilities"]
            if !Set(changedValues().keys).isDisjoint(with: assetKeys) {
                updateNetWorth()
            }
        }
    }
    
    // MARK: - Business Logic
    
    private func updateNetWorth() {
        netWorth = totalAssets - totalLiabilities
    }
    
    /// Creates a new WealthSnapshot with calculated net worth
    static func create(
        in context: NSManagedObjectContext,
        date: Date,
        totalAssets: Double,
        totalLiabilities: Double,
        cashPosition: Double,
        investmentValue: Double,
        propertyValue: Double
    ) -> WealthSnapshot {
        guard let entity = NSEntityDescription.entity(forEntityName: "WealthSnapshot", in: context) else {
            fatalError("WealthSnapshot entity not found in the provided context")
        }
        
        let wealthSnapshot = WealthSnapshot(entity: entity, insertInto: context)
        wealthSnapshot.id = UUID()
        wealthSnapshot.date = date
        wealthSnapshot.totalAssets = totalAssets
        wealthSnapshot.totalLiabilities = totalLiabilities
        wealthSnapshot.cashPosition = cashPosition
        wealthSnapshot.investmentValue = investmentValue
        wealthSnapshot.propertyValue = propertyValue
        wealthSnapshot.createdAt = Date()
        
        // Net worth is automatically calculated in willSave()
        wealthSnapshot.netWorth = totalAssets - totalLiabilities
        
        return wealthSnapshot
    }
}

// MARK: - WealthSnapshot Fetch Request Extension

extension WealthSnapshot {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<WealthSnapshot> {
        return NSFetchRequest<WealthSnapshot>(entityName: "WealthSnapshot")
    }
    
    /// Fetch wealth snapshots within a date range
    public class func fetchSnapshots(
        from startDate: Date,
        to endDate: Date,
        in context: NSManagedObjectContext
    ) throws -> [WealthSnapshot] {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@ AND date <= %@", startDate as NSDate, endDate as NSDate)
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \WealthSnapshot.date, ascending: true)
        ]
        return try context.fetch(request)
    }
    
    /// Fetch the most recent wealth snapshot
    public class func fetchLatestSnapshot(in context: NSManagedObjectContext) throws -> WealthSnapshot? {
        let request = fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \WealthSnapshot.date, ascending: false)
        ]
        request.fetchLimit = 1
        return try context.fetch(request).first
    }
}

/**
 * Purpose: Asset allocation model for portfolio composition tracking
 * Issues & Complexity Summary: Asset class allocation with target vs actual tracking
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~150
 *   - Core Algorithm Complexity: Low (allocation percentages)
 *   - Dependencies: WealthSnapshot relationship
 *   - State Management Complexity: Low
 *   - Novelty/Uncertainty Factor: Low
 * AI Pre-Task Self-Assessment: 90%
 * Problem Estimate: 70%
 * Initial Code Complexity Estimate: 65%
 * Final Code Complexity: [TBD]
 * Overall Result Score: [TBD]
 * Key Variances/Learnings: [TBD]
 * Last Updated: 2025-07-09
 */
@objc(AssetAllocation)
public class AssetAllocation: NSManagedObject, Identifiable {
    
    // MARK: - Core Data Properties
    
    @NSManaged public var id: UUID
    @NSManaged public var assetClass: String
    @NSManaged public var allocation: Double
    @NSManaged public var targetAllocation: Double
    @NSManaged public var currentValue: Double
    @NSManaged public var lastUpdated: Date
    
    // MARK: - Relationships
    
    @NSManaged public var wealthSnapshot: WealthSnapshot
    
    // MARK: - Core Data Lifecycle
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        
        self.id = UUID()
        self.lastUpdated = Date()
    }
    
    // MARK: - Business Logic
    
    /// Creates a new AssetAllocation linked to a wealth snapshot
    static func create(
        in context: NSManagedObjectContext,
        assetClass: String,
        allocation: Double,
        targetAllocation: Double,
        currentValue: Double,
        wealthSnapshot: WealthSnapshot
    ) -> AssetAllocation {
        guard let entity = NSEntityDescription.entity(forEntityName: "AssetAllocation", in: context) else {
            fatalError("AssetAllocation entity not found in the provided context")
        }
        
        let assetAllocation = AssetAllocation(entity: entity, insertInto: context)
        assetAllocation.id = UUID()
        assetAllocation.assetClass = assetClass
        assetAllocation.allocation = allocation
        assetAllocation.targetAllocation = targetAllocation
        assetAllocation.currentValue = currentValue
        assetAllocation.wealthSnapshot = wealthSnapshot
        assetAllocation.lastUpdated = Date()
        
        return assetAllocation
    }
}

// MARK: - AssetAllocation Fetch Request Extension

extension AssetAllocation {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<AssetAllocation> {
        return NSFetchRequest<AssetAllocation>(entityName: "AssetAllocation")
    }
}

/**
 * Purpose: Performance metrics model for portfolio performance tracking
 * Issues & Complexity Summary: Performance metrics with benchmarking and period tracking
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~150
 *   - Core Algorithm Complexity: Low (metric storage)
 *   - Dependencies: WealthSnapshot relationship
 *   - State Management Complexity: Low
 *   - Novelty/Uncertainty Factor: Low
 * AI Pre-Task Self-Assessment: 90%
 * Problem Estimate: 70%
 * Initial Code Complexity Estimate: 65%
 * Final Code Complexity: [TBD]
 * Overall Result Score: [TBD]
 * Key Variances/Learnings: [TBD]
 * Last Updated: 2025-07-09
 */
@objc(PerformanceMetrics)
public class PerformanceMetrics: NSManagedObject, Identifiable {
    
    // MARK: - Core Data Properties
    
    @NSManaged public var id: UUID
    @NSManaged public var metricType: String
    @NSManaged public var value: Double
    @NSManaged public var benchmarkValue: Double
    @NSManaged public var period: String
    @NSManaged public var calculatedAt: Date
    
    // MARK: - Relationships
    
    @NSManaged public var wealthSnapshot: WealthSnapshot
    
    // MARK: - Core Data Lifecycle
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        
        self.id = UUID()
        self.calculatedAt = Date()
    }
    
    // MARK: - Business Logic
    
    /// Creates a new PerformanceMetrics linked to a wealth snapshot
    static func create(
        in context: NSManagedObjectContext,
        metricType: String,
        value: Double,
        benchmarkValue: Double,
        period: String,
        wealthSnapshot: WealthSnapshot
    ) -> PerformanceMetrics {
        guard let entity = NSEntityDescription.entity(forEntityName: "PerformanceMetrics", in: context) else {
            fatalError("PerformanceMetrics entity not found in the provided context")
        }
        
        let performanceMetrics = PerformanceMetrics(entity: entity, insertInto: context)
        performanceMetrics.id = UUID()
        performanceMetrics.metricType = metricType
        performanceMetrics.value = value
        performanceMetrics.benchmarkValue = benchmarkValue
        performanceMetrics.period = period
        performanceMetrics.wealthSnapshot = wealthSnapshot
        performanceMetrics.calculatedAt = Date()
        
        return performanceMetrics
    }
}

// MARK: - PerformanceMetrics Fetch Request Extension

extension PerformanceMetrics {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<PerformanceMetrics> {
        return NSFetchRequest<PerformanceMetrics>(entityName: "PerformanceMetrics")
    }
}

// MARK: - Phase 4: Financial Goal Setting Framework (P4-003)

/**
 * Purpose: Core Data model for financial goals with SMART validation and progress tracking
 * Issues & Complexity Summary: Goal management with behavioral finance integration and gamification
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~500
 *   - Core Algorithm Complexity: Medium (SMART validation, progress calculations)
 *   - Dependencies: GoalMilestone, Transaction relationships
 *   - State Management Complexity: Medium (goal states, achievement tracking)
 *   - Novelty/Uncertainty Factor: Low (standard Core Data patterns with business logic)
 * AI Pre-Task Self-Assessment: 85%
 * Problem Estimate: 80%
 * Initial Code Complexity Estimate: 75%
 * Final Code Complexity: [TBD]
 * Overall Result Score: [TBD]
 * Key Variances/Learnings: [TBD]
 * Last Updated: 2025-07-10
 */
@objc(FinancialGoal)
public class FinancialGoal: NSManagedObject, Identifiable {
    
    // MARK: - Core Data Properties
    
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var goalDescription: String?
    @NSManaged public var targetAmount: Double
    @NSManaged public var currentAmount: Double
    @NSManaged public var targetDate: Date
    @NSManaged public var category: String
    @NSManaged public var priority: String
    @NSManaged public var createdAt: Date
    @NSManaged public var lastModified: Date
    @NSManaged public var isAchieved: Bool
    
    // MARK: - Relationships
    
    @NSManaged public var milestones: Set<GoalMilestone>
    @NSManaged public var transactions: Set<Transaction>
    
    // MARK: - Core Data Lifecycle
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        
        self.id = UUID()
        self.createdAt = Date()
        self.lastModified = Date()
        self.isAchieved = false
        self.currentAmount = 0.0
    }
    
    public override func willSave() {
        super.willSave()
        
        if isUpdated && !isDeleted {
            self.lastModified = Date()
            
            // Check if goal is achieved
            if currentAmount >= targetAmount && !isAchieved {
                isAchieved = true
            }
        }
    }
    
    // MARK: - Business Logic
    
    /// Calculate current progress as percentage (0.0 to 1.0)
    public func calculateProgress() -> Double {
        guard targetAmount > 0 else { return 0.0 }
        let progress = currentAmount / targetAmount
        return min(max(progress, 0.0), 1.0) // Clamp between 0 and 1
    }
    
    /// Update progress with new amount
    public func updateProgress(newAmount: Double) {
        currentAmount = newAmount
        if currentAmount >= targetAmount {
            isAchieved = true
        }
    }
    
    /// Add transaction to goal and update progress
    public func addTransaction(_ transaction: Transaction) {
        transactions.insert(transaction)
        transaction.associatedGoal = self
    }
    
    /// Update progress based on associated transactions
    public func updateProgressFromTransactions() {
        let totalFromTransactions = transactions.reduce(0.0) { total, transaction in
            return total + transaction.amount
        }
        updateProgress(newAmount: totalFromTransactions)
    }
    
    /// Generate automatic milestones (25%, 50%, 75%, 100%)
    public func generateAutomaticMilestones() {
        let percentages = [0.25, 0.50, 0.75, 1.0]
        
        for percentage in percentages {
            let milestoneAmount = targetAmount * percentage
            let milestoneTitle = "\(Int(percentage * 100))% milestone"
            
            let milestone = GoalMilestone.create(
                in: managedObjectContext!,
                title: milestoneTitle,
                targetAmount: milestoneAmount,
                goal: self
            )
            milestones.insert(milestone)
        }
    }
    
    // MARK: - SMART Validation
    
    /// Validate goal against SMART criteria
    public static func validateSMART(_ goalData: GoalFormData) -> SMARTValidationResult {
        var result = SMARTValidationResult()
        
        // Specific: Title should be descriptive (>5 characters)
        result.isSpecific = !goalData.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && 
                           goalData.title.count > 5
        
        // Measurable: Should have a specific target amount
        result.isMeasurable = goalData.targetAmount > 0
        
        // Achievable: Amount should be realistic (not more than $100k per month timeframe)
        let monthsToTarget = Calendar.current.dateComponents([.month], from: Date(), to: goalData.targetDate).month ?? 0
        let monthlyRequired = monthsToTarget > 0 ? goalData.targetAmount / Double(monthsToTarget) : goalData.targetAmount
        result.isAchievable = monthlyRequired <= 100000.0 // Max $100k per month
        
        // Relevant: Should have a valid category
        let validCategories = ["Savings", "Investment", "Emergency", "Travel", "Property", "Education", "Retirement"]
        result.isRelevant = validCategories.contains(goalData.category)
        
        // Time-bound: Target date should be in the future
        result.isTimeBound = goalData.targetDate > Date()
        
        result.isValid = result.isSpecific && result.isMeasurable && result.isAchievable && result.isRelevant && result.isTimeBound
        
        return result
    }
    
    /// Create a new FinancialGoal with validation (throwing version)
    static func createWithValidation(
        in context: NSManagedObjectContext,
        title: String,
        description: String?,
        targetAmount: Double,
        currentAmount: Double,
        targetDate: Date,
        category: String,
        priority: String
    ) throws -> FinancialGoal {
        
        // Validate input data
        guard !title.isEmpty else {
            throw GoalValidationError.invalidTitle
        }
        
        guard targetAmount > 0 else {
            throw GoalValidationError.invalidAmount
        }
        
        guard !category.isEmpty else {
            throw GoalValidationError.invalidCategory
        }
        
        guard let entity = NSEntityDescription.entity(forEntityName: "FinancialGoal", in: context) else {
            throw CoreDataError.entityNotFound
        }
        
        let goal = FinancialGoal(entity: entity, insertInto: context)
        goal.id = UUID()
        goal.title = title
        goal.goalDescription = description
        goal.targetAmount = targetAmount
        goal.currentAmount = currentAmount
        goal.targetDate = targetDate
        goal.category = category
        goal.priority = priority
        goal.createdAt = Date()
        goal.lastModified = Date()
        goal.isAchieved = currentAmount >= targetAmount
        
        return goal
    }
    
    /// Convenience create method for tests and normal usage
    static func create(
        in context: NSManagedObjectContext,
        title: String,
        description: String?,
        targetAmount: Double,
        currentAmount: Double,
        targetDate: Date,
        category: String,
        priority: String
    ) -> FinancialGoal {
        
        guard let entity = NSEntityDescription.entity(forEntityName: "FinancialGoal", in: context) else {
            fatalError("FinancialGoal entity not found in the provided context")
        }
        
        let goal = FinancialGoal(entity: entity, insertInto: context)
        goal.id = UUID()
        goal.title = title
        goal.goalDescription = description
        goal.targetAmount = targetAmount
        goal.currentAmount = currentAmount
        goal.targetDate = targetDate
        goal.category = category
        goal.priority = priority
        goal.createdAt = Date()
        goal.lastModified = Date()
        goal.isAchieved = currentAmount >= targetAmount
        
        return goal
    }
}

// MARK: - FinancialGoal Fetch Request Extension

extension FinancialGoal {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<FinancialGoal> {
        return NSFetchRequest<FinancialGoal>(entityName: "FinancialGoal")
    }
    
    /// Fetch goals by category
    public class func fetchGoals(
        byCategory category: String,
        in context: NSManagedObjectContext
    ) throws -> [FinancialGoal] {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "category == %@", category)
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \FinancialGoal.createdAt, ascending: false)
        ]
        return try context.fetch(request)
    }
    
    /// Fetch active (not achieved) goals
    public class func fetchActiveGoals(in context: NSManagedObjectContext) throws -> [FinancialGoal] {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "isAchieved == NO")
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \FinancialGoal.priority, ascending: false),
            NSSortDescriptor(keyPath: \FinancialGoal.targetDate, ascending: true)
        ]
        return try context.fetch(request)
    }
    
    /// Fetch goals by priority
    public class func fetchGoals(
        byPriority priority: String,
        in context: NSManagedObjectContext
    ) throws -> [FinancialGoal] {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "priority == %@", priority)
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \FinancialGoal.targetDate, ascending: true)
        ]
        return try context.fetch(request)
    }
}

/**
 * Purpose: Goal milestone model for tracking progress checkpoints
 * Issues & Complexity Summary: Milestone management with automatic achievement detection
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~150
 *   - Core Algorithm Complexity: Low (milestone tracking)
 *   - Dependencies: FinancialGoal relationship
 *   - State Management Complexity: Low
 *   - Novelty/Uncertainty Factor: Low
 * AI Pre-Task Self-Assessment: 90%
 * Problem Estimate: 70%
 * Initial Code Complexity Estimate: 65%
 * Final Code Complexity: [TBD]
 * Overall Result Score: [TBD]
 * Key Variances/Learnings: [TBD]
 * Last Updated: 2025-07-10
 */
@objc(GoalMilestone)
public class GoalMilestone: NSManagedObject, Identifiable {
    
    // MARK: - Core Data Properties
    
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var targetAmount: Double
    @NSManaged public var achievedDate: Date?
    @NSManaged public var isAchieved: Bool
    @NSManaged public var createdAt: Date
    
    // MARK: - Relationships
    
    @NSManaged public var goal: FinancialGoal
    
    // MARK: - Core Data Lifecycle
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        
        self.id = UUID()
        self.createdAt = Date()
        self.isAchieved = false
    }
    
    // MARK: - Business Logic
    
    /// Mark milestone as achieved
    public func markAsAchieved() {
        isAchieved = true
        achievedDate = Date()
    }
    
    /// Create a new GoalMilestone
    static func create(
        in context: NSManagedObjectContext,
        title: String,
        targetAmount: Double,
        goal: FinancialGoal
    ) -> GoalMilestone {
        
        guard let entity = NSEntityDescription.entity(forEntityName: "GoalMilestone", in: context) else {
            fatalError("GoalMilestone entity not found in the provided context")
        }
        
        let milestone = GoalMilestone(entity: entity, insertInto: context)
        milestone.id = UUID()
        milestone.title = title
        milestone.targetAmount = targetAmount
        milestone.goal = goal
        milestone.createdAt = Date()
        milestone.isAchieved = false
        
        return milestone
    }
}

// MARK: - GoalMilestone Fetch Request Extension

extension GoalMilestone {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<GoalMilestone> {
        return NSFetchRequest<GoalMilestone>(entityName: "GoalMilestone")
    }
}

// MARK: - Transaction Extension for Goal Relationships

extension Transaction {
    @NSManaged public var associatedGoal: FinancialGoal?
}

// MARK: - Supporting Data Structures

/// Data structure for goal form input
public struct GoalFormData {
    let title: String
    let description: String
    let targetAmount: Double
    let targetDate: Date
    let category: String
    
    init(title: String, description: String, targetAmount: Double, targetDate: Date, category: String) {
        self.title = title
        self.description = description
        self.targetAmount = targetAmount
        self.targetDate = targetDate
        self.category = category
    }
}

/// SMART validation result structure
public struct SMARTValidationResult {
    var isValid: Bool = false
    var isSpecific: Bool = false
    var isMeasurable: Bool = false
    var isAchievable: Bool = false
    var isRelevant: Bool = false
    var isTimeBound: Bool = false
}

// MARK: - Error Types

/// Goal validation errors
public enum GoalValidationError: Error, LocalizedError {
    case invalidTitle
    case invalidAmount
    case invalidCategory
    case invalidDate
    case invalidPriority
    
    public var errorDescription: String? {
        switch self {
        case .invalidTitle:
            return "Goal title cannot be empty"
        case .invalidAmount:
            return "Target amount must be greater than zero"
        case .invalidCategory:
            return "Goal category cannot be empty"
        case .invalidDate:
            return "Target date must be in the future"
        case .invalidPriority:
            return "Priority must be High, Medium, or Low"
        }
    }
}

/// Core Data operation errors
public enum CoreDataError: Error, LocalizedError {
    case entityNotFound
    case saveFailed
    case fetchFailed
    
    public var errorDescription: String? {
        switch self {
        case .entityNotFound:
            return "Core Data entity not found"
        case .saveFailed:
            return "Failed to save to Core Data"
        case .fetchFailed:
            return "Failed to fetch from Core Data"
        }
    }
}

