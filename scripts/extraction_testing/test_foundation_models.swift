#!/usr/bin/env swift

import Foundation
import FoundationModels

// FOUNDATION MODELS EXTRACTION TEST HARNESS
// Tests Apple's SystemLanguageModel for receipt extraction on M4 Max
// Compares performance against current regex system

class FoundationModelsTest {

    func checkAvailability() -> Bool {
        switch SystemLanguageModel.default.availability {
        case .available:
            print("[OK] Foundation Models available and ready")
            return true
        case .unavailable(let reason):
            switch reason {
            case .appleIntelligenceNotEnabled:
                print("[ERROR] Apple Intelligence not enabled in System Settings")
            case .deviceNotEligible:
                print("[ERROR] Device not eligible for Apple Intelligence")
            case .modelNotReady:
                print("[WARN] Model not ready - try restarting device")
            @unknown default:
                print("[ERROR] Model unavailable - unknown reason")
            }
            return false
        }
    }

    func testExtraction(emailText: String, subject: String, sender: String) async {
        print("\n=== FOUNDATION MODELS EXTRACTION TEST ===")
        print("Email: \(subject)")
        print("From: \(sender)")

        guard checkAvailability() else {
            print("[SKIP] Model unavailable")
            return
        }

        let prompt = """
        Extract financial transaction data from this Australian email receipt.

        Australian Context:
        - GST is always 10% of total
        - ABN format: XX XXX XXX XXX (11 digits)
        - Common BNPL providers: Afterpay, Zip, PayPal (extract TRUE merchant, not payment provider)
        - Major merchants: Bunnings, Woolworths, Coles, Officeworks, JB Hi-Fi

        Email Subject: \(subject)
        Email From: \(sender)

        Email Content:
        \(emailText)

        Extract and return ONLY a JSON object with this exact structure:
        {
          "merchant": "merchant name (normalize spelling: Officework->Officeworks)",
          "amount": 123.45,
          "category": "category name (Groceries/Retail/Utilities/Transport/Dining)",
          "gstAmount": 12.34,
          "abn": "XX XXX XXX XXX" or null,
          "invoiceNumber": "INV-123" or null,
          "paymentMethod": "Visa/Mastercard/Amex/PayPal" or null,
          "confidence": 0.85
        }

        Rules:
        - If merchant name appears via BNPL (e.g., "paid via Afterpay at Bunnings"), extract "Bunnings" as merchant
        - Confidence 0.9+ if all fields found, 0.7-0.9 if some fields missing, <0.7 if uncertain
        - Return ONLY valid JSON, no markdown formatting or explanations
        """

        do {
            let startTime = Date()

            // Use SystemLanguageModel API
            let session = LanguageModelSession()
            let response = try await session.respond(to: prompt)

            let duration = Date().timeIntervalSince(startTime)

            print("[SUCCESS] Extraction complete in \(String(format: "%.2f", duration))s")
            print("\n--- Raw Response ---")
            print(response.content)
            print("--- End Response ---\n")

            // Strip markdown code blocks if present
            var jsonString = response.content
            if jsonString.contains("```json") {
                jsonString = jsonString
                    .replacingOccurrences(of: "```json", with: "")
                    .replacingOccurrences(of: "```", with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                print("[INFO] Stripped markdown formatting")
            }

            // Parse JSON for validation
            if let jsonData = jsonString.data(using: .utf8),
               let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                print("[VALIDATE] JSON parsing: SUCCESS")
                print("\nExtracted Fields:")
                print("  Merchant: \(json["merchant"] as? String ?? "MISSING")")
                print("  Amount: $\(json["amount"] as? Double ?? 0.0)")
                print("  Category: \(json["category"] as? String ?? "MISSING")")
                print("  GST: $\(json["gstAmount"] as? Double ?? 0.0)")
                print("  ABN: \(json["abn"] as? String ?? "MISSING")")
                print("  Invoice: \(json["invoiceNumber"] as? String ?? "MISSING")")
                print("  Payment: \(json["paymentMethod"] as? String ?? "MISSING")")
                print("  Confidence: \(String(format: "%.1f%%", (json["confidence"] as? Double ?? 0.0) * 100))")
            } else {
                print("[ERROR] JSON parsing failed after markdown stripping")
                print("Cleaned string: \(jsonString)")
            }

        } catch {
            print("[ERROR] Foundation Models extraction failed: \(error.localizedDescription)")
        }
    }
}

// Test sample - Bunnings receipt
let bunningsTest = (
    subject: "Your Bunnings Receipt",
    sender: "noreply@bunnings.com.au",
    text: """
    TAX INVOICE 123456
    Bunnings Warehouse
    ABN 52 093 533 107

    Date: 09/10/2025

    Item: Power Drill      $129.00
    Item: Screws (100pk)   $15.50

    Subtotal: $144.50
    GST (10%): $14.45
    Total: $158.95

    Paid via Visa ending 4242
    """
)

print("=== FOUNDATION MODELS VALIDATION TEST ===")
print("Hardware: M4 Max with 128GB RAM")
print("macOS: 26.0.1")
print("Framework: /System/Library/Frameworks/FoundationModels.framework")
print("---")

let tester = FoundationModelsTest()

// Run async test
Task {
    await tester.testExtraction(
        emailText: bunningsTest.text,
        subject: bunningsTest.subject,
        sender: bunningsTest.sender
    )

    print("\n[COMPLETE] Test finished - check results above")
    exit(0)
}

// Keep script running for async tasks
RunLoop.main.run()
