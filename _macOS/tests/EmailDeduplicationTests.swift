import XCTest
import CoreData
@testable import FinanceMate

/// Email Deduplication Tests - RED Phase
/// Tests for Set-based email deduplication by ID and hash-based content deduplication
final class EmailDeduplicationTests: XCTestCase {

    var testContext: NSManagedObjectContext!
    var testPersistenceController: PersistenceController!
    var emailCacheService: EmailCacheService!

    override func setUpWithError() throws {
        testPersistenceController = PersistenceController(inMemory: true)
        testContext = testPersistenceController.container.viewContext
        emailCacheService = EmailCacheService(context: testContext)
    }

    override func tearDownWithError() throws {
        testContext = nil
        testPersistenceController = nil
        emailCacheService = nil
    }

    /// Test that getDeduplicatedEmails removes duplicates by email ID
    /// RED PHASE: This should fail because current implementation returns unchanged array
    func testGetDeduplicatedEmailsRemovesDuplicatesByID() throws {
        // Create test emails with duplicate IDs
        let email1 = GmailEmail(
            id: "duplicate-id-1",
            subject: "Original Email 1",
            sender: "test@example.com",
            date: Date(),
            snippet: "Original content 1",
            attachments: []
        )

        let email2 = GmailEmail(
            id: "duplicate-id-1", // Same ID as email1
            subject: "Updated Email 1", // Different content
            sender: "test@example.com",
            date: Date().addingTimeInterval(3600), // Different time
            snippet: "Updated content 1",
            attachments: []
        )

        let email3 = GmailEmail(
            id: "unique-id-3",
            subject: "Unique Email 3",
            sender: "other@example.com",
            date: Date(),
            snippet: "Unique content 3",
            attachments: []
        )

        let newEmails = [email1, email2, email3]

        // Test deduplication
        let deduplicatedEmails = emailCacheService.getDeduplicatedEmails(newEmails: newEmails)

        // RED VERIFICATION: Should remove duplicates, keeping the most recent by date
        XCTAssertEqual(deduplicatedEmails.count, 2, "Should remove duplicate email by ID, keeping most recent")

        // Should have unique email IDs
        let uniqueIDs = Set(deduplicatedEmails.map { $0.id })
        XCTAssertEqual(uniqueIDs.count, deduplicatedEmails.count, "All emails should have unique IDs")

        // Should keep the most recent version of the duplicate
        let keptDuplicate = deduplicatedEmails.first { $0.id == "duplicate-id-1" }
        XCTAssertNotNil(keptDuplicate, "Should keep one version of the duplicate email")
        XCTAssertEqual(keptDuplicate?.subject, "Updated Email 1", "Should keep the most recent version by date")

        // Should keep the unique email unchanged
        let keptUnique = deduplicatedEmails.first { $0.id == "unique-id-3" }
        XCTAssertNotNil(keptUnique, "Should keep unique email")
        XCTAssertEqual(keptUnique?.subject, "Unique Email 3", "Should keep unique email unchanged")
    }

    /// Test that getDeduplicatedEmails removes content duplicates even with different IDs
    /// RED PHASE: This should fail because current implementation returns unchanged array
    func testGetDeduplicatedEmailsRemovesContentDuplicatesByHash() throws {
        // Create emails with different IDs but identical content (should be deduplicated by content hash)
        let email1 = GmailEmail(
            id: "different-id-1",
            subject: "Same Subject",
            sender: "same@example.com",
            date: Date(),
            snippet: "Same snippet content",
            attachments: []
        )

        let email2 = GmailEmail(
            id: "different-id-2", // Different ID
            subject: "Same Subject", // Same content
            sender: "same@example.com",
            date: Date().addingTimeInterval(3600), // Different time
            snippet: "Same snippet content", // Same content
            attachments: []
        )

        let newEmails = [email1, email2]

        // Test deduplication
        let deduplicatedEmails = emailCacheService.getDeduplicatedEmails(newEmails: newEmails)

        // RED VERIFICATION: Should remove content duplicates, keeping the most recent by date
        XCTAssertEqual(deduplicatedEmails.count, 1, "Should remove content duplicates, keeping most recent")

        let keptEmail = deduplicatedEmails.first
        XCTAssertNotNil(keptEmail, "Should keep one version of the content duplicate")
        XCTAssertEqual(keptEmail?.subject, "Same Subject", "Should keep the content")
        // Should keep the most recent version (email2 with later date)
        XCTAssertEqual(keptEmail?.id, "different-id-2", "Should keep the most recent version by date")
    }

    /// Test that getDeduplicatedEmails handles empty array
    func testGetDeduplicatedEmailsHandlesEmptyArray() throws {
        let emptyEmails: [GmailEmail] = []

        let deduplicatedEmails = emailCacheService.getDeduplicatedEmails(newEmails: emptyEmails)

        XCTAssertEqual(deduplicatedEmails.count, 0, "Should handle empty array gracefully")
    }

    /// Test that getDeduplicatedEmails handles array with no duplicates
    func testGetDeduplicatedEmailsHandlesNoDuplicates() throws {
        let email1 = GmailEmail(
            id: "unique-id-1",
            subject: "Unique Email 1",
            sender: "test1@example.com",
            date: Date(),
            snippet: "Unique content 1",
            attachments: []
        )

        let email2 = GmailEmail(
            id: "unique-id-2",
            subject: "Unique Email 2",
            sender: "test2@example.com",
            date: Date(),
            snippet: "Unique content 2",
            attachments: []
        )

        let uniqueEmails = [email1, email2]

        let deduplicatedEmails = emailCacheService.getDeduplicatedEmails(newEmails: uniqueEmails)

        XCTAssertEqual(deduplicatedEmails.count, 2, "Should return all emails when there are no duplicates")
        XCTAssertEqual(deduplicatedEmails.map { $0.id }.sorted(), ["unique-id-1", "unique-id-2"], "Should preserve all unique emails")
    }
}