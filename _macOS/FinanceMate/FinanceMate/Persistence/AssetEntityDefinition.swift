import CoreData

/// Asset entity definition with real financial asset data
/// Focused responsibility: Asset entity configuration only
struct AssetEntityDefinition {
    
    /// Create the Asset entity with all required attributes
    /// - Returns: Configured NSEntityDescription for Asset
    static func createEntity() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = "Asset"
        entity.managedObjectClassName = "Asset"
        
        // Configure all asset attributes
        entity.properties = [
            createIdAttribute(),
            createNameAttribute(),
            createAssetTypeAttribute(),
            createCurrentValueAttribute(),
            createAcquisitionCostAttribute(),
            createAcquisitionDateAttribute(),
            createDescriptionAttribute(),
            createLocationAttribute(),
            createOwnershipPercentageAttribute(),
            createIsActiveAttribute(),
            createCreatedAtAttribute(),
            createUpdatedAtAttribute()
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
    
    /// Create the asset name attribute
    private static func createNameAttribute() -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = "name"
        attribute.attributeType = .stringAttributeType
        attribute.isOptional = false
        return attribute
    }
    
    /// Create the asset type attribute for real asset categorization
    private static func createAssetTypeAttribute() -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = "assetType"
        attribute.attributeType = .stringAttributeType
        attribute.isOptional = false
        // Real asset types: property, investment, cash, business, vehicle, other
        return attribute
    }
    
    /// Create the current value attribute for real asset valuation
    private static func createCurrentValueAttribute() -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = "currentValue"
        attribute.attributeType = .doubleAttributeType
        attribute.isOptional = false
        // Must contain real financial values only
        return attribute
    }
    
    /// Create the acquisition cost attribute
    private static func createAcquisitionCostAttribute() -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = "acquisitionCost"
        attribute.attributeType = .doubleAttributeType
        attribute.isOptional = true
        return attribute
    }
    
    /// Create the acquisition date attribute
    private static func createAcquisitionDateAttribute() -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = "acquisitionDate"
        attribute.attributeType = .dateAttributeType
        attribute.isOptional = true
        return attribute
    }
    
    /// Create the description attribute
    private static func createDescriptionAttribute() -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = "assetDescription"
        attribute.attributeType = .stringAttributeType
        attribute.isOptional = true
        return attribute
    }
    
    /// Create the location attribute
    private static func createLocationAttribute() -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = "location"
        attribute.attributeType = .stringAttributeType
        attribute.isOptional = true
        return attribute
    }
    
    /// Create the ownership percentage attribute
    private static func createOwnershipPercentageAttribute() -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = "ownershipPercentage"
        attribute.attributeType = .doubleAttributeType
        attribute.isOptional = false
        attribute.defaultValue = 100.0  // Default to full ownership
        return attribute
    }
    
    /// Create the active status attribute
    private static func createIsActiveAttribute() -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = "isActive"
        attribute.attributeType = .booleanAttributeType
        attribute.isOptional = false
        attribute.defaultValue = true
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
    
    /// Create the update timestamp attribute
    private static func createUpdatedAtAttribute() -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = "updatedAt"
        attribute.attributeType = .dateAttributeType
        attribute.isOptional = true
        return attribute
    }
}