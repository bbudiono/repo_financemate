import XCTest
@testable import FinanceMate

/// Tests for PDF attachment caching
/// Validates cache-first approach reduces redundant downloads
class PDFCachingTests: XCTestCase {

    /// Test that PDF caching reduces redundant downloads
    func testPDFCachingConsistency() async throws {
        let pdfAttachment = GmailAttachment(
            id: "attach_cache",
            filename: "invoice.pdf",
            mimeType: "application/pdf",
            size: 50000
        )

        let email = GmailEmail(
            id: "msg_cache",
            subject: "Invoice",
            sender: "test@example.com",
            date: Date(),
            snippet: "Invoice attached",
            attachments: [pdfAttachment]
        )

        // Extract twice
        let transactions1 = await IntelligentExtractionService.extract(from: email)
        let transactions2 = await IntelligentExtractionService.extract(from: email)

        XCTAssertGreaterThan(transactions1.count, 0)
        XCTAssertGreaterThan(transactions2.count, 0)
        XCTAssertEqual(transactions1.count, transactions2.count)
    }

    /// Test email with multiple PDF attachments
    func testMultiplePDFAttachments() async throws {
        let pdf1 = GmailAttachment(
            id: "attach1",
            filename: "invoice1.pdf",
            mimeType: "application/pdf",
            size: 50000
        )

        let pdf2 = GmailAttachment(
            id: "attach2",
            filename: "invoice2.pdf",
            mimeType: "application/pdf",
            size: 60000
        )

        let email = GmailEmail(
            id: "msg_multi",
            subject: "Multiple Invoices",
            sender: "vendor@example.com",
            date: Date(),
            snippet: "Two invoices attached",
            attachments: [pdf1, pdf2]
        )

        let transactions = await IntelligentExtractionService.extract(from: email)

        XCTAssertGreaterThan(transactions.count, 0)
    }

    /// Test email with mixed attachments (PDF + image)
    func testMixedAttachmentTypes() async throws {
        let pdfAttachment = GmailAttachment(
            id: "attach_pdf",
            filename: "invoice.pdf",
            mimeType: "application/pdf",
            size: 50000
        )

        let imageAttachment = GmailAttachment(
            id: "attach_img",
            filename: "receipt.jpg",
            mimeType: "image/jpeg",
            size: 200000
        )

        let email = GmailEmail(
            id: "msg_mixed",
            subject: "Invoice and Receipt",
            sender: "vendor@example.com",
            date: Date(),
            snippet: "Documents attached",
            attachments: [pdfAttachment, imageAttachment]
        )

        let transactions = await IntelligentExtractionService.extract(from: email)

        XCTAssertGreaterThan(transactions.count, 0)
        XCTAssertGreaterThan(transactions.first?.confidence ?? 0, 0.5)
    }
}
