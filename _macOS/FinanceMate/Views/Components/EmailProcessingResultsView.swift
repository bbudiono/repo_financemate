import SwiftUI

/**
 * EmailProcessingResultsView.swift
 * 
 * Purpose: PHASE 3.3 - Modular email processing results orchestration (now using sub-components)
 * Issues & Complexity Summary: Results orchestration using ProcessingStatisticsView and ReceiptListView
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~120 (orchestration only, components handle complexity)
 *   - Core Algorithm Complexity: Low (component coordination and bulk action handling)
 *   - Dependencies: 5 (SwiftUI, 2 sub-components, transaction management, bulk actions)
 *   - State Management Complexity: Low (reduced through component extraction)
 *   - Novelty/Uncertainty Factor: Low (modular orchestration patterns)
 * AI Pre-Task Self-Assessment: 96% (simplified through component breakdown)
 * Problem Estimate: 84% (reduced complexity through modular architecture)
 * Initial Code Complexity Estimate: 75% (orchestration benefits)
 * Target Coverage: Component integration testing with bulk action validation
 * Australian Compliance: Transaction handling, bulk operations, financial reporting
 * Last Updated: 2025-08-08
 */

/// Modular email processing results orchestration view
/// Uses ProcessingStatisticsView and ReceiptListView components to maintain <200 line rule
struct EmailProcessingResultsView: View {
    
    // MARK: - Properties
    
    let processingResult: EmailReceiptResult?
    @Binding var selectedTransactions: Set<UUID>
    @Binding var showingExportOptions: Bool
    
    let onTransactionSelection: (ProcessedReceipt) -> Void
    let onBulkAction: (BulkAction) -> Void
    
    @State private var filterOption: ProcessingStatisticsView.FilterOption = .all
    @State private var sortOption: ProcessingStatisticsView.SortOption = .dateDescending
    
    // MARK: - Supporting Types
    
    enum BulkAction {
        case createTransactions
        case exportSelected
        case reviewAll
        case deleteSelected
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 20) {
            if let result = processingResult {
                // Statistics component (modular)
                ProcessingStatisticsView(
                    result: result,
                    filterOption: $filterOption,
                    sortOption: $sortOption,
                    onExport: {
                        showingExportOptions = true
                    }
                )
                
                // Receipt list component (modular)
                ReceiptListView(
                    receipts: result.processedReceipts,
                    selectedTransactions: $selectedTransactions,
                    filterOption: filterOption,
                    sortOption: sortOption,
                    onTransactionSelection: onTransactionSelection,
                    onReceiptDetail: { receipt in
                        // Handle receipt detail navigation
                    }
                )
                
                // Bulk actions section (simplified)
                bulkActionsSection
            } else {
                resultsPlaceholder
            }
        }
        .modifier(GlassmorphismModifier(.minimal))
    }
    
    // MARK: - Bulk Actions Section
    
    private var bulkActionsSection: some View {
        VStack(spacing: 12) {
            if !selectedTransactions.isEmpty {
                HStack {
                    Text("\(selectedTransactions.count) selected")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                
                HStack(spacing: 12) {
                    Button("Create Transactions") {
                        onBulkAction(.createTransactions)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                    
                    Button("Export Selected") {
                        onBulkAction(.exportSelected)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    
                    Spacer()
                    
                    Button("Clear Selection") {
                        selectedTransactions.removeAll()
                    }
                    .buttonStyle(.borderless)
                    .controlSize(.small)
                    .foregroundColor(.secondary)
                }
            } else {
                HStack {
                    Button("Select All") {
                        if let result = processingResult {
                            selectedTransactions = Set(result.processedReceipts.map { $0.id })
                        }
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    
                    Spacer()
                    
                    Button("Review All") {
                        onBulkAction(.reviewAll)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }
        }
    }
    
    // MARK: - Placeholder View
    
    private var resultsPlaceholder: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("No Results")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text("Process some emails to see results here")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
    }
}

// MARK: - Preview

#Preview {
    EmailProcessingResultsView(
        processingResult: nil,
        selectedTransactions: .constant(Set<UUID>()),
        showingExportOptions: .constant(false),
        onTransactionSelection: { _ in },
        onBulkAction: { _ in }
    )
}