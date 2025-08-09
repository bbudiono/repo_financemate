import CoreData

/// User entity definition with authentication and profile data
/// Focused responsibility: User entity configuration only
struct UserEntityDefinition {
    
    /// Create the User entity with all required attributes
    /// - Returns: Configured NSEntityDescription for User
    static func createEntity() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = "User"
        entity.managedObjectClassName = "User"
        
        // Configure all user attributes
        entity.properties = [
            createIdAttribute(),
            createEmailAttribute(),
            createFirstNameAttribute(),
            createLastNameAttribute(),
            createRoleAttribute(),
            createIsActiveAttribute(),
            createLastLoginAttribute(),
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
    
    /// Create the email attribute for real user authentication
    private static func createEmailAttribute() -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = "email"
        attribute.attributeType = .stringAttributeType
        attribute.isOptional = false
        // Validation for real email addresses only
        return attribute
    }
    
    /// Create the first name attribute
    private static func createFirstNameAttribute() -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = "firstName"
        attribute.attributeType = .stringAttributeType
        attribute.isOptional = true
        return attribute
    }
    
    /// Create the last name attribute
    private static func createLastNameAttribute() -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = "lastName"
        attribute.attributeType = .stringAttributeType
        attribute.isOptional = true
        return attribute
    }
    
    /// Create the role attribute for real user permissions
    private static func createRoleAttribute() -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = "role"
        attribute.attributeType = .stringAttributeType
        attribute.isOptional = false
        attribute.defaultValue = "User"
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
    
    /// Create the last login timestamp attribute
    private static func createLastLoginAttribute() -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = "lastLogin"
        attribute.attributeType = .dateAttributeType
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
    
    /// Create the update timestamp attribute
    private static func createUpdatedAtAttribute() -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = "updatedAt"
        attribute.attributeType = .dateAttributeType
        attribute.isOptional = true
        return attribute
    }
}