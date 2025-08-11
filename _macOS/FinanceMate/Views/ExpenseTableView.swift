import SwiftUI
import Foundation

/**
 * ExpenseTableView.swift
 * 
 * Purpose: Display expense table from Gmail receipt processing
 * Issues & Complexity Summary: Real-time data display, UI integration, expense management
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~300 (Table display + filtering + real-time updates)
 *   - Core Algorithm Complexity: Medium (Data sorting, filtering, UI state management)
 *   - Dependencies: 2 New (GmailAPIService integration, SwiftUI table components)
 *   - State Management Complexity: Medium (Real-time expense updates, loading states)
 *   - Novelty/Uncertainty Factor: Low (Standard SwiftUI table patterns)
 * AI Pre-Task Self-Assessment: 92%
 * Problem Estimate: 95%
 * Initial Code Complexity Estimate: 88%
 * Target Coverage: Expense table display from real Gmail receipt data
 * User Acceptance Criteria: Show expense table populated from bernhardbudiono@gmail.com
 * Last Updated: 2025-08-10
 */

/// SwiftUI view displaying expense table from Gmail receipt processing
struct ExpenseTableView: View {
    
    // MARK: - Properties
    
    @StateObject private var gmailService: GmailAPIService
    @StateObject private var oauthManager = EmailOAuthManager()
    
    @State private var selectedCategory: GmailAPIService.ExpenseCategory? = nil
    @State private var sortOrder: SortOrder = .dateDescending
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var isRefreshing = false
    
    // MARK: - Computed Properties
    
    private var filteredExpenses: [GmailAPIService.ExpenseItem] {
        let expenses = selectedCategory == nil ? 
            gmailService.expenses : 
            gmailService.expenses.filter { $0.category == selectedCategory }
        
        return expenses.sorted { expense1, expense2 in
            switch sortOrder {
            case .dateDescending:
                return expense1.date > expense2.date
            case .dateAscending:
                return expense1.date < expense2.date
            case .amountDescending:
                return expense1.amount > expense2.amount
            case .amountAscending:
                return expense1.amount < expense2.amount
            case .vendorAscending:
                return expense1.vendor < expense2.vendor
            case .vendorDescending:
                return expense1.vendor > expense2.vendor
            }
        }
    }
    
    private var totalAmount: Double {
        return filteredExpenses.reduce(0) { $0 + $1.amount }
    }
    
    // MARK: - Initialization
    
    init() {
        let oauthManager = EmailOAuthManager()
        let gmailService = GmailAPIService(oauthManager: oauthManager)
        
        self._oauthManager = StateObject(wrappedValue: oauthManager)
        self._gmailService = StateObject(wrappedValue: gmailService)
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with title and controls
            headerView
            
            // Processing status
            if gmailService.isProcessing {
                processingView
            }
            
            // Main content
            if gmailService.expenses.isEmpty && !gmailService.isProcessing {
                emptyStateView
            } else {
                expenseTableView
            }
        }
        .navigationTitle("Email Receipts")
        .onAppear {
            loadExpensesIfNeeded()
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Email Receipts")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    if let lastUpdate = gmailService.lastUpdateDate {
                        Text("Last updated: \(lastUpdate, formatter: dateTimeFormatter)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Refresh button
                Button(action: refreshExpenses) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Refresh")
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
                }
                .disabled(gmailService.isProcessing)
                .opacity(gmailService.isProcessing ? 0.6 : 1.0)
            }
            
            // Summary stats
            HStack(spacing: 32) {
                StatView(
                    title: "Total Expenses", 
                    value: String(format: "%.2f", totalAmount),
                    prefix: "$"
                )
                
                StatView(
                    title: "Count", 
                    value: "\(filteredExpenses.count)",
                    prefix: ""
                )
                
                StatView(
                    title: "Categories", 
                    value: "\(Set(gmailService.expenses.map { $0.category }).count)",
                    prefix: ""
                )
                
                Spacer()
            }
            
            // Filters and sorting
            HStack {
                // Category filter
                Menu("Category: \(selectedCategory?.rawValue ?? "All")") {
                    Button("All Categories") {
                        selectedCategory = nil
                    }
                    
                    ForEach(GmailAPIService.ExpenseCategory.allCases, id: \.self) { category in
                        Button(category.rawValue) {
                            selectedCategory = category
                        }
                    }
                }
                .menuStyle(BorderedProminentMenuStyle())
                
                Spacer()
                
                // Sort order
                Menu("Sort: \(sortOrder.displayName)") {
                    ForEach(SortOrder.allCases, id: \.self) { order in
                        Button(order.displayName) {
                            sortOrder = order
                        }
                    }
                }
                .menuStyle(BorderedProminentMenuStyle())
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
        .padding(.horizontal)
    }
    
    // MARK: - Processing View
    
    private var processingView: some View {
        HStack {
            ProgressView()
                .scaleEffect(0.8)
                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
            
            Text(gmailService.processingStatus)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .animation(.easeInOut, value: gmailService.processingStatus)
        }
        .padding()
    }
    
    // MARK: - Empty State View
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "envelope.open")
                .font(.system(size: 64, weight: .light))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("No Email Receipts Found")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Connect to Gmail to automatically extract expense data from your receipt emails.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            VStack(spacing: 12) {
                if !oauthManager.isProviderAuthenticated("gmail") {
                    Button("Connect Gmail Account") {
                        Task {
                            await authenticateGmail()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    Button("Scan for Receipts") {
                        Task {
                            await loadExpenses()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Expense Table View
    
    private var expenseTableView: some View {
        Table(filteredExpenses) {
            TableColumn("Date") { expense in
                Text(expense.date, formatter: dateFormatter)
                    .font(.system(.body, design: .monospaced))
            }
            .width(80)
            
            TableColumn("Vendor") { expense in
                VStack(alignment: .leading, spacing: 2) {
                    Text(expense.vendor)
                        .font(.body)
                        .fontWeight(.medium)
                    
                    Text(expense.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            .width(200)
            
            TableColumn("Amount") { expense in
                HStack {
                    Text(expense.currency)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(String(format: "%.2f", expense.amount))
                        .font(.system(.body, design: .monospaced))
                        .fontWeight(.semibold)
                }
            }
            .width(80)
            
            TableColumn("Category") { expense in
                HStack {
                    CategoryIcon(category: expense.category)
                    
                    Text(expense.category.rawValue)
                        .font(.subheadline)
                }
            }
            .width(150)
            
            TableColumn("Payment") { expense in
                if let paymentMethod = expense.paymentMethod {
                    Text(paymentMethod)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                } else {
                    Text("—")
                        .foregroundColor(.secondary)
                }
            }
            .width(100)
            
            TableColumn("Confidence") { expense in
                ConfidenceIndicator(score: expense.confidenceScore)
            }
            .width(80)
        }
        .tableStyle(InsetTableStyle())
        .padding(.horizontal)
    }
    
    // MARK: - Helper Methods
    
    private func loadExpensesIfNeeded() {
        if gmailService.expenses.isEmpty && oauthManager.isProviderAuthenticated("gmail") {
            Task {
                await loadExpenses()
            }
        }
    }
    
    private func refreshExpenses() {
        Task {
            await loadExpenses()
        }
    }
    
    private func authenticateGmail() async {
        do {
            _ = try await oauthManager.authenticateProvider("gmail")
            await loadExpenses()
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
    
    private func loadExpenses() async {
        do {
            try await gmailService.fetchAndProcessReceipts()
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
}

// MARK: - Supporting Views and Types

struct StatView: View {
    let title: String
    let value: String
    let prefix: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                if !prefix.isEmpty {
                    Text(prefix)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                    .fontDesign(.monospaced)
            }
        }
    }
}

struct CategoryIcon: View {
    let category: GmailAPIService.ExpenseCategory
    
    var body: some View {
        Image(systemName: iconName)
            .foregroundColor(iconColor)
            .font(.caption)
    }
    
    private var iconName: String {
        switch category {
        case .food: return "fork.knife"
        case .shopping: return "bag"
        case .transportation: return "car"
        case .utilities: return "bolt"
        case .healthcare: return "heart"
        case .entertainment: return "tv"
        case .business: return "briefcase"
        case .travel: return "airplane"
        case .subscription: return "repeat"
        case .other: return "questionmark.circle"
        }
    }
    
    private var iconColor: Color {
        switch category {
        case .food: return .orange
        case .shopping: return .blue
        case .transportation: return .green
        case .utilities: return .yellow
        case .healthcare: return .red
        case .entertainment: return .purple
        case .business: return .brown
        case .travel: return .cyan
        case .subscription: return .pink
        case .other: return .gray
        }
    }
}

struct ConfidenceIndicator: View {
    let score: Double
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            
            Text(String(format: "%.0f%%", score * 100))
                .font(.caption)
                .foregroundColor(color)
        }
    }
    
    private var color: Color {
        if score >= 0.8 {
            return .green
        } else if score >= 0.6 {
            return .orange
        } else {
            return .red
        }
    }
}

enum SortOrder: CaseIterable {
    case dateDescending, dateAscending
    case amountDescending, amountAscending
    case vendorAscending, vendorDescending
    
    var displayName: String {
        switch self {
        case .dateDescending: return "Date (Newest)"
        case .dateAscending: return "Date (Oldest)"
        case .amountDescending: return "Amount (High)"
        case .amountAscending: return "Amount (Low)"
        case .vendorAscending: return "Vendor (A-Z)"
        case .vendorDescending: return "Vendor (Z-A)"
        }
    }
}

// MARK: - Formatters

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .none
    return formatter
}()

private let dateTimeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}()

#Preview {
    ExpenseTableView()
}