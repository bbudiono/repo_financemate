import Foundation

/// Batch processing extension for IntelligentExtractionService
/// KISS: Separated to maintain low complexity in main service
extension IntelligentExtractionService {

    // MARK: - Concurrent Batch Processing (BLUEPRINT Line 150)

    /// Extract transactions from multiple emails concurrently using TaskGroup
    /// - Parameters:
    ///   - emails: Array of emails to process
    ///   - maxConcurrency: Maximum number of concurrent tasks (default 5 for Apple Silicon)
    ///   - progressCallback: Optional callback for progress updates (processed, total, errors)
    /// - Returns: Array of all extracted transactions
    static func extractBatch(
        _ emails: [GmailEmail],
        maxConcurrency: Int = 5,
        progressCallback: (@Sendable (Int, Int, Int) async -> Void)? = nil
    ) async -> [ExtractedTransaction] {
        let totalEmails = emails.count
        var processedCount = 0
        var errorCount = 0

        NSLog("[BATCH-START] Processing \(totalEmails) emails with \(maxConcurrency) concurrent tasks")

        return await withTaskGroup(of: (Int, [ExtractedTransaction]?).self) { group in
            var results: [Int: [ExtractedTransaction]] = [:]
            var activeTaskCount = 0

            for (index, email) in emails.enumerated() {
                // Wait if at max concurrency
                if activeTaskCount >= maxConcurrency {
                    if let (completedIndex, transactions) = await group.next() {
                        activeTaskCount -= 1
                        processedCount += 1

                        if let transactions = transactions {
                            results[completedIndex] = transactions
                        } else {
                            errorCount += 1
                            NSLog("[BATCH-ERROR] Failed to extract from email at index \(completedIndex)")
                        }

                        await progressCallback?(processedCount, totalEmails, errorCount)
                    }
                }

                // Add new task
                group.addTask {
                    let extracted = await extract(from: email)
                    return (index, extracted)
                }
                activeTaskCount += 1
            }

            // Collect remaining results
            for await (index, transactions) in group {
                processedCount += 1

                if let transactions = transactions {
                    results[index] = transactions
                } else {
                    errorCount += 1
                }

                await progressCallback?(processedCount, totalEmails, errorCount)
            }

            // Return results in original order
            let orderedResults = (0..<totalEmails).compactMap { results[$0] }.flatMap { $0 }
            NSLog("[BATCH-COMPLETE] Processed: \(processedCount), Errors: \(errorCount), Results: \(orderedResults.count)")

            return orderedResults
        }
    }
}
