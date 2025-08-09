import CoreData

/// LineItem entity definition for transaction detail breakdown
/// Focused responsibility: LineItem entity configuration only
struct LineItemEntityDefinition {
    
    /// Create the LineItem entity with all required attributes
    /// - Returns: Configured NSEntityDescription for LineItem
    static func createEntity() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = "LineItem"
        entity.managedObjectClassName = "LineItem"
        
        // Configure all line item attributes
        entity.properties = [
            createIdAttribute(),
            createItemDescriptionAttribute(),
            createAmountAttribute()
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
    
    /// Create the item description attribute
    private static func createItemDescriptionAttribute() -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = "itemDescription"
        attribute.attributeType = .stringAttributeType
        attribute.isOptional = false
        return attribute
    }
    
    /// Create the amount attribute for real financial line items
    private static func createAmountAttribute() -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = "amount"
        attribute.attributeType = .doubleAttributeType
        attribute.isOptional = false
        return attribute
    }
}