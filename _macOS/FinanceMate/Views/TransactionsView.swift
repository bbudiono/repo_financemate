import SwiftUI

/// Transactions list view
/// BLUEPRINT: Simple table showing expenses from Gmail and manual entry
struct TransactionsView: View {
    @Environment(\.managedObjectContext) private var viewContext
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
                VStack(spacing: 16) {
                    Image(systemName: "tray")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)

                    Text("No transactions yet")
                        .font(.title3)
                        .foregroundColor(.secondary)

                    Text("Gmail receipts will appear here when imported")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxHeight: .infinity)
            } else {
                List(transactions) { transaction in
                    TransactionRow(transaction: transaction)
                }
            }
        }
    }
}

/// Simple transaction row
struct TransactionRow: View {
    let transaction: Transaction

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.itemDescription ?? "Unknown")
                    .font(.headline)

                Text(transaction.date ?? Date(), style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text("$\(transaction.amount, specifier: "%.2f")")
                .font(.headline)
                .foregroundColor(transaction.amount >= 0 ? .green : .red)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    TransactionsView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
