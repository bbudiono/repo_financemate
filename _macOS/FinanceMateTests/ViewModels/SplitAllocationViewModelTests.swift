import XCTest
import CoreData
@testable import FinanceMate

final class SplitAllocationViewModelTests: XCTestCase {

    var viewModel: SplitAllocationViewModel!
    var persistentContainer: NSPersistentContainer!
    var managedObjectContext: NSManagedObjectContext!
    var testLineItem: LineItem!

    override func setUpWithError() throws {
        // Create in-memory Core Data stack for testing
        persistentContainer = NSPersistentContainer(name: "FinanceMate", managedObjectModel: PersistenceController.createModel())
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        persistentContainer.persistentStoreDescriptions = [description]

        persistentContainer.loadPersistentStores { _, error in
            XCTAssertNil(error, "Failed to load test store: \(error?.localizedDescription ?? "Unknown error")")
        }

        managedObjectContext = persistentContainer.viewContext

        // Create a test line item
        testLineItem = LineItem(context: managedObjectContext)
        testLineItem.id = UUID()
        testLineItem.itemDescription = "Test Item"
        testLineItem.quantity = 2
        testLineItem.price = 50.0
        testLineItem.taxCategory = "Personal"

        try managedObjectContext.save()

        // Initialize ViewModel
        viewModel = SplitAllocationViewModel(context: managedObjectContext)
    }

    override func tearDownWithError() throws {
        viewModel = nil
        managedObjectContext = nil
        persistentContainer = nil
        testLineItem = nil
    }

    // MARK: - Initialization Tests

    func testInitialization() throws {
        XCTAssertNotNil(viewModel)
        XCTAssertEqual(viewModel.splitAllocations.count, 0)
        XCTAssertEqual(viewModel.newSplitPercentage, 0.0)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.customCategories.count, 0)
        XCTAssertFalse(viewModel.selectedTaxCategory.isEmpty)
    }

    func testDefaultTaxCategorySelection() throws {
        XCTAssertTrue(SplitAllocationTaxCategoryService.predefinedCategories.contains(viewModel.selectedTaxCategory))
    }

    // MARK: - Computed Properties Tests

    func testTotalPercentageCalculation() throws {
        // Given
        let allocation1 = SplitAllocation.create(in: managedObjectContext, percentage: 30.0, taxCategory: "Business", lineItem: testLineItem)
        let allocation2 = SplitAllocation.create(in: managedObjectContext, percentage: 40.0, taxCategory: "Personal", lineItem: testLineItem)
        viewModel.splitAllocations = [allocation1, allocation2]

        // When
        let total = viewModel.totalPercentage

        // Then
        XCTAssertEqual(total, 70.0, accuracy: 0.01, "Total should be sum of allocations")
    }

    func testIsValidSplit_EmptySplits() throws {
        // Given
        viewModel.splitAllocations = []

        // When
        let isValid = viewModel.isValidSplit

        // Then
        XCTAssertTrue(isValid, "Empty splits should be valid")
    }

    func testIsValidSplit_CompleteSplits() throws {
        // Given
        let allocation1 = SplitAllocation.create(in: managedObjectContext, percentage: 60.0, taxCategory: "Business", lineItem: testLineItem)
        let allocation2 = SplitAllocation.create(in: managedObjectContext, percentage: 40.0, taxCategory: "Personal", lineItem: testLineItem)
        viewModel.splitAllocations = [allocation1, allocation2]

        // When
        let isValid = viewModel.isValidSplit

        // Then
        XCTAssertTrue(isValid, "Complete 100% splits should be valid")
    }

    func testRemainingPercentageCalculation() throws {
        // Given
        let allocation1 = SplitAllocation.create(in: managedObjectContext, percentage: 30.0, taxCategory: "Business", lineItem: testLineItem)
        viewModel.splitAllocations = [allocation1]

        // When
        let remaining = viewModel.remainingPercentage

        // Then
        XCTAssertEqual(remaining, 70.0, accuracy: 0.01, "Should have 70% remaining")
    }

    func testAvailableTaxCategories() throws {
        // Given
        viewModel.customCategories = ["Custom1", "Custom2"]

        // When
        let available = viewModel.availableTaxCategories

        // Then
        let expectedCount = SplitAllocationTaxCategoryService.predefinedCategories.count + 2
        XCTAssertEqual(available.count, expectedCount, "Should include predefined and custom categories")
        XCTAssertTrue(available.contains("Custom1"), "Should include custom category")
        XCTAssertTrue(available.contains("Custom2"), "Should include custom category")
    }

    // MARK: - CRUD Operations Tests

    func testAddSplitAllocation_Success() throws {
        // Given
        viewModel.newSplitPercentage = 25.0
        viewModel.selectedTaxCategory = "Business"

        // When
        viewModel.addSplitAllocation(to: testLineItem)

        // Then
        XCTAssertNil(viewModel.errorMessage, "Should not have error message")
        XCTAssertEqual(viewModel.newSplitPercentage, 0.0, "Should reset percentage")
        XCTAssertEqual(viewModel.splitAllocations.count, 1, "Should have one allocation")
        XCTAssertEqual(viewModel.splitAllocations.first?.percentage, 25.0, "Should set correct percentage")
        XCTAssertEqual(viewModel.splitAllocations.first?.taxCategory, "Business", "Should set correct category")
    }

    func testAddSplitAllocation_InvalidPercentage() throws {
        // Given
        viewModel.newSplitPercentage = 150.0 // Invalid
        viewModel.selectedTaxCategory = "Business"

        // When
        viewModel.addSplitAllocation(to: testLineItem)

        // Then
        XCTAssertNotNil(viewModel.errorMessage, "Should have error message")
        XCTAssertEqual(viewModel.splitAllocations.count, 0, "Should not create allocation")
        XCTAssertTrue(viewModel.errorMessage?.contains("exceed 100%") == true, "Error should mention exceeding 100%")
    }

    func testAddSplitAllocation_InvalidCategory() throws {
        // Given
        viewModel.newSplitPercentage = 25.0
        viewModel.selectedTaxCategory = "  " // Invalid whitespace

        // When
        viewModel.addSplitAllocation(to: testLineItem)

        // Then
        XCTAssertNotNil(viewModel.errorMessage, "Should have error message")
        XCTAssertEqual(viewModel.errorMessage, "Invalid tax category")
        XCTAssertEqual(viewModel.splitAllocations.count, 0, "Should not create allocation")
    }

    func testUpdateSplitAllocation_Success() throws {
        // Given
        let allocation = SplitAllocation.create(in: managedObjectContext, percentage: 25.0, taxCategory: "Business", lineItem: testLineItem)
        try managedObjectContext.save()
        allocation.percentage = 35.0

        // When
        viewModel.updateSplitAllocation(allocation)

        // Then
        XCTAssertNil(viewModel.errorMessage, "Should not have error message")
    }

    func testUpdateSplitAllocation_InvalidPercentage() throws {
        // Given
        let allocation = SplitAllocation.create(in: managedObjectContext, percentage: 25.0, taxCategory: "Business", lineItem: testLineItem)
        try managedObjectContext.save()
        allocation.percentage = 150.0 // Invalid

        // When
        viewModel.updateSplitAllocation(allocation)

        // Then
        XCTAssertNotNil(viewModel.errorMessage, "Should have error message")
        XCTAssertEqual(viewModel.errorMessage, "Invalid percentage value")
    }

    func testDeleteSplitAllocation() throws {
        // Given
        let allocation = SplitAllocation.create(in: managedObjectContext, percentage: 25.0, taxCategory: "Business", lineItem: testLineItem)
        try managedObjectContext.save()
        viewModel.splitAllocations = [allocation]

        // When
        viewModel.deleteSplitAllocation(allocation)

        // Then
        XCTAssertNil(viewModel.errorMessage, "Should not have error message")
    }

    func testFetchSplitAllocations() throws {
        // Given
        let allocation1 = SplitAllocation.create(in: managedObjectContext, percentage: 30.0, taxCategory: "Business", lineItem: testLineItem)
        let allocation2 = SplitAllocation.create(in: managedObjectContext, percentage: 40.0, taxCategory: "Personal", lineItem: testLineItem)
        try managedObjectContext.save()

        // When
        viewModel.fetchSplitAllocations(for: testLineItem)

        // Then
        XCTAssertEqual(viewModel.splitAllocations.count, 2, "Should fetch all allocations")
        XCTAssertTrue(viewModel.splitAllocations.contains(allocation1), "Should contain first allocation")
        XCTAssertTrue(viewModel.splitAllocations.contains(allocation2), "Should contain second allocation")
    }

    // MARK: - Validation Tests

    func testValidateNewSplitAllocation_Valid() throws {
        // Given
        viewModel.newSplitPercentage = 25.0

        // When
        let isValid = viewModel.validateNewSplitAllocation()

        // Then
        XCTAssertTrue(isValid, "Should be valid")
        XCTAssertNil(viewModel.errorMessage, "Should not have error message")
    }

    func testValidateNewSplitAllocation_Invalid() throws {
        // Given
        viewModel.newSplitPercentage = 150.0

        // When
        let isValid = viewModel.validateNewSplitAllocation()

        // Then
        XCTAssertFalse(isValid, "Should be invalid")
        XCTAssertNotNil(viewModel.errorMessage, "Should have error message")
    }

    func testValidatePercentage() throws {
        // Given
        let validPercentages = [0.01, 25.0, 50.0, 100.0]
        let invalidPercentages = [0.0, -10.0, 150.0]

        // When/Then
        for percentage in validPercentages {
            XCTAssertTrue(viewModel.validatePercentage(percentage), "\(percentage) should be valid")
        }

        for percentage in invalidPercentages {
            XCTAssertFalse(viewModel.validatePercentage(percentage), "\(percentage) should be invalid")
        }
    }

    func testValidateLineItemSplitTotal_NoAllocations() throws {
        // When
        let isValid = viewModel.validateLineItemSplitTotal(for: testLineItem)

        // Then
        XCTAssertTrue(isValid, "No allocations should be valid")
    }

    // MARK: - Category Management Tests

    func testAddCustomTaxCategory_Success() throws {
        // Given
        let categoryName = "Custom Category"

        // When
        viewModel.addCustomTaxCategory(categoryName)

        // Then
        XCTAssertEqual(viewModel.customCategories.count, 1, "Should add custom category")
        XCTAssertTrue(viewModel.customCategories.contains("Custom Category"), "Should contain new category")
        XCTAssertNil(viewModel.errorMessage, "Should not have error message")
    }

    func testAddCustomTaxCategory_Duplicate() throws {
        // Given
        let categoryName = "Business" // Predefined

        // When
        viewModel.addCustomTaxCategory(categoryName)

        // Then
        XCTAssertEqual(viewModel.customCategories.count, 0, "Should not add duplicate")
        XCTAssertNotNil(viewModel.errorMessage, "Should have error message")
    }

    func testRemoveCustomTaxCategory_Success() throws {
        // Given
        viewModel.customCategories = ["Custom Category"]

        // When
        viewModel.removeCustomTaxCategory("Custom Category")

        // Then
        XCTAssertEqual(viewModel.customCategories.count, 0, "Should remove custom category")
        XCTAssertNil(viewModel.errorMessage, "Should not have error message")
    }

    func testRemoveCustomTaxCategory_Predefined() throws {
        // Given
        let categoryName = "Business" // Predefined

        // When
        viewModel.removeCustomTaxCategory(categoryName)

        // Then
        XCTAssertNotNil(viewModel.errorMessage, "Should have error message")
        XCTAssertTrue(viewModel.errorMessage?.contains("Cannot remove predefined") == true, "Error should mention predefined")
    }

    // MARK: - Quick Split Tests

    func testApplyQuickSplit_FiftyFifty() throws {
        // When
        viewModel.applyQuickSplit(.fiftyFifty, primaryCategory: "Business", secondaryCategory: "Personal", to: testLineItem)

        // Then
        XCTAssertNil(viewModel.errorMessage, "Should not have error message")
        XCTAssertEqual(viewModel.splitAllocations.count, 2, "Should create two allocations")

        let businessAllocations = viewModel.splitAllocations.filter { $0.taxCategory == "Business" }
        let personalAllocations = viewModel.splitAllocations.filter { $0.taxCategory == "Personal" }

        XCTAssertEqual(businessAllocations.count, 1, "Should have one business allocation")
        XCTAssertEqual(personalAllocations.count, 1, "Should have one personal allocation")
        XCTAssertEqual(businessAllocations.first?.percentage, 50.0, "Business should be 50%")
        XCTAssertEqual(personalAllocations.first?.percentage, 50.0, "Personal should be 50%")
    }

    func testApplyQuickSplit_SeventyThirty() throws {
        // When
        viewModel.applyQuickSplit(.seventyThirty, primaryCategory: "Business", secondaryCategory: "Personal", to: testLineItem)

        // Then
        XCTAssertNil(viewModel.errorMessage, "Should not have error message")
        XCTAssertEqual(viewModel.splitAllocations.count, 2, "Should create two allocations")

        let businessAllocations = viewModel.splitAllocations.filter { $0.taxCategory == "Business" }
        let personalAllocations = viewModel.splitAllocations.filter { $0.taxCategory == "Personal" }

        XCTAssertEqual(businessAllocations.first?.percentage, 70.0, "Business should be 70%")
        XCTAssertEqual(personalAllocations.first?.percentage, 30.0, "Personal should be 30%")
    }

    func testClearAllSplits() throws {
        // Given
        let allocation1 = SplitAllocation.create(in: managedObjectContext, percentage: 30.0, taxCategory: "Business", lineItem: testLineItem)
        let allocation2 = SplitAllocation.create(in: managedObjectContext, percentage: 40.0, taxCategory: "Personal", lineItem: testLineItem)
        try managedObjectContext.save()
        viewModel.fetchSplitAllocations(for: testLineItem)

        // When
        viewModel.clearAllSplits(for: testLineItem)

        // Then
        XCTAssertEqual(viewModel.splitAllocations.count, 0, "Should clear all allocations")
        XCTAssertNil(viewModel.errorMessage, "Should not have error message")
    }

    // MARK: - Formatting Tests

    func testFormatPercentage() throws {
        // Given
        let percentage = 33.3333

        // When
        let formatted = viewModel.formatPercentage(percentage)

        // Then
        XCTAssertEqual(formatted, "33.33%")
    }

    func testCalculateAmount() throws {
        // Given
        let percentage = 25.0
        // Line item: 2 * $50 = $100

        // When
        let amount = viewModel.calculateAmount(for: percentage, of: testLineItem)

        // Then
        XCTAssertEqual(amount, 25.0, accuracy: 0.01, "25% of $100 should be $25")
    }

    func testFormatCurrency() throws {
        // Given
        let amount = 123.45

        // When
        let formatted = viewModel.formatCurrency(amount)

        // Then
        XCTAssertEqual(formatted, "$123.45")
    }
}