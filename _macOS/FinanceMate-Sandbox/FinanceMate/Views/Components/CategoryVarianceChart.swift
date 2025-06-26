import Charts
import SwiftUI

struct CategoryVarianceChart: View {
    let analysis: BudgetVarianceAnalysis

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Category Variance Analysis")
                .font(.subheadline)
                .fontWeight(.medium)

            HStack(spacing: 16) {
                // Variance chart
                VStack(alignment: .leading, spacing: 8) {
                    Text("Budget vs Actual by Category")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Chart {
                        ForEach(analysis.categoryVariances, id: \.category) { variance in
                            // Budgeted amount
                            BarMark(
                                x: .value("Category", variance.category),
                                y: .value("Amount", variance.budgeted)
                            )
                            .foregroundStyle(.blue.opacity(0.7))
                            .position(by: .value("Type", "Budgeted"))

                            // Actual amount
                            BarMark(
                                x: .value("Category", variance.category),
                                y: .value("Amount", variance.actual)
                            )
                            .foregroundStyle(colorForVarianceStatus(variance.status))
                            .position(by: .value("Type", "Actual"))
                        }
                    }
                    .frame(height: 200)
                    .chartForegroundStyleScale([
                        "Budgeted": .blue.opacity(0.7),
                        "Actual": .orange
                    ])
                    .chartXAxis {
                        AxisMarks(position: .bottom) { value in
                            AxisValueLabel {
                                if let category = value.as(String.self) {
                                    Text(category)
                                        .font(.caption)
                                        .rotationEffect(.degrees(-45))
                                }
                            }
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading) { value in
                            AxisValueLabel {
                                if let amount = value.as(Double.self) {
                                    Text(formatCurrencyCompact(amount))
                                }
                            }
                        }
                    }
                    .chartLegend(position: .top, alignment: .leading)
                }

                // Category details
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(analysis.categoryVariances.prefix(6), id: \.category) { variance in
                        CategoryVarianceRow(variance: variance)
                    }

                    if analysis.categoryVariances.count > 6 {
                        Text("+ \(analysis.categoryVariances.count - 6) more categories")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }

    private func colorForVarianceStatus(_ status: VarianceStatus) -> Color {
        switch status {
        case .overBudget: return .red
        case .nearBudget: return .orange
        case .onTrack: return .green
        case .wellUnderBudget: return .blue
        }
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

struct CategoryVarianceRow: View {
    let variance: CategoryVariance

    private var statusColor: Color {
        switch variance.status {
        case .overBudget: return .red
        case .nearBudget: return .orange
        case .onTrack: return .green
        case .wellUnderBudget: return .blue
        }
    }

    private var statusIcon: String {
        switch variance.status {
        case .overBudget: return "exclamationmark.triangle.fill"
        case .nearBudget: return "exclamationmark.circle.fill"
        case .onTrack: return "checkmark.circle.fill"
        case .wellUnderBudget: return "checkmark.circle.fill"
        }
    }

    private var statusText: String {
        switch variance.status {
        case .overBudget: return "Over Budget"
        case .nearBudget: return "Near Budget"
        case .onTrack: return "On Track"
        case .wellUnderBudget: return "Under Budget"
        }
    }

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: statusIcon)
                .foregroundColor(statusColor)
                .frame(width: 16)

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(variance.category)
                        .font(.caption)
                        .fontWeight(.medium)

                    Spacer()

                    Text(formatCurrency(variance.variance, showSign: true))
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(statusColor)
                }

                HStack {
                    Text("\(formatCurrency(variance.actual)) / \(formatCurrency(variance.budgeted))")
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text(statusText)
                        .font(.caption2)
                        .foregroundColor(statusColor)
                }
            }
        }
        .padding(.vertical, 2)
        .padding(.horizontal, 6)
        .background(statusColor.opacity(0.1))
        .cornerRadius(4)
    }

    private func formatCurrency(_ amount: Double, showSign: Bool = false) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        let formattedAmount = formatter.string(from: NSNumber(value: abs(amount))) ?? "$0.00"

        if showSign {
            return amount >= 0 ? "+\(formattedAmount)" : "-\(formattedAmount)"
        } else {
            return formattedAmount
        }
    }
}

#Preview {
    CategoryVarianceChart(
        analysis: BudgetVarianceAnalysis(
            totalBudgeted: 3500.00,
            totalActual: 3750.50,
            overallVariance: 250.50,
            overallVariancePercentage: 7.16,
            categoryVariances: [
                CategoryVariance(category: "Food", budgeted: 800, actual: 950, variance: 150, variancePercentage: 18.75, status: .nearBudget),
                CategoryVariance(category: "Transportation", budgeted: 300, actual: 275, variance: -25, variancePercentage: -8.33, status: .onTrack),
                CategoryVariance(category: "Entertainment", budgeted: 200, actual: 320, variance: 120, variancePercentage: 60, status: .overBudget),
                CategoryVariance(category: "Shopping", budgeted: 500, actual: 450, variance: -50, variancePercentage: -10, status: .wellUnderBudget),
                CategoryVariance(category: "Utilities", budgeted: 250, actual: 240, variance: -10, variancePercentage: -4, status: .onTrack),
                CategoryVariance(category: "Healthcare", budgeted: 150, actual: 180, variance: 30, variancePercentage: 20, status: .nearBudget)
            ],
            insights: []
        )
    )
    .frame(width: 700)
    .padding()
}
