import Foundation
import SwiftUI
import OSLog

actor GmailTransactionExtractor {
    private let importTracker: ImportTracker
    private let transactionBuilder: TransactionBuilder
    private let logger = Logger(subsystem: "com.ablankcanvas.financemate", category: "GmailTransactionExtractor")

    init(importTracker: ImportTracker, transactionBuilder: TransactionBuilder) {
        self.importTracker = importTracker
        self.transactionBuilder = transactionBuilder
    }

    func extractTransactionsFromEmails(
        emails: [GmailEmail],
        onProgress: @escaping @Sendable (Int, Int, Int) -> Void
    ) async -> [ExtractedTransaction] {
        let startTime = Date()
        let processorCount = ProcessInfo.processInfo.processorCount

        // Adaptive concurrency based on email count and processor resources
        let adaptiveConcurrency = determineAdaptiveConcurrency(
            emailCount: emails.count,
            processorCount: processorCount
        )

        logger.log("Starting transaction extraction: \(emails.count) emails, concurrency: \(adaptiveConcurrency)")

        let allExtracted = await IntelligentExtractionService.extractBatch(
            emails,
            maxConcurrency: adaptiveConcurrency
        ) { processed, total, errors in
            logger.log("Extraction progress: \(processed)/\(total), errors: \(errors)")
            onProgress(processed, total, errors)
        }

        let extractedTransactions = allExtracted
            .filter { $0.confidence >= 0.4 }
            .sorted { $0.confidence > $1.confidence }

        logger.log("Extraction complete: \(extractedTransactions.count) transactions")

        return extractedTransactions
    }

    private func determineAdaptiveConcurrency(
        emailCount: Int,
        processorCount: Int
    ) -> Int {
        if emailCount < 10 {
            return 2
        } else if emailCount < 50 {
            return 3
        } else {
            let thermalState = ProcessInfo.processInfo.thermalState
            let baseConcurrency = min(processorCount, 5)

            return thermalState == .nominal ? baseConcurrency : max(1, baseConcurrency / 2)
        }
    }

    func createTransactions(from extractedTransactions: [ExtractedTransaction]) -> [Transaction] {
        extractedTransactions.compactMap {
            transactionBuilder.createTransaction(from: $0)
        }
    }
}