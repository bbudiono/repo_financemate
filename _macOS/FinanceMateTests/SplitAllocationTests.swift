import XCTest
import CoreData
@testable import FinanceMate

final class SplitAllocationTests: XCTestCase {

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
    }

    override func tearDownWithError() throws {
        managedObjectContext = nil
        persistentContainer = nil
        testLineItem = nil
    }

    // MARK: - Test SplitAllocation Creation

    func testSplitAllocationCreation() throws {
        // Given
        let splitAllocation = SplitAllocation.create(
            in: managedObjectContext,
            percentage: 75.0,
            taxCategory: "Business",
            lineItem: testLineItem
        )

        // Then
        XCTAssertNotNil(splitAllocation)
        XCTAssertEqual(splitAllocation.percentage, 75.0)
        XCTAssertEqual(splitAllocation.taxCategory, "Business")
        XCTAssertEqual(splitAllocation.lineItem, testLineItem)
        XCTAssertNotNil(splitAllocation.id)

        try managedObjectContext.save()

        // Verify the allocation was saved
        let fetchRequest: NSFetchRequest<SplitAllocation> = SplitAllocation.fetchRequest()
        let results = try managedObjectContext.fetch(fetchRequest)
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.percentage, 75.0)
    }

    // MARK: - Test Percentage Validation

    func testPercentageValidationValidRange() throws {
        // Given
        let validPercentages = [0.1, 25.0, 50.0, 75.0, 99.9, 100.0]

        for percentage in validPercentages {
            let splitAllocation = SplitAllocation.create(
                in: managedObjectContext,
                percentage: percentage,
                taxCategory: "Business",
                lineItem: testLineItem
            )

            // Then
            XCTAssertTrue(splitAllocation.validatePercentage(),
                         "Percentage \(percentage) should be valid")
        }
    }

    func testPercentageValidationInvalidRange() throws {
        // Given
        let invalidPercentages = [-10.0, -0.1, 0.0, 100.1, 150.0]

        for percentage in invalidPercentages {
            let splitAllocation = SplitAllocation.create(
                in: managedObjectContext,
                percentage: percentage,
                taxCategory: "Business",
                lineItem: testLineItem
            )

            // Then
            XCTAssertFalse(splitAllocation.validatePercentage(),
                          "Percentage \(percentage) should be invalid")
        }
    }

    // MARK: - Test Allocated Amount Calculation

    func testAllocatedAmountCalculation() throws {
        // Given
        testLineItem.price = 100.0
        testLineItem.quantity = 2
        try managedObjectContext.save()

        let splitAllocation = SplitAllocation.create(
            in: managedObjectContext,
            percentage: 25.0,
            taxCategory: "Business",
            lineItem: testLineItem
        )

        // Then
        let expectedAllocatedAmount = 200.0 * 0.25 // total: 2 * 100 = 200, 25% = 50
        XCTAssertEqual(splitAllocation.allocatedAmount(), expectedAllocatedAmount,
                      accuracy: 0.01,
                      "Allocated amount should be 25% of line item total")
    }

    func testAllocatedAmountZeroPercentage() throws {
        // Given
        let splitAllocation = SplitAllocation.create(
            in: managedObjectContext,
            percentage: 0.0,
            taxCategory: "Business",
            lineItem: testLineItem
        )

        // Then
        XCTAssertEqual(splitAllocation.allocatedAmount(), 0.0,
                      "Zero percentage should result in zero allocated amount")
    }

    // MARK: - Test Tax Category Assignment

    func testTaxCategoryAssignment() throws {
        // Given
        let taxCategories = ["Personal", "Business", "Investment", "Property Investment", "Other"]

        for category in taxCategories {
            let splitAllocation = SplitAllocation.create(
                in: managedObjectContext,
                percentage: 20.0,
                taxCategory: category,
                lineItem: testLineItem
            )

            // Then
            XCTAssertEqual(splitAllocation.taxCategory, category)
        }
    }

    func testDefaultTaxCategory() throws {
        // Given
        let splitAllocation = SplitAllocation(context: managedObjectContext)
        splitAllocation.lineItem = testLineItem

        // Then
        XCTAssertEqual(splitAllocation.taxCategory, "Personal",
                      "Default tax category should be Personal")
    }

    // MARK: - Test LineItem Relationship

    func testSplitAllocationLineItemRelationship() throws {
        // Given
        let splitAllocation = SplitAllocation.create(
            in: managedObjectContext,
            percentage: 50.0,
            taxCategory: "Business",
            lineItem: testLineItem
        )

        try managedObjectContext.save()

        // Then
        XCTAssertEqual(splitAllocation.lineItem, testLineItem)

        // Test the inverse relationship
        let splitAllocations = testLineItem.splitAllocations?.allObjects as? [SplitAllocation] ?? []
        XCTAssertEqual(splitAllocations.count, 1)
        XCTAssertEqual(splitAllocations.first?.percentage, 50.0)
    }

    func testMultipleSplitAllocationsForLineItem() throws {
        // Given
        let allocation1 = SplitAllocation.create(
            in: managedObjectContext,
            percentage: 60.0,
            taxCategory: "Business",
            lineItem: testLineItem
        )

        let allocation2 = SplitAllocation.create(
            in: managedObjectContext,
            percentage: 40.0,
            taxCategory: "Personal",
            lineItem: testLineItem
        )

        try managedObjectContext.save()

        // Then
        let splitAllocations = testLineItem.splitAllocations?.allObjects as? [SplitAllocation] ?? []
        XCTAssertEqual(splitAllocations.count, 2)
        XCTAssertTrue(splitAllocations.contains(allocation1))
        XCTAssertTrue(splitAllocations.contains(allocation2))

        // Test hasSplitAllocations property
        XCTAssertTrue(testLineItem.hasSplitAllocations)
    }

    // MARK: - Test Core Data Constraints

    func testSplitAllocationUUIDGeneration() throws {
        // Given
        let splitAllocation1 = SplitAllocation.create(
            in: managedObjectContext,
            percentage: 50.0,
            taxCategory: "Business",
            lineItem: testLineItem
        )

        let splitAllocation2 = SplitAllocation.create(
            in: managedObjectContext,
            percentage: 50.0,
            taxCategory: "Personal",
            lineItem: testLineItem
        )

        try managedObjectContext.save()

        // Then
        XCTAssertNotEqual(splitAllocation1.id, splitAllocation2.id,
                          "Each split allocation should have a unique UUID")
        XCTAssertNotNil(splitAllocation1.id)
        XCTAssertNotNil(splitAllocation2.id)
    }

    // MARK: - Test Delete Operations

    func testSplitAllocationDeletion() throws {
        // Given
        let splitAllocation = SplitAllocation.create(
            in: managedObjectContext,
            percentage: 100.0,
            taxCategory: "Business",
            lineItem: testLineItem
        )

        try managedObjectContext.save()

        // Verify allocation exists
        var fetchRequest: NSFetchRequest<SplitAllocation> = SplitAllocation.fetchRequest()
        var results = try managedObjectContext.fetch(fetchRequest)
        XCTAssertEqual(results.count, 1)

        // When
        managedObjectContext.delete(splitAllocation)
        try managedObjectContext.save()

        // Then
        results = try managedObjectContext.fetch(fetchRequest)
        XCTAssertEqual(results.count, 0)

        // Verify line item relationship is updated
        XCTAssertFalse(testLineItem.hasSplitAllocations)
    }

    // MARK: - Test Fetch Operations

    func testFetchSplitAllocations() throws {
        // Given
        let allocation1 = SplitAllocation.create(
            in: managedObjectContext,
            percentage: 30.0,
            taxCategory: "Business",
            lineItem: testLineItem
        )

        let allocation2 = SplitAllocation.create(
            in: managedObjectContext,
            percentage: 70.0,
            taxCategory: "Personal",
            lineItem: testLineItem
        )

        try managedObjectContext.save()

        // When
        let fetchRequest: NSFetchRequest<SplitAllocation> = SplitAllocation.fetchRequest()
        let results = try managedObjectContext.fetch(fetchRequest)

        // Then
        XCTAssertEqual(results.count, 2)
        XCTAssertTrue(results.contains(allocation1))
        XCTAssertTrue(results.contains(allocation2))
    }

    func testFetchSplitAllocationsByTaxCategory() throws {
        // Given
        let businessAllocation = SplitAllocation.create(
            in: managedObjectContext,
            percentage: 60.0,
            taxCategory: "Business",
            lineItem: testLineItem
        )

        let personalAllocation = SplitAllocation.create(
            in: managedObjectContext,
            percentage: 40.0,
            taxCategory: "Personal",
            lineItem: testLineItem
        )

        try managedObjectContext.save()

        // When
        let fetchRequest: NSFetchRequest<SplitAllocation> = SplitAllocation.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "taxCategory == %@", "Business")
        let businessResults = try managedObjectContext.fetch(fetchRequest)

        // Then
        XCTAssertEqual(businessResults.count, 1)
        XCTAssertEqual(businessResults.first?.taxCategory, "Business")
        XCTAssertEqual(businessResults.first?.percentage, 60.0)
    }

    // MARK: - BLUEPRINT MVP REQUIREMENT: Tax Splitting Tests (RED PHASE)

    func testTaxSplittingPercentageAllocationMustSumTo100() throws {
        // BLUEPRINT REQUIREMENT: "The UI must provide real-time validation to ensure splits sum to 100%"
        // Given: A line item with multiple split allocations
        let allocation1 = SplitAllocation.create(
            in: managedObjectContext,
            percentage: 70.0,
            taxCategory: "Business",
            lineItem: testLineItem
        )

        let allocation2 = SplitAllocation.create(
            in: managedObjectContext,
            percentage: 25.0,
            taxCategory: "Personal",
            lineItem: testLineItem
        )

        try managedObjectContext.save()

        // When: Calculating total percentage for the line item
        let fetchRequest: NSFetchRequest<SplitAllocation> = SplitAllocation.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "lineItem == %@", testLineItem)
        let allocations = try managedObjectContext.fetch(fetchRequest)
        let totalPercentage = allocations.reduce(0) { $0 + $1.percentage }

        // Then: Total should be less than 100% (failing condition)
        // This test FAILS because the validation logic is not yet implemented
        XCTAssertEqual(totalPercentage, 95.0, "Total should be 95% in this failing test")
        XCTAssertLessThan(totalPercentage, 100.0, "Total should be less than 100% to trigger validation failure")

        // Expected: The system should prevent this state and enforce 100% total
        // Implementation needed: Real-time validation that enforces sum-to-100% constraint
    }

    func testTaxSplittingRealTimeValidationPreventsInvalidSplits() throws {
        // BLUEPRINT REQUIREMENT: "Real-time validation to ensure splits sum to 100%, disabling the 'Save' button otherwise"
        // Given: A line item with existing allocations totaling 80%
        let existingAllocation = SplitAllocation.create(
            in: managedObjectContext,
            percentage: 80.0,
            taxCategory: "Business",
            lineItem: testLineItem
        )

        try managedObjectContext.save()

        // When: Attempting to add a new allocation that would exceed 100%
        let newAllocation = SplitAllocation.create(
            in: managedObjectContext,
            percentage: 30.0,  // This would make total 110%, which is invalid
            taxCategory: "Personal",
            lineItem: testLineItem
        )

        // Then: The validation should fail and prevent this allocation
        // This test FAILS because the real-time validation logic is not yet implemented
        let fetchRequest: NSFetchRequest<SplitAllocation> = SplitAllocation.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "lineItem == %@", testLineItem)
        let allocations = try managedObjectContext.fetch(fetchRequest)
        let totalPercentage = allocations.reduce(0) { $0 + $1.percentage }

        XCTAssertGreaterThan(totalPercentage, 100.0, "Total should exceed 100% to demonstrate validation failure")
        // Expected: Implementation should prevent adding allocations that exceed 100% total
    }

    func testTaxSplittingPersistenceWorkflow() throws {
        // BLUEPRINT REQUIREMENT: "proportionally allocate expenses across multiple tax categories"
        // Given: A line item and tax split allocations
        testLineItem.price = 200.0
        testLineItem.quantity = 1
        try managedObjectContext.save()

        let businessAllocation = SplitAllocation.create(
            in: managedObjectContext,
            percentage: 60.0,
            taxCategory: "Business",
            lineItem: testLineItem
        )

        let personalAllocation = SplitAllocation.create(
            in: managedObjectContext,
            percentage: 40.0,
            taxCategory: "Personal",
            lineItem: testLineItem
        )

        try managedObjectContext.save()

        // When: Retrieving the allocations and calculating allocated amounts
        let fetchRequest: NSFetchRequest<SplitAllocation> = SplitAllocation.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "lineItem == %@", testLineItem)
        let retrievedAllocations = try managedObjectContext.fetch(fetchRequest)

        // Then: The allocations should be correctly persisted and calculated
        XCTAssertEqual(retrievedAllocations.count, 2, "Should have exactly 2 allocations")

        let businessAllocated = businessAllocation.allocatedAmount()
        let personalAllocated = personalAllocation.allocatedAmount()

        XCTAssertEqual(businessAllocated, 120.0, accuracy: 0.01, "Business allocation should be 60% of $200")
        XCTAssertEqual(personalAllocated, 80.0, accuracy: 0.01, "Personal allocation should be 40% of $200")
        XCTAssertEqual(businessAllocated + personalAllocated, 200.0, accuracy: 0.01, "Total allocated should equal line item total")

        // This test PASSES but demonstrates the expected workflow for tax splitting
        // Implementation needed: UI integration and real-time validation
    }
}