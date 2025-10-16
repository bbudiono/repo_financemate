import Foundation

/// Detects negative patterns that indicate email is not a receipt
/// Part of EmailIntentAnalyzer - separated for complexity management
struct EmailNegativePatternDetector {

    /// Check for strong negative patterns that immediately disqualify emails as receipts
    /// - Parameters:
    ///   - subject: Email subject line
    ///   - sender: Sender email address
    ///   - content: Email body content
    /// - Returns: True if negative patterns detected
    static func containsNegativePatterns(subject: String, sender: String, content: String) -> Bool {
        NSLog("[INTENT-NEGATIVE] Entry: Checking strong negative patterns")

        let negativePatterns = [
            // Professional correspondence phrases (more specific)
            "thank you for your time",
            "appreciate your feedback",
            "looking forward to working with",
            "following up on our conversation",
            "rubric",
            "assessment",
            "evaluation",
            "agenda",
            "minutes",
            "action items",
            "project update",
            "team collaboration",

            // Academic/educational contexts (more specific)
            "assignment submitted",
            "grade posted",
            "student portal",
            "professor office",
            "university application",
            "college transcript",
            "semester registration",

            // Financial discussions (not transactions)
            "payment terms",
            "invoice attached for reference",
            "quote for your review",
            "estimate for your consideration",
            "proposal",
            "contract negotiation",
            "agreement draft",

            // Personal correspondence (more specific - removed overly broad patterns)
            "how are you doing",
            "hope you're doing well",
            "catching up soon",
            "just checking in on you"
        ]

        let fullText = "\(subject) \(content)"
        var matchedPatterns: [String] = []

        for (index, pattern) in negativePatterns.enumerated() {
            if let range = fullText.range(of: pattern, options: .caseInsensitive) {
                let match = String(fullText[range])
                matchedPatterns.append("Pattern \(index + 1): '\(match)'")
                NSLog("[INTENT-NEGATIVE] Match: Pattern \(index + 1) - '\(pattern)' -> '\(match)'")
            }
        }

        let result = !matchedPatterns.isEmpty
        NSLog("[INTENT-NEGATIVE] Exit: \(matchedPatterns.count) patterns matched, Result: \(result)")
        return result
    }
}