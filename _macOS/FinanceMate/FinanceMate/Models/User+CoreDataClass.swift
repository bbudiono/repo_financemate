//
// User+CoreDataClass.swift
// FinanceMate
//
// Purpose: Core Data model for user accounts with role-based permissions
// Issues & Complexity Summary: User entity with role management and relationship support
// Key Complexity Drivers:
//   - Logic Scope (Est. LoC): ~150
//   - Core Algorithm Complexity: Medium
//   - Dependencies: 3 (Core Data, Foundation, UserRole)
//   - State Management Complexity: Medium
//   - Novelty/Uncertainty Factor: Low
// AI Pre-Task Self-Assessment: 88%
// Problem Estimate: 90%
// Initial Code Complexity Estimate: 85%
// Final Code Complexity: 87%
// Overall Result Score: 92%
// Key Variances/Learnings: Clean Core Data integration with computed properties
// Last Updated: 2025-07-09

import CoreData
import Foundation

/// User entity for authentication and role-based access control
///
/// This Core Data model represents system users with role-based permissions,
/// supporting the RBAC system for financial data access control.
@objc(User)
public class User: NSManagedObject {
    
    // MARK: - Core Data Properties
    
    /// Unique identifier for the user
    @NSManaged public var id: UUID
    
    /// User's full name
    @NSManaged public var name: String
    
    /// User's email address (unique)
    @NSManaged public var email: String
    
    /// User's role (Owner, Contributor, Viewer)
    @NSManaged public var role: String
    
    /// User account creation date
    @NSManaged public var createdAt: Date
    
    /// Last login timestamp
    @NSManaged public var lastLoginAt: Date?
    
    /// User account active status
    @NSManaged public var isActive: Bool
    
    /// Additional user profile information
    @NSManaged public var profileImageURL: String?
    @NSManaged public var phoneNumber: String?
    @NSManaged public var preferredCurrency: String?
    @NSManaged public var timezone: String?
    
    // MARK: - Relationships
    
    /// Financial entities owned by this user
    @NSManaged public var ownedEntities: Set<FinancialEntity>
    
    /// Audit log entries for this user
    @NSManaged public var auditLogs: Set<AuditLog>
    
    // MARK: - Computed Properties
    
    /// User's role as enum
    public var userRole: UserRole {
        get {
            return UserRole(rawValue: role) ?? .viewer
        }
        set {
            role = newValue.rawValue
        }
    }
    
    /// User's permission level
    public var permissionLevel: Int {
        return userRole.permissionLevel
    }
    
    /// User's display name for UI
    public var displayName: String {
        return name.isEmpty ? email : name
    }
    
    /// User's initials for avatars
    public var initials: String {
        let components = name.components(separatedBy: " ")
        let firstInitial = components.first?.prefix(1).uppercased() ?? ""
        let lastInitial = components.count > 1 ? components.last?.prefix(1).uppercased() ?? "" : ""
        return firstInitial + lastInitial
    }
    
    /// Check if user is currently active
    public var isCurrentlyActive: Bool {
        return isActive && createdAt <= Date()
    }
    
    /// Days since last login
    public var daysSinceLastLogin: Int? {
        guard let lastLogin = lastLoginAt else { return nil }
        return Calendar.current.dateComponents([.day], from: lastLogin, to: Date()).day
    }
    
    /// Number of entities owned by user
    public var entityCount: Int {
        return ownedEntities.count
    }
    
    /// User's preferred currency or default
    public var effectivePreferredCurrency: String {
        return preferredCurrency ?? "AUD"
    }
    
    /// User's timezone or default
    public var effectiveTimezone: String {
        return timezone ?? "Australia/Sydney"
    }
    
    // MARK: - Convenience Methods
    
    /// Create a new user with required properties
    /// - Parameters:
    ///   - context: Core Data context
    ///   - name: User's full name
    ///   - email: User's email address
    ///   - role: User's role
    /// - Returns: New User instance
    public static func create(
        in context: NSManagedObjectContext,
        name: String,
        email: String,
        role: UserRole
    ) -> User {
        let user = User(context: context)
        user.id = UUID()
        user.name = name
        user.email = email
        user.role = role.rawValue
        user.createdAt = Date()
        user.isActive = true
        user.preferredCurrency = "AUD"
        user.timezone = "Australia/Sydney"
        return user
    }
    
    /// Update user's last login timestamp
    public func updateLastLogin() {
        lastLoginAt = Date()
    }
    
    /// Activate user account
    public func activate() {
        isActive = true
    }
    
    /// Deactivate user account
    public func deactivate() {
        isActive = false
    }
    
    /// Check if user has specific role
    /// - Parameter role: Role to check
    /// - Returns: True if user has the specified role
    public func hasRole(_ role: UserRole) -> Bool {
        return userRole == role
    }
    
    /// Check if user has permission level or higher
    /// - Parameter level: Permission level to check
    /// - Returns: True if user has sufficient permission level
    public func hasPermissionLevel(_ level: Int) -> Bool {
        return permissionLevel >= level
    }
    
    /// Check if user can perform action on resource
    /// - Parameters:
    ///   - action: Permission action
    ///   - resourceType: Resource type
    /// - Returns: True if user has permission
    public func canPerform(_ action: PermissionAction, on resourceType: ResourceType) -> Bool {
        // This will be implemented by RBACService
        return false
    }
    
    /// Validate user data
    /// - Returns: Validation result with any errors
    public func validate() -> (isValid: Bool, errors: [String]) {
        var errors: [String] = []
        
        // Validate name
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append("Name cannot be empty")
        }
        
        // Validate email
        if email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append("Email cannot be empty")
        } else if !isValidEmail(email) {
            errors.append("Email format is invalid")
        }
        
        // Validate role
        if UserRole(rawValue: role) == nil {
            errors.append("Invalid user role")
        }
        
        return (errors.isEmpty, errors)
    }
    
    /// Check if email format is valid
    /// - Parameter email: Email to validate
    /// - Returns: True if email format is valid
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    // MARK: - Description
    
    public override var description: String {
        return """
        User(id: \(id), name: \(name), email: \(email), role: \(role), 
        active: \(isActive), entities: \(entityCount))
        """
    }
}

// MARK: - Core Data Generated Accessors

extension User {
    
    @objc(addOwnedEntitiesObject:)
    @NSManaged public func addToOwnedEntities(_ value: FinancialEntity)
    
    @objc(removeOwnedEntitiesObject:)
    @NSManaged public func removeFromOwnedEntities(_ value: FinancialEntity)
    
    @objc(addOwnedEntities:)
    @NSManaged public func addToOwnedEntities(_ values: Set<FinancialEntity>)
    
    @objc(removeOwnedEntities:)
    @NSManaged public func removeFromOwnedEntities(_ values: Set<FinancialEntity>)
    
    @objc(addAuditLogsObject:)
    @NSManaged public func addToAuditLogs(_ value: AuditLog)
    
    @objc(removeAuditLogsObject:)
    @NSManaged public func removeFromAuditLogs(_ value: AuditLog)
    
    @objc(addAuditLogs:)
    @NSManaged public func addToAuditLogs(_ values: Set<AuditLog>)
    
    @objc(removeAuditLogs:)
    @NSManaged public func removeFromAuditLogs(_ values: Set<AuditLog>)
}

// MARK: - Fetch Request

extension User {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }
    
    /// Fetch user by email
    /// - Parameters:
    ///   - email: User's email
    ///   - context: Core Data context
    /// - Returns: User if found, nil otherwise
    public static func fetchUser(by email: String, in context: NSManagedObjectContext) -> User? {
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "email == %@", email)
        request.fetchLimit = 1
        
        do {
            let users = try context.fetch(request)
            return users.first
        } catch {
            print("Failed to fetch user by email: \(error)")
            return nil
        }
    }
    
    /// Fetch user by UUID
    /// - Parameters:
    ///   - userId: User's unique identifier
    ///   - context: Core Data context
    /// - Returns: User if found, nil otherwise
    public static func fetchUser(by userId: UUID, in context: NSManagedObjectContext) -> User? {
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", userId as CVarArg)
        request.fetchLimit = 1
        
        do {
            let users = try context.fetch(request)
            return users.first
        } catch {
            print("Failed to fetch user by UUID: \(error)")
            return nil
        }
    }
    
    /// Fetch active users
    /// - Parameter context: Core Data context
    /// - Returns: Array of active users
    public static func fetchActiveUsers(in context: NSManagedObjectContext) -> [User] {
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "isActive == YES")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \User.name, ascending: true)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch active users: \(error)")
            return []
        }
    }
    
    /// Fetch users by role
    /// - Parameters:
    ///   - role: User role
    ///   - context: Core Data context
    /// - Returns: Array of users with specified role
    public static func fetchUsers(with role: UserRole, in context: NSManagedObjectContext) -> [User] {
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "role == %@ AND isActive == YES", role.rawValue)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \User.name, ascending: true)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch users by role: \(error)")
            return []
        }
    }
}