import Foundation

/// Parser for extracting line items from OCR text
/// Handles City of Gold Coast, Bunnings, and generic invoice formats
struct PDFLineItemParser {

    /// Parse line items from OCR-extracted text
    /// - Parameter text: Raw OCR text from PDF
    /// - Returns: Array of parsed line items
    func parse(from text: String) -> [PDFLineItem] {
        var lineItems: [PDFLineItem] = []
        let lines = text.components(separatedBy: .newlines)

        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)

            // Try each pattern in priority order
            if let lineItem = parseBunningsFormat(trimmedLine) {
                lineItems.append(lineItem)
            } else if let lineItem = parseGoldCoastFormat(trimmedLine) {
                lineItems.append(lineItem)
            } else if let lineItem = parseSimpleFormat(trimmedLine) {
                lineItems.append(lineItem)
            }
        }

        return lineItems
    }

    // MARK: - Format Parsers

    /// Bunnings format: "Item ... $71.00 ... GST $6.45 ... Qty 1"
    private func parseBunningsFormat(_ text: String) -> PDFLineItem? {
        let pattern = #"^(.+?)\s+\$?([\d,]+\.?\d*)\s+.*?GST\s*\$?([\d,]+\.?\d*)\s+.*?Qty\s*(\d+)$"#
        return parseWithPattern(text, pattern: pattern, hasQuantity: true)
    }

    /// City of Gold Coast format: "Description ... $500.00 ... GST $0.00"
    private func parseGoldCoastFormat(_ text: String) -> PDFLineItem? {
        let pattern = #"^(.+?)\s+\$?([\d,]+\.?\d*)\s+.*?GST\s*\$?([\d,]+\.?\d*)$"#
        return parseWithPattern(text, pattern: pattern, hasQuantity: false)
    }

    /// Simple format: "Description $100.00"
    private func parseSimpleFormat(_ text: String) -> PDFLineItem? {
        let pattern = #"^(.+?)\s+\$?([\d,]+\.?\d*)$"#
        return parseWithPattern(text, pattern: pattern, hasQuantity: false, hasGST: false)
    }

    // MARK: - Pattern Matching

    /// Parse line item using regex pattern
    private func parseWithPattern(_ text: String, pattern: String, hasQuantity: Bool, hasGST: Bool = true) -> PDFLineItem? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else {
            return nil
        }

        let range = NSRange(text.startIndex..., in: text)
        guard let match = regex.firstMatch(in: text, options: [], range: range) else {
            return nil
        }

        let description = extractGroup(1, from: match, in: text) ?? ""
        guard let amount = extractAmount(group: 2, from: match, in: text) else { return nil }

        let gst = hasGST ? extractAmount(group: 3, from: match, in: text) ?? 0.0 : 0.0
        let quantity = hasQuantity ? extractQuantity(group: 4, from: match, in: text) : 1

        return PDFLineItem(
            description: description.trimmingCharacters(in: .whitespaces),
            amount: amount,
            gst: gst,
            quantity: quantity,
            rawText: text
        )
    }

    // MARK: - Extraction Helpers

    private func extractGroup(_ groupIndex: Int, from match: NSTextCheckingResult, in text: String) -> String? {
        guard let range = Range(match.range(at: groupIndex), in: text) else { return nil }
        return String(text[range])
    }

    private func extractAmount(group: Int, from match: NSTextCheckingResult, in text: String) -> Double? {
        guard let amountString = extractGroup(group, from: match, in: text) else { return nil }
        return Double(amountString.replacingOccurrences(of: ",", with: ""))
    }

    private func extractQuantity(group: Int, from match: NSTextCheckingResult, in text: String) -> Int {
        guard let qtyString = extractGroup(group, from: match, in: text),
              let qty = Int(qtyString) else { return 1 }
        return qty
    }
}
