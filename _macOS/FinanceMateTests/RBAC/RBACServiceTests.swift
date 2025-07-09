//
// RBACServiceTests.swift
// FinanceMateTests
//
// Purpose: Comprehensive test suite for Role-Based Access Control system
// Issues & Complexity Summary: Testing complex permission logic with multiple roles and resource types
// Key Complexity Drivers:
//   - Logic Scope (Est. LoC): ~400
//   - Core Algorithm Complexity: High
//   - Dependencies: 4 (XCTest, Core Data, User, RBACService)
//   - State Management Complexity: High
//   - Novelty/Uncertainty Factor: Medium
// AI Pre-Task Self-Assessment: 85%
// Problem Estimate: 88%
// Initial Code Complexity Estimate: 90%
// Final Code Complexity: 92%
// Overall Result Score: 91%
// Key Variances/Learnings: Complex permission matrix requires careful test design
// Last Updated: 2025-07-09

import XCTest
import CoreData
@testable import FinanceMate

final class RBACServiceTests: XCTestCase {
    
    var rbacService: RBACService!
    var testContext: NSManagedObjectContext!
    var testUser: User!
    var testEntity: FinancialEntity!
    var testTransaction: Transaction!
    
    override func setUp() {
        super.setUp()
        
        // Setup test Core Data context
        testContext = PersistenceController.preview.container.viewContext
        
        // Create RBAC service with test context
        rbacService = RBACService(context: testContext)
        
        // Create test user
        testUser = User(context: testContext)
        testUser.id = UUID()
        testUser.name = "Test User"
        testUser.email = "test@example.com"
        testUser.role = UserRole.owner.rawValue
        testUser.createdAt = Date()
        testUser.isActive = true
        
        // Create test financial entity
        testEntity = FinancialEntity(context: testContext)
        testEntity.id = UUID()
        testEntity.name = "Test Entity"
        testEntity.entityType = "Personal"
        testEntity.createdAt = Date()
        testEntity.lastModified = Date()
        testEntity.isActive = true
        
        // Create test transaction
        testTransaction = Transaction(context: testContext)
        testTransaction.id = UUID()
        testTransaction.amount = 100.0
        testTransaction.category = "Test Category"
        testTransaction.date = Date()
        testTransaction.createdAt = Date()
        testTransaction.assignedEntity = testEntity
        
        // Save context
        try? testContext.save()
    }
    
    override func tearDown() {
        rbacService = nil
        testUser = nil
        testEntity = nil
        testTransaction = nil
        testContext = nil
        super.tearDown()
    }
    
    // MARK: - Role Permission Tests
    
    func testOwnerPermissions() {
        // Given: User with Owner role
        testUser.role = UserRole.owner.rawValue
        
        // When: Testing all permissions
        let canCreate = rbacService.canCreate(resourceType: .transaction, user: testUser)
        let canRead = rbacService.canRead(resourceType: .transaction, user: testUser)
        let canUpdate = rbacService.canUpdate(resourceType: .transaction, user: testUser)
        let canDelete = rbacService.canDelete(resourceType: .transaction, user: testUser)
        let canManageUsers = rbacService.canManageUsers(user: testUser)
        let canManageEntities = rbacService.canManageEntities(user: testUser)
        
        // Then: Owner should have all permissions
        XCTAssertTrue(canCreate, "Owner should be able to create transactions")
        XCTAssertTrue(canRead, "Owner should be able to read transactions")
        XCTAssertTrue(canUpdate, "Owner should be able to update transactions")
        XCTAssertTrue(canDelete, "Owner should be able to delete transactions")
        XCTAssertTrue(canManageUsers, "Owner should be able to manage users")
        XCTAssertTrue(canManageEntities, "Owner should be able to manage entities")
    }
    
    func testContributorPermissions() {
        // Given: User with Contributor role
        testUser.role = UserRole.contributor.rawValue
        
        // When: Testing all permissions
        let canCreate = rbacService.canCreate(resourceType: .transaction, user: testUser)
        let canRead = rbacService.canRead(resourceType: .transaction, user: testUser)
        let canUpdate = rbacService.canUpdate(resourceType: .transaction, user: testUser)
        let canDelete = rbacService.canDelete(resourceType: .transaction, user: testUser)
        let canManageUsers = rbacService.canManageUsers(user: testUser)
        let canManageEntities = rbacService.canManageEntities(user: testUser)
        
        // Then: Contributor should have limited permissions
        XCTAssertTrue(canCreate, "Contributor should be able to create transactions")
        XCTAssertTrue(canRead, "Contributor should be able to read transactions")
        XCTAssertTrue(canUpdate, "Contributor should be able to update transactions")
        XCTAssertFalse(canDelete, "Contributor should NOT be able to delete transactions")
        XCTAssertFalse(canManageUsers, "Contributor should NOT be able to manage users")
        XCTAssertFalse(canManageEntities, "Contributor should NOT be able to manage entities")
    }
    
    func testViewerPermissions() {
        // Given: User with Viewer role
        testUser.role = UserRole.viewer.rawValue
        
        // When: Testing all permissions
        let canCreate = rbacService.canCreate(resourceType: .transaction, user: testUser)
        let canRead = rbacService.canRead(resourceType: .transaction, user: testUser)
        let canUpdate = rbacService.canUpdate(resourceType: .transaction, user: testUser)
        let canDelete = rbacService.canDelete(resourceType: .transaction, user: testUser)
        let canManageUsers = rbacService.canManageUsers(user: testUser)
        let canManageEntities = rbacService.canManageEntities(user: testUser)
        
        // Then: Viewer should have read-only permissions
        XCTAssertFalse(canCreate, "Viewer should NOT be able to create transactions")
        XCTAssertTrue(canRead, "Viewer should be able to read transactions")
        XCTAssertFalse(canUpdate, "Viewer should NOT be able to update transactions")
        XCTAssertFalse(canDelete, "Viewer should NOT be able to delete transactions")
        XCTAssertFalse(canManageUsers, "Viewer should NOT be able to manage users")
        XCTAssertFalse(canManageEntities, "Viewer should NOT be able to manage entities")
    }
    
    // MARK: - Resource Type Permission Tests
    
    func testFinancialEntityPermissions() {
        // Given: Different user roles
        let ownerUser = createUser(role: .owner)
        let contributorUser = createUser(role: .contributor)
        let viewerUser = createUser(role: .viewer)
        
        // When: Testing entity permissions
        let ownerCanManage = rbacService.canManageEntities(user: ownerUser)
        let contributorCanManage = rbacService.canManageEntities(user: contributorUser)
        let viewerCanManage = rbacService.canManageEntities(user: viewerUser)
        
        let ownerCanRead = rbacService.canRead(resourceType: .financialEntity, user: ownerUser)
        let contributorCanRead = rbacService.canRead(resourceType: .financialEntity, user: contributorUser)
        let viewerCanRead = rbacService.canRead(resourceType: .financialEntity, user: viewerUser)
        
        // Then: Check entity-specific permissions
        XCTAssertTrue(ownerCanManage, "Owner should be able to manage entities")
        XCTAssertFalse(contributorCanManage, "Contributor should NOT be able to manage entities")
        XCTAssertFalse(viewerCanManage, "Viewer should NOT be able to manage entities")
        
        XCTAssertTrue(ownerCanRead, "Owner should be able to read entities")
        XCTAssertTrue(contributorCanRead, "Contributor should be able to read entities")
        XCTAssertTrue(viewerCanRead, "Viewer should be able to read entities")
    }
    
    func testReportPermissions() {
        // Given: Different user roles
        let ownerUser = createUser(role: .owner)
        let contributorUser = createUser(role: .contributor)
        let viewerUser = createUser(role: .viewer)
        
        // When: Testing report permissions
        let ownerCanGenerate = rbacService.canGenerateReports(user: ownerUser)
        let contributorCanGenerate = rbacService.canGenerateReports(user: contributorUser)
        let viewerCanGenerate = rbacService.canGenerateReports(user: viewerUser)
        
        let ownerCanExport = rbacService.canExportData(user: ownerUser)
        let contributorCanExport = rbacService.canExportData(user: contributorUser)
        let viewerCanExport = rbacService.canExportData(user: viewerUser)
        
        // Then: Check report-specific permissions
        XCTAssertTrue(ownerCanGenerate, "Owner should be able to generate reports")
        XCTAssertTrue(contributorCanGenerate, "Contributor should be able to generate reports")
        XCTAssertTrue(viewerCanGenerate, "Viewer should be able to generate reports")
        
        XCTAssertTrue(ownerCanExport, "Owner should be able to export data")
        XCTAssertFalse(contributorCanExport, "Contributor should NOT be able to export data")
        XCTAssertTrue(viewerCanExport, "Viewer should be able to export data (for accountant access)")
    }
    
    // MARK: - Permission Enforcement Tests
    
    func testTransactionCreatePermissionEnforcement() {
        // Given: Users with different roles
        let ownerUser = createUser(role: .owner)
        let contributorUser = createUser(role: .contributor)
        let viewerUser = createUser(role: .viewer)
        
        // When: Attempting to create transactions
        let ownerResult = rbacService.enforcePermission(.create, resourceType: .transaction, user: ownerUser)
        let contributorResult = rbacService.enforcePermission(.create, resourceType: .transaction, user: contributorUser)
        let viewerResult = rbacService.enforcePermission(.create, resourceType: .transaction, user: viewerUser)
        
        // Then: Check enforcement results
        XCTAssertTrue(ownerResult.isAllowed, "Owner should be allowed to create transactions")
        XCTAssertTrue(contributorResult.isAllowed, "Contributor should be allowed to create transactions")
        XCTAssertFalse(viewerResult.isAllowed, "Viewer should NOT be allowed to create transactions")
        XCTAssertNotNil(viewerResult.denialReason, "Viewer should receive denial reason")
    }
    
    func testTransactionDeletePermissionEnforcement() {
        // Given: Users with different roles
        let ownerUser = createUser(role: .owner)
        let contributorUser = createUser(role: .contributor)
        let viewerUser = createUser(role: .viewer)
        
        // When: Attempting to delete transactions
        let ownerResult = rbacService.enforcePermission(.delete, resourceType: .transaction, user: ownerUser)
        let contributorResult = rbacService.enforcePermission(.delete, resourceType: .transaction, user: contributorUser)
        let viewerResult = rbacService.enforcePermission(.delete, resourceType: .transaction, user: viewerUser)
        
        // Then: Check enforcement results
        XCTAssertTrue(ownerResult.isAllowed, "Owner should be allowed to delete transactions")
        XCTAssertFalse(contributorResult.isAllowed, "Contributor should NOT be allowed to delete transactions")
        XCTAssertFalse(viewerResult.isAllowed, "Viewer should NOT be allowed to delete transactions")
    }
    
    // MARK: - Role Hierarchy Tests
    
    func testRoleHierarchy() {
        // Given: Role hierarchy levels
        let ownerLevel = rbacService.getPermissionLevel(for: .owner)
        let contributorLevel = rbacService.getPermissionLevel(for: .contributor)
        let viewerLevel = rbacService.getPermissionLevel(for: .viewer)
        
        // When: Comparing permission levels
        // Then: Owner should have highest level, viewer lowest
        XCTAssertTrue(ownerLevel > contributorLevel, "Owner should have higher permission level than Contributor")
        XCTAssertTrue(contributorLevel > viewerLevel, "Contributor should have higher permission level than Viewer")
        XCTAssertTrue(ownerLevel > viewerLevel, "Owner should have higher permission level than Viewer")
    }
    
    func testRoleUpgradePermissions() {
        // Given: User with Contributor role
        testUser.role = UserRole.contributor.rawValue
        
        // When: Checking if user can upgrade roles
        let canUpgradeToOwner = rbacService.canChangeUserRole(from: .contributor, to: .owner, requestingUser: testUser)
        let canUpgradeToContributor = rbacService.canChangeUserRole(from: .viewer, to: .contributor, requestingUser: testUser)
        
        // Then: Contributors should not be able to upgrade roles
        XCTAssertFalse(canUpgradeToOwner, "Contributor should NOT be able to upgrade to Owner")
        XCTAssertFalse(canUpgradeToContributor, "Contributor should NOT be able to upgrade other users")
    }
    
    func testOwnerRoleManagement() {
        // Given: User with Owner role
        testUser.role = UserRole.owner.rawValue
        
        // When: Testing role management capabilities
        let canUpgradeToOwner = rbacService.canChangeUserRole(from: .contributor, to: .owner, requestingUser: testUser)
        let canDowngradeToContributor = rbacService.canChangeUserRole(from: .owner, to: .contributor, requestingUser: testUser)
        let canSetViewer = rbacService.canChangeUserRole(from: .contributor, to: .viewer, requestingUser: testUser)
        
        // Then: Owner should be able to manage all roles
        XCTAssertTrue(canUpgradeToOwner, "Owner should be able to upgrade users to Owner")
        XCTAssertTrue(canDowngradeToContributor, "Owner should be able to downgrade users to Contributor")
        XCTAssertTrue(canSetViewer, "Owner should be able to set users as Viewer")
    }
    
    // MARK: - Entity-Based Permission Tests
    
    func testEntityOwnershipPermissions() {
        // Given: User owns specific entity
        testUser.role = UserRole.contributor.rawValue
        testEntity.owner = testUser
        
        // When: Testing entity-specific permissions
        let canEditOwnEntity = rbacService.canEditEntity(testEntity, user: testUser)
        let canDeleteOwnEntity = rbacService.canDeleteEntity(testEntity, user: testUser)
        
        // Create different entity owned by another user
        let otherUser = createUser(role: .owner)
        let otherEntity = createTestEntity(owner: otherUser)
        let canEditOtherEntity = rbacService.canEditEntity(otherEntity, user: testUser)
        let canDeleteOtherEntity = rbacService.canDeleteEntity(otherEntity, user: testUser)
        
        // Then: User should have permissions on owned entities
        XCTAssertTrue(canEditOwnEntity, "User should be able to edit their own entity")
        XCTAssertFalse(canDeleteOwnEntity, "Contributor should NOT be able to delete entities")
        XCTAssertFalse(canEditOtherEntity, "User should NOT be able to edit other users' entities")
        XCTAssertFalse(canDeleteOtherEntity, "User should NOT be able to delete other users' entities")
    }
    
    // MARK: - Permission Validation Tests
    
    func testInvalidUserRoleHandling() {
        // Given: User with invalid role
        testUser.role = "InvalidRole"
        
        // When: Testing permissions with invalid role
        let canCreate = rbacService.canCreate(resourceType: .transaction, user: testUser)
        let canRead = rbacService.canRead(resourceType: .transaction, user: testUser)
        let canUpdate = rbacService.canUpdate(resourceType: .transaction, user: testUser)
        let canDelete = rbacService.canDelete(resourceType: .transaction, user: testUser)
        
        // Then: Invalid role should have no permissions
        XCTAssertFalse(canCreate, "Invalid role should have no create permissions")
        XCTAssertFalse(canRead, "Invalid role should have no read permissions")
        XCTAssertFalse(canUpdate, "Invalid role should have no update permissions")
        XCTAssertFalse(canDelete, "Invalid role should have no delete permissions")
    }
    
    func testInactiveUserPermissions() {
        // Given: Inactive user
        testUser.role = UserRole.owner.rawValue
        testUser.isActive = false
        
        // When: Testing permissions for inactive user
        let canCreate = rbacService.canCreate(resourceType: .transaction, user: testUser)
        let canRead = rbacService.canRead(resourceType: .transaction, user: testUser)
        let canUpdate = rbacService.canUpdate(resourceType: .transaction, user: testUser)
        let canDelete = rbacService.canDelete(resourceType: .transaction, user: testUser)
        
        // Then: Inactive user should have no permissions
        XCTAssertFalse(canCreate, "Inactive user should have no create permissions")
        XCTAssertFalse(canRead, "Inactive user should have no read permissions")
        XCTAssertFalse(canUpdate, "Inactive user should have no update permissions")
        XCTAssertFalse(canDelete, "Inactive user should have no delete permissions")
    }
    
    // MARK: - Audit Trail Tests
    
    func testPermissionAuditTrail() {
        // Given: User attempting restricted action
        testUser.role = UserRole.viewer.rawValue
        
        // When: Attempting forbidden action
        let result = rbacService.enforcePermission(.create, resourceType: .transaction, user: testUser)
        
        // Then: Audit trail should be created
        XCTAssertFalse(result.isAllowed, "Action should be denied")
        
        // Check if audit log entry was created
        let auditLogs = rbacService.getAuditLogs(for: testUser)
        XCTAssertFalse(auditLogs.isEmpty, "Audit log should contain entries")
        
        let latestLog = auditLogs.first
        XCTAssertEqual(latestLog?.action, "CREATE", "Audit log should record attempted action")
        XCTAssertEqual(latestLog?.resourceType, "TRANSACTION", "Audit log should record resource type")
        XCTAssertEqual(latestLog?.result, "DENIED", "Audit log should record denial result")
    }
    
    // MARK: - Helper Methods
    
    private func createUser(role: UserRole) -> User {
        let user = User(context: testContext)
        user.id = UUID()
        user.name = "Test User \(role.rawValue)"
        user.email = "test.\(role.rawValue)@example.com"
        user.role = role.rawValue
        user.createdAt = Date()
        user.isActive = true
        return user
    }
    
    private func createTestEntity(owner: User) -> FinancialEntity {
        let entity = FinancialEntity(context: testContext)
        entity.id = UUID()
        entity.name = "Test Entity"
        entity.entityType = "Personal"
        entity.createdAt = Date()
        entity.lastModified = Date()
        entity.isActive = true
        entity.owner = owner
        return entity
    }
}