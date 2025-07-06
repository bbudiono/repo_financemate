import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    /// Shared preview instance for SwiftUI previews and testing
    static let preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        // Add sample data for previews
        let context = controller.container.viewContext
        
        // Create sample transactions for preview
        let sampleTransaction1 = Transaction.create(
            in: context,
            amount: 1250.00,
            category: "Income",
            note: "Salary payment"
        )
        
        let sampleTransaction2 = Transaction.create(
            in: context,
            amount: -89.50,
            category: "Food",
            note: "Grocery shopping"
        )
        
        let sampleTransaction3 = Transaction.create(
            in: context,
            amount: -45.00,
            category: "Transport",
            note: "Gas station"
        )
        
        try? context.save()
        return controller
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        // Create a programmatic Core Data model
        let model = NSManagedObjectModel()
        
        // Create Transaction entity
        let transactionEntity = NSEntityDescription()
        transactionEntity.name = "Transaction"
        transactionEntity.managedObjectClassName = "Transaction"
        
        // Add attributes
        let idAttribute = NSAttributeDescription()
        idAttribute.name = "id"
        idAttribute.attributeType = .UUIDAttributeType
        idAttribute.isOptional = false
        
        let dateAttribute = NSAttributeDescription()
        dateAttribute.name = "date"
        dateAttribute.attributeType = .dateAttributeType
        dateAttribute.isOptional = false
        
        let amountAttribute = NSAttributeDescription()
        amountAttribute.name = "amount"
        amountAttribute.attributeType = .doubleAttributeType
        amountAttribute.isOptional = false
        
        let categoryAttribute = NSAttributeDescription()
        categoryAttribute.name = "category"
        categoryAttribute.attributeType = .stringAttributeType
        categoryAttribute.isOptional = false
        
        let noteAttribute = NSAttributeDescription()
        noteAttribute.name = "note"
        noteAttribute.attributeType = .stringAttributeType
        noteAttribute.isOptional = true
        
        // Create LineItem entity
        let lineItemEntity = NSEntityDescription()
        lineItemEntity.name = "LineItem"
        lineItemEntity.managedObjectClassName = "LineItem"
        
        // LineItem attributes
        let lineItemIdAttribute = NSAttributeDescription()
        lineItemIdAttribute.name = "id"
        lineItemIdAttribute.attributeType = .UUIDAttributeType
        lineItemIdAttribute.isOptional = false
        
        let itemDescriptionAttribute = NSAttributeDescription()
        itemDescriptionAttribute.name = "itemDescription"
        itemDescriptionAttribute.attributeType = .stringAttributeType
        itemDescriptionAttribute.isOptional = false
        
        let lineItemAmountAttribute = NSAttributeDescription()
        lineItemAmountAttribute.name = "amount"
        lineItemAmountAttribute.attributeType = .doubleAttributeType
        lineItemAmountAttribute.isOptional = false
        
        lineItemEntity.properties = [lineItemIdAttribute, itemDescriptionAttribute, lineItemAmountAttribute]
        
        // Create SplitAllocation entity
        let splitAllocationEntity = NSEntityDescription()
        splitAllocationEntity.name = "SplitAllocation"
        splitAllocationEntity.managedObjectClassName = "SplitAllocation"
        
        // SplitAllocation attributes
        let splitIdAttribute = NSAttributeDescription()
        splitIdAttribute.name = "id"
        splitIdAttribute.attributeType = .UUIDAttributeType
        splitIdAttribute.isOptional = false
        
        let percentageAttribute = NSAttributeDescription()
        percentageAttribute.name = "percentage"
        percentageAttribute.attributeType = .doubleAttributeType
        percentageAttribute.isOptional = false
        
        let taxCategoryAttribute = NSAttributeDescription()
        taxCategoryAttribute.name = "taxCategory"
        taxCategoryAttribute.attributeType = .stringAttributeType
        taxCategoryAttribute.isOptional = false
        
        splitAllocationEntity.properties = [splitIdAttribute, percentageAttribute, taxCategoryAttribute]
        
        // Create relationships
        // Transaction -> LineItems (one-to-many)
        let transactionToLineItemsRelationship = NSRelationshipDescription()
        transactionToLineItemsRelationship.name = "lineItems"
        transactionToLineItemsRelationship.destinationEntity = lineItemEntity
        transactionToLineItemsRelationship.minCount = 0
        transactionToLineItemsRelationship.maxCount = 0 // 0 means unlimited for to-many
        transactionToLineItemsRelationship.deleteRule = .cascadeDeleteRule
        
        // LineItem -> Transaction (many-to-one)
        let lineItemToTransactionRelationship = NSRelationshipDescription()
        lineItemToTransactionRelationship.name = "transaction"
        lineItemToTransactionRelationship.destinationEntity = transactionEntity
        lineItemToTransactionRelationship.minCount = 1
        lineItemToTransactionRelationship.maxCount = 1
        lineItemToTransactionRelationship.deleteRule = .nullifyDeleteRule
        
        // LineItem -> SplitAllocations (one-to-many)
        let lineItemToSplitAllocationsRelationship = NSRelationshipDescription()
        lineItemToSplitAllocationsRelationship.name = "splitAllocations"
        lineItemToSplitAllocationsRelationship.destinationEntity = splitAllocationEntity
        lineItemToSplitAllocationsRelationship.minCount = 0
        lineItemToSplitAllocationsRelationship.maxCount = 0 // 0 means unlimited for to-many
        lineItemToSplitAllocationsRelationship.deleteRule = .cascadeDeleteRule
        
        // SplitAllocation -> LineItem (many-to-one)
        let splitAllocationToLineItemRelationship = NSRelationshipDescription()
        splitAllocationToLineItemRelationship.name = "lineItem"
        splitAllocationToLineItemRelationship.destinationEntity = lineItemEntity
        splitAllocationToLineItemRelationship.minCount = 1
        splitAllocationToLineItemRelationship.maxCount = 1
        splitAllocationToLineItemRelationship.deleteRule = .nullifyDeleteRule
        
        // Set up inverse relationships
        transactionToLineItemsRelationship.inverseRelationship = lineItemToTransactionRelationship
        lineItemToTransactionRelationship.inverseRelationship = transactionToLineItemsRelationship
        lineItemToSplitAllocationsRelationship.inverseRelationship = splitAllocationToLineItemRelationship
        splitAllocationToLineItemRelationship.inverseRelationship = lineItemToSplitAllocationsRelationship
        
        // Add relationships to entities
        transactionEntity.properties = [idAttribute, dateAttribute, amountAttribute, categoryAttribute, noteAttribute, transactionToLineItemsRelationship]
        lineItemEntity.properties = [lineItemIdAttribute, itemDescriptionAttribute, lineItemAmountAttribute, lineItemToTransactionRelationship, lineItemToSplitAllocationsRelationship]
        splitAllocationEntity.properties = [splitIdAttribute, percentageAttribute, taxCategoryAttribute, splitAllocationToLineItemRelationship]
        
        model.entities = [transactionEntity, lineItemEntity, splitAllocationEntity]
        
        container = NSPersistentContainer(name: "FinanceMateModel", managedObjectModel: model)
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { description, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
} 