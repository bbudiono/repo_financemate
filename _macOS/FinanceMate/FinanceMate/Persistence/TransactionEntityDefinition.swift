import CoreData

/// Transaction entity definition with real financial data attributes
/// Focused responsibility: Transaction entity configuration only
struct TransactionEntityDefinition {
    
    /// Create the Transaction entity with all required attributes
    /// - Returns: Configured NSEntityDescription for Transaction
    static func createEntity() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = "Transaction"
        entity.managedObjectClassName = "Transaction"
        
        // Configure all transaction attributes
        entity.properties = [
            createIdAttribute(),
            createDateAttribute(),
            createAmountAttribute(),
            createCategoryAttribute(),
            createNoteAttribute(),
            createCreatedAtAttribute()
        ]
        
        return entity
    }
    
    /// Create the unique identifier attribute
    private static func createIdAttribute() -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = "id"
        attribute.attributeType = .UUIDAttributeType
        attribute.isOptional = false
        return attribute
    }
    
    /// Create the transaction date attribute
    private static func createDateAttribute() -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = "date"
        attribute.attributeType = .dateAttributeType
        attribute.isOptional = false
        return attribute
    }
    
    /// Create the financial amount attribute for real user data
    private static func createAmountAttribute() -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = "amount"
        attribute.attributeType = .doubleAttributeType
        attribute.isOptional = false
        // Validation for real financial data
        attribute.attributeValueClassName = "NSNumber"
        return attribute
    }
    
    /// Create the transaction category attribute
    private static func createCategoryAttribute() -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = "category"
        attribute.attributeType = .stringAttributeType
        attribute.isOptional = false
        return attribute
    }
    
    /// Create the optional note attribute
    private static func createNoteAttribute() -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = "note"
        attribute.attributeType = .stringAttributeType
        attribute.isOptional = true
        return attribute
    }
    
    /// Create the creation timestamp attribute
    private static func createCreatedAtAttribute() -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = "createdAt"
        attribute.attributeType = .dateAttributeType
        attribute.isOptional = false
        return attribute
    }
}