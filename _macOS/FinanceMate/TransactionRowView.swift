import SwiftUI
import CoreData

/// Individual transaction row display component
/// Handles visual presentation of transaction data with badges and formatting
struct TransactionRowView: View {
    let transaction: Transaction

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.itemDescription)
                    .font(.headline)
                HStack(spacing: 8) {
                    // Source badge
                    if transaction.source == "gmail" {
                        Image(systemName: "envelope.fill")
                            .font(.caption2)
                            .foregroundColor(.blue)
                    }
                    // Tax category
                    Text(transaction.taxCategory)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(taxCategoryColor(transaction.taxCategory).opacity(0.2))
                        .foregroundColor(taxCategoryColor(transaction.taxCategory))
                        .cornerRadius(4)
                    // Date
                    Text(transaction.date, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Text(String(format: "$%.2f", transaction.amount))
                .font(.headline)
                .foregroundColor(transaction.amount >= 0 ? .green : .red)
        }
    }

    private func taxCategoryColor(_ category: String) -> Color {
        switch category {
        case "Personal": return .blue
        case "Business": return .purple
        case "Investment": return .green
        case "Property Investment": return .orange
        default: return .gray
        }
    }
}