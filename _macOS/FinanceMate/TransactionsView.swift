import SwiftUI

struct TransactionsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.colorScheme) private var colorScheme
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)],
        animation: .default)
    private var transactions: FetchedResults<Transaction>

    var body: some View {
        VStack {
            Text("Transactions")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            if transactions.isEmpty {
                Text("No transactions yet")
                    .foregroundColor(.secondary)
            } else {
                List(transactions) { transaction in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(transaction.itemDescription)
                                .font(.headline)
                            HStack(spacing: 8) {
                                Text(transaction.taxCategory)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(taxCategoryColor(transaction.taxCategory).opacity(0.2))
                                    .foregroundColor(taxCategoryColor(transaction.taxCategory))
                                    .cornerRadius(4)
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
            }
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
