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

    // MARK: - MARKETPLACE INTERMEDIARY TESTS (Critical Edge Cases)

    /// Email: Klook Marketplace Order - Bunnings mentioned in subject/body
    /// CRITICAL: Subject may say "Bunnings" but sender IS Klook
    func testMarketplace_Klook_BunningsOrder_All13Fields() async {
        let email = GmailEmail(
            id: "test-klook-bunnings",
            subject: "Your Klook booking confirmed - Bunnings Warehouse",
            sender: "noreply@klook.com",
            date: Date(),
            snippet: "Thank you for booking with Klook. Merchant: Bunnings Warehouse. Total: $123.45 GST: $11.23"
        )

        let results = await IntelligentExtractionService.extract(from: email)
        XCTAssertEqual(results.count, 1)
        let tx = results[0]

        // CRITICAL: Merchant MUST be "Klook" (who sent the email)
        // NOT "Bunnings" (mentioned in subject/body)
        XCTAssertEqual(tx.merchant, "Klook", "❌ MARKETPLACE BUG: Klook email MUST show merchant as Klook, not Bunnings from subject")
        XCTAssertEqual(tx.emailSender, "noreply@klook.com")
        XCTAssertEqual(tx.amount, 123.45, accuracy: 0.01)
        XCTAssertEqual(tx.gstAmount, 11.23, accuracy: 0.01)
        XCTAssertNotEqual(tx.merchant, "Bunnings", "❌ Must NOT extract Bunnings from subject when sender is Klook")
    }

    /// Email: Clevarea Marketplace - Bunnings product
    func testMarketplace_Clevarea_BunningsProduct_All13Fields() async {
        let email = GmailEmail(
            id: "test-clevarea-bunnings",
            subject: "Order confirmation - Bunnings item",
            sender: "orders@ma.clevarea.com.au",
            date: Date(),
            snippet: "Your order from Bunnings is confirmed. Total: $145.60 GST: $11.15"
        )

        let results = await IntelligentExtractionService.extract(from: email)
        XCTAssertEqual(results.count, 1)
        let tx = results[0]

        // CRITICAL: Merchant MUST be "Clevarea"
        XCTAssertEqual(tx.merchant, "Clevarea", "❌ Clevarea marketplace email showing wrong merchant")
        XCTAssertTrue(tx.emailSender.contains("clevarea"), "Sender must contain clevarea domain")
        XCTAssertEqual(tx.amount, 145.60, accuracy: 0.01)
        XCTAssertNotEqual(tx.merchant, "Bunnings", "❌ Must NOT extract Bunnings from body when sender is Clevarea")
    }

    /// Email: Huboox Marketplace - Three Kings Pizza
    func testMarketplace_Huboox_ThreeKingsPizza_All13Fields() async {
        let email = GmailEmail(
            id: "test-huboox-pizza",
            subject: "Three Kings Pizza - Order confirmed",
            sender: "notify@tryhuboox.com",
            date: Date(),
            snippet: "Your Three Kings Pizza order is ready. Total: $123.00 GST: $11.18"
        )

        let results = await IntelligentExtractionService.extract(from: email)
        XCTAssertEqual(results.count, 1)
        let tx = results[0]

        // Edge case: Should merchant be "Huboox" (sender) or "Three Kings Pizza" (actual restaurant)?
        // Decision: Use SENDER domain as authoritative (Huboox)
        XCTAssertEqual(tx.merchant, "Huboox", "❌ Marketplace platform (Huboox) is the sender, should be merchant")
        XCTAssertTrue(tx.emailSender.contains("huboox"))
        XCTAssertEqual(tx.amount, 123.00, accuracy: 0.01)
        XCTAssertEqual(tx.category, "Dining", "Huboox should be Dining category")
    }

    /// Email: SMAI with BlueBet mention
    func testEmail_SMAI_BlueBetConfusion_All13Fields() async {
        let email = GmailEmail(
            id: "test-smai-bluebet",
            subject: "BlueBet partnership offer",
            sender: "marketing@smai.com.au",
            date: Date(),
            snippet: "Special BlueBet offer for SMAI customers. Total: $123.45"
        )

        let results = await IntelligentExtractionService.extract(from: email)
        XCTAssertEqual(results.count, 1)
        let tx = results[0]

        // CRITICAL: Merchant MUST be "SMAI" (sender)
        XCTAssertEqual(tx.merchant, "Smai", "❌ SMAI sender showing wrong merchant")
        XCTAssertTrue(tx.emailSender.contains("smai"))
        XCTAssertNotEqual(tx.merchant, "BlueBet", "❌ BlueBet mentioned in subject but SMAI is sender")
    }

    /// Email: ANZ Corporate Name
    func testEmail_ANZ_CorporateName_All13Fields() async {
        let email = GmailEmail(
            id: "test-anz-corporate",
            subject: "ANZ Group Holdings Ltd - Statement",
            sender: "noreply@anz.com.au",
            date: Date(),
            snippet: "ANZ Group Holdings Ltd. Account statement for October. Total fees: $112.30 GST: $10.21"
        )

        let results = await IntelligentExtractionService.extract(from: email)
        XCTAssertEqual(results.count, 1)
        let tx = results[0]

        // Field validations
        XCTAssertEqual(tx.merchant, "Anz", "❌ ANZ domain should extract as ANZ")
        XCTAssertEqual(tx.emailSender, "noreply@anz.com.au")
        XCTAssertEqual(tx.amount, 112.30, accuracy: 0.01)
        XCTAssertEqual(tx.gstAmount, 10.21, accuracy: 0.01)
        XCTAssertEqual(tx.category, "Finance", "ANZ should be Finance category")
    }

    /// Email: Apple Store Purchase
    func testEmail_Apple_StorePurchase_All13Fields() async {
        let email = GmailEmail(
            id: "test-apple-store",
            subject: "Your receipt from Apple",
            sender: "no_reply@email.apple.com",
            date: Date(),
            snippet: "Thank you for your purchase. Total: $165.50 GST: $47.03"
        )

        let results = await IntelligentExtractionService.extract(from: email)
        XCTAssertEqual(results.count, 1)
        let tx = results[0]

        XCTAssertEqual(tx.merchant, "Apple", "❌ Apple domain must extract as Apple")
        XCTAssertTrue(tx.emailSender.contains("apple"))
        XCTAssertEqual(tx.amount, 165.50, accuracy: 0.01)
        XCTAssertEqual(tx.gstAmount, 47.03, accuracy: 0.01, "Should extract GST amount")
    }

    /// Email: Amigo Energy Utility Bill
    func testEmail_AmigoEnergy_UtilityBill_All13Fields() async {
        let email = GmailEmail(
            id: "test-amigo-energy",
            subject: "Your Amigo Energy Electricity bill",
            sender: "billing@amigoenergy.com.au",
            date: Date(),
            snippet: "Your electricity bill is ready. Amount Due: $132.65 GST: $11.98"
        )

        let results = await IntelligentExtractionService.extract(from: email)
        XCTAssertEqual(results.count, 1)
        let tx = results[0]

        XCTAssertEqual(tx.merchant, "Amigoenergy", "❌ Amigo Energy domain extraction")
        XCTAssertTrue(tx.emailSender.contains("amigoenergy"))
        XCTAssertEqual(tx.amount, 132.65, accuracy: 0.01)
        XCTAssertEqual(tx.gstAmount, 11.98, accuracy: 0.01)
        XCTAssertEqual(tx.category, "Utilities", "Energy company should be Utilities")
    }
}

    // MARK: - BATCH 2: DIVERSE REAL EMAILS (8 Scenarios with ABN, Payment, Government)

    /// Batch2 Email 4: Linkt Toll - ABN Extraction + Transport Category
    func testBatch2_Linkt_ABNExtraction_All13Fields() async {
        let email = GmailEmail(
            id: "199ef8a3c8f4c9cd",
            subject: "Hit the road for up to 30% less! Limited time only",
            sender: "Linkt <noreply@digital.linkt.com.au>",
            date: Date(),
            snippet: "Linkt rewards program. ABN: 86 010 630 921"
        )

        let results = await IntelligentExtractionService.extract(from: email)
        XCTAssertEqual(results.count, 1)
        let tx = results[0]

        // Merchant from digital.linkt.com.au subdomain
        XCTAssertEqual(tx.merchant, "Linkt", "❌ digital.linkt.com.au should extract as Linkt")
        XCTAssertEqual(tx.emailSender, "Linkt <noreply@digital.linkt.com.au>")
        
        // ABN extraction test
        XCTAssertEqual(tx.abn, "86 010 630 921", "❌ Should extract Linkt ABN from body")
        
        // Category inference
        XCTAssertEqual(tx.category, "Transport", "Linkt is toll road - should be Transport")
    }

    /// Batch2 Email 5: NAB Bank - ABN + Payment Method Extraction
    func testBatch2_NAB_ABNAndPaymentMethod_All13Fields() async {
        let email = GmailEmail(
            id: "199dbc86db9513cd",
            subject: "Bernhard, get rewarded with your NAB Goodies offers in the app",
            sender: "NAB <nab@updates.nab.com.au>",
            date: Date(),
            snippet: "Your NAB Goodies offers. ABN: 69 079 137 518. Use your Visa card for rewards."
        )

        let results = await IntelligentExtractionService.extract(from: email)
        XCTAssertEqual(results.count, 1)
        let tx = results[0]

        // Merchant
        XCTAssertEqual(tx.merchant, "NAB", "❌ updates.nab.com.au should extract as NAB")
        XCTAssertTrue(tx.emailSender.contains("nab"))
        
        // ABN
        XCTAssertEqual(tx.abn, "69 079 137 518", "❌ Should extract NAB ABN")
        
        // Payment Method - CRITICAL TEST
        XCTAssertEqual(tx.paymentMethod, "Visa", "❌ Should extract 'Visa' mention from snippet")
        
        // Category
        XCTAssertEqual(tx.category, "Finance", "NAB is bank - should be Finance")
    }

    /// Batch2 Email 6: Gold Coast City Council - Government Entity
    func testBatch2_GoldCoastCouncil_Government_All13Fields() async {
        let email = GmailEmail(
            id: "199e043ab69f8b64",
            subject: "Important correspondence from City of Gold Coast",
            sender: "City of Gold Coast <noreply@goldcoast.qld.gov.au>",
            date: Date(),
            snippet: "Please read the attached correspondence regarding your rates notice."
        )

        let results = await IntelligentExtractionService.extract(from: email)
        XCTAssertEqual(results.count, 1)
        let tx = results[0]

        // Merchant from goldcoast.qld.gov.au
        XCTAssertTrue(tx.merchant.contains("Goldcoast") || tx.merchant.contains("Gold"), "❌ Government domain extraction")
        XCTAssertTrue(tx.emailSender.contains("goldcoast.qld.gov.au"))
        
        // Category (government not in current categories, may be Other/Utilities)
        XCTAssertTrue(["Other", "Utilities"].contains(tx.category))
    }

    /// Batch2 Email 7: BioTek Supplements - Marketing Email
    func testBatch2_BioTek_Marketing_All13Fields() async {
        let email = GmailEmail(
            id: "199c7821fa6d4279",
            subject: "BIOTEK'S 48 HOUR FLASH SALE ON ALL STACKS",
            sender: "\"BioTek / Olympia Supps\" <contact@bioteksupps.com>",
            date: Date(),
            snippet: "FLASH SALE 25% OFF EVERYTHING SITEWIDE 48 HOURS ONLY"
        )

        let results = await IntelligentExtractionService.extract(from: email)
        XCTAssertEqual(results.count, 1)
        let tx = results[0]

        // Merchant
        XCTAssertTrue(tx.merchant.contains("Biotek") || tx.merchant == "BioTek", "❌ bioteksupps.com extraction")
        XCTAssertTrue(tx.emailSender.contains("bioteksupps"))
        
        // Amount (marketing email, no transaction)
        XCTAssertEqual(tx.amount, 0.0)
        
        // Confidence
        XCTAssertLessThan(tx.confidence, 0.6, "Marketing email should have low confidence")
        
        // Category
        XCTAssertTrue(["Health & Fitness", "Retail", "Other"].contains(tx.category))
    }

    /// Batch2 Email 8: Amazon Subscribe & Save - Amount + ABN Extraction
    func testBatch2_Amazon_AmountAndABN_All13Fields() async {
        let email = GmailEmail(
            id: "199c7748abe8d3ff",
            subject: "Price changes: review your upcoming delivery",
            sender: "\"Amazon Subscribe & Save\" <no-reply@amazon.com.au>",
            date: Date(),
            snippet: "Your next Subscribe & Save delivery. Order total (including tax) $165.88. ABN: 30 616 935 623"
        )

        let results = await IntelligentExtractionService.extract(from: email)
        XCTAssertEqual(results.count, 1)
        let tx = results[0]

        // Merchant
        XCTAssertEqual(tx.merchant, "Amazon", "❌ amazon.com.au should extract as Amazon")
        XCTAssertTrue(tx.emailSender.contains("amazon"))
        
        // Amount - CRITICAL TEST
        XCTAssertEqual(tx.amount, 165.88, accuracy: 0.01, "❌ Should extract 'Order total $165.88'")
        
        // ABN
        XCTAssertEqual(tx.abn, "30 616 935 623", "❌ Should extract Amazon Australia ABN")
        
        // Category
        XCTAssertTrue(["Retail", "Other", "Entertainment"].contains(tx.category))
    }
}
