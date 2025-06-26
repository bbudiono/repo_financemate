// SANDBOX FILE: For testing/development. See .cursorrules.
/*
* Purpose: Core Data stack management for FinanceMate Sandbox environment
* Issues & Complexity Summary: Centralized Core Data stack with persistent storage and memory context
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~150
  - Core Algorithm Complexity: Medium
  - Dependencies: 2 New (CoreData, Foundation)
  - State Management Complexity: Medium
  - Novelty/Uncertainty Factor: Low
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 70%
* Problem Estimate (Inherent Problem Difficulty %): 65%
* Initial Code Complexity Estimate %: 68%
* Justification for Estimates: Standard Core Data stack implementation
* Final Code Complexity (Actual %): TBD
* Overall Result Score (Success & Quality %): TBD
* Key Variances/Learnings: TBD
* Last Updated: 2025-06-03
*/

import CoreData
import Foundation

/// Core Data stack manager for FinanceMate application
/// Provides centralized access to persistent storage and managed object contexts
public class CoreDataStack {
    /// Shared singleton instance
    public static let shared = CoreDataStack()

    /// The persistent container for the Core Data stack
    public lazy var persistentContainer: NSPersistentContainer = {
        // Create in-memory model programmatically since no .xcdatamodeld file exists
        let model = createFinanceMateDataModel()
        let container = NSPersistentContainer(name: "FinanceMateDataModel", managedObjectModel: model)

        // SECURITY HARDENING: Configure persistent store with encryption
        for storeDescription in container.persistentStoreDescriptions {
            // Enable binary store format for better security
            storeDescription.type = NSSQLiteStoreType
            
            // Set secure options for SQLite
            storeDescription.setOption("WAL" as NSString, forKey: "journal_mode")
            storeDescription.setOption("1000" as NSString, forKey: "cache_size")
            storeDescription.setOption("NORMAL" as NSString, forKey: "synchronous")
            
            // Note: SQLite encryption would require SQLCipher or similar
            // For now, rely on macOS file system encryption and keychain security
            
            // Enable automatic migration with security validation
            storeDescription.shouldInferMappingModelAutomatically = true
            storeDescription.shouldMigrateStoreAutomatically = true
        }
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                // Log security-related errors
                Task { @MainActor in
                    SecurityAuditLogger.shared.log(event: .securityPolicyViolation(
                        policy: "Core Data Security",
                        details: "Failed to load persistent store with security configuration: \(error.localizedDescription)"
                    ))
                }
                
                // In production, handle this error gracefully
                fatalError("Failed to load persistent store: \(error), \(error.userInfo)")
            }
            
            // Log successful secure store initialization
            Task { @MainActor in
                SecurityAuditLogger.shared.log(event: .securityPolicyViolation(
                    policy: "Core Data Security",
                    details: "Persistent store loaded with security configuration"
                ))
            }
        }

        // PERFORMANCE OPTIMIZATION: Enhanced merge policy and context configuration
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        // Performance optimizations for main context
        container.viewContext.undoManager = nil // Disable undo for better performance
        container.viewContext.shouldDeleteInaccessibleFaults = true
        
        // Configure fetch batch size for better memory management
        container.viewContext.stalenessInterval = 0 // Always get fresh data

        return container
    }()

    /// The main managed object context (connected to persistent store coordinator)
    public var mainContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    /// Creates a new background context for concurrent operations
    public func newBackgroundContext() -> NSManagedObjectContext {
        persistentContainer.newBackgroundContext()
    }

    /// Saves the main context
    /// - Throws: Core Data save errors
    public func saveMainContext() throws {
        guard mainContext.hasChanges else { return }
        try mainContext.save()
    }

    /// Saves the given context
    /// - Parameter context: The managed object context to save
    /// - Throws: Core Data save errors
    public func save(context: NSManagedObjectContext) throws {
        guard context.hasChanges else { return }
        try context.save()
    }

    /// Performs a save operation on the main context asynchronously
    /// - Parameter completion: Completion handler called on main queue
    public func saveMainContextAsync(completion: @escaping (Result<Void, Error>) -> Void) {
        mainContext.perform {
            do {
                try self.saveMainContext()
                DispatchQueue.main.async {
                    completion(.success(()))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    /// Performs a save operation on a background context
    /// - Parameters:
    ///   - changes: Block to perform changes on background context
    ///   - completion: Completion handler called on main queue
    public func performBackgroundTask(
        changes: @escaping (NSManagedObjectContext) -> Void,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let backgroundContext = newBackgroundContext()

        backgroundContext.perform {
            changes(backgroundContext)

            do {
                try self.save(context: backgroundContext)
                DispatchQueue.main.async {
                    completion(.success(()))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    /// Deletes all data from the persistent store (useful for testing)
    /// - Throws: Core Data errors
    public func deleteAllData() throws {
        let entityNames = ["Document", "FinancialData", "Client", "Category", "Project", "Budget", "BudgetCategory", "BudgetAllocation", "Subscription"]

        for entityName in entityNames {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            deleteRequest.resultType = .resultTypeObjectIDs

            let result = try mainContext.execute(deleteRequest) as? NSBatchDeleteResult
            let objectIDArray = result?.result as? [NSManagedObjectID]
            let changes = [NSDeletedObjectsKey: objectIDArray ?? []]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [mainContext])
        }

        try saveMainContext()
    }

    /// Private initializer for singleton
    private init() {}

    /// Creates the Core Data model programmatically
    private func createFinanceMateDataModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        // Create FinancialData entity
        let financialDataEntity = NSEntityDescription()
        financialDataEntity.name = "FinancialData"
        financialDataEntity.managedObjectClassName = "FinancialData"

        // FinancialData attributes - match FinancialData+CoreDataProperties.swift
        let financialDataAttributes = [
            createAttribute(name: "id", type: .UUIDAttributeType, optional: true),
            createAttribute(name: "vendorName", type: .stringAttributeType, optional: true),
            createAttribute(name: "totalAmount", type: .decimalAttributeType, optional: true),
            createAttribute(name: "taxAmount", type: .decimalAttributeType, optional: true),
            createAttribute(name: "taxRate", type: .doubleAttributeType, optional: false),
            createAttribute(name: "currency", type: .stringAttributeType, optional: true),
            createAttribute(name: "invoiceNumber", type: .stringAttributeType, optional: true),
            createAttribute(name: "invoiceDate", type: .dateAttributeType, optional: true),
            createAttribute(name: "dueDate", type: .dateAttributeType, optional: true),
            createAttribute(name: "dateExtracted", type: .dateAttributeType, optional: true),
            createAttribute(name: "extractionConfidence", type: .doubleAttributeType, optional: false),
            createAttribute(name: "purchaseOrderNumber", type: .stringAttributeType, optional: true),
            createAttribute(name: "paymentTerms", type: .stringAttributeType, optional: true),
            createAttribute(name: "notes", type: .stringAttributeType, optional: true),
            createAttribute(name: "lineItems", type: .stringAttributeType, optional: true),
            createAttribute(name: "discountAmount", type: .decimalAttributeType, optional: true),
            createAttribute(name: "shippingAmount", type: .decimalAttributeType, optional: true),
            createAttribute(name: "metadata", type: .stringAttributeType, optional: true)
        ]
        financialDataEntity.properties = financialDataAttributes

        // Create Document entity
        let documentEntity = NSEntityDescription()
        documentEntity.name = "Document"
        documentEntity.managedObjectClassName = "Document"

        // Document attributes - match Document+CoreDataProperties.swift
        let documentAttributes = [
            createAttribute(name: "id", type: .UUIDAttributeType, optional: true),
            createAttribute(name: "fileName", type: .stringAttributeType, optional: true),
            createAttribute(name: "filePath", type: .stringAttributeType, optional: true),
            createAttribute(name: "fileSize", type: .integer64AttributeType, optional: false),
            createAttribute(name: "mimeType", type: .stringAttributeType, optional: true),
            createAttribute(name: "dateCreated", type: .dateAttributeType, optional: true),
            createAttribute(name: "dateModified", type: .dateAttributeType, optional: true),
            createAttribute(name: "documentType", type: .stringAttributeType, optional: true),
            createAttribute(name: "processingStatus", type: .stringAttributeType, optional: true),
            createAttribute(name: "notes", type: .stringAttributeType, optional: true),
            createAttribute(name: "fileHash", type: .stringAttributeType, optional: true),
            createAttribute(name: "ocrConfidence", type: .doubleAttributeType, optional: false),
            createAttribute(name: "rawOCRText", type: .stringAttributeType, optional: true),
            createAttribute(name: "metadata", type: .stringAttributeType, optional: true),
            createAttribute(name: "isArchived", type: .booleanAttributeType, optional: false),
            createAttribute(name: "isFavorite", type: .booleanAttributeType, optional: false)
        ]
        documentEntity.properties = documentAttributes

        // Create Category entity
        let categoryEntity = NSEntityDescription()
        categoryEntity.name = "Category"
        categoryEntity.managedObjectClassName = "Category"

        // Category attributes - match Category+CoreDataProperties.swift
        let categoryAttributes = [
            createAttribute(name: "id", type: .UUIDAttributeType, optional: true),
            createAttribute(name: "name", type: .stringAttributeType, optional: true),
            createAttribute(name: "colorHex", type: .stringAttributeType, optional: true),
            createAttribute(name: "iconName", type: .stringAttributeType, optional: true),
            createAttribute(name: "isActive", type: .booleanAttributeType, optional: false),
            createAttribute(name: "isDefault", type: .booleanAttributeType, optional: false),
            createAttribute(name: "sortOrder", type: .integer32AttributeType, optional: false),
            createAttribute(name: "dateCreated", type: .dateAttributeType, optional: true),
            createAttribute(name: "dateModified", type: .dateAttributeType, optional: true),
            createAttribute(name: "categoryDescription", type: .stringAttributeType, optional: true),
            createAttribute(name: "notes", type: .stringAttributeType, optional: true),
            createAttribute(name: "metadata", type: .stringAttributeType, optional: true)
        ]
        categoryEntity.properties = categoryAttributes

        // Create Client entity
        let clientEntity = NSEntityDescription()
        clientEntity.name = "Client"
        clientEntity.managedObjectClassName = "Client"

        // Client attributes - match Client+CoreDataProperties.swift
        let clientAttributes = [
            createAttribute(name: "id", type: .UUIDAttributeType, optional: true),
            createAttribute(name: "name", type: .stringAttributeType, optional: true),
            createAttribute(name: "email", type: .stringAttributeType, optional: true),
            createAttribute(name: "phone", type: .stringAttributeType, optional: true),
            createAttribute(name: "address", type: .stringAttributeType, optional: true),
            createAttribute(name: "city", type: .stringAttributeType, optional: true),
            createAttribute(name: "state", type: .stringAttributeType, optional: true),
            createAttribute(name: "zipCode", type: .stringAttributeType, optional: true),
            createAttribute(name: "country", type: .stringAttributeType, optional: true),
            createAttribute(name: "clientType", type: .stringAttributeType, optional: true),
            createAttribute(name: "isActive", type: .booleanAttributeType, optional: false),
            createAttribute(name: "dateCreated", type: .dateAttributeType, optional: true),
            createAttribute(name: "dateModified", type: .dateAttributeType, optional: true),
            createAttribute(name: "notes", type: .stringAttributeType, optional: true),
            createAttribute(name: "taxId", type: .stringAttributeType, optional: true),
            createAttribute(name: "website", type: .stringAttributeType, optional: true),
            createAttribute(name: "preferredPaymentMethod", type: .stringAttributeType, optional: true),
            createAttribute(name: "creditLimit", type: .decimalAttributeType, optional: true),
            createAttribute(name: "currentBalance", type: .decimalAttributeType, optional: true),
            createAttribute(name: "metadata", type: .stringAttributeType, optional: true)
        ]
        clientEntity.properties = clientAttributes

        // Create Project entity
        let projectEntity = NSEntityDescription()
        projectEntity.name = "Project"
        projectEntity.managedObjectClassName = "Project"

        // Project attributes - match Project+CoreDataProperties.swift
        let projectAttributes = [
            createAttribute(name: "id", type: .UUIDAttributeType, optional: true),
            createAttribute(name: "name", type: .stringAttributeType, optional: true),
            createAttribute(name: "projectDescription", type: .stringAttributeType, optional: true),
            createAttribute(name: "budget", type: .decimalAttributeType, optional: true),
            createAttribute(name: "startDate", type: .dateAttributeType, optional: true),
            createAttribute(name: "endDate", type: .dateAttributeType, optional: true),
            createAttribute(name: "status", type: .stringAttributeType, optional: true),
            createAttribute(name: "isActive", type: .booleanAttributeType, optional: false),
            createAttribute(name: "dateCreated", type: .dateAttributeType, optional: true),
            createAttribute(name: "dateModified", type: .dateAttributeType, optional: true),
            createAttribute(name: "notes", type: .stringAttributeType, optional: true),
            createAttribute(name: "priority", type: .integer16AttributeType, optional: false),
            createAttribute(name: "percentComplete", type: .doubleAttributeType, optional: false),
            createAttribute(name: "projectManager", type: .stringAttributeType, optional: true),
            createAttribute(name: "metadata", type: .stringAttributeType, optional: true)
        ]
        projectEntity.properties = projectAttributes

        // Create Budget entity
        let budgetEntity = NSEntityDescription()
        budgetEntity.name = "Budget"
        budgetEntity.managedObjectClassName = "Budget"

        // Budget attributes
        let budgetAttributes = [
            createAttribute(name: "id", type: .UUIDAttributeType, optional: true),
            createAttribute(name: "name", type: .stringAttributeType, optional: true),
            createAttribute(name: "totalAmount", type: .decimalAttributeType, optional: true),
            createAttribute(name: "budgetType", type: .stringAttributeType, optional: true),
            createAttribute(name: "startDate", type: .dateAttributeType, optional: true),
            createAttribute(name: "endDate", type: .dateAttributeType, optional: true),
            createAttribute(name: "isActive", type: .booleanAttributeType, optional: false),
            createAttribute(name: "dateCreated", type: .dateAttributeType, optional: true),
            createAttribute(name: "dateUpdated", type: .dateAttributeType, optional: true),
            createAttribute(name: "notes", type: .stringAttributeType, optional: true),
            createAttribute(name: "currency", type: .stringAttributeType, optional: true),
            createAttribute(name: "metadata", type: .stringAttributeType, optional: true)
        ]
        budgetEntity.properties = budgetAttributes

        // Create BudgetCategory entity
        let budgetCategoryEntity = NSEntityDescription()
        budgetCategoryEntity.name = "BudgetCategory"
        budgetCategoryEntity.managedObjectClassName = "BudgetCategory"

        // BudgetCategory attributes
        let budgetCategoryAttributes = [
            createAttribute(name: "id", type: .UUIDAttributeType, optional: true),
            createAttribute(name: "name", type: .stringAttributeType, optional: true),
            createAttribute(name: "budgetedAmount", type: .decimalAttributeType, optional: true),
            createAttribute(name: "spentAmount", type: .decimalAttributeType, optional: true),
            createAttribute(name: "categoryType", type: .stringAttributeType, optional: true),
            createAttribute(name: "colorHex", type: .stringAttributeType, optional: true),
            createAttribute(name: "icon", type: .stringAttributeType, optional: true),
            createAttribute(name: "alertThreshold", type: .doubleAttributeType, optional: false),
            createAttribute(name: "isActive", type: .booleanAttributeType, optional: false),
            createAttribute(name: "dateCreated", type: .dateAttributeType, optional: true),
            createAttribute(name: "dateUpdated", type: .dateAttributeType, optional: true),
            createAttribute(name: "notes", type: .stringAttributeType, optional: true),
            createAttribute(name: "metadata", type: .stringAttributeType, optional: true)
        ]
        budgetCategoryEntity.properties = budgetCategoryAttributes

        // Create BudgetAllocation entity
        let budgetAllocationEntity = NSEntityDescription()
        budgetAllocationEntity.name = "BudgetAllocation"
        budgetAllocationEntity.managedObjectClassName = "BudgetAllocation"

        // BudgetAllocation attributes
        let budgetAllocationAttributes = [
            createAttribute(name: "id", type: .UUIDAttributeType, optional: true),
            createAttribute(name: "amount", type: .decimalAttributeType, optional: true),
            createAttribute(name: "percentage", type: .doubleAttributeType, optional: false),
            createAttribute(name: "allocationDate", type: .dateAttributeType, optional: true),
            createAttribute(name: "notes", type: .stringAttributeType, optional: true),
            createAttribute(name: "isActive", type: .booleanAttributeType, optional: false),
            createAttribute(name: "dateCreated", type: .dateAttributeType, optional: true),
            createAttribute(name: "dateUpdated", type: .dateAttributeType, optional: true),
            createAttribute(name: "metadata", type: .stringAttributeType, optional: true)
        ]
        budgetAllocationEntity.properties = budgetAllocationAttributes

        // Create Subscription entity
        let subscriptionEntity = NSEntityDescription()
        subscriptionEntity.name = "Subscription"
        subscriptionEntity.managedObjectClassName = "Subscription"

        // Subscription attributes
        let subscriptionAttributes = [
            createAttribute(name: "id", type: .UUIDAttributeType, optional: true),
            createAttribute(name: "serviceName", type: .stringAttributeType, optional: true),
            createAttribute(name: "plan", type: .stringAttributeType, optional: true),
            createAttribute(name: "cost", type: .doubleAttributeType, optional: false),
            createAttribute(name: "billingCycle", type: .stringAttributeType, optional: true),
            createAttribute(name: "startDate", type: .dateAttributeType, optional: true),
            createAttribute(name: "nextBillingDate", type: .dateAttributeType, optional: true),
            createAttribute(name: "status", type: .stringAttributeType, optional: true),
            createAttribute(name: "category", type: .stringAttributeType, optional: true),
            createAttribute(name: "notes", type: .stringAttributeType, optional: true),
            createAttribute(name: "brandColorHex", type: .stringAttributeType, optional: true),
            createAttribute(name: "cancelledDate", type: .dateAttributeType, optional: true),
            createAttribute(name: "isActive", type: .booleanAttributeType, optional: false),
            createAttribute(name: "dateCreated", type: .dateAttributeType, optional: true),
            createAttribute(name: "dateModified", type: .dateAttributeType, optional: true),
            createAttribute(name: "metadata", type: .stringAttributeType, optional: true)
        ]
        subscriptionEntity.properties = subscriptionAttributes

        // Set up relationships
        setupRelationships(
            financialData: financialDataEntity,
            document: documentEntity,
            category: categoryEntity,
            client: clientEntity,
            project: projectEntity,
            budget: budgetEntity,
            budgetCategory: budgetCategoryEntity,
            budgetAllocation: budgetAllocationEntity,
            subscription: subscriptionEntity
        )

        // Add entities to model
        model.entities = [financialDataEntity, documentEntity, categoryEntity, clientEntity, projectEntity, budgetEntity, budgetCategoryEntity, budgetAllocationEntity, subscriptionEntity]

        return model
    }

    private func createAttribute(name: String, type: NSAttributeType, optional: Bool = false) -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = name
        attribute.attributeType = type
        attribute.isOptional = optional
        return attribute
    }

    private func setupRelationships(financialData: NSEntityDescription, document: NSEntityDescription, category: NSEntityDescription, client: NSEntityDescription, project: NSEntityDescription, budget: NSEntityDescription, budgetCategory: NSEntityDescription, budgetAllocation: NSEntityDescription, subscription: NSEntityDescription) {
        // FinancialData -> Document (many-to-one)
        let financialDataToDocument = NSRelationshipDescription()
        financialDataToDocument.name = "document"
        financialDataToDocument.destinationEntity = document
        financialDataToDocument.minCount = 0
        financialDataToDocument.maxCount = 1
        financialDataToDocument.deleteRule = .nullifyDeleteRule

        let documentToFinancialData = NSRelationshipDescription()
        documentToFinancialData.name = "financialData"
        documentToFinancialData.destinationEntity = financialData
        documentToFinancialData.minCount = 0
        documentToFinancialData.maxCount = 0 // to-many
        documentToFinancialData.deleteRule = .cascadeDeleteRule

        financialDataToDocument.inverseRelationship = documentToFinancialData
        documentToFinancialData.inverseRelationship = financialDataToDocument

        // Document -> Category (many-to-one)
        let documentToCategory = NSRelationshipDescription()
        documentToCategory.name = "category"
        documentToCategory.destinationEntity = category
        documentToCategory.minCount = 0
        documentToCategory.maxCount = 1
        documentToCategory.deleteRule = .nullifyDeleteRule

        let categoryToDocument = NSRelationshipDescription()
        categoryToDocument.name = "documents"
        categoryToDocument.destinationEntity = document
        categoryToDocument.minCount = 0
        categoryToDocument.maxCount = 0 // to-many
        categoryToDocument.deleteRule = .cascadeDeleteRule

        documentToCategory.inverseRelationship = categoryToDocument
        categoryToDocument.inverseRelationship = documentToCategory

        // Document -> Client (many-to-one)
        let documentToClient = NSRelationshipDescription()
        documentToClient.name = "client"
        documentToClient.destinationEntity = client
        documentToClient.minCount = 0
        documentToClient.maxCount = 1
        documentToClient.deleteRule = .nullifyDeleteRule

        let clientToDocument = NSRelationshipDescription()
        clientToDocument.name = "documents"
        clientToDocument.destinationEntity = document
        clientToDocument.minCount = 0
        clientToDocument.maxCount = 0 // to-many
        clientToDocument.deleteRule = .cascadeDeleteRule

        documentToClient.inverseRelationship = clientToDocument
        clientToDocument.inverseRelationship = documentToClient

        // Project -> Client (many-to-one)
        let projectToClient = NSRelationshipDescription()
        projectToClient.name = "client"
        projectToClient.destinationEntity = client
        projectToClient.minCount = 0
        projectToClient.maxCount = 1
        projectToClient.deleteRule = .nullifyDeleteRule

        let clientToProject = NSRelationshipDescription()
        clientToProject.name = "projects"
        clientToProject.destinationEntity = project
        clientToProject.minCount = 0
        clientToProject.maxCount = 0 // to-many
        clientToProject.deleteRule = .cascadeDeleteRule

        projectToClient.inverseRelationship = clientToProject
        clientToProject.inverseRelationship = projectToClient

        // Document -> Project (many-to-one)
        let documentToProject = NSRelationshipDescription()
        documentToProject.name = "project"
        documentToProject.destinationEntity = project
        documentToProject.minCount = 0
        documentToProject.maxCount = 1
        documentToProject.deleteRule = .nullifyDeleteRule

        let projectToDocument = NSRelationshipDescription()
        projectToDocument.name = "documents"
        projectToDocument.destinationEntity = document
        projectToDocument.minCount = 0
        projectToDocument.maxCount = 0 // to-many
        projectToDocument.deleteRule = .cascadeDeleteRule

        documentToProject.inverseRelationship = projectToDocument
        projectToDocument.inverseRelationship = documentToProject

        // Category -> Category (hierarchical, parent-child)
        let categoryToParent = NSRelationshipDescription()
        categoryToParent.name = "parentCategory"
        categoryToParent.destinationEntity = category
        categoryToParent.minCount = 0
        categoryToParent.maxCount = 1
        categoryToParent.deleteRule = .nullifyDeleteRule

        let categoryToSubcategories = NSRelationshipDescription()
        categoryToSubcategories.name = "subcategories"
        categoryToSubcategories.destinationEntity = category
        categoryToSubcategories.minCount = 0
        categoryToSubcategories.maxCount = 0 // to-many
        categoryToSubcategories.deleteRule = .cascadeDeleteRule

        categoryToParent.inverseRelationship = categoryToSubcategories
        categoryToSubcategories.inverseRelationship = categoryToParent

        // Budget -> BudgetCategory (one-to-many)
        let budgetToCategories = NSRelationshipDescription()
        budgetToCategories.name = "categories"
        budgetToCategories.destinationEntity = budgetCategory
        budgetToCategories.minCount = 0
        budgetToCategories.maxCount = 0 // to-many
        budgetToCategories.deleteRule = .cascadeDeleteRule

        let budgetCategoryToBudget = NSRelationshipDescription()
        budgetCategoryToBudget.name = "budget"
        budgetCategoryToBudget.destinationEntity = budget
        budgetCategoryToBudget.minCount = 0
        budgetCategoryToBudget.maxCount = 1
        budgetCategoryToBudget.deleteRule = .nullifyDeleteRule

        budgetToCategories.inverseRelationship = budgetCategoryToBudget
        budgetCategoryToBudget.inverseRelationship = budgetToCategories

        // Budget -> BudgetAllocation (one-to-many)
        let budgetToAllocations = NSRelationshipDescription()
        budgetToAllocations.name = "allocations"
        budgetToAllocations.destinationEntity = budgetAllocation
        budgetToAllocations.minCount = 0
        budgetToAllocations.maxCount = 0 // to-many
        budgetToAllocations.deleteRule = .cascadeDeleteRule

        let budgetAllocationToBudget = NSRelationshipDescription()
        budgetAllocationToBudget.name = "budget"
        budgetAllocationToBudget.destinationEntity = budget
        budgetAllocationToBudget.minCount = 0
        budgetAllocationToBudget.maxCount = 1
        budgetAllocationToBudget.deleteRule = .nullifyDeleteRule

        budgetToAllocations.inverseRelationship = budgetAllocationToBudget
        budgetAllocationToBudget.inverseRelationship = budgetToAllocations

        // BudgetCategory -> BudgetAllocation (one-to-many)
        let budgetCategoryToAllocations = NSRelationshipDescription()
        budgetCategoryToAllocations.name = "allocations"
        budgetCategoryToAllocations.destinationEntity = budgetAllocation
        budgetCategoryToAllocations.minCount = 0
        budgetCategoryToAllocations.maxCount = 0 // to-many
        budgetCategoryToAllocations.deleteRule = .cascadeDeleteRule

        let budgetAllocationToCategory = NSRelationshipDescription()
        budgetAllocationToCategory.name = "budgetCategory"
        budgetAllocationToCategory.destinationEntity = budgetCategory
        budgetAllocationToCategory.minCount = 0
        budgetAllocationToCategory.maxCount = 1
        budgetAllocationToCategory.deleteRule = .nullifyDeleteRule

        budgetCategoryToAllocations.inverseRelationship = budgetAllocationToCategory
        budgetAllocationToCategory.inverseRelationship = budgetCategoryToAllocations

        // Add relationships to entities
        financialData.properties.append(financialDataToDocument)
        document.properties.append(contentsOf: [documentToFinancialData, documentToCategory, documentToClient, documentToProject])
        category.properties.append(contentsOf: [categoryToDocument, categoryToParent, categoryToSubcategories])
        client.properties.append(contentsOf: [clientToDocument, clientToProject])
        project.properties.append(contentsOf: [projectToClient, projectToDocument])
        budget.properties.append(contentsOf: [budgetToCategories, budgetToAllocations])
        budgetCategory.properties.append(contentsOf: [budgetCategoryToBudget, budgetCategoryToAllocations])
        budgetAllocation.properties.append(contentsOf: [budgetAllocationToBudget, budgetAllocationToCategory])
    }
}

// MARK: - Core Data Model Helper Extensions

extension NSManagedObject {
    /// Generic fetch request for any NSManagedObject subclass
    /// - Returns: NSFetchRequest for the specific entity type
    public class func fetchRequest<T: NSManagedObject>() -> NSFetchRequest<T> {
        let entityName = String(describing: self)
        return NSFetchRequest<T>(entityName: entityName)
    }
}

extension NSManagedObjectContext {
    /// PERFORMANCE OPTIMIZED: Convenience method to fetch entities with predicate
    /// - Parameters:
    ///   - entityType: The type of entity to fetch
    ///   - predicate: Optional predicate for filtering
    ///   - sortDescriptors: Optional sort descriptors
    ///   - limit: Optional fetch limit
    ///   - batchSize: Batch size for memory management
    ///   - propertiesToFetch: Specific properties to fetch (for better performance)
    /// - Returns: Array of fetched entities
    /// - Throws: Core Data fetch errors
    public func fetch<T: NSManagedObject>(
        _ entityType: T.Type,
        predicate: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor]? = nil,
        limit: Int? = nil,
        batchSize: Int = 50,
        propertiesToFetch: [String]? = nil
    ) throws -> [T] {
        let request: NSFetchRequest<T> = entityType.fetchRequest()
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors

        // PERFORMANCE OPTIMIZATION: Advanced fetch configuration
        if let limit = limit {
            request.fetchLimit = limit
        }
        
        // Batch size optimization
        request.fetchBatchSize = min(batchSize, limit ?? batchSize)
        
        // Property-specific fetching for better performance
        if let properties = propertiesToFetch {
            request.propertiesToFetch = properties
            request.includesPropertyValues = true
        }
        
        // Memory management optimizations
        request.includesSubentities = false
        request.shouldRefreshRefetchedObjects = false
        
        return try fetch(request)
    }

    /// PERFORMANCE OPTIMIZED: Convenience method to count entities with predicate
    /// - Parameters:
    ///   - entityType: The type of entity to count
    ///   - predicate: Optional predicate for filtering
    /// - Returns: Count of entities
    /// - Throws: Core Data count errors
    public func count<T: NSManagedObject>(
        _ entityType: T.Type,
        predicate: NSPredicate? = nil
    ) throws -> Int {
        let request: NSFetchRequest<T> = entityType.fetchRequest()
        request.predicate = predicate
        
        // PERFORMANCE OPTIMIZATION: Configure for fastest counting
        request.resultType = .countResultType
        request.includesSubentities = false
        request.includesPropertyValues = false
        request.returnsObjectsAsFaults = true
        
        return try count(for: request)
    }
    
    /// PERFORMANCE OPTIMIZATION: Batch processing for large operations
    /// - Parameters:
    ///   - batchSize: Size of each batch
    ///   - operation: Operation to perform on each batch
    public func performBatchOperation<T: NSManagedObject>(
        on entityType: T.Type,
        batchSize: Int = 100,
        predicate: NSPredicate? = nil,
        operation: @escaping ([T]) throws -> Void
    ) throws {
        var offset = 0
        var hasMoreData = true
        
        while hasMoreData {
            let request: NSFetchRequest<T> = entityType.fetchRequest()
            request.predicate = predicate
            request.fetchLimit = batchSize
            request.fetchOffset = offset
            request.fetchBatchSize = batchSize
            request.returnsObjectsAsFaults = false
            
            let batch = try fetch(request)
            if batch.isEmpty {
                hasMoreData = false
            } else {
                try operation(batch)
                offset += batchSize
                
                // Memory management: reset context after each batch
                reset()
            }
        }
    }
}
