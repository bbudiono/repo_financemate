import Foundation

/// Extracts standard transaction data from Gmail emails (receipts, invoices)
struct GmailStandardTransactionExtractor {

    /// Extract standard transaction (receipts, invoices)
    static func extractStandardTransaction(from email: GmailEmail) -> ExtractedTransaction? {
        // CRITICAL: Add diagnostic logging to trace extraction failures
        let merchantExtracted = GmailTransactionExtractor.extractMerchant(from: email.subject, sender: email.sender)
        let amountExtracted = GmailTransactionExtractor.extractAmount(from: email.snippet)

        NSLog("[TIER1-EXTRACT] EmailID: \(email.id.prefix(8)) | Subject: \(email.subject.prefix(40)) | Merchant: \(merchantExtracted ?? "NIL") | Amount: \(amountExtracted ?? 0.0)")

        guard let merchant = merchantExtracted,
              let amount = amountExtracted else {
            NSLog("[TIER1-FAIL] EmailID: \(email.id.prefix(8)) | Reason: merchant=\(merchantExtracted == nil ? "NIL" : "OK"), amount=\(amountExtracted == nil ? "NIL" : "OK")")
            return nil
        }

        let items = GmailTransactionExtractor.extractLineItems(from: email.snippet)
        let category = GmailTransactionExtractor.inferCategory(from: merchant)
        let gstAmount = GmailTransactionExtractor.extractGST(from: email.snippet)
        let abn = GmailTransactionExtractor.extractABN(from: email.snippet)
        let invoiceNumber = GmailTransactionExtractor.extractInvoiceNumber(from: email.snippet, emailID: email.id)
        let paymentMethod = GmailTransactionExtractor.extractPaymentMethod(from: email.snippet)
        var confidence = calculateConfidence(merchant: merchant, amount: amount, items: items)

        // BLUEPRINT Line 196: Apply field validation to regex extraction
        var totalPenalty: Double = 0.0
        var validationFailures: [String] = []

        // Validate all 7 fields
        let amountResult = FieldValidator.validateAmount(amount)
        if !amountResult.isValid {
            totalPenalty += amountResult.confidencePenalty
            validationFailures.append("Amount")
        }

        let gstResult = FieldValidator.validateGST(gst: gstAmount, amount: amount)
        if !gstResult.isValid {
            totalPenalty += gstResult.confidencePenalty
            validationFailures.append("GST")
        }

        let abnResult = FieldValidator.validateABN(abn)
        if !abnResult.isValid {
            totalPenalty += abnResult.confidencePenalty
            validationFailures.append("ABN")
        }

        let invoiceResult = FieldValidator.validateInvoiceNumber(invoiceNumber)
        if !invoiceResult.isValid {
            totalPenalty += invoiceResult.confidencePenalty
            validationFailures.append("Invoice")
        }

        let dateResult = FieldValidator.validateDate(email.date, emailDate: email.date)
        if !dateResult.isValid {
            totalPenalty += dateResult.confidencePenalty
            validationFailures.append("Date")
        }

        let categoryResult = FieldValidator.validateCategory(category)
        if !categoryResult.isValid {
            totalPenalty += categoryResult.confidencePenalty
            validationFailures.append("Category")
        }

        let paymentResult = FieldValidator.validatePaymentMethod(paymentMethod)
        if !paymentResult.isValid {
            totalPenalty += paymentResult.confidencePenalty
            validationFailures.append("Payment")
        }

        // Apply confidence penalty
        confidence = max(0.0, confidence - totalPenalty)

        // Log validation results if failures
        if !validationFailures.isEmpty {
            NSLog("[REGEX-VALIDATION] \(validationFailures.count) failures - Penalty: \(totalPenalty) - Confidence: \(confidence)")
        }

        return ExtractedTransaction(
            id: email.id,
            merchant: merchant,
            amount: amount,
            date: email.date,
            category: category,
            items: items,
            confidence: confidence,  // Adjusted confidence after validation
            rawText: email.snippet,
            emailSubject: email.subject,
            emailSender: email.sender,
            gstAmount: gstAmount,
            abn: abn,
            invoiceNumber: invoiceNumber,
            paymentMethod: paymentMethod
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
