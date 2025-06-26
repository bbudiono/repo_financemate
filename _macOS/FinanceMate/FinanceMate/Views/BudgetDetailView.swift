import SwiftUI

struct BudgetDetailView: View {
    let budget: Budget
    @ObservedObject var budgetManager: BudgetManager
    @Environment(\.dismiss) private var dismiss

    @State private var selectedTab: BudgetDetailTab = .overview
    @State private var showingEditBudget = false
    @State private var showingAddCategory = false
    @State private var showingDeleteAlert = false

    private var categories: [BudgetCategory] {
        (budget.categories?.allObjects as? [BudgetCategory])?.sorted { $0.name ?? "" < $1.name ?? "" } ?? []
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                budgetDetailHeader

                Divider()

                // Tab Navigation
                budgetDetailTabNavigation

                Divider()

                // Tab Content
                Group {
                    switch selectedTab {
                    case .overview:
                        budgetOverviewContent
                    case .categories:
                        budgetCategoriesContent
                    case .transactions:
                        budgetTransactionsContent
                    case .analytics:
                        budgetAnalyticsContent
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(width: 800, height: 700)
        .navigationTitle(budget.name ?? "Budget Details")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Done") {
                    dismiss()
                }
            }

            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button("Edit Budget") {
                        showingEditBudget = true
                    }

                    Button("Add Category") {
                        showingAddCategory = true
                    }

                    Divider()

                    Button("Delete Budget", role: .destructive) {
                        showingDeleteAlert = true
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingEditBudget) {
            EditBudgetView(budget: budget, budgetManager: budgetManager)
        }
        .sheet(isPresented: $showingAddCategory) {
            AddCategoryToBudgetView(budget: budget, budgetManager: budgetManager)
        }
        .alert("Delete Budget", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                budgetManager.deleteBudget(budget)
                dismiss()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete this budget? This action cannot be undone.")
        }
    }

    // MARK: - Header

    private var budgetDetailHeader: some View {
        VStack(spacing: 16) {
            // Budget Title and Status
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(budget.name ?? "Unnamed Budget")
                        .font(.title)
                        .fontWeight(.bold)

                    Text(budget.budgetTypeEnum.displayName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(budget.isActive ? Color.green : Color.gray)
                            .frame(width: 8, height: 8)

                        Text(budget.isActive ? "Active" : "Inactive")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(budget.isActive ? .green : .secondary)
                    }

                    if budget.isActive {
                        Text("\(budget.daysRemaining) days remaining")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }

            // Financial Summary Cards
            HStack(spacing: 16) {
                BudgetSummaryCard(
                    title: "Total Budget",
                    amount: budget.totalBudgeted,
                    icon: "dollarsign.circle.fill",
                    color: .blue
                )

                BudgetSummaryCard(
                    title: "Total Spent",
                    amount: budget.totalSpent,
                    icon: "creditcard.fill",
                    color: .orange
                )

                BudgetSummaryCard(
                    title: "Remaining",
                    amount: budget.remainingAmount,
                    icon: budget.remainingAmount >= 0 ? "plus.circle.fill" : "minus.circle.fill",
                    color: budget.remainingAmount >= 0 ? .green : .red
                )

                BudgetProgressSummary(budget: budget)
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
    }

    // MARK: - Tab Navigation

    private var budgetDetailTabNavigation: some View {
        HStack(spacing: 0) {
            ForEach(BudgetDetailTab.allCases, id: \.self) { tab in
                Button(action: { selectedTab = tab }) {
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.title3)
                        Text(tab.title)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(selectedTab == tab ? .blue : .secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(selectedTab == tab ? Color.blue.opacity(0.1) : Color.clear)
                }
                .buttonStyle(.plain)
            }
        }
        .background(Color(NSColor.windowBackgroundColor))
    }

    // MARK: - Overview Content

    private var budgetOverviewContent: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                // Progress Overview
                budgetProgressOverview

                // Category Performance
                categoryPerformanceOverview

                // Recent Activity
                recentActivityOverview

                // Budget Insights
                budgetInsightsOverview
            }
            .padding()
        }
    }

    private var budgetProgressOverview: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Budget Progress")
                .font(.headline)
                .fontWeight(.semibold)

            VStack(spacing: 16) {
                // Main Progress Bar
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Overall Progress")
                            .font(.subheadline)
                            .fontWeight(.medium)

                        Spacer()

                        Text("\(Int(budget.spendingPercentage))%")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(budget.progressColor)
                    }

                    ProgressView(value: budget.spendingPercentage, total: 100)
                        .progressViewStyle(LinearProgressViewStyle(tint: budget.progressColor))
                        .frame(height: 12)
                }

                // Time Progress
                if budget.isActive, let startDate = budget.startDate, let endDate = budget.endDate {
                    let timeProgress = calculateTimeProgress(startDate: startDate, endDate: endDate)

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Time Progress")
                                .font(.subheadline)
                                .fontWeight(.medium)

                            Spacer()

                            Text("\(Int(timeProgress))%")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                        }

                        ProgressView(value: timeProgress, total: 100)
                            .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                            .frame(height: 8)
                    }
                }

                // Budget Health Indicator
                budgetHealthIndicator
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }

    private var categoryPerformanceOverview: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Category Performance")
                    .font(.headline)
                    .fontWeight(.semibold)

                Spacer()

                Button("View All") {
                    selectedTab = .categories
                }
                .font(.caption)
                .foregroundColor(.blue)
            }

            if categories.isEmpty {
                Text("No categories in this budget")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(categories.prefix(6), id: \.objectID) { category in
                        CategoryPerformanceCard(category: category)
                    }
                }
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }

    private var recentActivityOverview: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Activity")
                    .font(.headline)
                    .fontWeight(.semibold)

                Spacer()

                Button("View All") {
                    selectedTab = .transactions
                }
                .font(.caption)
                .foregroundColor(.blue)
            }

            // Placeholder for recent transactions
            VStack(spacing: 12) {
                ForEach(0..<3, id: \.self) { index in
                    HStack {
                        Image(systemName: "creditcard.fill")
                            .foregroundColor(.orange)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Sample Transaction \(index + 1)")
                                .font(.subheadline)
                                .fontWeight(.medium)

                            Text("\(Date().addingTimeInterval(-Double(index) * 86_400), style: .date)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        Text("-$\(Int.random(in: 10...100))")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.red)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }

    private var budgetInsightsOverview: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Budget Insights")
                .font(.headline)
                .fontWeight(.semibold)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                InsightCard(
                    title: "Spending Pace",
                    value: spendingPaceText,
                    icon: spendingPaceIcon,
                    color: spendingPaceColor
                )

                InsightCard(
                    title: "Top Category",
                    value: topSpendingCategory,
                    icon: "chart.bar.fill",
                    color: .purple
                )

                InsightCard(
                    title: "Budget Health",
                    value: budgetHealthText,
                    icon: "heart.fill",
                    color: budgetHealthColor
                )

                InsightCard(
                    title: "Projected Total",
                    value: projectedSpendingText,
                    icon: "chart.line.uptrend.xyaxis",
                    color: .blue
                )
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }

    // MARK: - Categories Content

    private var budgetCategoriesContent: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                // Categories Header
                HStack {
                    Text("Budget Categories (\(categories.count))")
                        .font(.title2)
                        .fontWeight(.bold)

                    Spacer()

                    Button("Add Category") {
                        showingAddCategory = true
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.horizontal)

                // Categories List
                if categories.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "list.clipboard")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)

                        Text("No categories in this budget")
                            .font(.headline)
                            .foregroundColor(.secondary)

                        Button("Add Your First Category") {
                            showingAddCategory = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.vertical, 40)
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(categories, id: \.objectID) { category in
                            DetailedCategoryCard(category: category, budget: budget, budgetManager: budgetManager)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
    }

    // MARK: - Transactions Content

    private var budgetTransactionsContent: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                HStack {
                    Text("Transactions")
                        .font(.title2)
                        .fontWeight(.bold)

                    Spacer()

                    Button("Add Transaction") {
                        // Would open add transaction sheet
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.horizontal)

                // Placeholder for transactions list
                VStack(spacing: 16) {
                    Image(systemName: "creditcard")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)

                    Text("Transaction integration coming soon")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    Text("Connect your accounts or add manual transactions to track spending")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.vertical, 60)
            }
            .padding(.vertical)
        }
    }

    // MARK: - Analytics Content

    private var budgetAnalyticsContent: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                Text("Budget Analytics")
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)

                // Spending Trends Chart
                spendingTrendsChart

                // Category Breakdown Chart
                categoryBreakdownChart

                // Performance Metrics
                performanceMetricsSection
            }
            .padding(.vertical)
        }
    }

    private var spendingTrendsChart: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Spending Trends")
                .font(.headline)
                .fontWeight(.semibold)

            // Placeholder chart
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(NSColor.windowBackgroundColor))
                .frame(height: 200)
                .overlay(
                    VStack {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)

                        Text("Spending trends over time")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                )
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
        .padding(.horizontal)
    }

    private var categoryBreakdownChart: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Category Breakdown")
                .font(.headline)
                .fontWeight(.semibold)

            if !categories.isEmpty {
                CategorySpendingChart(categories: categories)
                    .frame(height: 250)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(NSColor.windowBackgroundColor))
                    .frame(height: 200)
                    .overlay(
                        VStack {
                            Image(systemName: "chart.pie")
                                .font(.largeTitle)
                                .foregroundColor(.secondary)

                            Text("No category data available")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    )
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
        .padding(.horizontal)
    }

    private var performanceMetricsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Performance Metrics")
                .font(.headline)
                .fontWeight(.semibold)

            VStack(spacing: 12) {
                PerformanceMetricRow(
                    title: "Budget Utilization",
                    value: "\(Int(budget.spendingPercentage))%",
                    percentage: budget.spendingPercentage,
                    color: budget.progressColor
                )

                PerformanceMetricRow(
                    title: "Categories on Track",
                    value: "\(categoriesOnTrackCount)/\(categories.count)",
                    percentage: categoriesOnTrackPercentage,
                    color: categoriesOnTrackPercentage > 80 ? .green : .orange
                )

                PerformanceMetricRow(
                    title: "Daily Spending Rate",
                    value: formatCurrency(dailySpendingRate),
                    percentage: min(100, (dailySpendingRate / (budget.totalBudgeted / 30)) * 100),
                    color: dailySpendingRate <= (budget.totalBudgeted / 30) ? .green : .red
                )
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
        .padding(.horizontal)
    }

    // MARK: - Supporting Views

    private var budgetHealthIndicator: some View {
        HStack {
            Image(systemName: budgetHealthIcon)
                .foregroundColor(budgetHealthColor)
                .font(.title2)

            VStack(alignment: .leading, spacing: 4) {
                Text("Budget Health")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(budgetHealthText)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(budgetHealthScore)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(budgetHealthColor)
        }
        .padding()
        .background(budgetHealthColor.opacity(0.1))
        .cornerRadius(8)
    }

    // MARK: - Computed Properties

    private var spendingPaceText: String {
        guard budget.isActive, let startDate = budget.startDate, let endDate = budget.endDate else {
            return "N/A"
        }

        let totalDays = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 1
        let daysPassed = Calendar.current.dateComponents([.day], from: startDate, to: Date()).day ?? 0
        let timePercentage = (Double(daysPassed) / Double(totalDays)) * 100

        if budget.spendingPercentage > timePercentage + 10 {
            return "Fast"
        } else if budget.spendingPercentage < timePercentage - 10 {
            return "Slow"
        } else {
            return "On Track"
        }
    }

    private var spendingPaceIcon: String {
        switch spendingPaceText {
        case "Fast": return "speedometer"
        case "Slow": return "tortoise.fill"
        default: return "checkmark.circle.fill"
        }
    }

    private var spendingPaceColor: Color {
        switch spendingPaceText {
        case "Fast": return .red
        case "Slow": return .blue
        default: return .green
        }
    }

    private var topSpendingCategory: String {
        let sortedCategories = categories.sorted { a, b in
            (a.spentAmount?.doubleValue ?? 0) > (b.spentAmount?.doubleValue ?? 0)
        }
        return sortedCategories.first?.name ?? "N/A"
    }

    private var budgetHealthText: String {
        let score = calculateBudgetHealthScore()
        if score >= 80 {
            return "Excellent"
        } else if score >= 60 {
            return "Good"
        } else if score >= 40 {
            return "Fair"
        } else {
            return "Poor"
        }
    }

    private var budgetHealthColor: Color {
        let score = calculateBudgetHealthScore()
        if score >= 80 {
            return .green
        } else if score >= 60 {
            return .blue
        } else if score >= 40 {
            return .orange
        } else {
            return .red
        }
    }

    private var budgetHealthIcon: String {
        switch budgetHealthText {
        case "Excellent": return "heart.fill"
        case "Good": return "heart"
        case "Fair": return "heart.slash"
        default: return "heart.slash.fill"
        }
    }

    private var budgetHealthScore: String {
        "\(Int(calculateBudgetHealthScore()))/100"
    }

    private var projectedSpendingText: String {
        guard budget.isActive, let startDate = budget.startDate, let endDate = budget.endDate else {
            return "N/A"
        }

        let daysPassed = Calendar.current.dateComponents([.day], from: startDate, to: Date()).day ?? 1
        let totalDays = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 1

        if daysPassed > 0 {
            let dailyRate = budget.totalSpent / Double(daysPassed)
            let projectedTotal = dailyRate * Double(totalDays)
            return formatCurrency(projectedTotal)
        } else {
            return "N/A"
        }
    }

    private var categoriesOnTrackCount: Int {
        categories.filter { !$0.isOverBudget && $0.spentPercentage <= 85 }.count
    }

    private var categoriesOnTrackPercentage: Double {
        guard !categories.isEmpty else { return 0 }
        return (Double(categoriesOnTrackCount) / Double(categories.count)) * 100
    }

    private var dailySpendingRate: Double {
        guard budget.isActive, let startDate = budget.startDate else { return 0 }

        let daysPassed = Calendar.current.dateComponents([.day], from: startDate, to: Date()).day ?? 1
        return budget.totalSpent / Double(max(daysPassed, 1))
    }

    // MARK: - Helper Methods

    private func calculateTimeProgress(startDate: Date, endDate: Date) -> Double {
        let totalDuration = endDate.timeIntervalSince(startDate)
        let elapsed = Date().timeIntervalSince(startDate)
        return min(100, max(0, (elapsed / totalDuration) * 100))
    }

    private func calculateBudgetHealthScore() -> Double {
        var score = 100.0

        // Penalize for overspending
        if budget.isOverBudget {
            score -= 30
        } else if budget.spendingPercentage > 80 {
            score -= 10
        }

        // Penalize for categories over budget
        let overBudgetCategories = categories.filter { $0.isOverBudget }.count
        score -= Double(overBudgetCategories) * 10

        // Reward for balanced spending
        if !categories.isEmpty {
            let balancedCategories = categories.filter { $0.spentPercentage <= 85 && $0.spentPercentage >= 10 }.count
            score += Double(balancedCategories) * 5
        }

        return max(0, min(100, score))
    }

    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
}

// MARK: - Supporting Types and Views

enum BudgetDetailTab: CaseIterable {
    case overview, categories, transactions, analytics

    var title: String {
        switch self {
        case .overview: return "Overview"
        case .categories: return "Categories"
        case .transactions: return "Transactions"
        case .analytics: return "Analytics"
        }
    }

    var icon: String {
        switch self {
        case .overview: return "chart.pie.fill"
        case .categories: return "list.clipboard.fill"
        case .transactions: return "creditcard.fill"
        case .analytics: return "chart.bar.xaxis"
        }
    }
}

struct BudgetSummaryCard: View {
    let title: String
    let amount: Double
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

            Text(formatCurrency(amount))
                .font(.title2)
                .fontWeight(.bold)

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

struct BudgetProgressSummary: View {
    let budget: Budget

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(.purple)
                    .font(.title3)

                Spacer()
            }

            Text("\(Int(budget.spendingPercentage))%")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(budget.progressColor)

            Text("Budget Used")
                .font(.caption)
                .foregroundColor(.secondary)

            ProgressView(value: budget.spendingPercentage, total: 100)
                .progressViewStyle(LinearProgressViewStyle(tint: budget.progressColor))
                .frame(height: 4)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(8)
    }
}

struct CategoryPerformanceCard: View {
    let category: BudgetCategory

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: category.icon ?? "circle.fill")
                    .foregroundColor(category.statusColor)
                    .font(.caption)

                Text(category.name ?? "Unnamed")
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(1)

                Spacer()
            }

            Text("\(Int(category.spentPercentage))%")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(category.statusColor)

            ProgressView(value: category.spentPercentage, total: 100)
                .progressViewStyle(LinearProgressViewStyle(tint: category.statusColor))
                .frame(height: 3)
        }
        .padding(8)
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(6)
    }
}

struct DetailedCategoryCard: View {
    let category: BudgetCategory
    let budget: Budget
    @ObservedObject var budgetManager: BudgetManager

    @State private var showingEditCategory = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: category.icon ?? "circle.fill")
                        .foregroundColor(category.statusColor)
                        .font(.title2)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(category.name ?? "Unnamed Category")
                            .font(.headline)
                            .fontWeight(.semibold)

                        Text(category.categoryTypeEnum.displayName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    if category.isOverBudget {
                        HStack(spacing: 4) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                                .font(.caption)

                            Text("Over Budget")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    } else if category.shouldAlert {
                        HStack(spacing: 4) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundColor(.orange)
                                .font(.caption)

                            Text("Alert")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    } else {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.caption)

                            Text("On Track")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }

                    Button("Edit") {
                        showingEditCategory = true
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }

            // Financial Summary
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Spent")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(formatCurrency(category.spentAmount?.doubleValue ?? 0))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }

                Spacer()

                VStack(alignment: .center, spacing: 4) {
                    Text("Budget")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(formatCurrency(category.budgetedAmount?.doubleValue ?? 0))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Remaining")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(formatCurrency(category.remainingAmount))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(category.remainingAmount >= 0 ? .green : .red)
                }
            }

            // Progress Bar
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("\(Int(category.spentPercentage))% used")
                        .font(.caption)
                        .foregroundColor(category.statusColor)

                    Spacer()

                    if category.alertThreshold > 0 {
                        Text("Alert at \(Int(category.alertThreshold))%")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }

                ProgressView(value: category.spentPercentage, total: 100)
                    .progressViewStyle(LinearProgressViewStyle(tint: category.statusColor))
                    .frame(height: 8)
            }
        }
        .padding()
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(category.isOverBudget ? Color.red.opacity(0.3) : Color.clear, lineWidth: 1)
        )
        .sheet(isPresented: $showingEditCategory) {
            EditCategoryView(category: category, budgetManager: budgetManager)
        }
    }

    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
}

// MARK: - Placeholder Edit Views

struct EditBudgetView: View {
    let budget: Budget
    @ObservedObject var budgetManager: BudgetManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            VStack {
                Text("Edit Budget Feature")
                    .font(.headline)

                Text("Coming Soon")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(width: 400, height: 300)
            .navigationTitle("Edit Budget")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct AddCategoryToBudgetView: View {
    let budget: Budget
    @ObservedObject var budgetManager: BudgetManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            VStack {
                Text("Add Category Feature")
                    .font(.headline)

                Text("Coming Soon")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(width: 400, height: 300)
            .navigationTitle("Add Category")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct EditCategoryView: View {
    let category: BudgetCategory
    @ObservedObject var budgetManager: BudgetManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            VStack {
                Text("Edit Category Feature")
                    .font(.headline)

                Text("Coming Soon")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(width: 400, height: 300)
            .navigationTitle("Edit Category")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    let budget = Budget(context: CoreDataStack.shared.mainContext)
    budget.name = "Monthly Budget"
    budget.totalAmount = NSDecimalNumber(value: 3000)
    budget.budgetType = BudgetType.monthly.rawValue
    budget.isActive = true
    budget.startDate = Date()
    budget.endDate = Calendar.current.date(byAdding: .month, value: 1, to: Date())

    return BudgetDetailView(
        budget: budget,
        budgetManager: BudgetManager(context: CoreDataStack.shared.mainContext)
    )
}
