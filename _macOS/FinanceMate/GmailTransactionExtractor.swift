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
        NSLog("[MERCHANT-EXTRACT] Subject: '\(subject.prefix(50))', Sender: '\(sender.prefix(80))'")

        // PRIORITY 0A: Check for display name before angle bracket
        // "City of Gold Coast <noreply@goldcoast.qld.gov.au>" → "City of Gold Coast"
        if let angleBracket = sender.firstIndex(of: "<"),
           angleBracket != sender.startIndex {
            let displayName = String(sender[..<angleBracket]).trimmingCharacters(in: .whitespaces)
            // Filter out personal names (keep business names)
            if !displayName.isEmpty && !displayName.contains("Bernhard") && !displayName.contains("Budiono") {
                // Normalize verbose business names to brand name only
                let normalized = normalizeDisplayName(displayName)
                NSLog("[MERCHANT-EXTRACT] → Display name: '\(displayName)' → Normalized: '\(normalized)'")
                return normalized
            }
        }

        // PRIORITY 0B: Check for business name in email username (before @)
        // "OurSage@domain.com" → "OurSage" (business name)
        // "noreply@domain.com" → Skip to domain parsing
        if let atIndex = sender.firstIndex(of: "@") {
            let username = String(sender[..<atIndex]).trimmingCharacters(in: .whitespaces)
            let skipUsernames = ["noreply", "no-reply", "donotreply", "do_not_reply", "info", "support", "service", "hello", "contact", "billing", "receipts", "orders"]

            // If username looks like a business name (not generic), use it
            if !skipUsernames.contains(username.lowercased()) && username.count > 2 {
                // Normalize: "OurSage" → "Oursage"
                return username.capitalized
            }
        }

        // FIX: ALWAYS use email sender domain as merchant - it's the authoritative source
        // Subject lines can mention other merchants (e.g., "Klook booking for Bunnings")
        // but the SENDER is who actually sent the receipt/invoice
        if let atIndex = sender.firstIndex(of: "@") {
            let domain = String(sender[sender.index(after: atIndex)...])
                .replacingOccurrences(of: ">", with: "")  // Remove closing bracket if present
                .trimmingCharacters(in: .whitespaces)

            // PRIORITY 1: Check for known brand domains (handles subdomains correctly)
            // Finance & Investment
            if domain.contains("binance.com") { return "Binance" }
            if domain.contains("afterpay.com") { return "Afterpay" }
            if domain.contains("zip.co") { return "Zip" }
            if domain.contains("paypal.com") { return "PayPal" }
            if domain.contains("anz.com") { return "Anz" }
            if domain.contains("nab.com") { return "NAB" }
            if domain.contains("commbank.com") { return "CommBank" }
            if domain.contains("westpac.com") { return "Westpac" }

            // Retail
            if domain.contains("bunnings.com") { return "Bunnings" }
            if domain.contains("woolworths.com") { return "Woolworths" }
            if domain.contains("coles.com") { return "Coles" }
            if domain.contains("kmart.com") { return "Kmart" }
            if domain.contains("target.com") { return "Target" }
            if domain.contains("officeworks.com") { return "Officeworks" }
            if domain.contains("umart.com") { return "Umart" }

            // Gaming & Entertainment
            if domain.contains("nintendo.com") { return "Nintendo" }
            if domain.contains("playstation.com") { return "PlayStation" }
            if domain.contains("xbox.com") { return "Xbox" }
            if domain.contains("steam") { return "Steam" }
            if domain.contains("apple.com") { return "Apple" }

            // Marketplaces & Intermediaries
            if domain.contains("klook.com") { return "Klook" }
            if domain.contains("clevarea.com") { return "Clevarea" }
            if domain.contains("huboox.com") { return "Huboox" }

            // Sports & Fitness
            if domain.contains("gymandfitness.com") { return "Gym and Fitness" }
            if domain.contains("smai.com") { return "Smai" }

            // Utilities
            if domain.contains("amigoenergy.com") { return "Amigoenergy" }
            if domain.contains("agl.com") { return "AGL" }
            if domain.contains("origin") { return "Origin" }

            // Dining
            if domain.contains("ubereats.com") { return "Uber Eats" }
            if domain.contains("menulog.com") { return "Menulog" }
            if domain.contains("doordash.com") { return "DoorDash" }

            // Transport
            if domain.contains("linkt.com") { return "Linkt" }
            if domain.contains("uber.com") { return "Uber" }

            // Supplements & Health
            if domain.contains("bioteksupps.com") { return "Biotek" }

            // E-commerce
            if domain.contains("amazon.com") { return "Amazon" }

            // Government (.gov.au domains)
            if domain.contains(".gov.au") || domain.contains(".qld.gov") {
                // Extract department/agency name from domain (e.g., defence.gov.au → "Defence")
                let parts = domain.components(separatedBy: ".")
                NSLog("[MERCHANT-EXTRACT] GOV DOMAIN: '\(domain)' Parts: \(parts)")

                // Get the first meaningful part (skip www, mail, noreply)
                if let dept = parts.first, !["www", "mail", "noreply", "no-reply"].contains(dept.lowercased()) {
                    // Specific government entities - return full proper names
                    switch dept.lowercased() {
                    case "defence":
                        NSLog("[MERCHANT-EXTRACT] → Matched defence → Department of Defence")
                        return "Department of Defence"
                    case "goldcoast": return "Gold Coast Council"
                    case "ato": return "Australian Taxation Office"
                    case "centrelink": return "Centrelink"
                    case "qld": return "Queensland Government"
                    case "nsw": return "New South Wales Government"
                    case "vic": return "Victoria Government"
                    case "wa": return "Western Australia Government"
                    case "sa": return "South Australia Government"
                    case "tas": return "Tasmania Government"
                    case "act": return "Australian Capital Territory"
                    case "nt": return "Northern Territory"
                    default:
                        // Capitalize generic government entity names
                        return dept.capitalized + " Government"
                    }
                }

                // Fallback for unusual structures
                return "Government"
            }

            // PRIORITY 2: Parse domain intelligently
            let parts = domain.components(separatedBy: ".")

            // Skip common prefixes and suffixes
            let skipPrefixes = ["noreply", "no-reply", "info", "mail", "hello", "support", "receipts", "orders", "donotreply", "do_not_reply", "service", "accounts", "mgdirectmail", "digital", "updates", "contact", "notify", "email"]
            let skipSuffixes = ["com", "au", "co", "net", "org", "io", "gov"]

            // Find first meaningful part
            for part in parts where !skipPrefixes.contains(part.lowercased()) && !skipSuffixes.contains(part.lowercased()) && part.count > 2 {
                // Map known merchant variations
                switch part.lowercased() {
                case "gymandfitness": return "Gym and Fitness"
                case "clevarea": return "Clevarea"
                case "tryhuboox", "huboox": return "Huboox"
                case "activepipe": return "ActivePipe"
                case "loanmarket": return "Loan Market"
                default: return part.capitalized
                }
            }

            // Fallback: Use first non-skipped part
            let fallback = parts.first?.capitalized ?? "Unknown"
            NSLog("[MERCHANT-EXTRACT] → Fallback: '\(fallback)' from domain '\(domain)'")
            return fallback
        }

        NSLog("[MERCHANT-EXTRACT] → Returning nil (no merchant found)")
        return nil
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