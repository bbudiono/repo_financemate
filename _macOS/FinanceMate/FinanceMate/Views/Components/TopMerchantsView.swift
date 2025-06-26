import SwiftUI

struct TopMerchantsView: View {
    let analysis: SpendingAnalysis

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Top Merchants")
                .font(.subheadline)
                .fontWeight(.medium)

            if analysis.topMerchants.isEmpty {
                Text("No merchant data available")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(Array(analysis.topMerchants.enumerated()), id: \.element.merchant) { index, merchant in
                        MerchantRowView(
                            merchant: merchant,
                            rank: index + 1,
                            totalSpent: analysis.totalSpent
                        )
                    }
                }
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

struct MerchantRowView: View {
    let merchant: MerchantSpending
    let rank: Int
    let totalSpent: Double

    private var percentage: Double {
        totalSpent > 0 ? (merchant.amount / totalSpent) * 100 : 0
    }

    private var merchantIcon: String {
        switch merchant.merchant.lowercased() {
        case let name where name.contains("starbucks"): return "cup.and.saucer.fill"
        case let name where name.contains("uber"): return "car.fill"
        case let name where name.contains("netflix"): return "tv.fill"
        case let name where name.contains("amazon"): return "shippingbox.fill"
        case let name where name.contains("target"): return "target"
        case let name where name.contains("walmart"): return "cart.fill"
        case let name where name.contains("gas") || name.contains("shell") || name.contains("chevron"): return "fuelpump.fill"
        case let name where name.contains("grocery") || name.contains("whole foods"): return "basket.fill"
        case let name where name.contains("restaurant") || name.contains("cafe"): return "fork.knife"
        case let name where name.contains("bank"): return "building.columns.fill"
        default: return "storefront.fill"
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            // Rank
            Text("#\(rank)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.secondary)
                .frame(width: 20, alignment: .leading)

            // Merchant icon
            Image(systemName: merchantIcon)
                .foregroundColor(colorForCategory(merchant.category))
                .frame(width: 20)

            // Merchant details
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(merchant.merchant)
                        .font(.body)
                        .fontWeight(.medium)
                        .lineLimit(1)

                    Spacer()

                    Text(formatCurrency(merchant.amount))
                        .font(.body)
                        .fontWeight(.semibold)
                }

                HStack {
                    Text(merchant.category)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text("\(merchant.transactionCount) transactions • \(String(format: "%.1f", percentage))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(NSColor.windowBackgroundColor))
        )
    }

    private func colorForCategory(_ category: String) -> Color {
        switch category.lowercased() {
        case "food": return .orange
        case "transportation": return .green
        case "entertainment": return .purple
        case "shopping": return .pink
        case "utilities": return .blue
        case "healthcare": return .red
        case "income": return .mint
        case "housing": return .indigo
        case "insurance": return .teal
        default: return .gray
        }
    }

    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
}

#Preview {
    TopMerchantsView(
        analysis: SpendingAnalysis(
            period: .month,
            totalSpent: 2847.50,
            averageDailySpending: 94.92,
            categoryBreakdown: [],
            trendAnalysis: .increasing,
            topMerchants: [
                MerchantSpending(merchant: "Starbucks", amount: 285.40, transactionCount: 18, category: "Food"),
                MerchantSpending(merchant: "Uber", amount: 245.80, transactionCount: 12, category: "Transportation"),
                MerchantSpending(merchant: "Amazon", amount: 198.50, transactionCount: 8, category: "Shopping"),
                MerchantSpending(merchant: "Whole Foods", amount: 156.30, transactionCount: 6, category: "Food"),
                MerchantSpending(merchant: "Netflix", amount: 15.99, transactionCount: 1, category: "Entertainment"),
                MerchantSpending(merchant: "Shell Gas Station", amount: 124.75, transactionCount: 4, category: "Transportation")
            ],
            spendingByDay: [],
            spendingByMonth: [],
            insights: []
        )
    )
    .frame(width: 500)
    .padding()
}
