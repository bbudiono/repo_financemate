import SwiftUI

struct IncomeOverviewCards: View {
    let analysis: IncomeAnalysis

    var body: some View {
        HStack(spacing: 16) {
            IncomeCard(
                title: "Total Income",
                value: formatCurrency(analysis.totalIncome),
                icon: "plus.circle.fill",
                color: .green,
                subtitle: "in \(analysis.period.displayName.lowercased())"
            )

            IncomeCard(
                title: "Monthly Average",
                value: formatCurrency(analysis.averageMonthlyIncome),
                icon: "calendar",
                color: .blue,
                subtitle: "per month"
            )

            IncomeCard(
                title: "Income Streams",
                value: "\(analysis.incomeStreams.count)",
                icon: "arrow.branch",
                color: .purple,
                subtitle: "active sources"
            )

            IncomeCard(
                title: "Growth Rate",
                value: "\(String(format: "%.1f", analysis.growthRate))%",
                icon: analysis.growthRate >= 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill",
                color: analysis.growthRate >= 0 ? .green : .red,
                subtitle: "vs previous period"
            )

            IncomeCard(
                title: "Consistency",
                value: "\(Int(analysis.consistencyScore * 100))%",
                icon: "chart.line.uptrend.xyaxis",
                color: analysis.consistencyScore >= 0.8 ? .green : (analysis.consistencyScore >= 0.6 ? .orange : .red),
                subtitle: "income stability"
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

struct IncomeCard: View {
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

#Preview {
    IncomeOverviewCards(
        analysis: IncomeAnalysis(
            period: .month,
            totalIncome: 8450.00,
            averageMonthlyIncome: 8450.00,
            incomeStreams: [
                IncomeStream(source: "Primary Job", amount: 7500.00, frequency: 2, category: "Salary"),
                IncomeStream(source: "Freelance", amount: 650.00, frequency: 3, category: "Contract"),
                IncomeStream(source: "Investment Returns", amount: 300.00, frequency: 1, category: "Investment")
            ],
            growthRate: 5.2,
            consistencyScore: 0.92,
            insights: []
        )
    )
    .frame(width: 900)
    .padding()
}
