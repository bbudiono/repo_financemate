import CoreData
import SwiftUI

struct BudgetManagementView: View {
    // MARK: - State Management
    @StateObject private var taskMasterService = TaskMasterAIService()
    @State private var selectedTab: BudgetTab = .overview
    @State private var showingCreateBudget = false
    @State private var showingBudgetDetail: Budget?
    @State private var searchText = ""
    @State private var budgets: [BudgetData] = []
    @State private var isLoading = false

    var filteredBudgets: [BudgetData] {
        if searchText.isEmpty {
            return budgets
        } else {
            return budgets.filter { budget in
                budget.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        NavigationView {
            // Sidebar
            VStack(spacing: 0) {
                budgetSidebarHeader
                Divider()
                budgetSidebarNavigation
                Divider()
                budgetSummaryCard

                // TaskMaster Integration Panel
                TaskMasterBudgetPanel(taskMasterService: taskMasterService)
            }
            .frame(minWidth: 280)
            .background(Color(NSColor.controlBackgroundColor))

            // Main Content
            Group {
                switch selectedTab {
                case .overview:
                    budgetOverviewContent
                case .budgets:
                    budgetListContent
                case .categories:
                    categoriesContent
                case .analytics:
                    budgetAnalyticsContent
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationTitle("Budget Management")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    createBudgetWithTaskMaster()
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("New Budget")
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .sheet(isPresented: $showingCreateBudget) {
            CreateBudgetViewSandbox(onBudgetCreated: addBudget)
        }
        .sheet(item: $showingBudgetDetail) { budget in
            BudgetDetailViewSandbox(budget: budget)
        }
        .onAppear {
            loadSampleBudgets()
            initializeTaskMasterIntegration()
        }
    }

    // MARK: - Sidebar Components

    private var budgetSidebarHeader: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.pie.fill")
                .font(.system(size: 32))
                .foregroundColor(.green)

            Text("Budget Manager")
                .font(.title2)
                .fontWeight(.bold)

            Text("Smart Budget Planning & Tracking")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }

    private var budgetSidebarNavigation: some View {
        List(BudgetTab.allCases, id: \.self, selection: $selectedTab) { tab in
            Label(tab.title, systemImage: tab.icon)
                .foregroundColor(selectedTab == tab ? .blue : .primary)
                .onTapGesture {
                    trackTabSelection(tab)
                }
        }
        .listStyle(.sidebar)
    }

    private var budgetSummaryCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Quick Stats")
                .font(.headline)
                .fontWeight(.semibold)

            if let activeBudget = budgets.first(where: { $0.isActive }) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Active Budget")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Circle()
                            .fill(Color.green)
                            .frame(width: 6, height: 6)
                    }

                    Text(activeBudget.name)
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Text("$\(activeBudget.remainingAmount, specifier: "%.0f") remaining")
                        .font(.caption2)
                        .foregroundColor(activeBudget.remainingAmount >= 0 ? .green : .red)
                }
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "chart.pie")
                        .font(.title2)
                        .foregroundColor(.secondary)

                    Text("No Active Budget")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(8)
        .padding()
    }

    // MARK: - Overview Content

    private var budgetOverviewContent: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                budgetOverviewCards
                activeBudgetProgress
                recentBudgetActivity
                budgetInsights
            }
            .padding()
        }
    }

    private var budgetOverviewCards: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            BudgetOverviewCard(
                title: "Total Budgets",
                value: "\(budgets.count)",
                icon: "chart.pie.fill",
                color: .blue
            )

            BudgetOverviewCard(
                title: "Active Budgets",
                value: "\(budgets.filter { $0.isActive }.count)",
                icon: "play.circle.fill",
                color: .green
            )

            BudgetOverviewCard(
                title: "Total Budgeted",
                value: formatCurrency(totalBudgetedAmount),
                icon: "dollarsign.circle.fill",
                color: .purple
            )

            BudgetOverviewCard(
                title: "Total Spent",
                value: formatCurrency(totalSpentAmount),
                icon: "creditcard.fill",
                color: .orange
            )
        }
    }

    private var activeBudgetProgress: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Active Budget Progress")
                .font(.headline)
                .fontWeight(.semibold)

            if let activeBudget = budgets.first(where: { $0.isActive }) {
                BudgetProgressCardSandbox(budget: activeBudget) {
                    showingBudgetDetail = Budget() // Convert BudgetData to Budget if needed
                }
            } else {
                EmptyBudgetStateSandbox {
                    showingCreateBudget = true
                }
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }

    private var recentBudgetActivity: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Activity")
                .font(.headline)
                .fontWeight(.semibold)

            if budgets.isEmpty {
                Text("No budget activity yet")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                ForEach(Array(budgets.prefix(3).enumerated()), id: \.offset) { _, budget in
                    BudgetActivityRowSandbox(budget: budget) {
                        showingBudgetDetail = Budget() // Convert BudgetData to Budget if needed
                    }
                }
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }

    private var budgetInsights: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Budget Insights")
                .font(.headline)
                .fontWeight(.semibold)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                InsightCard(
                    title: "Spending Trend",
                    value: spendingTrendText,
                    icon: spendingTrendIcon,
                    color: spendingTrendColor
                )

                InsightCard(
                    title: "Budget Health",
                    value: budgetHealthText,
                    icon: "heart.fill",
                    color: budgetHealthColor
                )
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }

    // MARK: - Budget List Content

    private var budgetListContent: some View {
        VStack(spacing: 0) {
            // Search and Filter Bar
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search budgets...", text: $searchText)
                        .textFieldStyle(.plain)
                }
                .padding(8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)

                Spacer()

                Button("Create Budget") {
                    createBudgetWithTaskMaster()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()

            Divider()

            // Budget List
            if filteredBudgets.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "chart.pie")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)

                    Text(searchText.isEmpty ? "No budgets created yet" : "No budgets match your search")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    if searchText.isEmpty {
                        Button("Create Your First Budget") {
                            createBudgetWithTaskMaster()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredBudgets, id: \.id) { budget in
                            BudgetListCardSandbox(budget: budget) {
                                showingBudgetDetail = Budget() // Convert BudgetData to Budget if needed
                            }
                        }
                    }
                    .padding()
                }
            }
        }
    }

    // MARK: - Categories Content

    private var categoriesContent: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                Text("Categories view - Coming Soon")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 60)
            }
            .padding()
        }
    }

    // MARK: - Analytics Content

    private var budgetAnalyticsContent: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                Text("Budget Analytics - Coming Soon")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 60)
            }
            .padding()
        }
    }

    // MARK: - TaskMaster Integration Methods

    private func initializeTaskMasterIntegration() {
        Task {
            await taskMasterService.createTask(
                title: "Initialize Budget Management",
                description: "Set up budget management system with TaskMaster AI integration",
                level: .level5,
                priority: .medium,
                estimatedDuration: 5,
                tags: ["budget", "initialization", "system-setup"]
            )
        }
    }

    private func createBudgetWithTaskMaster() {
        Task {
            await taskMasterService.createTask(
                title: "Create New Budget",
                description: "User initiated budget creation through TaskMaster AI workflow",
                level: .level4,
                priority: .high,
                estimatedDuration: 10,
                tags: ["budget", "creation", "user-action"]
            )
        }
        showingCreateBudget = true
    }

    private func trackTabSelection(_ tab: BudgetTab) {
        Task {
            await taskMasterService.trackButtonAction(
                buttonId: "budget_tab_\(tab.rawValue)",
                actionDescription: "Selected \(tab.title) tab",
                userContext: "Budget Management View"
            )
        }
        selectedTab = tab
    }

    // MARK: - Data Management

    private func loadSampleBudgets() {
        budgets = [
            BudgetData(
                id: UUID().uuidString,
                name: "Monthly Budget",
                totalAmount: 3000.0,
                spentAmount: 1200.0,
                isActive: true,
                type: "monthly",
                startDate: Date(),
                endDate: Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
            ),
            BudgetData(
                id: UUID().uuidString,
                name: "Vacation Fund",
                totalAmount: 2000.0,
                spentAmount: 450.0,
                isActive: false,
                type: "project",
                startDate: Calendar.current.date(byAdding: .month, value: -2, to: Date()) ?? Date(),
                endDate: Calendar.current.date(byAdding: .month, value: 4, to: Date()) ?? Date()
            )
        ]
    }

    private func addBudget(_ budget: BudgetData) {
        budgets.append(budget)
        Task {
            await taskMasterService.createTask(
                title: "Budget Created: \(budget.name)",
                description: "Successfully created new budget with amount $\(budget.totalAmount)",
                level: .level3,
                priority: .medium,
                estimatedDuration: 2,
                tags: ["budget", "created", "success"]
            )
        }
    }

    // MARK: - Computed Properties

    private var totalBudgetedAmount: Double {
        budgets.reduce(0.0) { total, budget in
            total + budget.totalAmount
        }
    }

    private var totalSpentAmount: Double {
        budgets.reduce(0.0) { total, budget in
            total + budget.spentAmount
        }
    }

    private var spendingTrendText: String {
        if totalSpentAmount > totalBudgetedAmount * 0.8 {
            return "High"
        } else if totalSpentAmount > totalBudgetedAmount * 0.5 {
            return "Moderate"
        } else {
            return "Low"
        }
    }

    private var spendingTrendIcon: String {
        if totalSpentAmount > totalBudgetedAmount * 0.8 {
            return "arrow.up.circle.fill"
        } else if totalSpentAmount > totalBudgetedAmount * 0.5 {
            return "minus.circle.fill"
        } else {
            return "arrow.down.circle.fill"
        }
    }

    private var spendingTrendColor: Color {
        if totalSpentAmount > totalBudgetedAmount * 0.8 {
            return .red
        } else if totalSpentAmount > totalBudgetedAmount * 0.5 {
            return .orange
        } else {
            return .green
        }
    }

    private var budgetHealthText: String {
        let overBudgetCount = budgets.filter { $0.isOverBudget }.count
        let totalBudgets = budgets.count

        if totalBudgets == 0 {
            return "No Data"
        } else if overBudgetCount == 0 {
            return "Excellent"
        } else if overBudgetCount <= totalBudgets / 3 {
            return "Good"
        } else {
            return "Needs Attention"
        }
    }

    private var budgetHealthColor: Color {
        let overBudgetCount = budgets.filter { $0.isOverBudget }.count
        let totalBudgets = budgets.count

        if totalBudgets == 0 {
            return .gray
        } else if overBudgetCount == 0 {
            return .green
        } else if overBudgetCount <= totalBudgets / 3 {
            return .orange
        } else {
            return .red
        }
    }

    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
}

// MARK: - Supporting Types and Views

enum BudgetTab: String, CaseIterable {
    case overview, budgets, categories, analytics

    var title: String {
        switch self {
        case .overview: return "📊 Overview"
        case .budgets: return "💰 Budgets"
        case .categories: return "📋 Categories"
        case .analytics: return "📈 Analytics"
        }
    }

    var icon: String {
        switch self {
        case .overview: return "chart.pie.fill"
        case .budgets: return "dollarsign.circle.fill"
        case .categories: return "list.clipboard.fill"
        case .analytics: return "chart.bar.xaxis"
        }
    }
}

// MARK: - Budget Data Model for Sandbox

struct BudgetData: Identifiable {
    let id: String
    var name: String
    var totalAmount: Double
    var spentAmount: Double
    var isActive: Bool
    var type: String
    var startDate: Date
    var endDate: Date

    var remainingAmount: Double {
        totalAmount - spentAmount
    }

    var isOverBudget: Bool {
        spentAmount > totalAmount
    }

    var progressPercentage: Double {
        guard totalAmount > 0 else { return 0 }
        return (spentAmount / totalAmount) * 100
    }
}

// MARK: - Supporting View Components

struct BudgetOverviewCard: View {
    let title: String
    let value: String
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

            Text(value)
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
}

// MARK: - TaskMaster Integration Panel

struct TaskMasterBudgetPanel: View {
    @ObservedObject var taskMasterService: TaskMasterAIService
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: { isExpanded.toggle() }) {
                HStack {
                    Image(systemName: "brain.head.profile")
                        .foregroundColor(.blue)

                    Text("TaskMaster AI")
                        .font(.caption)
                        .fontWeight(.semibold)

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Active Tasks:")
                            .font(.caption2)
                            .foregroundColor(.secondary)

                        Spacer()

                        Text("\(taskMasterService.activeTasks.count)")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }

                    HStack {
                        Text("Completed:")
                            .font(.caption2)
                            .foregroundColor(.secondary)

                        Spacer()

                        Text("\(taskMasterService.completedTasks.count)")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    }

                    if taskMasterService.isProcessing {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.6)
                            Text("Processing...")
                                .font(.caption2)
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(8)
        .padding()
    }
}

// MARK: - Placeholder Components

struct BudgetProgressCardSandbox: View {
    let budget: BudgetData
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(budget.name)
                        .font(.headline)
                        .fontWeight(.semibold)

                    Spacer()

                    Text("\(Int(budget.progressPercentage))%")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(budget.isOverBudget ? .red : .blue)
                }

                ProgressView(value: budget.progressPercentage, total: 100)
                    .progressViewStyle(LinearProgressViewStyle(tint: budget.isOverBudget ? .red : .blue))
                    .frame(height: 8)

                HStack {
                    Text("Spent: $\(budget.spentAmount, specifier: "%.0f")")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text("Budget: $\(budget.totalAmount, specifier: "%.0f")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

struct EmptyBudgetStateSandbox: View {
    let onCreate: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.pie")
                .font(.system(size: 48))
                .foregroundColor(.secondary)

            Text("No Active Budget")
                .font(.headline)
                .foregroundColor(.secondary)

            Button("Create Budget") {
                onCreate()
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.vertical, 40)
    }
}

struct BudgetActivityRowSandbox: View {
    let budget: BudgetData
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: "chart.pie.fill")
                    .foregroundColor(.blue)

                VStack(alignment: .leading, spacing: 2) {
                    Text(budget.name)
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Text("\(budget.type.capitalized) budget")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Text("$\(budget.spentAmount, specifier: "%.0f")")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(budget.isOverBudget ? .red : .primary)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}

struct BudgetListCardSandbox: View {
    let budget: BudgetData
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(budget.name)
                            .font(.headline)
                            .fontWeight(.semibold)

                        Text("\(budget.type.capitalized) budget")
                            .font(.caption)
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
                    }
                }

                HStack {
                    Text("Spent: $\(budget.spentAmount, specifier: "%.0f")")
                        .font(.subheadline)

                    Spacer()

                    Text("Budget: $\(budget.totalAmount, specifier: "%.0f")")
                        .font(.subheadline)
                }

                ProgressView(value: budget.progressPercentage, total: 100)
                    .progressViewStyle(LinearProgressViewStyle(tint: budget.isOverBudget ? .red : .blue))
                    .frame(height: 6)
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Placeholder Views for Supporting Components

struct CreateBudgetViewSandbox: View {
    let onBudgetCreated: (BudgetData) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            VStack {
                Text("Create Budget Feature")
                    .font(.headline)

                Text("TaskMaster AI Integration - Coming Soon")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(width: 400, height: 300)
            .navigationTitle("Create Budget")
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

struct BudgetDetailViewSandbox: View {
    let budget: Budget
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            VStack {
                Text("Budget Detail Feature")
                    .font(.headline)

                Text("TaskMaster AI Integration - Coming Soon")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(width: 600, height: 500)
            .navigationTitle("Budget Details")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Temporary Budget Model for Demo

class Budget: ObservableObject, Identifiable {
    let id = UUID()

    init() {}
}

#Preview {
    BudgetManagementView()
}
