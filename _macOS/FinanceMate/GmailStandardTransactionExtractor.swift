import Foundation

/// Extracts standard transaction data from Gmail emails (receipts, invoices)
struct GmailStandardTransactionExtractor {

    /// Extract standard transaction (receipts, invoices)
    static func extractStandardTransaction(from email: GmailEmail) -> ExtractedTransaction? {
        guard let merchant = GmailTransactionExtractor.extractMerchant(from: email.subject, sender: email.sender),
              let amount = GmailTransactionExtractor.extractAmount(from: email.snippet) else { return nil }

        let items = GmailTransactionExtractor.extractLineItems(from: email.snippet)
        let category = GmailTransactionExtractor.inferCategory(from: merchant)
        let confidence = calculateConfidence(merchant: merchant, amount: amount, items: items)

        return ExtractedTransaction(
            id: email.id,
            merchant: merchant,
            amount: amount,
            date: email.date,
            category: category,
            items: items,
            confidence: confidence,
            rawText: email.snippet,
            emailSubject: email.subject,
            emailSender: email.sender,
            gstAmount: GmailTransactionExtractor.extractGST(from: email.snippet),
            abn: GmailTransactionExtractor.extractABN(from: email.snippet),
            invoiceNumber: GmailTransactionExtractor.extractInvoiceNumber(from: email.snippet, emailID: email.id),
            paymentMethod: GmailTransactionExtractor.extractPaymentMethod(from: email.snippet)
        )
    }

    private static func calculateConfidence(merchant: String, amount: Double, items: [GmailLineItem]) -> Double {
        var conf = 0.0
        if !merchant.isEmpty { conf += 0.4 }
        if amount > 0 { conf += 0.4 }
        if !items.isEmpty { conf += 0.2 }
        return conf
    }
}
