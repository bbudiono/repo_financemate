import Foundation

/// Service responsible for batch processing email extraction with progress tracking
/// BLUEPRINT Line 150: Concurrent batch processing with real-time progress updates
class GmailBatchProcessor {

    /// Progress callback type for real-time updates
    typealias ProgressCallback = @Sendable (Int, Int, Int) -> Void

    /// Result containing extracted transactions and processing metadata
    struct BatchResult {
        let transactions: [ExtractedTransaction]
        let totalProcessed: Int
        let errorCount: Int
        let processingTime: TimeInterval
    }

    /// Extract transactions from multiple emails with concurrent processing
    /// - Parameters:
    ///   - emails: Array of Gmail emails to process
    ///   - maxConcurrency: Maximum concurrent extraction operations (default: 5)
    ///   - progressCallback: Optional callback for progress updates
    /// - Returns: BatchResult containing filtered and sorted transactions
    func extractBatch(
        from emails: [GmailEmail],
        maxConcurrency: Int = 5,
        progressCallback: ProgressCallback? = nil
    ) async -> BatchResult {
        NSLog("=== EXTRACTION START ===")
        NSLog("Total emails: \(emails.count)")
        GmailDebugLogger.saveEmailsForDebug(emails)

        let startTime = Date()
        var errorCount = 0

        // BLUEPRINT Line 150: Use concurrent batch processing with progress
        let allExtracted = await IntelligentExtractionService.extractBatch(
            emails,
            maxConcurrency: maxConcurrency
        ) { processed, total, errors in
            errorCount = errors
            progressCallback?(processed, total, errors)
        }

        let processingTime = Date().timeIntervalSince(startTime)

        NSLog("Extracted: \(allExtracted.count) transactions")

        // Filter and sort by confidence
        let filteredTransactions = allExtracted
            .filter { $0.confidence >= 0.6 }
            .sorted { $0.confidence > $1.confidence }

        NSLog("After filter (≥0.6): \(filteredTransactions.count)")

        // Log top 3 results
        for (i, tx) in filteredTransactions.prefix(3).enumerated() {
            NSLog("\(i+1). \(tx.merchant) $\(tx.amount) (\(Int(tx.confidence*100))%)")
        }

        return BatchResult(
            transactions: filteredTransactions,
            totalProcessed: emails.count,
            errorCount: errorCount,
            processingTime: processingTime
        )
    }
}
