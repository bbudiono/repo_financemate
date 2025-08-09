import XCTest
import CoreData
@testable import FinanceMate

/**
 * MultiEntityArchitectureTests.swift
 * 
 * Purpose: Comprehensive test suite for multi-entity architecture and star schema implementation
 * Issues & Complexity Summary: Complex test scenarios covering entity hierarchies, cross-entity transactions, and Australian compliance
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~800
 *   - Core Algorithm Complexity: Very High
 *   - Dependencies: 6 (XCTest, Core Data, Foundation, Multi-Entity, Star Schema, Compliance)
 *   - State Management Complexity: Very High
 *   - Novelty/Uncertainty Factor: High
 * AI Pre-Task Self-Assessment: 96%
 * Problem Estimate: 94%
 * Initial Code Complexity Estimate: 95%
 * Final Code Complexity: TBD
 * Overall Result Score: TBD
 * Key Variances/Learnings: Comprehensive testing of enterprise multi-entity architecture with Australian compliance
 * Last Updated: 2025-08-08
 */

final class MultiEntityArchitectureTests: XCTestCase {
    
    var testContext: NSManagedObjectContext!
    var persistenceController: EnhancedPersistenceController!
    
    override func setUp() {
        super.setUp()
        persistenceController = EnhancedPersistenceController.preview
        testContext = persistenceController.container.newBackgroundContext()
    }
    
    override func tearDown() {
        testContext = nil
        persistenceController = nil
        super.tearDown()
    }
    
    // MARK: - Financial Entity Creation Tests
    
    func testCreateIndividualEntity() {
        // Given
        let entityName = "John Doe Personal"
        
        // When
        let entity = EntityType.individual.createEntity(name: entityName, in: testContext)
        
        // Then
        XCTAssertEqual(entity.name, entityName)
        XCTAssertEqual(entity.entityType, EntityType.individual.rawValue)
        XCTAssertFalse(entity.gstRegistered)
        XCTAssertNil(entity.abn) // Individual doesn't require ABN
        XCTAssertTrue(entity.isActive)
        XCTAssertNotNil(entity.id)
        XCTAssertNotNil(entity.createdDate)
    }
    
    func testCreateCompanyEntity() {
        // Given
        let entityName = "ABC Pty Ltd"
        
        // When
        let entity = EntityType.company.createEntity(name: entityName, in: testContext)
        
        // Then
        XCTAssertEqual(entity.name, entityName)
        XCTAssertEqual(entity.entityType, EntityType.company.rawValue)
        XCTAssertFalse(entity.gstRegistered)
        XCTAssertNil(entity.abn) // Will be set separately
        XCTAssertTrue(entity.isActive)
        XCTAssertTrue(EntityType.company.requiresABN)
    }
    
    func testCreateSMSFEntity() {
        // Given
        let entityName = "Smith Family SMSF"
        
        // When
        let entity = EntityType.smsf.createEntity(name: entityName, in: testContext)
        
        // Then
        XCTAssertEqual(entity.name, entityName)
        XCTAssertEqual(entity.entityType, EntityType.smsf.rawValue)
        XCTAssertTrue(EntityType.smsf.requiresABN)
        XCTAssertEqual(EntityType.smsf.gstThreshold, 0.0) // SMSFs don't register for GST
    }
    
    // MARK: - Entity Hierarchy Tests
    
    func testCreateEntityHierarchy() {
        // Given
        let parentEntity = EntityType.familyTrust.createEntity(name: "Smith Family Trust", in: testContext)
        let childEntity1 = EntityType.company.createEntity(name: "Smith Holdings Pty Ltd", in: testContext)
        let childEntity2 = EntityType.smsf.createEntity(name: "Smith Family SMSF", in: testContext)
        
        // When
        childEntity1.parentEntityId = parentEntity.id
        childEntity2.parentEntityId = parentEntity.id
        
        // Then
        XCTAssertEqual(childEntity1.parentEntityId, parentEntity.id)
        XCTAssertEqual(childEntity2.parentEntityId, parentEntity.id)
        XCTAssertNil(parentEntity.parentEntityId) // Top-level entity
    }
    
    func testEntityHierarchyRelationships() {
        // Given
        let parentEntity = EntityType.familyTrust.createEntity(name: "Parent Trust", in: testContext)
        let childEntity = EntityType.company.createEntity(name: "Child Company", in: testContext)
        
        // When - Establish parent-child relationship
        parentEntity.addToChildEntities(childEntity)
        
        // Then
        XCTAssertTrue(parentEntity.childEntities.contains(childEntity))
        XCTAssertEqual(childEntity.parentEntity, parentEntity)
    }
    
    // MARK: - SMSF Specialized Entity Tests
    
    func testCreateSMSFEntityDetails() {
        // Given
        let smsfEntity = EntityType.smsf.createEntity(name: "Test SMSF", in: testContext)
        let smsfDetails = SMSFEntityDetails(context: testContext)
        
        // When
        smsfDetails.abn = "12345678901"
        smsfDetails.trustDeedDate = Date()
        smsfDetails.investmentStrategyDate = Date()
        smsfDetails.nextAuditDueDate = Calendar.current.date(byAdding: .year, value: 1, to: Date())!
        smsfDetails.entity = smsfEntity
        
        // Then
        XCTAssertEqual(smsfDetails.abn, "12345678901")
        XCTAssertNotNil(smsfDetails.trustDeedDate)
        XCTAssertNotNil(smsfDetails.investmentStrategyDate)
        XCTAssertNotNil(smsfDetails.nextAuditDueDate)
        XCTAssertEqual(smsfDetails.entity, smsfEntity)
        XCTAssertEqual(smsfEntity.smsfDetails, smsfDetails)
    }
    
    func testSMSFAuditDueCalculation() {
        // Given
        let smsfDetails = SMSFEntityDetails(context: testContext)
        let pastDate = Calendar.current.date(byAdding: .year, value: -1, to: Date())!
        let futureDate = Calendar.current.date(byAdding: .year, value: 1, to: Date())!
        
        // When - Audit is overdue
        smsfDetails.nextAuditDueDate = pastDate
        
        // Then
        XCTAssertTrue(smsfDetails.isAuditDue)
        
        // When - Audit is not due yet
        smsfDetails.nextAuditDueDate = futureDate
        
        // Then
        XCTAssertFalse(smsfDetails.isAuditDue)
    }
    
    func testSMSFInvestmentStrategyDueCalculation() {
        // Given
        let smsfDetails = SMSFEntityDetails(context: testContext)
        let oldDate = Calendar.current.date(byAdding: .year, value: -2, to: Date())!
        let recentDate = Calendar.current.date(byAdding: .month, value: -6, to: Date())!
        
        // When - Investment strategy is old (>1 year)
        smsfDetails.investmentStrategyDate = oldDate
        
        // Then
        XCTAssertTrue(smsfDetails.isInvestmentStrategyDue)
        
        // When - Investment strategy is recent
        smsfDetails.investmentStrategyDate = recentDate
        
        // Then
        XCTAssertFalse(smsfDetails.isInvestmentStrategyDue)
    }
    
    // MARK: - Cross-Entity Transaction Tests
    
    func testCreateCrossEntityTransaction() {
        // Given
        let fromEntity = EntityType.individual.createEntity(name: "Personal Entity", in: testContext)
        let toEntity = EntityType.company.createEntity(name: "Business Entity", in: testContext)
        
        // When
        let crossTransaction = CrossEntityTransaction(context: testContext)
        crossTransaction.fromEntityId = fromEntity.id
        crossTransaction.toEntityId = toEntity.id
        crossTransaction.amount = 10000.0
        crossTransaction.description = "Loan to business"
        crossTransaction.transactionType = "Loan"
        crossTransaction.fromEntity = fromEntity
        crossTransaction.toEntity = toEntity
        
        // Then
        XCTAssertEqual(crossTransaction.fromEntityId, fromEntity.id)
        XCTAssertEqual(crossTransaction.toEntityId, toEntity.id)
        XCTAssertEqual(crossTransaction.amount, 10000.0)
        XCTAssertEqual(crossTransaction.description, "Loan to business")
        XCTAssertEqual(crossTransaction.transactionType, "Loan")
        XCTAssertEqual(crossTransaction.fromEntity, fromEntity)
        XCTAssertEqual(crossTransaction.toEntity, toEntity)
        XCTAssertNotNil(crossTransaction.id)
        XCTAssertNotNil(crossTransaction.transactionDate)
    }
    
    func testCrossEntityTransactionRelationships() {
        // Given
        let entity1 = EntityType.individual.createEntity(name: "Entity 1", in: testContext)
        let entity2 = EntityType.company.createEntity(name: "Entity 2", in: testContext)
        let crossTransaction = CrossEntityTransaction(context: testContext)
        
        // When
        crossTransaction.fromEntity = entity1
        crossTransaction.toEntity = entity2
        entity1.addToCrossEntityTransactions(crossTransaction)
        
        // Then
        XCTAssertTrue(entity1.crossEntityTransactions.contains(crossTransaction))
        XCTAssertEqual(crossTransaction.fromEntity, entity1)
        XCTAssertEqual(crossTransaction.toEntity, entity2)
    }
    
    // MARK: - Star Schema Relationship Tests
    
    func testTransactionEntityRelationships() {
        // Given
        let user = User(context: testContext)
        user.email = "test@example.com"
        
        let entity = EntityType.individual.createEntity(name: "Test Entity", in: testContext)
        let transaction = Transaction(context: testContext)
        
        // When
        transaction.user = user
        transaction.entity = entity
        transaction.amount = 100.0
        transaction.category = "Test"
        transaction.date = Date()
        
        // Then
        XCTAssertEqual(transaction.user, user)
        XCTAssertEqual(transaction.entity, entity)
        XCTAssertTrue(user.transactions.contains(transaction))
        XCTAssertTrue(entity.transactions.contains(transaction))
    }
    
    func testAssetEntityRelationships() {
        // Given
        let user = User(context: testContext)
        user.email = "test@example.com"
        
        let entity = EntityType.individual.createEntity(name: "Test Entity", in: testContext)
        let asset = Asset(context: testContext)
        
        // When
        asset.user = user
        asset.entity = entity
        asset.name = "Test Asset"
        asset.currentValue = 50000.0
        
        // Then
        XCTAssertEqual(asset.user, user)
        XCTAssertEqual(asset.entity, entity)
        XCTAssertTrue(user.assets.contains(asset))
        XCTAssertTrue(entity.assets.contains(asset))
    }
    
    func testUserEntityOwnershipRelationships() {
        // Given
        let user = User(context: testContext)
        user.email = "owner@example.com"
        
        let entity1 = EntityType.individual.createEntity(name: "Personal Entity", in: testContext)
        let entity2 = EntityType.company.createEntity(name: "Business Entity", in: testContext)
        
        // When
        entity1.owner = user
        entity2.owner = user
        user.addToOwnedEntities(entity1)
        user.addToOwnedEntities(entity2)
        
        // Then
        XCTAssertEqual(entity1.owner, user)
        XCTAssertEqual(entity2.owner, user)
        XCTAssertTrue(user.ownedEntities.contains(entity1))
        XCTAssertTrue(user.ownedEntities.contains(entity2))
        XCTAssertEqual(user.ownedEntities.count, 2)
    }
    
    // MARK: - Australian Compliance Tests
    
    func testEntityTypeABNRequirements() {
        // Individual and Joint don't require ABN
        XCTAssertFalse(EntityType.individual.requiresABN)
        XCTAssertFalse(EntityType.joint.requiresABN)
        
        // Business entities require ABN
        XCTAssertTrue(EntityType.soleTrader.requiresABN)
        XCTAssertTrue(EntityType.company.requiresABN)
        XCTAssertTrue(EntityType.partnership.requiresABN)
        XCTAssertTrue(EntityType.familyTrust.requiresABN)
        XCTAssertTrue(EntityType.smsf.requiresABN)
    }
    
    func testEntityTypeGSTThresholds() {
        // Standard business threshold
        XCTAssertEqual(EntityType.individual.gstThreshold, 75000.0)
        XCTAssertEqual(EntityType.company.gstThreshold, 75000.0)
        XCTAssertEqual(EntityType.soleTrader.gstThreshold, 75000.0)
        
        // SMSF special case
        XCTAssertEqual(EntityType.smsf.gstThreshold, 0.0)
    }
    
    func testEntityTypeTaxReturnRequirements() {
        // All entity types require tax returns in Australia
        for entityType in EntityType.allCases {
            XCTAssertTrue(entityType.requiresTaxReturn, "Entity type \(entityType.rawValue) should require tax return")
        }
    }
    
    // MARK: - Performance Tests
    
    func testEntityCreationPerformance() {
        measure {
            for i in 0..<100 {
                let entity = EntityType.company.createEntity(name: "Test Entity \(i)", in: testContext)
                entity.abn = "1234567890\(i % 10)"
            }
        }
    }
    
    func testCrossEntityTransactionPerformance() {
        // Given
        let entities = (0..<10).map { i in
            EntityType.company.createEntity(name: "Entity \(i)", in: testContext)
        }
        
        // When
        measure {
            for i in 0..<50 {
                let fromEntity = entities[i % entities.count]
                let toEntity = entities[(i + 1) % entities.count]
                
                let crossTransaction = CrossEntityTransaction(context: testContext)
                crossTransaction.fromEntity = fromEntity
                crossTransaction.toEntity = toEntity
                crossTransaction.amount = Double(i * 100)
                crossTransaction.description = "Test transaction \(i)"
                crossTransaction.transactionType = "Transfer"
            }
        }
    }
    
    // MARK: - Data Integrity Tests
    
    func testEntityHierarchyDataIntegrity() {
        // Given
        let parentEntity = EntityType.familyTrust.createEntity(name: "Parent", in: testContext)
        let childEntity = EntityType.company.createEntity(name: "Child", in: testContext)
        
        // When
        parentEntity.addToChildEntities(childEntity)
        
        // Then - Verify bidirectional relationship
        XCTAssertTrue(parentEntity.childEntities.contains(childEntity))
        XCTAssertEqual(childEntity.parentEntity, parentEntity)
        
        // When - Remove child
        parentEntity.removeFromChildEntities(childEntity)
        
        // Then - Verify removal
        XCTAssertFalse(parentEntity.childEntities.contains(childEntity))
        XCTAssertNil(childEntity.parentEntity)
    }
    
    func testCrossEntityTransactionDataIntegrity() {
        // Given
        let entity1 = EntityType.individual.createEntity(name: "Entity 1", in: testContext)
        let entity2 = EntityType.company.createEntity(name: "Entity 2", in: testContext)
        let crossTransaction = CrossEntityTransaction(context: testContext)
        
        // When
        crossTransaction.fromEntity = entity1
        crossTransaction.toEntity = entity2
        crossTransaction.fromEntityId = entity1.id
        crossTransaction.toEntityId = entity2.id
        
        // Then - Verify consistency
        XCTAssertEqual(crossTransaction.fromEntityId, entity1.id)
        XCTAssertEqual(crossTransaction.toEntityId, entity2.id)
        XCTAssertEqual(crossTransaction.fromEntity.id, entity1.id)
        XCTAssertEqual(crossTransaction.toEntity.id, entity2.id)
    }
    
    // MARK: - Integration Tests
    
    func testCompleteMultiEntityScenario() {
        // Given - Create a complex multi-entity structure
        let user = User(context: testContext)
        user.email = "test@example.com"
        
        let personalEntity = EntityType.individual.createEntity(name: "Personal", in: testContext)
        personalEntity.owner = user
        
        let businessEntity = EntityType.company.createEntity(name: "Business Pty Ltd", in: testContext)
        businessEntity.owner = user
        businessEntity.abn = "12345678901"
        businessEntity.gstRegistered = true
        
        let smsfEntity = EntityType.smsf.createEntity(name: "Family SMSF", in: testContext)
        smsfEntity.owner = user
        
        // Create SMSF details
        let smsfDetails = SMSFEntityDetails(context: testContext)
        smsfDetails.abn = "98765432109"
        smsfDetails.trustDeedDate = Date()
        smsfDetails.investmentStrategyDate = Date()
        smsfDetails.nextAuditDueDate = Calendar.current.date(byAdding: .year, value: 1, to: Date())!
        smsfDetails.entity = smsfEntity
        
        // Create assets for different entities
        let personalAsset = Asset(context: testContext)
        personalAsset.name = "Personal Home"
        personalAsset.currentValue = 800000.0
        personalAsset.user = user
        personalAsset.entity = personalEntity
        
        let businessAsset = Asset(context: testContext)
        businessAsset.name = "Business Equipment"
        businessAsset.currentValue = 50000.0
        businessAsset.user = user
        businessAsset.entity = businessEntity
        
        // Create cross-entity transaction
        let crossTransaction = CrossEntityTransaction(context: testContext)
        crossTransaction.fromEntity = personalEntity
        crossTransaction.toEntity = businessEntity
        crossTransaction.amount = 25000.0
        crossTransaction.description = "Initial business investment"
        crossTransaction.transactionType = "Investment"
        
        // When - Save context
        do {
            try testContext.save()
        } catch {
            XCTFail("Failed to save context: \(error)")
        }
        
        // Then - Verify complete structure
        XCTAssertEqual(user.ownedEntities.count, 3)
        XCTAssertTrue(user.ownedEntities.contains(personalEntity))
        XCTAssertTrue(user.ownedEntities.contains(businessEntity))
        XCTAssertTrue(user.ownedEntities.contains(smsfEntity))
        
        XCTAssertEqual(user.assets.count, 2)
        XCTAssertTrue(user.assets.contains(personalAsset))
        XCTAssertTrue(user.assets.contains(businessAsset))
        
        XCTAssertEqual(personalEntity.assets.count, 1)
        XCTAssertEqual(businessEntity.assets.count, 1)
        
        XCTAssertEqual(smsfEntity.smsfDetails, smsfDetails)
        XCTAssertFalse(smsfDetails.isAuditDue)
        
        XCTAssertEqual(crossTransaction.fromEntity, personalEntity)
        XCTAssertEqual(crossTransaction.toEntity, businessEntity)
    }
}




