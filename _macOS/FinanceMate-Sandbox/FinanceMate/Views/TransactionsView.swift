// SANDBOX FILE - ENHANCED UI IMPLEMENTATION WITH WATERMARK
//
// TransactionsView.swift
// FinanceMate-Sandbox
//
// Purpose: Displays a list of transactions with controls for searching and filtering.
// Issues & Complexity Summary: Manages user interaction and state from the ViewModel.
// Key Complexity Drivers:
//   - Logic Scope (Est. LoC): ~100
//   - Core Algorithm Complexity: Low
//   - Dependencies: 1 New (SwiftUI)
//   - State Management Complexity: Medium
//   - Novelty/Uncertainty Factor: Low
// AI Pre-Task Self-Assessment: 95%
// Problem Estimate: 60%
// Initial Code Complexity Estimate: 70%
// Final Code Complexity: TBD
// Overall Result Score: TBD
// Key Variances/Learnings: TBD
// Last Updated: 2025-07-06

import SwiftUI
import CoreData

struct TransactionsView: View {
    @StateObject private var viewModel: TransactionsViewModel
    @State private var showingAddTransaction = false
    @State private var showingFilters = false
    
    private let categories = ["Food", "Transportation", "Entertainment", "Utilities", "Shopping", "Healthcare", "General"]
    
    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: TransactionsViewModel(context: context))
    }
    
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Main content
            VStack(spacing: 0) {
                headerWithSearchSection
                
                if hasActiveFilters {
                    activeFiltersSection
                }
                
                statsSummarySection
                
                transactionList
            }
            .blur(radius: showingFilters ? 10 : 0)
            
            #if SANDBOX
            Text("SANDBOX")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(8)
                .background(Color.red.opacity(0.8))
                .cornerRadius(8)
                .padding([.top, .trailing], 16)
                .accessibilityIdentifier("SandboxBadge")
            #endif
        }
        .onAppear {
            viewModel.fetchTransactions()
        }
        .sheet(isPresented: $showingAddTransaction) {
            AddEditTransactionView(viewModel: viewModel, isPresented: $showingAddTransaction)
        }
        .sheet(isPresented: $showingFilters) {
            FilterTransactionsView(
                selectedCategory: $viewModel.selectedCategory,
                startDate: $viewModel.startDate,
                endDate: $viewModel.endDate,
                categories: categories
            )
        }
    }

    private var transactionList: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .accessibilityIdentifier("LoadingIndicator")
            } else if viewModel.filteredTransactions.isEmpty {
                emptyStateView
            } else {
                List {
                    ForEach(viewModel.filteredTransactions) { transaction in
                        transactionRow(transaction)
                    }
                    .onDelete(perform: deleteTransactions)
                }
                .listStyle(PlainListStyle())
                .accessibilityIdentifier("TransactionsList")
            }
        }
    }

    private func transactionRow(_ transaction: Transaction) -> some View {
        HStack(spacing: 15) {
            Image(systemName: categoryIcon(for: transaction.category))
                .font(.title2)
                .frame(width: 40, height: 40)
                .background(Color.gray.opacity(0.1))
                .clipShape(Circle())

            VStack(alignment: .leading) {
                Text(transaction.category)
                    .font(.headline)
                if let note = transaction.note, !note.isEmpty {
                    Text(note)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing) {
                Text(viewModel.formatCurrency(transaction.amount))
                    .font(.headline)
                    .foregroundColor(transaction.amount >= 0 ? .green : .primary)
                Text(viewModel.formatDate(transaction.date))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
        .accessibilityIdentifier("TransactionRow_\(transaction.id.uuidString)")
    }

    private var emptyStateView: some View {
        VStack {
            Spacer()
            Image(systemName: "tray.fill")
                .font(.largeTitle)
                .foregroundColor(.secondary)
            Text("No Transactions Found")
                .font(.headline)
            Text("Add a new transaction to get started.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
        }
    }
    
    // MARK: - Header with Search Section
    private var headerWithSearchSection: some View {
        VStack(spacing: 16) {
            // Title and Count
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Transactions")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("\(viewModel.filteredTransactionCount) of \(viewModel.totalTransactionCount) transactions")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Filter Button
                Button(action: {
                    showingFilters = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: hasActiveFilters ? "line.horizontal.3.decrease.circle.fill" : "line.horizontal.3.decrease.circle")
                            .font(.title2)
                        Text("Filter")
                            .font(.headline)
                    }
                    .foregroundColor(hasActiveFilters ? .blue : .primary)
                }
                .accessibilityIdentifier("FilterButton")
            }
            
            // Search Bar
            HStack(spacing: 12) {
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Search transactions...", text: $viewModel.searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .accessibilityIdentifier("SearchTextField")
                    
                    if !viewModel.searchText.isEmpty {
                        Button(action: {
                            viewModel.searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                        .accessibilityIdentifier("ClearSearchButton")
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .glassmorphism(.minimal)
                
                // Add Transaction Button
                Button(action: {
                    showingAddTransaction = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                .accessibilityIdentifier("AddTransactionButton")
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .glassmorphism(.secondary)
    }
    
    // MARK: - Active Filters Section
    private var activeFiltersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Active Filters")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button("Clear All") {
                    viewModel.resetFilters()
                }
                .font(.subheadline)
                .foregroundColor(.blue)
                .accessibilityIdentifier("ClearAllFiltersButton")
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    if let category = viewModel.selectedCategory {
                        filterTag("Category: \(category)") {
                            viewModel.selectedCategory = nil
                        }
                    }
                    
                    if let startDate = viewModel.startDate {
                        filterTag("From: \(viewModel.formatDate(startDate))") {
                            viewModel.startDate = nil
                        }
                    }
                    
                    if let endDate = viewModel.endDate {
                        filterTag("To: \(viewModel.formatDate(endDate))") {
                            viewModel.endDate = nil
                        }
                    }
                    
                    if !viewModel.searchText.isEmpty {
                        filterTag("Search: \(viewModel.searchText)") {
                            viewModel.searchText = ""
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.vertical, 16)
        .glassmorphism(.minimal)
    }
    
    private func filterTag(_ text: String, onRemove: @escaping () -> Void) -> some View {
        HStack(spacing: 8) {
            Text(text)
                .font(.caption)
                .foregroundColor(.primary)
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .glassmorphism(.accent)
    }
    
    // MARK: - Stats Summary Section
    private var statsSummarySection: some View {
        HStack(spacing: 20) {
            VStack(spacing: 4) {
                Text(viewModel.formatCurrency(totalIncome))
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
                
                Text("Income")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            
            VStack(spacing: 4) {
                Text(viewModel.formatCurrency(totalExpenses))
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.red)
                
                Text("Expenses")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            
            VStack(spacing: 4) {
                Text(viewModel.formatCurrency(netAmount))
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(netAmount >= 0 ? .green : .red)
                
                Text("Net")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(20)
        .glassmorphism(.secondary)
        .accessibilityIdentifier("StatsSummaryContainer")
    }
    
    // MARK: - Quick Actions Section
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack(spacing: 16) {
                // Add Income Button
                Button(action: {
                    showingAddTransaction = true
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.green)
                        
                        Text("Add Income")
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .glassmorphism(.minimal)
                }
                .accessibilityIdentifier("AddIncomeButton")
                
                // Add Expense Button
                Button(action: {
                    showingAddTransaction = true
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: "minus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.red)
                        
                        Text("Add Expense")
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .glassmorphism(.minimal)
                }
                .accessibilityIdentifier("AddExpenseButton")
                
                // Filter Button
                Button(action: {
                    showingFilters = true
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: "line.horizontal.3.decrease.circle")
                            .font(.title2)
                            .foregroundColor(.blue)
                        
                        Text("Filter")
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .glassmorphism(.minimal)
                }
                .accessibilityIdentifier("QuickFilterButton")
            }
        }
        .padding(20)
        .glassmorphism(.accent)
    }
    
    // MARK: - Transactions List Section
    private var transactionsListSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Transactions")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if viewModel.filteredTransactionCount != viewModel.totalTransactionCount {
                        Text("Showing \(viewModel.filteredTransactionCount) of \(viewModel.totalTransactionCount)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
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
            } else if viewModel.filteredTransactions.isEmpty && !viewModel.isLoading {
                if hasActiveFilters {
                    noResultsView
                } else {
                    emptyStateView
                }
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.filteredTransactions) { transaction in
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
    
    // MARK: - No Results View
    private var noResultsView: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.secondary.opacity(0.6))
            
            VStack(spacing: 8) {
                Text("No matching transactions")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("Try adjusting your filters or search terms to find more transactions")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: {
                viewModel.resetFilters()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                    Text("Clear Filters")
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .accessibilityIdentifier("ClearFiltersButton")
        }
        .padding(40)
    }
    
    // MARK: - Filters Sheet
    private var filtersSheet: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Category Filter
                VStack(alignment: .leading, spacing: 12) {
                    Text("Category")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            // All Categories Button
                            Button(action: {
                                viewModel.selectedCategory = nil
                            }) {
                                Text("All")
                                    .font(.subheadline)
                                    .foregroundColor(viewModel.selectedCategory == nil ? .white : .primary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(viewModel.selectedCategory == nil ? Color.blue : Color.clear)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.blue, lineWidth: 1)
                                    )
                                    .cornerRadius(8)
                            }
                            
                            ForEach(categories, id: \.self) { category in
                                Button(action: {
                                    viewModel.selectedCategory = category
                                }) {
                                    Text(category)
                                        .font(.subheadline)
                                        .foregroundColor(viewModel.selectedCategory == category ? .white : .primary)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(viewModel.selectedCategory == category ? Color.blue : Color.clear)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.blue, lineWidth: 1)
                                        )
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                
                // Date Range Filter
                VStack(alignment: .leading, spacing: 12) {
                    Text("Date Range")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("From")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            DatePicker("Start Date", selection: Binding(
                                get: { viewModel.startDate ?? Date() },
                                set: { viewModel.startDate = $0 }
                            ), displayedComponents: .date)
                            .datePickerStyle(CompactDatePickerStyle())
                            .accessibilityIdentifier("StartDatePicker")
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("To")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            DatePicker("End Date", selection: Binding(
                                get: { viewModel.endDate ?? Date() },
                                set: { viewModel.endDate = $0 }
                            ), displayedComponents: .date)
                            .datePickerStyle(CompactDatePickerStyle())
                            .accessibilityIdentifier("EndDatePicker")
                        }
                    }
                    
                    HStack {
                        Button("Clear Dates") {
                            viewModel.startDate = nil
                            viewModel.endDate = nil
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                        
                        Spacer()
                    }
                }
                
                Spacer()
            }
            .padding(20)
            .navigationTitle("Filter Transactions")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showingFilters = false
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        showingFilters = false
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .accessibilityIdentifier("FiltersSheet")
    }
    
    // MARK: - Computed Properties
    private var hasActiveFilters: Bool {
        return viewModel.selectedCategory != nil || viewModel.startDate != nil || viewModel.endDate != nil || !viewModel.searchText.isEmpty
    }
    
    private var totalIncome: Double {
        viewModel.filteredTransactions.filter { $0.amount > 0 }.reduce(0) { $0 + $1.amount }
    }
    
    private var totalExpenses: Double {
        viewModel.filteredTransactions.filter { $0.amount < 0 }.reduce(0) { $0 + $1.amount }
    }
    
    private var netAmount: Double {
        totalIncome + totalExpenses
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
    
    private func deleteTransactions(at offsets: IndexSet) {
        // Implementation to come
    }
    
    private func categoryIcon(for category: String) -> String {
        switch category {
            case "Food": return "fork.knife"
            case "Transportation": return "car.fill"
            case "Entertainment": return "film.fill"
            case "Utilities": return "lightbulb.fill"
            case "Shopping": return "bag.fill"
            case "Healthcare": return "heart.fill"
            default: return "questionmark.circle.fill"
        }
    }
}

struct FilterTransactionsView: View {
    @Binding var selectedCategory: String?
    @Binding var startDate: Date?
    @Binding var endDate: Date?
    let categories: [String]
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Category")) {
                    Picker("Category", selection: $selectedCategory) {
                        Text("All").tag(String?.none)
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(String?(category))
                        }
                    }
                }

                Section(header: Text("Date Range")) {
                    DatePicker("Start Date", selection: Binding($startDate, default: Date()), displayedComponents: .date)
                    DatePicker("End Date", selection: Binding($endDate, default: Date()), displayedComponents: .date)
                }
            }
            .navigationTitle("Filters")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// Helper for optional binding
extension Binding {
    init(_ source: Binding<Value?>, default defaultValue: Value) {
        self.init(
            get: { source.wrappedValue ?? defaultValue },
            set: { source.wrappedValue = $0 }
        )
    }
}

#Preview {
    TransactionsView(context: PersistenceController.preview.container.viewContext)
}