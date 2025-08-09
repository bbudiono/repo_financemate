//
// EmailProcessingView.swift
// FinanceMate
//
// Created by AI Agent on 2025-08-09.
// Phase 2 P1 Email-Receipt Integration: UI layer completing Email Processing Pipeline
//

/*
 * Purpose: SwiftUI View for Phase 2 P1 Email-Receipt Processing integration
 * Issues & Complexity Summary: UI state binding, progress visualization, results display, integration with ReceiptParser and EmailTransactionMatcher
 * Key Complexity Drivers:
   - Logic Scope (Est. LoC): ~400 (UI components + state management + service integration + results visualization)
   - Core Algorithm Complexity: Medium (SwiftUI state binding, async UI updates, results processing)
   - Dependencies: EmailProcessingViewModel, ReceiptParser, EmailTransactionMatcher, SwiftUI framework
   - State Management Complexity: High (async processing states, progress tracking, results visualization)
   - Novelty/Uncertainty Factor: Low (standard SwiftUI patterns, established MVVM integration)
 * AI Pre-Task Self-Assessment: 91%
 * Problem Estimate: 88%
 * Initial Code Complexity Estimate: 90%
 * Final Code Complexity: 92%
 * Overall Result Score: 90%
 * Key Variances/Learnings: SwiftUI async state management requires careful progress visualization
 * Last Updated: 2025-08-09
 */

import SwiftUI

/// Phase 2 P1 Email-Receipt Integration View
/// Provides UI for Gmail/Outlook email processing with receipt parsing and transaction matching
struct EmailProcessingView: View {
    
    @StateObject private var viewModel = EmailProcessingViewModel()
    @State private var showingResults = false
    @State private var selectedResult: EmailProcessingResult?
    @State private var showingTransactionDetails = false
    @State private var selectedTransaction: ValidatedTransaction?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                
                // Header Section
                headerSection
                
                // Status Section
                statusSection
                
                // Processing Controls
                processingControlsSection
                
                // Results Section
                if viewModel.hasResults {
                    resultsSection
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Email Processing")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Clear Results") {
                        viewModel.clearProcessingResults()
                    }
                    .disabled(!viewModel.hasResults)
                }
            }
        }
        .sheet(isPresented: $showingResults) {
            if let result = selectedResult {
                EmailProcessingResultView(result: result, onTransactionSelected: { transaction in
                    selectedTransaction = transaction
                    showingResults = false
                    showingTransactionDetails = true
                })
            }
        }
        .sheet(isPresented: $showingTransactionDetails) {
            if let transaction = selectedTransaction {
                TransactionDetailView(transaction: transaction)
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "envelope.badge.fill")
                    .font(.title2)
                    .foregroundColor(.accentColor)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Email Receipt Processing")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Gmail Integration for \(viewModel.configuredEmailAccount)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            Divider()
        }
    }
    
    // MARK: - Status Section
    
    private var statusSection: some View {
        VStack(spacing: 16) {
            
            // Processing Status
            HStack {
                Circle()
                    .fill(statusColor)
                    .frame(width: 12, height: 12)
                
                Text(viewModel.processingStatusText)
                    .font(.headline)
                    .foregroundColor(statusColor)
                
                Spacer()
                
                if viewModel.isProcessing {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
            
            // Progress Bar
            if viewModel.isProcessing {
                ProgressView(value: viewModel.processingProgress)
                    .progressViewStyle(LinearProgressViewStyle())
                    .animation(.easeInOut, value: viewModel.processingProgress)
            }
            
            // Results Summary
            if viewModel.hasResults {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Results Summary")
                            .font(.headline)
                        
                        Text(viewModel.resultsSummaryText)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button("View Details") {
                        showingResults = true
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }
    
    // MARK: - Processing Controls
    
    private var processingControlsSection: some View {
        VStack(spacing: 16) {
            
            // Primary Processing Button
            Button(action: {
                Task {
                    await processEmails()
                }
            }) {
                HStack {
                    Image(systemName: "envelope.arrow.triangle.branch")
                        .font(.headline)
                    
                    Text("Process Financial Emails")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.canStartProcessing ? Color.accentColor : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(!viewModel.canStartProcessing)
            
            // Processing Statistics
            if viewModel.hasResults {
                processingStatisticsView
            }
        }
    }
    
    // MARK: - Results Section
    
    private var resultsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Processing Results")
                .font(.headline)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                
                ForEach(Array(viewModel.processingResults.enumerated()), id: \.offset) { index, result in
                    resultCardView(result: result, index: index)
                }
            }
        }
        .padding(.top)
    }
    
    // MARK: - Processing Statistics
    
    private var processingStatisticsView: some View {
        let stats = viewModel.getProcessingStatistics()
        
        return VStack(spacing: 12) {
            Text("Processing Statistics")
                .font(.headline)
            
            HStack(spacing: 16) {
                StatisticCard(
                    title: "Total Runs",
                    value: "\(stats.totalProcessingRuns)",
                    icon: "play.circle.fill",
                    color: .blue
                )
                
                StatisticCard(
                    title: "Emails Processed",
                    value: "\(stats.totalEmailsProcessed)",
                    icon: "envelope.fill",
                    color: .green
                )
                
                StatisticCard(
                    title: "Transactions",
                    value: "\(stats.totalTransactionsExtracted)",
                    icon: "creditcard.fill",
                    color: .orange
                )
                
                StatisticCard(
                    title: "Success Rate",
                    value: "\(Int(stats.successRate * 100))%",
                    icon: "checkmark.circle.fill",
                    color: .purple
                )
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }
    
    // MARK: - Helper Views
    
    private func resultCardView(result: EmailProcessingResult, index: Int) -> some View {
        Button(action: {
            selectedResult = result
            showingResults = true
        }) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Run #\(index + 1)")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Circle()
                        .fill(result.extractedTransactions.isEmpty ? Color.red : Color.green)
                        .frame(width: 8, height: 8)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(result.processedEmails) emails")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("\(result.extractedTransactions.count) transactions")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Text(DateFormatter.shortDateTime.string(from: result.processingDate))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Computed Properties
    
    private var statusColor: Color {
        if viewModel.isProcessing {
            return .blue
        } else if viewModel.lastError != nil {
            return .red
        } else if viewModel.hasResults {
            return .green
        } else {
            return .gray
        }
    }
    
    // MARK: - Actions
    
    private func processEmails() async {
        let success = await viewModel.processFinancialEmails()
        
        if success {
            print("✅ Email processing completed successfully")
        } else {
            print("⚠️ Email processing completed with errors")
        }
    }
}

// MARK: - Supporting Views

struct StatisticCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

struct EmailProcessingResultView: View {
    let result: EmailProcessingResult
    let onTransactionSelected: (ValidatedTransaction) -> Void
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                
                // Result Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Processing Result")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Account: \(result.account)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Date: \(DateFormatter.medium.string(from: result.processingDate))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Divider()
                
                // Processing Summary
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Processed Emails")
                            .font(.headline)
                        Text("\(result.processedEmails)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Extracted Transactions")
                            .font(.headline)
                        Text("\(result.extractedTransactions.count)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                }
                
                // Transactions List
                if !result.extractedTransactions.isEmpty {
                    Text("Extracted Transactions")
                        .font(.headline)
                        .padding(.top)
                    
                    List(result.extractedTransactions, id: \.extractedTransaction.id) { transaction in
                        Button(action: {
                            onTransactionSelected(transaction)
                        }) {
                            TransactionRowView(transaction: transaction)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                        
                        Text("No transactions extracted")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        Text("Check email content and try again")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Processing Result")
        }
    }
}

struct TransactionRowView: View {
    let transaction: ValidatedTransaction
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.extractedTransaction.merchantName)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("$\(transaction.extractedTransaction.totalAmount, specifier: "%.2f")")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                if !transaction.extractedTransaction.lineItems.isEmpty {
                    Text("\(transaction.extractedTransaction.lineItems.count) line items")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Circle()
                    .fill(transaction.validationResult.isValid ? Color.green : Color.red)
                    .frame(width: 8, height: 8)
                
                Text("\(Int(transaction.validationResult.confidence * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct TransactionDetailView: View {
    let transaction: ValidatedTransaction
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    
                    // Transaction Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text(transaction.extractedTransaction.merchantName)
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("$\(transaction.extractedTransaction.totalAmount, specifier: "%.2f")")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                    
                    Divider()
                    
                    // Validation Status
                    HStack {
                        Image(systemName: transaction.validationResult.isValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(transaction.validationResult.isValid ? .green : .red)
                        
                        Text(transaction.validationResult.isValid ? "Valid Transaction" : "Validation Issues")
                            .font(.headline)
                    }
                    
                    // Line Items
                    if !transaction.extractedTransaction.lineItems.isEmpty {
                        Text("Line Items")
                            .font(.headline)
                            .padding(.top)
                        
                        ForEach(Array(transaction.extractedTransaction.lineItems.enumerated()), id: \.offset) { index, item in
                            LineItemRowView(item: item, index: index)
                        }
                    }
                    
                    // Validation Details
                    if !transaction.validationResult.errors.isEmpty || !transaction.validationResult.warnings.isEmpty {
                        Text("Validation Details")
                            .font(.headline)
                            .padding(.top)
                        
                        ForEach(transaction.validationResult.errors, id: \.self) { error in
                            Label(error, systemImage: "xmark.circle.fill")
                                .foregroundColor(.red)
                        }
                        
                        ForEach(transaction.validationResult.warnings, id: \.self) { warning in
                            Label(warning, systemImage: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Transaction Details")
        }
    }
}

struct LineItemRowView: View {
    let item: ExtractedLineItem
    let index: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Item \(index + 1)")
                    .font(.headline)
                
                Spacer()
                
                Text("$\(item.price, specifier: "%.2f")")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            Text(item.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Text("Qty: \(item.quantity, specifier: "%.0f")")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("Category: \(item.taxCategory)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Split Allocations
            if !item.splitAllocations.isEmpty {
                HStack {
                    Text("Split:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    ForEach(Array(item.splitAllocations.keys), id: \.self) { key in
                        Text("\(key): \(item.splitAllocations[key] ?? 0, specifier: "%.0f")%")
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(4)
                    }
                }
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

// MARK: - Date Formatting Extensions

private extension DateFormatter {
    static let shortDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    static let medium: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}

// MARK: - Preview Provider

#if DEBUG
struct EmailProcessingView_Previews: PreviewProvider {
    static var previews: some View {
        EmailProcessingView()
            .previewDisplayName("Email Processing")
    }
}
#endif