import Foundation

/// 3-Tier intelligent extraction pipeline
/// BLUEPRINT Section 3.1.1.4: Regex → Foundation Models → Manual Review
class IntelligentExtractionService {

    /// Extract transactions using 3-tier pipeline
    /// - Parameter email: Gmail email to process
    /// - Returns: Array of extracted transactions
    static func extract(from email: GmailEmail) async -> [ExtractedTransaction] {
        NSLog("[EXTRACT-START] Email: \(email.subject)")

        // TIER 1: Fast regex baseline (<100ms)
        let regexResult = tryRegexExtraction(email)
        if let quick = regexResult, quick.confidence > 0.8 {
            NSLog("[EXTRACT-TIER1] SUCCESS - Confidence: \(quick.confidence)")
            return [quick]
        }

        // TIER 2: Foundation Models (macOS 26+ only)
        if #available(macOS 26.0, *) {
            if let intelligent = try? await tryFoundationModelsExtraction(email) {
                if intelligent.confidence > 0.7 {
                    NSLog("[EXTRACT-TIER2] SUCCESS - Confidence: \(intelligent.confidence)")
                    return [intelligent]
                }
            }
        }

        // TIER 3: Manual review queue
        NSLog("[EXTRACT-TIER3] Low confidence - routing to manual review")
        return [createManualReviewTransaction(email)]
    }

    // MARK: - Tier 1: Regex Extraction

    private static func tryRegexExtraction(_ email: GmailEmail) -> ExtractedTransaction? {
        // Use existing GmailStandardTransactionExtractor
        return GmailStandardTransactionExtractor.extractStandardTransaction(from: email)
    }

    // MARK: - Tier 2: Foundation Models Extraction

    @available(macOS 26.0, *)
    private static func tryFoundationModelsExtraction(_ email: GmailEmail) async throws -> ExtractedTransaction {
        return try await FoundationModelsExtractor.extract(from: email)
    }

    // MARK: - Tier 3: Manual Review

    private static func createManualReviewTransaction(_ email: GmailEmail) -> ExtractedTransaction {
        // Extract basic info for manual review
        let merchant = email.sender.components(separatedBy: "@").last?.components(separatedBy: ".").first?.capitalized ?? "Unknown"

        return ExtractedTransaction(
            id: email.id,
            merchant: merchant,
            amount: 0.0,
            date: email.date,
            category: "Other",
            items: [],
            confidence: 0.3,  // Low confidence - needs review
            rawText: email.snippet,
            emailSubject: email.subject,
            emailSender: email.sender,
            gstAmount: nil,
            abn: nil,
            invoiceNumber: "EMAIL-\(email.id.prefix(8))",
            paymentMethod: nil
        )
    }
}
