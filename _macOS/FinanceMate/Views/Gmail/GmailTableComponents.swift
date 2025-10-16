import SwiftUI

// MARK: - Shared Helper Functions

/// Extracts meaningful domain name from email address
func extractDomain(from email: String) -> String {
    guard let atIndex = email.firstIndex(of: "@") else { return email }
    let domain = String(email[email.index(after: atIndex)...])
    let parts = domain.components(separatedBy: ".")
    let skipPrefixes = ["info", "mail", "noreply", "hello", "no-reply", "support"]
    for part in parts where !skipPrefixes.contains(part.lowercased()) && part.lowercased() != "com" && part.lowercased() != "au" {
        return part.capitalized
    }
    return parts.first?.capitalized ?? email
}

/// Returns color based on confidence score
func confidenceColor(_ confidence: Double) -> Color {
    if confidence >= 0.8 { return .green }
    else if confidence >= 0.5 { return .yellow }
    else { return .red }
}

// MARK: - Invoice Detail Components

/// Expandable detail panel showing ALL invoice metadata + HTML email viewer
/// BLUEPRINT Line 102: "HTML viewer when details expanded to confirm AI extraction"
struct InvoiceDetailPanel: View {
    let transaction: ExtractedTransaction
    @State private var showRawEmail = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header with toggle for raw email view
            HStack {
                Text("Invoice Details")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)

                Spacer()

                // BLUEPRINT Line 102: Toggle to show original email
                Button(action: { showRawEmail.toggle() }) {
                    HStack(spacing: 4) {
                        Image(systemName: showRawEmail ? "envelope.open.fill" : "envelope.fill")
                        Text(showRawEmail ? "Hide Email" : "Show Email")
                    }
                    .font(.caption2)
                    .foregroundColor(.blue)
                }
                .buttonStyle(.plain)
                .help("Toggle original email view to verify AI extraction")
            }

            if showRawEmail {
                // BLUEPRINT Line 102: HTML/Text viewer for original email content
                EmailContentViewer(transaction: transaction)
            } else {
                // Existing structured view
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

                    // Invoice tracking (MANDATORY fields per user requirement)
                    VStack(alignment: .leading, spacing: 6) {
                        InvoiceDetailRow(label: "Invoice#", value: transaction.invoiceNumber, color: .purple)
                        InvoiceDetailRow(label: "Payment", value: transaction.paymentMethod ?? "-", color: .green)
                    }
                }

                // Full item breakdown (MANDATORY per user requirement)
                Divider()
                Text("Purchase Details")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)

                if !transaction.items.isEmpty {
                    ForEach(transaction.items) { item in
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
                } else {
                    // Fallback: Show email snippet if no items extracted
                    Text(transaction.rawText)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(5)
                        .padding(.vertical, 4)
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

/// BLUEPRINT Line 102: Email content viewer for verification
/// Shows original email text to allow user to confirm AI extraction accuracy
struct EmailContentViewer: View {
    let transaction: ExtractedTransaction

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Email metadata header
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("From:")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(transaction.emailSender)
                        .font(.caption2.monospaced())
                        .foregroundColor(.primary)
                }

                HStack {
                    Text("Subject:")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(transaction.emailSubject)
                        .font(.caption2)
                        .foregroundColor(.primary)
                }

                HStack {
                    Text("Date:")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(transaction.date, format: .dateTime)
                        .font(.caption2)
                        .foregroundColor(.primary)
                }
            }
            .padding(.bottom, 4)

            Divider()

            // Email body content
            ScrollView {
                Text(transaction.rawText)
                    .font(.caption2)
                    .foregroundColor(.primary)
                    .textSelection(.enabled)  // Allow copy/paste
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(8)
                    .background(Color(nsColor: .textBackgroundColor))
                    .cornerRadius(6)
            }
            .frame(maxHeight: 200)

            // Helper text
            Text("💡 Compare this original email content with the AI-extracted fields above to verify accuracy")
                .font(.caption2)
                .foregroundColor(.secondary)
                .italic()
                .padding(.top, 4)
        }
    }
}

/// Single row in invoice detail panel
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
