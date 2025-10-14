import XCTest
@testable import FinanceMate

/// Tests for PDF extraction priority (Tier 0)
/// Validates that PDF extraction takes precedence over regex/Foundation Models
/// BLUEPRINT Line 58-69: PDF as highest priority extraction tier
class PDFExtractionPriorityTests: XCTestCase {

    // MARK: - Priority Tests

    /// Test that PDF extraction takes priority over regex extraction
    /// BLUEPRINT requirement: PDF should be Tier 0 (highest priority)
    func testPDFExtractionHasPriority() async throws {
        // Arrange: Email with both PDF attachment AND parseable body text
        let pdfAttachment = GmailAttachment(
            id: "attach123",
            filename: "invoice.pdf",
            mimeType: "application/pdf",
            size: 50000
        )

        let email = GmailEmail(
            id: "msg001",
            subject: "Your invoice for $100.00",
            sender: "test@example.com",
            date: Date(),
            snippet: "Invoice total: $100.00",
            attachments: [pdfAttachment]
        )

        // Act: Extract transactions
        let transactions = await IntelligentExtractionService.extract(from: email)

        // Assert: Should extract with high confidence (PDF extraction)
        XCTAssertGreaterThan(transactions.count, 0)
        XCTAssertGreaterThan(transactions.first?.confidence ?? 0, 0.8)
    }

    /// Test fallback to regex when PDF extraction fails
    func testFallbackToRegexWhenPDFFails() async throws {
        // Arrange: Email with corrupted PDF + parseable body
        let corruptedPDF = GmailAttachment(
            id: "attach_corrupt",
            filename: "corrupted.pdf",
            mimeType: "application/pdf",
            size: 100
        )

        let email = GmailEmail(
            id: "msg_fallback",
            subject: "Invoice $250.00",
            sender: "vendor@example.com",
            date: Date(),
            snippet: "Total: $250.00",
            attachments: [corruptedPDF]
        )

        // Act: Extract transactions
        let transactions = await IntelligentExtractionService.extract(from: email)

        // Assert: Should extract using fallback
        XCTAssertGreaterThan(transactions.count, 0)
        XCTAssertFalse(transactions.first?.merchant.isEmpty ?? true)
    }

    /// Test email with no PDF attachments uses existing extraction tiers
    func testNoPDFUsesExistingTiers() async throws {
        // Arrange: Email with no attachments
        let email = GmailEmail(
            id: "msg_no_pdf",
            subject: "Payment confirmation $100.00",
            sender: "paypal@example.com",
            date: Date(),
            snippet: "You paid $100.00",
            attachments: []
        )

        // Act: Extract transactions
        let transactions = await IntelligentExtractionService.extract(from: email)

        // Assert: Should use existing tiers
        XCTAssertGreaterThan(transactions.count, 0)
        XCTAssertFalse(transactions.first?.merchant.isEmpty ?? true)
    }
}
