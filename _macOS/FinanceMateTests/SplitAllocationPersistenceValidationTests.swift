import XCTest
import CoreData
@testable import FinanceMate

/*
 * Purpose: RED PHASE - Failing tests for tax split allocation persistence and data integrity validation
 * BLUEPRINT Requirements: Lines 115-126 - Core Splitting Functionality with robust data persistence
 * Test Strategy: Atomic TDD - Create failing tests first, then implement minimal code to pass
 *
 * Critical Success Criteria:
 * - Validate Core Data relationships maintain data integrity
 * - Test tax splitting calculations with real percentage allocations
 * - Ensure transaction CRUD operations don't corrupt split allocations
 * - Validate that 100% sum validation prevents invalid states
 * - Verify visual indicators accuracy and real-time updates
 */

final class SplitAllocationPersistenceValidationTests: XCTestCase {

    var persistentContainer: NSPersistentContainer!
    var managedObjectContext: NSManagedObjectContext!
    var testTransaction: Transaction!
    var testLineItem: LineItem!
    var validationService: SplitAllocationValidationService!
    var calculationService: SplitAllocationCalculationService!

    override func setUpWithError() throws {
        // Create in-memory Core Data stack for atomic testing
        persistentContainer = NSPersistentContainer(name: "FinanceMate", managedObjectModel: PersistenceController.createModel())
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        persistentContainer.persistentStoreDescriptions = [description]

        persistentContainer.loadPersistentStores { _, error in
            XCTAssertNil(error, "Failed to load test store: \(error?.localizedDescription ?? "Unknown error")")
        }

        managedObjectContext = persistentContainer.viewContext

        // Initialize services
        validationService = SplitAllocationValidationService()
        calculationService = SplitAllocationCalculationService()

        // Create test transaction with line item
        testTransaction = Transaction(context: managedObjectContext)
        testTransaction.id = UUID()
        testTransaction.date = Date()
        testTransaction.merchant = "Test Merchant"
        testTransaction.totalAmount = 300.0

        testLineItem = LineItem(context: managedObjectContext)
        testLineItem.id = UUID()
        testLineItem.itemDescription = "Test Service"
        testLineItem.quantity = 1
        testLineItem.price = 300.0
        testLineItem.transaction = testTransaction

        try managedObjectContext.save()
    }

    override func tearDownWithError() throws {
        managedObjectContext = nil
        persistentContainer = nil
        testTransaction = nil
        testLineItem = nil
        validationService = nil
        calculationService = nil
    }

    // MARK: - RED TEST 1: 100% Sum Validation Enforcement

    func testTaxSplitAllocationMustEnforce100PercentSum_ValidationFails() throws {
        // BLUEPRINT REQUIREMENT: "The UI must provide real-time validation to ensure splits sum to 100%"
        // This test is designed to FAIL until proper validation logic is implemented

        // Given: A line item with split allocations that DON'T sum to 100%
        let allocation1 = SplitAllocation.create(
            in: managedObjectContext,
            percentage: 70.0,
            taxCategory: "Business",
            lineItem: testLineItem
        )

        let allocation2 = SplitAllocation.create(
            in: managedObjectContext,
            percentage: 25.0,  // Only 95% total - this should fail validation
            taxCategory: "Personal",
            lineItem: testLineItem
        )

        try managedObjectContext.save()

        // When: Validating the split allocations
        let allocations = [allocation1, allocation2]
        let validationResult = validationService.validateSplitAllocations(allocations)

        // Then: Validation should FAIL because total is not 100%
        // THIS ASSERTION IS EXPECTED TO FAIL - RED PHASE
        XCTAssertFalse(validationResult,
                       "Split allocations totaling 95% should fail validation - ENFORCEMENT NEEDED")

        let totalPercentage = calculationService.calculateTotalPercentage(from: allocations)
        XCTAssertNotEqual(totalPercentage, 100.0,
                          accuracy: 0.01,
                          "Total percentage should not equal 100% to trigger validation failure")

        // Expected implementation: Real-time validation that prevents invalid split states
        // Status:  RED - VALIDATION LOGIC MISSING
    }

    // MARK: - RED TEST 2: Persistence Integrity Through CRUD Operations

    func testTaxSplitPersistenceIntegrityThroughCRUD_OperationsCorruptData() throws {
        // BLUEPRINT REQUIREMENT: Robust data persistence for tax allocations
        // This test is designed to FAIL until CRUD integrity is properly implemented

        // Given: A line item with valid split allocations totaling 100%
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

        // When: Performing CRUD operations on the parent transaction
        // Update transaction merchant (this should not affect split allocations)
        testTransaction.merchant = "Updated Merchant Name"

        // Add a new line item to the transaction (should not affect existing splits)
        let newLineItem = LineItem(context: managedObjectContext)
        newLineItem.id = UUID()
        newLineItem.itemDescription = "Additional Service"
        newLineItem.quantity = 1
        newLineItem.price = 100.0
        newLineItem.transaction = testTransaction

        try managedObjectContext.save()

        // Then: Split allocations should maintain integrity
        let fetchRequest: NSFetchRequest<SplitAllocation> = SplitAllocation.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "lineItem == %@", testLineItem)
        let retrievedAllocations = try managedObjectContext.fetch(fetchRequest)

        // THIS ASSERTION IS EXPECTED TO FAIL - RED PHASE
        XCTAssertEqual(retrievedAllocations.count, 2,
                      "Split allocations should be preserved during transaction updates")

        // Verify percentage integrity is maintained
        let totalPercentage = calculationService.calculateTotalPercentage(from: retrievedAllocations)
        XCTAssertEqual(totalPercentage, 100.0,
                      accuracy: 0.01,
                      "Total percentage should remain 100% after CRUD operations")

        // Verify calculated amounts remain accurate
        let businessAmount = calculationService.calculateAllocatedAmount(for: 60.0, of: testLineItem)
        let personalAmount = calculationService.calculateAllocatedAmount(for: 40.0, of: testLineItem)

        XCTAssertEqual(businessAmount, 180.0, accuracy: 0.01, "Business allocation should remain $180")
        XCTAssertEqual(personalAmount, 120.0, accuracy: 0.01, "Personal allocation should remain $120")

        // Expected implementation: CRUD operations that preserve split allocation data integrity
        // Status:  RED - CRUD INTEGRITY VALIDATION MISSING
    }

    // MARK: - RED TEST 3: Calculation Accuracy with Real Percentage Allocations

    func testTaxSplitCalculationAccuracyWithRealData_IncorrectResults() throws {
        // BLUEPRINT REQUIREMENT: "proportionally allocate expenses across multiple tax categories"
        // This test is designed to FAIL until calculation accuracy is properly implemented

        // Given: Complex real-world scenario with multiple line items and split allocations
        testLineItem.price = 450.50  // Real-world price with cents
        testLineItem.quantity = 2     // Multiple quantities

        let businessAllocation = SplitAllocation.create(
            in: managedObjectContext,
            percentage: 75.0,
            taxCategory: "Business",
            lineItem: testLineItem
        )

        let investmentAllocation = SplitAllocation.create(
            in: managedObjectContext,
            percentage: 25.0,
            taxCategory: "Investment",
            lineItem: testLineItem
        )

        try managedObjectContext.save()

        // When: Calculating allocated amounts with real-world precision
        let lineItemTotal = Double(testLineItem.quantity) * testLineItem.price
        let businessAllocated = calculationService.calculateAllocatedAmount(for: 75.0, of: testLineItem)
        let investmentAllocated = calculationService.calculateAllocatedAmount(for: 25.0, of: testLineItem)
        let totalAllocated = businessAllocated + investmentAllocated

        // Then: Calculations should be precise to the cent
        let expectedBusinessAmount = 450.50 * 2.0 * 0.75  // $675.75
        let expectedInvestmentAmount = 450.50 * 2.0 * 0.25 // $225.25
        let expectedTotal = expectedBusinessAmount + expectedInvestmentAmount // $901.00

        // THESE ASSERTIONS ARE EXPECTED TO FAIL - RED PHASE
        XCTAssertEqual(businessAllocated, expectedBusinessAmount,
                      accuracy: 0.01,
                      "Business allocation calculation should be precise to cents")

        XCTAssertEqual(investmentAllocated, expectedInvestmentAmount,
                      accuracy: 0.01,
                      "Investment allocation calculation should be precise to cents")

        XCTAssertEqual(totalAllocated, lineItemTotal,
                      accuracy: 0.01,
                      "Total allocated should exactly match line item total")

        // Test category breakdown accuracy
        let allocations = [businessAllocation, investmentAllocation]
        let categoryBreakdown = calculationService.calculateCategoryBreakdown(from: allocations)

        XCTAssertEqual(categoryBreakdown["Business"], expectedBusinessAmount,
                      accuracy: 0.01,
                      "Category breakdown should show correct business amount")

        XCTAssertEqual(categoryBreakdown["Investment"], expectedInvestmentAmount,
                      accuracy: 0.01,
                      "Category breakdown should show correct investment amount")

        // Expected implementation: Precise floating-point arithmetic for tax calculations
        // Status:  RED - CALCULATION ACCURACY VALIDATION MISSING
    }

    // MARK: - RED TEST 4: Visual Indicators and Real-Time Updates

    func testTaxSplitVisualIndicatorsAndRealTimeUpdates_NoVisualFeedback() throws {
        // BLUEPRINT REQUIREMENT: "A clear visual indicator MUST be present on any transaction row that has been split"
        // This test is designed to FAIL until visual indicators are properly implemented

        // Given: A transaction with split allocations
        let allocation = SplitAllocation.create(
            in: managedObjectContext,
            percentage: 100.0,
            taxCategory: "Business",
            lineItem: testLineItem
        )

        try managedObjectContext.save()

        // When: Checking for visual indicators on the transaction
        // These properties/methods should exist but likely don't yet

        // THIS ASSERTION IS EXPECTED TO FAIL - RED PHASE
        XCTAssertTrue(testTransaction.hasSplitAllocations,
                     "Transaction should indicate it has split allocations")

        XCTAssertEqual(testTransaction.splitAllocationCount, 1,
                     "Transaction should track the number of split allocations")

        // Test visual indicator properties
        XCTAssertNotNil(testTransaction.splitIndicatorDisplay,
                        "Transaction should have visual indicator for split status")

        // When: Modifying split allocations (simulating real-time updates)
        allocation.percentage = 50.0

        let secondAllocation = SplitAllocation.create(
            in: managedObjectContext,
            percentage: 50.0,
            taxCategory: "Personal",
            lineItem: testLineItem
        )

        try managedObjectContext.save()

        // Then: Visual indicators should update in real-time
        XCTAssertEqual(testTransaction.splitAllocationCount, 2,
                     "Split count should update when allocations change")

        XCTAssertTrue(testTransaction.hasValidSplitAllocation,
                     "Transaction should indicate split allocation is valid (100% total)")

        // Expected implementation: Real-time visual indicators that update with split changes
        // Status:  RED - VISUAL INDICATOR SYSTEM MISSING
    }

    // MARK: - RED TEST 5: Tax Category Management and Color Coding

    func testTaxCategoryManagementAndColorCoding_DefaultCategoriesMissing() throws {
        // BLUEPRINT REQUIREMENT: "The system must provide default Australian tax categories (Personal, Business, Investment)"
        // This test is designed to FAIL until tax category management is properly implemented

        // Given: The application should have default tax categories

        // When: Checking for default tax categories
        // This service should exist but likely doesn't yet
        let taxCategoryService = SplitAllocationTaxCategoryService()

        // THESE ASSERTIONS ARE EXPECTED TO FAIL - RED PHASE
        let defaultCategories = taxCategoryService.getDefaultTaxCategories()
        XCTAssertTrue(defaultCategories.contains("Personal"),
                     "Default categories should include 'Personal'")
        XCTAssertTrue(defaultCategories.contains("Business"),
                     "Default categories should include 'Business'")
        XCTAssertTrue(defaultCategories.contains("Investment"),
                     "Default categories should include 'Investment'")

        // Test color coding functionality
        let businessColor = taxCategoryService.getColorForTaxCategory("Business")
        let personalColor = taxCategoryService.getColorForTaxCategory("Personal")
        let investmentColor = taxCategoryService.getColorForTaxCategory("Investment")

        XCTAssertNotNil(businessColor, "Business category should have a color")
        XCTAssertNotNil(personalColor, "Personal category should have a color")
        XCTAssertNotNil(investmentColor, "Investment category should have a color")

        XCTAssertNotEqual(businessColor, personalColor,
                         "Different tax categories should have different colors")

        // Test custom category creation
        let customCategory = "Rental Property"
        let customColor = taxCategoryService.createCustomTaxCategory(customCategory)
        XCTAssertNotNil(customColor, "Should be able to create custom tax categories")

        // Expected implementation: Tax category management with color coding
        // Status:  RED - TAX CATEGORY MANAGEMENT SYSTEM MISSING
    }
}