import SwiftUI

struct TransactionsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.colorScheme) private var colorScheme
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)],
        animation: .default)
    private var transactions: FetchedResults<Transaction>

    @State private var searchText = ""
    @State private var selectedSource: String? = nil
    @State private var selectedCategory: String? = nil
    @State private var sortOption: SortOption = .dateDescending
    @State private var showingAddTransaction = false
    @State private var isDeleting = false

    enum SortOption {
        case dateDescending, dateAscending, amountDescending, amountAscending, categoryAZ
    }

    // BLUEPRINT Line 68: FILTERABLE, SEARCHABLE, SORTABLE
    var filteredTransactions: [Transaction] {
        var result = Array(transactions)

        // Search
        if !searchText.isEmpty {
            result = result.filter {
                $0.itemDescription.localizedCaseInsensitiveContains(searchText) ||
                $0.category.localizedCaseInsensitiveContains(searchText)
            }
        }

        // Filter by source
        if let source = selectedSource {
            result = result.filter { $0.source == source }
        }

        // Filter by category
        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }

        // Sort
        switch sortOption {
        case .dateDescending: result.sort { $0.date > $1.date }
        case .dateAscending: result.sort { $0.date < $1.date }
        case .amountDescending: result.sort { $0.amount > $1.amount }
        case .amountAscending: result.sort { $0.amount < $1.amount }
        case .categoryAZ: result.sort { $0.category < $1.category }
        }

        return result
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header with sort menu
            HStack {
                Text("Transactions")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()

                // Add Transaction Button
                Button(action: {
                    showingAddTransaction = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Add Transaction")

                // BLUEPRINT Line 68: SORTABLE
                Menu {
                    Button("Date (Newest)") { sortOption = .dateDescending }
                    Button("Date (Oldest)") { sortOption = .dateAscending }
                    Button("Amount (High)") { sortOption = .amountDescending }
                    Button("Amount (Low)") { sortOption = .amountAscending }
                    Button("Category (A-Z)") { sortOption = .categoryAZ }
                } label: {
                    Image(systemName: "arrow.up.arrow.down.circle")
                        .font(.title3)
                }
                .buttonStyle(.plain)
            }
            .padding()

            // BLUEPRINT Line 68: SEARCHABLE
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search transactions...", text: $searchText)
                    .textFieldStyle(.plain)
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(8)
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(8)
            .padding(.horizontal)

            // BLUEPRINT Line 68: FILTERABLE
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    FilterButton(title: "All", isSelected: selectedSource == nil && selectedCategory == nil) {
                        selectedSource = nil
                        selectedCategory = nil
                    }
                    FilterButton(title: "Gmail", isSelected: selectedSource == "gmail") {
                        selectedSource = selectedSource == "gmail" ? nil : "gmail"
                    }
                    FilterButton(title: "Manual", isSelected: selectedSource == "manual") {
                        selectedSource = selectedSource == "manual" ? nil : "manual"
                    }
                    ForEach(["Groceries", "Dining", "Transport", "Utilities"], id: \.self) { cat in
                        FilterButton(title: cat, isSelected: selectedCategory == cat) {
                            selectedCategory = selectedCategory == cat ? nil : cat
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }

            // Transaction List
            if filteredTransactions.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text(searchText.isEmpty ? "No transactions yet" : "No matching transactions")
                        .foregroundColor(.secondary)
                }
                .frame(maxHeight: .infinity)
            } else {
                List {
                    ForEach(filteredTransactions) { transaction in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(transaction.itemDescription)
                                    .font(.headline)
                                HStack(spacing: 8) {
                                    // Source badge
                                    if transaction.source == "gmail" {
                                        Image(systemName: "envelope.fill")
                                            .font(.caption2)
                                            .foregroundColor(.blue)
                                    }
                                    // Tax category
                                    Text(transaction.taxCategory)
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(taxCategoryColor(transaction.taxCategory).opacity(0.2))
                                        .foregroundColor(taxCategoryColor(transaction.taxCategory))
                                        .cornerRadius(4)
                                    // Date
                                    Text(transaction.date, style: .date)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }

                            Spacer()

                            Text(String(format: "$%.2f", transaction.amount))
                                .font(.headline)
                                .foregroundColor(transaction.amount >= 0 ? .green : .red)
                        }
                    }
                    .onDelete(perform: deleteTransaction)
                }
            }
        }
        .sheet(isPresented: $showingAddTransaction) {
            // Add Transaction Form (placeholder for now)
            VStack(spacing: 20) {
                Text("Add Transaction")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Transaction form coming soon")
                    .foregroundColor(.secondary)

                Button("Cancel") {
                    showingAddTransaction = false
                }
                .buttonStyle(.borderedProminent)
            }
            .frame(width: 400, height: 300)
            .padding()
        }
    }

    private func deleteTransaction(at offsets: IndexSet) {
        withAnimation {
            isDeleting = true
            for index in offsets {
                let transaction = filteredTransactions[index]
                viewContext.delete(transaction)
            }

            do {
                try viewContext.save()
                isDeleting = false
            } catch {
                // Handle error
                print("Failed to delete transaction: \(error)")
                isDeleting = false
            }
        }
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

// MARK: - Filter Button Component

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color.secondary.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
        .buttonStyle(.plain)
    }
}
