import SwiftUI

/// BLUEPRINT Lines 67-69: Individual table row with comprehensive column layout and expandable detail
/// Extracted from GmailReceiptsTableView for KISS compliance (<200 lines per file)
struct GmailTableRow: View {
    @ObservedObject var transaction: ExtractedTransaction
    @ObservedObject var viewModel: GmailViewModel
    @Binding var expandedID: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Main row - 8 columns (compiler-safe)
            HStack(spacing: 8) {
                // Checkbox
                Toggle("", isOn: Binding(
                    get: { viewModel.selectedIDs.contains(transaction.id) },
                    set: { if $0 { viewModel.selectedIDs.insert(transaction.id) } else { viewModel.selectedIDs.remove(transaction.id) } }
                ))
                .toggleStyle(.checkbox)
                .labelsHidden()
                .frame(width: 30)

                // Expansion indicator
                Image(systemName: expandedID == transaction.id ? "chevron.down" : "chevron.right")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .frame(width: 20)

                // Date
                Text(transaction.date, format: .dateTime.month().day())
                    .font(.caption.monospaced())
                    .frame(width: 70, alignment: .leading)

                // Merchant (AI-extracted) - BLUEPRINT Line 73: Show all extracted data
                TextField("Merchant", text: $transaction.merchant)
                    .textFieldStyle(.plain)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .frame(width: 140, alignment: .leading)
                    .help("AI-extracted merchant name (editable)")

                // Category (Inferred) - BLUEPRINT Line 74: Category badge
                Text(transaction.category)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(categoryColor(transaction.category))
                    .foregroundColor(.white)
                    .cornerRadius(4)
                    .frame(width: 90, alignment: .center)
                    .help("AI-inferred category")

                // From (Domain)
                VStack(alignment: .leading, spacing: 2) {
                    Text(extractDomain(from: transaction.emailSender))
                        .font(.caption)
                        .fontWeight(.semibold)
                    Text(transaction.emailSender)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                .frame(width: 160, alignment: .leading)

                // Subject (flexible width - takes remaining space)
                Text(transaction.emailSubject)
                    .font(.caption)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // Amount
                Text(transaction.amount, format: .currency(code: "AUD"))
                    .font(.caption.monospaced())
                    .fontWeight(.bold)
                    .foregroundColor(.red)
                    .frame(width: 90, alignment: .trailing)

                // GST - BLUEPRINT Line 76: Australian tax compliance
                if let gst = transaction.gstAmount {
                    Text(gst, format: .currency(code: "AUD"))
                        .font(.caption2.monospaced())
                        .foregroundColor(.orange)
                        .frame(width: 70, alignment: .trailing)
                } else {
                    Text("-")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .frame(width: 70, alignment: .center)
                }

                // Invoice# - BLUEPRINT Line 79: Business expense tracking
                if let invoice = transaction.invoiceNumber, !invoice.isEmpty {
                    Text(invoice)
                        .font(.caption2.monospaced())
                        .foregroundColor(.purple)
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .frame(width: 90, alignment: .leading)
                } else {
                    Text("-")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .frame(width: 90, alignment: .center)
                }

                // Payment Method - BLUEPRINT Line 80
                if let payment = transaction.paymentMethod, !payment.isEmpty {
                    Text(payment)
                        .font(.caption2)
                        .foregroundColor(.green)
                        .lineLimit(1)
                        .frame(width: 70, alignment: .leading)
                } else {
                    Text("-")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .frame(width: 70, alignment: .center)
                }

                // Items count
                Text("\(transaction.items.count)")
                    .font(.caption.monospaced())
                    .foregroundColor(.secondary)
                    .frame(width: 40, alignment: .center)

                // Confidence
                HStack(spacing: 4) {
                    Circle()
                        .fill(confidenceColor(transaction.confidence))
                        .frame(width: 6, height: 6)
                    Text("\(Int(transaction.confidence * 100))%")
                        .font(.caption2)
                }
                .frame(width: 50, alignment: .center)

                // Actions
                HStack(spacing: 6) {
                    Button(action: { deleteEmail() }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                    .buttonStyle(.borderless)
                    .help("Delete")

                    Button("Import") {
                        viewModel.createTransaction(from: transaction)
                        viewModel.selectedIDs.remove(transaction.id)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                }
                .frame(width: 110)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.2)) {
                    expandedID = expandedID == transaction.id ? nil : transaction.id
                }
            }
            .contextMenu {
                Button("Import to Transactions") {
                    viewModel.createTransaction(from: transaction)
                    viewModel.selectedIDs.remove(transaction.id)
                }
                Button("Delete Email") {
                    deleteEmail()
                }

                if !viewModel.selectedIDs.isEmpty {
                    Divider()
                    Button("Import Selected (\(viewModel.selectedIDs.count))") {
                        importSelected()
                    }
                    Button("Delete Selected") {
                        deleteSelected()
                    }
                }
            }

            // Expandable detail panel - Shows ALL invoice data
            if expandedID == transaction.id {
                InvoiceDetailPanel(transaction: transaction)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    // MARK: - Helper Methods

    private func categoryColor(_ category: String) -> Color {
        switch category.lowercased() {
        case "groceries": return .blue
        case "transport": return .purple
        case "utilities": return .orange
        case "retail", "hardware": return .green
        case "dining": return .red
        default: return .gray
        }
    }

    private func deleteEmail() {
        viewModel.extractedTransactions.removeAll(where: { $0.id == transaction.id })
        viewModel.selectedIDs.remove(transaction.id)
    }

    private func importSelected() {
        let selectedTransactions = viewModel.extractedTransactions.filter { viewModel.selectedIDs.contains($0.id) }
        selectedTransactions.forEach { viewModel.createTransaction(from: $0) }
        viewModel.selectedIDs.removeAll()
    }

    private func deleteSelected() {
        viewModel.extractedTransactions.removeAll { viewModel.selectedIDs.contains($0.id) }
        viewModel.selectedIDs.removeAll()
    }
}
