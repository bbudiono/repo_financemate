import XCTest
@testable import FinanceMate

/// Tests for transaction description extraction from Gmail receipts
/// Addresses BLUEPRINT.md Line 177: Transaction descriptions must be properly extracted
/// from Gmail receipts and displayed in Transactions table with real merchant data,
/// not default values or empty strings using proper parsing algorithms.
final class TransactionDescriptionExtractionTests: XCTestCase {

    /// Test merchant extraction fails with current implementation for realistic Gmail receipts
    func testMerchantExtractionFailsWithCurrentImplementation() {
        let testEmail = GmailEmail(
            id: "test_uber",
            subject: "Your Uber trip to Melbourne Airport",
            sender: "receipts@uber.com",
            date: Date(),
            snippet: "Total: $45.80 charged to Visa ending in 1234"
        )

        // This test will FAIL with current implementation - demonstrates the issue
        let extractedMerchant = GmailTransactionExtractor.extractMerchant(from: testEmail.subject, sender: testEmail.sender)

        // Current implementation likely returns nil or incorrect merchant name
        // This test documents the expected behavior that should work after fix
        let expectedMerchant = "Uber"
        XCTAssertEqual(
            extractedMerchant?.lowercased(),
            expectedMerchant.lowercased(),
            "Should extract '\(expectedMerchant)' from Uber receipt subject: '\(testEmail.subject)'"
        )
    }

    /// Test that transactions have proper merchant descriptions after extraction
    func testTransactionDescriptionMapping() {
        let testEmail = GmailEmail(
            id: "test_description",
            subject: "Your Woolworths receipt",
            sender: "orders@woolworths.com.au",
            date: Date(),
            snippet: "Total: $125.50 for groceries"
        )

        // Extract transaction from email
        let transactions = GmailTransactionExtractor.extract(from: testEmail)

        // Verify extraction works and merchant is properly identified
        XCTAssertFalse(transactions.isEmpty, "Should extract transaction from valid receipt")

        if let transaction = transactions.first {
            // Verify merchant description is not empty or generic
            XCTAssertFalse(transaction.merchant.isEmpty, "Merchant should not be empty")
            XCTAssertNotEqual(transaction.merchant, "Unknown", "Merchant should not be 'Unknown'")

            // Verify merchant appears in subject or can be derived from sender
            let subjectContainsMerchant = testEmail.subject.localizedCaseInsensitiveContains(transaction.merchant)
            let senderContainsMerchant = testEmail.sender.localizedCaseInsensitiveContains(transaction.merchant)

            XCTAssertTrue(
                subjectContainsMerchant || senderContainsMerchant,
                "Merchant '\(transaction.merchant)' should be related to email subject or sender"
            )
        }
    }

    /// Test edge case: empty subject should extract from sender domain
    func testMerchantExtractionFromSenderDomain() {
        let testEmail = GmailEmail(
            id: "test_empty_subject",
            subject: "",
            sender: "receipts@uber.com",
            date: Date(),
            snippet: "Receipt for your trip"
        )

        let extractedMerchant = GmailTransactionExtractor.extractMerchant(from: testEmail.subject, sender: testEmail.sender)

        XCTAssertNotNil(extractedMerchant, "Should extract merchant from sender domain when subject is empty")
        XCTAssertFalse(extractedMerchant?.isEmpty ?? true, "Extracted merchant should not be empty")
    }
}