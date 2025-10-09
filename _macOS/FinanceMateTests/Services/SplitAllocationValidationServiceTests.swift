import XCTest
import CoreData
@testable import FinanceMate

final class SplitAllocationValidationServiceTests: XCTestCase {

    var validationService: SplitAllocationValidationService!
    var persistentContainer: NSPersistentContainer!
    var managedObjectContext: NSManagedObjectContext!
    var testLineItem: LineItem!

    override func setUpWithError() throws {
        validationService = SplitAllocationValidationService()

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
        testLineItem.quantity = 1
        testLineItem.price = 100.0
        testLineItem.taxCategory = "Personal"

        try managedObjectContext.save()
    }

    override func tearDownWithError() throws {
        managedObjectContext = nil
        persistentContainer = nil
        validationService = nil
        testLineItem = nil
    }

    // MARK: - Percentage Validation Tests

    func testValidatePercentage_ValidRange() throws {
        // Given
        let validPercentages = [0.01, 25.0, 50.0, 75.0, 99.9, 100.0]

        for percentage in validPercentages {
            // When
            let result = validationService.validatePercentage(percentage)

            // Then
            XCTAssertTrue(result, "Percentage \(percentage) should be valid")
        }
    }

    func testValidatePercentage_InvalidRange() throws {
        // Given
        let invalidPercentages = [-10.0, -0.1, 0.0, 100.1, 150.0]

        for percentage in invalidPercentages {
            // When
            let result = validationService.validatePercentage(percentage)

            // Then
            XCTAssertFalse(result, "Percentage \(percentage) should be invalid")
        }
    }

    // MARK: - Total Percentage Validation Tests

    func testValidateTotalPercentage_ValidAddition() throws {
        // Given
        let currentTotal = 60.0
        let additionalPercentage = 30.0

        // When
        let result = validationService.validateTotalPercentage(currentTotal: currentTotal, adding: additionalPercentage)

        // Then
        XCTAssertTrue(result, "Adding 30% to 60% should be valid")
    }

    func testValidateTotalPercentage_Exceeds100() throws {
        // Given
        let currentTotal = 80.0
        let additionalPercentage = 25.0

        // When
        let result = validationService.validateTotalPercentage(currentTotal: currentTotal, adding: additionalPercentage)

        // Then
        XCTAssertFalse(result, "Adding 25% to 80% should be invalid")
    }

    func testValidateTotalPercentage_Exact100() throws {
        // Given
        let currentTotal = 70.0
        let additionalPercentage = 30.0

        // When
        let result = validationService.validateTotalPercentage(currentTotal: currentTotal, adding: additionalPercentage)

        // Then
        XCTAssertTrue(result, "Adding 30% to 70% should be valid")
    }

    // MARK: - Split Total Validation Tests

    func testIsValidSplitTotal_EmptySplit() throws {
        // Given
        let total = 0.0

        // When
        let result = validationService.isValidSplitTotal(total)

        // Then
        XCTAssertTrue(result, "Empty split (0%) should be valid")
    }

    func testIsValidSplitTotal_Perfect100() throws {
        // Given
        let total = 100.0

        // When
        let result = validationService.isValidSplitTotal(total)

        // Then
        XCTAssertTrue(result, "Perfect 100% split should be valid")
    }

    func testIsValidSplitTotal_CloseTo100() throws {
        // Given
        let total = 99.99

        // When
        let result = validationService.isValidSplitTotal(total)

        // Then
        XCTAssertTrue(result, "99.99% split should be valid within tolerance")
    }

    func testIsValidSplitTotal_IncompleteSplit() throws {
        // Given
        let total = 75.0

        // When
        let result = validationService.isValidSplitTotal(total)

        // Then
        XCTAssertFalse(result, "75% split should be invalid")
    }

    func testIsValidSplitTotal_Exceeds100() throws {
        // Given
        let total = 101.0

        // When
        let result = validationService.isValidSplitTotal(total)

        // Then
        XCTAssertFalse(result, "101% split should be invalid")
    }

    // MARK: - Remaining Percentage Calculation Tests

    func testCalculateRemainingPercentage_FromZero() throws {
        // Given
        let currentTotal = 0.0

        // When
        let remaining = validationService.calculateRemainingPercentage(from: currentTotal)

        // Then
        XCTAssertEqual(remaining, 100.0, "Remaining should be 100% from zero")
    }

    func testCalculateRemainingPercentage_FromPartial() throws {
        // Given
        let currentTotal = 30.0

        // When
        let remaining = validationService.calculateRemainingPercentage(from: currentTotal)

        // Then
        XCTAssertEqual(remaining, 70.0, "Remaining should be 70% from 30%")
    }

    func testCalculateRemainingPercentage_FromComplete() throws {
        // Given
        let currentTotal = 100.0

        // When
        let remaining = validationService.calculateRemainingPercentage(from: currentTotal)

        // Then
        XCTAssertEqual(remaining, 0.0, "Remaining should be 0% from 100%")
    }

    // MARK: - Split Allocation Validation Tests

    func testValidateSplitAllocations_ValidEmpty() throws {
        // Given
        let allocations: [SplitAllocation] = []

        // When
        let result = validationService.validateSplitAllocations(allocations)

        // Then
        XCTAssertTrue(result, "Empty allocations should be valid")
    }

    func testValidateSplitAllocations_ValidComplete() throws {
        // Given
        let allocation1 = SplitAllocation.create(in: managedObjectContext, percentage: 60.0, taxCategory: "Business", lineItem: testLineItem)
        let allocation2 = SplitAllocation.create(in: managedObjectContext, percentage: 40.0, taxCategory: "Personal", lineItem: testLineItem)
        let allocations = [allocation1, allocation2]

        // When
        let result = validationService.validateSplitAllocations(allocations)

        // Then
        XCTAssertTrue(result, "Complete 100% split should be valid")
    }

    func testValidateSplitAllocations_InvalidIncomplete() throws {
        // Given
        let allocation1 = SplitAllocation.create(in: managedObjectContext, percentage: 60.0, taxCategory: "Business", lineItem: testLineItem)
        let allocations = [allocation1]

        // When
        let result = validationService.validateSplitAllocations(allocations)

        // Then
        XCTAssertFalse(result, "Incomplete 60% split should be invalid")
    }

    // MARK: - New Split Allocation Validation Tests

    func testValidateNewSplitAllocation_ValidAddition() throws {
        // Given
        let existingAllocation = SplitAllocation.create(in: managedObjectContext, percentage: 50.0, taxCategory: "Business", lineItem: testLineItem)
        let existingAllocations = [existingAllocation]
        let newPercentage = 30.0

        // When
        let result = validationService.validateNewSplitAllocation(existingAllocations: existingAllocations, newPercentage: newPercentage)

        // Then
        XCTAssertTrue(result.isValid, "Adding 30% to existing 50% should be valid")
        XCTAssertNil(result.errorMessage, "Should not have error message for valid addition")
    }

    func testValidateNewSplitAllocation_InvalidPercentage() throws {
        // Given
        let existingAllocations: [SplitAllocation] = []
        let newPercentage = 150.0

        // When
        let result = validationService.validateNewSplitAllocation(existingAllocations: existingAllocations, newPercentage: newPercentage)

        // Then
        XCTAssertFalse(result.isValid, "150% should be invalid")
        XCTAssertNotNil(result.errorMessage, "Should have error message for invalid percentage")
        XCTAssertEqual(result.errorMessage, "Percentage must be between 0.01% and 100%")
    }

    func testValidateNewSplitAllocation_ExceedsTotal() throws {
        // Given
        let existingAllocation = SplitAllocation.create(in: managedObjectContext, percentage: 80.0, taxCategory: "Business", lineItem: testLineItem)
        let existingAllocations = [existingAllocation]
        let newPercentage = 30.0

        // When
        let result = validationService.validateNewSplitAllocation(existingAllocations: existingAllocations, newPercentage: newPercentage)

        // Then
        XCTAssertFalse(result.isValid, "Adding 30% to existing 80% should be invalid")
        XCTAssertNotNil(result.errorMessage, "Should have error message for exceeding total")
        XCTAssertTrue(result.errorMessage!.contains("exceed 100%"))
    }
}