import SwiftUI
import CoreData

/**
 * EmailConnectorView.swift
 * 
 * Purpose: Production email connector interface with configuration awareness and functional demonstration
 * Issues & Complexity Summary: Production-ready UI with OAuth configuration detection and processing capabilities
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~350 (Full UI with configuration, processing, results)
 *   - Core Algorithm Complexity: Medium (UI state management + service coordination)
 *   - Dependencies: 3 New (EmailConnectorService, SwiftUI, glassmorphism theming)
 *   - State Management Complexity: Medium (Configuration states + processing states)
 *   - Novelty/Uncertainty Factor: Low (Standard SwiftUI patterns)
 * AI Pre-Task Self-Assessment: 90%
 * Problem Estimate: 92%
 * Initial Code Complexity Estimate: 85%
 * Target Coverage: Real Gmail integration with user-friendly configuration guidance
 * Australian Compliance: Clear configuration instructions and privacy considerations
 * Last Updated: 2025-08-10
 */

/// Production email connector view implementing BLUEPRINT "HIGHEST PRIORITY" Gmail integration
/// Provides functional OAuth-based email processing with configuration-aware operation
struct EmailConnectorView: View {
    
    // MARK: - Dependencies
    
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var emailService: EmailConnectorService
    
    // MARK: - Initialization
    
    init() {
        // Initialize with default Core Data context for BLUEPRINT compliance
        self._emailService = StateObject(wrappedValue: EmailConnectorService())
    }
    
    // MARK: - State
    
    @State private var showingConfigurationHelp = false
    @State private var showingExpenseDetails = false
    @State private var selectedExpense: GmailAPIService.ExpenseItem?
    @State private var showingAuthentication = false
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header section
                    headerSection
                    
                    // Configuration status section
                    configurationStatusSection
                    
                    // Processing section
                    if emailService.isConfigured || !emailService.expenses.isEmpty {
                        processingSection
                    }
                    
                    // Results section
                    if !emailService.expenses.isEmpty {
                        resultsSection
                    }
                    
                    // Configuration help section
                    if !emailService.isConfigured {
                        configurationHelpSection
                    }
                }
                .padding()
            }
            .navigationTitle("Email Receipt Processing")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Help") {
                        showingConfigurationHelp = true
                    }
                }
            }
            .sheet(isPresented: $showingConfigurationHelp) {
                ConfigurationHelpSheet(emailService: emailService)
            }
            .sheet(isPresented: $showingExpenseDetails) {
                if let expense = selectedExpense {
                    ExpenseDetailSheet(expense: expense)
                }
            }
            .alert("BLUEPRINT COMPLIANCE REQUIRED", isPresented: $showingAuthentication) {
                Button("Cancel", role: .cancel) { }
                Button("Configure OAuth") {
                    showingConfigurationHelp = true
                }
                Button("Authenticate Gmail") {
                    Task {
                        do {
                            try await emailService.authenticateGmail()
                        } catch {
                            print("Gmail authentication failed: \(error.localizedDescription)")
                        }
                    }
                }
            } message: {
                Text("BLUEPRINT VIOLATION: Real Gmail OAuth credentials required for bernhardbudiono@gmail.com. No mock data allowed per BLUEPRINT.md requirements.")
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: View {
        VStack(spacing: 16) {
            Image(systemName: "envelope.badge.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("Gmail Receipt Processing")
                .font(.largeTitle)
                .fontWeight(.semibold)
            
            Text("Automatically extract expenses from your Gmail receipts")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .modifier(GlassmorphismModifier(.primary))
        .padding()
    }
    
    // MARK: - Configuration Status Section
    
    private var configurationStatusSection: View {
        HStack {
            Image(systemName: emailService.isConfigured ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .foregroundColor(emailService.isConfigured ? .green : .orange)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(emailService.isConfigured ? "Ready for Production" : "Demo Mode")
                    .font(.headline)
                    .foregroundColor(emailService.isConfigured ? .green : .orange)
                
                Text(emailService.configurationStatus)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .modifier(GlassmorphismModifier(.secondary))
        .padding()
    }
    
    // MARK: - Processing Section
    
    private var processingSection: View {
        VStack(spacing: 16) {
            HStack {
                Text("Email Processing")
                    .font(.headline)
                Spacer()
                
                Button(emailService.isConfigured ? "Process Gmail Receipts" : "BLUEPRINT ERROR: Real Credentials Required") {
                    Task {
                        await processEmailsWithAuthentication()
                    }
                }
                .disabled(emailService.isProcessing)
                .buttonStyle(.borderedProminent)
            }
            
            if emailService.isProcessing {
                VStack(spacing: 8) {
                    ProgressView()
                        .scaleEffect(1.2)
                    
                    Text(emailService.processingStatus)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
            
            if let error = emailService.processingError {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                }
                .padding(.horizontal)
            }
        }
        .modifier(GlassmorphismModifier(.secondary))
        .padding()
    }
    
    // MARK: - Results Section
    
    private var resultsSection: View {
        VStack(spacing: 16) {
            HStack {
                Text("Extracted Expenses")
                    .font(.headline)
                Spacer()
                Text("Total: AUD \(String(format: "%.2f", emailService.totalExpenses))")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            }
            
            LazyVStack(spacing: 12) {
                ForEach(emailService.expenses, id: \.id) { expense in
                    ExpenseRowView(expense: expense) {
                        selectedExpense = expense
                        showingExpenseDetails = true
                    }
                }
            }
        }
        .modifier(GlassmorphismModifier(.primary))
        .padding()
    }
    
    // MARK: - Configuration Help Section
    
    private var configurationHelpSection: View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.blue)
                Text("Configuration Required")
                    .font(.headline)
                Spacer()
            }
            
            Text("To enable real Gmail processing, configure OAuth 2.0 credentials in ProductionConfig.swift")
                .font(.body)
                .foregroundColor(.secondary)
            
            Button("View Configuration Guide") {
                showingConfigurationHelp = true
            }
            .buttonStyle(.bordered)
        }
        .modifier(GlassmorphismModifier(.accent))
        .padding()
    }
    
    // MARK: - Private Methods
    
    private func processEmailsWithAuthentication() async {
        if emailService.isConfigured && !emailService.oauthManager.isProviderAuthenticated("gmail") {
            // Need to authenticate first
            do {
                try await emailService.authenticateGmail()
            } catch {
                showingAuthentication = true
                return
            }
        }
        
        await emailService.processEmails()
    }
}

// MARK: - Supporting Views

private struct ExpenseRowView: View {
    let expense: GmailAPIService.ExpenseItem
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Category icon
                Image(systemName: categoryIcon)
                    .font(.title3)
                    .foregroundColor(.blue)
                    .frame(width: 24)
                
                // Expense details
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(expense.vendor)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Spacer()
                        Text("\(expense.currency) \(String(format: "%.2f", expense.amount))")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                    
                    HStack {
                        Text(expense.category.rawValue)
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
        }
        .buttonStyle(.plain)
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
    }
    
    private var categoryIcon: String {
        switch expense.category {
        case .food: return "fork.knife"
        case .shopping: return "bag.fill"
        case .transportation: return "car.fill"
        case .utilities: return "bolt.fill"
        case .healthcare: return "heart.fill"
        case .entertainment: return "tv.fill"
        case .business: return "briefcase.fill"
        case .travel: return "airplane"
        case .subscription: return "rectangle.stack.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }
}

private struct ConfigurationHelpSheet: View {
    let emailService: EmailConnectorService
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Configuration summary
                    Text("Configuration Status")
                        .font(.headline)
                    
                    Text(emailService.getConfigurationSummary())
                        .font(.body)
                        .padding()
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(8)
                    
                    // Setup instructions
                    Text("Setup Instructions")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        instructionStep("1", "Open Google Cloud Console")
                        instructionStep("2", "Create OAuth 2.0 credentials")
                        instructionStep("3", "Update ProductionConfig.swift")
                        instructionStep("4", "Test authentication flow")
                    }
                    
                    Spacer()
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
    
    private func instructionStep(_ number: String, _ description: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.headline)
                .foregroundColor(.blue)
                .frame(width: 24, height: 24)
                .background(Circle().fill(Color.blue.opacity(0.1)))
            
            Text(description)
                .font(.body)
            
            Spacer()
        }
    }
}

private struct ExpenseDetailSheet: View {
    let expense: GmailAPIService.ExpenseItem
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                // Expense summary
                VStack(alignment: .leading, spacing: 8) {
                    Text(expense.vendor)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("\(expense.currency) \(String(format: "%.2f", expense.amount))")
                        .font(.title)
                        .foregroundColor(.blue)
                }
                
                // Details
                VStack(alignment: .leading, spacing: 12) {
                    detailRow("Category", expense.category.rawValue)
                    detailRow("Date", expense.date, style: .date)
                    detailRow("Payment Method", expense.paymentMethod ?? "Unknown")
                    detailRow("Description", expense.description)
                    detailRow("Email Subject", expense.emailSubject)
                    detailRow("Confidence Score", "\(Int(expense.confidenceScore * 100))%")
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Expense Details")
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

#Preview {
    EmailConnectorView()
}