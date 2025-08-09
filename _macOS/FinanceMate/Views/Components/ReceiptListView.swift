import SwiftUI

/**
 * ReceiptListView.swift
 * 
 * Purpose: PHASE 3.3 - Modular receipt list orchestration (now using ReceiptDetailSheet)
 * Issues & Complexity Summary: Receipt list orchestration using ReceiptDetailSheet component
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~140 (orchestration only, detail sheet handles content display)
 *   - Core Algorithm Complexity: Medium (list filtering, sorting, selection management)
 *   - Dependencies: 4 (SwiftUI, receipt data models, selection binding, ReceiptDetailSheet)
 *   - State Management Complexity: Medium (selection state, detail navigation, filtering)
 *   - Novelty/Uncertainty Factor: Low (modular orchestration patterns)
 * AI Pre-Task Self-Assessment: 95% (simplified through component extraction)
 * Problem Estimate: 85% (reduced complexity through modular architecture)
 * Initial Code Complexity Estimate: 80% (orchestration benefits)
 * Target Coverage: List interaction testing with component integration
 * Australian Compliance: Transaction display formatting, currency handling
 * Last Updated: 2025-08-08
 */

/// Modular receipt list orchestration view component
/// Uses ReceiptDetailSheet component to maintain <200 line rule
struct ReceiptListView: View {
    
    // MARK: - Properties
    
    let receipts: [ProcessedReceipt]
    @Binding var selectedTransactions: Set<UUID>
    let filterOption: ProcessingStatisticsView.FilterOption
    let sortOption: ProcessingStatisticsView.SortOption
    let onTransactionSelection: (ProcessedReceipt) -> Void
    let onReceiptDetail: (ProcessedReceipt) -> Void
    
    @State private var showingDetails = false
    @State private var selectedReceipt: ProcessedReceipt?
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            let filteredReceipts = filterReceipts(receipts)
            let sortedReceipts = sortReceipts(filteredReceipts)
            
            if sortedReceipts.isEmpty {
                emptyResultsView
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(sortedReceipts, id: \.id) { receipt in
                        receiptResultRow(receipt)
                    }
                }
            }
        }
        .sheet(isPresented: $showingDetails) {
            if let receipt = selectedReceipt {
                ReceiptDetailSheet(
                    receipt: receipt,
                    isPresented: $showingDetails
                )
            }
        }
    }
    
    // MARK: - Receipt Row
    
    private func receiptResultRow(_ receipt: ProcessedReceipt) -> some View {
        HStack(spacing: 12) {
            // Selection checkbox
            Button(action: {
                toggleSelection(for: receipt)
            }) {
                Image(systemName: selectedTransactions.contains(receipt.id) ? "checkmark.square.fill" : "square")
                    .font(.title3)
                    .foregroundColor(selectedTransactions.contains(receipt.id) ? .blue : .secondary)
            }
            .buttonStyle(.plain)
            
            // Status indicator
            statusIndicator(for: receipt.processingStatus)
            
            // Receipt content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(receipt.vendor ?? "Unknown Vendor")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text(formatCurrency(receipt.extractedAmount))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(receipt.processingStatus == .success ? .primary : .secondary)
                }
                
                HStack {
                    if let date = receipt.extractedDate {
                        Text(formatDate(date))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if let category = receipt.suggestedCategory {
                        Text(category)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(4)
                            .foregroundColor(.blue)
                    }
                }
            }
            
            // Action button
            Button(action: {
                selectedReceipt = receipt
                showingDetails = true
            }) {
                Image(systemName: "info.circle")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(selectedTransactions.contains(receipt.id) ? Color.blue.opacity(0.1) : Color.clear)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(selectedTransactions.contains(receipt.id) ? Color.blue : Color.clear, lineWidth: 1)
        )
        .onTapGesture {
            onTransactionSelection(receipt)
        }
    }
    
    // MARK: - Status Indicator
    
    private func statusIndicator(for status: ProcessingStatus) -> some View {
        Circle()
            .fill(statusColor(for: status))
            .frame(width: 12, height: 12)
            .overlay(
                Circle()
                    .stroke(statusColor(for: status).opacity(0.3), lineWidth: 2)
                    .frame(width: 16, height: 16)
            )
    }
    
    private func statusColor(for status: ProcessingStatus) -> Color {
        switch status {
        case .success: return .green
        case .needsReview: return .orange
        case .failed: return .red
        }
    }
    
    // MARK: - Empty Results View
    
    private var emptyResultsView: some View {
        VStack(spacing: 12) {
            Image(systemName: "line.3.horizontal.decrease")
                .font(.title)
                .foregroundColor(.secondary)
            
            Text("No results match your filter")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("Try adjusting your filter settings")
                .font(.caption)
                .foregroundColor(.secondary)
                .opacity(0.8)
        }
        .frame(maxWidth: .infinity, minHeight: 100)
    }
    
    // MARK: - Helper Methods
    
    private func filterReceipts(_ receipts: [ProcessedReceipt]) -> [ProcessedReceipt] {
        switch filterOption {
        case .all:
            return receipts
        case .successful:
            return receipts.filter { $0.processingStatus == .success }
        case .needsReview:
            return receipts.filter { $0.processingStatus == .needsReview }
        case .errors:
            return receipts.filter { $0.processingStatus == .failed }
        }
    }
    
    private func sortReceipts(_ receipts: [ProcessedReceipt]) -> [ProcessedReceipt] {
        switch sortOption {
        case .dateDescending:
            return receipts.sorted { ($0.extractedDate ?? Date.distantPast) > ($1.extractedDate ?? Date.distantPast) }
        case .dateAscending:
            return receipts.sorted { ($0.extractedDate ?? Date.distantPast) < ($1.extractedDate ?? Date.distantPast) }
        case .amountDescending:
            return receipts.sorted { $0.extractedAmount > $1.extractedAmount }
        case .amountAscending:
            return receipts.sorted { $0.extractedAmount < $1.extractedAmount }
        case .vendor:
            return receipts.sorted { ($0.vendor ?? "").localizedCaseInsensitiveCompare($1.vendor ?? "") == .orderedAscending }
        }
    }
    
    private func toggleSelection(for receipt: ProcessedReceipt) {
        if selectedTransactions.contains(receipt.id) {
            selectedTransactions.remove(receipt.id)
        } else {
            selectedTransactions.insert(receipt.id)
        }
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "AUD"
        formatter.locale = Locale(identifier: "en_AU")
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
}

// MARK: - Preview

#Preview {
    ReceiptListView(
        receipts: [],
        selectedTransactions: .constant(Set<UUID>()),
        filterOption: .all,
        sortOption: .dateDescending,
        onTransactionSelection: { _ in },
        onReceiptDetail: { _ in }
    )
}