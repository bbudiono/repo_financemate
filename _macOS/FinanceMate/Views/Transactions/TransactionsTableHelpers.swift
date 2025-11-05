import SwiftUI

/// Helper utilities for Transactions table rendering
struct TransactionsTableHelpers {

    /// Extract invoice number from transaction note
    static func extractInvoice(from note: String?) -> String {
        guard let note = note else { return "" }
        let components = note.components(separatedBy: " | ")
        for c in components {
            if c.hasPrefix("Invoice#: ") {
                return c.replacingOccurrences(of: "Invoice#: ", with: "")
            }
        }
        return ""
    }

    /// Parse note field into structured components
    static func parseNoteComponents(_ note: String) -> [(key: String, value: String)] {
        let components = note.components(separatedBy: " | ")
        return components.compactMap { component in
            let parts = component.components(separatedBy: ": ")
            guard parts.count == 2 else { return nil }
            return (key: parts[0], value: parts[1])
        }
    }

    /// Format metadata for compact display (GST + Invoice + Payment)
    static func formatMetadata(_ note: String) -> String {
        let components = parseNoteComponents(note)
        var parts: [String] = []

        if let gst = components.first(where: { $0.key == "GST" }) {
            parts.append("GST: \(gst.value)")
        }
        if let invoice = components.first(where: { $0.key == "Invoice#" }) {
            parts.append("#\(invoice.value)")
        }
        if let payment = components.first(where: { $0.key == "Payment" }) {
            parts.append(payment.value)
        }

        return parts.isEmpty ? note : parts.joined(separator: " • ")
    }

    /// Tax category color mapping
    static func taxCategoryColor(_ category: String?) -> Color {
        guard let category = category else { return .gray }
        switch category {
        case "Personal": return .blue
        case "Business": return .purple
        case "Investment": return .green
        case "Property Investment": return .orange
        default: return .gray
        }
    }
}
