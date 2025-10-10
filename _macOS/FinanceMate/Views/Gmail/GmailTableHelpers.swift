import SwiftUI

/// Helper utilities for Gmail table rendering
/// Extracted to reduce GmailReceiptsTableView complexity
struct GmailTableHelpers {

    /// Returns color for transaction category badge
    static func categoryColor(_ category: String) -> Color {
        switch category.lowercased() {
        case "groceries": return .blue
        case "transport": return .purple
        case "utilities": return .orange
        case "retail", "hardware": return .green
        case "dining": return .red
        case "purchase": return .cyan
        default: return .gray
        }
    }

    /// Extracts domain from email address
    static func extractDomain(from email: String) -> String {
        let components = email.split(separator: "@")
        return components.count > 1 ? String(components[1]) : email
    }

    /// Returns traffic light color for confidence score
    static func confidenceColor(_ confidence: Double) -> Color {
        switch confidence {
        case 0.8...: return .green
        case 0.5..<0.8: return .orange
        default: return .red
        }
    }

    /// Builds context menu content for table selection
    @ViewBuilder
    static func contextMenu(
        for ids: Set<ExtractedTransaction.ID>,
        viewModel: GmailViewModel,
        onImport: @escaping () -> Void
    ) -> some View {
        if ids.count == 1, let id = ids.first {
            Button("Import") {
                if let tx = viewModel.extractedTransactions.first(where: { $0.id == id }) {
                    viewModel.createTransaction(from: tx)
                }
            }
            Button("Delete") {
                viewModel.extractedTransactions.removeAll { $0.id == id }
            }
        } else if ids.count > 1 {
            Button("Import \(ids.count) Selected") { onImport() }
            Button("Delete \(ids.count) Selected") {
                viewModel.extractedTransactions.removeAll { ids.contains($0.id) }
                viewModel.selectedIDs.removeAll()
            }
        }
    }
}
