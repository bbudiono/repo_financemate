import CoreData
import SwiftUI

/**
 * MilestoneEditView.swift
 *
 * Purpose: Provides UI for creating and editing milestones for financial goals
 * Issues & Complexity Summary: Simple form with validation and data binding
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~200+
 *   - Core Algorithm Complexity: Low
 *   - Dependencies: 2 (SwiftUI, CoreData)
 *   - State Management Complexity: Medium
 *   - Novelty/Uncertainty Factor: Low
 * AI Pre-Task Self-Assessment: 84%
 * Problem Estimate: 86%
 * Initial Code Complexity Estimate: 85%
 * Final Code Complexity: 87%
 * Overall Result Score: 86%
 * Key Variances/Learnings: Simple milestone editing with validation and data binding
 * Last Updated: 2025-07-11
 */

struct MilestoneEditView: View {
  @Environment(\.presentationMode) var presentationMode
  @ObservedObject var goal: FinancialGoal
  @StateObject private var viewModel = FinancialGoalViewModel()

  @State private var title: String = ""
  @State private var description: String = ""
  @State private var targetAmount: String = ""
  @State private var targetDate: Date = Date()
  @State private var showingValidationErrors: Bool = false
  @State private var validationErrors: [String] = []
  @State private var isLoading: Bool = false
  @State private var editingMilestone: GoalMilestone?

  // Form validation states
  @State private var titleError: String?
  @State private var amountError: String?
  @State private var dateError: String?

  private var currencyFormatter: NumberFormatter {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.locale = Locale(identifier: "en_AU")
    return formatter
  }

  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 24) {
          // Header
          headerSection

          // Milestone Form
          milestoneFormSection

          // Action Buttons
          actionButtons
        }
        .padding()
      }
      .navigationTitle(editingMilestone == nil ? "Create Milestone" : "Edit Milestone")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button("Cancel") {
            presentationMode.wrappedValue.dismiss()
          }
        }
      }
      .onAppear {
        if let milestone = editingMilestone {
          loadMilestoneData(milestone)
        }
      }
      .glassmorphismBackground()
    }
  }

  // MARK: - View Components

  private var headerSection: some View {
    VStack(spacing: 12) {
      Image(systemName: "flag.checkered")
        .font(.system(size: 48))
        .foregroundColor(.blue)

      Text(editingMilestone == nil ? "Create New Milestone" : "Edit Milestone")
        .font(.title2)
        .fontWeight(.bold)

      Text("Milestones help you track progress towards your goal")
        .font(.subheadline)
        .foregroundColor(.secondary)
        .multilineTextAlignment(.center)
    }
    .padding()
    .background(
      RoundedRectangle(cornerRadius: 16)
        .fill(Color.blue.opacity(0.1))
    )
  }

  private var milestoneFormSection: some View {
    VStack(spacing: 20) {
      // Title Field
      VStack(alignment: .leading, spacing: 8) {
        Text("Milestone Title")
          .font(.headline)
          .foregroundColor(.primary)

        TextField("e.g., First $5,000, Halfway Point", text: $title)
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
          .frame(height: 80)
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

        Text("The amount you want to reach for this milestone")
          .font(.caption)
          .foregroundColor(.secondary)
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

        Text("When do you want to achieve this milestone?")
          .font(.caption)
          .foregroundColor(.secondary)
      }

      // Goal Summary
      VStack(alignment: .leading, spacing: 8) {
        Text("Goal Summary")
          .font(.headline)
          .foregroundColor(.primary)

        HStack {
          VStack(alignment: .leading, spacing: 4) {
            Text("Goal")
              .font(.caption)
              .foregroundColor(.secondary)

            Text(goal.title)
              .font(.subheadline)
              .fontWeight(.medium)
              .foregroundColor(.primary)
          }

          Spacer()

          VStack(alignment: .trailing, spacing: 4) {
            Text("Goal Target")
              .font(.caption)
              .foregroundColor(.secondary)

            Text(currencyFormatter.string(from: NSNumber(value: goal.targetAmount)) ?? "$0.00")
              .font(.subheadline)
              .fontWeight(.medium)
              .foregroundColor(.primary)
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

  private var actionButtons: some View {
    VStack(spacing: 16) {
      Button(action: saveMilestone) {
        HStack {
          if isLoading {
            ProgressView()
              .scaleEffect(0.8)
              .progressViewStyle(CircularProgressViewStyle(tint: .white))
          } else {
            Text(editingMilestone == nil ? "Create Milestone" : "Save Changes")
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

  private func loadMilestoneData(_ milestone: GoalMilestone) {
    title = milestone.title
    description = milestone.description_text
    targetAmount = String(milestone.targetAmount)
    targetDate = milestone.targetDate
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
    } else if amount > goal.targetAmount {
      amountError = "Milestone amount cannot exceed goal target"
    }
  }

  private func validateDate() {
    dateError = nil

    let now = Date()

    if targetDate <= now {
      dateError = "Date must be in the future"
    } else if targetDate > goal.targetDate {
      dateError = "Milestone date cannot exceed goal target date"
    }
  }

  private func saveMilestone() {
    guard let amount = Double(targetAmount) else { return }

    isLoading = true

    let result: Result<GoalMilestone, Error>

    if let milestone = editingMilestone {
      result = viewModel.updateMilestone(
        milestone,
        title: title,
        description: description,
        targetAmount: amount,
        targetDate: targetDate
      )
    } else {
      result = viewModel.createMilestone(
        for: goal,
        title: title,
        description: description,
        targetAmount: amount,
        targetDate: targetDate
      )
    }

    isLoading = false

    switch result {
    case .success:
      presentationMode.wrappedValue.dismiss()
    case .failure(let error):
      validationErrors = [error.localizedDescription ?? "Failed to save milestone"]
      showingValidationErrors = true
    }
  }
}

// MARK: - Preview

struct MilestoneEditView_Previews: PreviewProvider {
  static var previews: some View {
    MilestoneEditView(goal: sampleGoal)
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
