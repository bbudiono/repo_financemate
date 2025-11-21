import Foundation

// Mock logging to avoid clutter
public func NSLog(_ format: String, _ args: CVarArg...) {
    // print(String(format: format, arguments: args)) // Uncomment for debug
}

class TestRunner {
    static var passed = 0
    static var failed = 0

    static func assert(_ condition: Bool, _ message: String) {
        if condition {
            passed += 1
            print("✅ PASS: \(message)")
        } else {
            failed += 1
            print("❌ FAIL: \(message)")
        }
    }
    
    static func assertEqual<T: Equatable>(_ actual: T?, _ expected: T, _ message: String) {
        if actual == expected {
            passed += 1
            print("✅ PASS: \(message)")
        } else {
            failed += 1
            print("❌ FAIL: \(message) - Expected \(expected), got \(String(describing: actual))")
        }
    }
}

@main
struct ExtractionTests {
    static func main() {
        print("🚀 Starting Extraction Accuracy Tests...")

        // TEST CASE 1: AUD Prefix
        let email1 = GmailEmail(
            id: "1",
            subject: "Receipt from Bunnings",
            sender: "Bunnings <receipts@bunnings.com.au>",
            date: Date(),
            snippet: "Thank you for shopping. Total: AUD 50.00. GST included.",
            status: .needsReview,
            attachments: []
        )
        let tx1 = GmailStandardTransactionExtractor.extractStandardTransaction(from: email1)
        TestRunner.assert(tx1 != nil, "Test 1: Extraction should succeed")
        TestRunner.assertEqual(tx1?.amount, 50.0, "Test 1: Amount should be 50.0")
        TestRunner.assertEqual(tx1?.merchant, "Bunnings", "Test 1: Merchant should be Bunnings")

        // TEST CASE 2: Suffix Currency
        let email2 = GmailEmail(
            id: "2",
            subject: "Your Invoice",
            sender: "Service Co <billing@service.com>",
            date: Date(),
            snippet: "Invoice #123. Amount Due: $120.50 AUD. Paid via Visa.",
            status: .needsReview,
            attachments: []
        )
        let tx2 = GmailStandardTransactionExtractor.extractStandardTransaction(from: email2)
        TestRunner.assert(tx2 != nil, "Test 2: Extraction should succeed")
        TestRunner.assertEqual(tx2?.amount, 120.50, "Test 2: Amount should be 120.50")

        // TEST CASE 3: "Payment" label instead of Total/Amount
        let email3 = GmailEmail(
            id: "3",
            subject: "Payment Confirmation",
            sender: "Gym <admin@gym.com>",
            date: Date(),
            snippet: "Payment received: $45.00. Reference: GYM-123.",
            status: .needsReview,
            attachments: []
        )
        let tx3 = GmailStandardTransactionExtractor.extractStandardTransaction(from: email3)
        TestRunner.assert(tx3 != nil, "Test 3: Extraction should succeed")
        TestRunner.assertEqual(tx3?.amount, 45.0, "Test 3: Amount should be 45.0")

        // TEST CASE 4: Multi-line Amount
        let email4 = GmailEmail(
            id: "4",
            subject: "Order Update",
            sender: "Amazon <shipment@amazon.com.au>",
            date: Date(),
            snippet: "Grand Total \n $99.99 \n Delivered tomorrow.",
            status: .needsReview,
            attachments: []
        )
        let tx4 = GmailStandardTransactionExtractor.extractStandardTransaction(from: email4)
        TestRunner.assert(tx4 != nil, "Test 4: Extraction should succeed")
        TestRunner.assertEqual(tx4?.amount, 99.99, "Test 4: Amount should be 99.99")

        // TEST CASE 5: Merchant Normalization (Pty Ltd)
        let email5 = GmailEmail(
            id: "5",
            subject: "Invoice",
            sender: "Local Cafe Pty Ltd <info@localcafe.com.au>",
            date: Date(),
            snippet: "Total: $12.50",
            status: .needsReview,
            attachments: []
        )
        let tx5 = GmailStandardTransactionExtractor.extractStandardTransaction(from: email5)
        TestRunner.assertEqual(tx5?.merchant, "Local Cafe", "Test 5: Merchant should be normalized to 'Local Cafe'")

        // TEST CASE 6: No Label (Just amount at end)
        let email6 = GmailEmail(
            id: "6",
            subject: "Uber Trip",
            sender: "Uber Receipts <receipts@uber.com>",
            date: Date(),
            snippet: "Thanks for riding with Uber. Total $24.15",
            status: .needsReview,
            attachments: []
        )
        let tx6 = GmailStandardTransactionExtractor.extractStandardTransaction(from: email6)
        TestRunner.assertEqual(tx6?.amount, 24.15, "Test 6: Amount should be 24.15")

        // TEST CASE 7: Line Items - Standard (Qty x Desc $Price)
        let email7 = GmailEmail(
            id: "7",
            subject: "Officeworks Receipt",
            sender: "Officeworks <receipts@officeworks.com.au>",
            date: Date(),
            snippet: "2x Pens Blue $5.00 \n 1x Notebook A4 $3.50 \n Total: $8.50",
            status: .needsReview,
            attachments: []
        )
        let tx7 = GmailStandardTransactionExtractor.extractStandardTransaction(from: email7)
        TestRunner.assertEqual(tx7?.items.count, 2, "Test 7: Should extract 2 line items")
        TestRunner.assertEqual(tx7?.items.first?.description, "Pens Blue", "Test 7: First item description")
        TestRunner.assertEqual(tx7?.items.first?.price, 5.00, "Test 7: First item price")
        TestRunner.assertEqual(tx7?.items.first?.quantity, 2, "Test 7: First item quantity")

        // TEST CASE 8: Line Items - No Quantity (Desc $Price)
        let email8 = GmailEmail(
            id: "8",
            subject: "Cafe Receipt",
            sender: "Cafe <receipts@cafe.com>",
            date: Date(),
            snippet: "Latte Large $4.50 \n Muffin Blueberry $5.50 \n Total: $10.00",
            status: .needsReview,
            attachments: []
        )
        let tx8 = GmailStandardTransactionExtractor.extractStandardTransaction(from: email8)
        TestRunner.assertEqual(tx8?.items.count, 2, "Test 8: Should extract 2 line items (implicit qty 1)")
        TestRunner.assertEqual(tx8?.items.first?.description, "Latte Large", "Test 8: First item description")
        TestRunner.assertEqual(tx8?.items.first?.quantity, 1, "Test 8: First item implicit quantity")

        // TEST CASE 9: Line Items - Currency Code (Desc AUD Price)
        let email9 = GmailEmail(
            id: "9",
            subject: "Software Subscription",
            sender: "SaaS Co <billing@saas.com>",
            date: Date(),
            snippet: "Pro Plan Monthly AUD 29.99 \n Add-on Feature AUD 5.00 \n Total AUD 34.99",
            status: .needsReview,
            attachments: []
        )
        let tx9 = GmailStandardTransactionExtractor.extractStandardTransaction(from: email9)
        TestRunner.assertEqual(tx9?.items.count, 2, "Test 9: Should extract 2 line items with AUD prefix")
        TestRunner.assertEqual(tx9?.items.first?.price, 29.99, "Test 9: First item price")

        print("\n=== SUMMARY ===")
        print("Passed: \(TestRunner.passed)")
        print("Failed: \(TestRunner.failed)")

        if TestRunner.failed > 0 {
            exit(1)
        }
    }
}
