import SwiftUI

struct SpendingOverviewCards: View {
    let analysis: SpendingAnalysis

    var body: some View {
        HStack(spacing: 16) {
            SpendingCard(
                title: "Total Spent",
                value: formatCurrency(analysis.totalSpent),
                icon: "minus.circle.fill",
                color: .red,
                subtitle: "in \(analysis.period.displayName.lowercased())"
            )

            SpendingCard(
                title: "Daily Average",
                value: formatCurrency(analysis.averageDailySpending),
                icon: "calendar",
                color: .orange,
                subtitle: "per day"
            )

            SpendingCard(
                title: "Top Category",
                value: analysis.categoryBreakdown.first?.category ?? "None",
                icon: "chart.pie.fill",
                color: .blue,
                subtitle: formatCurrency(analysis.categoryBreakdown.first?.amount ?? 0)
            )

            SpendingCard(
                title: "Trend",
                value: analysis.trendAnalysis.displayName,
                icon: analysis.trendAnalysis.iconName,
                color: analysis.trendAnalysis.color,
                subtitle: "vs previous period"
            )
        }
    }

    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
}

struct SpendingCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)

                Spacer()
            }

            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .lineLimit(1)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

extension TrendDirection {
    var displayName: String {
        switch self {
        case .increasing: return "Increasing"
        case .decreasing: return "Decreasing"
        case .stable: return "Stable"
        }
    }

    var iconName: String {
        switch self {
        case .increasing: return "arrow.up.circle.fill"
        case .decreasing: return "arrow.down.circle.fill"
        case .stable: return "minus.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .increasing: return .red
        case .decreasing: return .green
        case .stable: return .gray
        }
    }
}

#Preview {
    SpendingOverviewCards(
        analysis: SpendingAnalysis(
            period: .month,
            totalSpent: 2847.50,
            averageDailySpending: 94.92,
            categoryBreakdown: [
                CategorySpending(category: "Food", amount: 850.00, transactionCount: 25, averageAmount: 34.00),
                CategorySpending(category: "Transportation", amount: 425.00, transactionCount: 8, averageAmount: 53.13)
            ],
            trendAnalysis: .increasing,
            topMerchants: [],
            spendingByDay: [],
            spendingByMonth: [],
            insights: []
        )
    )
    .frame(width: 800)
    .padding()
}
