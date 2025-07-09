//
// FinancialEntityViewModel.swift
// FinanceMate
//
// Purpose: MVVM ViewModel for FinancialEntity management with comprehensive CRUD operations and hierarchy support
// Issues & Complexity Summary: ObservableObject with Core Data integration, entity hierarchy management, and active entity switching
// Key Complexity Drivers:
//   - Logic Scope (Est. LoC): ~400
//   - Core Algorithm Complexity: High
//   - Dependencies: 4 (SwiftUI, Core Data, Combine, Foundation)
//   - State Management Complexity: High
//   - Novelty/Uncertainty Factor: Medium
// AI Pre-Task Self-Assessment: 85%
// Problem Estimate: 90%
// Initial Code Complexity Estimate: 88%
// Final Code Complexity: TBD
// Overall Result Score: TBD
// Key Variances/Learnings: MVVM architecture for complex entity management with hierarchy support
// Last Updated: 2025-07-09

import Combine
import CoreData
import Foundation
import SwiftUI

/// FinancialEntityViewModel implementing MVVM architecture for financial entity management
///
/// This ViewModel manages the business logic and state for financial entity operations,
/// providing comprehensive CRUD operations, hierarchy management, and active entity switching.
///
/// Key Responsibilities:
/// - Entity CRUD operations (Create, Read, Update, Delete)
/// - Hierarchy management (parent-child relationships)
/// - Active entity switching and persistence
/// - Search and filtering capabilities
/// - Core Data integration with reactive updates
/// - Error handling and validation
@MainActor
class FinancialEntityViewModel: ObservableObject {

    // MARK: - Published Properties

    /// Array of all financial entities
    @Published var entities: [FinancialEntity] = []

    /// Currently selected/active financial entity
    @Published var currentEntity: FinancialEntity?

    /// Loading state for UI feedback during data operations
    @Published var isLoading = false

    /// Error message for user display when operations fail
    @Published var errorMessage: String?

    /// Search text for entity filtering
    @Published var searchText = ""

    /// Selected entity type for filtering
    @Published var selectedEntityType = "All"

    // MARK: - Computed Properties

    /// Filtered entities based on search text and selected type
    var filteredEntities: [FinancialEntity] {
        var filtered = entities

        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter { entity in
                entity.name?.localizedCaseInsensitiveContains(searchText) == true
            }
        }

        // Filter by entity type
        if selectedEntityType != "All" {
            filtered = filtered.filter { entity in
                entity.type == selectedEntityType
            }
        }

        return filtered
    }

    /// Total number of entities
    var entityCount: Int {
        entities.count
    }

    /// Root entities (entities without parent)
    var rootEntities: [FinancialEntity] {
        entities.filter { $0.parent == nil }
    }

    // MARK: - Private Properties

    private var context: NSManagedObjectContext
    private var cancellables = Set<AnyCancellable>()
    private let userDefaults = UserDefaults.standard
    private static let currentEntityKey = "FinancialEntity.CurrentEntity"

    // MARK: - Initialization

    /// Initialize FinancialEntityViewModel with Core Data context
    /// - Parameter context: NSManagedObjectContext for data operations
    init(context: NSManagedObjectContext) {
        self.context = context
        setupNotificationObservers()
        loadCurrentEntityFromDefaults()
    }

    /// Convenience initializer for @StateObject usage without immediate context
    /// Context must be set via setPersistenceContext before calling data methods
    convenience init() {
        // Create a temporary context that will be replaced via setPersistenceContext
        let tempContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        self.init(context: tempContext)
    }

    deinit {
        cancellables.removeAll()
    }

    // MARK: - Public Methods

    /// Fetch all financial entities from Core Data
    ///
    /// This method performs the following operations:
    /// 1. Sets loading state to true
    /// 2. Fetches all active entities from Core Data
    /// 3. Updates published properties for UI updates
    /// 4. Handles any errors gracefully
    func fetchEntities() async {
        isLoading = true
        errorMessage = nil

        do {
            let request: NSFetchRequest<FinancialEntity> = FinancialEntity.fetchRequest()
            request.predicate = NSPredicate(format: "isActive == YES")
            request.sortDescriptors = [
                NSSortDescriptor(keyPath: \FinancialEntity.name, ascending: true)
            ]

            let fetchedEntities = try context.fetch(request)
            
            await MainActor.run {
                self.entities = fetchedEntities
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to fetch entities: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }

    /// Create a new financial entity
    /// - Parameters:
    ///   - name: Entity name (required, non-empty)
    ///   - type: Entity type (Personal, Business, Trust, Investment)
    ///   - parent: Optional parent entity for hierarchy
    /// - Throws: Validation or Core Data errors
    func createEntity(name: String, type: String, parent: FinancialEntity? = nil) async throws {
        // Validate input
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ValidationError.emptyName
        }

        // Validate hierarchy depth
        if let parent = parent {
            let depth = getEntityDepth(for: parent)
            if depth >= 4 { // Maximum 5 levels (0-4)
                throw ValidationError.hierarchyTooDeep
            }
        }

        // Check for name uniqueness within same parent context
        let existingEntities = parent?.childEntities?.allObjects as? [FinancialEntity] ?? rootEntities
        if existingEntities.contains(where: { $0.name == name && $0.isActive }) {
            throw ValidationError.nameNotUnique
        }

        isLoading = true
        errorMessage = nil

        do {
            let entity = FinancialEntity(context: context)
            entity.id = UUID()
            entity.name = name
            entity.type = type
            entity.parent = parent
            entity.isActive = true
            entity.createdAt = Date()
            entity.updatedAt = Date()

            try context.save()

            await fetchEntities()
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to create entity: \(error.localizedDescription)"
                self.isLoading = false
            }
            throw error
        }
    }

    /// Update an existing financial entity
    /// - Parameters:
    ///   - entity: Entity to update
    ///   - name: New entity name
    ///   - type: New entity type
    /// - Throws: Validation or Core Data errors
    func updateEntity(_ entity: FinancialEntity, name: String, type: String) async throws {
        // Validate input
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ValidationError.emptyName
        }

        // Check for name uniqueness within same parent context
        let siblings = entity.parent?.childEntities?.allObjects as? [FinancialEntity] ?? rootEntities
        if siblings.contains(where: { $0.name == name && $0.isActive && $0 != entity }) {
            throw ValidationError.nameNotUnique
        }

        isLoading = true
        errorMessage = nil

        do {
            entity.name = name
            entity.type = type
            entity.updatedAt = Date()

            try context.save()

            await fetchEntities()
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to update entity: \(error.localizedDescription)"
                self.isLoading = false
            }
            throw error
        }
    }

    /// Delete a financial entity
    /// - Parameter entity: Entity to delete
    /// - Throws: Validation or Core Data errors
    func deleteEntity(_ entity: FinancialEntity) async throws {
        // Validate deletion is safe
        if let childEntities = entity.childEntities, !childEntities.isEmpty {
            throw ValidationError.hasChildEntities
        }

        // Check for associated transactions
        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        request.predicate = NSPredicate(format: "entityId == %@", entity.id?.uuidString ?? "")
        request.fetchLimit = 1

        do {
            let transactions = try context.fetch(request)
            if !transactions.isEmpty {
                throw ValidationError.hasTransactions
            }
        } catch {
            throw ValidationError.deletionValidationFailed
        }

        isLoading = true
        errorMessage = nil

        do {
            // If this is the current entity, clear it
            if currentEntity == entity {
                await setCurrentEntity(nil)
            }

            context.delete(entity)
            try context.save()

            await fetchEntities()
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to delete entity: \(error.localizedDescription)"
                self.isLoading = false
            }
            throw error
        }
    }

    /// Set the current/active entity
    /// - Parameter entity: Entity to set as current (nil to clear)
    func setCurrentEntity(_ entity: FinancialEntity?) async {
        currentEntity = entity
        
        // Persist current entity selection
        if let entity = entity, let entityIdString = entity.id?.uuidString {
            userDefaults.set(entityIdString, forKey: Self.currentEntityKey)
        } else {
            userDefaults.removeObject(forKey: Self.currentEntityKey)
        }
    }

    /// Search entities by name
    /// - Parameter query: Search query
    func searchEntities(query: String) {
        searchText = query
    }

    /// Filter entities by type
    /// - Parameter type: Entity type to filter by
    func filterEntitiesByType(_ type: String) {
        selectedEntityType = type
    }

    /// Get the hierarchical path for an entity
    /// - Parameter entity: Entity to get path for
    /// - Returns: Array of entities from root to target entity
    func getEntityPath(for entity: FinancialEntity) -> [FinancialEntity] {
        var path: [FinancialEntity] = []
        var current: FinancialEntity? = entity

        while let entity = current {
            path.insert(entity, at: 0)
            current = entity.parent
        }

        return path
    }

    /// Get the depth of an entity in the hierarchy
    /// - Parameter entity: Entity to get depth for
    /// - Returns: Depth level (0 for root entities)
    func getEntityDepth(for entity: FinancialEntity) -> Int {
        var depth = 0
        var current = entity.parent

        while current != nil {
            depth += 1
            current = current?.parent
        }

        return depth
    }

    /// Set the persistence context for this ViewModel
    /// - Parameter context: NSManagedObjectContext to use
    func setPersistenceContext(_ context: NSManagedObjectContext) {
        self.context = context
        setupNotificationObservers()
    }

    // MARK: - Private Methods

    /// Setup Core Data notification observers
    private func setupNotificationObservers() {
        NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave, object: context)
            .sink { [weak self] _ in
                Task {
                    await self?.fetchEntities()
                }
            }
            .store(in: &cancellables)
    }

    /// Load current entity from UserDefaults
    private func loadCurrentEntityFromDefaults() {
        guard let entityIdString = userDefaults.string(forKey: Self.currentEntityKey),
              let entityId = UUID(uuidString: entityIdString) else {
            return
        }

        Task {
            await fetchEntities()
            
            // Find the entity with the saved ID
            if let entity = entities.first(where: { $0.id == entityId }) {
                await setCurrentEntity(entity)
            }
        }
    }
}

// MARK: - Validation Errors

/// Validation errors for FinancialEntity operations
enum ValidationError: LocalizedError {
    case emptyName
    case nameNotUnique
    case hierarchyTooDeep
    case hasChildEntities
    case hasTransactions
    case deletionValidationFailed

    var errorDescription: String? {
        switch self {
        case .emptyName:
            return "Entity name cannot be empty"
        case .nameNotUnique:
            return "Entity name must be unique within the same parent"
        case .hierarchyTooDeep:
            return "Entity hierarchy cannot exceed 5 levels"
        case .hasChildEntities:
            return "Cannot delete entity with child entities"
        case .hasTransactions:
            return "Cannot delete entity with associated transactions"
        case .deletionValidationFailed:
            return "Failed to validate entity deletion"
        }
    }
}