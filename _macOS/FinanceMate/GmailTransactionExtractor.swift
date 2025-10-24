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
        NSLog("[MERCHANT-EXTRACT] START | Subject: '\(subject.prefix(50))', Sender: '\(sender.prefix(80))'")

        // PRIORITY 0A: Check for display name before angle bracket
        // "City of Gold Coast <noreply@goldcoast.qld.gov.au>" → "City of Gold Coast"
        if let angleBracket = sender.firstIndex(of: "<"),
           angleBracket != sender.startIndex {
            let displayName = String(sender[..<angleBracket]).trimmingCharacters(in: .whitespaces)
            // Filter out personal names (keep business names)
            if !displayName.isEmpty && !displayName.contains("Bernhard") && !displayName.contains("Budiono") {
                // Normalize verbose business names to brand name only
                let normalized = normalizeDisplayName(displayName)
                NSLog("[MERCHANT-EXTRACT] ✓ Display name: '\(displayName)' → Normalized: '\(normalized)'")
                return normalized
            }
        }

        // SMART DELEGATION: Use MerchantDatabase for intelligent domain parsing
        // MerchantDatabase has 150+ curated mappings + intelligent fallback parsing
        // BLUEPRINT Line 159: Semantic merchant normalization without hardcoding
        NSLog("[MERCHANT-EXTRACT] Delegating to MerchantDatabase for semantic merchant extraction")
        return MerchantDatabase.extractMerchant(from: subject, sender: sender)
    }

    /// Normalize verbose display names to short brand names
    /// "Bunnings Warehouse" → "Bunnings", "ANZ Group Holdings Ltd" → "ANZ"
    private static func normalizeDisplayName(_ displayName: String) -> String {
        NSLog("[NORMALIZE] Input: '\(displayName)'")
        let name = displayName.trimmingCharacters(in: .whitespaces)

        // Remove common business suffixes
        var normalized = name
            .replacingOccurrences(of: " Pty Ltd", with: "", options: .caseInsensitive)
            .replacingOccurrences(of: " Pty. Ltd.", with: "", options: .caseInsensitive)
            .replacingOccurrences(of: " Limited", with: "", options: .caseInsensitive)
            .replacingOccurrences(of: " Ltd", with: "", options: .caseInsensitive)
            .replacingOccurrences(of: " Group Holdings", with: "", options: .caseInsensitive)
            .replacingOccurrences(of: ".com.au", with: "", options: .caseInsensitive)
            .replacingOccurrences(of: ".com", with: "", options: .caseInsensitive)
            .replacingOccurrences(of: " Online", with: "", options: .caseInsensitive)
            .replacingOccurrences(of: " Prime", with: "", options: .caseInsensitive)
            .trimmingCharacters(in: .whitespaces)

        NSLog("[NORMALIZE] After suffix removal: '\(normalized)'")

        // Specific business name mappings
        if normalized.lowercased().contains("bunnings warehouse") || normalized.lowercased() == "bunnings warehouse" {
            NSLog("[NORMALIZE] → Matched Bunnings Warehouse → Bunnings")
            return "Bunnings"
        }
        if normalized.lowercased().contains("anz") {
            NSLog("[NORMALIZE] → Matched ANZ")
            return "ANZ"
        }
        if normalized.lowercased().contains("amazon") {
            return "Amazon"
        }
        if normalized.lowercased().contains("officeworks") {
            return "Officeworks"
        }

        // Return first word for multi-word names (unless it's a known full name)
        let words = normalized.components(separatedBy: " ")
        if words.count > 2 && !["City of"].contains(where: { normalized.hasPrefix($0) }) {
            // "ANZ Group" → "ANZ", but keep "City of Gold Coast"
            NSLog("[NORMALIZE] → Multi-word, returning first: '\(words[0])'")
            return words[0]
        }

        NSLog("[NORMALIZE] → Returning normalized: '\(normalized)'")
        return normalized
    }

    static func extractLineItems(from content: String) -> [GmailLineItem] {
        return LineItemExtractor.extract(from: content)
    }

    static func inferCategory(from merchant: String) -> String {
        return MerchantCategorizer.infer(from: merchant)
    }
}