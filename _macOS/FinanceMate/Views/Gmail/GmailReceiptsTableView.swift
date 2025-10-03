import SwiftUI

/// BLUEPRINT Line 67: Interactive, detailed, comprehensive table for Gmail receipts
/// Features: Sortable columns, filterable, searchable, best practice UI
struct GmailReceiptsTableView: View {
    @ObservedObject var viewModel: GmailViewModel
    @State private var sortOrder = [KeyPathComparator(\ExtractedTransaction.date, order: .reverse)]
    @State private var selection = Set<ExtractedTransaction.ID>()
    @State private var selectedTransaction: ExtractedTransaction?

    var body: some View {
        VStack(spacing: 0) {
            // Header with actions
            HStack {
                Text("\(viewModel.filteredAndSortedTransactions.count) transactions")
                    .font(.headline)
                    .foregroundColor(.secondary)

                Spacer()

                if !selection.isEmpty {
                    Text("\(selection.count) selected")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Button("Create Selected") {
                        createSelectedTransactions()
                    }
                    .buttonStyle(.bordered)
                }

                Button("Create All") {
                    viewModel.createAllTransactions()
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.extractedTransactions.isEmpty)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            // Professional table with sortable columns
            Table(viewModel.filteredAndSortedTransactions,
                  selection: $selection,
                  sortOrder: $sortOrder) {

                // Date column - sortable
                TableColumn("Date", value: \.date) { transaction in
                    Text(transaction.date, format: .dateTime.month().day().year())
                        .font(.caption)
                }
                .width(min: 80, ideal: 100, max: 120)

                // Merchant column - sortable
                TableColumn("Merchant", value: \.merchant) { transaction in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(transaction.merchant)
                            .font(.caption)
                            .fontWeight(.medium)
                        Text(transaction.emailSender)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                .width(min: 120, ideal: 180, max: 250)

                // Amount column - sortable, AUD formatted
                TableColumn("Amount", value: \.amount) { transaction in
                    Text(transaction.amount, format: .currency(code: "AUD"))
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                .width(min: 80, ideal: 100, max: 120)

                // Line Items count - visual indicator
                TableColumn("Items") { transaction in
                    HStack(spacing: 4) {
                        Image(systemName: "list.bullet")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("\(transaction.items.count)")
                            .font(.caption)
                    }
                }
                .width(min: 50, ideal: 60, max: 80)

                // Category - sortable
                TableColumn("Category", value: \.category) { transaction in
                    Text(transaction.category)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(categoryColor(transaction.category).opacity(0.2))
                        .cornerRadius(4)
                }
                .width(min: 80, ideal: 100, max: 120)

                // Confidence indicator - sortable
                TableColumn("Confidence", value: \.confidence) { transaction in
                    HStack(spacing: 4) {
                        Circle()
                            .fill(confidenceColor(transaction.confidence))
                            .frame(width: 8, height: 8)
                        Text("\(Int(transaction.confidence * 100))%")
                            .font(.caption2)
                            .foregroundColor(confidenceColor(transaction.confidence))
                    }
                }
                .width(min: 70, ideal: 85, max: 100)

                // Actions column
                TableColumn("Actions") { transaction in
                    Button("Create") {
                        viewModel.createTransaction(from: transaction)
                    }
                    .buttonStyle(.borderless)
                    .controlSize(.small)
                }
                .width(min: 60, ideal: 70, max: 80)
            }
            .onChange(of: sortOrder) { _ in
                viewModel.applySortOrder(sortOrder)
            }
            .contextMenu(forSelectionType: ExtractedTransaction.ID.self) { items in
                Button("Create Transactions") {
                    createTransactions(items)
                }
                Button("View Details") {
                    if let id = items.first,
                       let transaction = viewModel.extractedTransactions.first(where: { $0.id == id }) {
                        selectedTransaction = transaction
                    }
                }
                Divider()
                Button("Select All") {
                    selection = Set(viewModel.filteredAndSortedTransactions.map(\.id))
                }
                Button("Deselect All") {
                    selection.removeAll()
                }
            }
        }
        .sheet(item: $selectedTransaction) { transaction in
            TransactionDetailView(transaction: transaction) {
                viewModel.createTransaction(from: transaction)
            }
        }
    }

    // MARK: - Helper Methods

    private func createSelectedTransactions() {
        for id in selection {
            if let transaction = viewModel.extractedTransactions.first(where: { $0.id == id }) {
                viewModel.createTransaction(from: transaction)
            }
        }
        selection.removeAll()
    }

    private func createTransactions(_ ids: Set<ExtractedTransaction.ID>) {
        for id in ids {
            if let transaction = viewModel.extractedTransactions.first(where: { $0.id == id }) {
                viewModel.createTransaction(from: transaction)
            }
        }
    }

    private func confidenceColor(_ confidence: Double) -> Color {
        if confidence >= 0.8 { return .green }
        if confidence >= 0.6 { return .orange }
        return .red
    }

    private func categoryColor(_ category: String) -> Color {
        switch category.lowercased() {
        case "cashback": return .green
        case "expense": return .blue
        case "income": return .purple
        case "refund": return .orange
        default: return .gray
        }
    }
}
