import SwiftUI

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
                Text("No transactions yet")
                    .foregroundColor(.secondary)
            } else {
                List(transactions) { transaction in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(transaction.itemDescription)
                                .font(.headline)
                            Text(transaction.date, style: .date)
                                .font(.caption)
                                .foregroundColor(.secondary)
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
}
