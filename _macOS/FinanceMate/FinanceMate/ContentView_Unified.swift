import CoreData
import SwiftUI
import Foundation

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        TabView {
            // Dashboard Tab
            DashboardView(context: viewContext)
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

            // Email Receipts Tab - Unified Gmail interface
            UnifiedEmailReceiptView(context: viewContext)
                .tabItem {
                    Image(systemName: "envelope.open")
                    Text("Gmail")
                }
                .accessibilityIdentifier("EmailConnector")

            // Settings Tab
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .accessibilityIdentifier("Settings")
        }
        .frame(minWidth: 1200, minHeight: 800)
    }
}

// MARK: - Unified Gmail Interface

private struct UnifiedEmailReceiptView: View {
    let context: NSManagedObjectContext
    
    @State private var isProcessing = false
    @State private var processingStatus = ""
    @State private var isConfigured = false
    @State private var configurationStatus = "Real Gmail OAuth credentials required"
    @State private var expenses: [MockGmailExpense] = []
    @State private var totalExpenses: Double = 0.0
    @State private var processingError: String?
    
    var body: some View {
        HStack(spacing: 0) {
            // Left Panel - Gmail Processing
            leftPanelView
                .frame(width: 300)
            
            Divider()
            
            // Right Panel - Unified Expense Table (Matching Transactions Tab)
            rightPanelExpenseTable
                .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("Gmail Receipts")
        .onAppear {
            updateConfigurationStatus()
        }
    }
    
    // MARK: - Left Panel: Gmail Processing
    
    private var leftPanelView: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                headerSection
                
                // Configuration Status
                configurationStatusSection
                
                // Processing Controls
                processingControlsSection
                
                // Processing Status
                if isProcessing {
                    processingStatusSection
                }
                
                // Error Display
                if let error = processingError {
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
                Image(systemName: isConfigured ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                    .foregroundColor(isConfigured ? .green : .orange)
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(isConfigured ? "Production Ready" : "Configuration Required")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(isConfigured ? .green : .orange)
                    
                    Text(configurationStatus)
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
            if isConfigured {
                Button("Process Gmail Receipts") {
                    Task {
                        await processEmails()
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isProcessing)
            } else {
                Button("Setup OAuth") {
                    Task {
                        await authenticateGmail()
                    }
                }
                .buttonStyle(.bordered)
                .disabled(isProcessing)
                
                Text("BLUEPRINT REQUIREMENT: Real Gmail OAuth credentials needed for production use")
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
            
            Text(processingStatus)
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
                    
                    Text("\(expenses.count) expense\(expenses.count == 1 ? "" : "s") extracted")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Total amount
                VStack(alignment: .trailing) {
                    Text("AUD $\(String(format: "%.2f", totalExpenses))")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    Text("Total Expenses")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Quick stats row
            if !expenses.isEmpty {
                HStack(spacing: 20) {
                    statItem("Receipts", "\(expenses.count)", .blue)
                    statItem("Categories", "\(Set(expenses.map { $0.category.rawValue }).count)", .green)
                    
                    let avgConfidence = expenses.reduce(0) { $0 + $1.confidenceScore } / Double(max(expenses.count, 1))
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
                if expenses.isEmpty && !isProcessing {
                    emptyExpenseTableState
                } else {
                    ForEach(expenses, id: \.id) { expense in
                        gmailExpenseRow(expense)
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
                
                Text(isConfigured ? 
                     "Click 'Process Gmail Receipts' to extract expenses from your Gmail" :
                     "Setup OAuth authentication to connect to your Gmail account")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(40)
    }
    
    // Gmail expense row matching Transaction row structure
    private func gmailExpenseRow(_ expense: MockGmailExpense) -> some View {
        HStack(spacing: 16) {
            // Category Icon (matching Transaction tab)
            VStack {
                Image(systemName: iconForGmailCategory(expense.category))
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(colorForGmailCategory(expense.category))
                    .cornerRadius(12)
            }
            
            // Expense Details
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
                
                Text(expense.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                // Gmail-specific metadata
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "envelope.fill")
                            .font(.caption2)
                            .foregroundColor(.purple)
                        Text("Gmail")
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
            
            Spacer(minLength: 16)
            
            // Amount (matching Transaction format)
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(expense.currency) $\(String(format: "%.2f", expense.amount))")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.red) // All Gmail expenses are expenses
                
                Text(expense.category.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .glassmorphism(.minimal)
    }
    
    // Helper methods for Gmail categories (matching Transaction tab style)
    private func iconForGmailCategory(_ category: MockExpenseCategory) -> String {
        switch category {
        case .food: return "fork.knife"
        case .shopping: return "bag.fill"
        case .transportation: return "car.fill"
        case .utilities: return "bolt.fill"
        case .healthcare: return "cross.fill"
        case .entertainment: return "tv.fill"
        case .business: return "briefcase.fill"
        case .travel: return "airplane"
        case .subscription: return "rectangle.stack.fill"
        case .other: return "dollarsign.circle.fill"
        }
    }
    
    private func colorForGmailCategory(_ category: MockExpenseCategory) -> Color {
        switch category {
        case .food: return .orange
        case .shopping: return .pink
        case .transportation: return .blue
        case .utilities: return .yellow
        case .healthcare: return .red
        case .entertainment: return .purple
        case .business: return .indigo
        case .travel: return .cyan
        case .subscription: return .green
        case .other: return .gray
        }
    }
    
    // MARK: - Private Methods
    
    private func updateConfigurationStatus() {
        // This would check for real OAuth credentials
        isConfigured = false
        configurationStatus = "Real Gmail OAuth credentials required for production use"
    }
    
    private func authenticateGmail() async {
        processingStatus = "Initiating Gmail authentication..."
        processingError = nil
        isProcessing = true
        
        // Simulate OAuth authentication process
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        isProcessing = false
        processingError = "BLUEPRINT COMPLIANCE: Real Gmail OAuth required. This is demo mode only."
    }
    
    private func processEmails() async {
        isProcessing = true
        processingError = nil
        
        defer {
            isProcessing = false
        }
        
        // Simulate processing
        processingStatus = "Processing Gmail receipts..."
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        
        // This would use real Gmail API when configured
        expenses = MockGmailExpense.sampleData
        totalExpenses = expenses.reduce(0) { $0 + $1.amount }
        processingStatus = "Processed \(expenses.count) receipts"
    }
}

// MARK: - Mock Data for Development

struct MockGmailExpense: Identifiable {
    let id = UUID()
    let amount: Double
    let currency: String
    let date: Date
    let vendor: String
    let category: MockExpenseCategory
    let paymentMethod: String?
    let description: String
    let emailSubject: String
    let confidenceScore: Double
    
    static let sampleData: [MockGmailExpense] = [
        MockGmailExpense(
            amount: 87.50,
            currency: "AUD",
            date: Date().addingTimeInterval(-86400 * 2),
            vendor: "Woolworths",
            category: .food,
            paymentMethod: "Visa ****1234",
            description: "Weekly grocery shopping",
            emailSubject: "Your Woolworths Receipt",
            confidenceScore: 0.95
        ),
        MockGmailExpense(
            amount: 68.45,
            currency: "AUD",
            date: Date().addingTimeInterval(-86400 * 3),
            vendor: "Shell Coles Express",
            category: .transportation,
            paymentMethod: "Mastercard ****5678",
            description: "Fuel purchase - 45.2L Unleaded Petrol",
            emailSubject: "Shell Receipt",
            confidenceScore: 0.92
        ),
        MockGmailExpense(
            amount: 24.50,
            currency: "AUD",
            date: Date().addingTimeInterval(-86400),
            vendor: "Uber",
            category: .transportation,
            paymentMethod: "Apple Pay",
            description: "Uber ride from Sydney CBD",
            emailSubject: "Your trip with Uber",
            confidenceScore: 0.98
        ),
        MockGmailExpense(
            amount: 189.95,
            currency: "AUD",
            date: Date().addingTimeInterval(-86400 * 5),
            vendor: "David Jones",
            category: .shopping,
            paymentMethod: "Amex ****9012",
            description: "Business attire - shirt and accessories",
            emailSubject: "David Jones - Your Order Confirmation",
            confidenceScore: 0.89
        ),
        MockGmailExpense(
            amount: 32.90,
            currency: "AUD",
            date: Date(),
            vendor: "Chemist Warehouse",
            category: .healthcare,
            paymentMethod: "EFTPOS Debit",
            description: "Vitamins, paracetamol, first aid supplies",
            emailSubject: "Chemist Warehouse - Your Purchase Receipt",
            confidenceScore: 0.94
        )
    ]
}

enum MockExpenseCategory: String, CaseIterable {
    case food = "Food & Dining"
    case shopping = "Shopping"
    case transportation = "Transportation"
    case utilities = "Utilities"
    case healthcare = "Healthcare"
    case entertainment = "Entertainment"
    case business = "Business"
    case travel = "Travel"
    case subscription = "Subscriptions"
    case other = "Other"
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}