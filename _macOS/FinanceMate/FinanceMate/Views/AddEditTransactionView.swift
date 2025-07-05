// PRODUCTION FILE - MODAL TRANSACTION MANAGEMENT
//
// AddEditTransactionView.swift
// FinanceMate
//
// Purpose: Modal view for adding/editing transactions with Australian locale and comprehensive validation
// Issues & Complexity Summary: Modal presentation, form validation, Australian locale compliance, glassmorphism styling
// Key Complexity Drivers:
//   - Logic Scope (Est. LoC): ~400
//   - Core Algorithm Complexity: Medium
//   - Dependencies: 3 (SwiftUI, Core Data, Foundation)
//   - State Management Complexity: Medium
//   - Novelty/Uncertainty Factor: Low
// AI Pre-Task Self-Assessment: 85%
// Problem Estimate: 85%
// Initial Code Complexity Estimate: 85%
// Final Code Complexity: 90%
// Overall Result Score: 92%
// Key Variances/Learnings: Modal form implementation with comprehensive validation
// Last Updated: 2025-07-06

import SwiftUI
import Foundation

struct AddEditTransactionView: View {
    @ObservedObject var viewModel: TransactionsViewModel
    @Binding var isPresented: Bool
    
    @State private var amount: String = ""
    @State private var category: String = "General"
    @State private var note: String = ""
    @State private var isIncome: Bool = false
    @State private var showingValidationError: Bool = false
    @State private var validationMessage: String = ""
    
    private let categories = ["General", "Food", "Transportation", "Entertainment", "Utilities", "Shopping", "Healthcare", "Income", "Bills", "Education", "Travel", "Other"]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.05),
                        Color.purple.opacity(0.02),
                        Color.clear
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header Section
                        headerSection
                        
                        // Amount Section
                        amountSection
                        
                        // Category Section
                        categorySection
                        
                        // Note Section
                        noteSection
                        
                        // Action Buttons
                        actionButtonsSection
                        
                        Spacer(minLength: 50)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("Add Transaction")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .accessibilityIdentifier("CancelButton")
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveTransaction()
                    }
                    .fontWeight(.semibold)
                    .disabled(!isFormValid)
                    .accessibilityIdentifier("SaveButton")
                }
            }
            .alert("Validation Error", isPresented: $showingValidationError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(validationMessage)
            }
        }
        .accessibilityIdentifier("AddEditTransactionView")
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Transaction Type Toggle
            HStack(spacing: 0) {
                Button(action: {
                    isIncome = false
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: "minus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.red)
                        
                        Text("Expense")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(isIncome ? .secondary : .primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(isIncome ? Color.clear : Color.red.opacity(0.1))
                    )
                }
                .accessibilityIdentifier("ExpenseToggle")
                
                Button(action: {
                    isIncome = true
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.green)
                        
                        Text("Income")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(isIncome ? .primary : .secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(isIncome ? Color.green.opacity(0.1) : Color.clear)
                    )
                }
                .accessibilityIdentifier("IncomeToggle")
            }
            .padding(4)
            .glassmorphism(.secondary)
        }
    }
    
    // MARK: - Amount Section
    private var amountSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Amount")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack(spacing: 12) {
                // Currency Symbol
                Text("$")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                // Amount Input
                TextField("0.00", text: $amount)
                    .font(.title2)
                    .fontWeight(.medium)
                    .textFieldStyle(PlainTextFieldStyle())
                    .accessibilityIdentifier("AmountTextField")
                    .onChange(of: amount) { oldValue, newValue in
                        // Format input to Australian currency standards
                        amount = formatAmountInput(newValue)
                    }
                
                // Clear Button
                if !amount.isEmpty {
                    Button(action: {
                        amount = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .accessibilityIdentifier("ClearAmountButton")
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .glassmorphism(.minimal)
            
            // Amount Preview
            if let amountValue = Double(amount.replacingOccurrences(of: ",", with: "")), amountValue > 0 {
                Text("Amount: \(viewModel.formatCurrency(isIncome ? amountValue : -amountValue))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 16)
            }
        }
        .accessibilityIdentifier("AmountSection")
    }
    
    // MARK: - Category Section
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Category")
                .font(.headline)
                .foregroundColor(.primary)
            
            // Category Picker
            Menu {
                ForEach(categories, id: \.self) { categoryOption in
                    Button(categoryOption) {
                        category = categoryOption
                    }
                }
            } label: {
                HStack {
                    Image(systemName: iconForCategory(category))
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(colorForCategory(category))
                        .cornerRadius(8)
                    
                    Text(category)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .glassmorphism(.minimal)
            }
            .accessibilityIdentifier("CategoryPicker")
        }
        .accessibilityIdentifier("CategorySection")
    }
    
    // MARK: - Note Section
    private var noteSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Note (Optional)")
                .font(.headline)
                .foregroundColor(.primary)
            
            TextEditor(text: $note)
                .font(.body)
                .frame(minHeight: 80)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .glassmorphism(.minimal)
                .accessibilityIdentifier("NoteTextEditor")
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                )
            
            if note.isEmpty {
                Text("Add details about this transaction...")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 16)
                    .allowsHitTesting(false)
            }
        }
        .accessibilityIdentifier("NoteSection")
    }
    
    // MARK: - Action Buttons Section
    private var actionButtonsSection: some View {
        VStack(spacing: 16) {
            // Save Button
            Button(action: saveTransaction) {
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                    
                    Text("Save Transaction")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.blue,
                            Color.blue.opacity(0.8)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
            .disabled(!isFormValid)
            .opacity(isFormValid ? 1.0 : 0.6)
            .accessibilityIdentifier("SaveTransactionButton")
            
            // Quick Amount Buttons
            VStack(alignment: .leading, spacing: 12) {
                Text("Quick Amounts")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 12) {
                    ForEach(quickAmounts, id: \.self) { quickAmount in
                        Button(action: {
                            amount = String(format: "%.2f", quickAmount)
                        }) {
                            Text(viewModel.formatCurrency(quickAmount))
                                .font(.caption)
                                .foregroundColor(.primary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.secondary.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                }
            }
            .accessibilityIdentifier("QuickAmountsSection")
        }
    }
    
    // MARK: - Computed Properties
    private var isFormValid: Bool {
        guard let amountValue = Double(amount.replacingOccurrences(of: ",", with: "")) else {
            return false
        }
        return amountValue > 0 && !category.isEmpty
    }
    
    private var quickAmounts: [Double] {
        [5.00, 10.00, 20.00, 50.00, 100.00]
    }
    
    // MARK: - Helper Methods
    private func iconForCategory(_ category: String) -> String {
        switch category.lowercased() {
        case "food": return "fork.knife"
        case "transportation": return "car.fill"
        case "entertainment": return "tv.fill"
        case "utilities": return "bolt.fill"
        case "shopping": return "bag.fill"
        case "healthcare": return "cross.fill"
        case "income": return "plus.circle.fill"
        case "bills": return "doc.text.fill"
        case "education": return "book.fill"
        case "travel": return "airplane.circle.fill"
        default: return "dollarsign.circle.fill"
        }
    }
    
    private func colorForCategory(_ category: String) -> Color {
        switch category.lowercased() {
        case "food": return .orange
        case "transportation": return .blue
        case "entertainment": return .purple
        case "utilities": return .yellow
        case "shopping": return .pink
        case "healthcare": return .red
        case "income": return .green
        case "bills": return .brown
        case "education": return .indigo
        case "travel": return .teal
        default: return .gray
        }
    }
    
    private func formatAmountInput(_ input: String) -> String {
        // Remove any non-numeric characters except decimal point
        let filtered = input.filter { $0.isNumber || $0 == "." || $0 == "," }
        
        // Ensure only one decimal point
        let components = filtered.split(separator: ".")
        if components.count > 2 {
            return String(components[0]) + "." + String(components[1])
        }
        
        // Limit decimal places to 2
        if let decimalIndex = filtered.firstIndex(of: ".") {
            let decimalPart = filtered[filtered.index(after: decimalIndex)...]
            if decimalPart.count > 2 {
                let limitedDecimal = String(decimalPart.prefix(2))
                return String(filtered[..<decimalIndex]) + "." + limitedDecimal
            }
        }
        
        return filtered
    }
    
    private func saveTransaction() {
        // Validate input
        guard let amountValue = Double(amount.replacingOccurrences(of: ",", with: "")) else {
            showValidationError("Please enter a valid amount.")
            return
        }
        
        guard amountValue > 0 else {
            showValidationError("Amount must be greater than zero.")
            return
        }
        
        guard !category.isEmpty else {
            showValidationError("Please select a category.")
            return
        }
        
        // Create transaction with proper sign
        let finalAmount = isIncome ? amountValue : -amountValue
        let finalNote = note.isEmpty ? nil : note
        
        // Save transaction
        viewModel.createTransaction(
            amount: finalAmount,
            category: category,
            note: finalNote
        )
        
        // Close modal
        isPresented = false
    }
    
    private func showValidationError(_ message: String) {
        validationMessage = message
        showingValidationError = true
    }
}

// MARK: - Preview
#Preview {
    AddEditTransactionView(
        viewModel: TransactionsViewModel(context: PersistenceController.preview.container.viewContext),
        isPresented: .constant(true)
    )
}