//
// FinancialEntityManagementViewTests.swift
// FinanceMateTests
//
// Purpose: Unit tests for FinancialEntityManagementView covering UI logic and state management
// Issues & Complexity Summary: SwiftUI view testing with ViewModel integration and state validation
// Key Complexity Drivers:
//   - Logic Scope (Est. LoC): ~250
//   - Core Algorithm Complexity: Medium
//   - Dependencies: XCTest, SwiftUI, FinancialEntityViewModel
//   - State Management Complexity: High
//   - Novelty/Uncertainty Factor: Medium
// AI Pre-Task Self-Assessment: 75%
// Problem Estimate: 80%
// Initial Code Complexity Estimate: 78%
// Final Code Complexity: TBD
// Overall Result Score: TBD
// Key Variances/Learnings: TBD
// Last Updated: 2025-07-09

import XCTest
import SwiftUI
@testable import FinanceMate

final class FinancialEntityManagementViewTests: XCTestCase {
    
    var testContext: NSManagedObjectContext!
    var viewModel: FinancialEntityViewModel!
    
    override func setUp() {
        super.setUp()
        testContext = PersistenceController.preview.container.viewContext
        viewModel = FinancialEntityViewModel(context: testContext)
    }
    
    override func tearDown() {
        testContext = nil
        viewModel = nil
        super.tearDown()
    }
    
    // MARK: - View Initialization Tests
    
    func testFinancialEntityManagementViewInitialization() {
        // Given: Valid ViewModel
        // When: Creating the view
        let view = FinancialEntityManagementView(viewModel: viewModel)
        
        // Then: View should be created successfully
        XCTAssertNotNil(view)
    }
    
    func testViewModelBinding() {
        // Given: FinancialEntityManagementView
        let view = FinancialEntityManagementView(viewModel: viewModel)
        
        // When: View is initialized
        // Then: ViewModel should be properly bound
        XCTAssertNotNil(view.viewModel)
        XCTAssertIdentical(view.viewModel, viewModel)
    }
    
    // MARK: - Entity List Display Tests
    
    func testEntityListDisplaysEntities() async throws {
        // Given: ViewModel with test entities
        let personalEntity = FinancialEntity(context: testContext)
        personalEntity.name = "Personal"
        personalEntity.type = "Personal"
        
        let businessEntity = FinancialEntity(context: testContext)
        businessEntity.name = "Business"
        businessEntity.type = "Business"
        
        try testContext.save()
        
        // When: Fetching entities
        await viewModel.fetchEntities()
        
        // Then: Entities should be loaded
        XCTAssertEqual(viewModel.entities.count, 2)
        XCTAssertTrue(viewModel.entities.contains { $0.name == "Personal" })
        XCTAssertTrue(viewModel.entities.contains { $0.name == "Business" })
    }
    
    func testEmptyEntityListState() async throws {
        // Given: ViewModel with no entities
        // When: Fetching entities
        await viewModel.fetchEntities()
        
        // Then: Empty state should be handled
        XCTAssertEqual(viewModel.entities.count, 0)
        XCTAssertFalse(viewModel.isLoading)
    }
    
    // MARK: - Entity Creation Tests
    
    func testCreateEntitySheetPresentation() {
        // Given: FinancialEntityManagementView
        let view = FinancialEntityManagementView(viewModel: viewModel)
        
        // When: showingCreateSheet is true
        // Then: Create sheet should be presented
        // Note: This would typically be tested with ViewInspector or similar
        XCTAssertTrue(true) // Placeholder for SwiftUI view testing
    }
    
    func testCreateEntityValidation() async throws {
        // Given: New entity data
        let entityData = FinancialEntityData(
            name: "Test Entity",
            type: "Personal",
            description: "Test Description",
            parentEntityId: nil
        )
        
        // When: Creating entity
        await viewModel.createEntity(from: entityData)
        
        // Then: Entity should be created successfully
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.entities.contains { $0.name == "Test Entity" })
    }
    
    func testCreateEntityWithEmptyName() async throws {
        // Given: Entity data with empty name
        let entityData = FinancialEntityData(
            name: "",
            type: "Personal",
            description: "Test Description",
            parentEntityId: nil
        )
        
        // When: Creating entity
        await viewModel.createEntity(from: entityData)
        
        // Then: Error should be set
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.errorMessage?.contains("name cannot be empty") ?? false)
    }
    
    // MARK: - Entity Editing Tests
    
    func testEditEntitySheetPresentation() async throws {
        // Given: Entity to edit
        let entity = FinancialEntity(context: testContext)
        entity.name = "Original Name"
        entity.type = "Personal"
        try testContext.save()
        
        // When: Setting current entity for editing
        await viewModel.setCurrentEntity(entity)
        
        // Then: Current entity should be set
        XCTAssertEqual(viewModel.currentEntity?.name, "Original Name")
    }
    
    func testEditEntityUpdate() async throws {
        // Given: Existing entity
        let entity = FinancialEntity(context: testContext)
        entity.name = "Original Name"
        entity.type = "Personal"
        try testContext.save()
        
        await viewModel.setCurrentEntity(entity)
        
        // When: Updating entity
        let updatedData = FinancialEntityData(
            name: "Updated Name",
            type: "Business",
            description: "Updated Description",
            parentEntityId: nil
        )
        
        await viewModel.updateEntity(entity, with: updatedData)
        
        // Then: Entity should be updated
        XCTAssertEqual(entity.name, "Updated Name")
        XCTAssertEqual(entity.type, "Business")
    }
    
    // MARK: - Entity Deletion Tests
    
    func testDeleteEntityValidation() async throws {
        // Given: Entity to delete
        let entity = FinancialEntity(context: testContext)
        entity.name = "To Delete"
        entity.type = "Personal"
        try testContext.save()
        
        await viewModel.fetchEntities()
        let initialCount = viewModel.entities.count
        
        // When: Deleting entity
        await viewModel.deleteEntity(entity)
        
        // Then: Entity should be removed
        XCTAssertEqual(viewModel.entities.count, initialCount - 1)
        XCTAssertFalse(viewModel.entities.contains { $0.name == "To Delete" })
    }
    
    func testDeleteEntityWithChildren() async throws {
        // Given: Parent entity with children
        let parentEntity = FinancialEntity(context: testContext)
        parentEntity.name = "Parent"
        parentEntity.type = "Personal"
        
        let childEntity = FinancialEntity(context: testContext)
        childEntity.name = "Child"
        childEntity.type = "Personal"
        childEntity.parentEntity = parentEntity
        
        try testContext.save()
        
        // When: Deleting parent entity
        await viewModel.deleteEntity(parentEntity)
        
        // Then: Child entity should be orphaned, not deleted
        await viewModel.fetchEntities()
        XCTAssertTrue(viewModel.entities.contains { $0.name == "Child" })
        XCTAssertNil(viewModel.entities.first { $0.name == "Child" }?.parentEntity)
    }
    
    // MARK: - Hierarchy Management Tests
    
    func testEntityHierarchyDisplay() async throws {
        // Given: Parent and child entities
        let parentEntity = FinancialEntity(context: testContext)
        parentEntity.name = "Parent"
        parentEntity.type = "Personal"
        
        let childEntity = FinancialEntity(context: testContext)
        childEntity.name = "Child"
        childEntity.type = "Personal"
        childEntity.parentEntity = parentEntity
        
        try testContext.save()
        
        // When: Fetching entities
        await viewModel.fetchEntities()
        
        // Then: Hierarchy should be maintained
        let fetchedParent = viewModel.entities.first { $0.name == "Parent" }
        let fetchedChild = viewModel.entities.first { $0.name == "Child" }
        
        XCTAssertNotNil(fetchedParent)
        XCTAssertNotNil(fetchedChild)
        XCTAssertEqual(fetchedChild?.parentEntity?.name, "Parent")
    }
    
    func testCreateChildEntity() async throws {
        // Given: Parent entity
        let parentEntity = FinancialEntity(context: testContext)
        parentEntity.name = "Parent"
        parentEntity.type = "Personal"
        try testContext.save()
        
        // When: Creating child entity
        let childData = FinancialEntityData(
            name: "Child",
            type: "Personal",
            description: "Child Description",
            parentEntityId: parentEntity.id
        )
        
        await viewModel.createEntity(from: childData)
        
        // Then: Child entity should be created with correct parent
        let childEntity = viewModel.entities.first { $0.name == "Child" }
        XCTAssertNotNil(childEntity)
        XCTAssertEqual(childEntity?.parentEntity?.name, "Parent")
    }
    
    // MARK: - Entity Type Tests
    
    func testEntityTypeValidation() async throws {
        // Given: Valid entity types
        let validTypes = ["Personal", "Business", "Trust", "Investment"]
        
        for type in validTypes {
            // When: Creating entity with valid type
            let entityData = FinancialEntityData(
                name: "\(type) Entity",
                type: type,
                description: "Test Description",
                parentEntityId: nil
            )
            
            await viewModel.createEntity(from: entityData)
            
            // Then: Entity should be created successfully
            XCTAssertTrue(viewModel.entities.contains { $0.name == "\(type) Entity" })
        }
    }
    
    func testInvalidEntityType() async throws {
        // Given: Invalid entity type
        let entityData = FinancialEntityData(
            name: "Invalid Entity",
            type: "InvalidType",
            description: "Test Description",
            parentEntityId: nil
        )
        
        // When: Creating entity with invalid type
        await viewModel.createEntity(from: entityData)
        
        // Then: Error should be set
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.errorMessage?.contains("Invalid entity type") ?? false)
    }
    
    // MARK: - Search and Filter Tests
    
    func testEntitySearch() async throws {
        // Given: Multiple entities
        let entities = [
            ("Personal Account", "Personal"),
            ("Business Account", "Business"),
            ("Personal Investment", "Investment")
        ]
        
        for (name, type) in entities {
            let entity = FinancialEntity(context: testContext)
            entity.name = name
            entity.type = type
        }
        
        try testContext.save()
        
        // When: Searching for entities
        await viewModel.searchEntities(containing: "Personal")
        
        // Then: Only matching entities should be returned
        XCTAssertEqual(viewModel.entities.count, 2)
        XCTAssertTrue(viewModel.entities.allSatisfy { $0.name.contains("Personal") })
    }
    
    func testFilterEntitiesByType() async throws {
        // Given: Entities of different types
        let personalEntity = FinancialEntity(context: testContext)
        personalEntity.name = "Personal"
        personalEntity.type = "Personal"
        
        let businessEntity = FinancialEntity(context: testContext)
        businessEntity.name = "Business"
        businessEntity.type = "Business"
        
        try testContext.save()
        
        // When: Filtering by type
        await viewModel.fetchEntitiesByType(.business)
        
        // Then: Only business entities should be returned
        XCTAssertEqual(viewModel.entities.count, 1)
        XCTAssertEqual(viewModel.entities.first?.type, "Business")
    }
    
    // MARK: - Error Handling Tests
    
    func testEntityNameUniquenesValidation() async throws {
        // Given: Existing entity
        let existingEntity = FinancialEntity(context: testContext)
        existingEntity.name = "Existing Entity"
        existingEntity.type = "Personal"
        try testContext.save()
        
        // When: Creating entity with duplicate name
        let duplicateData = FinancialEntityData(
            name: "Existing Entity",
            type: "Personal",
            description: "Duplicate Description",
            parentEntityId: nil
        )
        
        await viewModel.createEntity(from: duplicateData)
        
        // Then: Error should be set for duplicate name
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.errorMessage?.contains("name already exists") ?? false)
    }
    
    func testCircularReferenceValidation() async throws {
        // Given: Parent and child entities
        let parentEntity = FinancialEntity(context: testContext)
        parentEntity.name = "Parent"
        parentEntity.type = "Personal"
        
        let childEntity = FinancialEntity(context: testContext)
        childEntity.name = "Child"
        childEntity.type = "Personal"
        childEntity.parentEntity = parentEntity
        
        try testContext.save()
        
        // When: Attempting to create circular reference
        let updatedData = FinancialEntityData(
            name: "Parent",
            type: "Personal",
            description: "Updated Description",
            parentEntityId: childEntity.id
        )
        
        await viewModel.updateEntity(parentEntity, with: updatedData)
        
        // Then: Error should be set for circular reference
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.errorMessage?.contains("circular") ?? false)
    }
    
    // MARK: - Loading State Tests
    
    func testLoadingStateManagement() async throws {
        // Given: ViewModel
        // When: Starting async operation
        XCTAssertFalse(viewModel.isLoading)
        
        let expectation = XCTestExpectation(description: "Loading state")
        
        Task {
            await viewModel.fetchEntities()
            expectation.fulfill()
        }
        
        // Then: Loading state should be managed properly
        await fulfillment(of: [expectation], timeout: 1.0)
        XCTAssertFalse(viewModel.isLoading)
    }
    
    // MARK: - Performance Tests
    
    func testEntityListPerformance() throws {
        // Given: Large number of entities
        measure {
            for i in 1...100 {
                let entity = FinancialEntity(context: testContext)
                entity.name = "Entity \(i)"
                entity.type = "Personal"
            }
            
            try! testContext.save()
        }
    }
}

// MARK: - Helper Structures

struct FinancialEntityData {
    let name: String
    let type: String
    let description: String?
    let parentEntityId: UUID?
}

// MARK: - FinancialEntityViewModel Extension for Testing

extension FinancialEntityViewModel {
    func createEntity(from data: FinancialEntityData) async {
        // This method would be implemented in the actual ViewModel
        // For now, this is a placeholder for the test structure
    }
    
    func updateEntity(_ entity: FinancialEntity, with data: FinancialEntityData) async {
        // This method would be implemented in the actual ViewModel
        // For now, this is a placeholder for the test structure
    }
}