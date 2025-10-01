import CoreData

/// Core Data persistence controller
/// BLUEPRINT: Simple Transaction entity only (for MVP)
struct PersistenceController {
    static let shared = PersistenceController()
    static let preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let viewContext = controller.container.viewContext

        // Add preview data
        let transaction = Transaction(context: viewContext)
        transaction.id = UUID()
        transaction.amount = 99.50
        transaction.itemDescription = "Preview transaction"
        transaction.date = Date()
        transaction.source = "preview"

        try? viewContext.save()
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
                fatalError("Core Data failed to load: \(error)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    /// Create programmatic Core Data model
    private static func createModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        // Transaction entity
        let transactionEntity = NSEntityDescription()
        transactionEntity.name = "Transaction"
        transactionEntity.managedObjectClassName = "Transaction"

        // Attributes
        let idAttr = NSAttributeDescription()
        idAttr.name = "id"
        idAttr.attributeType = .UUIDAttributeType

        let amountAttr = NSAttributeDescription()
        amountAttr.name = "amount"
        amountAttr.attributeType = .doubleAttributeType

        let descAttr = NSAttributeDescription()
        descAttr.name = "itemDescription"
        descAttr.attributeType = .stringAttributeType
        descAttr.isOptional = true

        let dateAttr = NSAttributeDescription()
        dateAttr.name = "date"
        dateAttr.attributeType = .dateAttributeType
        dateAttr.isOptional = true

        let sourceAttr = NSAttributeDescription()
        sourceAttr.name = "source"
        sourceAttr.attributeType = .stringAttributeType
        sourceAttr.isOptional = true

        transactionEntity.properties = [idAttr, amountAttr, descAttr, dateAttr, sourceAttr]

        model.entities = [transactionEntity]
        return model
    }
}
