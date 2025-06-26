import Charts
import SwiftUI

struct CategoryBreakdownChart: View {
    let analysis: SpendingAnalysis

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Category Breakdown")
                .font(.subheadline)
                .fontWeight(.medium)

            HStack(spacing: 16) {
                // Pie chart
                Chart(analysis.categoryBreakdown, id: \.category) { category in
                    SectorMark(
                        angle: .value("Amount", category.amount),
                        innerRadius: .ratio(0.6),
                        angularInset: 1
                    )
                    .foregroundStyle(colorForCategory(category.category))
                    .opacity(0.8)
                }
                .frame(width: 150, height: 150)

                // Category list
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(analysis.categoryBreakdown.prefix(6), id: \.category) { category in
                        CategoryRowView(
                            category: category,
                            totalSpent: analysis.totalSpent,
                            color: colorForCategory(category.category)
                        )
                    }

                    if analysis.categoryBreakdown.count > 6 {
                        Text("+ \(analysis.categoryBreakdown.count - 6) more categories")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
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
}

struct CategoryRowView: View {
    let category: CategorySpending
    let totalSpent: Double
    let color: Color

    private var percentage: Double {
        totalSpent > 0 ? (category.amount / totalSpent) * 100 : 0
    }

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(category.category)
                        .font(.caption)
                        .fontWeight(.medium)

                    Spacer()

                    Text(formatCurrency(category.amount))
                        .font(.caption)
                        .fontWeight(.semibold)
                }

                HStack {
                    Text("\(category.transactionCount) transactions")
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text("\(String(format: "%.1f", percentage))%")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
}

#Preview {
    CategoryBreakdownChart(
        analysis: SpendingAnalysis(
            period: .month,
            totalSpent: 2847.50,
            averageDailySpending: 94.92,
            categoryBreakdown: [
                CategorySpending(category: "Food", amount: 850.00, transactionCount: 25, averageAmount: 34.00),
                CategorySpending(category: "Transportation", amount: 425.00, transactionCount: 8, averageAmount: 53.13),
                CategorySpending(category: "Entertainment", amount: 320.00, transactionCount: 12, averageAmount: 26.67),
                CategorySpending(category: "Shopping", amount: 480.50, transactionCount: 15, averageAmount: 32.03),
                CategorySpending(category: "Utilities", amount: 245.00, transactionCount: 3, averageAmount: 81.67),
                CategorySpending(category: "Healthcare", amount: 180.00, transactionCount: 2, averageAmount: 90.00),
                CategorySpending(category: "Other", amount: 347.00, transactionCount: 18, averageAmount: 19.28)
            ],
            trendAnalysis: .increasing,
            topMerchants: [],
            spendingByDay: [],
            spendingByMonth: [],
            insights: []
        )
    )
    .frame(width: 500)
    .padding()
}
