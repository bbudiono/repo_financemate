import Foundation

/// Extracts transaction data from Gmail email content
struct GmailTransactionExtractor {

    /// Extract transactions from email - returns array for BLUEPRINT Line 66 compliance
    static func extract(from email: GmailEmail) -> [ExtractedTransaction] {
        // Detect email type and use appropriate extraction
        if email.subject.contains("Cashback") || email.sender.contains("shopback") {
            // Returns multiple transactions (one per line item)
            return GmailCashbackExtractor.extractCashbackTransactions(from: email)
        }

        // Default extraction for other emails (single transaction)
        if let transaction = GmailStandardTransactionExtractor.extractStandardTransaction(from: email) {
            return [transaction]
        }

        return []
    }

    // MARK: - Amount Extraction

    static func extractAmount(from content: String) -> Double? {
        let patterns = [
            #"Total:?\s?\$?(\d{1,6}[,.]?\d{0,2})"#,
            #"Amount:?\s?\$?(\d{1,6}[,.]?\d{0,2})"#,
            #"(?:Incl|Inc)\s+GST:?\s?\$?(\d{1,6}[,.]?\d{0,2})"#,
            #"Charged\s+\$?(\d{1,6}[,.]?\d{0,2})"#
        ]

        for pattern in patterns {
            if let match = content.range(of: pattern, options: [.regularExpression, .caseInsensitive]) {
                let text = String(content[match])
                let nums = text.components(separatedBy: CharacterSet(charactersIn: "0123456789.,").inverted).joined()
                let clean = nums.replacingOccurrences(of: ",", with: "")
                if let amount = Double(clean), amount > 0 { return amount }
            }
        }
        return nil
    }

    // MARK: - GST Extraction

    static func extractGST(from content: String) -> Double? {
        let patterns = [
            #"GST:?\s?\$?(\d+\.?\d{0,2})"#,
            #"Tax:?\s?\$?(\d+\.?\d{0,2})"#
        ]
        return extractFirstMatch(patterns: patterns, from: content)
    }

    // MARK: - ABN Extraction

    static func extractABN(from content: String) -> String? {
        let pattern = #"ABN:?\s?(\d{2}\s?\d{3}\s?\d{3}\s?\d{3})"#
        if let match = content.range(of: pattern, options: .regularExpression) {
            return String(content[match]).replacingOccurrences(of: "ABN:", with: "").trimmingCharacters(in: .whitespaces)
        }
        return nil
    }

    // MARK: - Invoice Number Extraction

    static func extractInvoiceNumber(from content: String) -> String? {
        let patterns = [
            #"Invoice\s?#:?\s?([A-Z0-9-]+)"#,
            #"Receipt\s?#:?\s?([A-Z0-9-]+)"#,
            #"Order\s?#:?\s?([A-Z0-9-]+)"#
        ]
        for pattern in patterns {
            if let match = content.range(of: pattern, options: .regularExpression) {
                return String(content[match]).components(separatedBy: ":").last?.trimmingCharacters(in: .whitespaces)
            }
        }
        return nil
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
        var items: [GmailLineItem] = []
        guard let regex = try? NSRegularExpression(pattern: #"(\d+)x?\s+(.+?)\s+\$(\d+\.?\d{0,2})"#) else { return items }
        regex.enumerateMatches(in: content, range: NSRange(content.startIndex..., in: content)) { match, _, _ in
            guard let match = match, match.numberOfRanges >= 4,
                  let qtyRange = Range(match.range(at: 1), in: content),
                  let descRange = Range(match.range(at: 2), in: content),
                  let priceRange = Range(match.range(at: 3), in: content),
                  let qty = Int(content[qtyRange]),
                  let price = Double(content[priceRange]) else { return }
            items.append(GmailLineItem(description: String(content[descRange]).trimmingCharacters(in: .whitespaces), quantity: qty, price: price))
        }
        return items
    }

    static func inferCategory(from merchant: String) -> String {
        let m = merchant.lowercased()
        if ["woolworths", "coles", "aldi", "iga"].contains(where: { m.contains($0) }) { return "Groceries" }
        if ["uber", "taxi", "bp", "shell"].contains(where: { m.contains($0) }) { return "Transport" }
        if ["restaurant", "cafe", "mcdonald"].contains(where: { m.contains($0) }) { return "Dining" }
        if ["telstra", "optus", "agl"].contains(where: { m.contains($0) }) { return "Utilities" }
        if ["bunnings", "kmart", "jb hi-fi"].contains(where: { m.contains($0) }) { return "Retail" }
        return "Other"
    }
}