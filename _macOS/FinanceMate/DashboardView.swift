import SwiftUI

struct DashboardView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.colorScheme) private var colorScheme
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)],
        animation: .default)
    private var transactions: FetchedResults<Transaction>

    var totalBalance: Double {
        transactions.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("FinanceMate")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                HStack(spacing: 16) {
                    StatCard(
                        title: "Total Balance",
                        value: String(format: "$%.2f", totalBalance),
                        color: .blue
                    )

                    StatCard(
                        title: "Transactions",
                        value: "\(transactions.count)",
                        color: .green
                    )
                }
                .padding()
            }
            .padding()
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text(value)
                .font(.title)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}
