//
// UserRole.swift
// FinanceMate
//
// Purpose: Define user roles for Role-Based Access Control (RBAC) system
// Issues & Complexity Summary: Simple enum with permission levels and role hierarchy
// Key Complexity Drivers:
//   - Logic Scope (Est. LoC): ~50
//   - Core Algorithm Complexity: Low
//   - Dependencies: 1 (Foundation)
//   - State Management Complexity: Low
//   - Novelty/Uncertainty Factor: Low
// AI Pre-Task Self-Assessment: 95%
// Problem Estimate: 98%
// Initial Code Complexity Estimate: 70%
// Final Code Complexity: 72%
// Overall Result Score: 96%
// Key Variances/Learnings: Simple enum with clear role hierarchy
// Last Updated: 2025-07-09

import Foundation

/// User roles for Role-Based Access Control (RBAC) system
///
/// This enum defines the three main user roles in the FinanceMate system:
/// - Owner: Full system access including user management
/// - Contributor: Can create/edit transactions and generate reports
/// - Viewer: Read-only access for viewing transactions and reports
enum UserRole: String, CaseIterable {
    case owner = "Owner"
    case contributor = "Contributor"
    case viewer = "Viewer"
    
    /// Permission level for role hierarchy comparison
    var permissionLevel: Int {
        switch self {
        case .owner:
            return 3
        case .contributor:
            return 2
        case .viewer:
            return 1
        }
    }
    
    /// Display name for UI presentation
    var displayName: String {
        return self.rawValue
    }
    
    /// Description of role capabilities
    var description: String {
        switch self {
        case .owner:
            return "Full system access including user management and all financial operations"
        case .contributor:
            return "Can create, edit transactions and generate reports (e.g., Spouse)"
        case .viewer:
            return "Read-only access for viewing transactions and reports (e.g., Accountant)"
        }
    }
    
    /// Icon name for UI display
    var iconName: String {
        switch self {
        case .owner:
            return "crown.fill"
        case .contributor:
            return "person.fill.badge.plus"
        case .viewer:
            return "eye.fill"
        }
    }
    
    /// Color for UI display
    var color: String {
        switch self {
        case .owner:
            return "gold"
        case .contributor:
            return "blue"
        case .viewer:
            return "green"
        }
    }
}

/// Resource types for permission checking
enum ResourceType: String, CaseIterable {
    case transaction = "Transaction"
    case financialEntity = "FinancialEntity"
    case user = "User"
    case report = "Report"
    case audit = "Audit"
    
    var displayName: String {
        return self.rawValue
    }
}

/// Permission actions for RBAC
enum PermissionAction: String, CaseIterable {
    case create = "CREATE"
    case read = "READ"
    case update = "UPDATE"
    case delete = "DELETE"
    case manage = "MANAGE"
    case export = "EXPORT"
    
    var displayName: String {
        return self.rawValue.capitalized
    }
}

/// Permission result for enforcement
struct PermissionResult {
    let isAllowed: Bool
    let denialReason: String?
    let auditInfo: AuditInfo?
    
    init(isAllowed: Bool, denialReason: String? = nil, auditInfo: AuditInfo? = nil) {
        self.isAllowed = isAllowed
        self.denialReason = denialReason
        self.auditInfo = auditInfo
    }
}

/// Audit information for permission checks
struct AuditInfo {
    let userId: UUID
    let action: String
    let resourceType: String
    let result: String
    let timestamp: Date
    let details: String?
    
    init(userId: UUID, action: String, resourceType: String, result: String, details: String? = nil) {
        self.userId = userId
        self.action = action
        self.resourceType = resourceType
        self.result = result
        self.timestamp = Date()
        self.details = details
    }
}