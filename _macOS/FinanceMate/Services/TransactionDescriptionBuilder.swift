import Foundation

/**
 * Purpose: Build rich transaction descriptions from extracted email data
 * BLUEPRINT Line 211: Properly extracted descriptions with real merchant data
 * Complexity: Low - String formatting service
 * Last Updated: 2025-10-09
 */

/// Service for building comprehensive transaction descriptions with all available context
class TransactionDescriptionBuilder {

    /// Builds a comprehensive transaction description with all available data
    /// - Parameter transaction: Extracted transaction from email
    /// - Returns: Formatted description string
    static func buildDescription(from transaction: ExtractedTransaction) -> String {
        var components: [String] = []

        // 1. Core merchant name (always present)
        components.append(transaction.merchant)

        // 2. Invoice/Receipt number if available
        if let invoice = transaction.invoiceNumber, !invoice.isEmpty {
            components.append("Invoice #\(invoice)")
        }

        // 3. GST amount if available (Australian tax compliance)
        if let gst = transaction.gstAmount, gst > 0 {
            components.append("GST: $\(String(format: "%.2f", gst))")
        }

        // 4. Payment method if available
        if let payment = transaction.paymentMethod, !payment.isEmpty {
            components.append("via \(payment)")
        }

        // 5. Line item count for multi-item purchases
        if transaction.items.count > 1 {
            components.append("(\(transaction.items.count) items)")
        }

        // 6. ABN if available (business verification)
        if let abn = transaction.abn, !abn.isEmpty {
            components.append("ABN: \(formatABN(abn))")
        }

        return components.joined(separator: " - ")
    }

    /// Builds a condensed description for compact UI views
    /// - Parameter transaction: Extracted transaction from email
    /// - Returns: Short formatted description
    static func buildShortDescription(from transaction: ExtractedTransaction) -> String {
        var result = transaction.merchant
        if let invoice = transaction.invoiceNumber, !invoice.isEmpty {
            result += " #\(invoice)"
        }
        return result
    }

    /// Formats ABN with proper spacing (11 digits → 2-3-3-3)
    /// - Parameter abn: Raw ABN string (may contain spaces, hyphens)
    /// - Returns: Formatted ABN string
    private static func formatABN(_ abn: String) -> String {
        let digits = abn.filter { $0.isNumber }
        guard digits.count == 11 else { return abn }

        let d = Array(digits)
        return "\(d[0])\(d[1]) \(d[2])\(d[3])\(d[4]) \(d[5])\(d[6])\(d[7]) \(d[8])\(d[9])\(d[10])"
    }
}

// MARK: - ExtractedTransaction Extension

extension ExtractedTransaction {
    /// Formatted description using TransactionDescriptionBuilder
    var formattedDescription: String {
        TransactionDescriptionBuilder.buildDescription(from: self)
    }

    /// Short description for compact UI views
    var shortDescription: String {
        TransactionDescriptionBuilder.buildShortDescription(from: self)
    }
}
