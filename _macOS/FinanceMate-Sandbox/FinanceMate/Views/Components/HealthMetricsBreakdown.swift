import Charts
import SwiftUI

struct HealthMetricsBreakdown: View {
    let healthScore: FinancialHealthScore

    private var metricsData: [HealthMetric] {
        [
            HealthMetric(
                name: "Savings Rate",
                score: healthScore.savingsRate * 100,
                weight: 30,
                target: 20,
                current: healthScore.savingsRate * 100,
                color: .green,
                icon: "banknote"
            ),
            HealthMetric(
                name: "Debt Ratio",
                score: max(0, 25 - (healthScore.debtToIncomeRatio * 50)) * 4,
                weight: 25,
                target: 36,
                current: healthScore.debtToIncomeRatio * 100,
                color: .red,
                icon: "creditcard",
                isLowerBetter: true
            ),
            HealthMetric(
                name: "Emergency Fund",
                score: min(20, healthScore.emergencyFundRatio * 3.33) * 4,
                weight: 20,
                target: 3,
                current: healthScore.emergencyFundRatio,
                color: .blue,
                icon: "shield.fill"
            ),
            HealthMetric(
                name: "Credit Usage",
                score: max(0, 15 - (healthScore.creditUtilization * 50)) * 6.67,
                weight: 15,
                target: 30,
                current: healthScore.creditUtilization * 100,
                color: .orange,
                icon: "percent",
                isLowerBetter: true
            ),
            HealthMetric(
                name: "Subscriptions",
                score: max(0, 10 - (healthScore.subscriptionBurden * 100)) * 10,
                weight: 10,
                target: 10,
                current: healthScore.subscriptionBurden * 100,
                color: .purple,
                icon: "app.badge",
                isLowerBetter: true
            )
        ]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Health Metrics Breakdown")
                .font(.subheadline)
                .fontWeight(.medium)

            HStack(spacing: 16) {
                // Metrics radar chart (simplified as bar chart)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Score by Category")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Chart(metricsData, id: \.name) { metric in
                        BarMark(
                            x: .value("Score", metric.score),
                            y: .value("Metric", metric.name)
                        )
                        .foregroundStyle(metric.color.gradient)
                        .cornerRadius(4)
                    }
                    .frame(height: 150)
                    .chartXScale(domain: 0...100)
                    .chartXAxis {
                        AxisMarks(position: .bottom) { value in
                            AxisValueLabel {
                                if let score = value.as(Double.self) {
                                    Text("\(Int(score))")
                                }
                            }
                        }
                    }
                }

                // Detailed metrics
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(metricsData, id: \.name) { metric in
                        HealthMetricDetailRow(metric: metric)
                    }
                }
            }

            // Weight visualization
            VStack(alignment: .leading, spacing: 8) {
                Text("Category Weights in Overall Score")
                    .font(.caption)
                    .foregroundColor(.secondary)

                HStack(spacing: 2) {
                    ForEach(metricsData, id: \.name) { metric in
                        Rectangle()
                            .fill(metric.color)
                            .frame(width: CGFloat(metric.weight) * 2.5, height: 8)
                            .overlay(
                                Text("\(metric.weight)%")
                                    .font(.caption2)
                                    .foregroundColor(.white)
                                    .opacity(metric.weight >= 15 ? 1 : 0)
                            )
                    }
                }
                .cornerRadius(4)
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

struct HealthMetricDetailRow: View {
    let metric: HealthMetric

    private var statusIcon: String {
        if metric.isLowerBetter {
            return metric.current <= metric.target ? "checkmark.circle.fill" : "exclamationmark.triangle.fill"
        } else {
            return metric.current >= metric.target ? "checkmark.circle.fill" : "exclamationmark.triangle.fill"
        }
    }

    private var statusColor: Color {
        if metric.isLowerBetter {
            return metric.current <= metric.target ? .green : .red
        } else {
            return metric.current >= metric.target ? .green : .red
        }
    }

    private var displayValue: String {
        switch metric.name {
        case "Emergency Fund":
            return String(format: "%.1f months", metric.current)
        default:
            return String(format: "%.1f%%", metric.current)
        }
    }

    var body: some View {
        HStack {
            Image(systemName: metric.icon)
                .foregroundColor(metric.color)
                .frame(width: 16)

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(metric.name)
                        .font(.caption)
                        .fontWeight(.medium)

                    Spacer()

                    Text(displayValue)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(metric.color)
                }

                HStack {
                    Text("Score: \(Int(metric.score))/100")
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    Spacer()

                    Image(systemName: statusIcon)
                        .foregroundColor(statusColor)
                        .font(.caption2)
                }
            }
        }
        .padding(.vertical, 2)
    }
}

struct HealthMetric {
    let name: String
    let score: Double
    let weight: Int
    let target: Double
    let current: Double
    let color: Color
    let icon: String
    var isLowerBetter: Bool = false
}

#Preview {
    HealthMetricsBreakdown(
        healthScore: FinancialHealthScore(
            overallScore: 78.5,
            savingsRate: 0.18,
            debtToIncomeRatio: 0.25,
            emergencyFundRatio: 4.2,
            creditUtilization: 0.15,
            subscriptionBurden: 0.08,
            recommendations: [],
            scoreHistory: []
        )
    )
    .frame(width: 600)
    .padding()
}
