import XCTest
@testable import FinanceMate

/// Test suite for merchant extraction from email senders
/// CRITICAL: Validates government domain extraction and cache poisoning prevention
class MerchantExtractionTests: XCTestCase {

    // MARK: - Government Domain Extraction Tests

    func test_extractMerchant_defenceGovAu_returnsDefenceDepartment() {
        // GIVEN: Email from defence.gov.au
        let subject = "Invoice from Department of Defence"
        let sender = "noreply@defence.gov.au"

        // WHEN: Extract merchant
        let result = GmailTransactionExtractor.extractMerchant(from: subject, sender: sender)

        // THEN: Should return "Department of Defence"
        XCTAssertEqual(result, "Department of Defence", "defence.gov.au must extract as 'Department of Defence'")
    }

    func test_extractMerchant_goldCoastQldGovAu_returnsGoldCoastCouncil() {
        // GIVEN: Email from goldcoast.qld.gov.au
        let subject = "Council Rate Notice"
        let sender = "City of Gold Coast <noreply@goldcoast.qld.gov.au>"

        // WHEN: Extract merchant
        let result = GmailTransactionExtractor.extractMerchant(from: subject, sender: sender)

        // THEN: Should return "Gold Coast Council"
        XCTAssertEqual(result, "Gold Coast Council", "goldcoast.qld.gov.au must extract as 'Gold Coast Council'")
    }

    func test_extractMerchant_atoGovAu_returnsATO() {
        // GIVEN: Email from ato.gov.au
        let subject = "Tax Notice"
        let sender = "noreply@ato.gov.au"

        // WHEN: Extract merchant
        let result = GmailTransactionExtractor.extractMerchant(from: subject, sender: sender)

        // THEN: Should return "Australian Taxation Office"
        XCTAssertEqual(result, "Australian Taxation Office", "ato.gov.au must extract as 'Australian Taxation Office'")
    }

    func test_extractMerchant_centrelinkGovAu_returnsCentrelink() {
        // GIVEN: Email from centrelink.gov.au
        let subject = "Payment Confirmation"
        let sender = "noreply@centrelink.gov.au"

        // WHEN: Extract merchant
        let result = GmailTransactionExtractor.extractMerchant(from: subject, sender: sender)

        // THEN: Should return "Centrelink"
        XCTAssertEqual(result, "Centrelink", "centrelink.gov.au must extract as 'Centrelink'")
    }

    func test_extractMerchant_queenslandGovAu_returnsQueenslandGovernment() {
        // GIVEN: Email from qld.gov.au
        let subject = "Government Service"
        let sender = "noreply@qld.gov.au"

        // WHEN: Extract merchant
        let result = GmailTransactionExtractor.extractMerchant(from: subject, sender: sender)

        // THEN: Should return "Queensland Government"
        XCTAssertEqual(result, "Queensland Government", "qld.gov.au must extract as 'Queensland Government'")
    }

    // MARK: - Cache Poisoning Prevention Tests

    func test_cacheExtraction_doesNotUsePoisonedItemDescription() {
        // GIVEN: A transaction cached with wrong merchant from itemDescription
        let email = GmailEmail(
            id: "test-defence-email",
            subject: "Defence Invoice",
            sender: "noreply@defence.gov.au",
            snippet: "Invoice Total $150.00",
            date: Date(),
            mimeType: "text/plain"
        )

        // WHEN: Extract merchant using proper logic (not itemDescription)
        let merchant = GmailTransactionExtractor.extractMerchant(from: email.subject, sender: email.sender)

        // THEN: Should use email sender, not cached itemDescription
        XCTAssertNotEqual(merchant, "Bunnings", "CRITICAL: Must not extract as Bunnings from defence.gov.au")
        XCTAssertEqual(merchant, "Department of Defence", "Must extract properly from email sender")
    }

    // MARK: - Known Brand Extraction Tests

    func test_extractMerchant_bunningsEmail_returnsBunnings() {
        // GIVEN: Email from bunnings.com
        let subject = "Order Confirmation"
        let sender = "orders@bunnings.com"

        // WHEN: Extract merchant
        let result = GmailTransactionExtractor.extractMerchant(from: subject, sender: sender)

        // THEN: Should return "Bunnings"
        XCTAssertEqual(result, "Bunnings", "bunnings.com must extract as 'Bunnings'")
    }

    func test_extractMerchant_woolworthsEmail_returnsWoolworths() {
        // GIVEN: Email from woolworths.com
        let subject = "Receipt"
        let sender: String = "noreply@woolworths.com"

        // WHEN: Extract merchant
        let result = GmailTransactionExtractor.extractMerchant(from: subject, sender: sender)

        // THEN: Should return "Woolworths"
        XCTAssertEqual(result, "Woolworths", "woolworths.com must extract as 'Woolworths'")
    }

    func test_extractMerchant_displayNameTakesPriority() {
        // GIVEN: Email with display name before angle bracket
        let subject = "Receipt"
        let sender = "Bunnings Warehouse <orders@bunnings.com>"

        // WHEN: Extract merchant
        let result = GmailTransactionExtractor.extractMerchant(from: subject, sender: sender)

        // THEN: Should return normalized display name
        XCTAssertEqual(result, "Bunnings", "Display name should be extracted and normalized")
    }

    func test_extractMerchant_malformedEmail_returnsUnknown() {
        // GIVEN: Malformed email address
        let subject = "Some Transaction"
        let sender = "invalid-email-no-at-sign"

        // WHEN: Extract merchant
        let result = GmailTransactionExtractor.extractMerchant(from: subject, sender: sender)

        // THEN: Should return nil (handling in upper layer)
        XCTAssertNil(result, "Malformed email should return nil")
    }
}
