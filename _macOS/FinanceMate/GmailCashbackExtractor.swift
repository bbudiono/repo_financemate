import Foundation

/// Extracts cashback transaction data from Gmail emails (ShopBack, etc.)
struct GmailCashbackExtractor {

    /// Extract ShopBack cashback confirmation - creates SEPARATE transaction per line item
    /// BLUEPRINT Line 66: "Every line item must be created as a distinct record"
    static func extractCashbackTransactions(from email: GmailEmail) -> [ExtractedTransaction] {
        let items = extractCashbackItems(from: email.snippet)
        guard !items.isEmpty else { return [] }

        // Extract merchant from EMAIL DOMAIN (not content) - user feedback
        let merchantFromDomain = extractDomainMerchant(from: email.sender)

        // Create SEPARATE transaction for each line item (BLUEPRINT Line 66 compliance)
        return items.enumerated().map { (index, item) in
            ExtractedTransaction(
                id: "\(email.id)-item-\(index)",
                merchant: merchantFromDomain,
                amount: item.price,
                date: email.date,
                category: "Purchase",
                items: [item], // Single item per transaction
                confidence: 0.5, // Lower confidence - user should review
                rawText: email.snippet,
                emailSubject: email.subject,
                emailSender: email.sender,
                gstAmount: nil,
                abn: nil,
                invoiceNumber: nil,
                paymentMethod: "Cashback"
            )
        }
    }

    // Extract merchant from email domain: "hello@info.shopback.com.au" → "ShopBack"
    private static func extractDomainMerchant(from sender: String) -> String {
        // Extract domain from email address
        guard let atIndex = sender.firstIndex(of: "@") else { return sender }
        let domain = String(sender[sender.index(after: atIndex)...])

        // Clean up domain: "info.shopback.com.au" → "shopback"
        let parts = domain.components(separatedBy: ".")

        // Find the meaningful part (skip "info", "mail", "noreply", etc.)
        let skipPrefixes = ["info", "mail", "noreply", "hello", "no-reply", "support"]
        for part in parts {
            if !skipPrefixes.contains(part.lowercased()) && part.lowercased() != "com" && part.lowercased() != "au" {
                return part.capitalized
            }
        }

        // Fallback to first part
        return parts.first?.capitalized ?? sender
    }

    static func extractCashbackItems(from content: String) -> [GmailLineItem] {
        var items: [GmailLineItem] = []

        // Pattern: "From Merchant\n$X.XX  Eligible Purchase Amount $XXX.XX"
        // Fixed: Match merchant BEFORE cashback amount (matches actual ShopBack email structure)
        let pattern = #"From\s+([A-Za-z\s]+?)\s*\n\s*\$(\d+\.\d{2})\s+Eligible\s+Purchase\s+Amount\s+\$([\d,]+\.\d{2})"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive, .dotMatchesLineSeparators]) else { return items }

        regex.enumerateMatches(in: content, range: NSRange(content.startIndex..., in: content)) { match, _, _ in
            guard let match = match, match.numberOfRanges >= 4,
                  let merchantRange = Range(match.range(at: 1), in: content),
                  let cashbackRange = Range(match.range(at: 2), in: content),
                  let purchaseRange = Range(match.range(at: 3), in: content),
                  let cashbackAmount = Double(content[cashbackRange]),
                  let purchaseAmount = Double(String(content[purchaseRange]).replacingOccurrences(of: ",", with: "")) else { return }

            let merchant = String(content[merchantRange]).trimmingCharacters(in: .whitespaces)
            items.append(GmailLineItem(
                description: "\(merchant) - Purchase: $\(String(format: "%.2f", purchaseAmount)) (Cashback: $\(String(format: "%.2f", cashbackAmount)))",
                quantity: 1,
                price: purchaseAmount
            ))
        }

        return items
    }
}
