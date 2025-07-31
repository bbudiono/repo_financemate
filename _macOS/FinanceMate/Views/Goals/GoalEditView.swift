import CoreData
import SwiftUI

/**
 * GoalEditView.swift
 *
 * Purpose: Provides UI for editing existing financial goals with validation
 * Issues & Complexity Summary: Complex form with validation and data binding
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~300+
 *   - Core Algorithm Complexity: Medium
 *   - Dependencies: 2 (SwiftUI, CoreData)
 *   - State Management Complexity: High
 *   - Novelty/Uncertainty Factor: Low
 * AI Pre-Task Self-Assessment: 86%
 * Problem Estimate: 88%
 * Initial Code Complexity Estimate: 87%
 * Final Code Complexity: 89%
 * Overall Result Score: 88%
 * Key Variances/Learnings: Comprehensive goal editing with validation and data binding
 * Last Updated: 2025-07-11
 */

struct GoalEditView: View {
  @Environment(\.presentationMode) var presentationMode
  @ObservedObject var goal: FinancialGoal
  @ObservedObject var viewModel: FinancialGoalViewModel

  @State private var title: String = ""
  @State private var description: String = ""
  @State private var targetAmount: String = ""
  @State private var targetDate: Date = Date()
  @State private var selectedCategory: GoalCategory = .emergencyFund
  @State private var selectedPriority: GoalPriority = .medium
  @State private var selectedStatus: GoalStatus = .active
  @State private var showingValidationErrors: Bool = false
  @State private var validationErrors: [String] = []
  @State private var isLoading: Bool = false

  // Form validation states
  @State private var titleError: String?
  @State private var amountError: String?
  @State private var dateError: String?

  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 24) {
          // Goal Details Form
          goalDetailsForm

          // Status Selection
          statusSelectionSection

          // Action Buttons
          actionButtons
        }
        .padding()
      }
      .navigationTitle("Edit Goal")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button("Cancel") {
            presentationMode.wrappedValue.dismiss()
          }
        }
      }
      .onAppear {
        loadGoalData()
      }
      .glassmorphismBackground()
    }
  }

  // MARK: - View Components

  private var goalDetailsForm: some View {
    VStack(spacing: 20) {
      // Title Field
      VStack(alignment: .leading, spacing: 8) {
        Text("Goal Title")
          .font(.headline)
          .foregroundColor(.primary)

        TextField("e.g., Emergency Fund, House Deposit", text: $title)
          .textFieldStyle(RoundedBorderTextFieldStyle())
          .onChange(of: title) { _ in
            validateTitle()
          }

        if let error = titleError {
          Text(error)
            .font(.caption)
            .foregroundColor(.red)
        }
      }

      // Description Field
      VStack(alignment: .leading, spacing: 8) {
        Text("Description (Optional)")
          .font(.headline)
          .foregroundColor(.primary)

        TextEditor(text: $description)
          .frame(height: 100)
          .overlay(
            RoundedRectangle(cornerRadius: 8)
              .stroke(Color.gray.opacity(0.3), lineWidth: 1)
          )
      }

      // Target Amount Field
      VStack(alignment: .leading, spacing: 8) {
        Text("Target Amount")
          .font(.headline)
          .foregroundColor(.primary)

        HStack {
          Text("$")
            .font(.title2)
            .foregroundColor(.secondary)

          TextField("0.00", text: $targetAmount)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .keyboardType(.decimalPad)
            .onChange(of: targetAmount) { _ in
              validateAmount()
            }
        }

        if let error = amountError {
          Text(error)
            .font(.caption)
            .foregroundColor(.red)
        }
      }

      // Target Date Picker
      VStack(alignment: .leading, spacing: 8) {
        Text("Target Date")
          .font(.headline)
          .foregroundColor(.primary)

        DatePicker("Select Date", selection: $targetDate, displayedComponents: .date)
          .datePickerStyle(CompactDatePickerStyle())
          .onChange(of: targetDate) { _ in
            validateDate()
          }

        if let error = dateError {
          Text(error)
            .font(.caption)
            .foregroundColor(.red)
        }
      }

      // Category Selection
      VStack(alignment: .leading, spacing: 12) {
        Text("Category")
          .font(.headline)
          .foregroundColor(.primary)

        LazyVGrid(
          columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
          ], spacing: 12
        ) {
          ForEach(GoalCategory.allCases, id: \.self) { category in
            CategorySelectionButton(
              category: category,
              isSelected: selectedCategory == category,
              action: { selectedCategory = category }
            )
          }
        }
      }

      // Priority Selection
      VStack(alignment: .leading, spacing: 12) {
        Text("Priority")
          .font(.headline)
          .foregroundColor(.primary)

        HStack(spacing: 12) {
          ForEach(GoalPriority.allCases, id: \.self) { priority in
            PrioritySelectionButton(
              priority: priority,
              isSelected: selectedPriority == priority,
              action: { selectedPriority = priority }
            )
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

  private var statusSelectionSection: some View {
    VStack(spacing: 16) {
      Text("Status")
        .font(.headline)
        .foregroundColor(.primary)

      LazyVGrid(
        columns: [
          GridItem(.flexible()),
          GridItem(.flexible()),
          GridItem(.flexible()),
        ], spacing: 12
      ) {
        ForEach(GoalStatus.allCases, id: \.self) { status in
          StatusSelectionButton(
            status: status,
            isSelected: selectedStatus == status,
            action: { selectedStatus = status }
          )
        }
      }
    }
    .padding()
    .background(
      RoundedRectangle(cornerRadius: 16)
        .fill(Color.white.opacity(0.1))
    )
  }

  private var actionButtons: some View {
    VStack(spacing: 16) {
      Button(action: saveGoal) {
        HStack {
          if isLoading {
            ProgressView()
              .scaleEffect(0.8)
              .progressViewStyle(CircularProgressViewStyle(tint: .white))
          } else {
            Text("Save Changes")
              .font(.headline)
              .foregroundColor(.white)
          }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
          RoundedRectangle(cornerRadius: 12)
            .fill(isFormValid ? Color.blue : Color.gray)
        )
      }
      .disabled(!isFormValid || isLoading)

      if !validationErrors.isEmpty && showingValidationErrors {
        VStack(alignment: .leading, spacing: 8) {
          ForEach(validationErrors, id: \.self) { error in
            HStack {
              Image(systemName: "exclamationmark.triangle")
                .foregroundColor(.red)
              Text(error)
                .font(.caption)
                .foregroundColor(.red)
            }
          }
        }
        .padding()
        .background(
          RoundedRectangle(cornerRadius: 8)
            .fill(Color.red.opacity(0.1))
        )
      }
    }
  }

  // MARK: - Computed Properties

  private var isFormValid: Bool {
    return titleError == nil && amountError == nil && dateError == nil
      && !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
      && Double(targetAmount) != nil && Double(targetAmount)! > 0
  }

  // MARK: - Methods

  private func loadGoalData() {
    title = goal.title
    description = goal.description_text
    targetAmount = String(goal.targetAmount)
    targetDate = goal.targetDate
    selectedCategory = GoalCategory(rawValue: goal.category) ?? .other
    selectedPriority = GoalPriority(rawValue: goal.priority) ?? .medium
    selectedStatus = GoalStatus(rawValue: goal.status) ?? .active
  }

  private func validateTitle() {
    titleError = nil

    if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
      titleError = "Title cannot be empty"
    } else if title.count < 3 {
      titleError = "Title must be at least 3 characters long"
    }
  }

  private func validateAmount() {
    amountError = nil

    guard let amount = Double(targetAmount) else {
      amountError = "Please enter a valid amount"
      return
    }

    if amount <= 0 {
      amountError = "Amount must be positive"
    } else if amount > 10_000_000 {
      amountError = "Amount cannot exceed $10,000,000"
    }
  }

  private func validateDate() {
    dateError = nil

    let now = Date()
    let fiftyYearsFromNow = Calendar.current.date(byAdding: .year, value: 50, to: now) ?? now

    if targetDate <= now {
      dateError = "Date must be in the future"
    } else if targetDate > fiftyYearsFromNow {
      dateError = "Date cannot be more than 50 years in the future"
    }
  }

  private func saveGoal() {
    guard let amount = Double(targetAmount) else { return }

    isLoading = true

    let result = viewModel.updateGoal(
      goal,
      title: title,
      description: description,
      targetAmount: amount,
      targetDate: targetDate,
      category: selectedCategory,
      priority: selectedPriority
    )

    // Update status separately if it changed
    if selectedStatus != GoalStatus(rawValue: goal.status) {
      let _ = viewModel.updateGoal(
        goal,
        status: selectedStatus
      )
    }

    isLoading = false

    switch result {
    case .success:
      presentationMode.wrappedValue.dismiss()
    case .failure(let error):
      validationErrors = [error.localizedDescription ?? "Failed to update goal"]
      showingValidationErrors = true
    }
  }
}

// MARK: - Supporting Views

struct StatusSelectionButton: View {
  let status: GoalStatus
  let isSelected: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      VStack(spacing: 4) {
        Image(systemName: status.icon)
          .font(.title3)
          .foregroundColor(isSelected ? .white : Color(status.color))

        Text(status.displayName)
          .font(.caption)
          .fontWeight(.medium)
          .foregroundColor(isSelected ? .white : .primary)
          .multilineTextAlignment(.center)
      }
      .frame(maxWidth: .infinity)
      .padding(.vertical, 8)
      .background(
        RoundedRectangle(cornerRadius: 8)
          .fill(isSelected ? Color(status.color) : Color.gray.opacity(0.2))
      )
    }
  }
}

// MARK: - Preview

struct GoalEditView_Previews: PreviewProvider {
  static var previews: some View {
    GoalEditView(
      goal: sampleGoal,
      viewModel: FinancialGoalViewModel()
    )
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
