import Foundation

/// Validates and parses Foundation Models JSON responses
struct ExtractionValidator {

    /// Parse JSON response from Foundation Models
    static func parseJSON(_ jsonString: String, email: GmailEmail) throws -> ExtractedTransaction {
        guard let data = jsonString.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw ExtractionError.jsonParsingFailed(jsonString)
        }

        guard let merchant = json["merchant"] as? String,
              let amount = json["amount"] as? Double else {
            throw ExtractionError.missingRequiredFields
        }

        // Extract fields
        let category = json["category"] as? String ?? "Other"
        let gstAmount = json["gstAmount"] as? Double
        let abn = json["abn"] as? String
        let invoiceNumber = (json["invoiceNumber"] as? String) ?? "EMAIL-\(email.id.prefix(8))"
        let paymentMethod = json["paymentMethod"] as? String
        var confidence = json["confidence"] as? Double ?? 0.5
        let transactionDate = email.date  // Use email date as transaction date

        // BLUEPRINT Line 196: Apply field validation
        var totalPenalty: Double = 0.0
        var validationFailures: [String] = []

        // Validate each field (7 validation rules)
        let amountResult = FieldValidator.validateAmount(amount)
        if !amountResult.isValid {
            totalPenalty += amountResult.confidencePenalty
            validationFailures.append("Amount: \(amountResult.reason ?? "Invalid")")
        }

        let gstResult = FieldValidator.validateGST(gst: gstAmount, amount: amount)
        if !gstResult.isValid {
            totalPenalty += gstResult.confidencePenalty
            validationFailures.append("GST: \(gstResult.reason ?? "Invalid")")
        }

        let abnResult = FieldValidator.validateABN(abn)
        if !abnResult.isValid {
            totalPenalty += abnResult.confidencePenalty
            validationFailures.append("ABN: \(abnResult.reason ?? "Invalid")")
        }

        let invoiceResult = FieldValidator.validateInvoiceNumber(invoiceNumber)
        if !invoiceResult.isValid {
            totalPenalty += invoiceResult.confidencePenalty
            validationFailures.append("Invoice: \(invoiceResult.reason ?? "Invalid")")
        }

        let dateResult = FieldValidator.validateDate(transactionDate, emailDate: email.date)
        if !dateResult.isValid {
            totalPenalty += dateResult.confidencePenalty
            validationFailures.append("Date: \(dateResult.reason ?? "Invalid")")
        }

        let categoryResult = FieldValidator.validateCategory(category)
        if !categoryResult.isValid {
            totalPenalty += categoryResult.confidencePenalty
            validationFailures.append("Category: \(categoryResult.reason ?? "Invalid")")
        }

        let paymentResult = FieldValidator.validatePaymentMethod(paymentMethod)
        if !paymentResult.isValid {
            totalPenalty += paymentResult.confidencePenalty
            validationFailures.append("Payment: \(paymentResult.reason ?? "Invalid")")
        }

        // Apply confidence penalty
        confidence = max(0.0, confidence - totalPenalty)

        // Log validation results
        if !validationFailures.isEmpty {
            NSLog("[EXTRACT-VALIDATION] \(validationFailures.count) failures - Penalty: \(totalPenalty) - New confidence: \(confidence)")
            for failure in validationFailures {
                NSLog("[EXTRACT-VALIDATION]   - \(failure)")
            }
        }

        return ExtractedTransaction(
            id: email.id,
            merchant: merchant,
            amount: amount,
            date: transactionDate,
            category: category,
            items: [],
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

    /// Strip markdown formatting from LLM response
    static func stripMarkdown(_ text: String) -> String {
        var cleaned = text
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        if let start = cleaned.firstIndex(of: "{"),
           let end = cleaned.lastIndex(of: "}") {
            cleaned = String(cleaned[start...end])
        }

        return cleaned
    }
}
