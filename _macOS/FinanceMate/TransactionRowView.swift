import SwiftUI
import CoreData

/// Individual transaction row display component
/// Handles visual presentation of transaction data with badges and formatting
/// BLUEPRINT Line 133: Includes visual indicator for split transactions
struct TransactionRowView: View {
    let transaction: Transaction

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(transaction.itemDescription)
                        .font(.headline)

                    // BLUEPRINT Line 133: Split indicator badge
                    if transaction.hasSplitAllocations {
                        splitIndicatorView
                    }
                }
                HStack(spacing: 8) {
                    // Source badge
                    if transaction.source == "gmail" {
                        Image(systemName: "envelope.fill")
                            .font(.caption2)
                            .foregroundColor(.blue)
                    }
                    // Tax category
                    Text(transaction.taxCategory ?? "Uncategorized")
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

    // MARK: - BLUEPRINT Line 133: Split Visual Indicator

    /// Visual indicator showing this transaction has been split across tax categories
    @ViewBuilder
    private var splitIndicatorView: some View {
        HStack(spacing: 2) {
            Image(systemName: "rectangle.split.2x1")
                .font(.caption2)
                .foregroundColor(.orange)

            // Show split count badge if more than one split
            if transaction.splitAllocationCount > 1 {
                Text("\(transaction.splitAllocationCount)")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 1)
                    .background(Color.orange)
                    .clipShape(Capsule())
            }
        }
        .help("Split across \(transaction.splitAllocationCount) tax categories")
        .accessibilityLabel("Transaction split across \(transaction.splitAllocationCount) tax categories")
    }

    private func taxCategoryColor(_ category: String?) -> Color {
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