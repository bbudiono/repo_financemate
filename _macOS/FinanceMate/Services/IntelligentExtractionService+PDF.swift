import Foundation

/// PDF extraction methods for IntelligentExtractionService (Phase 3.3)
/// KISS: Separated to maintain low complexity in main service
extension IntelligentExtractionService {

    // MARK: - Tier 0: PDF Attachment Extraction

    /// Attempt to extract transactions from PDF attachments
    /// - Parameter email: GmailEmail with potential attachments
    /// - Returns: Array of extracted transactions, or nil if no PDFs or extraction failed
    static func tryExtractFromPDFAttachments(_ email: GmailEmail) async -> [ExtractedTransaction]? {
        let pdfAttachments = email.attachments.filter { $0.isPDF }
        guard !pdfAttachments.isEmpty else { return nil }

        var allTransactions: [ExtractedTransaction] = []

        for attachment in pdfAttachments {
            if let transaction = await processPDFAttachment(attachment, email: email) {
                allTransactions.append(transaction)
            }
        }

        return allTransactions.isEmpty ? nil : allTransactions
    }

    /// Process single PDF attachment
    private static func processPDFAttachment(
        _ attachment: GmailAttachment,
        email: GmailEmail
    ) async -> ExtractedTransaction? {
        do {
            let pdfData = getCachedOrMockPDFData(for: email.id, filename: attachment.filename)
            let service = PDFExtractionService()
            let lineItems = try await service.extractLineItems(from: pdfData)

            return convertToTransaction(
                lineItems: lineItems,
                email: email,
                filename: attachment.filename
            )
        } catch let error as PDFExtractionError {
            if case .requiresPassword(let filename) = error {
                NSLog("[PDF] Password-protected: \(filename)")
                return createPasswordProtectedTransaction(email: email, filename: filename)
            }
            NSLog("[PDF] Extraction error: \(error)")
            return nil
        } catch {
            NSLog("[PDF] Extraction failed: \(error)")
            return nil
        }
    }

    /// Get cached PDF data or return mock data for testing
    private static func getCachedOrMockPDFData(for messageId: String, filename: String) -> Data {
        let cache = AttachmentCacheService.shared
        if let cached = cache.get(for: messageId, filename: filename) {
            return cached
        }
        // Return mock PDF data for testing (empty PDF)
        return Data()
    }

    /// Convert PDF line items to ExtractedTransaction
    private static func convertToTransaction(
        lineItems: [PDFLineItem],
        email: GmailEmail,
        filename: String
    ) -> ExtractedTransaction {
        let totalAmount = lineItems.reduce(0.0) { $0 + $1.amount }
        let totalGST = lineItems.reduce(0.0) { $0 + $1.gst }
        let merchant = extractMerchantFromFilename(filename) ?? extractMerchantFromSender(email.sender)

        let gmailLineItems = lineItems.map { pdfItem in
            GmailLineItem(
                description: pdfItem.description,
                quantity: pdfItem.quantity,
                price: pdfItem.amount
            )
        }

        return ExtractedTransaction(
            id: email.id,
            merchant: merchant,
            amount: totalAmount,
            date: email.date,
            category: "Uncategorized",
            items: gmailLineItems,
            confidence: 0.95,
            rawText: "PDF: \(filename)",
            emailSubject: email.subject,
            emailSender: email.sender,
            gstAmount: totalGST,
            abn: nil,
            invoiceNumber: "PDF-\(email.id.prefix(8))",
            paymentMethod: nil
        )
    }

    /// Create manual review transaction for password-protected PDFs
    private static func createPasswordProtectedTransaction(
        email: GmailEmail,
        filename: String
    ) -> ExtractedTransaction {
        return ExtractedTransaction(
            id: email.id,
            merchant: extractMerchantFromSender(email.sender),
            amount: 0.0,
            date: email.date,
            category: "Manual Review",
            items: [],
            confidence: 0.0,
            rawText: "Password-protected PDF: \(filename)",
            emailSubject: email.subject,
            emailSender: email.sender,
            gstAmount: nil,
            abn: nil,
            invoiceNumber: "MANUAL-\(email.id.prefix(8))",
            paymentMethod: nil
        )
    }

    /// Extract merchant name from PDF filename
    private static func extractMerchantFromFilename(_ filename: String) -> String? {
        let nameWithoutExtension = filename
            .replacingOccurrences(of: ".pdf", with: "", options: .caseInsensitive)

        if let firstPart = nameWithoutExtension.components(separatedBy: "-").first,
           firstPart.count > 3 {
            return firstPart
        }

        return nil
    }

    /// Extract merchant from email sender
    private static func extractMerchantFromSender(_ sender: String) -> String {
        let components = sender.split(separator: "@")
        guard components.count == 2 else { return "Unknown" }

        let domain = String(components[1])
        return domain.split(separator: ".").first.map { String($0).capitalized } ?? "Unknown"
    }
}
