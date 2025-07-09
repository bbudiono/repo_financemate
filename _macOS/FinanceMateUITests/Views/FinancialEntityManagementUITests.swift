//
// FinancialEntityManagementUITests.swift
// FinanceMateUITests
//
// Purpose: UI tests for FinancialEntityManagementView covering CRUD operations and hierarchy management
// Issues & Complexity Summary: Comprehensive UI testing for entity management with hierarchy visualization
// Key Complexity Drivers:
//   - Logic Scope (Est. LoC): ~200
//   - Core Algorithm Complexity: Medium
//   - Dependencies: XCTest, XCUITest, FinancialEntityViewModel
//   - State Management Complexity: Medium
//   - Novelty/Uncertainty Factor: Low
// AI Pre-Task Self-Assessment: 80%
// Problem Estimate: 75%
// Initial Code Complexity Estimate: 70%
// Final Code Complexity: TBD
// Overall Result Score: TBD
// Key Variances/Learnings: TBD
// Last Updated: 2025-07-09

import XCTest
@testable import FinanceMate

final class FinancialEntityManagementUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Entity Management Navigation Tests
    
    func testEntityManagementViewAppears() throws {
        // Given: Main app is launched
        // When: User navigates to entity management
        let settingsTab = app.buttons["Settings"]
        settingsTab.tap()
        
        let entityManagementButton = app.buttons["Manage Entities"]
        entityManagementButton.tap()
        
        // Then: Entity management view should appear
        let entityManagementView = app.otherElements["EntityManagementView"]
        XCTAssertTrue(entityManagementView.exists)
        
        // And: Navigation title should be correct
        let navigationTitle = app.staticTexts["Financial Entities"]
        XCTAssertTrue(navigationTitle.exists)
    }
    
    func testEntityListDisplaysExistingEntities() throws {
        // Given: Entity management view is open
        navigateToEntityManagement()
        
        // When: View loads
        let entityList = app.collectionViews["EntityList"]
        XCTAssertTrue(entityList.exists)
        
        // Then: Should show at least default entities
        let personalEntity = entityList.cells.containing(.staticText, identifier: "Personal").element
        XCTAssertTrue(personalEntity.exists)
    }
    
    // MARK: - Entity Creation Tests
    
    func testCreateNewEntityFlow() throws {
        // Given: Entity management view is open
        navigateToEntityManagement()
        
        // When: User taps create button
        let createButton = app.buttons["Create Entity"]
        createButton.tap()
        
        // Then: Create entity sheet should appear
        let createSheet = app.sheets["CreateEntitySheet"]
        XCTAssertTrue(createSheet.exists)
        
        // And: Form fields should be present
        let nameField = createSheet.textFields["Entity Name"]
        XCTAssertTrue(nameField.exists)
        
        let typeSelector = createSheet.buttons["Entity Type"]
        XCTAssertTrue(typeSelector.exists)
        
        let saveButton = createSheet.buttons["Save"]
        XCTAssertTrue(saveButton.exists)
        
        let cancelButton = createSheet.buttons["Cancel"]
        XCTAssertTrue(cancelButton.exists)
    }
    
    func testCreateEntityWithValidData() throws {
        // Given: Create entity sheet is open
        navigateToEntityManagement()
        app.buttons["Create Entity"].tap()
        
        // When: User enters valid entity data
        let nameField = app.textFields["Entity Name"]
        nameField.tap()
        nameField.typeText("My Business")
        
        let typeSelector = app.buttons["Entity Type"]
        typeSelector.tap()
        let businessType = app.buttons["Business"]
        businessType.tap()
        
        let saveButton = app.buttons["Save"]
        saveButton.tap()
        
        // Then: Entity should be created and sheet should close
        let createSheet = app.sheets["CreateEntitySheet"]
        XCTAssertFalse(createSheet.exists)
        
        // And: New entity should appear in list
        let entityList = app.collectionViews["EntityList"]
        let newEntity = entityList.cells.containing(.staticText, identifier: "My Business").element
        XCTAssertTrue(newEntity.exists)
    }
    
    func testCreateEntityWithEmptyName() throws {
        // Given: Create entity sheet is open
        navigateToEntityManagement()
        app.buttons["Create Entity"].tap()
        
        // When: User tries to save with empty name
        let saveButton = app.buttons["Save"]
        saveButton.tap()
        
        // Then: Error message should appear
        let errorMessage = app.staticTexts["Entity name cannot be empty"]
        XCTAssertTrue(errorMessage.exists)
        
        // And: Sheet should remain open
        let createSheet = app.sheets["CreateEntitySheet"]
        XCTAssertTrue(createSheet.exists)
    }
    
    // MARK: - Entity Editing Tests
    
    func testEditEntityFlow() throws {
        // Given: Entity management view with existing entity
        navigateToEntityManagement()
        
        // When: User taps edit button on an entity
        let entityList = app.collectionViews["EntityList"]
        let personalEntity = entityList.cells.containing(.staticText, identifier: "Personal").element
        personalEntity.tap()
        
        let editButton = app.buttons["Edit Entity"]
        editButton.tap()
        
        // Then: Edit sheet should appear with current data
        let editSheet = app.sheets["EditEntitySheet"]
        XCTAssertTrue(editSheet.exists)
        
        let nameField = editSheet.textFields["Entity Name"]
        XCTAssertTrue(nameField.exists)
        XCTAssertEqual(nameField.value as? String, "Personal")
    }
    
    func testEditEntitySaveChanges() throws {
        // Given: Edit entity sheet is open
        navigateToEntityManagement()
        let entityList = app.collectionViews["EntityList"]
        let personalEntity = entityList.cells.containing(.staticText, identifier: "Personal").element
        personalEntity.tap()
        app.buttons["Edit Entity"].tap()
        
        // When: User modifies entity name
        let nameField = app.textFields["Entity Name"]
        nameField.tap()
        nameField.clearText()
        nameField.typeText("Personal Finance")
        
        let saveButton = app.buttons["Save"]
        saveButton.tap()
        
        // Then: Changes should be saved and sheet should close
        let editSheet = app.sheets["EditEntitySheet"]
        XCTAssertFalse(editSheet.exists)
        
        // And: Updated entity should appear in list
        let updatedEntity = entityList.cells.containing(.staticText, identifier: "Personal Finance").element
        XCTAssertTrue(updatedEntity.exists)
    }
    
    // MARK: - Entity Deletion Tests
    
    func testDeleteEntityFlow() throws {
        // Given: Entity management view with existing entity
        navigateToEntityManagement()
        
        // When: User attempts to delete an entity
        let entityList = app.collectionViews["EntityList"]
        let personalEntity = entityList.cells.containing(.staticText, identifier: "Personal").element
        personalEntity.tap()
        
        let deleteButton = app.buttons["Delete Entity"]
        deleteButton.tap()
        
        // Then: Confirmation dialog should appear
        let confirmationDialog = app.alerts["Confirm Delete"]
        XCTAssertTrue(confirmationDialog.exists)
        
        let confirmButton = confirmationDialog.buttons["Delete"]
        XCTAssertTrue(confirmButton.exists)
        
        let cancelButton = confirmationDialog.buttons["Cancel"]
        XCTAssertTrue(cancelButton.exists)
    }
    
    func testDeleteEntityConfirmation() throws {
        // Given: Delete confirmation dialog is shown
        navigateToEntityManagement()
        let entityList = app.collectionViews["EntityList"]
        let personalEntity = entityList.cells.containing(.staticText, identifier: "Personal").element
        personalEntity.tap()
        app.buttons["Delete Entity"].tap()
        
        // When: User confirms deletion
        let confirmButton = app.alerts["Confirm Delete"].buttons["Delete"]
        confirmButton.tap()
        
        // Then: Entity should be removed from list
        let deletedEntity = entityList.cells.containing(.staticText, identifier: "Personal").element
        XCTAssertFalse(deletedEntity.exists)
    }
    
    // MARK: - Hierarchy Management Tests
    
    func testEntityHierarchyVisualization() throws {
        // Given: Entity management view with parent and child entities
        navigateToEntityManagement()
        
        // When: View displays entities with hierarchy
        let entityList = app.collectionViews["EntityList"]
        
        // Then: Parent entities should be visually distinguished
        let parentEntity = entityList.cells.containing(.image, identifier: "ParentEntityIcon").element
        XCTAssertTrue(parentEntity.exists)
        
        // And: Child entities should be indented
        let childEntity = entityList.cells.containing(.image, identifier: "ChildEntityIcon").element
        XCTAssertTrue(childEntity.exists)
    }
    
    func testCreateChildEntity() throws {
        // Given: Entity management view with parent entity
        navigateToEntityManagement()
        
        // When: User creates a child entity
        let entityList = app.collectionViews["EntityList"]
        let parentEntity = entityList.cells.containing(.staticText, identifier: "Personal").element
        parentEntity.tap()
        
        let addChildButton = app.buttons["Add Child Entity"]
        addChildButton.tap()
        
        // Then: Create child entity sheet should appear
        let createSheet = app.sheets["CreateEntitySheet"]
        XCTAssertTrue(createSheet.exists)
        
        // And: Parent entity should be pre-selected
        let parentSelector = createSheet.buttons["Parent Entity"]
        XCTAssertTrue(parentSelector.exists)
        XCTAssertEqual(parentSelector.label, "Personal")
    }
    
    // MARK: - Entity Type Tests
    
    func testEntityTypeSelection() throws {
        // Given: Create entity sheet is open
        navigateToEntityManagement()
        app.buttons["Create Entity"].tap()
        
        // When: User taps entity type selector
        let typeSelector = app.buttons["Entity Type"]
        typeSelector.tap()
        
        // Then: All entity types should be available
        let personalType = app.buttons["Personal"]
        XCTAssertTrue(personalType.exists)
        
        let businessType = app.buttons["Business"]
        XCTAssertTrue(businessType.exists)
        
        let trustType = app.buttons["Trust"]
        XCTAssertTrue(trustType.exists)
        
        let investmentType = app.buttons["Investment"]
        XCTAssertTrue(investmentType.exists)
    }
    
    func testEntityTypeIconDisplay() throws {
        // Given: Entity management view with different entity types
        navigateToEntityManagement()
        
        // When: View displays entities
        let entityList = app.collectionViews["EntityList"]
        
        // Then: Each entity type should have distinctive icon
        let personalIcon = entityList.images["PersonalEntityIcon"]
        XCTAssertTrue(personalIcon.exists)
        
        let businessIcon = entityList.images["BusinessEntityIcon"]
        XCTAssertTrue(businessIcon.exists)
    }
    
    // MARK: - Search and Filter Tests
    
    func testEntitySearch() throws {
        // Given: Entity management view with multiple entities
        navigateToEntityManagement()
        
        // When: User searches for entities
        let searchField = app.searchFields["Search Entities"]
        searchField.tap()
        searchField.typeText("Personal")
        
        // Then: Only matching entities should be shown
        let entityList = app.collectionViews["EntityList"]
        let matchingEntity = entityList.cells.containing(.staticText, identifier: "Personal").element
        XCTAssertTrue(matchingEntity.exists)
    }
    
    // MARK: - Accessibility Tests
    
    func testAccessibilityLabels() throws {
        // Given: Entity management view is open
        navigateToEntityManagement()
        
        // When: VoiceOver is enabled
        app.activate()
        
        // Then: All elements should have proper accessibility labels
        let createButton = app.buttons["Create Entity"]
        XCTAssertTrue(createButton.isAccessibilityElement)
        XCTAssertEqual(createButton.accessibilityLabel, "Create new financial entity")
        
        let entityList = app.collectionViews["EntityList"]
        XCTAssertTrue(entityList.isAccessibilityElement)
        XCTAssertEqual(entityList.accessibilityLabel, "Financial entities list")
    }
    
    // MARK: - Performance Tests
    
    func testEntityListPerformance() throws {
        // Given: Entity management view
        navigateToEntityManagement()
        
        // When: Loading entity list with multiple entities
        measure {
            let entityList = app.collectionViews["EntityList"]
            let _ = entityList.cells.count
        }
        
        // Then: Performance should be acceptable
    }
    
    // MARK: - Helper Methods
    
    private func navigateToEntityManagement() {
        let settingsTab = app.buttons["Settings"]
        settingsTab.tap()
        
        let entityManagementButton = app.buttons["Manage Entities"]
        entityManagementButton.tap()
    }
}

// MARK: - XCUIElement Extensions

extension XCUIElement {
    func clearText() {
        guard let stringValue = self.value as? String else {
            return
        }
        
        self.tap()
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        self.typeText(deleteString)
    }
}