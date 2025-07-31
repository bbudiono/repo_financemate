import CoreData
import SwiftUI

/**
 * AddProgressView.swift
 *
 * Purpose: Provides UI for adding progress to financial goals
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
 * Key Variances/Learnings: Simple progress entry with validation and data binding
 * Last Updated: 2025-07-11
 */

struct AddProgressView: View {
  @Environment(\.presentationMode) var presentationMode
  @ObservedObject var goal: FinancialGoal
  @ObservedObject var progressViewModel: GoalProgressViewModel

  @State private var progressAmount: String = ""
  @State private var progressNote: String = ""
  @State private var selectedDate: Date = Date()
  @State private var showingValidationErrors: Bool = false
  @State private var validationErrors: [String] = []
  @State private var isLoading: Bool = false

  // Form validation states
  @State private var amountError: String?

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
          // Goal Summary
          goalSummarySection

          // Progress Form
          progressFormSection

          // Action Buttons
          actionButtons
        }
        .padding()
      }
      .navigationTitle("Add Progress")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button("Cancel") {
            presentationMode.wrappedValue.dismiss()
          }
        }
      }
      .glassmorphismBackground()
    }
  }

  // MARK: - View Components

  private var goalSummarySection: some View {
    VStack(spacing: 16) {
      Text(goal.title)
        .font(.title2)
        .fontWeight(.bold)
        .foregroundColor(.primary)

      HStack {
        VStack(alignment: .leading, spacing: 4) {
          Text("Current Progress")
            .font(.caption)
            .foregroundColor(.secondary)

          Text(currencyFormatter.string(from: NSNumber(value: goal.currentAmount)) ?? "$0.00")
            .font(.title3)
            .fontWeight(.medium)
            .foregroundColor(.primary)
        }

        Spacer()

        VStack(alignment: .trailing, spacing: 4) {
          Text("Target Amount")
            .font(.caption)
            .foregroundColor(.secondary)

          Text(currencyFormatter.string(from: NSNumber(value: goal.targetAmount)) ?? "$0.00")
            .font(.title3)
            .fontWeight(.medium)
            .foregroundColor(.primary)
        }
      }

      // Progress Bar
      VStack(spacing: 8) {
        HStack {
          Text("Progress")
            .font(.caption)
            .foregroundColor(.secondary)

          Spacer()

          Text("\(String(format: "%.1f", goal.progressPercentage))%")
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.primary)
        }

        GeometryReader { geometry in
          ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 8)
              .fill(Color.gray.opacity(0.2))
              .frame(height: 12)

            RoundedRectangle(cornerRadius: 8)
              .fill(Color.blue)
              .frame(width: geometry.size.width * (goal.progressPercentage / 100), height: 12)
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

  private var progressFormSection: some View {
    VStack(spacing: 20) {
      // Amount Field
      VStack(alignment: .leading, spacing: 8) {
        Text("Progress Amount")
          .font(.headline)
          .foregroundColor(.primary)

        HStack {
          Text("$")
            .font(.title2)
            .foregroundColor(.secondary)

          TextField("0.00", text: $progressAmount)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .keyboardType(.decimalPad)
            .onChange(of: progressAmount) { _ in
              validateAmount()
            }
        }

        if let error = amountError {
          Text(error)
            .font(.caption)
            .foregroundColor(.red)
        }

        Text("Enter the amount you've contributed towards this goal")
          .font(.caption)
          .foregroundColor(.secondary)
      }

      // Date Picker
      VStack(alignment: .leading, spacing: 8) {
        Text("Date")
          .font(.headline)
          .foregroundColor(.primary)

        DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
          .datePickerStyle(CompactDatePickerStyle())

        Text("When did you make this contribution?")
          .font(.caption)
          .foregroundColor(.secondary)
      }

      // Note Field
      VStack(alignment: .leading, spacing: 8) {
        Text("Note (Optional)")
          .font(.headline)
          .foregroundColor(.primary)

        TextEditor(text: $progressNote)
          .frame(height: 100)
          .overlay(
            RoundedRectangle(cornerRadius: 8)
              .stroke(Color.gray.opacity(0.3), lineWidth: 1)
          )

        Text("Add any details about this progress entry")
          .font(.caption)
          .foregroundColor(.secondary)
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
      Button(action: addProgress) {
        HStack {
          if isLoading {
            ProgressView()
              .scaleEffect(0.8)
              .progressViewStyle(CircularProgressViewStyle(tint: .white))
          } else {
            Text("Add Progress")
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
    return amountError == nil
      && !progressAmount.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
      && Double(progressAmount) != nil && Double(progressAmount)! > 0
  }

  // MARK: - Methods

  private func validateAmount() {
    amountError = nil

    guard let amount = Double(progressAmount) else {
      amountError = "Please enter a valid amount"
      return
    }

    if amount <= 0 {
      amountError = "Amount must be positive"
    } else if amount > 1_000_000 {
      amountError = "Amount cannot exceed $1,000,000"
    }
  }

  private func addProgress() {
    guard let amount = Double(progressAmount) else { return }

    isLoading = true

    let result = progressViewModel.addProgress(
      to: goal,
      amount: amount,
      date: selectedDate,
      note: progressNote
    )

    isLoading = false

    switch result {
    case .success:
      presentationMode.wrappedValue.dismiss()
    case .failure(let error):
      validationErrors = [error.localizedDescription ?? "Failed to add progress"]
      showingValidationErrors = true
    }
  }
}

// MARK: - Preview

struct AddProgressView_Previews: PreviewProvider {
  static var previews: some View {
    AddProgressView(
      goal: sampleGoal,
      progressViewModel: GoalProgressViewModel()
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
