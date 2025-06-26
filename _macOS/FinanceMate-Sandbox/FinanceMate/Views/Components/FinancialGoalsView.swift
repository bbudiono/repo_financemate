import Charts
import SwiftUI

struct FinancialGoalsView: View {
    @StateObject private var goalsEngine = FinancialGoalsEngine()
    @State private var selectedTab = 0
    @State private var showingCreateGoal = false
    @State private var showingGoalDetail: FinancialGoalModel?

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Financial Goals")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Spacer()

                Button("New Goal") {
                    showingCreateGoal = true
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()

            // Tab Selector
            tabSelector

            // Tab Content
            TabView(selection: $selectedTab) {
                overviewTab.tag(0)
                activeGoalsTab.tag(1)
                achievementsTab.tag(2)
                insightsTab.tag(3)
            }
            .tabViewStyle(.automatic)
        }
        .sheet(isPresented: $showingCreateGoal) {
            CreateGoalView { goal in
                _ = goalsEngine.createGoal(
                    name: goal.name,
                    targetAmount: goal.targetAmount,
                    targetDate: goal.targetDate,
                    category: goal.category
                )
                showingCreateGoal = false
            }
        }
        .sheet(item: $showingGoalDetail) { goal in
            GoalDetailView(goal: goal, engine: goalsEngine)
        }
        .onAppear {
            loadSampleGoals()
        }
    }

    // MARK: - Tab Selector

    private var tabSelector: some View {
        HStack(spacing: 0) {
            TabButton(title: "Overview", isSelected: selectedTab == 0) {
                selectedTab = 0
            }
            TabButton(title: "Active Goals", isSelected: selectedTab == 1) {
                selectedTab = 1
            }
            TabButton(title: "Achievements", isSelected: selectedTab == 2) {
                selectedTab = 2
            }
            TabButton(title: "Insights", isSelected: selectedTab == 3) {
                selectedTab = 3
            }
        }
        .background(Color(.controlBackgroundColor))
    }

    // MARK: - Overview Tab

    private var overviewTab: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // Summary Cards
                HStack(spacing: 16) {
                    GoalsSummaryCard(
                        title: "Active Goals",
                        value: "\(goalsEngine.activeGoals.count)",
                        icon: "target",
                        color: .blue
                    )

                    GoalsSummaryCard(
                        title: "Total Target",
                        value: "$\(String(format: "%.0f", totalTargetAmount))",
                        icon: "dollarsign.circle",
                        color: .green
                    )

                    GoalsSummaryCard(
                        title: "Saved",
                        value: "$\(String(format: "%.0f", totalCurrentAmount))",
                        icon: "checkmark.circle",
                        color: .mint
                    )

                    GoalsSummaryCard(
                        title: "Completed",
                        value: "\(goalsEngine.completedGoals.count)",
                        icon: "trophy",
                        color: .yellow
                    )
                }

                // Progress Overview Chart
                if !goalsEngine.activeGoals.isEmpty {
                    ProgressOverviewChart(goals: goalsEngine.activeGoals)
                }

                // Recent Goals
                RecentGoalsSection(
                    goals: Array(goalsEngine.activeGoals.prefix(3))
                ) { goal in
                        showingGoalDetail = goal
                    }
            }
            .padding()
        }
    }

    // MARK: - Active Goals Tab

    private var activeGoalsTab: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(goalsEngine.activeGoals) { goal in
                    GoalCard(
                        goal: goal,
                        progress: goalsEngine.calculateGoalProgress(goal),
                        onTap: {
                            showingGoalDetail = goal
                        },
                        onUpdateProgress: { newAmount in
                            goalsEngine.updateGoalProgress(goal.id, newAmount: newAmount)
                        }
                    )
                }

                if goalsEngine.activeGoals.isEmpty {
                    EmptyStateView(
                        title: "No Active Goals",
                        message: "Create your first financial goal to start saving",
                        actionTitle: "Create Goal"
                    ) {
                            showingCreateGoal = true
                        }
                }
            }
            .padding()
        }
    }

    // MARK: - Achievements Tab

    private var achievementsTab: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                // Completed Goals
                if !goalsEngine.completedGoals.isEmpty {
                    Section("Completed Goals") {
                        ForEach(goalsEngine.completedGoals) { goal in
                            CompletedGoalCard(goal: goal)
                        }
                    }
                }

                // Achievement History
                if !goalsEngine.goalAchievements.isEmpty {
                    Section("Recent Achievements") {
                        ForEach(goalsEngine.goalAchievements.sorted { $0.achievedDate > $1.achievedDate }) { achievement in
                            AchievementCard(achievement: achievement)
                        }
                    }
                }

                if goalsEngine.completedGoals.isEmpty && goalsEngine.goalAchievements.isEmpty {
                    EmptyStateView(
                        title: "No Achievements Yet",
                        message: "Complete goals and milestones to unlock achievements",
                        actionTitle: "View Active Goals"
                    ) {
                            selectedTab = 1
                        }
                }
            }
            .padding()
        }
    }

    // MARK: - Insights Tab

    private var insightsTab: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(goalsEngine.activeGoals) { goal in
                    let insights = goalsEngine.generateGoalInsights(goal)
                    if !insights.isEmpty {
                        GoalInsightsSection(goal: goal, insights: insights)
                    }
                }

                if goalsEngine.activeGoals.isEmpty {
                    EmptyStateView(
                        title: "No Insights Available",
                        message: "Create goals to receive personalized insights and recommendations",
                        actionTitle: "Create Goal"
                    ) {
                            showingCreateGoal = true
                        }
                }
            }
            .padding()
        }
    }

    // MARK: - Computed Properties

    private var totalTargetAmount: Double {
        goalsEngine.activeGoals.reduce(0) { $0 + $1.targetAmount }
    }

    private var totalCurrentAmount: Double {
        goalsEngine.activeGoals.reduce(0) { $0 + $1.currentAmount }
    }

    // MARK: - Helper Methods

    private func loadSampleGoals() {
        // Create sample goals for demonstration
        if goalsEngine.activeGoals.isEmpty {
            _ = goalsEngine.createGoal(
                name: "Emergency Fund",
                targetAmount: 10_000,
                currentAmount: 3500,
                targetDate: Calendar.current.date(byAdding: .month, value: 12, to: Date())!,
                category: .emergency
            )

            _ = goalsEngine.createGoal(
                name: "Europe Vacation",
                targetAmount: 5000,
                currentAmount: 1200,
                targetDate: Calendar.current.date(byAdding: .month, value: 8, to: Date())!,
                category: .vacation
            )

            _ = goalsEngine.createGoal(
                name: "House Down Payment",
                targetAmount: 50_000,
                currentAmount: 12_000,
                targetDate: Calendar.current.date(byAdding: .year, value: 3, to: Date())!,
                category: .house
            )
        }
    }
}

// MARK: - Supporting Views

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.accentColor : Color.clear)
                .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

struct GoalsSummaryCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.controlBackgroundColor))
        .cornerRadius(12)
    }
}

struct ProgressOverviewChart: View {
    let goals: [FinancialGoalModel]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Goals Progress")
                .font(.headline)

            Chart(goals, id: \.id) { goal in
                BarMark(
                    x: .value("Progress", goal.progressPercentage),
                    y: .value("Goal", goal.name)
                )
                .foregroundStyle(goal.category.color.gradient)
            }
            .frame(height: 200)
        }
        .padding()
        .background(Color(.controlBackgroundColor))
        .cornerRadius(12)
    }
}

struct RecentGoalsSection: View {
    let goals: [FinancialGoalModel]
    let onGoalTap: (FinancialGoalModel) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Goals")
                .font(.headline)

            ForEach(goals) { goal in
                GoalRowView(goal: goal) {
                    onGoalTap(goal)
                }
            }
        }
        .padding()
        .background(Color(.controlBackgroundColor))
        .cornerRadius(12)
    }
}

struct GoalRowView: View {
    let goal: FinancialGoalModel
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: goal.category.icon)
                    .foregroundColor(goal.category.color)
                    .frame(width: 20)

                VStack(alignment: .leading, spacing: 2) {
                    Text(goal.name)
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Text("$\(String(format: "%.0f", goal.currentAmount)) / $\(String(format: "%.0f", goal.targetAmount))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Text("\(String(format: "%.1f", goal.progressPercentage))%")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(goal.category.color)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}

struct GoalCard: View {
    let goal: FinancialGoalModel
    let progress: GoalProgress
    let onTap: () -> Void
    let onUpdateProgress: (Double) -> Void

    @State private var showingUpdateSheet = false

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                // Header
                HStack {
                    Image(systemName: goal.category.icon)
                        .foregroundColor(goal.category.color)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(goal.name)
                            .font(.headline)
                            .foregroundColor(.primary)

                        Text(goal.category.rawValue)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(String(format: "%.1f", progress.progressPercentage))%")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(goal.category.color)

                        Text("\(progress.daysRemaining) days")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                // Progress Bar
                ProgressView(value: progress.progressPercentage / 100)
                    .progressViewStyle(LinearProgressViewStyle(tint: goal.category.color))

                // Amounts
                HStack {
                    Text("$\(String(format: "%.2f", goal.currentAmount))")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Spacer()

                    Text("$\(String(format: "%.2f", goal.targetAmount))")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }

                // Daily savings needed
                if progress.dailySavingsNeeded > 0 {
                    HStack {
                        Text("Save $\(String(format: "%.2f", progress.dailySavingsNeeded))/day to reach goal")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Spacer()
                    }
                }
            }
            .padding()
            .background(Color(.controlBackgroundColor))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button("Update Progress") {
                showingUpdateSheet = true
            }

            Button("Goal Details") {
                onTap()
            }
        }
        .sheet(isPresented: $showingUpdateSheet) {
            UpdateProgressSheet(
                goal: goal,
                onUpdate: onUpdateProgress
            )
        }
    }
}

struct CompletedGoalCard: View {
    let goal: FinancialGoalModel

    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.title2)

            VStack(alignment: .leading, spacing: 4) {
                Text(goal.name)
                    .font(.headline)

                Text("Completed • $\(String(format: "%.2f", goal.targetAmount))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "trophy.fill")
                .foregroundColor(.yellow)
                .font(.title2)
        }
        .padding()
        .background(Color(.controlBackgroundColor))
        .cornerRadius(12)
    }
}

struct AchievementCard: View {
    let achievement: GoalAchievement

    var body: some View {
        HStack {
            Image(systemName: achievement.type == .completion ? "trophy.fill" : "flag.checkered")
                .foregroundColor(achievement.type == .completion ? .yellow : .blue)
                .font(.title2)

            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.title)
                    .font(.headline)

                Text(achievement.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text(achievement.achievedDate, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(Color(.controlBackgroundColor))
        .cornerRadius(12)
    }
}

struct GoalInsightsSection: View {
    let goal: FinancialGoalModel
    let insights: [GoalInsight]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: goal.category.icon)
                    .foregroundColor(goal.category.color)

                Text(goal.name)
                    .font(.headline)
            }

            ForEach(insights.indices, id: \.self) { index in
                GoalsInsightCard(insight: insights[index])
            }
        }
        .padding()
        .background(Color(.controlBackgroundColor))
        .cornerRadius(12)
    }
}

struct GoalsInsightCard: View {
    let insight: GoalInsight

    var body: some View {
        HStack {
            Image(systemName: iconForInsightType(insight.type))
                .foregroundColor(colorForPriority(insight.priority))

            VStack(alignment: .leading, spacing: 2) {
                Text(insight.title)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(insight.message)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 8)
    }

    private func iconForInsightType(_ type: InsightType) -> String {
        switch type {
        case .achievement: return "star.fill"
        case .warning: return "exclamationmark.triangle"
        case .urgency: return "clock.fill"
        case .milestone: return "flag.fill"
        case .suggestion: return "lightbulb.fill"
        }
    }

    private func colorForPriority(_ priority: GoalInsightPriority) -> Color {
        switch priority {
        case .low: return .secondary
        case .medium: return .blue
        case .high: return .red
        }
    }
}

struct EmptyStateView: View {
    let title: String
    let message: String
    let actionTitle: String
    let action: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "target")
                .font(.system(size: 48))
                .foregroundColor(.secondary)

            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button(actionTitle, action: action)
                .buttonStyle(.borderedProminent)
        }
        .padding(40)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Create Goal Sheet

struct CreateGoalView: View {
    let onSave: (CreateGoalData) -> Void

    @State private var name = ""
    @State private var targetAmount = ""
    @State private var targetDate = Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date()
    @State private var selectedCategory = GoalCategory.other
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            Form {
                Section("Goal Details") {
                    TextField("Goal Name", text: $name)
                    TextField("Target Amount", text: $targetAmount)
                    DatePicker("Target Date", selection: $targetDate, displayedComponents: .date)

                    Picker("Category", selection: $selectedCategory) {
                        ForEach(GoalCategory.allCases, id: \.self) { category in
                            Label(category.rawValue, systemImage: category.icon)
                                .tag(category)
                        }
                    }
                }
            }
            .navigationTitle("Create Goal")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveGoal()
                    }
                    .disabled(name.isEmpty || targetAmount.isEmpty)
                }
            }
        }
        .frame(width: 400, height: 300)
    }

    private func saveGoal() {
        guard let amount = Double(targetAmount) else { return }

        let goalData = CreateGoalData(
            name: name,
            targetAmount: amount,
            targetDate: targetDate,
            category: selectedCategory
        )

        onSave(goalData)
    }
}

struct CreateGoalData {
    let name: String
    let targetAmount: Double
    let targetDate: Date
    let category: GoalCategory
}

// MARK: - Goal Detail Sheet

struct GoalDetailView: View {
    let goal: FinancialGoalModel
    let engine: FinancialGoalsEngine
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Goal Overview
                    GoalOverviewSection(goal: goal, engine: engine)

                    // Milestones
                    MilestonesSection(goal: goal)

                    // Insights
                    let insights = engine.generateGoalInsights(goal)
                    if !insights.isEmpty {
                        GoalInsightsSection(goal: goal, insights: insights)
                    }
                }
                .padding()
            }
            .navigationTitle(goal.name)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .frame(width: 600, height: 500)
    }
}

struct GoalOverviewSection: View {
    let goal: FinancialGoalModel
    let engine: FinancialGoalsEngine

    var body: some View {
        let progress = engine.calculateGoalProgress(goal)

        VStack(spacing: 16) {
            // Progress Circle
            ZStack {
                Circle()
                    .stroke(Color.secondary.opacity(0.3), lineWidth: 8)

                Circle()
                    .trim(from: 0, to: progress.progressPercentage / 100)
                    .stroke(goal.category.color.gradient, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))

                VStack {
                    Text("\(String(format: "%.1f", progress.progressPercentage))%")
                        .font(.title)
                        .fontWeight(.bold)

                    Text("Complete")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 120, height: 120)

            // Details
            VStack(spacing: 8) {
                HStack {
                    Text("Current Amount:")
                    Spacer()
                    Text("$\(String(format: "%.2f", goal.currentAmount))")
                        .fontWeight(.medium)
                }

                HStack {
                    Text("Target Amount:")
                    Spacer()
                    Text("$\(String(format: "%.2f", goal.targetAmount))")
                        .fontWeight(.medium)
                }

                HStack {
                    Text("Remaining:")
                    Spacer()
                    Text("$\(String(format: "%.2f", progress.remainingAmount))")
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text("Days Remaining:")
                    Spacer()
                    Text("\(progress.daysRemaining)")
                        .fontWeight(.medium)
                }

                if progress.dailySavingsNeeded > 0 {
                    HStack {
                        Text("Daily Savings Needed:")
                        Spacer()
                        Text("$\(String(format: "%.2f", progress.dailySavingsNeeded))")
                            .fontWeight(.medium)
                            .foregroundColor(progress.isOnTrack ? .green : .red)
                    }
                }
            }
        }
        .padding()
        .background(Color(.controlBackgroundColor))
        .cornerRadius(12)
    }
}

struct MilestonesSection: View {
    let goal: FinancialGoalModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Milestones")
                .font(.headline)

            ForEach(goal.milestones) { milestone in
                MilestoneRow(milestone: milestone, currentAmount: goal.currentAmount)
            }
        }
        .padding()
        .background(Color(.controlBackgroundColor))
        .cornerRadius(12)
    }
}

struct MilestoneRow: View {
    let milestone: GoalMilestone
    let currentAmount: Double

    var body: some View {
        HStack {
            Image(systemName: milestone.isAchieved ? "checkmark.circle.fill" : "circle")
                .foregroundColor(milestone.isAchieved ? .green : .secondary)

            VStack(alignment: .leading, spacing: 2) {
                Text(milestone.name)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text("$\(String(format: "%.2f", milestone.targetAmount))")
                    .font(.caption)
                    .foregroundColor(.secondary)

                if let achievedDate = milestone.achievedDate {
                    Text("Achieved \(achievedDate, style: .date)")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }

            Spacer()

            if !milestone.isAchieved && currentAmount >= milestone.targetAmount {
                Text("Ready!")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(4)
            }
        }
    }
}

// MARK: - Update Progress Sheet

struct UpdateProgressSheet: View {
    let goal: FinancialGoalModel
    let onUpdate: (Double) -> Void

    @State private var newAmount: String
    @Environment(\.dismiss) private var dismiss

    init(goal: FinancialGoalModel, onUpdate: @escaping (Double) -> Void) {
        self.goal = goal
        self.onUpdate = onUpdate
        self._newAmount = State(initialValue: String(format: "%.2f", goal.currentAmount))
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Update Progress") {
                    TextField("Current Amount", text: $newAmount)

                    Text("Previous: $\(String(format: "%.2f", goal.currentAmount))")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("Target: $\(String(format: "%.2f", goal.targetAmount))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Update \(goal.name)")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Update") {
                        updateProgress()
                    }
                    .disabled(newAmount.isEmpty)
                }
            }
        }
        .frame(width: 300, height: 200)
    }

    private func updateProgress() {
        guard let amount = Double(newAmount) else { return }
        onUpdate(amount)
        dismiss()
    }
}

#Preview {
    FinancialGoalsView()
}
