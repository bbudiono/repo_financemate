import SwiftUI

struct BudgetVarianceOverview: View {
    let analysis: BudgetVarianceAnalysis

    private var overBudgetCategories: [CategoryVariance] {
        analysis.categoryVariances.filter { $0.status == .overBudget }
    }

    private var underBudgetCategories: [CategoryVariance] {
        analysis.categoryVariances.filter { $0.status == .wellUnderBudget }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Budget vs Actual Overview")
                .font(.subheadline)
                .fontWeight(.medium)

            // Summary cards
            HStack(spacing: 16) {
                BudgetSummaryCard(
                    title: "Total Budgeted",
                    amount: analysis.totalBudgeted,
                    icon: "target",
                    color: .blue
                )

                BudgetSummaryCard(
                    title: "Total Spent",
                    amount: analysis.totalActual,
                    icon: "minus.circle.fill",
                    color: .orange
                )

                BudgetSummaryCard(
                    title: "Variance",
                    amount: analysis.overallVariance,
                    icon: analysis.overallVariance >= 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill",
                    color: analysis.overallVariance >= 0 ? .red : .green,
                    isVariance: true
                )

                BudgetPercentageCard(
                    title: "Budget Usage",
                    percentage: analysis.totalBudgeted > 0 ? (analysis.totalActual / analysis.totalBudgeted) * 100 : 0,
                    icon: "percent",
                    color: budgetUsageColor(analysis.totalBudgeted > 0 ? (analysis.totalActual / analysis.totalBudgeted) : 0)
                )
            }

            // Status overview
            HStack(spacing: 16) {
                // Categories over budget
                StatusOverviewCard(
                    title: "Over Budget",
                    count: overBudgetCategories.count,
                    totalAmount: overBudgetCategories.reduce(0) { $0 + $1.variance },
                    icon: "exclamationmark.triangle.fill",
                    color: .red
                )

                // Categories under budget
                StatusOverviewCard(
                    title: "Under Budget",
                    count: underBudgetCategories.count,
                    totalAmount: underBudgetCategories.reduce(0) { $0 + abs($1.variance) },
                    icon: "checkmark.circle.fill",
                    color: .green
                )

                // On track categories
                StatusOverviewCard(
                    title: "On Track",
                    count: analysis.categoryVariances.filter { $0.status == .onTrack || $0.status == .nearBudget }.count,
                    totalAmount: 0,
                    icon: "minus.circle.fill",
                    color: .blue,
                    hideAmount: true
                )
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }

    private func budgetUsageColor(_ usage: Double) -> Color {
        if usage <= 0.8 { return .green } else if usage <= 1.0 { return .orange } else { return .red }
    }
}

struct BudgetSummaryCard: View {
    let title: String
    let amount: Double
    let icon: String
    let color: Color
    var isVariance: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)

                Spacer()
            }

            Text(formatCurrency(amount, showSign: isVariance))
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
                .lineLimit(1)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(8)
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

struct BudgetPercentageCard: View {
    let title: String
    let percentage: Double
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)

                Spacer()
            }

            Text("\(String(format: "%.1f", percentage))%")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(8)
    }
}

struct StatusOverviewCard: View {
    let title: String
    let count: Int
    let totalAmount: Double
    let icon: String
    let color: Color
    var hideAmount: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)

                Spacer()

                Text("\(count)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }

            if !hideAmount && totalAmount > 0 {
                Text(formatCurrency(totalAmount))
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(8)
    }

    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
}

#Preview {
    BudgetVarianceOverview(
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
    .frame(width: 800)
    .padding()
}
