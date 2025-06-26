import Charts
import SwiftUI

struct SpendingTrendChart: View {
    let analysis: SpendingAnalysis
    let period: AnalyticsPeriod

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Spending Trend")
                .font(.subheadline)
                .fontWeight(.medium)

            Chart {
                ForEach(analysis.spendingByDay, id: \.date) { dataPoint in
                    LineMark(
                        x: .value("Date", dataPoint.date),
                        y: .value("Amount", dataPoint.amount)
                    )
                    .foregroundStyle(.red)
                    .lineStyle(StrokeStyle(lineWidth: 2))

                    AreaMark(
                        x: .value("Date", dataPoint.date),
                        y: .value("Amount", dataPoint.amount)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.red.opacity(0.3), .red.opacity(0.1)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }

                // Add average line
                RuleMark(y: .value("Average", analysis.averageDailySpending))
                    .foregroundStyle(.orange)
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 3]))
                    .annotation(position: .top, alignment: .trailing) {
                        Text("Avg: \(formatCurrency(analysis.averageDailySpending))")
                            .font(.caption)
                            .foregroundColor(.orange)
                            .padding(4)
                            .background(Color(NSColor.controlBackgroundColor))
                            .cornerRadius(4)
                    }
            }
            .frame(height: 200)
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisValueLabel {
                        if let amount = value.as(Double.self) {
                            Text(formatCurrencyCompact(amount))
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks(position: .bottom) { value in
                    AxisValueLabel {
                        if let date = value.as(Date.self) {
                            Text(date, format: period == .week ?
                                .dateTime.weekday(.abbreviated) :
                                .dateTime.month(.abbreviated).day()
                            )
                        }
                    }
                }
            }

            // Trend insights
            HStack {
                Image(systemName: analysis.trendAnalysis.iconName)
                    .foregroundColor(analysis.trendAnalysis.color)

                Text("Spending is \(analysis.trendAnalysis.displayName.lowercased()) compared to the previous period")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }

    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }

    private func formatCurrencyCompact(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"

        if abs(amount) >= 1000 {
            formatter.maximumFractionDigits = 0
            return formatter.string(from: NSNumber(value: amount / 1000)) ?? "$0" + "K"
        } else {
            formatter.maximumFractionDigits = 0
            return formatter.string(from: NSNumber(value: amount)) ?? "$0"
        }
    }
}

#Preview {
    SpendingTrendChart(
        analysis: SpendingAnalysis(
            period: .month,
            totalSpent: 2847.50,
            averageDailySpending: 94.92,
            categoryBreakdown: [],
            trendAnalysis: .increasing,
            topMerchants: [],
            spendingByDay: [
                DailySpending(date: Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date(), amount: 120.50, transactionCount: 3),
                DailySpending(date: Calendar.current.date(byAdding: .day, value: -6, to: Date()) ?? Date(), amount: 85.30, transactionCount: 2),
                DailySpending(date: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(), amount: 156.75, transactionCount: 4),
                DailySpending(date: Calendar.current.date(byAdding: .day, value: -4, to: Date()) ?? Date(), amount: 92.40, transactionCount: 2),
                DailySpending(date: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(), amount: 203.20, transactionCount: 6),
                DailySpending(date: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(), amount: 67.85, transactionCount: 1),
                DailySpending(date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(), amount: 145.60, transactionCount: 3)
            ],
            spendingByMonth: [],
            insights: []
        ),
        period: .week
    )
    .frame(width: 600)
    .padding()
}
