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
        if let quick = regexResult, quick.confidence > ExtractionConstants.tier1ConfidenceThreshold {
            NSLog("[EXTRACT-TIER1] SUCCESS - Confidence: \(quick.confidence)")
            return [quick]
        }

        // TIER 2: Foundation Models (macOS 26+ only)
        // P0 FIX: Proper error logging for Foundation Models (2025-10-11)
        // SECURITY: Silent error swallowing replaced with explicit logging
        if #available(macOS 26.0, *) {
            do {
                let intelligent = try await tryFoundationModelsExtraction(email)
                if intelligent.confidence > ExtractionConstants.tier2ConfidenceThreshold {
                    NSLog("[EXTRACT-TIER2] SUCCESS - Confidence: \(intelligent.confidence)")
                    return [intelligent]
                }
            } catch {
                NSLog("[EXTRACT-ERROR] Foundation Models failed: \(error.localizedDescription)")
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
        // P0 FIX: Safe merchant extraction with proper validation (2025-10-11)
        // SECURITY: Prevents crashes from malformed email addresses
        let emailComponents = email.sender.split(separator: "@")
        guard emailComponents.count == 2 else {
            NSLog("[EXTRACT-SECURITY] Malformed sender address: \(email.sender)")
            return ExtractedTransaction(
                id: email.id,
                merchant: "Unknown Email",
                amount: 0.0,
                date: email.date,
                category: "Other",
                items: [],
                confidence: ExtractionConstants.manualReviewConfidence,
                rawText: email.snippet,
                emailSubject: email.subject,
                emailSender: email.sender,
                gstAmount: nil,
                abn: nil,
                invoiceNumber: "EMAIL-\(email.id.prefix(8))",
                paymentMethod: nil
            )
        }

        let domain = String(emailComponents[1])
        let merchant = domain.split(separator: ".").first.map { String($0).capitalized } ?? "Unknown"

        return ExtractedTransaction(
            id: email.id,
            merchant: merchant,
            amount: 0.0,
            date: email.date,
            category: "Other",
            items: [],
            confidence: ExtractionConstants.manualReviewConfidence,  // Low confidence - needs review
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
