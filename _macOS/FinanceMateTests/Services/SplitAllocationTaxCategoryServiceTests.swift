import XCTest
@testable import FinanceMate

final class SplitAllocationTaxCategoryServiceTests: XCTestCase {

    var taxCategoryService: SplitAllocationTaxCategoryService!

    override func setUpWithError() throws {
        taxCategoryService = SplitAllocationTaxCategoryService()
    }

    override func tearDownWithError() throws {
        taxCategoryService = nil
    }

    // MARK: - Predefined Categories Tests

    func testPredefinedCategories() throws {
        // When
        let categories = SplitAllocationTaxCategoryService.predefinedCategories

        // Then
        XCTAssertFalse(categories.isEmpty, "Predefined categories should not be empty")
        XCTAssertTrue(categories.contains("Business"), "Should contain Business category")
        XCTAssertTrue(categories.contains("Personal"), "Should contain Personal category")
        XCTAssertTrue(categories.contains("Investment"), "Should contain Investment category")
        XCTAssertEqual(categories.count, 10, "Should have exactly 10 predefined categories")
    }

    // MARK: - Available Categories Tests

    func testGetAllAvailableCategories_NoCustom() throws {
        // Given
        let customCategories: [String] = []

        // When
        let allCategories = taxCategoryService.getAllAvailableCategories(customCategories: customCategories)

        // Then
        XCTAssertEqual(allCategories.count, 10, "Should have 10 predefined categories")
        XCTAssertTrue(allCategories.contains("Business"), "Should contain Business category")
    }

    func testGetAllAvailableCategories_WithCustom() throws {
        // Given
        let customCategories = ["Custom Category 1", "Custom Category 2"]

        // When
        let allCategories = taxCategoryService.getAllAvailableCategories(customCategories: customCategories)

        // Then
        XCTAssertEqual(allCategories.count, 12, "Should have 10 predefined + 2 custom categories")
        XCTAssertTrue(allCategories.contains("Business"), "Should contain Business category")
        XCTAssertTrue(allCategories.contains("Custom Category 1"), "Should contain custom category")
        XCTAssertTrue(allCategories.contains("Custom Category 2"), "Should contain custom category")
    }

    func testGetAllAvailableCategories_SortsCustomCategories() throws {
        // Given
        let customCategories = ["Z Category", "A Category", "M Category"]

        // When
        let allCategories = taxCategoryService.getAllAvailableCategories(customCategories: customCategories)

        // Then
        let customPart = allCategories.filter { !SplitAllocationTaxCategoryService.predefinedCategories.contains($0) }
        XCTAssertEqual(customPart, ["A Category", "M Category", "Z Category"], "Custom categories should be sorted alphabetically")
    }

    // MARK: - Category Name Validation Tests

    func testIsValidCategoryName_ValidNames() throws {
        // Given
        let validNames = ["Business", "Personal Travel", "Investment Property", "A", "A very long category name that is still valid"]

        for name in validNames {
            // When
            let result = taxCategoryService.isValidCategoryName(name)

            // Then
            XCTAssertTrue(result, "Category name '\(name)' should be valid")
        }
    }

    func testIsValidCategoryName_InvalidNames() throws {
        // Given
        let invalidNames = ["", "   ", "A", "A very long category name that exceeds the fifty character limit and should be invalid"]

        for name in invalidNames {
            // When
            let result = taxCategoryService.isValidCategoryName(name)

            // Then
            XCTAssertFalse(result, "Category name '\(name)' should be invalid")
        }
    }

    func testPrepareCategoryName_ValidInput() throws {
        // Given
        let input = "  Valid Category Name  "

        // When
        let result = taxCategoryService.prepareCategoryName(input)

        // Then
        XCTAssertEqual(result, "Valid Category Name", "Should trim whitespace")
    }

    func testPrepareCategoryName_InvalidInput() throws {
        // Given
        let input = "  "

        // When
        let result = taxCategoryService.prepareCategoryName(input)

        // Then
        XCTAssertNil(result, "Should return nil for invalid input")
    }

    // MARK: - Category Existence Tests

    func testCategoryExists_PredefinedCategory() throws {
        // Given
        let categoryName = "Business"
        let customCategories: [String] = []

        // When
        let exists = taxCategoryService.categoryExists(categoryName, in: customCategories)

        // Then
        XCTAssertTrue(exists, "Business should exist as predefined category")
    }

    func testCategoryExists_CustomCategory() throws {
        // Given
        let categoryName = "Custom Category"
        let customCategories = ["Custom Category", "Another Custom"]

        // When
        let exists = taxCategoryService.categoryExists(categoryName, in: customCategories)

        // Then
        XCTAssertTrue(exists, "Custom Category should exist in custom categories")
    }

    func testCategoryExists_NonExistentCategory() throws {
        // Given
        let categoryName = "Non Existent Category"
        let customCategories = ["Custom Category", "Another Custom"]

        // When
        let exists = taxCategoryService.categoryExists(categoryName, in: customCategories)

        // Then
        XCTAssertFalse(exists, "Non-existent category should not exist")
    }

    func testCategoryExists_HandlesWhitespace() throws {
        // Given
        let categoryName = "  Business  "
        let customCategories: [String] = []

        // When
        let exists = taxCategoryService.categoryExists(categoryName, in: customCategories)

        // Then
        XCTAssertTrue(exists, "Should handle whitespace in category name")
    }

    // MARK: - Add Custom Category Tests

    func testAddCustomCategory_ValidNewCategory() throws {
        // Given
        let categoryName = "New Custom Category"
        let customCategories: [String] = []

        // When
        let result = taxCategoryService.addCustomCategory(categoryName, to: customCategories)

        // Then
        XCTAssertTrue(result.isSuccess, "Should successfully add new category")
        XCTAssertEqual(result.categories?.count, 1, "Should have 1 custom category")
        XCTAssertTrue(result.categories?.contains("New Custom Category") == true, "Should contain new category")
    }

    func testAddCustomCategory_DuplicateCategory() throws {
        // Given
        let categoryName = "Business" // Predefined category
        let customCategories = ["Custom Category"]

        // When
        let result = taxCategoryService.addCustomCategory(categoryName, to: customCategories)

        // Then
        XCTAssertFalse(result.isSuccess, "Should fail to add duplicate category")
        XCTAssertNotNil(result.errorMessage, "Should have error message")
        XCTAssertTrue(result.errorMessage?.contains("already exists") == true, "Error should mention duplicate")
    }

    func testAddCustomCategory_InvalidName() throws {
        // Given
        let categoryName = "A" // Too short
        let customCategories: [String] = []

        // When
        let result = taxCategoryService.addCustomCategory(categoryName, to: customCategories)

        // Then
        XCTAssertFalse(result.isSuccess, "Should fail to add invalid category")
        XCTAssertNotNil(result.errorMessage, "Should have error message")
    }

    func testAddCustomCategory_HandlesWhitespace() throws {
        // Given
        let categoryName = "  Valid Category  "
        let customCategories: [String] = []

        // When
        let result = taxCategoryService.addCustomCategory(categoryName, to: customCategories)

        // Then
        XCTAssertTrue(result.isSuccess, "Should successfully add trimmed category")
        XCTAssertTrue(result.categories?.contains("Valid Category") == true, "Should contain trimmed category")
    }

    // MARK: - Remove Custom Category Tests

    func testRemoveCustomCategory_ValidCustomCategory() throws {
        // Given
        let categoryName = "Custom Category"
        let customCategories = ["Custom Category", "Another Custom"]

        // When
        let result = taxCategoryService.removeCustomCategory(categoryName, from: customCategories)

        // Then
        XCTAssertTrue(result.isSuccess, "Should successfully remove custom category")
        XCTAssertEqual(result.categories?.count, 1, "Should have 1 remaining category")
        XCTAssertFalse(result.categories?.contains("Custom Category") == true, "Should not contain removed category")
    }

    func testRemoveCustomCategory_PredefinedCategory() throws {
        // Given
        let categoryName = "Business" // Predefined category
        let customCategories = ["Custom Category"]

        // When
        let result = taxCategoryService.removeCustomCategory(categoryName, from: customCategories)

        // Then
        XCTAssertFalse(result.isSuccess, "Should fail to remove predefined category")
        XCTAssertNotNil(result.errorMessage, "Should have error message")
        XCTAssertTrue(result.errorMessage?.contains("Cannot remove predefined") == true, "Error should mention predefined")
    }

    func testRemoveCustomCategory_NonExistentCategory() throws {
        // Given
        let categoryName = "Non Existent Category"
        let customCategories = ["Custom Category"]

        // When
        let result = taxCategoryService.removeCustomCategory(categoryName, from: customCategories)

        // Then
        XCTAssertFalse(result.isSuccess, "Should fail to remove non-existent category")
        XCTAssertNotNil(result.errorMessage, "Should have error message")
        XCTAssertTrue(result.errorMessage?.contains("not found") == true, "Error should mention not found")
    }

    func testRemoveCustomCategory_EmptyName() throws {
        // Given
        let categoryName = ""
        let customCategories = ["Custom Category"]

        // When
        let result = taxCategoryService.removeCustomCategory(categoryName, from: customCategories)

        // Then
        XCTAssertFalse(result.isSuccess, "Should fail to remove empty category")
        XCTAssertNotNil(result.errorMessage, "Should have error message")
    }

    func testRemoveCustomCategory_HandlesWhitespace() throws {
        // Given
        let categoryName = "  Custom Category  "
        let customCategories = ["Custom Category", "Another Custom"]

        // When
        let result = taxCategoryService.removeCustomCategory(categoryName, from: customCategories)

        // Then
        XCTAssertTrue(result.isSuccess, "Should successfully remove trimmed category")
        XCTAssertFalse(result.categories?.contains("Custom Category") == true, "Should not contain removed category")
    }
}