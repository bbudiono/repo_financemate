import SwiftUI
import CoreData

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
            TransactionSearchBar(searchText: $searchText)

            // BLUEPRINT Line 68: FILTERABLE
            TransactionFilterBar(
                selectedSource: $selectedSource,
                selectedCategory: $selectedCategory
            )

            // Transaction List
            if filteredTransactions.isEmpty {
                TransactionEmptyStateView(searchText: searchText)
            } else {
                List {
                    ForEach(filteredTransactions) { transaction in
                        TransactionRowView(transaction: transaction)
                    }
                    .onDelete(perform: deleteTransaction)
                }
            }
        }
        .sheet(isPresented: $showingAddTransaction) {
            AddTransactionForm(isPresented: $showingAddTransaction)
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
}