//
// AuditLog+CoreDataClass.swift
// FinanceMate
//
// Purpose: Core Data model for audit trail logging in RBAC system
// Issues & Complexity Summary: Audit logging for security and compliance tracking
// Key Complexity Drivers:
//   - Logic Scope (Est. LoC): ~100
//   - Core Algorithm Complexity: Low
//   - Dependencies: 2 (Core Data, Foundation)
//   - State Management Complexity: Low
//   - Novelty/Uncertainty Factor: Low
// AI Pre-Task Self-Assessment: 92%
// Problem Estimate: 95%
// Initial Code Complexity Estimate: 75%
// Final Code Complexity: 78%
// Overall Result Score: 94%
// Key Variances/Learnings: Straightforward audit logging implementation
// Last Updated: 2025-07-09

import CoreData
import Foundation

/// Audit log entity for tracking user actions and permission checks
///
/// This Core Data model provides audit trail functionality for the RBAC system,
/// logging all permission checks and user actions for security and compliance.
@objc(AuditLog)
public class AuditLog: NSManagedObject {
    
    // MARK: - Core Data Properties
    
    /// Unique identifier for the audit log entry
    @NSManaged public var id: UUID
    
    /// User who performed the action
    @NSManaged public var userId: UUID
    
    /// Action attempted (CREATE, READ, UPDATE, DELETE, etc.)
    @NSManaged public var action: String
    
    /// Resource type affected (Transaction, FinancialEntity, etc.)
    @NSManaged public var resourceType: String
    
    /// Resource ID if applicable
    @NSManaged public var resourceId: UUID?
    
    /// Result of the action (ALLOWED, DENIED)
    @NSManaged public var result: String
    
    /// Timestamp of the action
    @NSManaged public var timestamp: Date
    
    /// Additional details about the action
    @NSManaged public var details: String?
    
    /// IP address of the user (for security tracking)
    @NSManaged public var ipAddress: String?
    
    /// User agent string (for security tracking)
    @NSManaged public var userAgent: String?
    
    // MARK: - Relationships
    
    /// The user who performed the action
    @NSManaged public var user: User?
    
    // MARK: - Computed Properties
    
    /// Formatted timestamp for display
    public var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter.string(from: timestamp)
    }
    
    /// Whether the action was allowed
    public var wasAllowed: Bool {
        return result.uppercased() == "ALLOWED"
    }
    
    /// Whether the action was denied
    public var wasDenied: Bool {
        return result.uppercased() == "DENIED"
    }
    
    /// Display-friendly action name
    public var displayAction: String {
        return action.capitalized
    }
    
    /// Display-friendly resource type
    public var displayResourceType: String {
        return resourceType.capitalized
    }
    
    /// Security risk level based on action and result
    public var riskLevel: String {
        if wasDenied {
            if action.uppercased() == "DELETE" || action.uppercased() == "MANAGE" {
                return "HIGH"
            } else {
                return "MEDIUM"
            }
        } else {
            if action.uppercased() == "DELETE" || action.uppercased() == "MANAGE" {
                return "MEDIUM"
            } else {
                return "LOW"
            }
        }
    }
    
    // MARK: - Convenience Methods
    
    /// Create a new audit log entry
    /// - Parameters:
    ///   - context: Core Data context
    ///   - userId: User ID who performed the action
    ///   - action: Action performed
    ///   - resourceType: Resource type affected
    ///   - resourceId: Resource ID if applicable
    ///   - result: Result of the action
    ///   - details: Additional details
    /// - Returns: New AuditLog instance
    public static func create(
        in context: NSManagedObjectContext,
        userId: UUID,
        action: String,
        resourceType: String,
        resourceId: UUID? = nil,
        result: String,
        details: String? = nil
    ) -> AuditLog {
        let auditLog = AuditLog(context: context)
        auditLog.id = UUID()
        auditLog.userId = userId
        auditLog.action = action.uppercased()
        auditLog.resourceType = resourceType.uppercased()
        auditLog.resourceId = resourceId
        auditLog.result = result.uppercased()
        auditLog.timestamp = Date()
        auditLog.details = details
        return auditLog
    }
    
    /// Create audit log for permission check
    /// - Parameters:
    ///   - context: Core Data context
    ///   - user: User performing the action
    ///   - action: Permission action
    ///   - resourceType: Resource type
    ///   - resourceId: Resource ID if applicable
    ///   - isAllowed: Whether action was allowed
    ///   - details: Additional details
    /// - Returns: New AuditLog instance
    public static func logPermissionCheck(
        in context: NSManagedObjectContext,
        user: User,
        action: PermissionAction,
        resourceType: ResourceType,
        resourceId: UUID? = nil,
        isAllowed: Bool,
        details: String? = nil
    ) -> AuditLog {
        let result = isAllowed ? "ALLOWED" : "DENIED"
        let auditLog = create(
            in: context,
            userId: user.id,
            action: action.rawValue,
            resourceType: resourceType.rawValue,
            resourceId: resourceId,
            result: result,
            details: details
        )
        auditLog.user = user
        return auditLog
    }
    
    /// Create audit log for user action
    /// - Parameters:
    ///   - context: Core Data context
    ///   - user: User performing the action
    ///   - action: Action performed
    ///   - resourceType: Resource type
    ///   - resourceId: Resource ID if applicable
    ///   - details: Additional details
    /// - Returns: New AuditLog instance
    public static func logUserAction(
        in context: NSManagedObjectContext,
        user: User,
        action: String,
        resourceType: String,
        resourceId: UUID? = nil,
        details: String? = nil
    ) -> AuditLog {
        let auditLog = create(
            in: context,
            userId: user.id,
            action: action,
            resourceType: resourceType,
            resourceId: resourceId,
            result: "ALLOWED",
            details: details
        )
        auditLog.user = user
        return auditLog
    }
    
    // MARK: - Description
    
    public override var description: String {
        return """
        AuditLog(id: \(id), user: \(userId), action: \(action), 
        resource: \(resourceType), result: \(result), timestamp: \(formattedTimestamp))
        """
    }
}

// MARK: - Fetch Request

extension AuditLog {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<AuditLog> {
        return NSFetchRequest<AuditLog>(entityName: "AuditLog")
    }
    
    /// Fetch audit logs for a user
    /// - Parameters:
    ///   - userId: User ID
    ///   - context: Core Data context
    ///   - limit: Maximum number of logs to return
    /// - Returns: Array of audit logs
    public static func fetchLogs(
        for userId: UUID,
        in context: NSManagedObjectContext,
        limit: Int = 100
    ) -> [AuditLog] {
        let request: NSFetchRequest<AuditLog> = AuditLog.fetchRequest()
        request.predicate = NSPredicate(format: "userId == %@", userId as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \AuditLog.timestamp, ascending: false)]
        request.fetchLimit = limit
        
        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch audit logs: \(error)")
            return []
        }
    }
    
    /// Fetch recent audit logs
    /// - Parameters:
    ///   - context: Core Data context
    ///   - limit: Maximum number of logs to return
    /// - Returns: Array of recent audit logs
    public static func fetchRecentLogs(in context: NSManagedObjectContext, limit: Int = 50) -> [AuditLog] {
        let request: NSFetchRequest<AuditLog> = AuditLog.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \AuditLog.timestamp, ascending: false)]
        request.fetchLimit = limit
        
        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch recent audit logs: \(error)")
            return []
        }
    }
    
    /// Fetch denied actions for security monitoring
    /// - Parameters:
    ///   - context: Core Data context
    ///   - limit: Maximum number of logs to return
    /// - Returns: Array of denied action logs
    public static func fetchDeniedActions(in context: NSManagedObjectContext, limit: Int = 50) -> [AuditLog] {
        let request: NSFetchRequest<AuditLog> = AuditLog.fetchRequest()
        request.predicate = NSPredicate(format: "result == %@", "DENIED")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \AuditLog.timestamp, ascending: false)]
        request.fetchLimit = limit
        
        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch denied actions: \(error)")
            return []
        }
    }
    
    /// Fetch logs for specific resource type
    /// - Parameters:
    ///   - resourceType: Resource type to filter by
    ///   - context: Core Data context
    ///   - limit: Maximum number of logs to return
    /// - Returns: Array of audit logs for the resource type
    public static func fetchLogs(
        for resourceType: String,
        in context: NSManagedObjectContext,
        limit: Int = 100
    ) -> [AuditLog] {
        let request: NSFetchRequest<AuditLog> = AuditLog.fetchRequest()
        request.predicate = NSPredicate(format: "resourceType == %@", resourceType.uppercased())
        request.sortDescriptors = [NSSortDescriptor(keyPath: \AuditLog.timestamp, ascending: false)]
        request.fetchLimit = limit
        
        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch logs for resource type: \(error)")
            return []
        }
    }
}