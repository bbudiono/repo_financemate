import SwiftUI

/// BLUEPRINT Lines 67-69: Gmail Receipts Review Table with Expandable Details
/// Master-detail pattern: 8-column summary + expandable invoice data panel
struct GmailReceiptsTableView: View {
    @ObservedObject var viewModel: GmailViewModel
    @State private var expandedID: String?

    var body: some View {
        VStack(spacing: 12) {
            // Header with batch actions
            HStack {
                Text("\(viewModel.extractedTransactions.count) emails to review")
                    .font(.headline)
                Spacer()
                if !viewModel.selectedIDs.isEmpty {
                    Text("\(viewModel.selectedIDs.count) selected")
                        .foregroundColor(.secondary)
                    Button("Import Selected") {
                        importSelected()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding(.horizontal)

            // Spreadsheet-like list with expandable rows
            List {
                ForEach(viewModel.extractedTransactions) { transaction in
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
                                Button(action: { deleteEmail(transaction) }) {
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
            }
            .listStyle(.plain)
        }
    }

    // MARK: - Helper Methods

    private func extractDomain(from email: String) -> String {
        guard let atIndex = email.firstIndex(of: "@") else { return email }
        let domain = String(email[email.index(after: atIndex)...])
        let parts = domain.components(separatedBy: ".")
        let skipPrefixes = ["info", "mail", "noreply", "hello", "no-reply", "support"]
        for part in parts where !skipPrefixes.contains(part.lowercased()) && part.lowercased() != "com" && part.lowercased() != "au" {
            return part.capitalized
        }
        return parts.first?.capitalized ?? email
    }

    private func deleteEmail(_ transaction: ExtractedTransaction) {
        viewModel.extractedTransactions.removeAll(where: { $0.id == transaction.id })
        viewModel.selectedIDs.remove(transaction.id)
    }

    private func importSelected() {
        for id in viewModel.selectedIDs {
            if let transaction = viewModel.extractedTransactions.first(where: { $0.id == id }) {
                viewModel.createTransaction(from: transaction)
            }
        }
        viewModel.selectedIDs.removeAll()
    }

    private func confidenceColor(_ confidence: Double) -> Color {
        if confidence >= 0.8 { return .green }
        else if confidence >= 0.5 { return .yellow }
        else { return .red }
    }
}

/// Expandable detail panel showing ALL invoice metadata
struct InvoiceDetailPanel: View {
    let transaction: ExtractedTransaction

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Invoice Details")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)

            HStack(spacing: 24) {
                // Australian tax data
                VStack(alignment: .leading, spacing: 6) {
                    if let gst = transaction.gstAmount {
                        InvoiceDetailRow(label: "GST", value: gst.formatted(.currency(code: "AUD")), color: .orange)
                    }
                    if let abn = transaction.abn {
                        InvoiceDetailRow(label: "ABN", value: abn, color: .blue)
                    }
                }

                // Invoice tracking
                VStack(alignment: .leading, spacing: 6) {
                    if let invoice = transaction.invoiceNumber {
                        InvoiceDetailRow(label: "Invoice#", value: invoice, color: .purple)
                    }
                    if let payment = transaction.paymentMethod {
                        InvoiceDetailRow(label: "Payment", value: payment, color: .green)
                    }
                }
            }

            // Full item breakdown
            if !transaction.items.isEmpty {
                Divider()
                Text("Purchase Details")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)

                ForEach(transaction.items, id: \.description) { item in
                    HStack {
                        Text("\(item.quantity)×")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .frame(width: 30, alignment: .leading)
                        Text(item.description)
                            .font(.caption2)
                        Spacer()
                        Text(item.price, format: .currency(code: "AUD"))
                            .font(.caption2.monospaced())
                            .fontWeight(.medium)
                    }
                }
            }
        }
        .padding(12)
        .background(Color.secondary.opacity(0.08))
        .cornerRadius(8)
        .padding(.leading, 50)
        .padding(.trailing, 12)
        .padding(.bottom, 8)
    }
}

struct InvoiceDetailRow: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 6) {
            Text(label + ":")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text(value)
                .font(.caption2.monospaced())
                .foregroundColor(color)
        }
    }
}
