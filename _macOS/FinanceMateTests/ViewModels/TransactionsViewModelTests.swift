import XCTest
import CoreData
@testable import FinanceMate

/**
 * TransactionsViewModelTests.swift
 * 
 * Purpose: Comprehensive TDD unit tests for TransactionsViewModel with filtering and search functionality
 * Issues & Complexity Summary: Tests filtering, searching, Australian locale, and performance optimization
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~400
 *   - Core Algorithm Complexity: High
 *   - Dependencies: 4 (Core Data, XCTest, Combine, Foundation)
 *   - State Management Complexity: High
 *   - Novelty/Uncertainty Factor: Medium
 * AI Pre-Task Self-Assessment: 85%
 * Problem Estimate: 90%
 * Initial Code Complexity Estimate: 85%
 * Final Code Complexity: TBD
 * Overall Result Score: TBD
 * Key Variances/Learnings: Comprehensive TDD for enhanced transaction management
 * Last Updated: 2025-07-06
 */

// EMERGENCY FIX: Removed to eliminate Swift Concurrency crashes
// COMPREHENSIVE FIX: Removed ALL Swift Concurrency patterns to eliminate TaskLocal crashes
final class TransactionsViewModelTests: XCTestCase {
    var viewModel: TransactionsViewModel!
    var persistenceController: PersistenceController!
    var context: NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        persistenceController = PersistenceController(inMemory: true)
        context = persistenceController.container.viewContext
        viewModel = TransactionsViewModel(context: context)
    }
    
    override func tearDown() {
        viewModel = nil
        context = nil
        persistenceController = nil
        super.tearDown()
    }
    
    // MARK: - Helper Methods
    
    private func createTestTransaction(amount: Double, category: String, note: String? = nil, date: Date = Date()) -> Transaction {
        let transaction = Transaction.create(in: context, amount: amount, category: category, note: note)
        transaction.date = date
        try! context.save()
        return transaction
    }
    
    private func createLargeDataset(count: Int = 1000) {
        let categories = ["Food", "Transport", "Entertainment", "Bills", "Shopping", "Health", "Education"]
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_AU")
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        for i in 0..<count {
            let amount = Double.random(in: 10.0...500.0)
            let category = categories.randomElement()!
            let note = i % 3 == 0 ? "Test transaction \(i)" : nil
            let daysAgo = Int.random(in: 0...365)
            let date = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date())!
            
            _ = createTestTransaction(amount: amount, category: category, note: note, date: date)
        }
    }
    
    // MARK: - Initialization Tests
    
    func testViewModelInitialization() {
        // Given: A Core Data context
        // When: Creating a TransactionsViewModel
        let newViewModel = TransactionsViewModel(context: context)
        
        // Then: The view model should be properly initialized
        XCTAssertNotNil(newViewModel, "TransactionsViewModel should be properly initialized")
        XCTAssertEqual(newViewModel.transactions.count, 0, "Initial transactions array should be empty")
        XCTAssertEqual(newViewModel.filteredTransactions.count, 0, "Initial filtered transactions should be empty")
        XCTAssertFalse(newViewModel.isLoading, "Initial loading state should be false")
        XCTAssertNil(newViewModel.errorMessage, "Initial error message should be nil")
        XCTAssertEqual(newViewModel.searchText, "", "Initial search text should be empty")
        XCTAssertNil(newViewModel.selectedCategory, "Initial selected category should be nil")
        XCTAssertNil(newViewModel.startDate, "Initial start date should be nil")
        XCTAssertNil(newViewModel.endDate, "Initial end date should be nil")
    }
    
    // MARK: - Core Data Integration Tests
    
    func testFetchTransactions() {
        // Given: Some test transactions
        createTestTransaction(amount: 100.0, category: "Food")
        createTestTransaction(amount: 200.0, category: "Transport")
        
        // When: Fetching transactions
        viewModel.fetchTransactions()
        
        // Then: Transactions should be fetched and sorted by date descending
        XCTAssertEqual(viewModel.transactions.count, 2, "Should have 2 transactions")
        XCTAssertFalse(viewModel.isLoading, "Loading should be false after fetch")
        XCTAssertNil(viewModel.errorMessage, "Error message should be nil for successful fetch")
    }
    
    func testFetchTransactionsEmptyDatabase() {
        // Given: Empty database
        // When: Fetching transactions
        viewModel.fetchTransactions()
        
        // Then: Should handle empty result gracefully
        XCTAssertEqual(viewModel.transactions.count, 0, "Should have no transactions")
        XCTAssertEqual(viewModel.filteredTransactions.count, 0, "Should have no filtered transactions")
        XCTAssertFalse(viewModel.isLoading, "Loading should be false after fetch")
        XCTAssertNil(viewModel.errorMessage, "Error message should be nil")
    }
    
    // MARK: - Search Functionality Tests
    
    func testSearchFunctionality() {
        // Given: Transactions with different notes
        createTestTransaction(amount: 50.0, category: "Food", note: "McDonald's lunch")
        createTestTransaction(amount: 75.0, category: "Food", note: "KFC dinner")
        createTestTransaction(amount: 100.0, category: "Transport", note: "Uber ride")
        viewModel.fetchTransactions()
        
        // When: Searching for "lunch"
        viewModel.searchText = "lunch"
        
        // Then: Should return only matching transactions
        XCTAssertEqual(viewModel.filteredTransactions.count, 1, "Should find 1 transaction with 'lunch'")
        XCTAssertEqual(viewModel.filteredTransactions.first?.note, "McDonald's lunch", "Should match the correct transaction")
    }
    
    func testCaseInsensitiveSearch() {
        // Given: Transactions with mixed case notes
        createTestTransaction(amount: 50.0, category: "Food", note: "McDonald's LUNCH")
        createTestTransaction(amount: 75.0, category: "Transport", note: "uber ride")
        viewModel.fetchTransactions()
        
        // When: Searching with different cases
        viewModel.searchText = "lunch"
        XCTAssertEqual(viewModel.filteredTransactions.count, 1, "Should find 'LUNCH' with lowercase search")
        
        viewModel.searchText = "UBER"
        XCTAssertEqual(viewModel.filteredTransactions.count, 1, "Should find 'uber' with uppercase search")
        
        viewModel.searchText = "McDonaLD"
        XCTAssertEqual(viewModel.filteredTransactions.count, 1, "Should find 'McDonald's' with mixed case search")
    }
    
    func testSearchInCategory() {
        // Given: Transactions with searchable categories
        createTestTransaction(amount: 50.0, category: "Food & Dining")
        createTestTransaction(amount: 75.0, category: "Transportation")
        createTestTransaction(amount: 100.0, category: "Entertainment")
        viewModel.fetchTransactions()
        
        // When: Searching for category text
        viewModel.searchText = "food"
        
        // Then: Should find transactions by category
        XCTAssertEqual(viewModel.filteredTransactions.count, 1, "Should find transaction with 'Food' in category")
    }
    
    func testEmptySearchReturnsAllTransactions() {
        // Given: Multiple transactions
        createTestTransaction(amount: 50.0, category: "Food")
        createTestTransaction(amount: 75.0, category: "Transport")
        viewModel.fetchTransactions()
        
        // When: Search text is empty
        viewModel.searchText = ""
        
        // Then: Should return all transactions
        XCTAssertEqual(viewModel.filteredTransactions.count, 2, "Empty search should return all transactions")
    }
    
    // MARK: - Category Filtering Tests
    
    func testCategoryFiltering() {
        // Given: Transactions with different categories
        createTestTransaction(amount: 50.0, category: "Food")
        createTestTransaction(amount: 75.0, category: "Transport")
        createTestTransaction(amount: 100.0, category: "Food")
        viewModel.fetchTransactions()
        
        // When: Filtering by category
        viewModel.selectedCategory = "Food"
        
        // Then: Should return only Food transactions
        XCTAssertEqual(viewModel.filteredTransactions.count, 2, "Should find 2 Food transactions")
        for transaction in viewModel.filteredTransactions {
            XCTAssertEqual(transaction.category, "Food", "All filtered transactions should be Food category")
        }
    }
    
    func testNilCategoryShowsAllTransactions() {
        // Given: Transactions with different categories
        createTestTransaction(amount: 50.0, category: "Food")
        createTestTransaction(amount: 75.0, category: "Transport")
        viewModel.fetchTransactions()
        
        // When: Category filter is nil (show all)
        viewModel.selectedCategory = nil
        
        // Then: Should return all transactions
        XCTAssertEqual(viewModel.filteredTransactions.count, 2, "Nil category should show all transactions")
    }
    
    // MARK: - Date Range Filtering Tests
    
    func testDateRangeFiltering() {
        // Given: Transactions with different dates
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let lastWeek = calendar.date(byAdding: .day, value: -7, to: today)!
        
        createTestTransaction(amount: 50.0, category: "Food", date: today)
        createTestTransaction(amount: 75.0, category: "Transport", date: yesterday)
        createTestTransaction(amount: 100.0, category: "Entertainment", date: lastWeek)
        viewModel.fetchTransactions()
        
        // When: Filtering by date range (yesterday to today)
        viewModel.startDate = yesterday
        viewModel.endDate = today
        
        // Then: Should return only transactions within range
        XCTAssertEqual(viewModel.filteredTransactions.count, 2, "Should find 2 transactions in date range")
    }
    
    func testStartDateOnlyFiltering() {
        // Given: Transactions with different dates
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let lastWeek = calendar.date(byAdding: .day, value: -7, to: today)!
        
        createTestTransaction(amount: 50.0, category: "Food", date: today)
        createTestTransaction(amount: 75.0, category: "Transport", date: yesterday)
        createTestTransaction(amount: 100.0, category: "Entertainment", date: lastWeek)
        viewModel.fetchTransactions()
        
        // When: Setting only start date
        viewModel.startDate = yesterday
        viewModel.endDate = nil
        
        // Then: Should return transactions from start date onwards
        XCTAssertEqual(viewModel.filteredTransactions.count, 2, "Should find transactions from yesterday onwards")
    }
    
    func testEndDateOnlyFiltering() {
        // Given: Transactions with different dates
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let lastWeek = calendar.date(byAdding: .day, value: -7, to: today)!
        
        createTestTransaction(amount: 50.0, category: "Food", date: today)
        createTestTransaction(amount: 75.0, category: "Transport", date: yesterday)
        createTestTransaction(amount: 100.0, category: "Entertainment", date: lastWeek)
        viewModel.fetchTransactions()
        
        // When: Setting only end date
        viewModel.startDate = nil
        viewModel.endDate = yesterday
        
        // Then: Should return transactions up to end date
        XCTAssertEqual(viewModel.filteredTransactions.count, 2, "Should find transactions up to yesterday")
    }
    
    // MARK: - Combined Filtering Tests
    
    func testCombinedFiltering() {
        // Given: Transactions with various properties
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        
        createTestTransaction(amount: 50.0, category: "Food", note: "Lunch at cafe", date: today)
        createTestTransaction(amount: 75.0, category: "Food", note: "Dinner at restaurant", date: yesterday)
        createTestTransaction(amount: 100.0, category: "Transport", note: "Lunch taxi", date: today)
        viewModel.fetchTransactions()
        
        // When: Applying multiple filters
        viewModel.selectedCategory = "Food"
        viewModel.searchText = "lunch"
        viewModel.startDate = today
        
        // Then: Should return only transactions matching all criteria
        XCTAssertEqual(viewModel.filteredTransactions.count, 1, "Should find 1 transaction matching all filters")
        let transaction = viewModel.filteredTransactions.first!
        XCTAssertEqual(transaction.category, "Food")
        XCTAssertTrue(transaction.note?.lowercased().contains("lunch") ?? false)
    }
    
    // MARK: - Australian Locale Tests
    
    func testAustralianCurrencyFormatting() {
        // Given: A transaction with amount
        createTestTransaction(amount: 1234.56, category: "Test")
        viewModel.fetchTransactions()
        
        // When: Formatting currency for Australian locale
        let formattedAmount = viewModel.formatCurrency(1234.56)
        
        // Then: Should format according to Australian standards
        XCTAssertTrue(formattedAmount.contains("$"), "Should contain dollar sign")
        XCTAssertTrue(formattedAmount.contains("1,234.56") || formattedAmount.contains("1234.56"), "Should format amount correctly")
    }
    
    func testAustralianDateFormatting() {
        // Given: A transaction with date
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_AU")
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let testDate = dateFormatter.date(from: "25/12/2023")!
        
        createTestTransaction(amount: 100.0, category: "Test", date: testDate)
        viewModel.fetchTransactions()
        
        // When: Formatting date for Australian locale
        let formattedDate = viewModel.formatDate(testDate)
        
        // Then: Should format as DD/MM/YYYY
        XCTAssertEqual(formattedDate, "25/12/2023", "Should format date in Australian format")
    }
    
    // MARK: - Performance Tests
    
    func testPerformanceWithLargeDataset() {
        // Given: Large dataset
        createLargeDataset(count: 1000)
        
        // When: Measuring fetch performance
        measure {
            viewModel.fetchTransactions()
        }
        
        // Then: Should complete within reasonable time
        XCTAssertEqual(viewModel.transactions.count, 1000, "Should fetch all 1000 transactions")
    }
    
    func testSearchPerformanceWithLargeDataset() {
        // Given: Large dataset with searchable content
        createLargeDataset(count: 1000)
        viewModel.fetchTransactions()
        
        // When: Measuring search performance
        measure {
            viewModel.searchText = "transaction"
        }
        
        // Then: Search should complete efficiently
        XCTAssertGreaterThan(viewModel.filteredTransactions.count, 0, "Should find matching transactions")
    }
    
    func testFilteringPerformanceWithLargeDataset() {
        // Given: Large dataset
        createLargeDataset(count: 1000)
        viewModel.fetchTransactions()
        
        // When: Measuring filtering performance
        measure {
            viewModel.selectedCategory = "Food"
        }
        
        // Then: Filtering should complete efficiently
        XCTAssertGreaterThan(viewModel.filteredTransactions.count, 0, "Should find Food transactions")
    }
    
    // MARK: - Error Handling Tests
    
    func testErrorStateManagement() {
        // Given: A view model
        // When: Error occurs (simulated by setting error message)
        viewModel.errorMessage = "Test error"
        
        // Then: Error state should be managed correctly
        XCTAssertEqual(viewModel.errorMessage, "Test error", "Error message should be set")
        
        // When: Clearing error
        viewModel.clearError()
        
        // Then: Error should be cleared
        XCTAssertNil(viewModel.errorMessage, "Error message should be cleared")
    }
    
    // MARK: - State Management Tests
    
    func testLoadingStateManagement() {
        // Given: A view model
        XCTAssertFalse(viewModel.isLoading, "Initial loading state should be false")
        
        // When: Starting an operation (fetch)
        viewModel.fetchTransactions()
        
        // Then: Loading state should be managed
        XCTAssertFalse(viewModel.isLoading, "Loading should be false after fetch completes")
    }
    
    func testTransactionCountCalculation() {
        // Given: Multiple transactions
        createTestTransaction(amount: 50.0, category: "Food")
        createTestTransaction(amount: 75.0, category: "Transport")
        createTestTransaction(amount: 100.0, category: "Entertainment")
        viewModel.fetchTransactions()
        
        // When: Getting transaction count
        let totalCount = viewModel.totalTransactionCount
        let filteredCount = viewModel.filteredTransactionCount
        
        // Then: Counts should be accurate
        XCTAssertEqual(totalCount, 3, "Total count should be 3")
        XCTAssertEqual(filteredCount, 3, "Filtered count should be 3 with no filters")
        
        // When: Applying filter
        viewModel.selectedCategory = "Food"
        
        // Then: Filtered count should update
        XCTAssertEqual(viewModel.filteredTransactionCount, 1, "Filtered count should be 1 with Food filter")
    }
    
    // MARK: - Validation Tests
    
    func testTransactionValidation() {
        // Given: Invalid transaction data
        // When: Attempting to create transaction with zero amount
        let isValidZero = viewModel.validateTransactionAmount(0.0)
        
        // Then: Should be invalid
        XCTAssertFalse(isValidZero, "Zero amount should be invalid")
        
        // When: Attempting to create transaction with negative amount
        let isValidNegative = viewModel.validateTransactionAmount(-50.0)
        
        // Then: Should be invalid
        XCTAssertFalse(isValidNegative, "Negative amount should be invalid")
        
        // When: Valid amount
        let isValidPositive = viewModel.validateTransactionAmount(50.0)
        
        // Then: Should be valid
        XCTAssertTrue(isValidPositive, "Positive amount should be valid")
    }
    
    // MARK: - Categories Management Tests
    
    func testAvailableCategories() {
        // Given: Transactions with various categories
        createTestTransaction(amount: 50.0, category: "Food")
        createTestTransaction(amount: 75.0, category: "Transport")
        createTestTransaction(amount: 100.0, category: "Food")
        createTestTransaction(amount: 125.0, category: "Entertainment")
        viewModel.fetchTransactions()
        
        // When: Getting available categories
        let categories = viewModel.availableCategories
        
        // Then: Should return unique categories
        XCTAssertEqual(categories.count, 3, "Should have 3 unique categories")
        XCTAssertTrue(categories.contains("Food"), "Should contain Food category")
        XCTAssertTrue(categories.contains("Transport"), "Should contain Transport category")
        XCTAssertTrue(categories.contains("Entertainment"), "Should contain Entertainment category")
    }
    
    // MARK: - Reset Functionality Tests
    
    func testResetFilters() {
        // Given: Applied filters
        viewModel.searchText = "test"
        viewModel.selectedCategory = "Food"
        viewModel.startDate = Date()
        viewModel.endDate = Date()
        
        // When: Resetting filters
        viewModel.resetFilters()
        
        // Then: All filters should be cleared
        XCTAssertEqual(viewModel.searchText, "", "Search text should be empty")
        XCTAssertNil(viewModel.selectedCategory, "Selected category should be nil")
        XCTAssertNil(viewModel.startDate, "Start date should be nil")
        XCTAssertNil(viewModel.endDate, "End date should be nil")
    }
}