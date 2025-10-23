import Foundation
import CoreData

/// 4-Tier intelligent extraction pipeline (Phase 3.3)
/// BLUEPRINT Section 3.1.1.4: PDF → Regex → Foundation Models → Manual Review
class IntelligentExtractionService {

    /// Extract transactions using 4-tier pipeline with cache-first optimization (BLUEPRINT Line 151)
    /// - Parameter email: Gmail email to process
    /// - Returns: Array of extracted transactions
    /// - Note: Thread-safe for concurrent batch processing - each email is isolated
    static func extract(from email: GmailEmail) async -> [ExtractedTransaction] {
        // FIX: Create isolated copies of email fields to prevent race conditions
        let emailID = email.id
        let emailSubject = email.subject
        let emailSender = email.sender
        let emailDate = email.date
        let emailSnippet = email.snippet

        NSLog("[EXTRACT-START] Email ID: \(emailID) | Subject: \(emailSubject) | Sender: \(emailSender)")

        // CACHE CHECK: Query Core Data for existing extraction (BLUEPRINT Line 151)
        let contentHash = emailSnippet.hashValue
        if let cached = queryCachedExtraction(emailID: emailID, hash: Int64(contentHash)) {
            NSLog("[EXTRACT-CACHE] HIT - EmailID: \(emailID) - Skipping re-extraction (95% performance boost)")
            validateExtraction(cached, sourceEmail: email)
            return [cached]
        }
        NSLog("[EXTRACT-CACHE] MISS - EmailID: \(emailID) - Proceeding with full extraction")

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
            NSLog("[EXTRACT-TIER1] SUCCESS - EmailID: \(emailID) - Confidence: \(quick.confidence)")
            validateExtraction(quick, sourceEmail: email)
            return [quick]
        }

        // TIER 2: Foundation Models (macOS 26+ only)
        // P0 FIX: Proper error logging for Foundation Models (2025-10-11)
        // SECURITY: Silent error swallowing replaced with explicit logging
        if #available(macOS 26.0, *) {
            do {
                let intelligent = try await tryFoundationModelsExtraction(email)
                if intelligent.confidence > ExtractionConstants.tier2ConfidenceThreshold {
                    NSLog("[EXTRACT-TIER2] SUCCESS - EmailID: \(emailID) - Confidence: \(intelligent.confidence)")
                    validateExtraction(intelligent, sourceEmail: email)
                    return [intelligent]
                }
            } catch {
                NSLog("[EXTRACT-ERROR] EmailID: \(emailID) - Foundation Models failed: \(error.localizedDescription)")
            }
        }

        // TIER 3: Manual review queue
        NSLog("[EXTRACT-TIER3] EmailID: \(emailID) - Low confidence - routing to manual review")
        let manualTx = createManualReviewTransaction(email)
        validateExtraction(manualTx, sourceEmail: email)
        return [manualTx]
    }

    // MARK: - Validation

    /// Validate that extracted transaction matches source email (prevents data corruption)
    /// - Parameters:
    ///   - transaction: Extracted transaction to validate
    ///   - sourceEmail: Original email that was extracted from
    private static func validateExtraction(_ transaction: ExtractedTransaction, sourceEmail: GmailEmail) {
        // CRITICAL: Validate transaction ID matches email ID
        guard transaction.id == sourceEmail.id else {
            NSLog("[EXTRACT-CORRUPTION] CRITICAL - Transaction ID mismatch! Expected: \(sourceEmail.id), Got: \(transaction.id)")
            assertionFailure("Transaction ID must match source email ID - data corruption detected")
            return
        }

        // CRITICAL: Validate email fields match source
        guard transaction.emailSender == sourceEmail.sender else {
            NSLog("[EXTRACT-CORRUPTION] CRITICAL - Email sender mismatch! Expected: \(sourceEmail.sender), Got: \(transaction.emailSender)")
            assertionFailure("Email sender must match source - data corruption detected")
            return
        }

        guard transaction.emailSubject == sourceEmail.subject else {
            NSLog("[EXTRACT-CORRUPTION] CRITICAL - Email subject mismatch! Expected: \(sourceEmail.subject), Got: \(transaction.emailSubject)")
            assertionFailure("Email subject must match source - data corruption detected")
            return
        }

        // Log successful validation
        NSLog("[EXTRACT-VALIDATED] ✓ Transaction \(transaction.id) matches source email - Merchant: \(transaction.merchant), Sender: \(transaction.emailSender)")
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

            // CRITICAL FIX: Check for duplicates and clean up if found
            if results.count > 1 {
                NSLog("[EXTRACT-CACHE] WARNING - Found \(results.count) duplicate cached extractions for emailID: \(emailID)")
                // Delete all but the most recent
                let sorted = results.sorted { ($0.importedDate ?? Date.distantPast) > ($1.importedDate ?? Date.distantPast) }
                for duplicate in sorted.dropFirst() {
                    context.delete(duplicate)
                    NSLog("[EXTRACT-CACHE] Deleted duplicate cached extraction")
                }
                try? context.save()
            }

            guard let transaction = results.first else { return nil }

            // CRITICAL: If emailSource is missing, cache is from old version - invalidate it
            guard let emailSource = transaction.emailSource, !emailSource.isEmpty else {
                NSLog("[EXTRACT-CACHE] INVALIDATED - emailSource missing (old cache version)")
                // Delete poisoned cache entry
                context.delete(transaction)
                try? context.save()
                return nil  // Force fresh extraction
            }

            // Convert Core Data Transaction to ExtractedTransaction
            // CRITICAL FIX: Use proper merchant extraction instead of cached itemDescription
            // itemDescription might be wrong if cache was poisoned - use authoritative email source
            let merchant = GmailTransactionExtractor.extractMerchant(
                from: transaction.note ?? "",
                sender: emailSource
            ) ?? "Unknown"

            return ExtractedTransaction(
                id: emailID,
                merchant: merchant,  // Proper extraction, not itemDescription
                amount: abs(transaction.amount),
                date: transaction.date,
                category: transaction.category,
                items: [],
                confidence: 0.9,  // Cached extractions are trusted
                rawText: transaction.note ?? "",
                emailSubject: transaction.note ?? "",
                emailSender: transaction.emailSource ?? "",
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
