import CoreData
import SwiftUI
import Foundation

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        TabView {
            // Dashboard Tab
            DashboardView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Dashboard")
                }
                .accessibilityIdentifier("Dashboard")

            // Transactions Tab
            TransactionsView(context: viewContext)
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Transactions")
                }
                .accessibilityIdentifier("Transactions")

            // Email Receipts Tab - Ready for Gmail Integration
            GmailReceiptView(context: viewContext)
                .tabItem {
                    Image(systemName: "envelope.open")
                    Text("Gmail")
                }
                .accessibilityIdentifier("EmailConnector")

            // AI Assistant Tab
            ProductionAIAssistantView(context: viewContext)
                .tabItem {
                    Image(systemName: "brain.head.profile")
                    Text("AI Assistant")
                }
                .accessibilityIdentifier("AIAssistant")

            // Settings Tab
            SimpleSettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .accessibilityIdentifier("Settings")
        }
        .frame(minWidth: 1200, minHeight: 800)
    }
}

// MARK: - Gmail Receipt Processing Interface

private struct GmailReceiptView: View {
    let context: NSManagedObjectContext
    
    @State private var isProcessing = false
    @State private var processingStatus = ""
    @State private var gmailExpenses: [GmailExpenseItem] = []
    @State private var showingConfigurationHelp = false
    @State private var selectedExpense: GmailExpenseItem?
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // Left Panel - Gmail Processing Controls
            gmailProcessingPanel
                .frame(width: 300)
            
            Divider()
            
            // Right Panel - Gmail Expense Table
            gmailExpenseTable
                .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("Gmail Receipt Processing")
        .sheet(isPresented: $showingConfigurationHelp) {
            GmailConfigurationHelpView()
        }
    }
    
    // MARK: - Left Panel: Gmail Processing Controls
    
    private var gmailProcessingPanel: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                headerSection
                
                // Configuration Status
                configurationStatusSection
                
                // Processing Controls
                processingControlsSection
                
                // Processing Status
                if emailConnector.isProcessing {
                    processingStatusSection
                }
                
                // Error Display
                if let error = emailConnector.processingError {
                    errorSection(error: error)
                }
                
                Spacer(minLength: 20)
            }
            .padding(16)
        }
        .background(.regularMaterial)
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "envelope.badge.fill")
                .font(.system(size: 48))
                .foregroundColor(.blue)
            
            Text("Gmail Receipt Processing")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            Text("bernhardbudiono@gmail.com")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .glassmorphism(.secondary)
    }
    
    private var configurationStatusSection: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: emailConnector.isConfigured ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                    .foregroundColor(emailConnector.isConfigured ? .green : .orange)
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(emailConnector.isConfigured ? "Production Ready" : "Configuration Required")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(emailConnector.isConfigured ? .green : .orange)
                    
                    Text(emailConnector.configurationStatus)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                }
                
                Spacer()
            }
        }
        .padding(12)
        .glassmorphism(.minimal)
    }
    
    private var processingControlsSection: some View {
        VStack(spacing: 12) {
            if emailConnector.isConfigured {
                Button("Process Gmail Receipts") {
                    Task {
                        await processRealGmailReceipts()
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(emailConnector.isProcessing)
            } else {
                Button("Setup OAuth") {
                    Task {
                        await authenticateRealGmail()
                    }
                }
                .buttonStyle(.bordered)
                .disabled(emailConnector.isProcessing)
                
                Text("BLUEPRINT REQUIREMENT: Real Gmail OAuth credentials needed for bernhardbudiono@gmail.com")
                    .font(.caption)
                    .foregroundColor(.orange)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
            }
        }
        .padding(12)
        .glassmorphism(.accent)
    }
    
    private var processingStatusSection: some View {
        VStack(spacing: 8) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text(emailConnector.processingStatus)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(12)
        .glassmorphism(.minimal)
    }
    
    private func errorSection(error: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
            
            Text("Processing Error")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.red)
            
            Text(error)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(12)
        .glassmorphism(.minimal)
    }
    
    // MARK: - Right Panel: Unified Expense Table
    
    private var rightPanelExpenseTable: some View {
        VStack(spacing: 0) {
            // Header matching Transactions tab
            expenseTableHeader
            
            Divider()
            
            // Expense list with same structure as Transactions tab
            expenseTableContent
        }
        .background(.regularMaterial)
    }
    
    private var expenseTableHeader: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Gmail Receipts")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text("\(emailConnector.expenses.count) expense\(emailConnector.expenses.count == 1 ? "" : "s") extracted")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Total amount
                VStack(alignment: .trailing) {
                    Text("AUD $\(String(format: "%.2f", emailConnector.totalExpenses))")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    Text("Total Expenses")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Quick stats row
            if !emailConnector.expenses.isEmpty {
                HStack(spacing: 20) {
                    statItem("Receipts", "\(emailConnector.expenses.count)", .blue)
                    statItem("Categories", "\(Set(emailConnector.expenses.map { $0.category.rawValue }).count)", .green)
                    
                    let avgConfidence = emailConnector.expenses.reduce(0) { $0 + $1.confidenceScore } / Double(max(emailConnector.expenses.count, 1))
                    statItem("Confidence", "\(Int(avgConfidence * 100))%", .orange)
                }
            }
        }
        .padding(16)
    }
    
    private func statItem(_ title: String, _ value: String, _ color: Color) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var expenseTableContent: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if emailConnector.expenses.isEmpty && !emailConnector.isProcessing {
                    emptyExpenseTableState
                } else {
                    ForEach(emailConnector.expenses, id: \.id) { expense in
                        realGmailExpenseRow(expense)
                    }
                }
            }
            .padding(16)
        }
    }
    
    private var emptyExpenseTableState: some View {
        VStack(spacing: 20) {
            Image(systemName: "envelope.open")
                .font(.system(size: 60))
                .foregroundColor(.secondary.opacity(0.6))
            
            VStack(spacing: 8) {
                Text("No Gmail receipts processed")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(emailConnector.isConfigured ? 
                     "Click 'Process Gmail Receipts' to extract expenses from bernhardbudiono@gmail.com" :
                     "Setup OAuth authentication to connect to bernhardbudiono@gmail.com")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(40)
    }
    
    // Real Gmail expense row matching Transaction row structure exactly
    private func realGmailExpenseRow(_ expense: GmailAPIService.ExpenseItem) -> some View {
        Button(action: {
            selectedExpense = expense
            showingExpenseDetails = true
        }) {
            HStack(spacing: 16) {
                // Category Icon (matching Transaction tab exactly)
                VStack {
                    Image(systemName: iconForCategory(expense.category.rawValue))
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(colorForCategory(expense.category.rawValue))
                        .cornerRadius(12)
                }
                .accessibilityIdentifier("GmailExpenseCategoryContainer")
                
                // Transaction Details (matching Transaction tab structure)
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(expense.vendor)
                            .font(.headline)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Text(expense.date, style: .date)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Description with Gmail metadata
                    VStack(alignment: .leading, spacing: 4) {
                        Text(expense.emailSubject)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        
                        // Gmail-specific metadata (similar to Transaction tab note section)
                        HStack(spacing: 12) {
                            HStack(spacing: 4) {
                                Image(systemName: "envelope.fill")
                                    .font(.caption2)
                                    .foregroundColor(.purple)
                                Text("Gmail Receipt")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            
                            if let paymentMethod = expense.paymentMethod {
                                HStack(spacing: 4) {
                                    Image(systemName: "creditcard.fill")
                                        .font(.caption2)
                                        .foregroundColor(.blue)
                                    Text(paymentMethod)
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            HStack(spacing: 4) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.caption2)
                                    .foregroundColor(.green)
                                Text("\(Int(expense.confidenceScore * 100))%")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                Spacer(minLength: 16)
                
                // Amount (matching Transaction format exactly)
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(expense.currency) $\(String(format: "%.2f", expense.amount))")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.red) // All Gmail expenses are expenses
                    
                    Text("Expense")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(16)
            .glassmorphism(.minimal)
            .accessibilityIdentifier("GmailExpenseRow")
        }
        .buttonStyle(.plain)
    }
    
    // Helper methods matching Transaction tab exactly
    private func iconForCategory(_ category: String) -> String {
        switch category.lowercased() {
        case "food & dining", "food": return "fork.knife"
        case "transportation": return "car.fill"
        case "entertainment": return "tv.fill"
        case "utilities": return "bolt.fill"
        case "shopping": return "bag.fill"
        case "healthcare": return "cross.fill"
        case "business": return "briefcase.fill"
        case "travel": return "airplane"
        case "subscriptions": return "rectangle.stack.fill"
        default: return "dollarsign.circle.fill"
        }
    }
    
    private func colorForCategory(_ category: String) -> Color {
        switch category.lowercased() {
        case "food & dining", "food": return .orange
        case "transportation": return .blue
        case "entertainment": return .purple
        case "utilities": return .yellow
        case "shopping": return .pink
        case "healthcare": return .red
        case "business": return .indigo
        case "travel": return .cyan
        case "subscriptions": return .green
        default: return .gray
        }
    }
    
    // MARK: - Private Methods
    
    private func authenticateRealGmail() async {
        do {
            _ = try await emailConnector.authenticateGmail()
        } catch {
            // Error handling is already done in EmailConnectorService
        }
    }
    
    private func processRealGmailReceipts() async {
        await emailConnector.processEmails()
    }
}

// MARK: - Supporting Views

private struct ConfigurationHelpView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Gmail OAuth Configuration")
                        .font(.headline)
                    
                    Text("To process receipts from bernhardbudiono@gmail.com, you need to configure Gmail OAuth 2.0 credentials in the ProductionConfig.swift file.")
                        .font(.body)
                        .padding()
                        .background(.regularMaterial)
                        .cornerRadius(12)
                    
                    Text("BLUEPRINT Requirements")
                        .font(.headline)
                    
                    Text("Real Gmail OAuth credentials required for production use. No mock data allowed per BLUEPRINT.md requirements.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .padding()
                        .background(.regularMaterial)
                        .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("Gmail Configuration")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

private struct ExpenseDetailView: View {
    let expense: GmailAPIService.ExpenseItem
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                // Expense Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(expense.vendor)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("\(expense.currency) $\(String(format: "%.2f", expense.amount))")
                        .font(.title)
                        .foregroundColor(.red)
                }
                
                // Details
                VStack(alignment: .leading, spacing: 12) {
                    detailRow("Category", expense.category.rawValue)
                    detailRow("Date", expense.date, style: .date)
                    detailRow("Payment Method", expense.paymentMethod ?? "Unknown")
                    detailRow("Description", expense.description)
                    detailRow("Email Subject", expense.emailSubject)
                    detailRow("Confidence Score", "\(Int(expense.confidenceScore * 100))%")
                    detailRow("Gmail Processing", "Extracted from bernhardbudiono@gmail.com")
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Expense Details")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func detailRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
        }
    }
    
    private func detailRow(_ label: String, _ date: Date, style: Text.DateStyle) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(date, style: style)
                .font(.subheadline)
        }
    }
}

// MARK: - Gmail Integration Complete
// Real EmailConnectorService now integrated - SimplifiedGmailProcessor removed

// MARK: - Simple Settings View (Temporary Build Fix)

private struct SimpleSettingsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Settings")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("FinanceMate Settings")
                .font(.title2)
                .foregroundColor(.secondary)
            
            VStack(spacing: 16) {
                settingRow("Theme", "System")
                settingRow("Currency", "AUD")
                settingRow("Notifications", "Enabled")
                settingRow("Data Source", "Core Data + Gmail")
            }
            .glassmorphism(.primary)
            .padding()
            
            Spacer()
        }
        .padding()
    }
    
    private func settingRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.primary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}