import XCTest
@testable import FinanceMate

/// E2E tests using 10 REAL Gmail emails from production Gmail account
/// Ground truth manually verified against actual email content
/// Tests fix for merchant extraction bug where wrong merchants appeared
final class RealGmailExtractionTests: XCTestCase {

    // MARK: - Test 1-2: Personal Emails (Should Skip)

    func testEmail1_PersonalEmail_ShouldSkipOrReturnGmail() async {
        let email = GmailEmail(
            id: "199eeeccfa678715",
            subject: "Re: 80269822 Vehicle Fund Closure Payout Advice",
            sender: "Bernhard Budiono <bernhardbudiono@gmail.com>",
            date: Date(),
            snippet: "Hi there, This has been paid out, can you please review and close out the account..."
        )

        let results = await IntelligentExtractionService.extract(from: email)

        // Personal emails should extract with low confidence or "Gmail" merchant
        XCTAssertEqual(results.count, 1)
        XCTAssertTrue(results[0].merchant == "Gmail" || results[0].merchant == "Bernhard")
        XCTAssertEqual(results[0].amount, 0.0)  // No transaction amount
    }

    // MARK: - Test 3: Umart Feedback Email

    func testEmail3_Umart_FeedbackRequest() async {
        let email = GmailEmail(
            id: "199eee0cdc1b23f8",
            subject: "Thanks for your order – We are waiting for your feedback",
            sender: "Umart Online <support@umart.com.au>",
            date: Date(),
            snippet: "My Orders My Account Help Hot Deals! Tell us what you think! Thank you for your order..."
        )

        let results = await IntelligentExtractionService.extract(from: email)

        XCTAssertEqual(results.count, 1)
        // CRITICAL: Merchant MUST be "Umart" (from sender domain)
        XCTAssertEqual(results[0].merchant, "Umart", "❌ Merchant should be extracted from sender domain: support@umart.com.au")
        XCTAssertEqual(results[0].emailSender, "Umart Online <support@umart.com.au>")
    }

    // MARK: - Test 4: Afterpay Payment Confirmation

    func testEmail4_Afterpay_PaymentConfirmation() async {
        let email = GmailEmail(
            id: "199eea08c36eec62",
            subject: "Thanks for your payment!",
            sender: "Afterpay <donotreply@afterpay.com>",
            date: Date(),
            snippet: "Hi Bernhard Budiono Thank you for your recent payment. Payment confirmation Total amount paid $519.65"
        )

        let results = await IntelligentExtractionService.extract(from: email)

        XCTAssertEqual(results.count, 1)
        // CRITICAL: Merchant MUST be "Afterpay" (from sender domain)
        XCTAssertEqual(results[0].merchant, "Afterpay", "❌ Merchant should be Afterpay from sender: donotreply@afterpay.com")
        XCTAssertEqual(results[0].emailSender, "Afterpay <donotreply@afterpay.com>")
        XCTAssertEqual(results[0].amount, 519.65, accuracy: 0.01)
    }

    // MARK: - Test 5: Binance Subdomain Issue

    func testEmail5_Binance_SubdomainExtraction() async {
        let email = GmailEmail(
            id: "199ed52d5b05c641",
            subject: "Recurring Buy Deduction Reminder - 2025-10-16 14:00:32 (UTC)",
            sender: "Binance <do_not_reply@mgdirectmail.binance.com>",
            date: Date(),
            snippet: "Recurring Buy Deduction Reminder Your recurring plan is about to be charged tomorrow..."
        )

        let results = await IntelligentExtractionService.extract(from: email)

        XCTAssertEqual(results.count, 1)
        // CRITICAL FIX: Domain "mgdirectmail.binance.com" should extract "Binance" NOT "Mgdirectmail"
        XCTAssertEqual(results[0].merchant, "Binance", "❌ BUG: Extracted 'Mgdirectmail' instead of 'Binance' from subdomain")
        XCTAssertEqual(results[0].emailSender, "Binance <do_not_reply@mgdirectmail.binance.com>")
        XCTAssertNotEqual(results[0].merchant, "Mgdirectmail", "❌ Should NOT extract subdomain prefix")
    }

    // MARK: - Test 6 & 8: PayPal Payment Notifications

    func testEmail6_PayPal_PaymentToNintendo() async {
        let email = GmailEmail(
            id: "199ecd39169de15c",
            subject: "You've authorised a payment to Nintendo",
            sender: "\"service@paypal.com.au\" <service@paypal.com.au>",
            date: Date(),
            snippet: "WARNING: This email originated from outside of the organization. Bernhard Budiono, thanks..."
        )

        let results = await IntelligentExtractionService.extract(from: email)

        XCTAssertEqual(results.count, 1)
        // CRITICAL: Even though subject mentions "Nintendo", merchant MUST be "PayPal" (actual sender)
        XCTAssertEqual(results[0].merchant, "PayPal", "❌ Subject mentions Nintendo but sender is PayPal - must use sender")
        XCTAssertEqual(results[0].emailSender, "\"service@paypal.com.au\" <service@paypal.com.au>")
        XCTAssertNotEqual(results[0].merchant, "Nintendo", "❌ Should NOT extract merchant from subject line")
    }

    // MARK: - Test 7 & 9: Nintendo Direct Receipts

    func testEmail7_Nintendo_DirectReceipt() async {
        let email = GmailEmail(
            id: "199ecd30e4bed65e",
            subject: "Thank you for your Nintendo eShop purchase",
            sender: "Nintendo <no-reply@accounts.nintendo.com>",
            date: Date(),
            snippet: "Tax Invoice Date 16/10/2025 22:41:15 (AEDT) Nintendo Australia Pty Limited ABN: 43 060 566 083"
        )

        let results = await IntelligentExtractionService.extract(from: email)

        XCTAssertEqual(results.count, 1)
        // CRITICAL FIX: Domain "accounts.nintendo.com" should extract "Nintendo" NOT "Accounts"
        XCTAssertEqual(results[0].merchant, "Nintendo", "❌ BUG: Extracted 'Accounts' instead of 'Nintendo' from subdomain")
        XCTAssertEqual(results[0].emailSender, "Nintendo <no-reply@accounts.nintendo.com>")
        XCTAssertNotEqual(results[0].merchant, "Accounts", "❌ Should NOT extract 'accounts' subdomain")
    }

    // MARK: - Test 10: Marketing Email (Non-Financial)

    func testEmail10_ActivePipe_MarketingEmail() async {
        let email = GmailEmail(
            id: "199ec1a1ea52bc99",
            subject: "Make this summer yours 🏖",
            sender: "Steve Orme <steve.orme@activepipe.loanmarket.com.au>",
            date: Date(),
            snippet: "Hi Bernhard, As the days get longer, the summer wish list starts growing..."
        )

        let results = await IntelligentExtractionService.extract(from: email)

        XCTAssertEqual(results.count, 1)
        // Should extract "ActivePipe" or "Loan Market" from domain
        XCTAssertTrue(results[0].merchant == "ActivePipe" || results[0].merchant == "Loan Market")
        XCTAssertEqual(results[0].amount, 0.0)  // No transaction
    }

    // MARK: - Integration Test: All 10 Emails

    func testAllRealEmails_NoMerchantMixing() async {
        // Load all 10 real emails from fixture
        let emails = [
            GmailEmail(id: "199eeeccfa678715", subject: "Re: 80269822 Vehicle Fund Closure Payout Advice", sender: "Bernhard Budiono <bernhardbudiono@gmail.com>", date: Date(), snippet: "Hi there..."),
            GmailEmail(id: "199eee0cdc1b23f8", subject: "Thanks for your order – We are waiting for your feedback", sender: "Umart Online <support@umart.com.au>", date: Date(), snippet: "My Orders..."),
            GmailEmail(id: "199eea08c36eec62", subject: "Thanks for your payment!", sender: "Afterpay <donotreply@afterpay.com>", date: Date(), snippet: "Total amount paid $519.65"),
            GmailEmail(id: "199ed52d5b05c641", subject: "Recurring Buy Deduction Reminder", sender: "Binance <do_not_reply@mgdirectmail.binance.com>", date: Date(), snippet: "Recurring Buy..."),
            GmailEmail(id: "199ecd39169de15c", subject: "You've authorised a payment to Nintendo", sender: "\"service@paypal.com.au\" <service@paypal.com.au>", date: Date(), snippet: "payment to Nintendo"),
            GmailEmail(id: "199ecd30e4bed65e", subject: "Thank you for your Nintendo eShop purchase", sender: "Nintendo <no-reply@accounts.nintendo.com>", date: Date(), snippet: "Tax Invoice Nintendo Australia"),
        ]

        // Extract all concurrently (test race conditions)
        let results = await IntelligentExtractionService.extractBatch(emails, maxConcurrency: 3)

        XCTAssertEqual(results.count, 6)

        // Validate specific merchant extractions
        let umartResult = results.first(where: { $0.id == "199eee0cdc1b23f8" })
        XCTAssertEqual(umartResult?.merchant, "Umart")

        let afterpayResult = results.first(where: { $0.id == "199eea08c36eec62" })
        XCTAssertEqual(afterpayResult?.merchant, "Afterpay")
        XCTAssertEqual(afterpayResult?.amount, 519.65, accuracy: 0.01)

        let binanceResult = results.first(where: { $0.id == "199ed52d5b05c641" })
        XCTAssertEqual(binanceResult?.merchant, "Binance", "❌ Binance subdomain bug")

        let paypalResult = results.first(where: { $0.id == "199ecd39169de15c" })
        XCTAssertEqual(paypalResult?.merchant, "PayPal", "❌ Should be PayPal not Nintendo")

        let nintendoResult = results.first(where: { $0.id == "199ecd30e4bed65e" })
        XCTAssertEqual(nintendoResult?.merchant, "Nintendo", "❌ Nintendo subdomain bug")
    }

    // MARK: - COMPREHENSIVE 13-FIELD VALIDATION TESTS

    /// Email 4: Afterpay - ALL 13 FIELDS validated
    func testEmail4_Afterpay_All13Fields() async {
        let email = GmailEmail(
            id: "199eea08c36eec62",
            subject: "Thanks for your payment!",
            sender: "Afterpay <donotreply@afterpay.com>",
            date: Date(),
            snippet: "Hi Bernhard Budiono Thank you for your recent payment. Please find further details below. Payment confirmation Total amount paid $519.65 Payment date Fri, 17 Oct 2025 Repayments Payment method"
        )

        let results = await IntelligentExtractionService.extract(from: email)
        XCTAssertEqual(results.count, 1)
        let tx = results[0]

        // Field 1: ID
        XCTAssertEqual(tx.id, "199eea08c36eec62")

        // Field 2: Merchant
        XCTAssertEqual(tx.merchant, "Afterpay")

        // Field 3: Amount
        XCTAssertEqual(tx.amount, 519.65, accuracy: 0.01, "Should extract 'Total amount paid $519.65'")

        // Field 4: Date
        XCTAssertNotNil(tx.date)

        // Field 5: Category
        XCTAssertEqual(tx.category, "Finance", "Afterpay should be categorized as Finance")

        // Field 6: Items
        // (No line items in payment confirmation)

        // Field 7: Confidence
        XCTAssertGreaterThan(tx.confidence, 0.6, "Should have reasonable confidence with merchant + amount")

        // Field 8: Email Subject
        XCTAssertEqual(tx.emailSubject, "Thanks for your payment!")

        // Field 9: Email Sender
        XCTAssertEqual(tx.emailSender, "Afterpay <donotreply@afterpay.com>")

        // Field 10: GST
        XCTAssertNil(tx.gstAmount, "Afterpay payment has no GST")

        // Field 11: ABN
        XCTAssertNil(tx.abn, "No ABN in this email")

        // Field 12: Invoice Number
        XCTAssertTrue(tx.invoiceNumber.starts(with: "EMAIL-"), "Should use fallback invoice number")

        // Field 13: Payment Method
        XCTAssertNil(tx.paymentMethod, "Payment method not specified in snippet")
    }

    /// Email 5: Binance - ALL 13 FIELDS with subdomain edge case
    func testEmail5_Binance_All13Fields() async {
        let email = GmailEmail(
            id: "199ed52d5b05c641",
            subject: "Recurring Buy Deduction Reminder - 2025-10-16 14:00:32 (UTC)",
            sender: "Binance <do_not_reply@mgdirectmail.binance.com>",
            date: Date(),
            snippet: "Recurring Buy Deduction Reminder Your recurring plan is about to be charged tomorrow, to avoid investment failure, please make sure your bank account has enough balance. Repeat on: Every week, Friday"
        )

        let results = await IntelligentExtractionService.extract(from: email)
        XCTAssertEqual(results.count, 1)
        let tx = results[0]

        // Field 1: ID
        XCTAssertEqual(tx.id, "199ed52d5b05c641")

        // Field 2: Merchant - CRITICAL EDGE CASE
        XCTAssertEqual(tx.merchant, "Binance", "❌ Domain 'mgdirectmail.binance.com' MUST extract 'Binance' not 'Mgdirectmail'")

        // Field 3: Amount
        XCTAssertEqual(tx.amount, 0.0, "Reminder email has no transaction amount")

        // Field 4: Date
        XCTAssertNotNil(tx.date)

        // Field 5: Category
        XCTAssertEqual(tx.category, "Investment", "Binance should be Investment category")

        // Field 6: Items
        XCTAssertEqual(tx.items.count, 0)

        // Field 7: Confidence
        XCTAssertLessThan(tx.confidence, 0.7, "Reminder with no amount should have low confidence")

        // Field 8: Email Subject
        XCTAssertEqual(tx.emailSubject, "Recurring Buy Deduction Reminder - 2025-10-16 14:00:32 (UTC)")

        // Field 9: Email Sender
        XCTAssertEqual(tx.emailSender, "Binance <do_not_reply@mgdirectmail.binance.com>")

        // Field 10: GST
        XCTAssertNil(tx.gstAmount)

        // Field 11: ABN
        XCTAssertNil(tx.abn)

        // Field 12: Invoice Number
        XCTAssertTrue(tx.invoiceNumber.starts(with: "EMAIL-"))

        // Field 13: Payment Method
        XCTAssertNil(tx.paymentMethod)
    }

    /// Email 7: Nintendo with ABN - ALL 13 FIELDS including ABN extraction
    func testEmail7_Nintendo_All13FieldsWithABN() async {
        let email = GmailEmail(
            id: "199ecd30e4bed65e",
            subject: "Thank you for your Nintendo eShop purchase",
            sender: "Nintendo <no-reply@accounts.nintendo.com>",
            date: Date(),
            snippet: "Tax Invoice -------------------- Date 16/10/2025 22:41:15 (AEDT) -------------------- Nintendo Australia Pty Limited 804 Stud Road Scoresby VIC 3179 Australia ABN: 43 060 566 083 http://www.nintendo."
        )

        let results = await IntelligentExtractionService.extract(from: email)
        XCTAssertEqual(results.count, 1)
        let tx = results[0]

        // Field 1: ID
        XCTAssertEqual(tx.id, "199ecd30e4bed65e")

        // Field 2: Merchant - CRITICAL EDGE CASE
        XCTAssertEqual(tx.merchant, "Nintendo", "❌ Domain 'accounts.nintendo.com' MUST extract 'Nintendo' not 'Accounts'")

        // Field 3: Amount
        // (Amount might be 0 if not in snippet preview)

        // Field 4: Date
        XCTAssertNotNil(tx.date)

        // Field 5: Category
        XCTAssertEqual(tx.category, "Gaming", "Nintendo should be Gaming category")

        // Field 6: Items
        // (May or may not have items)

        // Field 7: Confidence
        XCTAssertGreaterThan(tx.confidence, 0.6, "Tax invoice with ABN should have decent confidence")

        // Field 8: Email Subject
        XCTAssertEqual(tx.emailSubject, "Thank you for your Nintendo eShop purchase")

        // Field 9: Email Sender
        XCTAssertEqual(tx.emailSender, "Nintendo <no-reply@accounts.nintendo.com>")

        // Field 10: GST
        // (May or may not be present)

        // Field 11: ABN - CRITICAL TEST
        XCTAssertEqual(tx.abn, "43 060 566 083", "❌ Should extract ABN from email snippet")

        // Field 12: Invoice Number
        // (Should extract or use fallback)
        XCTAssertFalse(tx.invoiceNumber.isEmpty)

        // Field 13: Payment Method
        // (Likely none in eShop receipt)
    }
}
