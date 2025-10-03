import SwiftUI

// BLUEPRINT Lines 67-68: Information dense, spreadsheet-like table with in-line editing
struct GmailReceiptsTableView: View {
    @Binding var transactions: [ExtractedTransaction]
    @Binding var selectedIDs: Set<String>
    @State private var sortOrder: [KeyPathComparator<ExtractedTransaction>] = [
        .init(\.date, order: .reverse)
    ]

    // In-line editing state (track which row is being edited)
    @State private var editingID: String?

    var body: some View {
        VStack(spacing: 0) {
            // Spreadsheet-like Table (BLUEPRINT Line 68)
            Table(transactions, selection: $selectedIDs, sortOrder: $sortOrder) {
                // COLUMN 1: Confirmation checkbox
                TableColumn("") { transaction in
                    Toggle("", isOn: Binding(
                        get: { selectedIDs.contains(transaction.id) },
                        set: { isSelected in
                            if isSelected {
                                selectedIDs.insert(transaction.id)
                            } else {
                                selectedIDs.remove(transaction.id)
                            }
                        }
                    ))
                    .toggleStyle(.checkbox)
                    .labelsHidden()
                }
                .width(30)

                // COLUMN 2: Date (sortable, data typed)
                TableColumn("Date", value: \.date) { transaction in
                    Text(transaction.date, style: .date)
                        .font(.system(.body, design: .monospaced))
                }
                .width(min: 90, ideal: 100, max: 120)

                // COLUMN 3: Merchant (editable - BLUEPRINT Line 68)
                TableColumn("Merchant", value: \.merchant) { transaction in
                    if editingID == transaction.id {
                        TextField("Merchant", text: Binding(
                            get: { transaction.merchant },
                            set: { transaction.merchant = $0 }
                        ))
                        .textFieldStyle(.plain)
                        .onSubmit {
                            editingID = nil
                        }
                    } else {
                        Text(transaction.merchant)
                            .onTapGesture(count: 2) {
                                editingID = transaction.id
                            }
                    }
                }
                .width(min: 120, ideal: 150)

                // COLUMN 4: Amount (editable, currency formatted - BLUEPRINT Line 68)
                TableColumn("Amount", value: \.amount) { transaction in
                    if editingID == transaction.id {
                        TextField("Amount", value: Binding(
                            get: { transaction.amount },
                            set: { transaction.amount = $0 }
                        ), format: .number)
                        .textFieldStyle(.plain)
                        .onSubmit {
                            editingID = nil
                        }
                    } else {
                        Text(transaction.amount, format: .currency(code: "AUD"))
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(transaction.amount < 0 ? .red : .primary)
                            .onTapGesture(count: 2) {
                                editingID = transaction.id
                            }
                    }
                }
                .width(min: 80, ideal: 100)

                // COLUMN 5: Category (editable - BLUEPRINT Line 68)
                TableColumn("Category", value: \.category) { transaction in
                    if editingID == transaction.id {
                        TextField("Category", text: Binding(
                            get: { transaction.category },
                            set: { transaction.category = $0 }
                        ))
                        .textFieldStyle(.plain)
                        .onSubmit {
                            editingID = nil
                        }
                    } else {
                        Text(transaction.category)
                            .onTapGesture(count: 2) {
                                editingID = transaction.id
                            }
                    }
                }
                .width(min: 100, ideal: 120)

                // COLUMN 6: Confidence (data typed as percentage)
                TableColumn("Confidence", value: \.confidence) { transaction in
                    HStack {
                        Text("\(Int(transaction.confidence * 100))%")
                            .font(.system(.body, design: .monospaced))

                        // Visual indicator
                        Circle()
                            .fill(confidenceColor(transaction.confidence))
                            .frame(width: 8, height: 8)
                    }
                }
                .width(min: 80, ideal: 90)

                // COLUMN 7: Items count
                TableColumn("Items") { transaction in
                    Text("\(transaction.items.count)")
                        .font(.system(.body, design: .monospaced))
                }
                .width(min: 50, ideal: 60)

                // COLUMN 8: Source details
                TableColumn("Source") { transaction in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(transaction.emailSender)
                            .font(.caption)
                            .lineLimit(1)
                        Text(transaction.emailSubject)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                .width(min: 150, ideal: 200)
            }
            .onChange(of: sortOrder) { oldValue, newValue in
                transactions.sort(using: newValue)
            }
        }
    }

    // MARK: - Helper Functions

    private func confidenceColor(_ confidence: Double) -> Color {
        if confidence >= 0.8 { return .green }
        else if confidence >= 0.5 { return .yellow }
        else { return .red }
    }
}
