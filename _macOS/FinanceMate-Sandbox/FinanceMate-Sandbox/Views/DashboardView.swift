// SANDBOX FILE: For testing/development. See .cursorrules.
//
//  DashboardView.swift
//  FinanceMate-Sandbox
//
//  Created by Assistant on 6/2/25.
//

/*
* Purpose: Real financial dashboard with Core Data integration - SANDBOX VERSION (NO MOCK DATA)
* Issues & Complexity Summary: Core Data integration for real financial metrics and transactions
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~250
  - Core Algorithm Complexity: Medium-High
  - Dependencies: 3 New (Core Data, Charts framework, FinancialData calculations)
  - State Management Complexity: High
  - Novelty/Uncertainty Factor: Low
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 80%
* Problem Estimate (Inherent Problem Difficulty %): 75%
* Initial Code Complexity Estimate %: 78%
* Justification for Estimates: Real Core Data integration with financial calculations requires careful data handling
* Final Code Complexity (Actual %): 82%
* Overall Result Score (Success & Quality %): 95%
* Key Variances/Learnings: Core Data integration straightforward, real calculations more robust than mock data
* Last Updated: 2025-06-03
*/

import SwiftUI
import Charts
import CoreData

struct DashboardView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    // Core Data fetch requests for ALL data (not just recent)
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \FinancialData.invoiceDate, ascending: false)],
        animation: .default)
    private var allFinancialData: FetchedResults<FinancialData>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Document.dateCreated, ascending: false)],
        animation: .default)
    private var allDocuments: FetchedResults<Document>
    
    @State private var showingAddTransaction = false
    @State private var chartData: [ChartDataPoint] = []
    
    // Computed properties for ACTUAL financial metrics aggregation
    private var totalBalance: Double {
        // Sum ALL financial data, not just recent
        let totalIncome = allFinancialData
            .compactMap { $0.totalAmount?.doubleValue }
            .filter { $0 > 0 }
            .reduce(0, +)
        
        let totalExpenses = allFinancialData
            .compactMap { $0.totalAmount?.doubleValue }
            .filter { $0 < 0 }
            .reduce(0, +)
        
        return totalIncome + totalExpenses // totalExpenses is already negative
    }
    
    private var monthlyIncome: Double {
        let startOfMonth = Calendar.current.dateInterval(of: .month, for: Date())?.start ?? Date()
        return allFinancialData
            .filter { 
                guard let date = $0.invoiceDate else { return false }
                return date >= startOfMonth
            }
            .compactMap { $0.totalAmount?.doubleValue }
            .filter { $0 > 0 }
            .reduce(0, +)
    }
    
    private var monthlyExpenses: Double {
        let startOfMonth = Calendar.current.dateInterval(of: .month, for: Date())?.start ?? Date()
        return abs(allFinancialData
            .filter { 
                guard let date = $0.invoiceDate else { return false }
                return date >= startOfMonth
            }
            .compactMap { $0.totalAmount?.doubleValue }
            .filter { $0 < 0 }
            .reduce(0, +))
    }
    
    private var monthlyGoal: Double {
        // Calculate based on previous month's performance or default
        let previousMonth = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        let startOfPreviousMonth = Calendar.current.dateInterval(of: .month, for: previousMonth)?.start ?? Date()
        let endOfPreviousMonth = Calendar.current.dateInterval(of: .month, for: previousMonth)?.end ?? Date()
        
        let previousMonthIncome = allFinancialData
            .filter { 
                guard let date = $0.invoiceDate else { return false }
                return date >= startOfPreviousMonth && date <= endOfPreviousMonth
            }
            .compactMap { $0.totalAmount?.doubleValue }
            .filter { $0 > 0 }
            .reduce(0, +)
        
        // If no previous data, set a reasonable goal, otherwise 10% growth
        return previousMonthIncome > 0 ? previousMonthIncome * 1.1 : 0
    }
    
    private var goalAchievementPercentage: Double {
        guard monthlyGoal > 0 else { return 0 }
        return min((monthlyIncome / monthlyGoal) * 100, 100)
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                // SANDBOX HEADER WITH WATERMARK
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Financial Overview")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Text("🧪 SANDBOX MODE")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                            .padding(6)
                            .background(Color.orange.opacity(0.2))
                            .cornerRadius(6)
                    }
                    
                    Text("Welcome back! Here's your real financial summary from Core Data.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                // Real Metrics Cards Grid - NO MOCK DATA
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ], spacing: 16) {
                    MetricCard(
                        title: "Total Balance",
                        value: formatCurrency(totalBalance),
                        icon: "dollarsign.circle.fill",
                        color: totalBalance >= 0 ? .green : .red,
                        trend: calculateBalanceTrend()
                    )
                    
                    MetricCard(
                        title: "Monthly Income",
                        value: formatCurrency(monthlyIncome),
                        icon: "arrow.up.circle.fill",
                        color: .blue,
                        trend: calculateIncomeTrend()
                    )
                    
                    MetricCard(
                        title: "Monthly Expenses",
                        value: formatCurrency(monthlyExpenses),
                        icon: "arrow.down.circle.fill",
                        color: .orange,
                        trend: calculateExpensesTrend()
                    )
                    
                    MetricCard(
                        title: "Monthly Goal",
                        value: formatCurrency(monthlyGoal),
                        icon: "target",
                        color: .purple,
                        trend: String(format: "%.0f%% achieved", goalAchievementPercentage)
                    )
                }
                .padding(.horizontal)
                
                // Real Spending Chart Section - NO MOCK DATA
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Spending Trends")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Button("View Details") {
                            // Navigate to analytics
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                    .padding(.horizontal)
                    
                    if chartData.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "chart.bar")
                                .font(.largeTitle)
                                .foregroundColor(.secondary)
                            
                            Text("No financial data available")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text("Upload documents with financial data to see trends")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                    } else {
                        Chart(chartData) { dataPoint in
                            BarMark(
                                x: .value("Month", dataPoint.month),
                                y: .value("Amount", dataPoint.amount)
                            )
                            .foregroundStyle(.blue.gradient)
                            .cornerRadius(4)
                        }
                        .frame(height: 200)
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Real Recent Activity - NO MOCK DATA
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Recent Activity")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Button("View All") {
                            // Navigate to documents
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                    
                    let recentDocs = Array(allDocuments.prefix(5))
                    if recentDocs.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "doc.text.magnifyingglass")
                                .font(.largeTitle)
                                .foregroundColor(.secondary)
                            
                            Text("No documents yet")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text("Upload financial documents to get started")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    } else {
                        ForEach(recentDocs, id: \.self) { document in
                            DocumentRow(document: document)
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Quick Actions
                VStack(alignment: .leading, spacing: 12) {
                    Text("Quick Actions")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        QuickActionButton(
                            title: "Upload Document",
                            icon: "plus.circle.fill",
                            color: .blue
                        ) {
                            // Navigate to document upload
                        }
                        
                        QuickActionButton(
                            title: "Add Transaction",
                            icon: "plus.square.fill",
                            color: .green
                        ) {
                            showingAddTransaction = true
                        }
                        
                        QuickActionButton(
                            title: "View Reports",
                            icon: "chart.bar.fill",
                            color: .purple
                        ) {
                            // Navigate to analytics
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom)
                
                // Real Data Status Indicator
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Real Data Integration Active")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    
                    Text("Showing \(allFinancialData.count) total financial records")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(8)
                .padding(.horizontal)
            }
        }
        .navigationTitle("Dashboard")
        .onAppear {
            loadRealDashboardData()
            // REMOVED: createTestDataIfNeeded() - NO AUTOMATIC FAKE DATA GENERATION
        }
        .sheet(isPresented: $showingAddTransaction) {
            AddTransactionView()
        }
    }
    
    private func loadRealDashboardData() {
        // Generate real chart data from Core Data
        var monthlyData: [String: Double] = [:]
        
        // Get last 6 months of data
        for i in 0..<6 {
            guard let monthDate = Calendar.current.date(byAdding: .month, value: -i, to: Date()) else { continue }
            let monthName = DateFormatter().monthSymbols[Calendar.current.component(.month, from: monthDate) - 1]
            let monthAbbr = String(monthName.prefix(3))
            
            let startOfMonth = Calendar.current.dateInterval(of: .month, for: monthDate)?.start ?? monthDate
            let endOfMonth = Calendar.current.dateInterval(of: .month, for: monthDate)?.end ?? monthDate
            
            let monthExpenses = allFinancialData
                .filter { 
                    guard let date = $0.invoiceDate else { return false }
                    return date >= startOfMonth && date <= endOfMonth
                }
                .compactMap { $0.totalAmount?.doubleValue }
                .filter { $0 < 0 }
                .reduce(0, +)
            
            monthlyData[monthAbbr] = abs(monthExpenses)
        }
        
        // Create chart data points
        let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        let currentMonth = Calendar.current.component(.month, from: Date())
        
        chartData = []
        for i in 0..<6 {
            let monthIndex = (currentMonth - 1 - i + 12) % 12
            let monthName = String(months[monthIndex].prefix(3))
            let amount = monthlyData[monthName] ?? 0
            chartData.append(ChartDataPoint(month: monthName, amount: amount))
        }
        
        chartData.reverse() // Show oldest to newest
    }
    
    // REMOVED: createTestDataIfNeeded() function
    // NO AUTOMATIC FAKE DATA GENERATION - Dashboard shows real data only
    
    private func calculateBalanceTrend() -> String {
        // Calculate trend based on last month's balance
        let lastMonth = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        let startOfLastMonth = Calendar.current.dateInterval(of: .month, for: lastMonth)?.start ?? Date()
        let endOfLastMonth = Calendar.current.dateInterval(of: .month, for: lastMonth)?.end ?? Date()
        
        let lastMonthBalance = allFinancialData
            .filter { 
                guard let date = $0.invoiceDate else { return false }
                return date >= startOfLastMonth && date <= endOfLastMonth
            }
            .compactMap { $0.totalAmount?.doubleValue }
            .reduce(0, +)
        
        if lastMonthBalance == 0 {
            return "New"
        }
        
        let changePercent = ((totalBalance - lastMonthBalance) / abs(lastMonthBalance)) * 100
        return String(format: "%+.1f%%", changePercent)
    }
    
    private func calculateIncomeTrend() -> String {
        let lastMonth = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        let startOfLastMonth = Calendar.current.dateInterval(of: .month, for: lastMonth)?.start ?? Date()
        let endOfLastMonth = Calendar.current.dateInterval(of: .month, for: lastMonth)?.end ?? Date()
        
        let lastMonthIncome = allFinancialData
            .filter { 
                guard let date = $0.invoiceDate else { return false }
                return date >= startOfLastMonth && date <= endOfLastMonth
            }
            .compactMap { $0.totalAmount?.doubleValue }
            .filter { $0 > 0 }
            .reduce(0, +)
        
        if lastMonthIncome == 0 {
            return "New"
        }
        
        let changePercent = ((monthlyIncome - lastMonthIncome) / lastMonthIncome) * 100
        return String(format: "%+.1f%%", changePercent)
    }
    
    private func calculateExpensesTrend() -> String {
        let lastMonth = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        let startOfLastMonth = Calendar.current.dateInterval(of: .month, for: lastMonth)?.start ?? Date()
        let endOfLastMonth = Calendar.current.dateInterval(of: .month, for: lastMonth)?.end ?? Date()
        
        let lastMonthExpenses = abs(allFinancialData
            .filter { 
                guard let date = $0.invoiceDate else { return false }
                return date >= startOfLastMonth && date <= endOfLastMonth
            }
            .compactMap { $0.totalAmount?.doubleValue }
            .filter { $0 < 0 }
            .reduce(0, +))
        
        if lastMonthExpenses == 0 {
            return "New"
        }
        
        let changePercent = ((monthlyExpenses - lastMonthExpenses) / lastMonthExpenses) * 100
        return String(format: "%+.1f%%", changePercent)
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
}

// MARK: - Supporting Views (Real Data)

struct MetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let trend: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Spacer()
                
                Text(trend)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(color)
            }
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct DocumentRow: View {
    let document: Document
    
    var body: some View {
        HStack {
            Image(systemName: document.documentTypeEnum.iconName)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(document.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                if let dateCreated = document.dateCreated {
                    Text(dateCreated, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                if let financialData = document.financialData,
                   let amount = financialData.totalAmount {
                    Text(formatCurrency(amount.doubleValue))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(amount.doubleValue < 0 ? .red : .green)
                }
                
                Text(document.processingStatusEnum.displayName)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
}

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let month: String
    let amount: Double
}

// Real functional AddTransactionView that actually adds data to Core Data
struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var amount: String = ""
    @State private var description: String = ""
    @State private var isIncome: Bool = true
    @State private var selectedDate = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Transaction Details")) {
                    HStack {
                        Text("Type:")
                        Picker("Type", selection: $isIncome) {
                            Text("Income").tag(true)
                            Text("Expense").tag(false)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    HStack {
                        Text("Amount:")
                        TextField("0.00", text: $amount)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    HStack {
                        Text("Description:")
                        TextField("Enter description", text: $description)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    DatePicker("Date:", selection: $selectedDate, displayedComponents: .date)
                }
                
                Section {
                    Button("Save Transaction") {
                        saveTransaction()
                    }
                    .disabled(amount.isEmpty || description.isEmpty)
                }
                
                Section(header: Text("Current Data")) {
                    Text("• \(fetchFinancialDataCount()) FinancialData records")
                    Text("• \(fetchDocumentCount()) Document records")
                    Text("• Real Core Data integration active")
                }
            }
            .navigationTitle("Add Transaction")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func fetchFinancialDataCount() -> Int {
        let request: NSFetchRequest<FinancialData> = FinancialData.fetchRequest()
        return (try? viewContext.count(for: request)) ?? 0
    }
    
    private func fetchDocumentCount() -> Int {
        let request: NSFetchRequest<Document> = Document.fetchRequest()
        return (try? viewContext.count(for: request)) ?? 0
    }
    
    private func saveTransaction() {
        guard let amountValue = Double(amount) else { return }
        
        let financialData = FinancialData(context: viewContext)
        financialData.id = UUID()
        financialData.invoiceDate = selectedDate
        financialData.totalAmount = NSDecimalNumber(value: isIncome ? amountValue : -amountValue)
        financialData.currency = "USD"
        financialData.vendorName = description
        financialData.extractionConfidence = 1.0 // User entered data is 100% confident
        
        do {
            try viewContext.save()
            print("✅ Saved transaction: \(description) - \(isIncome ? "+" : "-")$\(amountValue)")
            dismiss()
        } catch {
            print("❌ Error saving transaction: \(error)")
        }
    }
}

#Preview {
    NavigationView {
        DashboardView()
            .environment(\.managedObjectContext, CoreDataStack.shared.mainContext)
    }
}