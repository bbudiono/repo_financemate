import Foundation

/// Validates if email is likely a receipt using multiple checks
/// Part of EmailIntentAnalyzer - separated for complexity management
struct ReceiptValidator {

    /// Validate if email is likely a receipt (must pass multiple checks)
    /// - Parameters:
    ///   - subject: Email subject line
    ///   - sender: Sender email address
    ///   - content: Email body content
    /// - Returns: True if appears to be a legitimate receipt
    static func isLikelyReceipt(subject: String, sender: String, content: String) -> Bool {
        NSLog("[INTENT-RECEIPT] Entry: Validating receipt indicators")

        var score = 0
        let maxScore = 6
        var checkResults: [String] = []

        // Check 1: Subject line contains receipt indicators (enhanced patterns)
        if subject.range(of: "receipt|invoice|order|purchase|payment|confirmation|transaction|tax invoice|your order|payment received|order confirmation", options: .caseInsensitive) != nil {
            score += 1
            checkResults.append("Subject:")
            NSLog("[INTENT-RECEIPT] Check 1: Subject contains receipt indicator")
        } else {
            checkResults.append("Subject:")
        }

        // Check 2: Sender is known merchant domain
        if isKnownMerchant(sender: sender) {
            score += 1
            checkResults.append("Merchant:")
            NSLog("[INTENT-RECEIPT] Check 2: Known merchant detected")
        } else {
            checkResults.append("Merchant:")
        }

        // Check 3: Contains monetary amounts
        if content.range(of: "\\$\\s?\\d+\\.\\d{2}", options: .regularExpression) != nil {
            score += 1
            checkResults.append("Amount:")
            NSLog("[INTENT-RECEIPT] Check 3: Monetary amount found")
        } else {
            checkResults.append("Amount:")
        }

        // Check 4: Contains transaction-specific indicators
        if containsTransactionalIndicators(subject: subject, content: content) {
            score += 1
            checkResults.append("Transaction:")
            NSLog("[INTENT-RECEIPT] Check 4: Transaction indicators found")
        } else {
            checkResults.append("Transaction:")
        }

        // Check 5: Has order/transaction ID
        if content.range(of: "order|transaction id|receipt|invoice", options: .caseInsensitive) != nil {
            score += 1
            checkResults.append("ID:")
            NSLog("[INTENT-RECEIPT] Check 5: Transaction ID found")
        } else {
            checkResults.append("ID:")
        }

        // Check 6: Reasonable length (increased for modern HTML receipts)
        if content.count < 10000 { // Increased from 2000 to 10KB for HTML emails
            score += 1
            checkResults.append("Length:")
            NSLog("[INTENT-RECEIPT] Check 6: Appropriate length for receipt")
        } else {
            checkResults.append("Length:")
        }

        let finalScore = Double(score) / Double(maxScore)
        let result = score >= 3 // Require at least 3/6 checks to pass (50% score, was 4/6)

        NSLog("[INTENT-RECEIPT] Exit: Score=\(score)/\(maxScore) (\(String(format: "%.1f", finalScore * 100))%), Checks=\(checkResults.joined(separator: " ")), Result=\(result)")
        return result
    }

    /// Check if sender is a known merchant/retailer
    private static func isKnownMerchant(sender: String) -> Bool {
        let knownMerchants = [
            // Australian retailers
            "woolworths", "coles", "aldi", "iga", "bws",
            "bunnings", "kmart", "target", "bigw", "harveynorman",
            "jbhifi", "officeworks", "dicksmith", "myer", "davidjones",
            "hungryjacks", "maccas", "kfc", "subway", "dominos",
            "boostjuice", "guzman", "oporto", "nandos", "rebel",

            // International retailers
            "amazon", "ebay", "paypal", "apple", "google",
            "uber", "didi", "ola", "netflix", "spotify",
            "spotify", "netflix", "disney+", "youtube", "microsoft",

            // Food delivery & takeout
            "uber eats", "doordash", "menulog", "deliveroo", "foodora",
            "hungryhouse", "justeat", "zomato", "skip", "swiggy",

            // Banks and financial institutions
            "commbank", "nab", "anz", "westpac", "ing",
            "paypal", "afterpay", "zip", "klarna", "shopback",
            "paypal", "square", "stripe", "wise", "revolut",

            // Utilities and services
            "telstra", "optus", "vodafone", "agl", "origin",
            "energyaustralia", "sydneywater", "toll", "gas",

            // Online services & subscriptions
            "adobe", "microsoft", "github", "dropbox", "zoom",
            "slack", "linkedin", "netflix", "spotify", "youtube",

            // Travel & accommodation
            "booking.com", "expedia", "airbnb", "hotels.com", "trip.com",
            "qantas", "virgin", "jetstar", "ryanair", "emirates"
        ]

        let senderLower = sender.lowercased()
        let result = knownMerchants.contains { merchant in
            senderLower.contains(merchant)
        }

        if let merchant = knownMerchants.first(where: { senderLower.contains($0) }) {
            NSLog("[INTENT-MERCHANT] Known merchant detected: \(merchant)")
        }

        return result
    }

    /// Check for transaction-specific indicators
    private static func containsTransactionalIndicators(subject: String, content: String) -> Bool {
        let transactionalIndicators = [
            // Payment methods
            "visa", "mastercard", "amex", "american express", "afterpay", "paypal",
            "zip pay", "klarna", "apple pay", "google pay", "samsung pay",

            // Transaction terms
            "total", "amount", "subtotal", "balance", "payment", "paid",
            "charged", "debited", "credit", "refund", "transaction",

            // Receipt/invoice terms
            "gst", "tax", "invoice", "receipt", "order", "purchase",
            "confirmation", "booking", "reservation",

            // Delivery/shipping
            "order shipped", "delivery", "tracking", "dispatch",
            "estimated delivery", "shipping",

            // Currency symbols and amounts
            "$", "aud", "usd", "eur", "gbp", "¥", "€", "£"
        ]

        let fullText = "\(subject) \(content)"
        var matchedIndicators: [String] = []

        for indicator in transactionalIndicators {
            if fullText.range(of: indicator, options: .caseInsensitive) != nil {
                matchedIndicators.append(indicator)
            }
        }

        let result = !matchedIndicators.isEmpty
        NSLog("[INTENT-TRANSACTION] \(matchedIndicators.count) indicators found, Result=\(result)")

        if result {
            NSLog("[INTENT-TRANSACTION] Matched indicators: \(matchedIndicators.joined(separator: ", "))")
        }

        return result
    }
}