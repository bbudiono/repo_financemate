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
        transactionEntity.managedObjectClassName = "SandboxTransaction"
        
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
        
        transactionEntity.properties = [idAttribute, dateAttribute, amountAttribute, categoryAttribute, noteAttribute]
        model.entities = [transactionEntity]
        
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