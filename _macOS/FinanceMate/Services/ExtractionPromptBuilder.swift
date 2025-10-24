import Foundation

/// Builds extraction prompts for Foundation Models with anti-hallucination rules
/// BLUEPRINT Section 3.1.1.4: Australian context and validated prompt engineering
struct ExtractionPromptBuilder {

    /// Build extraction prompt with Australian financial context
    static func build(for email: GmailEmail) -> String {
        """
        Extract Australian financial transaction data from this email. Return ONLY valid JSON.

        MANDATORY RULES (validated through testing):
        1. Extract FINAL TOTAL amount only (look for "Total:", "Grand Total:", "Amount Due:")
           - NOT line item prices ($129.00 for Power Drill)
           - NOT subtotals ($144.50 before tax)
           - NOT installment amounts ($112.50 for Afterpay)
        2. If field not found, return null - NEVER invent placeholder data:
           -  WRONG: "abn": "XX XXX XXX XXX"
           -  CORRECT: "abn": null
        3. For BNPL emails (Afterpay/Zip/PayPal), extract TRUE merchant:
           - "Afterpay (Bunnings Warehouse)" → merchant: "Bunnings"
           - "via PayPal from Coles" → merchant: "Coles"
        4. Normalize merchant names semantically (BLUEPRINT Line 159):
           - "Officework" → "Officeworks"
           - "Woollies" → "Woolworths"
           - "JB HI-FI" → "JB Hi-Fi"
           - "sharesies.com.au" → "Sharesies"
           - "americanexpress.com.au" → "American Express"
           - "defence.gov.au" → "Department of Defence"
           - Extract canonical brand name from domain, not abbreviations or email prefixes
        5. Set confidence honestly:
           - 0.9-1.0: All fields certain
           - 0.7-0.9: Some fields missing
           - <0.7: Mostly guessing

        Australian Context:
        - GST is always 10% of pre-tax total
        - ABN format: XX XXX XXX XXX (11 digits)
        - Payment methods: Visa, Mastercard, Amex, PayPal, Afterpay, Zip

        Email Subject: \(email.subject)
        Email From: \(email.sender)
        Email Date: \(email.date)

        Email Content:
        \(email.snippet)

        Return JSON:
        {
          "merchant": "Merchant Name",
          "amount": 123.45,
          "category": "Groceries|Retail|Transport|Utilities|Dining|Other",
          "gstAmount": 12.34 or null,
          "abn": "XX XXX XXX XXX" or null,
          "invoiceNumber": "ABC-123" or null,
          "paymentMethod": "Visa|Mastercard|PayPal|etc" or null,
          "confidence": 0.85
        }

        Return ONLY the JSON object above, no markdown formatting or explanations.
        """
    }
}
