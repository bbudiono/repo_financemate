import SwiftUI

/// BLUEPRINT Lines 67-84: Native SwiftUI Table for Excel-like spreadsheet functionality
/// Uses macOS 12+ Table API with built-in sorting, scrolling, column resizing
struct GmailReceiptsTableView: View {
    @ObservedObject var viewModel: GmailViewModel
    @State private var sortOrder = [KeyPathComparator(\ExtractedTransaction.date, order: .reverse)]
    @State private var selectedTransaction: ExtractedTransaction?
    @State private var expandedRowId: String? // BLUEPRINT Column 2: Track expanded row

    /// BLUEPRINT: Apply sorting to paginated transactions based on column header clicks
    private var sortedTransactions: [ExtractedTransaction] {
        viewModel.paginatedTransactions.sorted(using: sortOrder)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header with batch actions
            headerView

            // BLUEPRINT Line 150: Batch extraction progress (shown during processing)
            BatchExtractionProgressView(viewModel: viewModel)

            // NATIVE TABLE - BLUEPRINT Line 75: "Microsoft Excel spreadsheets"
            tableView

            // BLUEPRINT Column 2: Detail panel shown when row expanded
            if let expandedId = expandedRowId,
               let transaction = sortedTransactions.first(where: { $0.id == expandedId }) {
                Divider()
                InvoiceDetailPanel(transaction: transaction)
                    .frame(height: 300)
            }

            // Pagination
            if viewModel.hasMorePages {
                paginationButton
            }
        }
    }

    // MARK: - View Components

    private var headerView: some View {
        HStack {
            Text("\(viewModel.unprocessedEmails.count) emails to review")
                .font(.headline)
            Spacer()

            // Force re-extraction button
            Button("Re-Extract All") {
                Task {
                    EmailCacheManager.clear()
                    await viewModel.fetchEmails()
                }
            }
            .buttonStyle(.bordered)
            .help("Clear cache and re-extract with latest logic")

            if !viewModel.selectedIDs.isEmpty {
                Text("\(viewModel.selectedIDs.count) selected")
                    .foregroundColor(.secondary)
                Button("Import Selected") {
                    importSelected()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }

    private var tableView: some View {
        Table(sortedTransactions, selection: $viewModel.selectedIDs, sortOrder: $sortOrder) {
            // BLUEPRINT Column 1: Selection checkbox (MANDATORY)
            checkboxColumn

            // BLUEPRINT Column 2: Expand/collapse indicator (MANDATORY)
            expandCollapseColumn

            coreColumns
            metadataColumns
            statusColumns

            // BLUEPRINT Column 14: Action buttons (MANDATORY)
            actionButtonsColumn
        }
        .tableStyle(.inset)
        .contextMenu(forSelectionType: ExtractedTransaction.ID.self) { ids in
            GmailTableHelpers.contextMenu(for: ids, viewModel: viewModel, onImport: importSelected)
        }
        .onChange(of: viewModel.selectedIDs) { newSelection in
            selectedTransaction = newSelection.first.flatMap { id in
                viewModel.extractedTransactions.first { $0.id == id }
            }
        }
    }

    // MARK: - BLUEPRINT Column 1: Selection Checkbox

    @TableColumnBuilder<ExtractedTransaction, KeyPathComparator<ExtractedTransaction>>
    private var checkboxColumn: some TableColumnContent<ExtractedTransaction, KeyPathComparator<ExtractedTransaction>> {
        TableColumn("☑", value: \.id) { tx in
            Button(action: {
                toggleSelection(for: tx.id)
            }) {
                Image(systemName: viewModel.selectedIDs.contains(tx.id) ? "checkmark.square.fill" : "square")
                    .foregroundColor(viewModel.selectedIDs.contains(tx.id) ? .blue : .secondary)
            }
            .buttonStyle(.plain)
        }
        .width(30)
    }

    // MARK: - BLUEPRINT Column 2: Expand/Collapse Indicator

    @TableColumnBuilder<ExtractedTransaction, KeyPathComparator<ExtractedTransaction>>
    private var expandCollapseColumn: some TableColumnContent<ExtractedTransaction, KeyPathComparator<ExtractedTransaction>> {
        TableColumn("▼", value: \.id) { tx in
            Button(action: {
                toggleExpanded(for: tx.id)
            }) {
                Image(systemName: expandedRowId == tx.id ? "chevron.down.circle.fill" : "chevron.right.circle")
                    .foregroundColor(expandedRowId == tx.id ? .blue : .secondary)
            }
            .buttonStyle(.plain)
        }
        .width(30)
    }

    @TableColumnBuilder<ExtractedTransaction, KeyPathComparator<ExtractedTransaction>>
    private var coreColumns: some TableColumnContent<ExtractedTransaction, KeyPathComparator<ExtractedTransaction>> {
        TableColumn("Date", value: \.date) { tx in
            Text(tx.date, format: .dateTime.month().day())
                .font(.caption.monospaced())
        }
        .width(min: 70, ideal: 80, max: 100)

        TableColumn("Merchant", value: \.merchant) { tx in
            Text(tx.merchant)
                .font(.caption)
                .fontWeight(.semibold)
        }
        .width(min: 120, ideal: 140, max: 200)

        TableColumn("Category", value: \.category) { tx in
            Text(tx.category)
                .font(.caption2)
                .fontWeight(.medium)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(GmailTableHelpers.categoryColor(tx.category))
                .foregroundColor(.white)
                .cornerRadius(4)
        }
        .width(90)

        TableColumn("Amount", value: \.amount) { tx in
            Text(tx.amount, format: .currency(code: "AUD"))
                .font(.caption.monospaced())
                .fontWeight(.bold)
                .foregroundColor(.red)
        }
        .width(90)
    }

    @TableColumnBuilder<ExtractedTransaction, KeyPathComparator<ExtractedTransaction>>
    private var metadataColumns: some TableColumnContent<ExtractedTransaction, KeyPathComparator<ExtractedTransaction>> {
        TableColumn("GST") { tx in
            if let gst = tx.gstAmount {
                Text(gst, format: .currency(code: "AUD"))
                    .font(.caption2.monospaced())
                    .foregroundColor(.orange)
            } else {
                Text("-").font(.caption2).foregroundColor(.secondary)
            }
        }
        .width(70)

        TableColumn("From") { tx in
            Text(GmailTableHelpers.extractDomain(from: tx.emailSender))
                .font(.caption)
        }
        .width(min: 100, ideal: 120)

        TableColumn("Subject") { tx in
            Text(tx.emailSubject)
                .font(.caption)
                .lineLimit(1)
        }
        .width(min: 150, ideal: 200, max: 400)

        TableColumn("Invoice#") { tx in
            Text(tx.invoiceNumber)
                .font(.caption2.monospaced())
                .foregroundColor(.purple)
                .lineLimit(1)
        }
        .width(min: 90, ideal: 120, max: 180)
    }

    @TableColumnBuilder<ExtractedTransaction, KeyPathComparator<ExtractedTransaction>>
    private var statusColumns: some TableColumnContent<ExtractedTransaction, KeyPathComparator<ExtractedTransaction>> {
        TableColumn("Payment") { tx in
            if let payment = tx.paymentMethod {
                Text(payment).font(.caption2).foregroundColor(.green)
            } else {
                Text("-").font(.caption2).foregroundColor(.secondary)
            }
        }
        .width(80)

        TableColumn("Items") { tx in
            Text("\(tx.items.count)").font(.caption.monospaced())
        }
        .width(50)

        TableColumn("Confidence", value: \.confidence) { tx in
            HStack(spacing: 4) {
                Circle()
                    .fill(GmailTableHelpers.confidenceColor(tx.confidence))
                    .frame(width: 6, height: 6)
                Text("\(Int(tx.confidence * 100))%")
                    .font(.caption2)
            }
        }
        .width(70)
    }

    // MARK: - BLUEPRINT Column 14: Action Buttons

    @TableColumnBuilder<ExtractedTransaction, KeyPathComparator<ExtractedTransaction>>
    private var actionButtonsColumn: some TableColumnContent<ExtractedTransaction, KeyPathComparator<ExtractedTransaction>> {
        TableColumn("Actions", value: \.id) { tx in
            HStack(spacing: 4) {
                // Import button
                Button(action: {
                    importTransaction(tx)
                }) {
                    Image(systemName: "square.and.arrow.down")
                        .foregroundColor(.blue)
                }
                .buttonStyle(.plain)
                .help("Import to Transactions")

                // Delete button
                Button(action: {
                    deleteTransaction(tx)
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
                .help("Delete")
            }
        }
        .width(70)
    }

    private var paginationButton: some View {
        HStack {
            Spacer()
            Button("Load 50 More") {
                viewModel.loadNextPage()
            }
            .buttonStyle(.borderedProminent)
            .padding()
            Spacer()
        }
    }

    // MARK: - Helper Methods

    /// BLUEPRINT Column 1: Toggle checkbox selection
    private func toggleSelection(for id: String) {
        if viewModel.selectedIDs.contains(id) {
            viewModel.selectedIDs.remove(id)
        } else {
            viewModel.selectedIDs.insert(id)
        }
    }

    /// BLUEPRINT Column 2: Toggle row expansion
    private func toggleExpanded(for id: String) {
        if expandedRowId == id {
            expandedRowId = nil  // Collapse if already expanded
        } else {
            expandedRowId = id  // Expand (only one row at a time)
        }
    }

    /// BLUEPRINT Column 14: Import single transaction
    private func importTransaction(_ transaction: ExtractedTransaction) {
        viewModel.createTransaction(from: transaction)
        viewModel.selectedIDs.remove(transaction.id)  // Remove from selection after import
    }

    /// BLUEPRINT Column 14: Delete single transaction
    private func deleteTransaction(_ transaction: ExtractedTransaction) {
        if let index = viewModel.extractedTransactions.firstIndex(where: { $0.id == transaction.id }) {
            viewModel.extractedTransactions.remove(at: index)
        }
        viewModel.selectedIDs.remove(transaction.id)
        if expandedRowId == transaction.id {
            expandedRowId = nil  // Collapse if was expanded
        }
    }

    private func importSelected() {
        for id in viewModel.selectedIDs {
            if let tx = viewModel.extractedTransactions.first(where: { $0.id == id }) {
                viewModel.createTransaction(from: tx)
            }
        }
        viewModel.selectedIDs.removeAll()
    }
}
