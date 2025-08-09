import XCTest
import CoreData
@testable import FinanceMate

/**
 * EntityManagerTests.swift
 * 
 * Purpose: Comprehensive TDD unit tests for multi-entity financial architecture with data isolation and compliance
 * Issues & Complexity Summary: Tests entity CRUD, hierarchy management, data isolation, and Australian compliance
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~500+
 *   - Core Algorithm Complexity: High
 *   - Dependencies: 5 (Core Data, XCTest, Foundation, Security, Combine)
 *   - State Management Complexity: High
 *   - Novelty/Uncertainty Factor: Medium-High
 * AI Pre-Task Self-Assessment: 85%
 * Problem Estimate: 90%
 * Initial Code Complexity Estimate: 90%
 * Final Code Complexity: TBD
 * Overall Result Score: TBD
 * Key Variances/Learnings: Multi-entity financial architecture with enterprise-grade security and compliance
 * Last Updated: 2025-07-08
 */

// EMERGENCY FIX: Removed to eliminate Swift Concurrency crashes
// COMPREHENSIVE FIX: Removed ALL Swift Concurrency patterns to eliminate TaskLocal crashes
final class EntityManagerTests: XCTestCase {
    var entityManager: EntityManager!
    var persistenceController: PersistenceController!
    var context: NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        persistenceController = PersistenceController(inMemory: true)
        context = persistenceController.container.viewContext
        entityManager = EntityManager(context: context)
    }
    
    override func tearDown() {
        entityManager = nil
        context = nil
        persistenceController = nil
        super.tearDown()
    }
    
    // MARK: - Helper Methods
    
    private func createTestEntity(
        name: String = "Test Entity",
        type: EntityType = .personal,
        abn: String? = nil
    ) -> FinancialEntity {
        return entityManager.createEntity(name: name, type: type, abn: abn)
    }
    
    private func createTestTransaction(
        entity: FinancialEntity,
        amount: Double,
        category: String = "General",
        date: Date = Date()
    ) -> Transaction {
        let transaction = Transaction.create(in: context, amount: amount, category: category)
        transaction.entity = entity
        transaction.entityId = entity.id
        transaction.date = date
        try! context.save()
        return transaction
    }
    
    // MARK: - Entity Creation Tests
    
    func testCreatePersonalEntity() {
        // Given
        let entityName = "John's Personal Finances"
        
        // When
        let entity = entityManager.createEntity(name: entityName, type: .personal)
        
        // Then
        XCTAssertEqual(entity.name, entityName)
        XCTAssertEqual(entity.entityType, EntityType.personal.rawValue)
        XCTAssertNotNil(entity.id)
        XCTAssertNotNil(entity.createdDate)
        XCTAssertTrue(entity.isActive)
        XCTAssertNil(entity.abn) // Personal entities don't need ABN
    }
    
    func testCreateBusinessEntity() {
        // Given
        let entityName = "Smith Consulting Pty Ltd"
        let abn = "12345678901"
        
        // When
        let entity = entityManager.createEntity(name: entityName, type: .business, abn: abn)
        
        // Then
        XCTAssertEqual(entity.name, entityName)
        XCTAssertEqual(entity.entityType, EntityType.business.rawValue)
        XCTAssertEqual(entity.abn, abn)
        XCTAssertTrue(entity.isActive)
    }
    
    func testCreateSMSFEntity() {
        // Given
        let entityName = "Smith Family SMSF"
        let abn = "98765432109"
        
        // When
        let entity = entityManager.createEntity(name: entityName, type: .smsf, abn: abn)
        
        // Then
        XCTAssertEqual(entity.name, entityName)
        XCTAssertEqual(entity.entityType, EntityType.smsf.rawValue)
        XCTAssertEqual(entity.abn, abn)
        XCTAssertNotNil(entity.smsfDetails)
        XCTAssertTrue(entity.isActive)
    }
    
    func testCreateTrustEntity() {
        // Given
        let entityName = "Smith Family Trust"
        let abn = "11122233344"
        
        // When
        let entity = entityManager.createEntity(name: entityName, type: .trust, abn: abn)
        
        // Then
        XCTAssertEqual(entity.name, entityName)
        XCTAssertEqual(entity.entityType, EntityType.trust.rawValue)
        XCTAssertEqual(entity.abn, abn)
        XCTAssertTrue(entity.isActive)
    }
    
    // MARK: - Entity Validation Tests
    
    func testBusinessEntityRequiresABN() {
        // Given/When/Then
        XCTAssertThrowsError(try entityManager.validateEntityCreation(name: "Business", type: .business, abn: nil)) {
            error in
            XCTAssertTrue(error is EntityValidationError)
            XCTAssertEqual(error as? EntityValidationError, .abnRequired)
        }
    }
    
    func testSMSFEntityRequiresABN() {
        // Given/When/Then
        XCTAssertThrowsError(try entityManager.validateEntityCreation(name: "SMSF", type: .smsf, abn: nil)) {
            error in
            XCTAssertTrue(error is EntityValidationError)
            XCTAssertEqual(error as? EntityValidationError, .abnRequired)
        }
    }
    
    func testABNValidation() {
        // Given - Invalid ABN (not 11 digits)
        let invalidABN = "12345"
        
        // When/Then
        XCTAssertThrowsError(try entityManager.validateEntityCreation(name: "Business", type: .business, abn: invalidABN)) {
            error in
            XCTAssertTrue(error is EntityValidationError)
            XCTAssertEqual(error as? EntityValidationError, .invalidABN)
        }
    }
    
    func testEntityNameValidation() {
        // Given - Empty name
        let emptyName = ""
        
        // When/Then
        XCTAssertThrowsError(try entityManager.validateEntityCreation(name: emptyName, type: .personal)) {
            error in
            XCTAssertTrue(error is EntityValidationError)
            XCTAssertEqual(error as? EntityValidationError, .invalidName)
        }
    }
    
    // MARK: - Entity Hierarchy Tests
    
    func testCreateEntityHierarchy() {
        // Given
        let parentEntity = createTestEntity(name: "Parent Entity", type: .business)
        let childName = "Child Entity"
        
        // When
        let childEntity = entityManager.createChildEntity(
            name: childName,
            type: .business,
            parent: parentEntity
        )
        
        // Then
        XCTAssertEqual(childEntity.parentEntityId, parentEntity.id)
        XCTAssertTrue(parentEntity.childEntities.contains(childEntity))
    }
    
    func testPreventCircularHierarchy() {
        // Given
        let entityA = createTestEntity(name: "Entity A", type: .business)
        let entityB = entityManager.createChildEntity(name: "Entity B", type: .business, parent: entityA)
        
        // When/Then - Attempting to make A a child of B should fail
        XCTAssertThrowsError(try entityManager.setParentEntity(child: entityA, parent: entityB)) {
            error in
            XCTAssertTrue(error is EntityValidationError)
            XCTAssertEqual(error as? EntityValidationError, .circularHierarchy)
        }
    }
    
    func testMaxHierarchyDepth() {
        // Given - Create a deep hierarchy
        var currentParent = createTestEntity(name: "Root", type: .business)
        
        // Create 4 levels of hierarchy (should be allowed)
        for i in 1...4 {
            currentParent = entityManager.createChildEntity(
                name: "Level \(i)",
                type: .business,
                parent: currentParent
            )
        }
        
        // When/Then - 6th level should fail (max depth is 5)
        XCTAssertThrowsError(try entityManager.createChildEntity(
            name: "Too Deep",
            type: .business,
            parent: currentParent
        )) { error in
            XCTAssertTrue(error is EntityValidationError)
            XCTAssertEqual(error as? EntityValidationError, .maxHierarchyDepthExceeded)
        }
    }
    
    // MARK: - Data Isolation Tests
    
    func testEntityDataIsolation() {
        // Given
        let entity1 = createTestEntity(name: "Entity 1", type: .personal)
        let entity2 = createTestEntity(name: "Entity 2", type: .business)
        
        let transaction1 = createTestTransaction(entity: entity1, amount: 100.0)
        let transaction2 = createTestTransaction(entity: entity2, amount: 200.0)
        
        // When
        let entity1Context = EntityAwareContext(parent: context, entityId: entity1.id)
        let entity2Context = EntityAwareContext(parent: context, entityId: entity2.id)
        
        let entity1Transactions = entityManager.fetchTransactions(context: entity1Context)
        let entity2Transactions = entityManager.fetchTransactions(context: entity2Context)
        
        // Then
        XCTAssertEqual(entity1Transactions.count, 1)
        XCTAssertEqual(entity2Transactions.count, 1)
        XCTAssertEqual(entity1Transactions.first?.id, transaction1.id)
        XCTAssertEqual(entity2Transactions.first?.id, transaction2.id)
    }
    
    func testCrossEntityTransactionPrevention() {
        // Given
        let entity1 = createTestEntity(name: "Entity 1", type: .personal)
        let entity2 = createTestEntity(name: "Entity 2", type: .business)
        let entity1Context = EntityAwareContext(parent: context, entityId: entity1.id)
        
        // When/Then - Attempting to access entity2's data from entity1's context should return empty
        let transaction2 = createTestTransaction(entity: entity2, amount: 200.0)
        let entity1Transactions = entityManager.fetchTransactions(context: entity1Context)
        
        XCTAssertEqual(entity1Transactions.count, 0)
        XCTAssertFalse(entity1Transactions.contains { $0.id == transaction2.id })
    }
    
    // MARK: - Cross-Entity Transaction Tests
    
    func testCreateCrossEntityTransaction() {
        // Given
        let fromEntity = createTestEntity(name: "Business Entity", type: .business)
        let toEntity = createTestEntity(name: "Personal Entity", type: .personal)
        let amount: Double = 1000.0
        let description = "Management fee payment"
        
        // When
        let crossTransaction = entityManager.createCrossEntityTransaction(
            from: fromEntity,
            to: toEntity,
            amount: amount,
            description: description,
            type: .managementFee
        )
        
        // Then
        XCTAssertEqual(crossTransaction.fromEntityId, fromEntity.id)
        XCTAssertEqual(crossTransaction.toEntityId, toEntity.id)
        XCTAssertEqual(crossTransaction.amount, amount)
        XCTAssertEqual(crossTransaction.description, description)
        XCTAssertEqual(crossTransaction.transactionType, CrossEntityTransactionType.managementFee.rawValue)
        XCTAssertNotNil(crossTransaction.auditTrail)
    }
    
    func testCrossEntityTransactionAuditTrail() {
        // Given
        let fromEntity = createTestEntity(name: "From Entity", type: .business)
        let toEntity = createTestEntity(name: "To Entity", type: .personal)
        
        // When
        let crossTransaction = entityManager.createCrossEntityTransaction(
            from: fromEntity,
            to: toEntity,
            amount: 500.0,
            description: "Test transaction",
            type: .loan
        )
        
        // Then
        XCTAssertNotNil(crossTransaction.auditTrail)
        
        let auditTrail = try! JSONDecoder().decode(CrossEntityAuditTrail.self, from: crossTransaction.auditTrail!)
        XCTAssertEqual(auditTrail.action, "CREATE_CROSS_ENTITY_TRANSACTION")
        XCTAssertEqual(auditTrail.fromEntityName, fromEntity.name)
        XCTAssertEqual(auditTrail.toEntityName, toEntity.name)
        XCTAssertNotNil(auditTrail.timestamp)
    }
    
    // MARK: - Entity Management Tests
    
    func testFetchAllEntities() {
        // Given
        let entity1 = createTestEntity(name: "Entity 1", type: .personal)
        let entity2 = createTestEntity(name: "Entity 2", type: .business)
        let entity3 = createTestEntity(name: "Entity 3", type: .trust)
        
        // When
        let allEntities = entityManager.fetchAllEntities()
        
        // Then
        XCTAssertEqual(allEntities.count, 3)
        XCTAssertTrue(allEntities.contains(entity1))
        XCTAssertTrue(allEntities.contains(entity2))
        XCTAssertTrue(allEntities.contains(entity3))
    }
    
    func testFetchEntitiesByType() {
        // Given
        createTestEntity(name: "Personal 1", type: .personal)
        createTestEntity(name: "Personal 2", type: .personal)
        createTestEntity(name: "Business 1", type: .business)
        
        // When
        let personalEntities = entityManager.fetchEntities(ofType: .personal)
        let businessEntities = entityManager.fetchEntities(ofType: .business)
        
        // Then
        XCTAssertEqual(personalEntities.count, 2)
        XCTAssertEqual(businessEntities.count, 1)
        XCTAssertTrue(personalEntities.allSatisfy { $0.entityType == EntityType.personal.rawValue })
        XCTAssertTrue(businessEntities.allSatisfy { $0.entityType == EntityType.business.rawValue })
    }
    
    func testDeleteEntity() {
        // Given
        let entity = createTestEntity(name: "Test Entity", type: .personal)
        let entityId = entity.id
        
        // When
        let success = entityManager.deleteEntity(entity)
        
        // Then
        XCTAssertTrue(success)
        
        let deletedEntity = entityManager.fetchEntity(byId: entityId)
        XCTAssertNil(deletedEntity)
    }
    
    func testDeleteEntityWithTransactions() {
        // Given
        let entity = createTestEntity(name: "Entity with Transactions", type: .personal)
        createTestTransaction(entity: entity, amount: 100.0)
        createTestTransaction(entity: entity, amount: 200.0)
        
        // When/Then - Should prevent deletion
        XCTAssertThrowsError(try entityManager.deleteEntity(entity)) { error in
            XCTAssertTrue(error is EntityValidationError)
            XCTAssertEqual(error as? EntityValidationError, .cannotDeleteEntityWithTransactions)
        }
    }
    
    // MARK: - Compliance Tests
    
    func testSMSFComplianceValidation() {
        // Given
        let smsfEntity = createTestEntity(name: "Test SMSF", type: .smsf, abn: "12345678901")
        
        // When
        let complianceStatus = entityManager.validateSMSFCompliance(smsfEntity)
        
        // Then
        XCTAssertNotNil(complianceStatus)
        XCTAssertTrue(complianceStatus.hasValidABN)
        // Additional SMSF-specific validations would be tested here
    }
    
    func testBusinessGSTCalculation() {
        // Given
        let businessEntity = createTestEntity(name: "GST Business", type: .business, abn: "12345678901")
        businessEntity.gstRegistered = true
        let transaction = createTestTransaction(entity: businessEntity, amount: 110.0) // $110 GST-inclusive
        
        // When
        let gstAmount = entityManager.calculateGST(for: transaction)
        
        // Then
        XCTAssertEqual(gstAmount, 10.0, accuracy: 0.01) // $10 GST
    }
    
    // MARK: - Performance Tests
    
    func testFetchPerformanceWithManyEntities() {
        // Given - Create 100 entities
        for i in 1...100 {
            createTestEntity(name: "Entity \(i)", type: .personal)
        }
        
        // When
        let startTime = CFAbsoluteTimeGetCurrent()
        let entities = entityManager.fetchAllEntities()
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        // Then
        XCTAssertEqual(entities.count, 100)
        XCTAssertLessThan(timeElapsed, 0.1) // Should complete in under 100ms
    }
    
    func testEntityContextPerformance() {
        // Given
        let entity = createTestEntity(name: "Performance Entity", type: .personal)
        
        // Create 1000 transactions
        for i in 1...1000 {
            createTestTransaction(entity: entity, amount: Double(i))
        }
        
        // When
        let entityContext = EntityAwareContext(parent: context, entityId: entity.id)
        
        let startTime = CFAbsoluteTimeGetCurrent()
        let transactions = entityManager.fetchTransactions(context: entityContext)
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        // Then
        XCTAssertEqual(transactions.count, 1000)
        XCTAssertLessThan(timeElapsed, 0.2) // Should complete in under 200ms
    }
}

// MARK: - Test Enums and Structs

enum EntityValidationError: Error, Equatable {
    case invalidName
    case abnRequired
    case invalidABN
    case circularHierarchy
    case maxHierarchyDepthExceeded
    case cannotDeleteEntityWithTransactions
}

enum EntityType: String, CaseIterable {
    case personal = "Personal"
    case business = "Business"
    case trust = "Trust"
    case smsf = "SMSF"
    case joint = "Joint"
}

enum CrossEntityTransactionType: String, CaseIterable {
    case loan = "Loan"
    case managementFee = "Management Fee"
    case distribution = "Distribution"
    case intercompanyTransfer = "Intercompany Transfer"
}

struct CrossEntityAuditTrail: Codable {
    let action: String
    let fromEntityName: String
    let toEntityName: String
    let timestamp: Date
    let userId: String?
}

struct SMSFComplianceStatus {
    let hasValidABN: Bool
    let trustDeedCompliant: Bool
    let memberTrusteeRatioValid: Bool
    let investmentStrategyUpToDate: Bool
    let auditUpToDate: Bool
    
    var isCompliant: Bool {
        hasValidABN && trustDeedCompliant && memberTrusteeRatioValid && 
        investmentStrategyUpToDate && auditUpToDate
    }
}