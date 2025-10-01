import SwiftUI

/// Dashboard showing financial overview
/// BLUEPRINT: Beautiful, simple balance cards
struct DashboardView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var totalBalance: Double = 0.0
    @State private var transactionCount: Int = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("FinanceMate Dashboard")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Complete Financial Overview")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()

                // Balance Cards
                HStack(spacing: 16) {
                    BalanceCard(
                        title: "Total Balance",
                        amount: totalBalance,
                        color: .blue,
                        icon: "dollarsign.circle.fill"
                    )

                    BalanceCard(
                        title: "Transactions",
                        amount: Double(transactionCount),
                        color: .green,
                        icon: "list.bullet",
                        isCurrency: false
                    )
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding()
        }
        .background(Color(NSColor.windowBackgroundColor))
    }
}

/// Simple balance card component
struct BalanceCard: View {
    let title: String
    let amount: Double
    let color: Color
    let icon: String
    var isCurrency: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)

                Spacer()
            }

            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)

            if isCurrency {
                Text("$\(amount, specifier: "%.2f")")
                    .font(.title)
                    .fontWeight(.bold)
            } else {
                Text("\(Int(amount))")
                    .font(.title)
                    .fontWeight(.bold)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

#Preview {
    DashboardView()
}
