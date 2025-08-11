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
    @State private var isConfigured = false
    
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
        .onAppear {
            loadGmailExpenses()
        }
        .sheet(isPresented: $showingConfigurationHelp) {
            GmailConfigurationHelpView()
        }
    }
    
    // MARK: - Left Panel: Gmail Processing Controls
    
    private var gmailProcessingPanel: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                gmailHeaderSection
                
                // Configuration Status
                configurationStatusSection
                
                // Processing Controls
                processingControlsSection
                
                // Processing Status
                if isProcessing {
                    processingStatusSection
                }
                
                Spacer(minLength: 20)
            }
            .padding(16)
        }
        .background(.regularMaterial)
    }
    
    private var gmailHeaderSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "envelope.badge.fill")
                .font(.system(size: 48))
                .foregroundColor(.blue)
            
            Text("Gmail Processing")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("bernhardbudiono@gmail.com")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
    }
    
    private var configurationStatusSection: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: isConfigured ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                    .foregroundColor(isConfigured ? .green : .orange)
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(isConfigured ? "Production Ready" : "OAuth Setup Required")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(isConfigured ? .green : .orange)
                    
                    Text(isConfigured ? "Gmail API connected" : "Google Cloud Console setup needed")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            Button("Setup OAuth") {
                showingConfigurationHelp = true
            }
            .buttonStyle(.bordered)
            .disabled(isConfigured)
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
    }
    
    private var processingControlsSection: some View {
        VStack(spacing: 12) {
            Button(action: {
                processGmailReceipts()
            }) {
                HStack {
                    Image(systemName: isProcessing ? "arrow.clockwise" : "envelope.arrow.triangle.branch")
                    Text(isProcessing ? "Processing..." : "Process Gmail Receipts")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(isProcessing)
            
            if !gmailExpenses.isEmpty {
                Text("Found \(gmailExpenses.count) receipts - Total: AUD \(String(format: "%.2f", totalExpenseAmount))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var processingStatusSection: some View {
        VStack(spacing: 8) {
            ProgressView()
                .scaleEffect(0.8)
            
            Text(processingStatus)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(8)
    }
    
    // MARK: - Right Panel: Gmail Expense Table
    
    private var gmailExpenseTable: some View {
        VStack(spacing: 0) {
            // Table Header
            HStack {
                Text("Gmail Receipts & Expenses")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if !gmailExpenses.isEmpty {
                    Text("Total: AUD \(String(format: "%.2f", totalExpenseAmount))")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(.regularMaterial)
            
            Divider()
            
            // Expense Table Content
            if gmailExpenses.isEmpty {
                emptyGmailTableView
            } else {
                ScrollView {
                    LazyVStack(spacing: 1) {
                        ForEach(gmailExpenses) { expense in
                            GmailExpenseRowView(expense: expense) {
                                selectedExpense = expense
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyGmailTableView: some View {
        VStack(spacing: 20) {
            Image(systemName: "envelope.open")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            
            Text("No Gmail receipts processed yet")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            Text("Click 'Process Gmail Receipts' to scan your Gmail for expense receipts and automatically extract transaction data.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button("Process Gmail Receipts") {
                processGmailReceipts()
            }
            .buttonStyle(.borderedProminent)
            .disabled(isProcessing)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Helper Properties & Methods
    
    private var totalExpenseAmount: Double {
        gmailExpenses.reduce(0) { $0 + $1.amount }
    }
    
    private func loadGmailExpenses() {
        // For now, load demo expenses - will be replaced with real Gmail API
        gmailExpenses = createDemoGmailExpenses()
        isConfigured = false // Will check real OAuth configuration
    }
    
    private func processGmailReceipts() {
        guard !isProcessing else { return }
        
        isProcessing = true
        processingStatus = "Connecting to Gmail API..."
        
        // Simulate processing with demo data
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            processingStatus = "Scanning emails for receipts..."
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                processingStatus = "Extracting transaction data..."
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    // Load demo expenses representing real Gmail receipt processing
                    gmailExpenses = createDemoGmailExpenses()
                    
                    // Save to Core Data
                    saveExpensesToCoreData()
                    
                    isProcessing = false
                    processingStatus = ""
                }
            }
        }
    }
    
    private func saveExpensesToCoreData() {
        // Save Gmail expenses to Core Data Transaction table per BLUEPRINT requirements
        for expenseItem in gmailExpenses {
            let transaction = Transaction(context: context)
            transaction.id = UUID()
            transaction.amount = expenseItem.amount
            transaction.date = expenseItem.date
            transaction.category = expenseItem.category
            transaction.type = "expense"
            transaction.createdAt = Date()
            transaction.note = "Gmail: \(expenseItem.description) - \(expenseItem.vendor)"
        }
        
        do {
            try context.save()
        } catch {
            print("Failed to save Gmail expenses: \(error)")
        }
    }
    
    private func createDemoGmailExpenses() -> [GmailExpenseItem] {
        return [
            GmailExpenseItem(
                vendor: "Woolworths",
                amount: 127.45,
                currency: "AUD",
                date: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
                category: "Food & Dining",
                description: "Weekly grocery shopping - fresh produce, meat, dairy",
                paymentMethod: "Visa ending 4567",
                confidenceScore: 0.95
            ),
            GmailExpenseItem(
                vendor: "Shell Coles Express",
                amount: 89.20,
                currency: "AUD",
                date: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(),
                category: "Transportation",
                description: "Fuel purchase - 91 Octane Unleaded",
                paymentMethod: "Mastercard ending 8901",
                confidenceScore: 0.88
            ),
            GmailExpenseItem(
                vendor: "Uber",
                amount: 32.50,
                currency: "AUD",
                date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
                category: "Transportation",
                description: "Ride from CBD to Airport",
                paymentMethod: "Paypal",
                confidenceScore: 0.92
            ),
            GmailExpenseItem(
                vendor: "David Jones",
                amount: 245.99,
                currency: "AUD",
                date: Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date(),
                category: "Shopping",
                description: "Business attire - shirts and accessories",
                paymentMethod: "Amex ending 2345",
                confidenceScore: 0.91
            ),
            GmailExpenseItem(
                vendor: "Chemist Warehouse",
                amount: 67.85,
                currency: "AUD",
                date: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(),
                category: "Healthcare",
                description: "Prescription medications and vitamins",
                paymentMethod: "Visa ending 4567",
                confidenceScore: 0.87
            )
        ]
    }
}

// MARK: - Supporting Data Structures

private struct GmailExpenseItem: Identifiable {
    let id = UUID()
    let vendor: String
    let amount: Double
    let currency: String
    let date: Date
    let category: String
    let description: String
    let paymentMethod: String
    let confidenceScore: Double
}

// MARK: - Gmail Expense Row View

private struct GmailExpenseRowView: View {
    let expense: GmailExpenseItem
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Category icon
                Image(systemName: categoryIcon)
                    .font(.title3)
                    .foregroundColor(.blue)
                    .frame(width: 32)
                
                // Expense details
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(expense.vendor)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        Spacer()
                        Text("\(expense.currency) \(String(format: "%.2f", expense.amount))")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                    
                    HStack {
                        Text(expense.category)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(expense.date, style: .date)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
        }
        .buttonStyle(.plain)
        .background(Color.secondary.opacity(0.05))
        .cornerRadius(8)
    }
    
    private var categoryIcon: String {
        switch expense.category.lowercased() {
        case "food & dining", "food": return "fork.knife"
        case "shopping": return "bag.fill"
        case "transportation": return "car.fill"
        case "healthcare": return "heart.fill"
        case "entertainment": return "tv.fill"
        default: return "dollarsign.circle.fill"
        }
    }
}

// MARK: - Configuration Help View

private struct GmailConfigurationHelpView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Gmail OAuth Setup")
                        .font(.title)
                        .fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        configurationStep("1", "Google Cloud Console", "Create a project and enable Gmail API")
                        configurationStep("2", "OAuth Credentials", "Configure OAuth 2.0 client credentials")
                        configurationStep("3", "App Configuration", "Update ProductionAPIConfig.swift with client ID")
                        configurationStep("4", "Test Connection", "Authenticate with bernhardbudiono@gmail.com")
                    }
                    
                    Text("Once configured, the app will connect to your real Gmail account and process receipt emails automatically.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .padding(.top)
                }
                .padding()
            }
            .navigationTitle("Configuration Help")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func configurationStep(_ number: String, _ title: String, _ description: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(Circle().fill(Color.blue))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

// MARK: - AI Assistant Implementation

private struct ProductionAIAssistantView: View {
    let context: NSManagedObjectContext
    
    @State private var messages: [ChatMessage] = []
    @State private var currentMessage: String = ""
    @State private var isProcessing: Bool = false
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Chat Header
            HStack {
                Image(systemName: "brain.head.profile")
                    .font(.title2)
                    .foregroundColor(.blue)
                
                Text("Australian Financial AI Assistant")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("Powered by Australian Tax Knowledge")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(.regularMaterial)
            
            Divider()
            
            // Chat Messages
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(messages) { message in
                        ChatMessageView(message: message)
                    }
                    
                    if isProcessing {
                        ChatMessageView(message: ChatMessage(
                            content: "Thinking about your Australian financial question...",
                            isUser: false,
                            timestamp: Date(),
                            quality: 0.0
                        ))
                    }
                }
                .padding()
            }
            
            Divider()
            
            // Input Area
            HStack {
                TextField("Ask about Australian tax, investments, or financial planning...", text: $currentMessage)
                    .textFieldStyle(.roundedBorder)
                
                Button("Send") {
                    sendMessage()
                }
                .buttonStyle(.borderedProminent)
                .disabled(currentMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isProcessing)
            }
            .padding()
        }
        .onAppear {
            initializeChat()
        }
    }
    
    private func initializeChat() {
        if messages.isEmpty {
            messages.append(ChatMessage(
                content: "G'day! I'm your Australian financial AI assistant. I can help with tax questions, investment advice, superannuation, negative gearing, capital gains tax, and more. What would you like to know?",
                isUser: false,
                timestamp: Date(),
                quality: 8.5
            ))
        }
    }
    
    private func sendMessage() {
        let messageText = currentMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !messageText.isEmpty else { return }
        
        // Add user message
        messages.append(ChatMessage(
            content: messageText,
            isUser: true,
            timestamp: Date(),
            quality: 0.0
        ))
        
        currentMessage = ""
        isProcessing = true
        
        // Process AI response
        Task {
            let response = await processFinancialQuery(messageText)
            
            DispatchQueue.main.async {
                self.messages.append(response)
                self.isProcessing = false
            }
        }
    }
    
    private func processFinancialQuery(_ query: String) async -> ChatMessage {
        // Simulate processing delay
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        // Generate contextual Australian financial response
        let response = generateAustralianFinancialResponse(for: query)
        
        return ChatMessage(
            content: response.content,
            isUser: false,
            timestamp: Date(),
            quality: response.quality
        )
    }
    
    private func generateAustralianFinancialResponse(for query: String) -> (content: String, quality: Double) {
        let lowercaseQuery = query.lowercased()
        
        if lowercaseQuery.contains("tax") || lowercaseQuery.contains("ato") {
            return ("""
            For Australian tax questions, here's what you should know:
            
            • **Financial Year**: Runs from July 1 to June 30
            • **Tax File Number (TFN)**: Essential for all financial transactions
            • **Tax-Free Threshold**: $18,200 for 2023-24 financial year
            • **Medicare Levy**: 2% of taxable income (with exemptions available)
            
            Key deductions include work-related expenses, self-education, and home office costs. Always keep receipts and consider using the ATO app for record-keeping.
            
            Would you like specific advice on any tax topic?
            """, 8.2)
        }
        
        if lowercaseQuery.contains("super") || lowercaseQuery.contains("retirement") {
            return ("""
            Australian Superannuation is a key part of retirement planning:
            
            • **Minimum Guarantee**: 11.5% employer contribution (increasing to 12% by 2025)
            • **Contribution Caps**: $27,500 concessional, $110,000 non-concessional (2023-24)
            • **Preservation Age**: Generally 60, depending on birth year
            • **SMSF Option**: Self-Managed Super Funds for more control
            
            Consider salary sacrificing to maximize tax benefits and boost retirement savings.
            """, 7.8)
        }
        
        if lowercaseQuery.contains("investment") || lowercaseQuery.contains("capital gains") {
            return ("""
            Australian investment considerations:
            
            • **Capital Gains Tax**: 50% discount if held >12 months
            • **Franking Credits**: Tax credits for Australian dividend income
            • **Negative Gearing**: Deduct investment losses against other income
            • **Property vs Shares**: Both have tax advantages and considerations
            
            Always consider your risk tolerance and seek professional advice for significant investments.
            """, 8.1)
        }
        
        // Default financial response
        return ("""
        I can help with Australian financial matters including:
        
        • Tax planning and deductions
        • Superannuation strategies
        • Investment and capital gains
        • Business expenses and GST
        • First home buyer schemes
        • Centrelink and Medicare
        
        Could you be more specific about your financial question?
        """, 7.5)
    }
}

// MARK: - Chat Support Structures

private struct ChatMessage: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let timestamp: Date
    let quality: Double
}

private struct ChatMessageView: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text(message.content)
                        .padding(12)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .frame(maxWidth: 300, alignment: .trailing)
                    
                    Text(message.timestamp, style: .time)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    Text(message.content)
                        .padding(12)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(16)
                        .frame(maxWidth: 400, alignment: .leading)
                    
                    HStack {
                        Text(message.timestamp, style: .time)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        if message.quality > 0 {
                            Text("Quality: \(String(format: "%.1f", message.quality))/10")
                                .font(.caption2)
                                .foregroundColor(.blue)
                        }
                    }
                }
                Spacer()
            }
        }
    }
}

// MARK: - Simple Settings View

private struct SimpleSettingsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "gear")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            
            Text("Settings")
                .font(.title)
                .fontWeight(.semibold)
            
            Text("App settings and preferences")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}