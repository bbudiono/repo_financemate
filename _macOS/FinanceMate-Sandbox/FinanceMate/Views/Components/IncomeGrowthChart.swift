import Charts
import SwiftUI

struct IncomeGrowthChart: View {
    let analysis: IncomeAnalysis

    private var monthlyIncomeData: [MonthlyIncomeData] {
        let calendar = Calendar.current
        var data: [MonthlyIncomeData] = []

        // Generate sample monthly income data based on analysis
        for i in (0...11).reversed() {
            let date = calendar.date(byAdding: .month, value: -i, to: Date()) ?? Date()
            let baseAmount = analysis.averageMonthlyIncome
            let variation = Double.random(in: -500...500)
            let amount = max(0, baseAmount + variation)

            data.append(MonthlyIncomeData(
                month: date,
                amount: amount,
                growthRate: i == 11 ? 0 : Double.random(in: -10...15)
            ))
        }

        return data
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Income Growth Trend")
                .font(.subheadline)
                .fontWeight(.medium)

            Chart {
                ForEach(monthlyIncomeData, id: \.month) { dataPoint in
                    BarMark(
                        x: .value("Month", dataPoint.month),
                        y: .value("Income", dataPoint.amount)
                    )
                    .foregroundStyle(.green.gradient)
                    .cornerRadius(4)

                    LineMark(
                        x: .value("Month", dataPoint.month),
                        y: .value("Growth Rate", mapGrowthRateToChart(dataPoint.growthRate))
                    )
                    .foregroundStyle(.blue)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    .symbol(.circle)
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
                            Text(date, format: .dateTime.month(.abbreviated))
                        }
                    }
                }
            }

            // Growth insights
            HStack(spacing: 20) {
                GrowthInsightCard(
                    title: "Average Growth",
                    value: "\(String(format: "%.1f", analysis.growthRate))%",
                    icon: analysis.growthRate >= 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill",
                    color: analysis.growthRate >= 0 ? .green : .red
                )

                GrowthInsightCard(
                    title: "Consistency Score",
                    value: "\(Int(analysis.consistencyScore * 100))%",
                    icon: "chart.line.uptrend.xyaxis",
                    color: analysis.consistencyScore >= 0.8 ? .green : .orange
                )

                GrowthInsightCard(
                    title: "Trend Direction",
                    value: analysis.growthRate > 5 ? "Strong Growth" : (analysis.growthRate > 0 ? "Stable" : "Declining"),
                    icon: analysis.growthRate > 5 ? "arrow.up.right.circle.fill" : (analysis.growthRate > 0 ? "minus.circle.fill" : "arrow.down.right.circle.fill"),
                    color: analysis.growthRate > 5 ? .green : (analysis.growthRate > 0 ? .blue : .red)
                )
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }

    private func mapGrowthRateToChart(_ growthRate: Double) -> Double {
        // Map growth rate to a reasonable chart scale relative to income amounts
        analysis.averageMonthlyIncome + (growthRate * 100)
    }

    private func formatCurrencyCompact(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"

        if abs(amount) >= 1_000_000 {
            formatter.maximumFractionDigits = 1
            return formatter.string(from: NSNumber(value: amount / 1_000_000)) ?? "$0" + "M"
        } else if abs(amount) >= 1000 {
            formatter.maximumFractionDigits = 0
            return formatter.string(from: NSNumber(value: amount / 1000)) ?? "$0" + "K"
        } else {
            formatter.maximumFractionDigits = 0
            return formatter.string(from: NSNumber(value: amount)) ?? "$0"
        }
    }
}

struct GrowthInsightCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)

            Text(value)
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(color)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(8)
    }
}

struct MonthlyIncomeData {
    let month: Date
    let amount: Double
    let growthRate: Double
}

#Preview {
    IncomeGrowthChart(
        analysis: IncomeAnalysis(
            period: .year,
            totalIncome: 101_400.00,
            averageMonthlyIncome: 8450.00,
            incomeStreams: [],
            growthRate: 8.5,
            consistencyScore: 0.92,
            insights: []
        )
    )
    .frame(width: 700)
    .padding()
}
