// SANDBOX FILE: For testing/development. See .cursorrules.
//
// FinancialEntityViewModelTests.swift
// FinanceMateTests
//
// Purpose: Comprehensive TDD unit tests for FinancialEntityViewModel MVVM architecture
// Issues & Complexity Summary: Testing MVVM patterns, Core Data integration, hierarchy management, and active entity switching
// Key Complexity Drivers:
//   - Logic Scope (Est. LoC): ~450
//   - Core Algorithm Complexity: High
//   - Dependencies: 4 (Core Data, XCTest, Combine, Foundation)
//   - State Management Complexity: High
//   - Novelty/Uncertainty Factor: Medium
// AI Pre-Task Self-Assessment: 85%
// Problem Estimate: 90%
// Initial Code Complexity Estimate: 88%
// Final Code Complexity: TBD
// Overall Result Score: TBD
// Key Variances/Learnings: MVVM pattern for entity management with comprehensive state management
// Last Updated: 2025-07-09

import XCTest
import CoreData
import Combine
@testable import FinanceMate

@MainActor
final class FinancialEntityViewModelTests: XCTestCase {
    
    // MARK: - Properties
    var viewModel: FinancialEntityViewModel!
    var persistenceController: PersistenceController!
    var context: NSManagedObjectContext!
    var cancellables: Set<AnyCancellable>!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        
        // Create in-memory Core Data stack for testing
        persistenceController = PersistenceController(inMemory: true)
        context = persistenceController.container.viewContext
        
        // Initialize ViewModel with test context
        viewModel = FinancialEntityViewModel(context: context)
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        cancellables?.removeAll()
        viewModel = nil
        context = nil
        persistenceController = nil
        super.tearDown()
    }
    
    // MARK: - Helper Methods
    
    private func createTestEntity(
        name: String = "Test Entity",
        type: String = "Personal",
        parent: FinancialEntity? = nil
    ) -> FinancialEntity {
        let entity = FinancialEntity(context: context)
        entity.id = UUID()
        entity.name = name
        entity.type = type
        entity.parentEntity = parent
        entity.isActive = true
        entity.createdAt = Date()
        entity.lastModified = Date()
        
        return entity
    }
    
    private func saveContext() {
        do {
            try context.save()
        } catch {
            XCTFail("Failed to save context: \(error)")
        }
    }
    
    // MARK: - Entity CRUD Tests (8 test methods)
    
    func testCreateEntity() async {
        // Given
        let entityName = "Test Business Entity"
        let entityType = "Business"
        
        // When
        do {
            try await viewModel.createEntity(name: entityName, type: entityType, parent: nil)
            
            // Then
            XCTAssertFalse(viewModel.entities.isEmpty, "Entities should not be empty after creation")
            XCTAssertEqual(viewModel.entities.first?.name, entityName, "Entity name should match")
            XCTAssertEqual(viewModel.entities.first?.type, entityType, "Entity type should match")
            XCTAssertNil(viewModel.errorMessage, "Error message should be nil on successful creation")
            
        } catch {
            XCTFail("Entity creation should not throw error: \(error)")
        }
    }
    
    func testCreateEntityWithValidation() async {
        // Given
        let validName = "Valid Entity Name"
        let emptyName = ""
        let entityType = "Personal"
        
        // When - Test valid creation
        do {
            try await viewModel.createEntity(name: validName, type: entityType, parent: nil)
            XCTAssertEqual(viewModel.entities.count, 1, "Should have one entity after valid creation")
        } catch {
            XCTFail("Valid entity creation should not throw error: \(error)")
        }
        
        // When - Test invalid creation (empty name)
        do {
            try await viewModel.createEntity(name: emptyName, type: entityType, parent: nil)
            XCTFail("Empty name entity creation should throw error")
        } catch {
            // Then - Should throw validation error
            XCTAssertNotNil(error, "Should throw validation error for empty name")
        }
    }
    
    func testUpdateEntity() async {
        // Given
        let entity = createTestEntity(name: "Original Name", type: "Personal")
        saveContext()
        await viewModel.fetchEntities()
        
        let updatedName = "Updated Name"
        let updatedType = "Business"
        
        // When
        do {
            try await viewModel.updateEntity(entity, name: updatedName, type: updatedType)
            
            // Then
            XCTAssertEqual(entity.name, updatedName, "Entity name should be updated")
            XCTAssertEqual(entity.type, updatedType, "Entity type should be updated")
            XCTAssertNil(viewModel.errorMessage, "Error message should be nil on successful update")
            
        } catch {
            XCTFail("Entity update should not throw error: \(error)")
        }
    }
    
    func testDeleteEntity() async {
        // Given
        let entity = createTestEntity(name: "Entity to Delete", type: "Personal")
        saveContext()
        await viewModel.fetchEntities()
        
        let initialCount = viewModel.entities.count
        
        // When
        do {
            try await viewModel.deleteEntity(entity)
            
            // Then
            XCTAssertEqual(viewModel.entities.count, initialCount - 1, "Entity count should decrease by 1")
            XCTAssertFalse(viewModel.entities.contains(entity), "Entity should be removed from entities array")
            XCTAssertNil(viewModel.errorMessage, "Error message should be nil on successful deletion")
            
        } catch {
            XCTFail("Entity deletion should not throw error: \(error)")
        }
    }
    
    func testFetchAllEntities() async {
        // Given
        let entity1 = createTestEntity(name: "Entity 1", type: "Personal")
        let entity2 = createTestEntity(name: "Entity 2", type: "Business")
        let entity3 = createTestEntity(name: "Entity 3", type: "Investment")
        saveContext()
        
        // When
        await viewModel.fetchEntities()
        
        // Then
        XCTAssertEqual(viewModel.entities.count, 3, "Should fetch all 3 entities")
        XCTAssertTrue(viewModel.entities.contains(entity1), "Should contain entity 1")
        XCTAssertTrue(viewModel.entities.contains(entity2), "Should contain entity 2")
        XCTAssertTrue(viewModel.entities.contains(entity3), "Should contain entity 3")
        XCTAssertFalse(viewModel.isLoading, "Loading should be false after fetch")
    }
    
    func testFetchActiveEntities() async {
        // Given
        let activeEntity = createTestEntity(name: "Active Entity", type: "Personal")
        activeEntity.isActive = true
        
        let inactiveEntity = createTestEntity(name: "Inactive Entity", type: "Business")
        inactiveEntity.isActive = false
        
        saveContext()
        
        // When
        await viewModel.fetchEntities()
        
        // Then
        let activeEntities = viewModel.entities.filter { $0.isActive }
        XCTAssertEqual(activeEntities.count, 1, "Should only fetch active entities")
        XCTAssertTrue(activeEntities.contains(activeEntity), "Should contain active entity")
        XCTAssertFalse(activeEntities.contains(inactiveEntity), "Should not contain inactive entity")
    }
    
    func testFetchEntitiesByType() async {
        // Given
        let personalEntity = createTestEntity(name: "Personal Entity", type: "Personal")
        let businessEntity = createTestEntity(name: "Business Entity", type: "Business")
        let investmentEntity = createTestEntity(name: "Investment Entity", type: "Investment")
        saveContext()
        
        await viewModel.fetchEntities()
        
        // When
        viewModel.filterEntitiesByType("Business")
        
        // Then
        XCTAssertEqual(viewModel.filteredEntities.count, 1, "Should filter to only business entities")
        XCTAssertTrue(viewModel.filteredEntities.contains(businessEntity), "Should contain business entity")
        XCTAssertFalse(viewModel.filteredEntities.contains(personalEntity), "Should not contain personal entity")
        XCTAssertFalse(viewModel.filteredEntities.contains(investmentEntity), "Should not contain investment entity")
    }
    
    func testSearchEntities() async {
        // Given
        let entity1 = createTestEntity(name: "Apple Business", type: "Business")
        let entity2 = createTestEntity(name: "Microsoft Corporation", type: "Business")
        let entity3 = createTestEntity(name: "Personal Account", type: "Personal")
        saveContext()
        
        await viewModel.fetchEntities()
        
        // When
        viewModel.searchEntities(query: "Business")
        
        // Then
        XCTAssertEqual(viewModel.filteredEntities.count, 1, "Should find 1 entity matching 'Business'")
        XCTAssertTrue(viewModel.filteredEntities.contains(entity1), "Should contain Apple Business entity")
        
        // When - Search for partial match
        viewModel.searchEntities(query: "Corp")
        
        // Then
        XCTAssertEqual(viewModel.filteredEntities.count, 1, "Should find 1 entity matching 'Corp'")
        XCTAssertTrue(viewModel.filteredEntities.contains(entity2), "Should contain Microsoft Corporation entity")
    }
    
    // MARK: - Hierarchy Management Tests (6 test methods)
    
    func testCreateChildEntity() async {
        // Given
        let parentEntity = createTestEntity(name: "Parent Entity", type: "Business")
        saveContext()
        await viewModel.fetchEntities()
        
        // When
        do {
            try await viewModel.createEntity(name: "Child Entity", type: "Personal", parent: parentEntity)
            
            // Then
            let childEntity = viewModel.entities.first { $0.name == "Child Entity" }
            XCTAssertNotNil(childEntity, "Child entity should be created")
            XCTAssertEqual(childEntity?.parentEntity, parentEntity, "Child should have correct parent")
            XCTAssertTrue(parentEntity.childEntities.contains(childEntity!), "Parent should contain child")
            
        } catch {
            XCTFail("Child entity creation should not throw error: \(error)")
        }
    }
    
    func testMoveEntityHierarchy() async {
        // Given
        let parentEntity1 = createTestEntity(name: "Parent 1", type: "Business")
        let parentEntity2 = createTestEntity(name: "Parent 2", type: "Business")
        let childEntity = createTestEntity(name: "Child", type: "Personal", parent: parentEntity1)
        saveContext()
        await viewModel.fetchEntities()
        
        // When
        do {
            try await viewModel.updateEntity(childEntity, name: "Child", type: "Personal")
            childEntity.parentEntity = parentEntity2
            try context.save()
            
            // Then
            XCTAssertEqual(childEntity.parentEntity, parentEntity2, "Child should have new parent")
            XCTAssertTrue(parentEntity2.childEntities.contains(childEntity), "New parent should contain child")
            XCTAssertFalse(parentEntity1.childEntities.contains(childEntity), "Old parent should not contain child")
            
        } catch {
            XCTFail("Entity hierarchy move should not throw error: \(error)")
        }
    }
    
    func testGetEntityPath() async {
        // Given
        let rootEntity = createTestEntity(name: "Root", type: "Business")
        let childEntity = createTestEntity(name: "Child", type: "Personal", parent: rootEntity)
        let grandchildEntity = createTestEntity(name: "Grandchild", type: "Investment", parent: childEntity)
        saveContext()
        await viewModel.fetchEntities()
        
        // When
        let path = viewModel.getEntityPath(for: grandchildEntity)
        
        // Then
        XCTAssertEqual(path.count, 3, "Path should contain 3 entities")
        XCTAssertEqual(path[0], rootEntity, "First entity should be root")
        XCTAssertEqual(path[1], childEntity, "Second entity should be child")
        XCTAssertEqual(path[2], grandchildEntity, "Third entity should be grandchild")
    }
    
    func testValidateCircularReference() async {
        // Given
        let parentEntity = createTestEntity(name: "Parent", type: "Business")
        let childEntity = createTestEntity(name: "Child", type: "Personal", parent: parentEntity)
        saveContext()
        await viewModel.fetchEntities()
        
        // When - Try to create circular reference
        do {
            try await viewModel.updateEntity(parentEntity, name: "Parent", type: "Business")
            parentEntity.parentEntity = childEntity
            try context.save()
            
            XCTFail("Circular reference should throw error")
        } catch {
            // Then - Should throw validation error
            XCTAssertNotNil(error, "Should throw validation error for circular reference")
        }
    }
    
    func testGetRootEntities() async {
        // Given
        let rootEntity1 = createTestEntity(name: "Root 1", type: "Business")
        let rootEntity2 = createTestEntity(name: "Root 2", type: "Personal")
        let childEntity = createTestEntity(name: "Child", type: "Investment", parent: rootEntity1)
        saveContext()
        await viewModel.fetchEntities()
        
        // When
        let rootEntities = viewModel.rootEntities
        
        // Then
        XCTAssertEqual(rootEntities.count, 2, "Should have 2 root entities")
        XCTAssertTrue(rootEntities.contains(rootEntity1), "Should contain root entity 1")
        XCTAssertTrue(rootEntities.contains(rootEntity2), "Should contain root entity 2")
        XCTAssertFalse(rootEntities.contains(childEntity), "Should not contain child entity")
    }
    
    func testGetEntityDepth() async {
        // Given
        let rootEntity = createTestEntity(name: "Root", type: "Business")
        let childEntity = createTestEntity(name: "Child", type: "Personal", parent: rootEntity)
        let grandchildEntity = createTestEntity(name: "Grandchild", type: "Investment", parent: childEntity)
        saveContext()
        await viewModel.fetchEntities()
        
        // When & Then
        XCTAssertEqual(viewModel.getEntityDepth(for: rootEntity), 0, "Root entity should have depth 0")
        XCTAssertEqual(viewModel.getEntityDepth(for: childEntity), 1, "Child entity should have depth 1")
        XCTAssertEqual(viewModel.getEntityDepth(for: grandchildEntity), 2, "Grandchild entity should have depth 2")
    }
    
    // MARK: - Active Entity Management Tests (4 test methods)
    
    func testSetCurrentEntity() async {
        // Given
        let entity = createTestEntity(name: "Current Entity", type: "Personal")
        saveContext()
        await viewModel.fetchEntities()
        
        // When
        await viewModel.setCurrentEntity(entity)
        
        // Then
        XCTAssertEqual(viewModel.currentEntity, entity, "Current entity should be set")
        XCTAssertEqual(viewModel.currentEntity?.name, "Current Entity", "Current entity name should match")
    }
    
    func testSwitchEntity() async {
        // Given
        let entity1 = createTestEntity(name: "Entity 1", type: "Personal")
        let entity2 = createTestEntity(name: "Entity 2", type: "Business")
        saveContext()
        await viewModel.fetchEntities()
        
        // When
        await viewModel.setCurrentEntity(entity1)
        XCTAssertEqual(viewModel.currentEntity, entity1, "Should set first entity as current")
        
        await viewModel.setCurrentEntity(entity2)
        
        // Then
        XCTAssertEqual(viewModel.currentEntity, entity2, "Should switch to second entity")
        XCTAssertNotEqual(viewModel.currentEntity, entity1, "Should not be first entity anymore")
    }
    
    func testCurrentEntityPersistence() async throws {
        // Given
        let entity = createTestEntity(name: "Persistent Entity", type: "Personal")
        saveContext()
        await viewModel.fetchEntities()
        
        // When
        await viewModel.setCurrentEntity(entity)
        
        // Create new ViewModel instance to test persistence
        let newViewModel = FinancialEntityViewModel(context: context)
        await newViewModel.fetchEntities()
        
        // Wait for async loading to complete
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Then
        XCTAssertEqual(newViewModel.currentEntity?.id, entity.id, "Current entity should persist across ViewModel instances")
    }
    
    func testCurrentEntityValidation() async {
        // Given
        let entity = createTestEntity(name: "Valid Entity", type: "Personal")
        saveContext()
        await viewModel.fetchEntities()
        
        // When - Set valid entity
        await viewModel.setCurrentEntity(entity)
        XCTAssertEqual(viewModel.currentEntity, entity, "Should set valid entity as current")
        
        // When - Try to set nil entity
        await viewModel.setCurrentEntity(nil)
        
        // Then - Should handle nil gracefully
        XCTAssertNil(viewModel.currentEntity, "Should handle nil entity gracefully")
    }
    
    // MARK: - State Management Tests (5 test methods)
    
    func testLoadingStates() async {
        // Given
        let expectation = XCTestExpectation(description: "Loading state should change")
        
        viewModel.$isLoading
            .sink { isLoading in
                if isLoading {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        await viewModel.fetchEntities()
        
        // Then
        await fulfillment(of: [expectation], timeout: 1.0)
        XCTAssertFalse(viewModel.isLoading, "Loading should be false after fetch completes")
    }
    
    func testErrorHandling() async {
        // Given
        let invalidEntity = createTestEntity(name: "", type: "Personal") // Invalid name
        
        // When
        do {
            try await viewModel.updateEntity(invalidEntity, name: "", type: "Personal")
            XCTFail("Should throw error for invalid entity update")
        } catch {
            // Then
            XCTAssertNotNil(viewModel.errorMessage, "Error message should be set on error")
            XCTAssertTrue(viewModel.errorMessage?.contains("validation") == true, "Error message should mention validation")
        }
    }
    
    func testEntityCountUpdate() async {
        // Given
        let initialCount = viewModel.entityCount
        
        // When
        let entity = createTestEntity(name: "New Entity", type: "Personal")
        saveContext()
        await viewModel.fetchEntities()
        
        // Then
        XCTAssertEqual(viewModel.entityCount, initialCount + 1, "Entity count should increase by 1")
        XCTAssertEqual(viewModel.entityCount, viewModel.entities.count, "Entity count should match entities array count")
    }
    
    func testEntityListUpdates() async {
        // Given
        let entity1 = createTestEntity(name: "Entity 1", type: "Personal")
        let entity2 = createTestEntity(name: "Entity 2", type: "Business")
        saveContext()
        
        // When
        await viewModel.fetchEntities()
        let initialCount = viewModel.entities.count
        
        // Create new entity
        do {
            try await viewModel.createEntity(name: "New Entity", type: "Investment", parent: nil)
            
            // Then
            XCTAssertEqual(viewModel.entities.count, initialCount + 1, "Entity list should update after creation")
            XCTAssertTrue(viewModel.entities.contains { $0.name == "New Entity" }, "New entity should be in the list")
            
        } catch {
            XCTFail("Entity creation should not throw error: \(error)")
        }
    }
    
    func testPerformanceEntityLoad() async {
        // Given
        let entityCount = 100
        for i in 0..<entityCount {
            let entity = createTestEntity(name: "Entity \(i)", type: "Personal")
            if i % 10 == 0 {
                saveContext() // Save periodically to avoid memory issues
            }
        }
        saveContext()
        
        // When
        let startTime = CFAbsoluteTimeGetCurrent()
        await viewModel.fetchEntities()
        let endTime = CFAbsoluteTimeGetCurrent()
        
        // Then
        let executionTime = endTime - startTime
        XCTAssertLessThan(executionTime, 0.5, "Should load 100 entities in less than 500ms")
        XCTAssertEqual(viewModel.entities.count, entityCount, "Should load all entities")
    }
}