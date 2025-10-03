import Foundation

/// Extracts cashback transaction data from Gmail emails (ShopBack, etc.)
struct GmailCashbackExtractor {

    /// Extract ShopBack cashback confirmation - creates SEPARATE transaction per line item
    /// BLUEPRINT Line 66: "Every line item must be created as a distinct record"
    static func extractCashbackTransactions(from email: GmailEmail) -> [ExtractedTransaction] {
        let items = extractCashbackItems(from: email.snippet)
        guard !items.isEmpty else { return [] }

        // Create SEPARATE transaction for each line item (BLUEPRINT Line 66 compliance)
        return items.enumerated().map { (index, item) in
            ExtractedTransaction(
                id: "\(email.id)-item-\(index)",
                merchant: extractMerchantName(from: item.description),
                amount: item.price,
                date: email.date,
                category: "Purchase",
                items: [item], // Single item per transaction
                confidence: 0.9,
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

    // Helper to extract merchant name from description
    private static func extractMerchantName(from description: String) -> String {
        // Description format: "eBay - Purchase: $99.71 (Cashback: $1.30)"
        if let dashRange = description.range(of: " - ") {
            return String(description[..<dashRange.lowerBound])
        }
        return description
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
