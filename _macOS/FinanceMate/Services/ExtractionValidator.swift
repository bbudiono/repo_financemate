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

        return ExtractedTransaction(
            id: email.id,
            merchant: merchant,
            amount: amount,
            date: email.date,
            category: json["category"] as? String ?? "Other",
            items: [],
            confidence: json["confidence"] as? Double ?? 0.5,
            rawText: email.snippet,
            emailSubject: email.subject,
            emailSender: email.sender,
            gstAmount: json["gstAmount"] as? Double,
            abn: json["abn"] as? String,
            invoiceNumber: (json["invoiceNumber"] as? String) ?? "EMAIL-\(email.id.prefix(8))",
            paymentMethod: json["paymentMethod"] as? String
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
