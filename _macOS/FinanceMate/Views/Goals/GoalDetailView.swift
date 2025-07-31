import Charts
import CoreData
import SwiftUI

/**
 * GoalDetailView.swift
 *
 * Purpose: Provides comprehensive UI for viewing and managing individual financial goals
 * Issues & Complexity Summary: Complex view with progress tracking, charts, and milestone management
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~500+
 *   - Core Algorithm Complexity: Medium-High
 *   - Dependencies: 4 (SwiftUI, CoreData, Charts, Combine)
 *   - State Management Complexity: High
 *   - Novelty/Uncertainty Factor: Medium
 * AI Pre-Task Self-Assessment: 89%
 * Problem Estimate: 91%
 * Initial Code Complexity Estimate: 90%
 * Final Code Complexity: 92%
 * Overall Result Score: 91%
 * Key Variances/Learnings: Comprehensive goal detail view with progress tracking and milestone management
 * Last Updated: 2025-07-11
 */

struct GoalDetailView: View {
  @Environment(\.presentationMode) var presentationMode
  @ObservedObject var goal: FinancialGoal
  @StateObject private var progressViewModel = GoalProgressViewModel()
  @StateObject private var viewModel = FinancialGoalViewModel()

  @State private var showingEditSheet: Bool = false
  @State private var showingAddProgressSheet: Bool = false
  @State private var showingMilestoneSheet: Bool = false
  @State private var showingDeleteAlert: Bool = false
  @State private var selectedProgressPeriod: ProgressPeriod = .month
  @State private var progressAmount: String = ""
  @State private var progressNote: String = ""

  private var currencyFormatter: NumberFormatter {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.locale = Locale(identifier: "en_AU")
    return formatter
  }

  var body: some View {
    ScrollView {
      VStack(spacing: 24) {
        // Goal Header
        goalHeaderSection

        // Progress Overview
        progressOverviewSection

        // Progress Chart
        progressChartSection

        // SMART Status
        smartStatusSection

        // Milestones
        milestonesSection

        // Recent Progress
        recentProgressSection

        // Action Buttons
        actionButtons
      }
      .padding()
    }
    .navigationTitle(goal.title)
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Menu {
          Button(action: { showingEditSheet = true }) {
            Label("Edit Goal", systemImage: "pencil")
          }
          Button(action: { showingDeleteAlert = true }) {
            Label("Delete Goal", systemImage: "trash")
              .foregroundColor(.red)
          }
        } label: {
          Image(systemName: "ellipsis.circle")
        }
      }
    }
    .onAppear {
      progressViewModel.selectGoal(goal)
    }
    .sheet(isPresented: $showingEditSheet) {
      NavigationView {
        GoalEditView(goal: goal, viewModel: viewModel)
      }
    }
    .sheet(isPresented: $showingAddProgressSheet) {
      NavigationView {
        AddProgressView(goal: goal, progressViewModel: progressViewModel)
      }
    }
    .sheet(isPresented: $showingMilestoneSheet) {
      NavigationView {
        MilestoneEditView(goal: goal)
      }
    }
    .alert("Delete Goal", isPresented: $showingDeleteAlert) {
      Button("Cancel", role: .cancel) {}
      Button("Delete", role: .destructive) {
        deleteGoal()
      }
    } message: {
      Text("Are you sure you want to delete this goal? This action cannot be undone.")
    }
    .glassmorphismBackground()
  }

  // MARK: - View Components

  private var goalHeaderSection: some View {
    VStack(spacing: 16) {
      HStack {
        VStack(alignment: .leading, spacing: 4) {
          Text(goal.title)
            .font(.title)
            .fontWeight(.bold)

          Text(goal.categoryDisplayName)
            .font(.subheadline)
            .foregroundColor(.secondary)
        }

        Spacer()

        VStack(alignment: .trailing, spacing: 4) {
          Text(goal.priorityDisplayName)
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(priorityColor)

          Text(goal.statusDisplayName)
            .font(.caption)
            .foregroundColor(statusColor)
        }
      }

      if !goal.description_text.isEmpty {
        Text(goal.description_text)
          .font(.body)
          .foregroundColor(.secondary)
          .multilineTextAlignment(.leading)
      }
    }
    .padding()
    .background(
      RoundedRectangle(cornerRadius: 16)
        .fill(Color.white.opacity(0.1))
    )
  }

  private var progressOverviewSection: some View {
    VStack(spacing: 16) {
      Text("Progress Overview")
        .font(.headline)
        .foregroundColor(.primary)

      VStack(spacing: 12) {
        // Progress Bar
        VStack(spacing: 8) {
          HStack {
            Text("Progress")
              .font(.subheadline)
              .foregroundColor(.secondary)

            Spacer()

            Text("\(String(format: "%.1f", goal.progressPercentage))%")
              .font(.subheadline)
              .fontWeight(.medium)
              .foregroundColor(.primary)
          }

          GeometryReader { geometry in
            ZStack(alignment: .leading) {
              RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.2))
                .frame(height: 12)

              RoundedRectangle(cornerRadius: 8)
                .fill(progressColor)
                .frame(width: geometry.size.width * (goal.progressPercentage / 100), height: 12)
            }
          }
        }

        // Amount Details
        HStack {
          VStack(alignment: .leading, spacing: 4) {
            Text("Current")
              .font(.caption)
              .foregroundColor(.secondary)

            Text(currencyFormatter.string(from: NSNumber(value: goal.currentAmount)) ?? "$0.00")
              .font(.title3)
              .fontWeight(.medium)
              .foregroundColor(.primary)
          }

          Spacer()

          VStack(alignment: .trailing, spacing: 4) {
            Text("Target")
              .font(.caption)
              .foregroundColor(.secondary)

            Text(currencyFormatter.string(from: NSNumber(value: goal.targetAmount)) ?? "$0.00")
              .font(.title3)
              .fontWeight(.medium)
              .foregroundColor(.primary)
          }
        }

        // Time Details
        HStack {
          VStack(alignment: .leading, spacing: 4) {
            Text("Created")
              .font(.caption)
              .foregroundColor(.secondary)

            Text(dateFormatter.string(from: goal.createdAt))
              .font(.subheadline)
              .foregroundColor(.primary)
          }

          Spacer()

          VStack(alignment: .trailing, spacing: 4) {
            Text("Target Date")
              .font(.caption)
              .foregroundColor(.secondary)

            Text(dateFormatter.string(from: goal.targetDate))
              .font(.subheadline)
              .foregroundColor(.primary)
          }
        }

        // Status Indicators
        HStack {
          if goal.isCompleted {
            Label("Completed", systemImage: "checkmark.circle.fill")
              .foregroundColor(.green)
          } else if goal.isOverdue {
            Label("Overdue", systemImage: "exclamationmark.triangle.fill")
              .foregroundColor(.red)
          } else if goal.isOnTrack {
            Label("On Track", systemImage: "checkmark.circle")
              .foregroundColor(.green)
          } else {
            Label("Behind Schedule", systemImage: "clock")
              .foregroundColor(.orange)
          }

          Spacer()

          if goal.isLongTermGoal {
            Label("Long Term", systemImage: "calendar")
              .foregroundColor(.blue)
          }
        }
      }
    }
    .padding()
    .background(
      RoundedRectangle(cornerRadius: 16)
        .fill(Color.white.opacity(0.1))
    )
  }

  private var progressChartSection: some View {
    VStack(spacing: 16) {
      HStack {
        Text("Progress Trend")
          .font(.headline)
          .foregroundColor(.primary)

        Spacer()

        Picker("Period", selection: $selectedProgressPeriod) {
          ForEach(ProgressPeriod.allCases, id: \.self) { period in
            Text(period.displayName).tag(period)
          }
        }
        .pickerStyle(MenuPickerStyle())
      }

      let progressData = progressViewModel.progressTrend(for: selectedProgressPeriod)

      if !progressData.isEmpty {
        Chart {
          ForEach(progressData) { dataPoint in
            LineMark(
              x: .value("Date", dataPoint.date),
              y: .value("Amount", dataPoint.amount)
            )
            .foregroundStyle(Color.blue)
            .symbol(Circle())

            AreaMark(
              x: .value("Date", dataPoint.date),
              y: .value("Amount", dataPoint.amount)
            )
            .foregroundStyle(
              LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.blue.opacity(0.1)]),
                startPoint: .top,
                endPoint: .bottom
              )
            )
          }
        }
        .frame(height: 200)
        .chartXAxis {
          AxisMarks(position: .bottom, value: .automatic) { _ in
            AxisGridLine()
            AxisTick()
            AxisValueLabel(format: .dateTime.month().day())
          }
        }
        .chartYAxis {
          AxisMarks(position: .leading, value: .automatic) { _ in
            AxisGridLine()
            AxisTick()
            AxisValueLabel(format: .currency(code: "AUD"))
          }
        }
      } else {
        Text("No progress data available")
          .font(.subheadline)
          .foregroundColor(.secondary)
          .frame(height: 200)
      }
    }
    .padding()
    .background(
      RoundedRectangle(cornerRadius: 16)
        .fill(Color.white.opacity(0.1))
    )
  }

  private var smartStatusSection: some View {
    VStack(spacing: 16) {
      Text("SMART Goal Status")
        .font(.headline)
        .foregroundColor(.primary)

      LazyVGrid(
        columns: [
          GridItem(.flexible()),
          GridItem(.flexible()),
          GridItem(.flexible()),
          GridItem(.flexible()),
          GridItem(.flexible()),
        ], spacing: 12
      ) {
        SMARTStatusCard(
          title: "Specific",
          isValid: goal.isSpecific,
          icon: "target"
        )

        SMARTStatusCard(
          title: "Measurable",
          isValid: goal.isMeasurable,
          icon: "ruler"
        )

        SMARTStatusCard(
          title: "Achievable",
          isValid: goal.isAchievable,
          icon: "checkmark.shield"
        )

        SMARTStatusCard(
          title: "Relevant",
          isValid: goal.isRelevant,
          icon: "star"
        )

        SMARTStatusCard(
          title: "Time-bound",
          isValid: goal.isTimeBound,
          icon: "calendar"
        )
      }
    }
    .padding()
    .background(
      RoundedRectangle(cornerRadius: 16)
        .fill(Color.white.opacity(0.1))
    )
  }

  private var milestonesSection: some View {
    VStack(spacing: 16) {
      HStack {
        Text("Milestones")
          .font(.headline)
          .foregroundColor(.primary)

        Spacer()

        Button(action: { showingMilestoneSheet = true }) {
          Image(systemName: "plus.circle.fill")
            .foregroundColor(.blue)
            .font(.title2)
        }
      }

      if let milestones = goal.milestones?.allObjects as? [GoalMilestone], !milestones.isEmpty {
        ForEach(milestones) { milestone in
          MilestoneRow(milestone: milestone)
        }
      } else {
        Text("No milestones set")
          .font(.subheadline)
          .foregroundColor(.secondary)
          .frame(maxWidth: .infinity, alignment: .leading)
      }
    }
    .padding()
    .background(
      RoundedRectangle(cornerRadius: 16)
        .fill(Color.white.opacity(0.1))
    )
  }

  private var recentProgressSection: some View {
    VStack(spacing: 16) {
      HStack {
        Text("Recent Progress")
          .font(.headline)
          .foregroundColor(.primary)

        Spacer()

        Button(action: { showingAddProgressSheet = true }) {
          Image(systemName: "plus.circle.fill")
            .foregroundColor(.blue)
            .font(.title2)
        }
      }

      let progressEntries = progressViewModel.progressEntries.sorted { $0.date > $1.date }

      if !progressEntries.isEmpty {
        ForEach(progressEntries.prefix(5)) { entry in
          ProgressEntryRow(entry: entry, currencyFormatter: currencyFormatter)
        }

        if progressEntries.count > 5 {
          NavigationLink(destination: ProgressHistoryView(progressViewModel: progressViewModel)) {
            Text("View All Progress")
              .font(.subheadline)
              .foregroundColor(.blue)
          }
        }
      } else {
        Text("No progress recorded yet")
          .font(.subheadline)
          .foregroundColor(.secondary)
          .frame(maxWidth: .infinity, alignment: .leading)
      }
    }
    .padding()
    .background(
      RoundedRectangle(cornerRadius: 16)
        .fill(Color.white.opacity(0.1))
    )
  }

  private var actionButtons: some View {
    VStack(spacing: 12) {
      Button(action: { showingAddProgressSheet = true }) {
        HStack {
          Image(systemName: "plus.circle.fill")
            .font(.title3)

          Text("Add Progress")
            .font(.headline)
            .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
          RoundedRectangle(cornerRadius: 12)
            .fill(Color.blue)
        )
        .foregroundColor(.white)
      }

      if !goal.isCompleted {
        Button(action: markAsCompleted) {
          HStack {
            Image(systemName: "checkmark.circle.fill")
              .font(.title3)

            Text("Mark as Completed")
              .font(.headline)
              .fontWeight(.medium)
          }
          .frame(maxWidth: .infinity)
          .padding()
          .background(
            RoundedRectangle(cornerRadius: 12)
              .fill(Color.green)
          )
          .foregroundColor(.white)
        }
      }
    }
  }

  // MARK: - Computed Properties

  private var dateFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    return formatter
  }

  private var progressColor: Color {
    if goal.isCompleted {
      return .green
    } else if goal.isOverdue {
      return .red
    } else if goal.isOnTrack {
      return .blue
    } else {
      return .orange
    }
  }

  private var priorityColor: Color {
    switch goal.priority {
    case "low": return .green
    case "medium": return .orange
    case "high": return .red
    case "critical": return .purple
    default: return .gray
    }
  }

  private var statusColor: Color {
    switch goal.status {
    case "active": return .blue
    case "completed": return .green
    case "paused": return .orange
    case "overdue": return .red
    case "cancelled": return .gray
    default: return .gray
    }
  }

  // MARK: - Methods

  private func deleteGoal() {
    let _ = viewModel.deleteGoal(goal)
    presentationMode.wrappedValue.dismiss()
  }

  private func markAsCompleted() {
    let _ = viewModel.updateGoal(
      goal,
      status: .completed
    )
  }
}

// MARK: - Supporting Views

struct SMARTStatusCard: View {
  let title: String
  let isValid: Bool
  let icon: String

  var body: some View {
    VStack(spacing: 8) {
      Image(systemName: isValid ? "checkmark.circle.fill" : "circle")
        .foregroundColor(isValid ? .green : .gray)
        .font(.title2)

      Text(title)
        .font(.caption)
        .fontWeight(.medium)
        .foregroundColor(.primary)
        .multilineTextAlignment(.center)
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 8)
    .background(
      RoundedRectangle(cornerRadius: 8)
        .fill(isValid ? Color.green.opacity(0.1) : Color.gray.opacity(0.1))
    )
  }
}

struct MilestoneRow: View {
  @ObservedObject var milestone: GoalMilestone

  var body: some View {
    HStack {
      VStack(alignment: .leading, spacing: 4) {
        Text(milestone.title)
          .font(.subheadline)
          .fontWeight(.medium)
          .foregroundColor(.primary)

        Text(milestone.targetAmount, format: .currency(code: "AUD"))
          .font(.caption)
          .foregroundColor(.secondary)
      }

      Spacer()

      VStack(alignment: .trailing, spacing: 4) {
        Text(milestone.isCompleted ? "Completed" : "Pending")
          .font(.caption)
          .fontWeight(.medium)
          .foregroundColor(milestone.isCompleted ? .green : .orange)

        if let completedDate = milestone.completedDate {
          Text(completedDate, formatter: shortDateFormatter)
            .font(.caption)
            .foregroundColor(.secondary)
        }
      }
    }
    .padding(.vertical, 4)
  }

  private var shortDateFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .none
    return formatter
  }
}

struct ProgressEntryRow: View {
  let entry: ProgressEntry
  let currencyFormatter: NumberFormatter

  var body: some View {
    HStack {
      VStack(alignment: .leading, spacing: 4) {
        Text(currencyFormatter.string(from: NSNumber(value: entry.amount)) ?? "$0.00")
          .font(.subheadline)
          .fontWeight(.medium)
          .foregroundColor(.primary)

        if !entry.note.isEmpty {
          Text(entry.note)
            .font(.caption)
            .foregroundColor(.secondary)
        }
      }

      Spacer()

      Text(entry.date, formatter: shortDateFormatter)
        .font(.caption)
        .foregroundColor(.secondary)
    }
    .padding(.vertical, 4)
  }

  private var shortDateFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .none
    return formatter
  }
}

// MARK: - Preview

struct GoalDetailView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      GoalDetailView(goal: sampleGoal)
    }
    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
  }

  static var sampleGoal: FinancialGoal {
    let context = PersistenceController.preview.container.viewContext
    let goal = FinancialGoal(context: context)
    goal.id = UUID()
    goal.title = "Emergency Fund"
    goal.description_text = "Build a 6-month emergency fund"
    goal.targetAmount = 30000
    goal.currentAmount = 15000
    goal.targetDate = Date().addingTimeInterval(86400 * 365)
    goal.category = "emergency_fund"
    goal.priority = "high"
    goal.status = "active"
    goal.createdAt = Date().addingTimeInterval(-86400 * 30)
    goal.lastModified = Date()
    goal.isCompleted = false
    goal.progressPercentage = 50.0
    return goal
  }
}
