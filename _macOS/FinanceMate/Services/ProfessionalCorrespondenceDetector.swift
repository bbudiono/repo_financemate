import Foundation

/// Detects professional business correspondence vs transactional emails
/// Part of EmailIntentAnalyzer - separated for complexity management
struct ProfessionalCorrespondenceDetector {

    /// Detect if email is professional business correspondence
    /// - Parameters:
    ///   - subject: Email subject line
    ///   - sender: Sender email address
    ///   - content: Email body content
    /// - Returns: True if appears to be professional correspondence
    static func isProfessionalCorrespondence(subject: String, sender: String, content: String) -> Bool {
        NSLog("[INTENT-BUSINESS] Entry: Checking professional correspondence patterns")

        // Business domain indicators
        let businessDomains = [
            "consulting", "legal", "accounting", "firm", "partners", "associates",
            "solutions", "group", "company", "corp", "inc", "llc", "pty", "ltd"
        ]

        let senderDomain = sender.components(separatedBy: "@").last?.lowercased() ?? ""
        var businessDomainFound: String?

        for domain in businessDomains {
            if senderDomain.contains(domain) {
                businessDomainFound = domain
                NSLog("[INTENT-BUSINESS] Business domain detected: \(domain) in \(senderDomain)")
                break
            }
        }

        // Professional closing phrases
        let professionalClosings = [
            "best regards",
            "kind regards",
            "sincerely",
            "respectfully",
            "yours truly",
            "cheers",
            "many thanks",
            "with thanks"
        ]

        let fullText = "\(subject) \(content)"
        var closingFound: String?

        for closing in professionalClosings {
            if fullText.range(of: closing, options: .caseInsensitive) != nil {
                closingFound = closing
                NSLog("[INTENT-BUSINESS] Professional closing detected: '\(closing)'")
                break
            }
        }

        // Email length and structure analysis
        let tooLongForReceipt = content.count > 500 && !containsTransactionalIndicators(subject: subject, content: content)
        if tooLongForReceipt {
            NSLog("[INTENT-BUSINESS] Long professional email without transaction indicators")
        }

        let result = businessDomainFound != nil || closingFound != nil || tooLongForReceipt
        NSLog("[INTENT-BUSINESS] Exit: BusinessDomain=\(businessDomainFound ?? "nil"), Closing=\(closingFound ?? "nil"), TooLong=\(tooLongForReceipt), Result=\(result)")
        return result
    }

    /// Check for transaction-specific indicators
    private static func containsTransactionalIndicators(subject: String, content: String) -> Bool {
        let transactionalIndicators = [
            "total",
            "amount",
            "visa",
            "mastercard",
            "afterpay",
            "paypal",
            "gst",
            "tax",
            "subtotal",
            "balance",
            "payment",
            "order shipped",
            "delivery"
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