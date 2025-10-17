import Foundation

/// Extracts invoice/receipt/transaction IDs from email text
/// MANDATORY: Always returns a value - uses email ID as fallback
struct InvoiceNumberExtractor {
    static func extract(from content: String, emailID: String) -> String {
        NSLog("[INVOICE-EXTRACT] Searching content length: \(content.count) chars")

        let patterns = [
            #"Order\s+#?:?\s?(\d{3}-\d{7}-\d{7})"#,      // Amazon: 111-2222222-3333333
            #"Transaction\s+ID:?\s+([A-Z0-9]{6,})"#,     // PayPal: Transaction ID: ABC123XYZ
            #"Payment\s+ID:?\s+([A-Z0-9]{6,})"#,         // PayPal: Payment ID: ABC123
            #"Reference:?\s+([A-Z0-9]{6,})"#,            // Generic: Reference: ABC123
            #"TAX INVOICE\s+(\d+)"#,                     // Bunnings: TAX INVOICE 123456
            #"Invoice\s?#?:?\s?([A-Z0-9-]{3,20})"#,      // Generic: Invoice #123
            #"Receipt\s?#?:?\s?([A-Z0-9-]{3,20})"#,      // Generic: Receipt #123
            #"\b([A-Z]{2,3}-\d{4,}-\d+)\b"#,             // Woolworths: WW-789012
            #"Confirmation:?\s+([A-Z0-9]{6,})"#,         // Generic: Confirmation ABC123
            #"\b(\d{10,})\b"#                            // Any 10+ digit number (fallback)
        ]

        for (index, p) in patterns.enumerated() {
            if let match = content.range(of: p, options: .regularExpression) {
                let matched = String(content[match])
                if let num = matched.components(separatedBy: CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-")).inverted).last(where: { $0.count >= 3 }) {
                    NSLog("[INVOICE-EXTRACT] Pattern \(index+1) matched: \(num)")
                    return num
                }
            }
        }

        // MANDATORY FALLBACK: Use email ID if no pattern matched
        let fallback = "EMAIL-" + emailID.prefix(8)
        NSLog("[INVOICE-EXTRACT] No patterns matched - using fallback: \(fallback)")
        return String(fallback)
    }
}

/// Extracts line items from receipts
struct LineItemExtractor {
    static func extract(from content: String) -> [GmailLineItem] {
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
}

/// Infers category from merchant name
struct MerchantCategorizer {
    static func infer(from merchant: String) -> String {
        let m = merchant.lowercased()

        // Groceries
        if ["woolworths", "coles", "aldi", "iga"].contains(where: { m.contains($0) }) { return "Groceries" }

        // Transport
        if ["uber", "taxi", "bp", "shell", "caltex", "petrol", "linkt", "toll"].contains(where: { m.contains($0) }) { return "Transport" }

        // Retail
        if ["bunnings", "kmart", "jb", "target", "big w", "officeworks", "umart", "amazon"].contains(where: { m.contains($0) }) { return "Retail" }

        // Utilities
        if ["telstra", "optus", "agl", "energy", "amigo"].contains(where: { m.contains($0) }) { return "Utilities" }

        // Finance
        if ["afterpay", "zip", "paypal", "anz", "nab", "commonwealth", "westpac"].contains(where: { m.contains($0) }) { return "Finance" }

        // Investment
        if ["binance", "coinbase", "stake", "commsec", "crypto"].contains(where: { m.contains($0) }) { return "Investment" }

        // Gaming
        if ["nintendo", "playstation", "xbox", "steam", "epic"].contains(where: { m.contains($0) }) { return "Gaming" }

        // Dining
        if ["pizza", "restaurant", "cafe", "menulog", "ubereats", "doordash", "huboox"].contains(where: { m.contains($0) }) { return "Dining" }

        // Sports & Fitness
        if ["gym", "fitness", "smai", "biotek", "protein", "supplements"].contains(where: { m.contains($0) }) { return "Health & Fitness" }

        // Entertainment
        if ["apple", "google play", "itunes"].contains(where: { m.contains($0) }) { return "Entertainment" }

        // Government
        if ["government", "council", "goldcoast", ".gov"].contains(where: { m.contains($0) }) { return "Government" }

        return "Other"
    }
}
