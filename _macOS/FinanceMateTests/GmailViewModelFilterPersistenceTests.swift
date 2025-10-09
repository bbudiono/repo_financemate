import XCTest
import CoreData
@testable import FinanceMate

/// GmailViewModel Filter Persistence Tests
/// Tests the persistence of Gmail filter state across app sessions
/// BLUEPRINT REQUIREMENT: Gmail filtering system with filter persistence
final class GmailViewModelFilterPersistenceTests: XCTestCase {

    var viewModel: GmailViewModel!
    var testContext: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        // Set up test Core Data context
        let persistenceController = PersistenceController.preview
        testContext = persistenceController.container.viewContext
        viewModel = GmailViewModel(context: testContext)

        // Clear any existing UserDefaults data for clean test
        UserDefaults.standard.removeObject(forKey: "GmailFilter_searchText")
        UserDefaults.standard.removeObject(forKey: "GmailFilter_merchantFilter")
        UserDefaults.standard.removeObject(forKey: "GmailFilter_categoryFilter")
    }

    override func tearDown() {
        // Clean up UserDefaults after each test
        UserDefaults.standard.removeObject(forKey: "GmailFilter_searchText")
        UserDefaults.standard.removeObject(forKey: "GmailFilter_merchantFilter")
        UserDefaults.standard.removeObject(forKey: "GmailFilter_categoryFilter")
        viewModel = nil
        testContext = nil
        super.tearDown()
    }

    // MARK: - RED PHASE TESTS - These should FAIL initially

    /// Test that filter state persists to UserDefaults when changed
    func testFilterStatePersistence_WhenFiltersChanged_ShouldPersistToUserDefaults() {
        // Given: Initial filter state
        XCTAssertEqual(viewModel.searchText, "", "Initial search text should be empty")
        XCTAssertNil(viewModel.merchantFilter, "Initial merchant filter should be nil")
        XCTAssertNil(viewModel.categoryFilter, "Initial category filter should be nil")

        // When: Change filter values and manually save
        viewModel.merchantFilter = "Test Merchant"
        viewModel.categoryFilter = "Test Category"
        viewModel.searchText = "test search"
        viewModel.saveFilterState()

        // Then: Filter state should be persisted to UserDefaults
        XCTAssertEqual(UserDefaults.standard.string(forKey: "GmailFilter_searchText"), "test search")
        XCTAssertEqual(UserDefaults.standard.string(forKey: "GmailFilter_merchantFilter"), "Test Merchant")
        XCTAssertEqual(UserDefaults.standard.string(forKey: "GmailFilter_categoryFilter"), "Test Category")
    }

    /// Test that filter state restores from UserDefaults on initialization
    func testFilterStateRestoration_WhenAppLaunches_ShouldRestorePersistedFilters() {
        // Given: Persisted filter state in UserDefaults
        UserDefaults.standard.set("restored search", forKey: "GmailFilter_searchText")
        UserDefaults.standard.set("Restored Merchant", forKey: "GmailFilter_merchantFilter")
        UserDefaults.standard.set("Restored Category", forKey: "GmailFilter_categoryFilter")

        // When: Create new GmailViewModel instance and load state
        let newViewModel = GmailViewModel(context: testContext)
        newViewModel.loadFilterState()

        // Then: Filter state should be restored from UserDefaults
        XCTAssertEqual(newViewModel.merchantFilter, "Restored Merchant", "Merchant filter should be restored")
        XCTAssertEqual(newViewModel.categoryFilter, "Restored Category", "Category filter should be restored")
        XCTAssertEqual(newViewModel.searchText, "restored search", "Search text should be restored")
    }

    /// Test that clear all filters updates persistence
    func testClearAllFilters_WhenCalled_ShouldUpdatePersistedState() {
        // Given: Set some filter values and persist them
        viewModel.merchantFilter = "Clear Test Merchant"
        viewModel.categoryFilter = "Clear Test Category"
        viewModel.searchText = "clear test search"
        viewModel.saveFilterState()

        // Verify initial state is persisted
        XCTAssertEqual(UserDefaults.standard.string(forKey: "GmailFilter_searchText"), "clear test search")
        XCTAssertEqual(UserDefaults.standard.string(forKey: "GmailFilter_merchantFilter"), "Clear Test Merchant")
        XCTAssertEqual(UserDefaults.standard.string(forKey: "GmailFilter_categoryFilter"), "Clear Test Category")

        // When: Clear all filters
        viewModel.clearAllFilters()

        // Then: Persisted state should be reset to defaults
        XCTAssertEqual(UserDefaults.standard.string(forKey: "GmailFilter_searchText"), "")
        XCTAssertNil(UserDefaults.standard.string(forKey: "GmailFilter_merchantFilter"))
        XCTAssertNil(UserDefaults.standard.string(forKey: "GmailFilter_categoryFilter"))
    }

    /// Test that partial filter state persistence works correctly
    func testPartialFilterPersistence_WhenOnlySomeFiltersChanged_ShouldPersistOnlyChangedFilters() {
        // Given: Initial state
        XCTAssertEqual(viewModel.searchText, "")

        // When: Change only one filter and save
        viewModel.searchText = "partial test"
        viewModel.saveFilterState()

        // Then: Only changed filter should be persisted
        XCTAssertEqual(UserDefaults.standard.string(forKey: "GmailFilter_searchText"), "partial test")

        // Unchanged filters should not exist in UserDefaults
        XCTAssertNil(UserDefaults.standard.string(forKey: "GmailFilter_merchantFilter"))
        XCTAssertNil(UserDefaults.standard.string(forKey: "GmailFilter_categoryFilter"))
    }
}