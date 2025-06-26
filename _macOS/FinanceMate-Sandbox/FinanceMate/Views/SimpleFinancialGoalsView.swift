import CoreData
import SwiftUI

struct SimpleFinancialGoalsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedTab: Int = 0
    @State private var showingCreateGoal = false

    private let tabs = ["Goals", "Progress", "Achievements", "Settings"]

    var body: some View {
        VStack(spacing: 0) {
            // Tab Picker
            Picker("Goals Tabs", selection: $selectedTab) {
                ForEach(0..<tabs.count, id: \.self) { index in
                    Text(tabs[index]).tag(index)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal, 20)
            .padding(.top, 20)

            // Tab Content
            Group {
                switch selectedTab {
                case 0:
                    GoalsOverviewView()
                case 1:
                    GoalsProgressView()
                case 2:
                    GoalsAchievementsView()
                case 3:
                    GoalsSettingsView()
                default:
                    GoalsOverviewView()
                }
            }
        }
        .navigationTitle("Financial Goals")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("New Goal") {
                    showingCreateGoal = true
                }
            }
        }
        .sheet(isPresented: $showingCreateGoal) {
            CreateGoalSheet()
        }
    }
}

// MARK: - Tab Views

struct GoalsOverviewView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Your Financial Goals")
                        .font(.title2)
                        .fontWeight(.semibold)

                    VStack(spacing: 16) {
                        GoalCard(
                            name: "Emergency Fund",
                            target: 10_000,
                            current: 6500,
                            color: .blue,
                            dueDate: "Dec 2025"
                        )

                        GoalCard(
                            name: "Vacation Fund",
                            target: 3000,
                            current: 1200,
                            color: .green,
                            dueDate: "Jun 2025"
                        )

                        GoalCard(
                            name: "New Car",
                            target: 25_000,
                            current: 8000,
                            color: .orange,
                            dueDate: "Mar 2026"
                        )
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Goal Summary")
                        .font(.title2)
                        .fontWeight(.semibold)

                    HStack(spacing: 20) {
                        SummaryCard(title: "Active Goals", value: "3", color: .blue)
                        SummaryCard(title: "Total Target", value: "$38,000", color: .green)
                        SummaryCard(title: "Total Saved", value: "$15,700", color: .purple)
                    }
                }

                Spacer()
            }
            .padding(20)
        }
    }
}

struct GoalsProgressView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Progress Tracking")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                VStack(spacing: 16) {
                    ProgressCard(
                        name: "Emergency Fund",
                        target: 10_000,
                        current: 6500,
                        monthlyContribution: 500,
                        color: .blue
                    )

                    ProgressCard(
                        name: "Vacation Fund",
                        target: 3000,
                        current: 1200,
                        monthlyContribution: 300,
                        color: .green
                    )

                    ProgressCard(
                        name: "New Car",
                        target: 25_000,
                        current: 8000,
                        monthlyContribution: 750,
                        color: .orange
                    )
                }
                .padding(.horizontal, 20)

                Spacer()
            }
        }
    }
}

struct GoalsAchievementsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Achievements")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                VStack(spacing: 12) {
                    AchievementCard(
                        title: "First Goal Completed",
                        description: "Completed your first financial goal",
                        date: "Jan 2025",
                        isUnlocked: true
                    )

                    AchievementCard(
                        title: "Consistent Saver",
                        description: "Made contributions for 6 months straight",
                        date: "Mar 2025",
                        isUnlocked: true
                    )

                    AchievementCard(
                        title: "Goal Setter",
                        description: "Create 5 financial goals",
                        date: "Locked",
                        isUnlocked: false
                    )

                    AchievementCard(
                        title: "Emergency Ready",
                        description: "Complete your emergency fund goal",
                        date: "Locked",
                        isUnlocked: false
                    )
                }
                .padding(.horizontal, 20)

                Spacer()
            }
        }
    }
}

struct GoalsSettingsView: View {
    @State private var defaultContribution: String = "500"
    @State private var reminderEnabled: Bool = true
    @State private var reminderFrequency: String = "Weekly"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Goal Settings")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Default Monthly Contribution")
                            .font(.headline)
                        TextField("Enter default amount", text: $defaultContribution)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Goal Reminders")
                                .font(.headline)
                            Spacer()
                            Toggle("", isOn: $reminderEnabled)
                        }

                        if reminderEnabled {
                            Picker("Reminder Frequency", selection: $reminderFrequency) {
                                Text("Daily").tag("Daily")
                                Text("Weekly").tag("Weekly")
                                Text("Monthly").tag("Monthly")
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                    }
                }
                .padding(.horizontal, 20)

                Spacer()
            }
        }
    }
}

// MARK: - Supporting Views

struct GoalCard: View {
    let name: String
    let target: Double
    let current: Double
    let color: Color
    let dueDate: String

    var progress: Double {
        current / target
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .font(.headline)
                        .fontWeight(.semibold)

                    Text("Due: \(dueDate)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("$\(Int(current))")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(color)

                    Text("of $\(Int(target))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: color))

                HStack {
                    Text("\(Int(progress * 100))% complete")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text("$\(Int(target - current)) remaining")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(16)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }
}

struct SummaryCard: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

struct ProgressCard: View {
    let name: String
    let target: Double
    let current: Double
    let monthlyContribution: Double
    let color: Color

    var progress: Double {
        current / target
    }

    var monthsRemaining: Int {
        let remaining = target - current
        return Int(ceil(remaining / monthlyContribution))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(name)
                .font(.headline)
                .fontWeight(.semibold)

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current Progress")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("$\(Int(current)) / $\(Int(target))")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Monthly Contribution")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("$\(Int(monthlyContribution))")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(color)
                }
            }

            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: color))

            HStack {
                Text("\(Int(progress * 100))% complete")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Text("~\(monthsRemaining) months remaining")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }
}

struct AchievementCard: View {
    let title: String
    let description: String
    let date: String
    let isUnlocked: Bool

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: isUnlocked ? "star.fill" : "star")
                .font(.title2)
                .foregroundColor(isUnlocked ? .yellow : .gray)
                .frame(width: 40, height: 40)
                .background(isUnlocked ? Color.yellow.opacity(0.1) : Color.gray.opacity(0.1))
                .cornerRadius(8)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(isUnlocked ? .primary : .secondary)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(date)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
        .padding(16)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
        .opacity(isUnlocked ? 1.0 : 0.7)
    }
}

struct CreateGoalSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var goalName: String = ""
    @State private var targetAmount: String = ""
    @State private var dueDate = Date()
    @State private var monthlyContribution: String = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var showingSuccess = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Create New Goal")
                .font(.title2)
                .fontWeight(.semibold)

            VStack(alignment: .leading, spacing: 8) {
                Text("Goal Name")
                    .font(.headline)
                TextField("Enter goal name", text: $goalName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Target Amount")
                    .font(.headline)
                TextField("Enter target amount", text: $targetAmount)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Due Date")
                    .font(.headline)
                DatePicker("", selection: $dueDate, displayedComponents: .date)
                    .datePickerStyle(CompactDatePickerStyle())
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Monthly Contribution")
                    .font(.headline)
                TextField("Enter monthly amount", text: $monthlyContribution)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            HStack(spacing: 12) {
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.bordered)

                Button("Create Goal") {
                    createGoal()
                }
                .buttonStyle(.borderedProminent)
                .disabled(goalName.isEmpty || targetAmount.isEmpty || monthlyContribution.isEmpty)
            }

            Spacer()
        }
        .padding(20)
        .frame(width: 450, height: 400)
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .alert("Success", isPresented: $showingSuccess) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Goal '\(goalName)' created successfully with target $\(targetAmount)")
        }
    }

    private func createGoal() {
        guard let targetAmountValue = Double(targetAmount) else {
            errorMessage = "Please enter a valid target amount"
            showingError = true
            return
        }

        guard let monthlyContributionValue = Double(monthlyContribution) else {
            errorMessage = "Please enter a valid monthly contribution amount"
            showingError = true
            return
        }

        guard targetAmountValue > 0 else {
            errorMessage = "Target amount must be greater than zero"
            showingError = true
            return
        }

        guard monthlyContributionValue > 0 else {
            errorMessage = "Monthly contribution must be greater than zero"
            showingError = true
            return
        }

        guard dueDate > Date() else {
            errorMessage = "Due date must be in the future"
            showingError = true
            return
        }

        // Calculate estimated completion based on monthly contribution
        let monthsToComplete = Int(ceil(targetAmountValue / monthlyContributionValue))

        // Create financial goal using simplified approach
        let goalData: [String: Any] = [
            "id": UUID().uuidString,
            "name": goalName,
            "targetAmount": targetAmountValue,
            "currentAmount": 0.0,
            "monthlyContribution": monthlyContributionValue,
            "dueDate": dueDate,
            "estimatedCompletion": monthsToComplete,
            "isActive": true,
            "dateCreated": Date(),
            "currency": "USD",
            "category": "savings"
        ]

        // Save to UserDefaults as temporary storage
        saveGoalToUserDefaults(goalData)

        showingSuccess = true
    }

    private func saveGoalToUserDefaults(_ goalData: [String: Any]) {
        var existingGoals = UserDefaults.standard.array(forKey: "SavedGoals") as? [[String: Any]] ?? []
        existingGoals.append(goalData)
        UserDefaults.standard.set(existingGoals, forKey: "SavedGoals")
        print("✅ Goal saved successfully: \(goalData["name"] ?? "Unknown") - Target: $\(goalData["targetAmount"] ?? 0)")
    }
}

#Preview {
    SimpleFinancialGoalsView()
        .frame(width: 800, height: 600)
}
