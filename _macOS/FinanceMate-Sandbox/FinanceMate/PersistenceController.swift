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
        let modelURL = Bundle.main.url(forResource: "FinanceMateModel", withExtension: "momd")
        guard let modelURL = modelURL, let model = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Failed to load Core Data model from FinanceMateModel.xcdatamodeld")
        }
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