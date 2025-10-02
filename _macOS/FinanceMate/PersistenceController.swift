import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    static let preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let viewContext = controller.container.viewContext

        let transaction = Transaction(context: viewContext)

        do {
            try viewContext.save()
        } catch {
            print("Preview save error: \(error.localizedDescription)")
        }
        return controller
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "FinanceMate", managedObjectModel: Self.createModel())

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data load error: \(error.localizedDescription)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    private static func createModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        // MARK: - LineItem Entity

        let lineItemEntity = NSEntityDescription()
        lineItemEntity.name = "LineItem"
        lineItemEntity.managedObjectClassName = "LineItem"

        let lineItemId = NSAttributeDescription()
        lineItemId.name = "id"
        lineItemId.attributeType = .UUIDAttributeType
        lineItemId.isOptional = false

        let lineItemDescription = NSAttributeDescription()
        lineItemDescription.name = "itemDescription"
        lineItemDescription.attributeType = .stringAttributeType
        lineItemDescription.isOptional = false
        lineItemDescription.defaultValue = ""

        let lineItemQuantity = NSAttributeDescription()
        lineItemQuantity.name = "quantity"
        lineItemQuantity.attributeType = .integer32AttributeType
        lineItemQuantity.isOptional = false
        lineItemQuantity.defaultValue = 1

        let lineItemPrice = NSAttributeDescription()
        lineItemPrice.name = "price"
        lineItemPrice.attributeType = .doubleAttributeType
        lineItemPrice.isOptional = false
        lineItemPrice.defaultValue = 0.0

        let lineItemTaxCategory = NSAttributeDescription()
        lineItemTaxCategory.name = "taxCategory"
        lineItemTaxCategory.attributeType = .stringAttributeType
        lineItemTaxCategory.isOptional = false
        lineItemTaxCategory.defaultValue = "Personal"

        lineItemEntity.properties = [lineItemId, lineItemDescription, lineItemQuantity, lineItemPrice, lineItemTaxCategory]

        // MARK: - Transaction Entity

        let transactionEntity = NSEntityDescription()
        transactionEntity.name = "Transaction"
        transactionEntity.managedObjectClassName = "Transaction"

        let idAttr = NSAttributeDescription()
        idAttr.name = "id"
        idAttr.attributeType = .UUIDAttributeType
        idAttr.isOptional = false

        let amountAttr = NSAttributeDescription()
        amountAttr.name = "amount"
        amountAttr.attributeType = .doubleAttributeType
        amountAttr.isOptional = false
        amountAttr.defaultValue = 0.0

        let descAttr = NSAttributeDescription()
        descAttr.name = "itemDescription"
        descAttr.attributeType = .stringAttributeType
        descAttr.isOptional = false
        descAttr.defaultValue = ""

        let dateAttr = NSAttributeDescription()
        dateAttr.name = "date"
        dateAttr.attributeType = .dateAttributeType
        dateAttr.isOptional = false

        let sourceAttr = NSAttributeDescription()
        sourceAttr.name = "source"
        sourceAttr.attributeType = .stringAttributeType
        sourceAttr.isOptional = false
        sourceAttr.defaultValue = "manual"

        let categoryAttr = NSAttributeDescription()
        categoryAttr.name = "category"
        categoryAttr.attributeType = .stringAttributeType
        categoryAttr.isOptional = false
        categoryAttr.defaultValue = "Other"

        let noteAttr = NSAttributeDescription()
        noteAttr.name = "note"
        noteAttr.attributeType = .stringAttributeType
        noteAttr.isOptional = true

        let taxCategoryAttr = NSAttributeDescription()
        taxCategoryAttr.name = "taxCategory"
        taxCategoryAttr.attributeType = .stringAttributeType
        taxCategoryAttr.isOptional = false
        taxCategoryAttr.defaultValue = "Personal"

        transactionEntity.properties = [idAttr, amountAttr, descAttr, dateAttr, sourceAttr, categoryAttr, noteAttr, taxCategoryAttr]

        // MARK: - Relationships

        let lineItemsRelationship = NSRelationshipDescription()
        lineItemsRelationship.name = "lineItems"
        lineItemsRelationship.destinationEntity = lineItemEntity
        lineItemsRelationship.minCount = 0
        lineItemsRelationship.maxCount = 0
        lineItemsRelationship.deleteRule = .cascadeDeleteRule
        lineItemsRelationship.isOptional = true

        let transactionRelationship = NSRelationshipDescription()
        transactionRelationship.name = "transaction"
        transactionRelationship.destinationEntity = transactionEntity
        transactionRelationship.minCount = 0
        transactionRelationship.maxCount = 1
        transactionRelationship.deleteRule = .nullifyDeleteRule
        transactionRelationship.isOptional = true

        lineItemsRelationship.inverseRelationship = transactionRelationship
        transactionRelationship.inverseRelationship = lineItemsRelationship

        transactionEntity.properties.append(lineItemsRelationship)
        lineItemEntity.properties.append(transactionRelationship)

        model.entities = [transactionEntity, lineItemEntity]
        return model
    }
}
