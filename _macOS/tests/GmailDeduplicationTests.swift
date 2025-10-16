import XCTest
@testable import FinanceMate

/// PHASE 1: Gmail Deduplication Tests - RED
/// Tests missing email ID + content hash deduplication
final class GmailDeduplicationTests: XCTestCase {

    func testGmailPagination_FiltersDuplicatesByIdAndHash() async throws {
        let email1 = createTestGmailEmail(id: "1", content: "Receipt from Amazon - $25.99", sender: "amazon@amazon.com")
        let email2 = createTestGmailEmail(id: "2", content: "Receipt from Amazon - $25.99", sender: "amazon@amazon.com")
        let email3 = createTestGmailEmail(id: "1", content: "Receipt from Amazon - $25.99", sender: "amazon@amazon.com")
        let emails = [email1, email2, email3]

        let result = GmailPaginationEnhancer.deduplicateEmails(emails)

        XCTAssertEqual(result.unique.count, 2, "Should keep 2 unique emails")
        XCTAssertEqual(result.duplicatesRemoved, 1, "Should remove 1 duplicate")
        XCTAssertGreaterThan(result.contentHashes.count, 0, "Should track content hashes")
    }

    func testGmailPagination_ContentHashConsistency() async throws {
        let content1 = "Order #12345 - Amazon.com - Total: $99.99"
        let content2 = "Order #12345 - Amazon.com - Total: $99.99"
        let content3 = "Order #67890 - Different content"

        let hash1 = content1.sha256()
        let hash2 = content2.sha256()
        let hash3 = content3.sha256()

        XCTAssertEqual(hash1, hash2, "Same content must produce same hash")
        XCTAssertNotEqual(hash1, hash3, "Different content must produce different hash")
        XCTAssertFalse(hash1.isEmpty, "Hash must not be empty")
    }

    private func createTestGmailEmail(id: String, content: String, sender: String) -> GmailEmail {
        return GmailEmail(
            id: id,
            subject: "Test Receipt",
            sender: sender,
            date: Date(),
            snippet: content,
            attachments: []
        )
    }
}