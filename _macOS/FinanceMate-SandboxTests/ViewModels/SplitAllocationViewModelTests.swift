import XCTest
import CoreData
@testable import FinanceMate

/**
 * SplitAllocationViewModelTests.swift
 * 
 * Purpose: Comprehensive TDD unit tests for SplitAllocationViewModel with real-time percentage validation and tax category management
 * Issues & Complexity Summary: Tests split allocation management, real-time validation, tax categories, and percentage constraint logic
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~600
 *   - Core Algorithm Complexity: High (Real-time percentage validation, split constraint logic)
 *   - Dependencies: 6 (Core Data, XCTest, Combine, Foundation, LineItem/SplitAllocation entities, Tax categories)
 *   - State Management Complexity: High (@Published properties, real-time validation, async operations)
 *   - Novelty/Uncertainty Factor: Medium-High (Complex percentage validation and tax category management)
 * AI Pre-Task Self-Assessment: 85%
 * Problem Estimate: 90%
 * Initial Code Complexity Estimate: 85%
 * Final Code Complexity: TBD
 * Overall Result Score: TBD
 * Key Variances/Learnings: TDD for complex percentage validation with real-time feedback and tax category integration
 * Last Updated: 2025-07-07
 */

// EMERGENCY FIX: Removed to eliminate Swift Concurrency crashes
// COMPREHENSIVE FIX: Removed ALL Swift Concurrency patterns to eliminate TaskLocal crashes
final class SplitAllocationViewModelTests: XCTestCase {
    var viewModel: SplitAllocationViewModel!
    var persistenceController: PersistenceController!
    var context: NSManagedObjectContext!
    var testLineItem: LineItem!
    var testTransaction: Transaction!
    
    override func setUp() {
        super.setUp()
        persistenceController = PersistenceController(inMemory: true)
        context = persistenceController.container.viewContext
        viewModel = SplitAllocationViewModel(context: context)
        
        // Create test transaction and line item
        testTransaction = Transaction.create(in: context, amount: 200.00, category: "Test", note: "Test transaction")
        testLineItem = LineItem.create(in: context, itemDescription: "Test Item", amount: 100.00, transaction: testTransaction)
        try! context.save()
    }
    
    override func tearDown() {
        testLineItem = nil
        testTransaction = nil
        viewModel = nil
        context = nil
        persistenceController = nil
        super.tearDown()
    }
    
    // MARK: - Helper Methods
    
    private func createTestSplitAllocation(percentage: Double, taxCategory: String, lineItem: LineItem? = nil) -> SplitAllocation {
        let targetLineItem = lineItem ?? testLineItem!
        let split = SplitAllocation.create(in: context, percentage: percentage, taxCategory: taxCategory, lineItem: targetLineItem)
        try! context.save()
        return split
    }
    
    private func createMultipleSplits(percentages: [Double], categories: [String], lineItem: LineItem? = nil) -> [SplitAllocation] {
        let targetLineItem = lineItem ?? testLineItem!
        var splits: [SplitAllocation] = []
        
        for (index, percentage) in percentages.enumerated() {
            let category = index < categories.count ? categories[index] : "Default"
            let split = SplitAllocation.create(in: context, percentage: percentage, taxCategory: category, lineItem: targetLineItem)
            splits.append(split)
        }
        
        try! context.save()
        return splits
    }
    
    // MARK: - Initialization Tests
    
    func testViewModelInitialization() {
        // Given: A Core Data context
        // When: Creating a SplitAllocationViewModel
        let newViewModel = SplitAllocationViewModel(context: context)
        
        // Then: The view model should be properly initialized
        XCTAssertNotNil(newViewModel, "SplitAllocationViewModel should be properly initialized")
        XCTAssertEqual(newViewModel.splitAllocations.count, 0, "Initial split allocations array should be empty")
        XCTAssertFalse(newViewModel.isLoading, "Initial loading state should be false")
        XCTAssertNil(newViewModel.errorMessage, "Initial error message should be nil")
        XCTAssertEqual(newViewModel.totalPercentage, 0.0, "Initial total percentage should be zero")
        XCTAssertTrue(newViewModel.isValidSplit, "Initial validation should be true (empty is valid)")
    }
    
    func testInitializationWithPredefinedTaxCategories() {
        // Given: A new view model
        // When: Checking predefined tax categories
        // Then: Should have Australian tax categories
        XCTAssertTrue(viewModel.predefinedCategories.contains("Business"), "Should include Business category")
        XCTAssertTrue(viewModel.predefinedCategories.contains("Personal"), "Should include Personal category")
        XCTAssertTrue(viewModel.predefinedCategories.contains("Investment"), "Should include Investment category")
        XCTAssertTrue(viewModel.predefinedCategories.contains("Charity"), "Should include Charity category")
        XCTAssertGreaterThan(viewModel.predefinedCategories.count, 3, "Should have multiple predefined categories")
    }
    
    // MARK: - CRUD Operation Tests
    
    func testAddSplitAllocationSuccess() {
        // Given: Valid split allocation data
        viewModel.newSplitPercentage = 60.0
        viewModel.selectedTaxCategory = "Business"
        
        // When: Adding a split allocation
        viewModel.addSplitAllocation(to: testLineItem)
        
        // Then: Split allocation should be created successfully
        viewModel.fetchSplitAllocations(for: testLineItem)
        XCTAssertEqual(viewModel.splitAllocations.count, 1, "Should have one split allocation")
        XCTAssertEqual(viewModel.splitAllocations.first?.percentage ?? 0, 60.0, accuracy: 0.01, "Percentage should match")
        XCTAssertEqual(viewModel.splitAllocations.first?.taxCategory, "Business", "Tax category should match")
        XCTAssertEqual(viewModel.totalPercentage, 60.0, accuracy: 0.01, "Total percentage should be updated")
        XCTAssertFalse(viewModel.isLoading, "Loading should be complete")
        XCTAssertNil(viewModel.errorMessage, "Should have no error")
    }
    
    func testAddSplitAllocationValidationFailure() {
        // Given: Invalid split allocation data (negative percentage)
        viewModel.newSplitPercentage = -10.0
        viewModel.selectedTaxCategory = "Business"
        
        // When: Adding a split allocation
        viewModel.addSplitAllocation(to: testLineItem)
        
        // Then: Should fail validation
        XCTAssertNotNil(viewModel.errorMessage, "Should have validation error")
        XCTAssertTrue(viewModel.errorMessage?.contains("percentage") == true, "Error should mention percentage")
        viewModel.fetchSplitAllocations(for: testLineItem)
        XCTAssertEqual(viewModel.splitAllocations.count, 0, "Should have no split allocations")
    }
    
    func testAddSplitAllocationExceedingTotalPercentage() {
        // Given: Existing split allocation at 70%
        _ = createTestSplitAllocation(percentage: 70.0, taxCategory: "Business")
        viewModel.fetchSplitAllocations(for: testLineItem)
        
        // When: Attempting to add another 50% split (total would be 120%)
        viewModel.newSplitPercentage = 50.0
        viewModel.selectedTaxCategory = "Personal"
        viewModel.addSplitAllocation(to: testLineItem)
        
        // Then: Should fail validation for exceeding 100%
        XCTAssertNotNil(viewModel.errorMessage, "Should have validation error")
        XCTAssertTrue(viewModel.errorMessage?.contains("100%") == true, "Error should mention 100% limit")
        XCTAssertEqual(viewModel.splitAllocations.count, 1, "Should still have only one split allocation")
    }
    
    func testUpdateSplitAllocationSuccess() {
        // Given: An existing split allocation
        let splitAllocation = createTestSplitAllocation(percentage: 50.0, taxCategory: "Business")
        viewModel.fetchSplitAllocations(for: testLineItem)
        
        // When: Updating the split allocation
        splitAllocation.percentage = 75.0
        splitAllocation.taxCategory = "Personal"
        viewModel.updateSplitAllocation(splitAllocation)
        
        // Then: Split allocation should be updated
        viewModel.fetchSplitAllocations(for: testLineItem)
        XCTAssertEqual(viewModel.splitAllocations.first?.percentage ?? 0, 75.0, accuracy: 0.01, "Percentage should be updated")
        XCTAssertEqual(viewModel.splitAllocations.first?.taxCategory, "Personal", "Tax category should be updated")
        XCTAssertEqual(viewModel.totalPercentage, 75.0, accuracy: 0.01, "Total percentage should be updated")
        XCTAssertNil(viewModel.errorMessage, "Should have no error")
    }
    
    func testDeleteSplitAllocationSuccess() {
        // Given: An existing split allocation
        let splitAllocation = createTestSplitAllocation(percentage: 40.0, taxCategory: "Investment")
        viewModel.fetchSplitAllocations(for: testLineItem)
        XCTAssertEqual(viewModel.splitAllocations.count, 1, "Should have one split allocation")
        
        // When: Deleting the split allocation
        viewModel.deleteSplitAllocation(splitAllocation)
        
        // Then: Split allocation should be deleted
        viewModel.fetchSplitAllocations(for: testLineItem)
        XCTAssertEqual(viewModel.splitAllocations.count, 0, "Should have no split allocations")
        XCTAssertEqual(viewModel.totalPercentage, 0.0, accuracy: 0.01, "Total percentage should be zero")
        XCTAssertNil(viewModel.errorMessage, "Should have no error")
    }
    
    func testFetchSplitAllocationsForLineItem() {
        // Given: Multiple split allocations for different line items
        let otherLineItem = LineItem.create(in: context, itemDescription: "Other Item", amount: 150.0, transaction: testTransaction)
        try! context.save()
        
        _ = createTestSplitAllocation(percentage: 30.0, taxCategory: "Business", lineItem: testLineItem)
        _ = createTestSplitAllocation(percentage: 70.0, taxCategory: "Personal", lineItem: testLineItem)
        _ = createTestSplitAllocation(percentage: 100.0, taxCategory: "Investment", lineItem: otherLineItem)
        
        // When: Fetching split allocations for test line item
        viewModel.fetchSplitAllocations(for: testLineItem)
        
        // Then: Should only get split allocations for test line item
        XCTAssertEqual(viewModel.splitAllocations.count, 2, "Should have two split allocations for test line item")
        XCTAssertTrue(viewModel.splitAllocations.allSatisfy { $0.lineItem == testLineItem }, "All split allocations should belong to test line item")
        XCTAssertEqual(viewModel.totalPercentage, 100.0, accuracy: 0.01, "Total percentage should be 100%")
    }
    
    // MARK: - Real-Time Percentage Validation Tests
    
    func testRealTimePercentageValidation() {
        // Given: Multiple split allocations
        _ = createMultipleSplits(percentages: [40.0, 35.0], categories: ["Business", "Personal"])
        viewModel.fetchSplitAllocations(for: testLineItem)
        
        // When: Checking real-time validation states
        // Then: Should calculate total percentage and validation correctly
        XCTAssertEqual(viewModel.totalPercentage, 75.0, accuracy: 0.01, "Total percentage should be 75%")
        XCTAssertFalse(viewModel.isValidSplit, "Should be invalid (not 100%)")
        XCTAssertEqual(viewModel.remainingPercentage, 25.0, accuracy: 0.01, "Remaining percentage should be 25%")
    }
    
    func testPerfectSplitValidation() {
        // Given: Split allocations totaling exactly 100%
        _ = createMultipleSplits(percentages: [60.0, 40.0], categories: ["Business", "Personal"])
        viewModel.fetchSplitAllocations(for: testLineItem)
        
        // When: Checking validation
        // Then: Should be perfectly valid
        XCTAssertEqual(viewModel.totalPercentage, 100.0, accuracy: 0.01, "Total percentage should be 100%")
        XCTAssertTrue(viewModel.isValidSplit, "Should be valid (exactly 100%)")
        XCTAssertEqual(viewModel.remainingPercentage, 0.0, accuracy: 0.01, "Remaining percentage should be 0%")
    }
    
    func testExceedingPercentageValidation() {
        // Given: Split allocations exceeding 100%
        _ = createMultipleSplits(percentages: [70.0, 50.0], categories: ["Business", "Personal"])
        viewModel.fetchSplitAllocations(for: testLineItem)
        
        // When: Checking validation
        // Then: Should be invalid (exceeding 100%)
        XCTAssertEqual(viewModel.totalPercentage, 120.0, accuracy: 0.01, "Total percentage should be 120%")
        XCTAssertFalse(viewModel.isValidSplit, "Should be invalid (exceeding 100%)")
        XCTAssertEqual(viewModel.remainingPercentage, -20.0, accuracy: 0.01, "Remaining percentage should be -20%")
    }
    
    func testZeroPercentageValidation() {
        // Given: No split allocations
        viewModel.fetchSplitAllocations(for: testLineItem)
        
        // When: Checking validation
        // Then: Should be valid (empty state)
        XCTAssertEqual(viewModel.totalPercentage, 0.0, accuracy: 0.01, "Total percentage should be 0%")
        XCTAssertTrue(viewModel.isValidSplit, "Should be valid (empty state)")
        XCTAssertEqual(viewModel.remainingPercentage, 100.0, accuracy: 0.01, "Remaining percentage should be 100%")
    }
    
    // MARK: - Individual Percentage Validation Tests
    
    func testValidatePercentagePositive() {
        // Given: Positive percentage
        let isValid = viewModel.validatePercentage(50.0)
        
        // Then: Should be valid
        XCTAssertTrue(isValid, "Positive percentage should be valid")
    }
    
    func testValidatePercentageZero() {
        // Given: Zero percentage
        let isValid = viewModel.validatePercentage(0.0)
        
        // Then: Should be invalid
        XCTAssertFalse(isValid, "Zero percentage should be invalid")
    }
    
    func testValidatePercentageNegative() {
        // Given: Negative percentage
        let isValid = viewModel.validatePercentage(-10.0)
        
        // Then: Should be invalid
        XCTAssertFalse(isValid, "Negative percentage should be invalid")
    }
    
    func testValidatePercentageExceedsMaximum() {
        // Given: Percentage exceeding 100%
        let isValid = viewModel.validatePercentage(150.0)
        
        // Then: Should be invalid
        XCTAssertFalse(isValid, "Percentage exceeding 100% should be invalid")
    }
    
    func testValidatePercentageTwoDecimalPlaces() {
        // Given: Percentage with two decimal places
        let isValid = viewModel.validatePercentage(99.99)
        
        // Then: Should be valid
        XCTAssertTrue(isValid, "Percentage with two decimal places should be valid")
    }
    
    func testValidatePercentageMoreThanTwoDecimalPlaces() {
        // Given: Percentage with more than two decimal places
        let isValid = viewModel.validatePercentage(99.999)
        
        // Then: Should be invalid (assuming validation checks decimal places)
        XCTAssertFalse(isValid, "Percentage with more than two decimal places should be invalid")
    }
    
    // MARK: - Tax Category Management Tests
    
    func testPredefinedTaxCategories() {
        // Given: Fresh view model
        // When: Checking predefined categories
        // Then: Should include Australian tax categories
        let categories = viewModel.predefinedCategories
        
        XCTAssertTrue(categories.contains("Business"), "Should include Business")
        XCTAssertTrue(categories.contains("Personal"), "Should include Personal")
        XCTAssertTrue(categories.contains("Investment"), "Should include Investment")
        XCTAssertTrue(categories.contains("Charity"), "Should include Charity")
        XCTAssertTrue(categories.contains("Education"), "Should include Education")
        XCTAssertGreaterThanOrEqual(categories.count, 5, "Should have at least 5 predefined categories")
    }
    
    func testAddCustomTaxCategory() {
        // Given: A custom tax category name
        let customCategory = "Research & Development"
        
        // When: Adding a custom tax category
        viewModel.addCustomTaxCategory(customCategory)
        
        // Then: Should be added to available categories
        XCTAssertTrue(viewModel.availableTaxCategories.contains(customCategory), "Should include custom category")
        XCTAssertTrue(viewModel.customCategories.contains(customCategory), "Should be in custom categories list")
    }
    
    func testAddDuplicateCustomTaxCategory() {
        // Given: An existing custom category
        let customCategory = "Consulting"
        viewModel.addCustomTaxCategory(customCategory)
        let initialCount = viewModel.customCategories.count
        
        // When: Attempting to add the same category again
        viewModel.addCustomTaxCategory(customCategory)
        
        // Then: Should not create duplicate
        XCTAssertEqual(viewModel.customCategories.count, initialCount, "Should not add duplicate category")
    }
    
    func testRemoveCustomTaxCategory() {
        // Given: An existing custom category
        let customCategory = "Travel"
        viewModel.addCustomTaxCategory(customCategory)
        XCTAssertTrue(viewModel.customCategories.contains(customCategory), "Category should be added")
        
        // When: Removing the custom category
        viewModel.removeCustomTaxCategory(customCategory)
        
        // Then: Should be removed from custom categories
        XCTAssertFalse(viewModel.customCategories.contains(customCategory), "Category should be removed")
        XCTAssertFalse(viewModel.availableTaxCategories.contains(customCategory), "Should not be in available categories")
    }
    
    func testCannotRemovePredefinedTaxCategory() {
        // Given: A predefined tax category
        let predefinedCategory = "Business"
        let initialCount = viewModel.predefinedCategories.count
        
        // When: Attempting to remove predefined category
        viewModel.removeCustomTaxCategory(predefinedCategory)
        
        // Then: Should not be removed
        XCTAssertEqual(viewModel.predefinedCategories.count, initialCount, "Predefined categories should not be affected")
        XCTAssertTrue(viewModel.availableTaxCategories.contains(predefinedCategory), "Predefined category should remain available")
    }
    
    // MARK: - Loading State Tests
    
    func testLoadingStatesDuringAdd() {
        // Given: Valid split allocation data
        viewModel.newSplitPercentage = 50.0
        viewModel.selectedTaxCategory = "Business"
        
        // When: Adding split allocation (check loading state changes)
        let addTask = // EMERGENCY FIX: Removed Task block - immediate execution
// COMPREHENSIVE FIX: Removed ALL Swift Concurrency patterns to eliminate TaskLocal crashes
        viewModel.addSplitAllocation(to: testLineItem)
        
        // Then: Loading state should be managed properly
        addTask.value
        XCTAssertFalse(viewModel.isLoading, "Loading should be false after completion")
    }
    
    // MARK: - Error Handling Tests
    
    func testErrorHandlingInvalidLineItem() {
        // Given: Invalid line item (nil context)
        let invalidLineItem = LineItem(context: context)
        // Don't save to make it invalid
        
        viewModel.newSplitPercentage = 50.0
        viewModel.selectedTaxCategory = "Business"
        
        // When: Adding split allocation to invalid line item
        viewModel.addSplitAllocation(to: invalidLineItem)
        
        // Then: Should handle error gracefully
        XCTAssertNotNil(viewModel.errorMessage, "Should have error message")
        XCTAssertFalse(viewModel.isLoading, "Loading should be false")
    }
    
    func testErrorHandlingEmptyTaxCategory() {
        // Given: Valid percentage but empty tax category
        viewModel.newSplitPercentage = 50.0
        viewModel.selectedTaxCategory = ""
        
        // When: Adding split allocation
        viewModel.addSplitAllocation(to: testLineItem)
        
        // Then: Should fail validation
        XCTAssertNotNil(viewModel.errorMessage, "Should have validation error")
        XCTAssertTrue(viewModel.errorMessage?.contains("category") == true, "Error should mention category")
    }
    
    // MARK: - Split Templates and Quick Actions Tests
    
    func testQuickSplit5050() {
        // Given: Empty line item
        viewModel.fetchSplitAllocations(for: testLineItem)
        
        // When: Applying 50/50 quick split
        viewModel.applyQuickSplit(.fiftyFifty, primaryCategory: "Business", secondaryCategory: "Personal", to: testLineItem)
        
        // Then: Should create two 50% splits
        viewModel.fetchSplitAllocations(for: testLineItem)
        XCTAssertEqual(viewModel.splitAllocations.count, 2, "Should have two split allocations")
        
        let businessSplit = viewModel.splitAllocations.first { $0.taxCategory == "Business" }
        let personalSplit = viewModel.splitAllocations.first { $0.taxCategory == "Personal" }
        
        XCTAssertNotNil(businessSplit, "Should have Business split")
        XCTAssertNotNil(personalSplit, "Should have Personal split")
        XCTAssertEqual(businessSplit?.percentage ?? 0, 50.0, accuracy: 0.01, "Business split should be 50%")
        XCTAssertEqual(personalSplit?.percentage ?? 0, 50.0, accuracy: 0.01, "Personal split should be 50%")
        XCTAssertEqual(viewModel.totalPercentage, 100.0, accuracy: 0.01, "Total should be 100%")
        XCTAssertTrue(viewModel.isValidSplit, "Split should be valid")
    }
    
    func testQuickSplit7030() {
        // Given: Empty line item
        viewModel.fetchSplitAllocations(for: testLineItem)
        
        // When: Applying 70/30 quick split
        viewModel.applyQuickSplit(.seventyThirty, primaryCategory: "Business", secondaryCategory: "Personal", to: testLineItem)
        
        // Then: Should create 70%/30% splits
        viewModel.fetchSplitAllocations(for: testLineItem)
        XCTAssertEqual(viewModel.splitAllocations.count, 2, "Should have two split allocations")
        
        let businessSplit = viewModel.splitAllocations.first { $0.taxCategory == "Business" }
        let personalSplit = viewModel.splitAllocations.first { $0.taxCategory == "Personal" }
        
        XCTAssertEqual(businessSplit?.percentage ?? 0, 70.0, accuracy: 0.01, "Business split should be 70%")
        XCTAssertEqual(personalSplit?.percentage ?? 0, 30.0, accuracy: 0.01, "Personal split should be 30%")
        XCTAssertTrue(viewModel.isValidSplit, "Split should be valid")
    }
    
    func testClearAllSplits() {
        // Given: Multiple existing split allocations
        _ = createMultipleSplits(percentages: [40.0, 35.0, 25.0], categories: ["Business", "Personal", "Investment"])
        viewModel.fetchSplitAllocations(for: testLineItem)
        XCTAssertEqual(viewModel.splitAllocations.count, 3, "Should have three split allocations")
        
        // When: Clearing all splits
        viewModel.clearAllSplits(for: testLineItem)
        
        // Then: Should remove all split allocations
        viewModel.fetchSplitAllocations(for: testLineItem)
        XCTAssertEqual(viewModel.splitAllocations.count, 0, "Should have no split allocations")
        XCTAssertEqual(viewModel.totalPercentage, 0.0, accuracy: 0.01, "Total percentage should be zero")
        XCTAssertTrue(viewModel.isValidSplit, "Empty state should be valid")
    }
    
    // MARK: - Performance Tests
    
    func testPerformanceWithLargeSplitDataset() {
        // Given: Large number of split allocations
        var splitData: [(Double, String)] = []
        for i in 0..<50 {
            splitData.append((2.0, "Category\(i % 10)"))
        }
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // When: Creating many split allocations
        for (percentage, category) in splitData {
            _ = createTestSplitAllocation(percentage: percentage, taxCategory: category)
        }
        
        viewModel.fetchSplitAllocations(for: testLineItem)
        
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        // Then: Should handle large dataset efficiently
        XCTAssertEqual(viewModel.splitAllocations.count, 50, "Should fetch all split allocations")
        XCTAssertLessThan(timeElapsed, 2.0, "Large dataset operations should complete within 2 seconds")
        XCTAssertEqual(viewModel.totalPercentage, 100.0, accuracy: 0.01, "Total percentage should be 100%")
    }
    
    // MARK: - Data Integrity Tests
    
    func testSplitAllocationLineItemRelationship() {
        // Given: A split allocation
        let splitAllocation = createTestSplitAllocation(percentage: 60.0, taxCategory: "Business")
        
        // When: Checking relationship
        // Then: Split allocation should be properly linked to line item
        XCTAssertEqual(splitAllocation.lineItem, testLineItem, "Split allocation should be linked to line item")
        XCTAssertTrue(testLineItem.splitAllocations.contains(splitAllocation), "Line item should contain the split allocation")
    }
    
    func testCascadeDeleteSplitAllocations() {
        // Given: Multiple split allocations for a line item
        _ = createMultipleSplits(percentages: [40.0, 60.0], categories: ["Business", "Personal"])
        viewModel.fetchSplitAllocations(for: testLineItem)
        XCTAssertEqual(viewModel.splitAllocations.count, 2, "Should have two split allocations")
        
        // When: Deleting the line item
        context.delete(testLineItem)
        try! context.save()
        
        // Then: Split allocations should be cascade deleted
        let fetchRequest: NSFetchRequest<SplitAllocation> = SplitAllocation.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "lineItem == %@", testLineItem)
        let remainingSplits = try! context.fetch(fetchRequest)
        
        XCTAssertEqual(remainingSplits.count, 0, "Split allocations should be cascade deleted")
    }
}