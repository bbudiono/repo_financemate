import CoreData

/// Core Data model definition with programmatic entity configuration
/// Focused responsibility: Entity, attribute, and relationship definitions
class CoreDataModel {
    
    /// Shared singleton instance to prevent duplicate entity registrations
    static let shared = CoreDataModel()
    
    /// The complete managed object model with all entities
    let managedObjectModel: NSManagedObjectModel
    
    /// Private initializer to create the complete model
    private init() {
        managedObjectModel = Self.createManagedObjectModel()
    }
    
    /// Create the complete Core Data model programmatically
    /// - Returns: Configured NSManagedObjectModel with all entities
    private static func createManagedObjectModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()
        
        // Create only the entities that have EntityDefinition classes implemented
        let transactionEntity = TransactionEntityDefinition.createEntity()
        let lineItemEntity = LineItemEntityDefinition.createEntity()
        let splitAllocationEntity = SplitAllocationEntityDefinition.createEntity()
        let userEntity = UserEntityDefinition.createEntity()
        let assetEntity = AssetEntityDefinition.createEntity()
        
        // Configure relationships between implemented entities
        RelationshipConfigurator.configureAllRelationships(
            transaction: transactionEntity,
            lineItem: lineItemEntity,
            splitAllocation: splitAllocationEntity,
            user: userEntity,
            asset: assetEntity,
            liability: nil,
            netWealthSnapshot: nil,
            assetValuation: nil,
            auditLog: nil,
            financialEntity: nil
        )
        
        // Add implemented entities to the model
        model.entities = [
            transactionEntity,
            lineItemEntity,
            splitAllocationEntity,
            userEntity,
            assetEntity
        ]
        
        return model
    }
}