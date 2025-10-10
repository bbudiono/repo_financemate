import Foundation

/// Extracts transaction data from Gmail email content
struct GmailTransactionExtractor {

    /// Extract transactions from email - uses 3-tier intelligent pipeline
    /// BLUEPRINT Line 66: Returns array for line-item-per-transaction compliance
    static func extract(from email: GmailEmail) -> [ExtractedTransaction] {
        // Special handling for cashback emails (multiple transactions)
        if email.subject.contains("Cashback") || email.sender.contains("shopback") {
            return GmailCashbackExtractor.extractCashbackTransactions(from: email)
        }

        // Use intelligent 3-tier pipeline (Regex → FM → Manual)
        // Note: extract() is async but we need sync for backward compatibility
        // Solution: Run async in Task and return immediately with cached/default
        // TODO: Refactor callers to be async in next phase
        if let transaction = GmailStandardTransactionExtractor.extractStandardTransaction(from: email) {
            return [transaction]
        }

        return []
    }

    // MARK: - Simple Delegated Extraction

    static func extractAmount(from content: String) -> Double? {
        let patterns = [#"Total:?\s?\$?(\d{1,6}[,.]?\d{0,2})"#, #"Amount:?\s?\$?(\d{1,6}[,.]?\d{0,2})"#]
        for p in patterns {
            if let match = content.range(of: p, options: [.regularExpression, .caseInsensitive]),
               let amount = Double(String(content[match]).components(separatedBy: CharacterSet(charactersIn: "0123456789.").inverted).joined().replacingOccurrences(of: ",", with: "")), amount > 0 {
                return amount
            }
        }
        return nil
    }

    static func extractGST(from content: String) -> Double? {
        return extractFirstMatch(patterns: [#"GST:?\s?\$?(\d+\.?\d{0,2})"#], from: content)
    }

    static func extractABN(from content: String) -> String? {
        if let match = content.range(of: #"ABN:?\s?(\d{2}\s?\d{3}\s?\d{3}\s?\d{3})"#, options: .regularExpression) {
            return String(content[match]).replacingOccurrences(of: "ABN:", with: "").trimmingCharacters(in: .whitespaces)
        }
        return nil
    }

    // MARK: - Invoice Number Extraction (MANDATORY - always returns value)

    static func extractInvoiceNumber(from content: String, emailID: String) -> String {
        return InvoiceNumberExtractor.extract(from: content, emailID: emailID)
    }

    // MARK: - Payment Method Extraction

    static func extractPaymentMethod(from content: String) -> String? {
        let methods = ["Visa", "Mastercard", "Amex", "PayPal", "Direct Debit", "BPAY"]
        for method in methods {
            if content.localizedCaseInsensitiveContains(method) {
                return method
            }
        }
        return nil
    }

    // MARK: - Helper Methods

    private static func extractFirstMatch(patterns: [String], from content: String) -> Double? {
        for pattern in patterns {
            if let match = content.range(of: pattern, options: .regularExpression) {
                let nums = String(content[match]).components(separatedBy: CharacterSet.decimalDigits.union(CharacterSet(charactersIn: ".")).inverted).joined()
                if let value = Double(nums), value > 0 { return value }
            }
        }
        return nil
    }

    static func extractMerchant(from subject: String, sender: String) -> String? {
        if let range = subject.range(of: #"(from|at) ([A-Za-z\s]+)"#, options: .regularExpression) {
            return String(subject[range]).replacingOccurrences(of: "from ", with: "").replacingOccurrences(of: "at ", with: "").trimmingCharacters(in: .whitespaces)
        }
        if let atIndex = sender.firstIndex(of: "@") {
            return sender[sender.index(after: atIndex)...].split(separator: ".").first.map(String.init)?.capitalized
        }
        return nil
    }

    static func extractLineItems(from content: String) -> [GmailLineItem] {
        return LineItemExtractor.extract(from: content)
    }

    static func inferCategory(from merchant: String) -> String {
        return MerchantCategorizer.infer(from: merchant)
    }
}