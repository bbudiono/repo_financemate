import CoreData

/// SplitAllocation entity definition for tax and allocation management
/// Focused responsibility: SplitAllocation entity configuration only
struct SplitAllocationEntityDefinition {
    
    /// Create the SplitAllocation entity with all required attributes
    /// - Returns: Configured NSEntityDescription for SplitAllocation
    static func createEntity() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = "SplitAllocation"
        entity.managedObjectClassName = "SplitAllocation"
        
        // Configure all split allocation attributes
        entity.properties = [
            createIdAttribute(),
            createPercentageAttribute(),
            createTaxCategoryAttribute()
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
    
    /// Create the percentage allocation attribute
    private static func createPercentageAttribute() -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = "percentage"
        attribute.attributeType = .doubleAttributeType
        attribute.isOptional = false
        return attribute
    }
    
    /// Create the tax category attribute for real tax calculations
    private static func createTaxCategoryAttribute() -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = "taxCategory"
        attribute.attributeType = .stringAttributeType
        attribute.isOptional = false
        return attribute
    }
}