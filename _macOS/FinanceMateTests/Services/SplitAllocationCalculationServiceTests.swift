import XCTest
import CoreData
@testable import FinanceMate

final class SplitAllocationCalculationServiceTests: XCTestCase {

    var calculationService: SplitAllocationCalculationService!
    var persistentContainer: NSPersistentContainer!
    var managedObjectContext: NSManagedObjectContext!
    var testLineItem: LineItem!

    override func setUpWithError() throws {
        calculationService = SplitAllocationCalculationService()

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
    }

    override func tearDownWithError() throws {
        managedObjectContext = nil
        persistentContainer = nil
        calculationService = nil
        testLineItem = nil
    }

    // MARK: - Allocated Amount Calculation Tests

    func testCalculateAllocatedAmount_SimpleCase() throws {
        // Given
        let percentage = 25.0
        // Line item: 2 * $50 = $100

        // When
        let allocatedAmount = calculationService.calculateAllocatedAmount(for: percentage, of: testLineItem)

        // Then
        XCTAssertEqual(allocatedAmount, 25.0, accuracy: 0.01, "25% of $100 should be $25")
    }

    func testCalculateAllocatedAmount_HundredPercent() throws {
        // Given
        let percentage = 100.0
        // Line item: 2 * $50 = $100

        // When
        let allocatedAmount = calculationService.calculateAllocatedAmount(for: percentage, of: testLineItem)

        // Then
        XCTAssertEqual(allocatedAmount, 100.0, accuracy: 0.01, "100% of $100 should be $100")
    }

    func testCalculateAllocatedAmount_ZeroPercent() throws {
        // Given
        let percentage = 0.0
        // Line item: 2 * $50 = $100

        // When
        let allocatedAmount = calculationService.calculateAllocatedAmount(for: percentage, of: testLineItem)

        // Then
        XCTAssertEqual(allocatedAmount, 0.0, accuracy: 0.01, "0% of $100 should be $0")
    }

    func testCalculateAllocatedAmount_DifferentLineItem() throws {
        // Given
        let percentage = 50.0
        testLineItem.quantity = 3
        testLineItem.price = 75.0
        // Line item: 3 * $75 = $225
        try managedObjectContext.save()

        // When
        let allocatedAmount = calculationService.calculateAllocatedAmount(for: percentage, of: testLineItem)

        // Then
        XCTAssertEqual(allocatedAmount, 112.5, accuracy: 0.01, "50% of $225 should be $112.50")
    }

    // MARK: - Percentage Formatting Tests

    func testFormatPercentage_WholeNumber() throws {
        // Given
        let percentage = 50.0

        // When
        let formatted = calculationService.formatPercentage(percentage)

        // Then
        XCTAssertEqual(formatted, "50.00%")
    }

    func testFormatPercentage_WithDecimals() throws {
        // Given
        let percentage = 33.3333

        // When
        let formatted = calculationService.formatPercentage(percentage)

        // Then
        XCTAssertEqual(formatted, "33.33%")
    }

    func testFormatPercentage_Zero() throws {
        // Given
        let percentage = 0.0

        // When
        let formatted = calculationService.formatPercentage(percentage)

        // Then
        XCTAssertEqual(formatted, "0.00%")
    }

    func testFormatPercentage_Hundred() throws {
        // Given
        let percentage = 100.0

        // When
        let formatted = calculationService.formatPercentage(percentage)

        // Then
        XCTAssertEqual(formatted, "100.00%")
    }

    // MARK: - Currency Formatting Tests

    func testFormatCurrency_WholeAmount() throws {
        // Given
        let amount = 100.0

        // When
        let formatted = calculationService.formatCurrency(amount)

        // Then
        XCTAssertEqual(formatted, "$100.00")
    }

    func testFormatCurrency_WithCents() throws {
        // Given
        let amount = 123.45

        // When
        let formatted = calculationService.formatCurrency(amount)

        // Then
        XCTAssertEqual(formatted, "$123.45")
    }

    func testFormatCurrency_Zero() throws {
        // Given
        let amount = 0.0

        // When
        let formatted = calculationService.formatCurrency(amount)

        // Then
        XCTAssertEqual(formatted, "$0.00")
    }

    func testFormatCurrency_LargeAmount() throws {
        // Given
        let amount = 1234567.89

        // When
        let formatted = calculationService.formatCurrency(amount)

        // Then
        XCTAssertEqual(formatted, "$1,234,567.89")
    }

    // MARK: - Total Percentage Calculation Tests

    func testCalculateTotalPercentage_EmptyArray() throws {
        // Given
        let allocations: [SplitAllocation] = []

        // When
        let total = calculationService.calculateTotalPercentage(from: allocations)

        // Then
        XCTAssertEqual(total, 0.0, accuracy: 0.01, "Empty array should total 0%")
    }

    func testCalculateTotalPercentage_SingleAllocation() throws {
        // Given
        let allocation = SplitAllocation.create(in: managedObjectContext, percentage: 75.0, taxCategory: "Business", lineItem: testLineItem)
        let allocations = [allocation]

        // When
        let total = calculationService.calculateTotalPercentage(from: allocations)

        // Then
        XCTAssertEqual(total, 75.0, accuracy: 0.01, "Single allocation should total its percentage")
    }

    func testCalculateTotalPercentage_MultipleAllocations() throws {
        // Given
        let allocation1 = SplitAllocation.create(in: managedObjectContext, percentage: 60.0, taxCategory: "Business", lineItem: testLineItem)
        let allocation2 = SplitAllocation.create(in: managedObjectContext, percentage: 40.0, taxCategory: "Personal", lineItem: testLineItem)
        let allocations = [allocation1, allocation2]

        // When
        let total = calculationService.calculateTotalPercentage(from: allocations)

        // Then
        XCTAssertEqual(total, 100.0, accuracy: 0.01, "Multiple allocations should sum correctly")
    }

    // MARK: - Remaining Percentage Calculation Tests

    func testCalculateRemainingPercentage_EmptyAllocations() throws {
        // Given
        let allocations: [SplitAllocation] = []

        // When
        let remaining = calculationService.calculateRemainingPercentage(for: allocations)

        // Then
        XCTAssertEqual(remaining, 100.0, accuracy: 0.01, "Empty allocations should have 100% remaining")
    }

    func testCalculateRemainingPercentage_PartialAllocations() throws {
        // Given
        let allocation1 = SplitAllocation.create(in: managedObjectContext, percentage: 30.0, taxCategory: "Business", lineItem: testLineItem)
        let allocation2 = SplitAllocation.create(in: managedObjectContext, percentage: 20.0, taxCategory: "Personal", lineItem: testLineItem)
        let allocations = [allocation1, allocation2]

        // When
        let remaining = calculationService.calculateRemainingPercentage(for: allocations)

        // Then
        XCTAssertEqual(remaining, 50.0, accuracy: 0.01, "50% allocated should leave 50% remaining")
    }

    func testCalculateRemainingPercentage_CompleteAllocations() throws {
        // Given
        let allocation1 = SplitAllocation.create(in: managedObjectContext, percentage: 70.0, taxCategory: "Business", lineItem: testLineItem)
        let allocation2 = SplitAllocation.create(in: managedObjectContext, percentage: 30.0, taxCategory: "Personal", lineItem: testLineItem)
        let allocations = [allocation1, allocation2]

        // When
        let remaining = calculationService.calculateRemainingPercentage(for: allocations)

        // Then
        XCTAssertEqual(remaining, 0.0, accuracy: 0.01, "Complete allocations should have 0% remaining")
    }

    // MARK: - Line Item Split Total Validation Tests

    func testValidateLineItemSplitTotal_NoAllocations() throws {
        // Given
        // testLineItem has no allocations

        // When
        let isValid = calculationService.validateLineItemSplitTotal(for: testLineItem)

        // Then
        XCTAssertTrue(isValid, "Line item with no allocations should be valid")
    }

    func testValidateLineItemSplitTotal_CompleteSplit() throws {
        // Given
        let allocation1 = SplitAllocation.create(in: managedObjectContext, percentage: 60.0, taxCategory: "Business", lineItem: testLineItem)
        let allocation2 = SplitAllocation.create(in: managedObjectContext, percentage: 40.0, taxCategory: "Personal", lineItem: testLineItem)
        try managedObjectContext.save()

        // When
        let isValid = calculationService.validateLineItemSplitTotal(for: testLineItem)

        // Then
        XCTAssertTrue(isValid, "Complete split should be valid")
    }

    func testValidateLineItemSplitTotal_IncompleteSplit() throws {
        // Given
        let allocation1 = SplitAllocation.create(in: managedObjectContext, percentage: 60.0, taxCategory: "Business", lineItem: testLineItem)
        try managedObjectContext.save()

        // When
        let isValid = calculationService.validateLineItemSplitTotal(for: testLineItem)

        // Then
        XCTAssertFalse(isValid, "Incomplete split should be invalid")
    }

    // MARK: - Category Breakdown Calculation Tests

    func testCalculateCategoryBreakdown_SingleCategory() throws {
        // Given
        let allocation1 = SplitAllocation.create(in: managedObjectContext, percentage: 50.0, taxCategory: "Business", lineItem: testLineItem)
        let allocation2 = SplitAllocation.create(in: managedObjectContext, percentage: 25.0, taxCategory: "Business", lineItem: testLineItem)
        let allocations = [allocation1, allocation2]

        // When
        let breakdown = calculationService.calculateCategoryBreakdown(from: allocations)

        // Then
        XCTAssertEqual(breakdown.count, 1, "Should have 1 category")
        XCTAssertEqual(breakdown["Business"], 75.0, accuracy: 0.01, "Business should total 75% of line item")
    }

    func testCalculateCategoryBreakdown_MultipleCategories() throws {
        // Given
        let allocation1 = SplitAllocation.create(in: managedObjectContext, percentage: 60.0, taxCategory: "Business", lineItem: testLineItem)
        let allocation2 = SplitAllocation.create(in: managedObjectContext, percentage: 40.0, taxCategory: "Personal", lineItem: testLineItem)
        let allocations = [allocation1, allocation2]

        // When
        let breakdown = calculationService.calculateCategoryBreakdown(from: allocations)

        // Then
        XCTAssertEqual(breakdown.count, 2, "Should have 2 categories")
        XCTAssertEqual(breakdown["Business"], 60.0, accuracy: 0.01, "Business should be 60% of line item")
        XCTAssertEqual(breakdown["Personal"], 40.0, accuracy: 0.01, "Personal should be 40% of line item")
    }

    func testCalculateCategoryBreakdown_EmptyAllocations() throws {
        // Given
        let allocations: [SplitAllocation] = []

        // When
        let breakdown = calculationService.calculateCategoryBreakdown(from: allocations)

        // Then
        XCTAssertTrue(breakdown.isEmpty, "Empty allocations should produce empty breakdown")
    }
}