import CoreData

/// Remaining entity definitions for complete Core Data model
/// Focused responsibility: Additional entity configurations

// MARK: - Liability Entity Definition
struct LiabilityEntityDefinition {
    static func createEntity() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = "Liability"
        entity.managedObjectClassName = "Liability"
        entity.properties = [createBasicAttributes()]
        return entity
    }
    
    private static func createBasicAttributes() -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = "id"
        attribute.attributeType = .UUIDAttributeType
        attribute.isOptional = false
        return attribute
    }
}

// MARK: - NetWealthSnapshot Entity Definition
struct NetWealthSnapshotEntityDefinition {
    static func createEntity() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = "NetWealthSnapshot"
        entity.managedObjectClassName = "NetWealthSnapshot"
        entity.properties = [createBasicAttributes()]
        return entity
    }
    
    private static func createBasicAttributes() -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = "id"
        attribute.attributeType = .UUIDAttributeType
        attribute.isOptional = false
        return attribute
    }
}

// MARK: - AssetValuation Entity Definition
struct AssetValuationEntityDefinition {
    static func createEntity() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = "AssetValuation"
        entity.managedObjectClassName = "AssetValuation"
        entity.properties = [createBasicAttributes()]
        return entity
    }
    
    private static func createBasicAttributes() -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = "id"
        attribute.attributeType = .UUIDAttributeType
        attribute.isOptional = false
        return attribute
    }
}

// MARK: - AuditLog Entity Definition
struct AuditLogEntityDefinition {
    static func createEntity() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = "AuditLog"
        entity.managedObjectClassName = "AuditLog"
        entity.properties = [createBasicAttributes()]
        return entity
    }
    
    private static func createBasicAttributes() -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = "id"
        attribute.attributeType = .UUIDAttributeType
        attribute.isOptional = false
        return attribute
    }
}

// MARK: - FinancialEntity Entity Definition
struct FinancialEntityEntityDefinition {
    static func createEntity() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = "FinancialEntity"
        entity.managedObjectClassName = "FinancialEntity"
        entity.properties = [createBasicAttributes()]
        return entity
    }
    
    private static func createBasicAttributes() -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = "id"
        attribute.attributeType = .UUIDAttributeType
        attribute.isOptional = false
        return attribute
    }
}