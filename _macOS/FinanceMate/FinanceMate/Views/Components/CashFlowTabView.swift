import Charts
import SwiftUI

struct CashFlowTabView: View {
    let aggregationService: AccountAggregationService
    @Binding var selectedPeriod: TimePeriod
    @State private var cashFlowAnalysis: CashFlowAnalysis?

    var body: some View {
        VStack(spacing: 20) {
            periodSelectorView

            if let analysis = cashFlowAnalysis {
                cashFlowSummaryView(analysis: analysis)
                cashFlowChartsView(analysis: analysis)
                savingsInsightsView(analysis: analysis)
            } else {
                ProgressView("Loading cash flow analysis...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            loadCashFlowAnalysis()
        }
        .onChange(of: selectedPeriod) { _, _ in
            loadCashFlowAnalysis()
        }
    }

    private var periodSelectorView: some View {
        HStack {
            Text("Cash Flow Analysis")
                .font(.headline)
                .fontWeight(.semibold)

            Spacer()

            Picker("Time Period", selection: $selectedPeriod) {
                ForEach(TimePeriod.allCases, id: \.self) { period in
                    Text(period.displayName).tag(period)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 300)
        }
    }

    private func cashFlowSummaryView(analysis: CashFlowAnalysis) -> some View {
        HStack(spacing: 16) {
            CashFlowSummaryCard(
                title: "Income",
                amount: analysis.totalIncome,
                icon: "plus.circle.fill",
                color: .green
            )

            CashFlowSummaryCard(
                title: "Expenses",
                amount: analysis.totalExpenses,
                icon: "minus.circle.fill",
                color: .red
            )

            CashFlowSummaryCard(
                title: "Net Cash Flow",
                amount: analysis.netCashFlow,
                icon: analysis.netCashFlow >= 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill",
                color: analysis.netCashFlow >= 0 ? .green : .red
            )

            CashFlowSummaryCard(
                title: "Savings Rate",
                amount: analysis.savingsRate,
                icon: "percent",
                color: analysis.savingsRate >= 0.2 ? .green : (analysis.savingsRate >= 0.1 ? .orange : .red),
                isPercentage: true
            )
        }
    }

    private func cashFlowChartsView(analysis: CashFlowAnalysis) -> some View {
        HStack(spacing: 16) {
            // Income breakdown
            VStack(alignment: .leading, spacing: 12) {
                Text("Income Sources")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Chart(analysis.incomeByCategory, id: \.category) { data in
                    BarMark(
                        x: .value("Amount", data.amount),
                        y: .value("Category", data.category)
                    )
                    .foregroundStyle(.green)
                }
                .frame(height: 150)
                .chartXAxis {
                    AxisMarks(position: .bottom) { value in
                        AxisValueLabel {
                            if let amount = value.as(Double.self) {
                                Text(formatCurrencyCompact(amount))
                            }
                        }
                    }
                }

                LazyVStack(alignment: .leading, spacing: 4) {
                    ForEach(analysis.incomeByCategory, id: \.category) { data in
                        HStack {
                            Circle()
                                .fill(.green)
                                .frame(width: 6, height: 6)

                            Text(data.category)
                                .font(.caption)

                            Spacer()

                            Text(formatCurrency(data.amount))
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                    }
                }
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))
            .cornerRadius(8)

            // Expenses breakdown
            VStack(alignment: .leading, spacing: 12) {
                Text("Expense Categories")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Chart(analysis.expensesByCategory, id: \.category) { data in
                    SectorMark(
                        angle: .value("Amount", data.amount),
                        innerRadius: .ratio(0.6),
                        angularInset: 1
                    )
                    .foregroundStyle(colorForExpenseCategory(data.category))
                }
                .frame(height: 150)

                LazyVStack(alignment: .leading, spacing: 4) {
                    ForEach(analysis.expensesByCategory, id: \.category) { data in
                        HStack {
                            Circle()
                                .fill(colorForExpenseCategory(data.category))
                                .frame(width: 6, height: 6)

                            Text(data.category)
                                .font(.caption)

                            Spacer()

                            Text(formatCurrency(data.amount))
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                    }
                }
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))
            .cornerRadius(8)
        }
    }

    private func savingsInsightsView(analysis: CashFlowAnalysis) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Savings Insights")
                .font(.subheadline)
                .fontWeight(.medium)

            HStack(spacing: 16) {
                // Savings rate gauge
                VStack {
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                            .frame(width: 100, height: 100)

                        Circle()
                            .trim(from: 0, to: min(analysis.savingsRate, 1.0))
                            .stroke(
                                analysis.savingsRate >= 0.2 ? .green : (analysis.savingsRate >= 0.1 ? .orange : .red),
                                style: StrokeStyle(lineWidth: 8, lineCap: .round)
                            )
                            .frame(width: 100, height: 100)
                            .rotationEffect(.degrees(-90))

                        VStack {
                            Text("\(Int(analysis.savingsRate * 100))%")
                                .font(.title2)
                                .fontWeight(.bold)

                            Text("Saved")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    InsightRow(
                        icon: "target",
                        title: "Savings Goal",
                        value: "20% recommended",
                        color: .blue
                    )

                    InsightRow(
                        icon: analysis.savingsRate >= 0.2 ? "checkmark.circle.fill" : "exclamationmark.triangle.fill",
                        title: "Status",
                        value: analysis.savingsRate >= 0.2 ? "Excellent!" : (analysis.savingsRate >= 0.1 ? "Good" : "Needs Improvement"),
                        color: analysis.savingsRate >= 0.2 ? .green : (analysis.savingsRate >= 0.1 ? .orange : .red)
                    )

                    InsightRow(
                        icon: "calendar",
                        title: "Annual Savings",
                        value: formatCurrency(analysis.netCashFlow * 12),
                        color: .green
                    )

                    if analysis.savingsRate < 0.2 {
                        InsightRow(
                            icon: "lightbulb.fill",
                            title: "To reach 20%",
                            value: "Save \(formatCurrency((analysis.totalIncome * 0.2) - analysis.netCashFlow)) more",
                            color: .orange
                        )
                    }
                }

                Spacer()
            }
        }
        .padding()
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(8)
    }

    private func loadCashFlowAnalysis() {
        cashFlowAnalysis = aggregationService.getCashFlowAnalysis(period: selectedPeriod)
    }

    private func colorForExpenseCategory(_ category: String) -> Color {
        switch category.lowercased() {
        case "housing": return .blue
        case "food": return .orange
        case "transportation": return .green
        case "utilities": return .yellow
        case "entertainment": return .purple
        case "insurance": return .red
        default: return .gray
        }
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

struct CashFlowSummaryCard: View {
    let title: String
    let amount: Double
    let icon: String
    let color: Color
    var isPercentage: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)

                Spacer()
            }

            Text(isPercentage ? "\(Int(amount * 100))%" : formatCurrency(amount))
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

    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
}

struct InsightRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 16)

            Text(title)
                .font(.body)
                .foregroundColor(.secondary)

            Spacer()

            Text(value)
                .font(.body)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    CashFlowTabView(
        aggregationService: AccountAggregationService(),
        selectedPeriod: .constant(.month)
    )
    .frame(width: 700, height: 600)
}
