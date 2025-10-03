import SwiftUI

/// Detailed modal view for extracted Gmail transactions
/// Shows all email metadata, line items, and actions
struct TransactionDetailView: View {
    let transaction: ExtractedTransaction
    let onCreateTransaction: () -> Void
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header with merchant and amount
                    VStack(alignment: .leading, spacing: 8) {
                        Text(transaction.merchant)
                            .font(.title)
                            .fontWeight(.bold)

                        Text(transaction.amount, format: .currency(code: "AUD"))
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.accentColor)

                        HStack(spacing: 12) {
                            Label(
                                transaction.date.formatted(date: .long, time: .shortened),
                                systemImage: "calendar"
                            )
                            .font(.caption)

                            Circle()
                                .fill(Color.secondary)
                                .frame(width: 4, height: 4)

                            Label(transaction.category, systemImage: "tag")
                                .font(.caption)

                            Circle()
                                .fill(Color.secondary)
                                .frame(width: 4, height: 4)

                            HStack(spacing: 4) {
                                Circle()
                                    .fill(confidenceColor)
                                    .frame(width: 8, height: 8)
                                Text("\(Int(transaction.confidence * 100))% confidence")
                                    .font(.caption)
                                    .foregroundColor(confidenceColor)
                            }
                        }
                    }
                    .padding()
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(12)

                    // Email metadata section
                    GroupBox("Email Details") {
                        VStack(alignment: .leading, spacing: 12) {
                            DetailRow(label: "Subject", value: transaction.emailSubject)
                            DetailRow(label: "From", value: transaction.emailSender)

                            if let paymentMethod = transaction.paymentMethod {
                                DetailRow(label: "Payment Method", value: paymentMethod)
                            }
                        }
                        .padding(.vertical, 4)
                    }

                    // Australian tax details (if available)
                    if transaction.gstAmount != nil || transaction.abn != nil || transaction.invoiceNumber != nil {
                        GroupBox("Australian Tax Details") {
                            VStack(alignment: .leading, spacing: 12) {
                                if let gst = transaction.gstAmount {
                                    DetailRow(
                                        label: "GST",
                                        value: gst.formatted(.currency(code: "AUD"))
                                    )
                                }

                                if let abn = transaction.abn {
                                    DetailRow(label: "ABN", value: abn)
                                }

                                if let invoice = transaction.invoiceNumber {
                                    DetailRow(label: "Invoice Number", value: invoice)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }

                    // Line items section
                    if !transaction.items.isEmpty {
                        GroupBox("Line Items (\(transaction.items.count))") {
                            VStack(alignment: .leading, spacing: 12) {
                                ForEach(transaction.items.indices, id: \.self) { index in
                                    LineItemRow(item: transaction.items[index])

                                    if index < transaction.items.count - 1 {
                                        Divider()
                                    }
                                }

                                // Total row
                                Divider()
                                HStack {
                                    Text("Total")
                                        .font(.headline)
                                    Spacer()
                                    Text(transaction.amount, format: .currency(code: "AUD"))
                                        .font(.headline)
                                        .fontWeight(.bold)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }

                    // Raw email snippet (for debugging)
                    DisclosureGroup("Raw Email Content") {
                        Text(transaction.rawText)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .textSelection(.enabled)
                            .padding(.top, 8)
                    }
                }
                .padding()
            }
            .navigationTitle("Transaction Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    Button("Create Transaction") {
                        onCreateTransaction()
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .frame(minWidth: 600, minHeight: 500)
    }

    // MARK: - Helper Views

    private var confidenceColor: Color {
        if transaction.confidence >= 0.8 { return .green }
        if transaction.confidence >= 0.6 { return .orange }
        return .red
    }
}

// MARK: - Supporting Components

struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
            Text(value)
                .font(.body)
                .textSelection(.enabled)
        }
    }
}

struct LineItemRow: View {
    let item: GmailLineItem

    var body: some View {
        HStack(alignment: .top) {
            Text("\(item.quantity)×")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 30, alignment: .leading)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.description)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            Text(item.price, format: .currency(code: "AUD"))
                .font(.body)
                .fontWeight(.semibold)
        }
    }
}
