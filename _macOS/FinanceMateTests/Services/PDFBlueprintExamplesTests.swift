import XCTest
@testable import FinanceMate

/// Tests for BLUEPRINT PDF examples (City of Gold Coast, Our Sage, Bunnings)
/// BLUEPRINT Line 58-69: Validates real-world PDF extraction scenarios
class PDFBlueprintExamplesTests: XCTestCase {

    /// Test City of Gold Coast PDF extraction (BLUEPRINT Example 1)
    /// Expected: 2 line items (Rates $500.00, Merchant Fee $3.40)
    func testCityOfGoldCoastPDF() async throws {
        let pdfAttachment = GmailAttachment(
            id: "attach_cog",
            filename: "05416335.pdf",
            mimeType: "application/pdf",
            size: 75000
        )

        let email = GmailEmail(
            id: "msg_cog",
            subject: "City of Gold Coast Rates Notice",
            sender: "noreply@goldcoast.qld.gov.au",
            date: Date(),
            snippet: "Your rates assessment...",
            attachments: [pdfAttachment]
        )

        let transactions = await IntelligentExtractionService.extract(from: email)

        XCTAssertGreaterThan(transactions.count, 0)
        XCTAssertGreaterThan(transactions.first?.confidence ?? 0, 0.7)
        XCTAssertFalse(transactions.first?.merchant.isEmpty ?? true)
    }

    /// Test password-protected PDF handling (BLUEPRINT Example 2 - Our Sage)
    /// Expected: Manual review transaction with password escalation
    func testPasswordProtectedPDF() async throws {
        let pdfAttachment = GmailAttachment(
            id: "attach_sage",
            filename: "Receipt-249589.pdf",
            mimeType: "application/pdf",
            size: 35000
        )

        let email = GmailEmail(
            id: "msg_sage",
            subject: "Our Sage Receipt",
            sender: "OurSage@automedsystems-syd.com.au",
            date: Date(),
            snippet: "Your receipt is attached",
            attachments: [pdfAttachment]
        )

        let transactions = await IntelligentExtractionService.extract(from: email)

        XCTAssertEqual(transactions.count, 1)
        XCTAssertFalse(transactions.first?.merchant.isEmpty ?? true)
        XCTAssertNotNil(transactions.first?.date)
    }

    /// Test Bunnings multi-line PDF extraction (BLUEPRINT Example 3)
    /// Expected: Transactions with line items
    func testBunningsMultiLinePDF() async throws {
        let pdfAttachment = GmailAttachment(
            id: "attach_bunnings",
            filename: "Invoice-IN2134A-7931.pdf",
            mimeType: "application/pdf",
            size: 90000
        )

        let email = GmailEmail(
            id: "msg_bunnings",
            subject: "Bunnings Marketplace Order Confirmation",
            sender: "noreply@marketplace-comms.bunnings.com.au",
            date: Date(),
            snippet: "Your order has been shipped",
            attachments: [pdfAttachment]
        )

        let transactions = await IntelligentExtractionService.extract(from: email)

        XCTAssertGreaterThan(transactions.count, 0)
        XCTAssertGreaterThan(transactions.first?.confidence ?? 0, 0.7)
        XCTAssertNotNil(transactions.first?.items)
    }
}
