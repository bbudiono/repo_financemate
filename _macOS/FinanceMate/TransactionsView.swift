import SwiftUI
import CoreData

// BLUEPRINT Lines 73-75: Information dense, spreadsheet-like transaction table
struct TransactionsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.colorScheme) private var colorScheme
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)],
        animation: .default)
    private var transactions: FetchedResults<Transaction>

    @StateObject private var viewModel: TransactionsViewModel
    @State private var showingAddTransaction = false

    init() {
        // Initialize viewModel with a temporary context
        // Will be updated in onAppear with the actual environment context
        let tempContext = PersistenceController.shared.container.viewContext
        _viewModel = StateObject(wrappedValue: TransactionsViewModel(viewContext: tempContext))
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header with actions
            HStack {
                Text("Transactions")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityValue("\(viewModel.filteredTransactions.count) transactions")
                Spacer()

                // Add Transaction Button
                Button(action: {
                    showingAddTransaction = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
                .buttonStyle(.plain)
                .accessibleFocus() // WCAG 2.1 AA: Focus visible indicator
                .accessibilityLabel("Add Transaction")

                // BLUEPRINT Line 73: SORTABLE via Menu (SortOption enum in ViewModel)
                Menu {
                    Button("Date (Newest)") { viewModel.sortOption = .dateDescending }
                    Button("Date (Oldest)") { viewModel.sortOption = .dateAscending }
                    Button("Amount (High)") { viewModel.sortOption = .amountDescending }
                    Button("Amount (Low)") { viewModel.sortOption = .amountAscending }
                    Button("Category (A-Z)") { viewModel.sortOption = .categoryAZ }
                } label: {
                    Image(systemName: "arrow.up.arrow.down.circle")
                        .font(.title3)
                }
                .buttonStyle(.plain)
                .accessibleFocus() // WCAG 2.1 AA: Focus visible indicator
                .accessibilityLabel("Sort Options")
            }
            .padding()

            // BLUEPRINT Line 73: SEARCHABLE
            TransactionSearchBar(searchText: $viewModel.searchText)

            // BLUEPRINT Line 73: FILTERABLE
            TransactionFilterBar(
                selectedSource: $viewModel.selectedSource,
                selectedCategory: $viewModel.selectedCategory
            )

            // BLUEPRINT Lines 73-75: Spreadsheet-like table
            if viewModel.filteredTransactions.isEmpty {
                TransactionEmptyStateView(searchText: viewModel.searchText)
            } else {
                TransactionsTableView(viewModel: viewModel)
            }
        }
        .sheet(isPresented: $showingAddTransaction) {
            AddTransactionForm(isPresented: $showingAddTransaction)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Transactions View")
        .accessibilityValue("\(viewModel.filteredTransactions.count) transactions, filtered by \(viewModel.selectedSource ?? "all sources")")
        .accessibilityIdentifier("TransactionsView")
        .onAppear {
            // Update viewModel with actual transactions
            viewModel.updateTransactions(Array(transactions))
        }
        .onChange(of: transactions.count) { oldCount, newCount in
            // Refresh when transactions change
            viewModel.updateTransactions(Array(transactions))
        }
    }
}