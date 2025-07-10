/**
 * Purpose: SwiftUI view for managing financial goals with SMART validation and progress tracking
 * Issues & Complexity Summary: Goal list display, form handling, progress visualization
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~400
 *   - Core Algorithm Complexity: Medium (UI state management, form validation)
 *   - Dependencies: SwiftUI, FinancialGoalViewModel
 *   - State Management Complexity: Medium (multiple view states)
 *   - Novelty/Uncertainty Factor: Low (standard SwiftUI patterns)
 * AI Pre-Task Self-Assessment: 85%
 * Problem Estimate: 75%
 * Initial Code Complexity Estimate: 70%
 * Final Code Complexity: [TBD]
 * Overall Result Score: [TBD]
 * Key Variances/Learnings: [TBD]
 * Last Updated: 2025-07-10
 */

import SwiftUI
import CoreData

struct FinancialGoalView: View {
    @StateObject private var viewModel: FinancialGoalViewModel
    @Environment(\.managedObjectContext) private var context
    
    init(context: NSManagedObjectContext) {
        self._viewModel = StateObject(wrappedValue: FinancialGoalViewModel(context: context))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if viewModel.isLoading {
                    ProgressView("Loading goals...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    goalsList
                }
            }
            .navigationTitle("Financial Goals")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Add Goal") {
                        viewModel.showingAddGoal = true
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingAddGoal) {
                AddGoalSheet(viewModel: viewModel)
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
        .onAppear {
            viewModel.fetchGoals()
        }
    }
    
    private var goalsList: some View {
        List {
            if !viewModel.activeGoals.isEmpty {
                Section("Active Goals") {
                    ForEach(viewModel.activeGoals, id: \.id) { goal in
                        GoalRow(goal: goal, viewModel: viewModel)
                    }
                }
            }
            
            if !viewModel.completedGoals.isEmpty {
                Section("Completed Goals") {
                    ForEach(viewModel.completedGoals, id: \.id) { goal in
                        GoalRow(goal: goal, viewModel: viewModel)
                    }
                }
            }
            
            if viewModel.goals.isEmpty {
                ContentUnavailableView(
                    "No Goals Yet",
                    systemImage: "target",
                    description: Text("Create your first financial goal to get started")
                )
            }
        }
        .refreshable {
            viewModel.fetchGoals()
        }
    }
}

struct GoalRow: View {
    let goal: FinancialGoal
    let viewModel: FinancialGoalViewModel
    @State private var showingDetail = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(goal.title)
                        .font(.headline)
                        .foregroundColor(goal.isAchieved ? .secondary : .primary)
                    
                    Spacer()
                    
                    priorityBadge
                }
                
                Text(goal.category)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                progressView
                
                HStack {
                    Text("$\(goal.currentAmount, specifier: "%.0f") of $\(goal.targetAmount, specifier: "%.0f")")
                        .font(.caption)
                    
                    Spacer()
                    
                    Text(goal.targetDate, style: .date)
                        .font(.caption)
                        .foregroundColor(goal.targetDate < Date() && !goal.isAchieved ? .red : .secondary)
                }
            }
            
            if goal.isAchieved {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title2)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            showingDetail = true
        }
        .sheet(isPresented: $showingDetail) {
            GoalDetailView(goal: goal, viewModel: viewModel)
        }
    }
    
    private var priorityBadge: some View {
        Text(goal.priority)
            .font(.caption2)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(priorityColor.opacity(0.2))
            .foregroundColor(priorityColor)
            .cornerRadius(4)
    }
    
    private var priorityColor: Color {
        switch goal.priority {
        case "High":
            return .red
        case "Medium":
            return .orange
        default:
            return .blue
        }
    }
    
    private var progressView: some View {
        ProgressView(value: goal.calculateProgress())
            .progressViewStyle(LinearProgressViewStyle(tint: goal.isAchieved ? .green : .blue))
    }
}

struct AddGoalSheet: View {
    @ObservedObject var viewModel: FinancialGoalViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("Goal Details") {
                    TextField("Goal Title", text: $viewModel.goalForm.title)
                    
                    TextField("Description (optional)", text: $viewModel.goalForm.description)
                    
                    Picker("Category", selection: $viewModel.goalForm.category) {
                        ForEach(FinancialGoalViewModel.goalCategories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    
                    Picker("Priority", selection: $viewModel.goalForm.priority) {
                        ForEach(FinancialGoalViewModel.priorityLevels, id: \.self) { priority in
                            Text(priority).tag(priority)
                        }
                    }
                }
                
                Section("Financial Details") {
                    HStack {
                        Text("Target Amount")
                        Spacer()
                        TextField("Amount", value: $viewModel.goalForm.targetAmount, format: .currency(code: "USD"))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 120)
                    }
                    
                    HStack {
                        Text("Current Amount")
                        Spacer()
                        TextField("Amount", value: $viewModel.goalForm.currentAmount, format: .currency(code: "USD"))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 120)
                    }
                    
                    DatePicker("Target Date", selection: $viewModel.goalForm.targetDate, displayedComponents: .date)
                }
                
                if let validation = viewModel.smartValidation {
                    Section("SMART Goal Validation") {
                        validationRow("Specific", validation.isSpecific)
                        validationRow("Measurable", validation.isMeasurable)
                        validationRow("Achievable", validation.isAchievable)
                        validationRow("Relevant", validation.isRelevant)
                        validationRow("Time-bound", validation.isTimeBound)
                    }
                }
                
                if !viewModel.getSuggestionsForCategory(viewModel.goalForm.category).isEmpty {
                    Section("Suggestions for \(viewModel.goalForm.category)") {
                        ForEach(viewModel.getSuggestionsForCategory(viewModel.goalForm.category), id: \.self) { suggestion in
                            Button(suggestion) {
                                viewModel.goalForm.title = suggestion
                            }
                            .foregroundColor(.primary)
                        }
                    }
                }
            }
            .navigationTitle("New Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.resetForm()
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.createGoal()
                        dismiss()
                    }
                    .disabled(!viewModel.isFormValid)
                }
            }
        }
    }
    
    private func validationRow(_ title: String, _ isValid: Bool) -> some View {
        HStack {
            Image(systemName: isValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(isValid ? .green : .red)
            Text(title)
            Spacer()
        }
    }
}

struct GoalDetailView: View {
    let goal: FinancialGoal
    @ObservedObject var viewModel: FinancialGoalViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingAddProgress = false
    @State private var progressAmount: Double = 0
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text(goal.title)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        if let description = goal.goalDescription, !description.isEmpty {
                            Text(description)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text(goal.category)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(8)
                            
                            Text(goal.priority)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(priorityColor.opacity(0.1))
                                .foregroundColor(priorityColor)
                                .cornerRadius(8)
                            
                            Spacer()
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    
                    // Progress Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Progress")
                            .font(.headline)
                        
                        ProgressView(value: goal.calculateProgress())
                            .progressViewStyle(LinearProgressViewStyle(tint: goal.isAchieved ? .green : .blue))
                            .scaleEffect(x: 1, y: 2)
                        
                        HStack {
                            Text("$\(goal.currentAmount, specifier: "%.0f")")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Text("$\(goal.targetAmount, specifier: "%.0f")")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                        }
                        
                        Text("\(goal.calculateProgress() * 100, specifier: "%.1f")% Complete")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    
                    // Actions
                    if !goal.isAchieved {
                        VStack(spacing: 12) {
                            Button("Add Progress") {
                                showingAddProgress = true
                            }
                            .buttonStyle(.borderedProminent)
                            
                            if goal.calculateProgress() >= 1.0 {
                                Button("Mark as Achieved") {
                                    viewModel.markGoalAsAchieved(goal)
                                    dismiss()
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                        .padding()
                    }
                    
                    // Milestones
                    if !goal.milestones.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Milestones")
                                .font(.headline)
                            
                            ForEach(Array(goal.milestones).sorted(by: { $0.targetAmount < $1.targetAmount }), id: \.id) { milestone in
                                MilestoneRow(milestone: milestone)
                            }
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Goal Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingAddProgress) {
                AddProgressSheet(goal: goal, viewModel: viewModel, progressAmount: $progressAmount)
            }
        }
    }
    
    private var priorityColor: Color {
        switch goal.priority {
        case "High":
            return .red
        case "Medium":
            return .orange
        default:
            return .blue
        }
    }
}

struct MilestoneRow: View {
    let milestone: GoalMilestone
    
    var body: some View {
        HStack {
            Image(systemName: milestone.isAchieved ? "checkmark.circle.fill" : "circle")
                .foregroundColor(milestone.isAchieved ? .green : .secondary)
            
            VStack(alignment: .leading) {
                Text(milestone.title)
                    .font(.body)
                
                Text("$\(milestone.targetAmount, specifier: "%.0f")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if let achievedDate = milestone.achievedDate {
                Text(achievedDate, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct AddProgressSheet: View {
    let goal: FinancialGoal
    @ObservedObject var viewModel: FinancialGoalViewModel
    @Binding var progressAmount: Double
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("Add Progress") {
                    HStack {
                        Text("Amount")
                        Spacer()
                        TextField("Amount", value: $progressAmount, format: .currency(code: "USD"))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 120)
                    }
                    
                    HStack {
                        Text("New Total")
                        Spacer()
                        Text("$\(goal.currentAmount + progressAmount, specifier: "%.0f")")
                            .fontWeight(.semibold)
                    }
                }
            }
            .navigationTitle("Add Progress")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        viewModel.addProgress(to: goal, amount: progressAmount)
                        progressAmount = 0
                        dismiss()
                    }
                    .disabled(progressAmount <= 0)
                }
            }
        }
    }
}

#Preview {
    FinancialGoalView(context: PersistenceController.preview.container.viewContext)
}