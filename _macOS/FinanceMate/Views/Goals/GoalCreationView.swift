import CoreData
import SwiftUI

/**
 * GoalCreationView.swift
 *
 * Purpose: Provides comprehensive UI for creating new financial goals with SMART validation
 * Issues & Complexity Summary: Complex form with validation and user guidance
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~450+
 *   - Core Algorithm Complexity: Medium
 *   - Dependencies: 2 (SwiftUI, CoreData)
 *   - State Management Complexity: High
 *   - Novelty/Uncertainty Factor: Medium
 * AI Pre-Task Self-Assessment: 87%
 * Problem Estimate: 89%
 * Initial Code Complexity Estimate: 88%
 * Final Code Complexity: 90%
 * Overall Result Score: 89%
 * Key Variances/Learnings: Comprehensive goal creation with SMART validation and user guidance
 * Last Updated: 2025-07-11
 */

struct GoalCreationView: View {
  @Environment(\.presentationMode) var presentationMode
  @ObservedObject var viewModel: FinancialGoalViewModel

  @State private var title: String = ""
  @State private var description: String = ""
  @State private var targetAmount: String = ""
  @State private var targetDate: Date = Date().addingTimeInterval(86400 * 365)  // Default 1 year from now
  @State private var selectedCategory: GoalCategory = .emergencyFund
  @State private var selectedPriority: GoalPriority = .medium
  @State private var showingValidationErrors: Bool = false
  @State private var validationErrors: [String] = []
  @State private var showingSuccessAlert: Bool = false
  @State private var isLoading: Bool = false

  // Form validation states
  @State private var titleError: String?
  @State private var amountError: String?
  @State private var dateError: String?

  // SMART validation indicators
  @State private var isSpecific: Bool = false
  @State private var isMeasurable: Bool = false
  @State private var isAchievable: Bool = false
  @State private var isRelevant: Bool = false
  @State private var isTimeBound: Bool = false

  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 24) {
          // Header Section
          headerSection

          // Goal Details Form
          goalDetailsForm

          // SMART Validation Section
          smartValidationSection

          // Category and Priority Selection
          categoryPrioritySection

          // Action Buttons
          actionButtons
        }
        .padding()
      }
      .navigationTitle("Create Financial Goal")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button("Cancel") {
            presentationMode.wrappedValue.dismiss()
          }
        }
      }
      .glassmorphismBackground()
      .alert("Goal Created Successfully", isPresented: $showingSuccessAlert) {
        Button("OK") {
          presentationMode.wrappedValue.dismiss()
        }
      } message: {
        Text(
          "Your financial goal has been created successfully. You can now track your progress towards achieving it."
        )
      }
    }
  }

  // MARK: - View Components

  private var headerSection: some View {
    VStack(spacing: 12) {
      Image(systemName: "target")
        .font(.system(size: 48))
        .foregroundColor(.blue)

      Text("Create Your Financial Goal")
        .font(.title2)
        .fontWeight(.bold)

      Text("Set a SMART goal to increase your chances of success")
        .font(.subheadline)
        .foregroundColor(.secondary)
        .multilineTextAlignment(.center)
    }
    .padding()
    .glassmorphism(.accent, cornerRadius: 16)
  }

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
            updateSMARTValidation()
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
              updateSMARTValidation()
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
            updateSMARTValidation()
          }

        if let error = dateError {
          Text(error)
            .font(.caption)
            .foregroundColor(.red)
        }
      }
    }
    .padding()
    .glassmorphism(.primary, cornerRadius: 16)
  }

  private var smartValidationSection: some View {
    VStack(spacing: 16) {
      Text("SMART Goal Validation")
        .font(.headline)
        .foregroundColor(.primary)

      VStack(spacing: 12) {
        SMARTValidationRow(
          title: "Specific",
          description: "Clear and well-defined",
          isValid: isSpecific,
          icon: "target"
        )

        SMARTValidationRow(
          title: "Measurable",
          description: "Quantifiable progress",
          isValid: isMeasurable,
          icon: "ruler"
        )

        SMARTValidationRow(
          title: "Achievable",
          description: "Realistic and attainable",
          isValid: isAchievable,
          icon: "checkmark.shield"
        )

        SMARTValidationRow(
          title: "Relevant",
          description: "Important to you",
          isValid: isRelevant,
          icon: "star"
        )

        SMARTValidationRow(
          title: "Time-bound",
          description: "Has a deadline",
          isValid: isTimeBound,
          icon: "calendar"
        )
      }
    }
    .padding()
    .glassmorphism(.primary, cornerRadius: 16)
  }

  private var categoryPrioritySection: some View {
    VStack(spacing: 20) {
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
              action: {
                selectedCategory = category
                updateSMARTValidation()
              }
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
    .glassmorphism(.primary, cornerRadius: 16)
  }

  private var actionButtons: some View {
    VStack(spacing: 16) {
      Button(action: createGoal) {
        HStack {
          if isLoading {
            ProgressView()
              .scaleEffect(0.8)
              .progressViewStyle(CircularProgressViewStyle(tint: .white))
          } else {
            Text("Create Goal")
              .font(.headline)
              .foregroundColor(.white)
          }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .glassmorphism(isFormValid ? .accent : .minimal, cornerRadius: 12)
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
        .glassmorphism(.minimal, cornerRadius: 8)
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

  private func updateSMARTValidation() {
    // Specific: Title is detailed enough
    isSpecific = title.count >= 10 && !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

    // Measurable: Has a valid target amount
    isMeasurable = Double(targetAmount) != nil && Double(targetAmount)! > 0

    // Achievable: Amount is reasonable and timeline is adequate
    if let amount = Double(targetAmount), amount > 0 {
      let monthsToTarget =
        Calendar.current.dateComponents([.month], from: Date(), to: targetDate).month ?? 0
      let monthlyAmountNeeded = amount / Double(max(monthsToTarget, 1))
      isAchievable = monthlyAmountNeeded <= 10000  // $10k per month max
    } else {
      isAchievable = false
    }

    // Relevant: Has a category selected
    isRelevant = selectedCategory != .other

    // Time-bound: Has a future date
    isTimeBound = targetDate > Date()
  }

  private func createGoal() {
    guard let amount = Double(targetAmount) else { return }

    isLoading = true

    let result = viewModel.createGoal(
      title: title,
      description: description,
      targetAmount: amount,
      targetDate: targetDate,
      category: selectedCategory,
      priority: selectedPriority
    )

    isLoading = false

    switch result {
    case .success:
      showingSuccessAlert = true
    case .failure(let error):
      validationErrors = [error.localizedDescription ?? "Failed to create goal"]
      showingValidationErrors = true
    }
  }
}

// MARK: - Supporting Views

struct SMARTValidationRow: View {
  let title: String
  let description: String
  let isValid: Bool
  let icon: String

  var body: some View {
    HStack {
      Image(systemName: isValid ? "checkmark.circle.fill" : "circle")
        .foregroundColor(isValid ? .green : .gray)
        .font(.title3)

      VStack(alignment: .leading, spacing: 2) {
        Text(title)
          .font(.subheadline)
          .fontWeight(.medium)
          .foregroundColor(.primary)

        Text(description)
          .font(.caption)
          .foregroundColor(.secondary)
      }

      Spacer()

      Image(systemName: icon)
        .foregroundColor(.secondary)
        .font(.caption)
    }
    .padding(.vertical, 4)
  }
}

struct CategorySelectionButton: View {
  let category: GoalCategory
  let isSelected: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      VStack(spacing: 4) {
        Image(systemName: category.icon)
          .font(.title3)
          .foregroundColor(isSelected ? .white : Color(category.color))

        Text(category.displayName)
          .font(.caption)
          .fontWeight(.medium)
          .foregroundColor(isSelected ? .white : .primary)
          .multilineTextAlignment(.center)
      }
      .frame(maxWidth: .infinity)
      .padding(.vertical, 8)
      .background(
        RoundedRectangle(cornerRadius: 8)
          .fill(isSelected ? Color(category.color) : Color.gray.opacity(0.2))
      )
    }
  }
}

struct PrioritySelectionButton: View {
  let priority: GoalPriority
  let isSelected: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Text(priority.displayName)
        .font(.subheadline)
        .fontWeight(.medium)
        .foregroundColor(isSelected ? .white : .primary)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
          RoundedRectangle(cornerRadius: 20)
            .fill(isSelected ? priorityColor : Color.gray.opacity(0.2))
        )
    }
  }

  private var priorityColor: Color {
    switch priority {
    case .low: return .green
    case .medium: return .orange
    case .high: return .red
    case .critical: return .purple
    }
  }
}

// MARK: - Preview

struct GoalCreationView_Previews: PreviewProvider {
  static var previews: some View {
    GoalCreationView(viewModel: FinancialGoalViewModel())
      .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
  }
}
