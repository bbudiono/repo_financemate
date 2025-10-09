import SwiftUI

/// Content sections for transaction detail view
/// Displays email metadata, tax details, line items, and raw email content
struct TransactionDetailContentView: View {
    let transaction: ExtractedTransaction
    let onTaxSplit: (GmailLineItem) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
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
                            DetailRow(label: "GST", value: gst.formatted(.currency(code: "AUD")))
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
                            LineItemRowWithSplit(
                                item: transaction.items[index],
                                onTaxSplit: {
                                    onTaxSplit(transaction.items[index])
                                }
                            )
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
    }
}