import SwiftUI

/// BLUEPRINT Lines 67-69: Individual table row with 8-column layout and expandable detail
/// Extracted from GmailReceiptsTableView for KISS compliance (<200 lines per file)
struct GmailTableRow: View {
    let transaction: ExtractedTransaction
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
                    .frame(width: 90, alignment: .trailing)

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

            // Expandable detail panel - Shows ALL invoice data
            if expandedID == transaction.id {
                InvoiceDetailPanel(transaction: transaction)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    // MARK: - Helper Methods

    private func deleteEmail() {
        viewModel.extractedTransactions.removeAll(where: { $0.id == transaction.id })
        viewModel.selectedIDs.remove(transaction.id)
    }
}
