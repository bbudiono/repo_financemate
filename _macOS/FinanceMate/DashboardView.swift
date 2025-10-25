import SwiftUI

// BLUEPRINT Lines 147-160: Enhanced Dashboard with icons, trends, secondary metrics
struct DashboardView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.colorScheme) private var colorScheme
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)],
        animation: .default)
    private var transactions: FetchedResults<Transaction>

    @StateObject private var viewModel: DashboardViewModel

    init() {
        let tempContext = PersistenceController.shared.container.viewContext
        _viewModel = StateObject(wrappedValue: DashboardViewModel(context: tempContext))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                Text("FinanceMate")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .accessibilityLabel("FinanceMate Dashboard")
                    .accessibilityAddTraits(.isHeader)

                // BLUEPRINT Lines 147-148: Enhanced summary cards with icons, secondary metrics, trends
                VStack(spacing: 16) {
                    HStack(spacing: 16) {
                        EnhancedStatCard(
                            icon: "dollarsign.circle.fill",
                            title: "Total Balance",
                            value: viewModel.formattedTotalBalance,
                            secondaryMetric: "Monthly: \(viewModel.formattedMonthlySpending)",
                            trend: viewModel.balanceTrend,
                            color: .blue
                        )
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Total Balance: \(viewModel.formattedTotalBalance), Monthly spending: \(viewModel.formattedMonthlySpending), Trend: \(viewModel.balanceTrend.accessibilityDescription)")
                        .accessibilityHint("Double-tap to view balance details")

                        EnhancedStatCard(
                            icon: "list.bullet.rectangle.fill",
                            title: "Transactions",
                            value: "\(viewModel.transactionCount)",
                            secondaryMetric: "This month: \(viewModel.monthlyTransactionCount)",
                            trend: viewModel.transactionTrend,
                            color: .green
                        )
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Transactions: \(viewModel.transactionCount), This month: \(viewModel.monthlyTransactionCount), Trend: \(viewModel.transactionTrend.accessibilityDescription)")
                        .accessibilityHint("Double-tap to view transaction details")
                    }

                    HStack(spacing: 16) {
                        EnhancedStatCard(
                            icon: "arrow.down.circle.fill",
                            title: "Expenses",
                            value: viewModel.formattedExpenses,
                            secondaryMetric: "Avg/month: \(viewModel.formattedAvgMonthlyExpenses)",
                            trend: viewModel.expensesTrend,
                            color: .red
                        )
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Expenses: \(viewModel.formattedExpenses), Average per month: \(viewModel.formattedAvgMonthlyExpenses), Trend: \(viewModel.expensesTrend.accessibilityDescription)")
                        .accessibilityHint("Double-tap to view expense details")

                        EnhancedStatCard(
                            icon: "arrow.up.circle.fill",
                            title: "Income",
                            value: viewModel.formattedIncome,
                            secondaryMetric: "This month: \(viewModel.formattedMonthlyIncome)",
                            trend: viewModel.incomeTrend,
                            color: .green
                        )
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Income: \(viewModel.formattedIncome), This month: \(viewModel.formattedMonthlyIncome), Trend: \(viewModel.incomeTrend.accessibilityDescription)")
                        .accessibilityHint("Double-tap to view income details")
                    }
                }
                .padding()

                // BLUEPRINT Lines 158-160: Visual analytics/charts
                if viewModel.hasData {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Spending by Category")
                            .font(.headline)
                            .padding(.horizontal)
                            .accessibilityLabel("Spending by Category Chart")
                            .accessibilityAddTraits(.isHeader)

                        SpendingCategoryChart(data: viewModel.categorySpending)
                            .frame(height: 200)
                            .padding()
                            .accessibilityElement(children: .contain)
                            .accessibilityLabel("Category spending breakdown chart showing \(viewModel.categorySpending.count) categories")
                    }
                }
            }
            .padding()
        }
        .onAppear {
            viewModel.updateTransactions(Array(transactions))
        }
        .onChange(of: transactions.count) { oldCount, newCount in
            viewModel.updateTransactions(Array(transactions))
        }
    }
}

// BLUEPRINT Lines 147-148: Enhanced stat card with icon, trend, secondary metric
struct EnhancedStatCard: View {
    let icon: String
    let title: String
    let value: String
    let secondaryMetric: String
    let trend: TrendIndicator
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Icon + Title row
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                // Trend indicator
                TrendView(trend: trend)
            }

            // Primary value (with proper typography)
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)

            // Secondary metric
            Text(secondaryMetric)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
        .accessibleFocus() // WCAG 2.1 AA: Focus visible indicator for stat cards
    }
}

// BLUEPRINT Line 147: Visual trend indicator (up/down arrow with %)
struct TrendView: View {
    let trend: TrendIndicator

    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: trend.direction == .up ? "arrow.up" : trend.direction == .down ? "arrow.down" : "minus")
                .font(.caption2)
                .foregroundColor(trendColor)
            Text(trend.percentageText)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(trendColor)
        }
    }

    private var trendColor: Color {
        switch trend.direction {
        case .up: return .green
        case .down: return .red
        case .neutral: return .gray
        }
    }
}

// Simple spending category chart (bar chart visualization)
struct SpendingCategoryChart: View {
    let data: [(category: String, amount: Double, color: Color)]

    var maxAmount: Double {
        data.map(\.amount).max() ?? 1
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(data, id: \.category) { item in
                HStack {
                    Text(item.category)
                        .font(.caption)
                        .frame(width: 100, alignment: .leading)

                    GeometryReader { geometry in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(item.color)
                            .frame(width: geometry.size.width * (item.amount / maxAmount))
                    }

                    Text(item.amount, format: .currency(code: "AUD"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(width: 80, alignment: .trailing)
                }
                .frame(height: 24)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(item.category): \(item.amount, format: .currency(code: "AUD"))")
                .accessibilityValue("\(Int((item.amount / maxAmount) * 100))% of total spending")
            }
        }
    }
}

// Trend indicator model
struct TrendIndicator {
    enum Direction {
        case up, down, neutral
    }

    let direction: Direction
    let percentage: Double

    var percentageText: String {
        String(format: "%.1f%%", abs(percentage))
    }

    // WCAG 2.1 AA: Accessibility description for VoiceOver
    var accessibilityDescription: String {
        let directionText: String
        switch direction {
        case .up:
            directionText = "up"
        case .down:
            directionText = "down"
        case .neutral:
            directionText = "unchanged"
        }
        return "\(percentageText) \(directionText)"
    }
}
