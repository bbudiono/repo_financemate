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
                    if editingID == transaction.id {
                        DatePicker("", selection: Binding(
                            get: { transaction.date },
                            set: { transaction.date = $0 }
                        ), displayedComponents: .date)
                        .labelsHidden()
                        .datePickerStyle(.compact)
                        .onSubmit {
                            saveChanges()
                            editingID = nil
                        }
                    } else {
                        Text(transaction.date, style: .date)
                            .font(.system(.body, design: .monospaced))
                            .onTapGesture(count: 2) {
                                editingID = transaction.id
                            }
                    }
                }
                .width(min: 90, ideal: 100, max: 120)

                // COLUMN 3: Description (editable - BLUEPRINT Line 75)
                TableColumn("Description", value: \.itemDescription) { transaction in
                    if editingID == transaction.id {
                        TextField("Description", text: Binding(
                            get: { transaction.itemDescription },
                            set: { transaction.itemDescription = $0 }
                        ))
                        .textFieldStyle(.plain)
                        .onSubmit {
                            saveChanges()
                            editingID = nil
                        }
                    } else {
                        Text(transaction.itemDescription)
                            .lineLimit(1)
                            .onTapGesture(count: 2) {
                                editingID = transaction.id
                            }
                    }
                }
                .width(min: 150, ideal: 200)

                // COLUMN 4: Amount (editable, currency formatted - BLUEPRINT Line 75)
                TableColumn("Amount", value: \.amount) { transaction in
                    if editingID == transaction.id {
                        TextField("Amount", value: Binding(
                            get: { transaction.amount },
                            set: { transaction.amount = $0 }
                        ), format: .number)
                        .textFieldStyle(.plain)
                        .onSubmit {
                            saveChanges()
                            editingID = nil
                        }
                    } else {
                        Text(transaction.amount, format: .currency(code: "AUD"))
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(transaction.amount < 0 ? .red : .green)
                            .onTapGesture(count: 2) {
                                editingID = transaction.id
                            }
                    }
                }
                .width(min: 100, ideal: 120)

                // COLUMN 5: Category (editable - BLUEPRINT Line 75)
                TableColumn("Category", value: \.category) { transaction in
                    if editingID == transaction.id {
                        TextField("Category", text: Binding(
                            get: { transaction.category },
                            set: { transaction.category = $0 }
                        ))
                        .textFieldStyle(.plain)
                        .onSubmit {
                            saveChanges()
                            editingID = nil
                        }
                    } else {
                        Text(transaction.category)
                            .lineLimit(1)
                            .onTapGesture(count: 2) {
                                editingID = transaction.id
                            }
                    }
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

                // COLUMN 7: Tax Category (editable - BLUEPRINT Line 75)
                TableColumn("Tax Category", value: \.taxCategory) { transaction in
                    if editingID == transaction.id {
                        Picker("", selection: Binding(
                            get: { transaction.taxCategory },
                            set: { transaction.taxCategory = $0 }
                        )) {
                            ForEach(TaxCategory.allCases, id: \.self) { category in
                                Text(category.rawValue).tag(category.rawValue)
                            }
                        }
                        .labelsHidden()
                        .onSubmit {
                            saveChanges()
                            editingID = nil
                        }
                    } else {
                        Text(transaction.taxCategory)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(taxCategoryColor(transaction.taxCategory).opacity(0.2))
                            .foregroundColor(taxCategoryColor(transaction.taxCategory))
                            .cornerRadius(4)
                            .onTapGesture(count: 2) {
                                editingID = transaction.id
                            }
                    }
                }
                .width(min: 120, ideal: 140)
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
}
