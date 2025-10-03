import SwiftUI
import CoreData

// BLUEPRINT Lines 73-75: Information dense, spreadsheet-like table with in-line editing
struct TransactionsTableView: View {
    @ObservedObject var viewModel: TransactionsViewModel
    @State private var sortOrder: [KeyPathComparator<Transaction>] = [
        .init(\.date, order: .reverse)
    ]

    // In-line editing state
    @State private var editingID: UUID?

    var body: some View {
        createTableView()
    }

    @ViewBuilder
    private func createTableView() -> some View {
        VStack(spacing: 0) {
            // Spreadsheet-like Table (BLUEPRINT Lines 73-75)
            Table(viewModel.filteredTransactions, selection: $viewModel.selectedIDs, sortOrder: $sortOrder) {
                // COLUMN 1: Selection checkbox
                TableColumn("") { transaction in
                    Toggle("", isOn: Binding(
                        get: { viewModel.selectedIDs.contains(transaction.id) },
                        set: { isSelected in
                            if isSelected {
                                viewModel.selectedIDs.insert(transaction.id)
                            } else {
                                viewModel.selectedIDs.remove(transaction.id)
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

                // COLUMN 3: Description
                TableColumn("Description", value: \.itemDescription) { transaction in
                    Text(transaction.itemDescription)
                        .lineLimit(1)
                }
                .width(min: 150, ideal: 200)

                // COLUMN 4: Amount
                TableColumn("Amount", value: \.amount) { transaction in
                    Text(transaction.amount, format: .currency(code: "AUD"))
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(transaction.amount < 0 ? .red : .green)
                }
                .width(min: 100, ideal: 120)

                // COLUMN 5: Category
                TableColumn("Category", value: \.category) { transaction in
                    Text(transaction.category)
                        .lineLimit(1)
                }
                .width(min: 100, ideal: 120)

                // COLUMN 6: Source (data typed)
                TableColumn("Source", value: \.source) { transaction in
                    HStack(spacing: 4) {
                        if transaction.source == "gmail" {
                            Image(systemName: "envelope.fill")
                                .font(.caption2)
                                .foregroundColor(.blue)
                        } else if transaction.source == "manual" {
                            Image(systemName: "hand.tap.fill")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                        Text(transaction.source.capitalized)
                            .font(.caption)
                    }
                }
                .width(min: 80, ideal: 90)

                // COLUMN 7: Tax Category
                TableColumn("Tax Category", value: \.taxCategory) { transaction in
                    Text(transaction.taxCategory)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(taxCategoryColor(transaction.taxCategory).opacity(0.2))
                        .foregroundColor(taxCategoryColor(transaction.taxCategory))
                        .cornerRadius(4)
                }
                .width(min: 120, ideal: 140)

                // COLUMN 8: Note Summary (shows if has invoice details)
                TableColumn("Note") { transaction in
                    if let note = transaction.note, !note.isEmpty {
                        Text(note)
                            .font(.caption2)
                            .lineLimit(2)
                    } else {
                        Text("-")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .width(min: 150, ideal: 200)
            }
            .onChange(of: sortOrder) { oldValue, newValue in
                viewModel.updateSort(newValue)
            }
        }
    }

    // MARK: - Helper Functions

    private func saveChanges() {
        viewModel.saveContext()
    }

    private func taxCategoryColor(_ category: String) -> Color {
        switch category {
        case "Personal": return .blue
        case "Business": return .purple
        case "Investment": return .green
        case "Property Investment": return .orange
        default: return .gray
        }
    }

    // Parse note field for structured display (GST, ABN, Invoice#, Payment Method)
    private func parseNoteComponents(_ note: String) -> [(key: String, value: String)] {
        // Note format: "Email: ... | From: ... | GST: $X | ABN: XXX | Invoice#: XXX | Payment: XXX"
        let components = note.components(separatedBy: " | ")
        return components.compactMap { component in
            let parts = component.components(separatedBy: ": ")
            guard parts.count == 2 else { return nil }
            return (key: parts[0], value: parts[1])
        }
    }
}
