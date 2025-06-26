import Charts
import SwiftUI

struct AdvancedAnalyticsView: View {
    @StateObject private var analyticsEngine = AdvancedAnalyticsEngine()
    @StateObject private var aggregationService = AccountAggregationService()
    @State private var selectedPeriod: AnalyticsPeriod = .month
    @State private var selectedTab = 0
    @State private var spendingAnalysis: SpendingAnalysis?
    @State private var incomeAnalysis: IncomeAnalysis?
    @State private var healthScore: FinancialHealthScore?
    @State private var budgetVarianceAnalysis: BudgetVarianceAnalysis?
    @State private var showingInsightDetails: AnalyticsInsight?

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            headerView

            if analyticsEngine.isLoading {
                loadingView
            } else {
                tabView
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
        .onAppear {
            loadAnalytics()
        }
        .onChange(of: selectedPeriod) { _, _ in
            loadAnalytics()
        }
        .sheet(item: $showingInsightDetails) { insight in
            InsightDetailSheet(insight: insight)
        }
    }

    private var headerView: some View {
        HStack {
            Image(systemName: "chart.bar.xaxis")
                .font(.title2)
                .foregroundColor(.purple)

            VStack(alignment: .leading) {
                Text("Advanced Analytics")
                    .font(.headline)
                    .fontWeight(.semibold)

                Text("Comprehensive financial insights")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Picker("Time Period", selection: $selectedPeriod) {
                ForEach(AnalyticsPeriod.allCases, id: \.self) { period in
                    Text(period.displayName).tag(period)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 300)
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)

            Text("Analyzing your financial data...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 40)
    }

    private var tabView: some View {
        VStack(spacing: 0) {
            // Tab selector
            HStack(spacing: 0) {
                AnalyticsTabButton(title: "Spending", isSelected: selectedTab == 0) {
                    selectedTab = 0
                }
                AnalyticsTabButton(title: "Income", isSelected: selectedTab == 1) {
                    selectedTab = 1
                }
                AnalyticsTabButton(title: "Health Score", isSelected: selectedTab == 2) {
                    selectedTab = 2
                }
                AnalyticsTabButton(title: "Budget vs Actual", isSelected: selectedTab == 3) {
                    selectedTab = 3
                }
                AnalyticsTabButton(title: "Forecasting", isSelected: selectedTab == 4) {
                    selectedTab = 4
                }
            }
            .padding(.bottom, 16)

            // Tab content
            ScrollView {
                switch selectedTab {
                case 0:
                    spendingAnalyticsTab
                case 1:
                    incomeAnalyticsTab
                case 2:
                    healthScoreTab
                case 3:
                    budgetVarianceTab
                case 4:
                    forecastingTab
                default:
                    spendingAnalyticsTab
                }
            }
        }
    }

    private var spendingAnalyticsTab: some View {
        VStack(spacing: 20) {
            if let analysis = spendingAnalysis {
                SpendingOverviewCards(analysis: analysis)
                SpendingTrendChart(analysis: analysis, period: selectedPeriod)
                CategoryBreakdownChart(analysis: analysis)
                TopMerchantsView(analysis: analysis)
                InsightsView(insights: analysis.insights) { insight in
                    showingInsightDetails = insight
                }
            } else {
                Text("No spending data available for the selected period")
                    .foregroundColor(.secondary)
                    .padding(.vertical, 40)
            }
        }
    }

    private var incomeAnalyticsTab: some View {
        VStack(spacing: 20) {
            if let analysis = incomeAnalysis {
                IncomeOverviewCards(analysis: analysis)
                IncomeGrowthChart(analysis: analysis)
                IncomeStreamsView(analysis: analysis)
                IncomeConsistencyView(analysis: analysis)
                InsightsView(insights: analysis.insights) { insight in
                    showingInsightDetails = insight
                }
            } else {
                Text("No income data available for the selected period")
                    .foregroundColor(.secondary)
                    .padding(.vertical, 40)
            }
        }
    }

    private var healthScoreTab: some View {
        VStack(spacing: 20) {
            if let score = healthScore {
                FinancialHealthScoreView(healthScore: score)
                HealthMetricsBreakdown(healthScore: score)
                HealthRecommendationsView(recommendations: score.recommendations)
                HealthScoreHistoryChart(scoreHistory: score.scoreHistory)
            } else {
                Text("Calculating financial health score...")
                    .foregroundColor(.secondary)
                    .padding(.vertical, 40)
            }
        }
    }

    private var budgetVarianceTab: some View {
        VStack(spacing: 20) {
            if let variance = budgetVarianceAnalysis {
                BudgetVarianceOverview(analysis: variance)
                CategoryVarianceChart(analysis: variance)
                VarianceInsightsView(insights: variance.insights) { insight in
                    showingInsightDetails = insight
                }
            } else {
                Text("Connect budgets to see variance analysis")
                    .foregroundColor(.secondary)
                    .padding(.vertical, 40)
            }
        }
    }

    private var forecastingTab: some View {
        VStack(spacing: 20) {
            ForecastingView(
                analyticsEngine: analyticsEngine,
                spendingAnalysis: spendingAnalysis,
                selectedPeriod: selectedPeriod
            )
        }
    }

    private func loadAnalytics() {
        analyticsEngine.isLoading = true

        Task {
            let sampleTransactions = generateSampleTransactions()
            let sampleSubscriptions = generateSampleSubscriptions()

            await MainActor.run {
                spendingAnalysis = analyticsEngine.generateSpendingAnalysis(
                    transactions: sampleTransactions,
                    period: selectedPeriod
                )

                incomeAnalysis = analyticsEngine.generateIncomeAnalysis(
                    transactions: sampleTransactions,
                    period: selectedPeriod
                )

                aggregationService.loadAccounts()

                if let spending = spendingAnalysis, let income = incomeAnalysis {
                    healthScore = analyticsEngine.generateFinancialHealthScore(
                        spendingAnalysis: spending,
                        incomeAnalysis: income,
                        accounts: aggregationService.accounts,
                        subscriptions: sampleSubscriptions
                    )
                }

                budgetVarianceAnalysis = generateSampleBudgetVariance()
                analyticsEngine.isLoading = false
            }
        }
    }

    private func generateSampleTransactions() -> [FinancialTransaction] {
        var transactions: [FinancialTransaction] = []
        let calendar = Calendar.current
        let categories = ["Food", "Transportation", "Entertainment", "Shopping", "Utilities", "Healthcare"]
        let merchants = ["Starbucks", "Uber", "Netflix", "Amazon", "PG&E", "CVS Pharmacy", "Whole Foods", "Shell"]

        // Generate expense transactions
        for i in 0..<100 {
            let date = calendar.date(byAdding: .day, value: -i, to: Date()) ?? Date()
            let amount = -Double.random(in: 5...200)
            let category = categories.randomElement() ?? "Other"
            let merchant = merchants.randomElement() ?? "Unknown"

            transactions.append(FinancialTransaction(
                amount: amount,
                description: "\(merchant) Purchase",
                category: category,
                merchant: merchant,
                date: date
            ))
        }

        // Generate income transactions
        for i in 0..<12 {
            let date = calendar.date(byAdding: .day, value: -i * 7, to: Date()) ?? Date()
            let amount = Double.random(in: 2000...4000)

            transactions.append(FinancialTransaction(
                amount: amount,
                description: "Salary Deposit",
                category: "Income",
                merchant: "Employer",
                date: date
            ))
        }

        return transactions
    }

    private func generateSampleSubscriptions() -> [Subscription] {
        [
            Subscription(
                name: "Netflix",
                amount: 15.99,
                billingCycle: .monthly,
                nextRenewalDate: Date(),
                category: "Entertainment",
                icon: "tv.fill",
                color: .red
            ),
            Subscription(
                name: "Spotify",
                amount: 9.99,
                billingCycle: .monthly,
                nextRenewalDate: Date(),
                category: "Music",
                icon: "music.note",
                color: .green
            )
        ]
    }

    private func generateSampleBudgetVariance() -> BudgetVarianceAnalysis {
        let sampleVariances = [
            CategoryVariance(category: "Food", budgeted: 800, actual: 950, variance: 150, variancePercentage: 18.75, status: .nearBudget),
            CategoryVariance(category: "Transportation", budgeted: 300, actual: 275, variance: -25, variancePercentage: -8.33, status: .onTrack),
            CategoryVariance(category: "Entertainment", budgeted: 200, actual: 320, variance: 120, variancePercentage: 60, status: .overBudget),
            CategoryVariance(category: "Shopping", budgeted: 500, actual: 450, variance: -50, variancePercentage: -10, status: .wellUnderBudget)
        ]

        return BudgetVarianceAnalysis(
            totalBudgeted: 1800,
            totalActual: 1995,
            overallVariance: 195,
            overallVariancePercentage: 10.83,
            categoryVariances: sampleVariances,
            insights: [
                AnalyticsInsight(
                    type: .warning,
                    title: "Entertainment Over Budget",
                    description: "Entertainment spending is 60% over budget this month.",
                    actionable: true
                )
            ]
        )
    }
}

// MARK: - Tab Button

struct AnalyticsTabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isSelected ? Color.purple : Color.clear)
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Insight Detail Sheet

struct InsightDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    let insight: AnalyticsInsight

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Image(systemName: iconForInsightType(insight.type))
                        .font(.title)
                        .foregroundColor(colorForInsightType(insight.type))

                    VStack(alignment: .leading) {
                        Text(insight.title)
                            .font(.title2)
                            .fontWeight(.bold)

                        Text(typeDescription(insight.type))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()
                }

                Text(insight.description)
                    .font(.body)
                    .foregroundColor(.primary)

                if insight.actionable {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recommended Actions")
                            .font(.headline)
                            .fontWeight(.semibold)

                        VStack(alignment: .leading, spacing: 8) {
                            ActionItem(text: "Review recent transactions in this category")
                            ActionItem(text: "Set up spending alerts for early warnings")
                            ActionItem(text: "Consider adjusting your budget allocation")
                        }
                    }
                    .padding()
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(8)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Insight Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
        .frame(width: 400, height: 300)
    }

    private func iconForInsightType(_ type: InsightType) -> String {
        switch type {
        case .positive: return "checkmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .info: return "info.circle.fill"
        }
    }

    private func colorForInsightType(_ type: InsightType) -> Color {
        switch type {
        case .positive: return .green
        case .warning: return .orange
        case .info: return .blue
        }
    }

    private func typeDescription(_ type: InsightType) -> String {
        switch type {
        case .positive: return "Good news!"
        case .warning: return "Needs attention"
        case .info: return "For your information"
        }
    }
}

struct ActionItem: View {
    let text: String

    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle")
                .foregroundColor(.blue)
                .frame(width: 16)

            Text(text)
                .font(.body)
        }
    }
}

#Preview {
    AdvancedAnalyticsView()
        .frame(width: 900, height: 700)
}
