import SwiftUI
import CoreData

// BLUEPRINT Lines 73-75: ViewModel for managing transaction table state
class TransactionsViewModel: ObservableObject {
    @Published var selectedIDs: Set<UUID> = []
    @Published var searchText: String = ""
    @Published var selectedSource: String? = nil
    @Published var selectedCategory: String? = nil
    @Published var sortOption: SortOption = .dateDescending

    private var viewContext: NSManagedObjectContext
    private var allTransactions: [Transaction] = []

    enum SortOption {
        case dateDescending, dateAscending, amountDescending, amountAscending, categoryAZ
    }

    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
    }

    // BLUEPRINT Line 73: Filterable, searchable, sortable
    var filteredTransactions: [Transaction] {
        var result = allTransactions

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

    func updateTransactions(_ transactions: [Transaction]) {
        self.allTransactions = transactions
        objectWillChange.send()
    }

    func updateSort(_ sortOrder: [KeyPathComparator<Transaction>]) {
        // Handle sort order changes from Table
        objectWillChange.send()
    }

    func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }

    func deleteTransactions(at offsets: IndexSet) {
        for index in offsets {
            let transaction = filteredTransactions[index]
            viewContext.delete(transaction)
        }
        saveContext()
    }

    // Delete single transaction (for quick action button)
    func deleteTransaction(_ transaction: Transaction) {
        viewContext.delete(transaction)
        saveContext()
        objectWillChange.send()
    }
}
