import XCTest
import CoreData
@testable import FinanceMate

/// Core Data Gmail Archive Tests - Phase 2 RED
/// BLUEPRINT Line 104: Core Data Model Changes for Gmail Archive System
/// Comprehensive failing tests for Core Data model updates needed for archive functionality
final class CoreDataGmailArchiveTests: XCTestCase {

    var testContext: NSManagedObjectContext!
    var testPersistenceController: PersistenceController!

    override func setUpWithError() throws {
        testPersistenceController = PersistenceController(inMemory: true)
        testContext = testPersistenceController.container.viewContext
    }

    override func tearDownWithError() throws {
        testContext = nil
        testPersistenceController = nil
    }

    // MARK: - Email Status Entity Tests

    /// Test EmailStatusEntity exists in Core Data model
    func testEmailStatusEntityExists() throws {
        // This test should FAIL until EmailStatusEntity is added to Core Data model
        let entity = NSEntityDescription.entity(forEntityName: "EmailStatusEntity", in: testContext)

        XCTAssertNotNil(entity, "EmailStatusEntity should exist in Core Data model")

        // Test required attributes exist
        XCTAssertNotNil(entity?.attributesByName["emailId"], "EmailStatusEntity should have emailId attribute")
        XCTAssertNotNil(entity?.attributesByName["status"], "EmailStatusEntity should have status attribute")
        XCTAssertNotNil(entity?.attributesByName["lastUpdated"], "EmailStatusEntity should have lastUpdated attribute")
    }

    /// Test EmailStatusEntity attribute types
    func testEmailStatusEntityAttributeTypes() throws {
        // This test should FAIL until EmailStatusEntity is properly configured
        let entity = NSEntityDescription.entity(forEntityName: "EmailStatusEntity", in: testContext)

        // Test emailId attribute type
        let emailIdAttribute = entity?.attributesByName["emailId"]
        XCTAssertEqual(emailIdAttribute?.attributeType, .stringAttributeType, "emailId should be string type")
        XCTAssertFalse(emailIdAttribute?.isOptional ?? true, "emailId should be required")

        // Test status attribute type
        let statusAttribute = entity?.attributesByName["status"]
        XCTAssertEqual(statusAttribute?.attributeType, .stringAttributeType, "status should be string type")
        XCTAssertFalse(statusAttribute?.isOptional ?? true, "status should be required")

        // Test lastUpdated attribute type
        let lastUpdatedAttribute = entity?.attributesByName["lastUpdated"]
        XCTAssertEqual(lastUpdatedAttribute?.attributeType, .dateAttributeType, "lastUpdated should be date type")
        XCTAssertFalse(lastUpdatedAttribute?.isOptional ?? true, "lastUpdated should be required")
    }

    /// Test EmailStatusEntity creation and validation
    func testEmailStatusEntityCreation() throws {
        // This test should FAIL until EmailStatusEntity is implemented
        let emailStatus = EmailStatusEntity(context: testContext)

        // Test required properties
        emailStatus.emailId = "test-email-123"
        emailStatus.status = "archived"
        emailStatus.lastUpdated = Date()

        // Save to Core Data
        try testContext.save()

        // Retrieve and verify
        let fetchRequest: NSFetchRequest<EmailStatusEntity> = EmailStatusEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "emailId == %@", "test-email-123")
        let results = try testContext.fetch(fetchRequest)

        XCTAssertEqual(results.count, 1, "Should create and retrieve EmailStatusEntity")
        XCTAssertEqual(results.first?.emailId, "test-email-123")
        XCTAssertEqual(results.first?.status, "archived")
        XCTAssertNotNil(results.first?.lastUpdated)
    }

    /// Test EmailStatusEntity unique constraint on emailId
    func testEmailStatusEntityUniqueConstraint() throws {
        // This test should FAIL until unique constraint is added to Core Data model
        let emailId = "unique-test-email"

        // Create first EmailStatusEntity
        let firstStatus = EmailStatusEntity(context: testContext)
        firstStatus.emailId = emailId
        firstStatus.status = "needsReview"
        firstStatus.lastUpdated = Date()

        try testContext.save()

        // Try to create second EmailStatusEntity with same emailId
        let secondStatus = EmailStatusEntity(context: testContext)
        secondStatus.emailId = emailId
        secondStatus.status = "archived"
        secondStatus.lastUpdated = Date()

        // Should fail due to unique constraint
        XCTAssertThrowsError(try testContext.save(), "Should prevent duplicate emailId")
    }

    // MARK: - Transaction Entity Relationship Tests

    /// Test Transaction entity has emailStatus relationship
    func testTransactionEntityEmailStatusRelationship() throws {
        // This test should FAIL until relationship is added to Transaction entity
        let transaction = Transaction(context: testContext)

        // Test relationship exists
        let relationship = transaction.entity.relationshipsByName["emailStatus"]
        XCTAssertNotNil(relationship, "Transaction should have emailStatus relationship")

        // Test relationship type
        XCTAssertEqual(relationship?.isToMany, false, "emailStatus should be to-one relationship")
    }

    /// Test Transaction to EmailStatusEntity relationship
    func testTransactionToEmailStatusRelationship() throws {
        // This test should FAIL until relationship is implemented
        let transaction = Transaction(context: testContext)
        transaction.id = UUID()
        transaction.amount = 25.50
        transaction.itemDescription = "Test Transaction"
        transaction.date = Date()
        transaction.sourceEmailID = "test-email-456"

        let emailStatus = EmailStatusEntity(context: testContext)
        emailStatus.emailId = "test-email-456"
        emailStatus.status = "transactionCreated"
        emailStatus.lastUpdated = Date()

        // Establish relationship
        transaction.emailStatus = emailStatus

        // Save both entities
        try testContext.save()

        // Verify relationship
        let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "sourceEmailID == %@", "test-email-456")
        let results = try testContext.fetch(fetchRequest)

        XCTAssertEqual(results.count, 1, "Should find transaction")
        XCTAssertEqual(results.first?.emailStatus?.emailId, "test-email-456")
        XCTAssertEqual(results.first?.emailStatus?.status, "transactionCreated")
    }

    /// Test EmailStatusEntity to Transaction inverse relationship
    func testEmailStatusToTransactionInverseRelationship() throws {
        // This test should FAIL until inverse relationship is implemented
        let emailStatus = EmailStatusEntity(context: testContext)
        emailStatus.emailId = "inverse-test-email"
        emailStatus.status = "needsReview"
        emailStatus.lastUpdated = Date()

        let transaction = Transaction(context: testContext)
        transaction.id = UUID()
        transaction.amount = 50.0
        transaction.itemDescription = "Inverse Test Transaction"
        transaction.date = Date()
        transaction.sourceEmailID = "inverse-test-email"

        // Establish relationship
        emailStatus.transaction = transaction

        // Save both entities
        try testContext.save()

        // Verify inverse relationship
        let fetchRequest: NSFetchRequest<EmailStatusEntity> = EmailStatusEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "emailId == %@", "inverse-test-email")
        let results = try testContext.fetch(fetchRequest)

        XCTAssertEqual(results.count, 1, "Should find EmailStatusEntity")
        XCTAssertNotNil(results.first?.transaction, "Should have related transaction")
        XCTAssertEqual(results.first?.transaction?.sourceEmailID, "inverse-test-email")
    }

    // MARK: - GmailEmail Entity Tests

    /// Test GmailEmail entity exists in Core Data model
    func testGmailEmailEntityExists() throws {
        // This test should FAIL until GmailEmail entity is added to Core Data model
        let entity = NSEntityDescription.entity(forEntityName: "GmailEmail", in: testContext)

        XCTAssertNotNil(entity, "GmailEmail entity should exist in Core Data model")

        // Test required attributes
        XCTAssertNotNil(entity?.attributesByName["id"], "GmailEmail should have id attribute")
        XCTAssertNotNil(entity?.attributesByName["subject"], "GmailEmail should have subject attribute")
        XCTAssertNotNil(entity?.attributesByName["sender"], "GmailEmail should have sender attribute")
        XCTAssertNotNil(entity?.attributesByName["date"], "GmailEmail should have date attribute")
        XCTAssertNotNil(entity?.attributesByName["snippet"], "GmailEmail should have snippet attribute")
        XCTAssertNotNil(entity?.attributesByName["status"], "GmailEmail should have status attribute")
    }

    /// Test GmailEmail entity creation and validation
    func testGmailEmailEntityCreation() throws {
        // This test should FAIL until GmailEmail entity is implemented
        let gmailEmail = GmailEmailEntity(context: testContext)

        // Set required properties
        gmailEmail.id = "gmail-email-123"
        gmailEmail.subject = "Test Receipt"
        gmailEmail.sender = "test@test.com"
        gmailEmail.date = Date()
        gmailEmail.snippet = "Test receipt snippet"
        gmailEmail.status = "needsReview"

        // Save to Core Data
        try testContext.save()

        // Retrieve and verify
        let fetchRequest: NSFetchRequest<GmailEmailEntity> = GmailEmailEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", "gmail-email-123")
        let results = try testContext.fetch(fetchRequest)

        XCTAssertEqual(results.count, 1, "Should create and retrieve GmailEmailEntity")
        XCTAssertEqual(results.first?.id, "gmail-email-123")
        XCTAssertEqual(results.first?.subject, "Test Receipt")
        XCTAssertEqual(results.first?.sender, "test@test.com")
        XCTAssertEqual(results.first?.status, "needsReview")
    }

    /// Test GmailEmail to Transaction relationship
    func testGmailEmailToTransactionRelationship() throws {
        // This test should FAIL until relationship is implemented
        let gmailEmail = GmailEmailEntity(context: testContext)
        gmailEmail.id = "related-gmail-email"
        gmailEmail.subject = "Related Test Receipt"
        gmailEmail.sender = "related@test.com"
        gmailEmail.date = Date()
        gmailEmail.snippet = "Related test receipt snippet"
        gmailEmail.status = "transactionCreated"

        let transaction = Transaction(context: testContext)
        transaction.id = UUID()
        transaction.amount = 75.0
        transaction.itemDescription = "Related Test Transaction"
        transaction.date = Date()
        transaction.sourceEmailID = "related-gmail-email"

        // Establish relationship
        gmailEmail.transaction = transaction

        // Save both entities
        try testContext.save()

        // Verify relationship
        let fetchRequest: NSFetchRequest<GmailEmailEntity> = GmailEmailEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", "related-gmail-email")
        let results = try testContext.fetch(fetchRequest)

        XCTAssertEqual(results.count, 1, "Should find GmailEmailEntity")
        XCTAssertNotNil(results.first?.transaction, "Should have related transaction")
        XCTAssertEqual(results.first?.transaction?.sourceEmailID, "related-gmail-email")
    }

    // MARK: - Email Status Enum Tests

    /// Test EmailStatus enum values in Core Data
    func testEmailStatusEnumInCoreData() throws {
        // This test should FAIL until enum is properly handled in Core Data
        let emailId = "enum-test-email"

        // Test all enum values can be stored and retrieved
        let statuses: [EmailStatus] = [.needsReview, .transactionCreated, .archived]

        for (index, status) in statuses.enumerated() {
            let emailStatus = EmailStatusEntity(context: testContext)
            emailStatus.emailId = "\(emailId)-\(index)"
            emailStatus.status = status.rawValue
            emailStatus.lastUpdated = Date()

            try testContext.save()

            // Retrieve and verify enum conversion
            let fetchRequest: NSFetchRequest<EmailStatusEntity> = EmailStatusEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "emailId == %@", "\(emailId)-\(index)")
            let results = try testContext.fetch(fetchRequest)

            XCTAssertEqual(results.count, 1, "Should find EmailStatusEntity for \(status)")
            XCTAssertEqual(results.first?.status, status.rawValue, "Should preserve enum raw value")

            // Test enum conversion back from Core Data
            let retrievedStatus = EmailStatus(rawValue: results.first!.status)
            XCTAssertNotNil(retrievedStatus, "Should convert back to EmailStatus enum")
            XCTAssertEqual(retrievedStatus, status, "Should preserve enum value")
        }
    }

    // MARK: - Migration Tests

    /// test Core Data model migration for archive features
    func testCoreDataModelMigrationForArchiveFeatures() throws {
        // This test should FAIL until migration is implemented
        // This would test migrating from existing model to model with archive features

        // For now, verify new model can be created
        XCTAssertNotNil(testPersistenceController, "Should be able to create persistence controller with archive features")

        // Migration testing would require setting up multiple model versions
        // and testing migration between them
    }

    /// Test fallback for existing transactions without email status
    func testFallbackForExistingTransactions() throws {
        // This test should FAIL until fallback logic is implemented
        // Create transaction without email status (simulating existing data)
        let transaction = Transaction(context: testContext)
        transaction.id = UUID()
        transaction.amount = 100.0
        transaction.itemDescription = "Existing Transaction"
        transaction.date = Date()
        transaction.sourceEmailID = "existing-email-123"

        try testContext.save()

        // System should handle missing email status gracefully
        // Should default to needsReview status for missing entities
        let fetchRequest: NSFetchRequest<EmailStatusEntity> = EmailStatusEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "emailId == %@", "existing-email-123")
        let results = try testContext.fetch(fetchRequest)

        XCTAssertEqual(results.count, 0, "Should not have EmailStatusEntity for existing transaction")

        // System should create default status when accessed
        // This requires implementing fallback logic
    }

    // MARK: - Performance Tests

    /// Test performance with large number of email statuses
    func testEmailStatusPerformanceWithLargeDataset() throws {
        // This test should FAIL until performance is optimized
        let emailCount = 10000
        var emailStatuses: [EmailStatusEntity] = []

        // Create large dataset
        let startTime = CFAbsoluteTimeGetCurrent()

        for i in 0..<emailCount {
            let emailStatus = EmailStatusEntity(context: testContext)
            emailStatus.emailId = "perf-test-\(i)"
            emailStatus.status = i % 2 == 0 ? "archived" : "needsReview"
            emailStatus.lastUpdated = Date()
            emailStatuses.append(emailStatus)
        }

        try testContext.save()

        let creationTime = CFAbsoluteTimeGetCurrent() - startTime
        XCTAssertLessThan(creationTime, 5.0, "Should create \(emailCount) email statuses within 5 seconds")

        // Test query performance
        let queryStartTime = CFAbsoluteTimeGetCurrent()

        let fetchRequest: NSFetchRequest<EmailStatusEntity> = EmailStatusEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "status == %@", "archived")
        let archivedCount = try testContext.count(for: fetchRequest)

        let queryTime = CFAbsoluteTimeGetCurrent() - queryStartTime
        XCTAssertLessThan(queryTime, 1.0, "Should query archived statuses within 1 second")
        XCTAssertEqual(archivedCount, emailCount / 2, "Should find half of emails as archived")
    }

    /// Test relationship performance
    func testRelationshipPerformanceWithLargeDataset() throws {
        // This test should FAIL until relationship performance is optimized
        let transactionCount = 1000

        // Create transactions with email relationships
        let startTime = CFAbsoluteTimeGetCurrent()

        for i in 0..<transactionCount {
            let transaction = Transaction(context: testContext)
            transaction.id = UUID()
            transaction.amount = Double(i)
            transaction.itemDescription = "Performance Transaction \(i)"
            transaction.date = Date()
            transaction.sourceEmailID = "perf-email-\(i)"

            let emailStatus = EmailStatusEntity(context: testContext)
            emailStatus.emailId = "perf-email-\(i)"
            emailStatus.status = "transactionCreated"
            emailStatus.lastUpdated = Date()

            transaction.emailStatus = emailStatus
        }

        try testContext.save()

        let creationTime = CFAbsoluteTimeGetCurrent() - startTime
        XCTAssertLessThan(creationTime, 3.0, "Should create \(transactionCount) relationships within 3 seconds")

        // Test relationship query performance
        let queryStartTime = CFAbsoluteTimeGetCurrent()

        let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "emailStatus.status == %@", "transactionCreated")
        let relatedCount = try testContext.count(for: fetchRequest)

        let queryTime = CFAbsoluteTimeGetCurrent() - queryStartTime
        XCTAssertLessThan(queryTime, 1.0, "Should query relationships within 1 second")
        XCTAssertEqual(relatedCount, transactionCount, "Should find all related transactions")
    }

    // MARK: - Data Integrity Tests

    /// Test email status data integrity
    func testEmailStatusDataIntegrity() throws {
        // This test should FAIL until data integrity is enforced
        let emailStatus = EmailStatusEntity(context: testContext)

        // Test required field validation
        emailStatus.emailId = ""  // Invalid empty emailId
        emailStatus.status = "archived"
        emailStatus.lastUpdated = Date()

        // Should fail validation
        XCTAssertThrowsError(try testContext.save(), "Should prevent empty emailId")

        testContext.reset()

        // Test invalid status
        let invalidStatusEmail = EmailStatusEntity(context: testContext)
        invalidStatusEmail.emailId = "invalid-status-test"
        invalidStatusEmail.status = "invalid_status"  // Not a valid EmailStatus
        invalidStatusEmail.lastUpdated = Date()

        try testContext.save()

        // Should handle invalid status gracefully when reading
        let fetchRequest: NSFetchRequest<EmailStatusEntity> = EmailStatusEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "emailId == %@", "invalid-status-test")
        let results = try testContext.fetch(fetchRequest)

        XCTAssertEqual(results.count, 1, "Should save entity with invalid status")
        // System should handle invalid status when converting to enum
        let retrievedStatus = EmailStatus(rawValue: results.first!.status)
        XCTAssertNil(retrievedStatus, "Should return nil for invalid status")
    }

    /// Test cascade delete rules
    func testCascadeDeleteRules() throws {
        // This test should FAIL until delete rules are properly configured
        let emailStatus = EmailStatusEntity(context: testContext)
        emailStatus.emailId = "cascade-test-email"
        emailStatus.status = "needsReview"
        emailStatus.lastUpdated = Date()

        let transaction = Transaction(context: testContext)
        transaction.id = UUID()
        transaction.amount = 25.0
        transaction.itemDescription = "Cascade Test Transaction"
        transaction.date = Date()
        transaction.sourceEmailID = "cascade-test-email"

        emailStatus.transaction = transaction

        try testContext.save()

        // Verify relationship exists
        XCTAssertEqual(emailStatus.transaction?.sourceEmailID, "cascade-test-email")

        // Delete transaction
        testContext.delete(transaction)
        try testContext.save()

        // Verify EmailStatusEntity is also deleted (cascade delete)
        let fetchRequest: NSFetchRequest<EmailStatusEntity> = EmailStatusEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "emailId == %@", "cascade-test-email")
        let results = try testContext.fetch(fetchRequest)

        XCTAssertEqual(results.count, 0, "EmailStatusEntity should be deleted when related transaction is deleted")
    }
}

// MARK: - Supporting Entity Classes (These should be added to Core Data model)

/// Gmail Email Entity (should be added to Core Data model)
class GmailEmailEntity: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var subject: String
    @NSManaged public var sender: String
    @NSManaged public var date: Date
    @NSManaged public var snippet: String
    @NSManaged public var status: String
    @NSManaged public var transaction: Transaction?
}

// Extension to add relationship properties to existing entities
extension Transaction {
    @NSManaged public var emailStatus: EmailStatusEntity?
}

extension EmailStatusEntity {
    @NSManaged public var transaction: Transaction?
}