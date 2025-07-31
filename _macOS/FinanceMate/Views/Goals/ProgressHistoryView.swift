import Charts
import CoreData
import SwiftUI

/**
 * ProgressHistoryView.swift
 *
 * Purpose: Provides UI for viewing and managing progress history for financial goals
 * Issues & Complexity Summary: Complex view with charts, filtering, and data management
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~300+
 *   - Core Algorithm Complexity: Medium
 *   - Dependencies: 3 (SwiftUI, CoreData, Charts)
 *   - State Management Complexity: High
 *   - Novelty/Uncertainty Factor: Low
 * AI Pre-Task Self-Assessment: 87%
 * Problem Estimate: 89%
 * Initial Code Complexity Estimate: 88%
 * Final Code Complexity: 90%
 * Overall Result Score: 89%
 * Key Variances/Learnings: Comprehensive progress history with charts and filtering
 * Last Updated: 2025-07-11
 */

struct ProgressHistoryView: View {
  @ObservedObject var progressViewModel: GoalProgressViewModel
  @State private var selectedPeriod: ProgressPeriod = .month
  @State private var showingDeleteAlert: Bool = false
  @State private var progressToDelete: ProgressEntry?
  @State private var showingEditSheet: Bool = false
  @State private var progressToEdit: ProgressEntry?

  private var currencyFormatter: NumberFormatter {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.locale = Locale(identifier: "en_AU")
    return formatter
  }

  var body: some View {
    ScrollView {
      VStack(spacing: 24) {
        // Summary Cards
        summaryCardsSection

        // Progress Chart
        progressChartSection

        // Progress List
        progressListSection
      }
      .padding()
    }
    .navigationTitle("Progress History")
    .navigationBarTitleDisplayMode(.inline)
    .sheet(isPresented: $showingEditSheet) {
      if let progress = progressToEdit {
        NavigationView {
          EditProgressView(progress: progress, progressViewModel: progressViewModel)
        }
      }
    }
    .alert("Delete Progress Entry", isPresented: $showingDeleteAlert) {
      Button("Cancel", role: .cancel) {
        progressToDelete = nil
      }
      Button("Delete", role: .destructive) {
        if let progress = progressToDelete {
          deleteProgress(progress)
        }
      }
    } message: {
      Text("Are you sure you want to delete this progress entry? This action cannot be undone.")
    }
    .glassmorphismBackground()
  }

  // MARK: - View Components

  private var summaryCardsSection: some View {
    VStack(spacing: 16) {
      Text("Progress Summary")
        .font(.headline)
        .foregroundColor(.primary)

      LazyVGrid(
        columns: [
          GridItem(.flexible()),
          GridItem(.flexible()),
          GridItem(.flexible()),
        ], spacing: 12
      ) {
        SummaryCard(
          title: "Total Progress",
          value: currencyFormatter.string(from: NSNumber(value: totalProgressAmount)) ?? "$0.00",
          icon: "chart.line.uptrend.xyaxis",
          color: .blue
        )

        SummaryCard(
          title: "Entries Count",
          value: "\(progressViewModel.progressEntries.count)",
          icon: "list.bullet",
          color: .green
        )

        SummaryCard(
          title: "Average Progress",
          value: currencyFormatter.string(from: NSNumber(value: averageProgressAmount)) ?? "$0.00",
          icon: "chart.bar",
          color: .orange
        )
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

        Picker("Period", selection: $selectedPeriod) {
          ForEach(ProgressPeriod.allCases, id: \.self) { period in
            Text(period.displayName).tag(period)
          }
        }
        .pickerStyle(MenuPickerStyle())
      }

      let progressData = progressViewModel.progressTrend(for: selectedPeriod)

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

  private var progressListSection: some View {
    VStack(spacing: 16) {
      HStack {
        Text("Progress Entries")
          .font(.headline)
          .foregroundColor(.primary)

        Spacer()

        Text("\(progressViewModel.progressEntries.count) entries")
          .font(.subheadline)
          .foregroundColor(.secondary)
      }

      if progressViewModel.progressEntries.isEmpty {
        Text("No progress entries found")
          .font(.subheadline)
          .foregroundColor(.secondary)
          .frame(maxWidth: .infinity, alignment: .center)
          .padding()
      } else {
        let sortedEntries = progressViewModel.progressEntries.sorted { $0.date > $1.date }

        ForEach(sortedEntries) { entry in
          ProgressHistoryRow(
            entry: entry,
            currencyFormatter: currencyFormatter,
            onEdit: {
              progressToEdit = entry
              showingEditSheet = true
            },
            onDelete: {
              progressToDelete = entry
              showingDeleteAlert = true
            }
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

  // MARK: - Computed Properties

  private var totalProgressAmount: Double {
    return progressViewModel.progressEntries.reduce(0) { $0 + $1.amount }
  }

  private var averageProgressAmount: Double {
    guard !progressViewModel.progressEntries.isEmpty else { return 0 }
    return totalProgressAmount / Double(progressViewModel.progressEntries.count)
  }

  // MARK: - Methods

  private func deleteProgress(_ progress: ProgressEntry) {
    let _ = progressViewModel.deleteProgress(progress)
    progressToDelete = nil
  }
}

// MARK: - Supporting Views

struct SummaryCard: View {
  let title: String
  let value: String
  let icon: String
  let color: Color

  var body: some View {
    VStack(spacing: 8) {
      Image(systemName: icon)
        .font(.title2)
        .foregroundColor(color)

      Text(title)
        .font(.caption)
        .fontWeight(.medium)
        .foregroundColor(.secondary)
        .multilineTextAlignment(.center)

      Text(value)
        .font(.subheadline)
        .fontWeight(.bold)
        .foregroundColor(.primary)
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 12)
    .background(
      RoundedRectangle(cornerRadius: 8)
        .fill(color.opacity(0.1))
    )
  }
}

struct ProgressHistoryRow: View {
  let entry: ProgressEntry
  let currencyFormatter: NumberFormatter
  let onEdit: () -> Void
  let onDelete: () -> Void

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
            .lineLimit(2)
        }

        Text(entry.date, formatter: shortDateFormatter)
          .font(.caption)
          .foregroundColor(.secondary)
      }

      Spacer()

      HStack(spacing: 8) {
        Button(action: onEdit) {
          Image(systemName: "pencil")
            .foregroundColor(.blue)
            .font(.caption)
        }

        Button(action: onDelete) {
          Image(systemName: "trash")
            .foregroundColor(.red)
            .font(.caption)
        }
      }
    }
    .padding(.vertical, 8)
    .background(
      RoundedRectangle(cornerRadius: 8)
        .fill(Color.white.opacity(0.05))
    )
  }

  private var shortDateFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .none
    return formatter
  }
}

// MARK: - Edit Progress View

struct EditProgressView: View {
  @Environment(\.presentationMode) var presentationMode
  @ObservedObject var progress: ProgressEntry
  @ObservedObject var progressViewModel: GoalProgressViewModel

  @State private var amount: String = ""
  @State private var note: String = ""
  @State private var date: Date = Date()
  @State private var isLoading: Bool = false
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
          // Amount Field
          VStack(alignment: .leading, spacing: 8) {
            Text("Progress Amount")
              .font(.headline)
              .foregroundColor(.primary)

            HStack {
              Text("$")
                .font(.title2)
                .foregroundColor(.secondary)

              TextField("0.00", text: $amount)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)
                .onChange(of: amount) { _ in
                  validateAmount()
                }
            }

            if let error = amountError {
              Text(error)
                .font(.caption)
                .foregroundColor(.red)
            }
          }

          // Date Picker
          VStack(alignment: .leading, spacing: 8) {
            Text("Date")
              .font(.headline)
              .foregroundColor(.primary)

            DatePicker("Select Date", selection: $date, displayedComponents: .date)
              .datePickerStyle(CompactDatePickerStyle())
          }

          // Note Field
          VStack(alignment: .leading, spacing: 8) {
            Text("Note (Optional)")
              .font(.headline)
              .foregroundColor(.primary)

            TextEditor(text: $note)
              .frame(height: 100)
              .overlay(
                RoundedRectangle(cornerRadius: 8)
                  .stroke(Color.gray.opacity(0.3), lineWidth: 1)
              )
          }

          // Action Button
          Button(action: saveProgress) {
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
        }
        .padding()
      }
      .navigationTitle("Edit Progress")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button("Cancel") {
            presentationMode.wrappedValue.dismiss()
          }
        }
      }
      .onAppear {
        loadProgressData()
      }
      .glassmorphismBackground()
    }
  }

  // MARK: - Computed Properties

  private var isFormValid: Bool {
    return amountError == nil && !amount.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
      && Double(amount) != nil && Double(amount)! > 0
  }

  // MARK: - Methods

  private func loadProgressData() {
    amount = String(progress.amount)
    note = progress.note
    date = progress.date
  }

  private func validateAmount() {
    amountError = nil

    guard let amountValue = Double(amount) else {
      amountError = "Please enter a valid amount"
      return
    }

    if amountValue <= 0 {
      amountError = "Amount must be positive"
    } else if amountValue > 1_000_000 {
      amountError = "Amount cannot exceed $1,000,000"
    }
  }

  private func saveProgress() {
    guard let amountValue = Double(amount) else { return }

    isLoading = true

    let result = progressViewModel.updateProgress(
      progress,
      amount: amountValue,
      date: date,
      note: note
    )

    isLoading = false

    switch result {
    case .success:
      presentationMode.wrappedValue.dismiss()
    case .failure(let error):
      // Handle error (in a real app, you'd show an alert)
      print("Error updating progress: \(error.localizedDescription ?? "Unknown error")")
    }
  }
}

// MARK: - Preview

struct ProgressHistoryView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      ProgressHistoryView(progressViewModel: GoalProgressViewModel())
    }
    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
  }
}
