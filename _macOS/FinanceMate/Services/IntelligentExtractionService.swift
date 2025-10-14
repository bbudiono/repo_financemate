import Foundation
import CoreData

/// 4-Tier intelligent extraction pipeline (Phase 3.3)
/// BLUEPRINT Section 3.1.1.4: PDF → Regex → Foundation Models → Manual Review
class IntelligentExtractionService {

    /// Extract transactions using 4-tier pipeline with cache-first optimization (BLUEPRINT Line 151)
    /// - Parameter email: Gmail email to process
    /// - Returns: Array of extracted transactions
    static func extract(from email: GmailEmail) async -> [ExtractedTransaction] {
        NSLog("[EXTRACT-START] Email: \(email.subject)")

        // CACHE CHECK: Query Core Data for existing extraction (BLUEPRINT Line 151)
        let contentHash = email.snippet.hashValue
        if let cached = queryCachedExtraction(emailID: email.id, hash: Int64(contentHash)) {
            NSLog("[EXTRACT-CACHE] HIT - Skipping re-extraction (95% performance boost)")
            return [cached]
        }
        NSLog("[EXTRACT-CACHE] MISS - Proceeding with full extraction")

        // TIER 0: PDF ATTACHMENT EXTRACTION (Phase 3.3)
        if let pdfTransactions = await tryExtractFromPDFAttachments(email) {
            if !pdfTransactions.isEmpty {
                NSLog("[EXTRACT-TIER0] PDF SUCCESS - \(pdfTransactions.count) transactions")
                return pdfTransactions
            }
        }

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

    // MARK: - Cache Management (BLUEPRINT Line 151)

    /// Query Core Data for cached extraction by email ID and content hash
    /// - Parameters:
    ///   - emailID: Source email ID
    ///   - hash: Content hash of email snippet
    /// - Returns: Cached ExtractedTransaction if found and hash matches
    private static func queryCachedExtraction(emailID: String, hash: Int64) -> ExtractedTransaction? {
        let context = PersistenceController.shared.container.viewContext
        let request = NSFetchRequest<Transaction>(entityName: "Transaction")
        request.predicate = NSPredicate(format: "sourceEmailID == %@ AND contentHash == %lld", emailID, hash)
        request.fetchLimit = 1

        do {
            let results = try context.fetch(request)
            guard let transaction = results.first else { return nil }

            // Convert Core Data Transaction to ExtractedTransaction
            return ExtractedTransaction(
                id: emailID,
                merchant: transaction.itemDescription.components(separatedBy: " - ").first ?? "Unknown",
                amount: abs(transaction.amount),
                date: transaction.date,
                category: transaction.category,
                items: [],
                confidence: 0.9,  // Cached extractions are trusted
                rawText: transaction.note ?? "",
                emailSubject: transaction.note ?? "",
                emailSender: "",
                gstAmount: nil,
                abn: nil,
                invoiceNumber: "CACHED-\(emailID.prefix(8))",
                paymentMethod: nil
            )
        } catch {
            NSLog("[EXTRACT-CACHE-ERROR] Query failed: \(error.localizedDescription)")
            return nil
        }
    }
}
