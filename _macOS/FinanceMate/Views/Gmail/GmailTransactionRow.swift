import SwiftUI

// MARK: - Extracted Transaction Row

struct ExtractedTransactionRow: View {
    let extracted: ExtractedTransaction
    let onApprove: () -> Void

    var confidenceColor: Color {
        if extracted.confidence >= 0.8 { return .green }
        if extracted.confidence >= 0.6 { return .orange }
        return .red
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header: Merchant and Amount
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(extracted.merchant)
                        .font(.headline)
                    Text(extracted.category)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(String(format: "$%.2f", extracted.amount))
                        .font(.title3)
                        .fontWeight(.bold)
                    HStack(spacing: 4) {
                        Circle()
                            .fill(confidenceColor)
                            .frame(width: 8, height: 8)
                        Text("\(Int(extracted.confidence * 100))%")
                            .font(.caption)
                            .foregroundColor(confidenceColor)
                    }
                }
            }

            // Email metadata
            VStack(alignment: .leading, spacing: 4) {
                Text(extracted.emailSubject)
                    .font(.caption)
                    .foregroundColor(.primary)
                Text("From: \(extracted.emailSender)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            // Australian tax details
            if extracted.gstAmount != nil || extracted.abn != nil || extracted.invoiceNumber != nil {
                HStack(spacing: 12) {
                    if let gst = extracted.gstAmount {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("GST")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text("$\(String(format: "%.2f", gst))")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                    }

                    if let abn = extracted.abn {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("ABN")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text(abn)
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                    }

                    if !extracted.invoiceNumber.isEmpty {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Invoice")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text(extracted.invoiceNumber)
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                    }
                }
                .padding(.vertical, 4)
            }

            // Line items with prominent purchase amounts
            if !extracted.items.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("\(extracted.items.count) line items:")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)

                    ForEach(extracted.items.indices, id: \.self) { index in
                        HStack(alignment: .top, spacing: 8) {
                            Text("\(extracted.items[index].quantity)x")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .frame(width: 20, alignment: .leading)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(extracted.items[index].description)
                                    .font(.caption2)
                                    .foregroundColor(.primary)
                            }

                            Spacer()

                            Text("$\(String(format: "%.2f", extracted.items[index].price))")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                        }
                    }
                }
                .padding(.vertical, 6)
            }

            Button("Create Transaction") {
                NSLog("=== CREATE TRANSACTION BUTTON CLICKED ===")
                onApprove()
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
    }
}
