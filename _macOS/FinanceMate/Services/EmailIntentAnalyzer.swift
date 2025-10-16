import Foundation

/// Email intent analyzer - pre-classifies emails to prevent false positives
/// CRITICAL: Prevents professional correspondence from being processed as receipts
/// REFACTORED: Now delegates to specialized components for complexity management
struct EmailIntentAnalyzer {

    /// Email intent classification result
    enum EmailIntent {
        case receipt               // Actual transactional receipt
        case businessCorrespondence // Professional business communication
        case personal               // Personal email
        case marketing             // Promotional content
        case unknown               // Cannot determine intent
    }

    /// Analyze email to determine if it's actually a receipt before extraction
    /// - Parameters:
    ///   - subject: Email subject line
    ///   - sender: Sender email address
    ///   - content: Email body content
    /// - Returns: EmailIntent classification
    static func analyzeIntent(subject: String, sender: String, content: String) -> EmailIntent {
        let startTime = Date()
        NSLog("[INTENT-ANALYZER] Entry: Analyzing email - Subject: '\(subject)', Sender: '\(sender)', Content Length: \(content.count)")

        // PERFORMANCE CHECK: Reject very large emails (accommodate modern HTML emails)
        if content.count > 51200 { // 50KB limit - increased from 10KB
            NSLog("[INTENT-ANALYZER] Performance: Email too large (\(content.count) chars), rejecting")
            return .unknown
        }

        // PHASE 1: Strong negative patterns (immediate rejection)
        if EmailNegativePatternDetector.containsNegativePatterns(subject: subject, sender: sender, content: content) {
            let processingTime = Date().timeIntervalSince(startTime)
            NSLog("[INTENT-ANALYZER] Exit: REJECT - Strong negative patterns detected, Processing Time: \(String(format: "%.2f", processingTime * 1000))ms")
            return .businessCorrespondence
        }

        // PHASE 2: Professional correspondence detection
        if ProfessionalCorrespondenceDetector.isProfessionalCorrespondence(subject: subject, sender: sender, content: content) {
            let processingTime = Date().timeIntervalSince(startTime)
            NSLog("[INTENT-ANALYZER] Exit: REJECT - Professional correspondence detected, Processing Time: \(String(format: "%.2f", processingTime * 1000))ms")
            return .businessCorrespondence
        }

        // PHASE 3: Marketing/promotional content detection
        if MarketingContentDetector.isMarketingContent(subject: subject, sender: sender, content: content) {
            let processingTime = Date().timeIntervalSince(startTime)
            NSLog("[INTENT-ANALYZER] Exit: REJECT - Marketing content detected, Processing Time: \(String(format: "%.2f", processingTime * 1000))ms")
            return .marketing
        }

        // PHASE 4: Receipt validation (must pass multiple checks)
        if ReceiptValidator.isLikelyReceipt(subject: subject, sender: sender, content: content) {
            let processingTime = Date().timeIntervalSince(startTime)
            NSLog("[INTENT-ANALYZER] Exit: ACCEPT - Likely receipt detected, Processing Time: \(String(format: "%.2f", processingTime * 1000))ms")
            return .receipt
        }

        let processingTime = Date().timeIntervalSince(startTime)
        NSLog("[INTENT-ANALYZER] Exit: UNKNOWN - No clear intent detected, Processing Time: \(String(format: "%.2f", processingTime * 1000))ms")
        return .unknown
    }
}