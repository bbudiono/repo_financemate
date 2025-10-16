import Foundation

/// Detects promotional/marketing content in emails
/// Part of EmailIntentAnalyzer - separated for complexity management
struct MarketingContentDetector {

    /// Detect if email contains marketing/promotional content
    /// - Parameters:
    ///   - subject: Email subject line
    ///   - sender: Sender email address
    ///   - content: Email body content
    /// - Returns: True if appears to be marketing content
    static func isMarketingContent(subject: String, sender: String, content: String) -> Bool {
        NSLog("[INTENT-MARKETING] Entry: Checking marketing content patterns")

        let marketingPatterns = [
            "sale",
            "discount",
            "promotion",
            "offer",
            "deal",
            "limited time",
            "exclusive",
            "coupon",
            "voucher",
            "free shipping",
            "shop now",
            "buy now",
            "don't miss",
            "unsubscribe"
        ]

        let fullText = "\(subject) \(content)"
        var matchedPatterns: [String] = []

        for pattern in marketingPatterns {
            if fullText.range(of: pattern, options: .caseInsensitive) != nil {
                matchedPatterns.append(pattern)
            }
        }

        let threshold = 2
        let result = matchedPatterns.count >= threshold

        NSLog("[INTENT-MARKETING] Exit: \(matchedPatterns.count)/\(threshold) patterns matched, Result=\(result)")
        if result {
            NSLog("[INTENT-MARKETING] Matched patterns: \(matchedPatterns.joined(separator: ", "))")
        }

        return result
    }
}