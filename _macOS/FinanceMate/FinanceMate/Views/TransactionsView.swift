// PRODUCTION FILE - UI IMPLEMENTATION
//
// TransactionsView.swift
// FinanceMate
//
// Purpose: MVVM View for displaying and managing financial transactions with glassmorphism design
// Issues & Complexity Summary: SwiftUI layout, Core Data integration, glassmorphism styling, transaction display
// Key Complexity Drivers:
//   - Logic Scope (Est. LoC): ~450
//   - Core Algorithm Complexity: Medium
//   - Dependencies: 4 (SwiftUI, Core Data, Combine, Foundation)
//   - State Management Complexity: Medium
//   - Novelty/Uncertainty Factor: Low
// AI Pre-Task Self-Assessment: 85%
// Problem Estimate: 85%
// Initial Code Complexity Estimate: 82%
// Final Code Complexity: 85%
// Overall Result Score: 92%
// Key Variances/Learnings: Glassmorphism design system integration with transaction list UI
// Last Updated: 2025-07-05

import SwiftUI
import CoreData

struct TransactionsView: View {
    @EnvironmentObject var viewModel: TransactionsViewModel
    @State private var showingAddTransaction = false
    @State private var newTransactionAmount = ""
    @State private var newTransactionCategory = "General"
    @State private var newTransactionNote = ""
    
    let categories = ["Food", "Transportation", "Entertainment", "Utilities", "Shopping", "Healthcare", "General"]
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.1),
                    Color.purple.opacity(0.05),
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
                    
                    // Add Transaction Section
                    addTransactionSection
                    
                    // Transactions List Section
                    transactionsListSection
                    
                    Spacer(minLength: 50)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .accessibilityIdentifier("TransactionsView")
        }
        .onAppear {
            viewModel.fetchTransactions()
        }
        .sheet(isPresented: $showingAddTransaction) {
            addTransactionSheet
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Transactions")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Manage your financial records")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Quick Stats
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(viewModel.transactions.count)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Total Transactions")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Transaction Summary
            if !viewModel.transactions.isEmpty {
                HStack(spacing: 20) {
                    VStack(spacing: 4) {
                        Text("\(totalIncome, specifier: "%.2f")")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                        
                        Text("Income")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(spacing: 4) {
                        Text("\(totalExpenses, specifier: "%.2f")")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.red)
                        
                        Text("Expenses")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(spacing: 4) {
                        Text("\(netAmount, specifier: "%.2f")")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(netAmount >= 0 ? .green : .red)
                        
                        Text("Net")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(20)
        .glassmorphism(.secondary)
        .accessibilityIdentifier("TransactionsHeaderContainer")
    }
    
    // MARK: - Add Transaction Section
    private var addTransactionSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Quick Actions")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("Add new transactions or manage existing ones")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: {
                showingAddTransaction = true
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                    
                    Text("Add Transaction")
                        .font(.headline)
                        .fontWeight(.medium)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue, Color.purple]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
            .accessibilityIdentifier("AddTransactionButton")
        }
        .padding(20)
        .glassmorphism(.accent)
    }
    
    // MARK: - Transactions List Section
    private var transactionsListSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Recent Transactions")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                        .accessibilityIdentifier("TransactionsLoadingIndicator")
                }
            }
            
            if let errorMessage = viewModel.errorMessage {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.orange)
                    
                    Text("Error Loading Transactions")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(errorMessage)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Button("Retry") {
                        viewModel.fetchTransactions()
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding(20)
            } else if viewModel.transactions.isEmpty && !viewModel.isLoading {
                emptyStateView
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.transactions, id: \.self) { transaction in
                        transactionRow(transaction)
                    }
                }
                .accessibilityIdentifier("TransactionsList")
            }
        }
        .padding(20)
        .glassmorphism(.primary)
        .accessibilityIdentifier("TransactionsListContainer")
    }
    
    // MARK: - Transaction Row
    private func transactionRow(_ transaction: Transaction) -> some View {
        HStack(spacing: 16) {
            // Category Icon
            VStack {
                Image(systemName: iconForCategory(transaction.category))
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(colorForCategory(transaction.category))
                    .cornerRadius(10)
            }
            .accessibilityIdentifier("TransactionCategoryContainer")
            
            // Transaction Details
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(transaction.category)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(formatDate(transaction.date))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let note = transaction.note, !note.isEmpty {
                    Text(note)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            // Amount
            VStack(alignment: .trailing, spacing: 2) {
                Text("$\(transaction.amount, specifier: "%.2f")")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(transaction.amount >= 0 ? .green : .red)
                
                Text(transaction.amount >= 0 ? "Income" : "Expense")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .glassmorphism(.minimal)
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "list.bullet.clipboard")
                .font(.system(size: 60))
                .foregroundColor(.secondary.opacity(0.6))
            
            VStack(spacing: 8) {
                Text("No transactions found")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("Start by adding your first transaction using the button above")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: {
                showingAddTransaction = true
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                    Text("Add First Transaction")
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
        .padding(40)
    }
    
    // MARK: - Add Transaction Sheet
    private var addTransactionSheet: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Amount")
                        .font(.headline)
                    
                    TextField("0.00", text: $newTransactionAmount)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Category")
                        .font(.headline)
                    
                    Picker("Category", selection: $newTransactionCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Note (Optional)")
                        .font(.headline)
                    
                    TextField("Add a note...", text: $newTransactionNote)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Spacer()
            }
            .padding(20)
            .navigationTitle("Add Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showingAddTransaction = false
                        resetForm()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveTransaction()
                    }
                    .disabled(newTransactionAmount.isEmpty)
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    private var totalIncome: Double {
        viewModel.transactions.filter { $0.amount > 0 }.reduce(0) { $0 + $1.amount }
    }
    
    private var totalExpenses: Double {
        abs(viewModel.transactions.filter { $0.amount < 0 }.reduce(0) { $0 + $1.amount })
    }
    
    private var netAmount: Double {
        viewModel.transactions.reduce(0) { $0 + $1.amount }
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
        default: return .gray
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func saveTransaction() {
        guard let amount = Double(newTransactionAmount) else { return }
        
        viewModel.createTransaction(
            amount: amount,
            category: newTransactionCategory,
            note: newTransactionNote.isEmpty ? nil : newTransactionNote
        )
        
        showingAddTransaction = false
        resetForm()
    }
    
    private func resetForm() {
        newTransactionAmount = ""
        newTransactionCategory = "General"
        newTransactionNote = ""
    }
}

#Preview {
    TransactionsView()
        .environmentObject(TransactionsViewModel(context: PersistenceController.preview.container.viewContext))
}