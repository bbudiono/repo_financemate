import XCTest
import CoreData
@testable import FinanceMate

final class CoreDataTests: XCTestCase {
    var persistenceController: PersistenceController!
    var context: NSManagedObjectContext!

    override func setUpWithError() throws {
        persistenceController = PersistenceController(inMemory: true)
        
        // FORCE main thread context for headless testing - resolves threading violations
        if ProcessInfo.processInfo.environment["HEADLESS_MODE"] == "1" || 
           ProcessInfo.processInfo.environment["UI_TESTING"] == "1" {
            context = MainActor.assumeIsolated {
                persistenceController.container.viewContext
            }
        } else {
            context = persistenceController.container.viewContext
        }
        
        // Ensure context is properly configured for testing
        context.automaticallyMergesChangesFromParent = true
        context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
    }

    override func tearDownWithError() throws {
        // AGGRESSIVE cleanup for test isolation - prevents data pollution between tests
        if let context = context {
            let entityNames = ["Transaction", "LineItem", "SplitAllocation", "FinancialEntity", "NetWealthSnapshot"]
            
            for entityName in entityNames {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                
                do {
                    try context.execute(deleteRequest)
                    try context.save()
                } catch {
                    print("⚠️ Cleanup failed for \(entityName): \(error)")
                }
            }
            
            context.reset()
        }
        
        persistenceController = nil
        context = nil
        super.tearDown()
    }

    func testTransactionCreationAndFetch() throws {
        // Create
        let tx = Transaction.create(in: context, amount: 42.0, category: "Test", note: "UnitTest")
        try context.save()

        // Fetch
        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        let results = try context.fetch(request)
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.amount, 42.0)
        XCTAssertEqual(results.first?.category, "Test")
        XCTAssertEqual(results.first?.note, "UnitTest")
    }

    func testTransactionLineItemSplitting() throws {
        // 1. Create a Transaction
        let tx = Transaction.create(in: context, amount: 100.0, category: "Test", note: "LineItemTest")
        
        // 2. Create two LineItems (e.g., "Laptop", "Mouse")
        let laptopItem = LineItem.create(in: context, itemDescription: "Laptop", amount: 80.0, transaction: tx)
        let mouseItem = LineItem.create(in: context, itemDescription: "Mouse", amount: 20.0, transaction: tx)
        
        // 3. For each LineItem, create SplitAllocations (e.g., 70% Business, 30% Personal)
        let laptopBusinessSplit = SplitAllocation.create(in: context, percentage: 70.0, taxCategory: "Business", lineItem: laptopItem)
        let laptopPersonalSplit = SplitAllocation.create(in: context, percentage: 30.0, taxCategory: "Personal", lineItem: laptopItem)
        
        let mouseBusinessSplit = SplitAllocation.create(in: context, percentage: 100.0, taxCategory: "Business", lineItem: mouseItem)
        
        // 4. Save context
        try context.save()
        
        // 5. Fetch Transaction and verify:
        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        let results = try context.fetch(request)
        
        XCTAssertEqual(results.count, 1)
        let fetchedTransaction = results.first!
        
        // - It has 2 LineItems
        let lineItems = Array(fetchedTransaction.lineItems)
        XCTAssertEqual(lineItems.count, 2)
        
        // - Each LineItem has correct SplitAllocations
        let laptopLineItem = lineItems.first { $0.itemDescription == "Laptop" }!
        let mouseLineItem = lineItems.first { $0.itemDescription == "Mouse" }!
        
        let laptopSplitAllocations = laptopLineItem.splitAllocations?.allObjects as? [SplitAllocation] ?? []
        let mouseSplitAllocations = mouseLineItem.splitAllocations?.allObjects as? [SplitAllocation] ?? []
        XCTAssertEqual(laptopSplitAllocations.count, 2)
        XCTAssertEqual(mouseSplitAllocations.count, 1)
        
        // - Each LineItem's splits sum to 100%
        let laptopTotalPercentage = laptopSplitAllocations.reduce(0.0) { $0 + $1.percentage }
        let mouseTotalPercentage = mouseSplitAllocations.reduce(0.0) { $0 + $1.percentage }
        
        XCTAssertEqual(laptopTotalPercentage, 100.0, accuracy: 0.01)
        XCTAssertEqual(mouseTotalPercentage, 100.0, accuracy: 0.01)
        
        // Verify specific split allocations
        let laptopSplits = laptopSplitAllocations
        let businessSplit = laptopSplits.first { $0.taxCategory == "Business" }!
        let personalSplit = laptopSplits.first { $0.taxCategory == "Personal" }!
        
        XCTAssertEqual(businessSplit.percentage, 70.0, accuracy: 0.01)
        XCTAssertEqual(personalSplit.percentage, 30.0, accuracy: 0.01)
    }
    
    // MARK: - FinancialEntity Tests
    
    func testFinancialEntityCreation() throws {
        // Test creating a financial entity with valid data
        let entity = FinancialEntity(context: context)
        entity.id = UUID()
        entity.name = "Test Personal Entity"
        entity.type = "Personal"
        entity.isActive = true
        entity.createdAt = Date()
        entity.lastModified = Date()
        
        try context.save()
        
        XCTAssertNotNil(entity.id)
        XCTAssertEqual(entity.name, "Test Personal Entity")
        XCTAssertEqual(entity.type, "Personal")
        XCTAssertTrue(entity.isActive)
        XCTAssertNotNil(entity.createdAt)
        XCTAssertNotNil(entity.lastModified)
    }
    
    func testFinancialEntityTypes() throws {
        // Test all valid entity types
        let validTypes = ["Personal", "Business", "Trust", "Investment"]
        
        for (index, type) in validTypes.enumerated() {
            let entity = FinancialEntity(context: context)
            entity.id = UUID()
            entity.name = "Test Entity \(index)"
            entity.type = type
            entity.isActive = true
            entity.createdAt = Date()
            entity.lastModified = Date()
            
            XCTAssertEqual(entity.type, type)
        }
        
        try context.save()
        
        // Verify all entities were saved
        let fetchRequest: NSFetchRequest<FinancialEntity> = FinancialEntity.fetchRequest()
        let results = try context.fetch(fetchRequest)
        XCTAssertEqual(results.count, 4)
    }
    
    func testFinancialEntityHierarchy() throws {
        // Create parent entity
        let parentEntity = FinancialEntity(context: context)
        parentEntity.id = UUID()
        parentEntity.name = "Parent Trust"
        parentEntity.type = "Trust"
        parentEntity.isActive = true
        parentEntity.createdAt = Date()
        parentEntity.lastModified = Date()
        
        // Create child entity
        let childEntity = FinancialEntity(context: context)
        childEntity.id = UUID()
        childEntity.name = "Child Business"
        childEntity.type = "Business"
        childEntity.isActive = true
        childEntity.createdAt = Date()
        childEntity.lastModified = Date()
        childEntity.parentEntity = parentEntity
        
        try context.save()
        
        // Test parent-child relationships
        XCTAssertEqual(parentEntity.childEntities.count, 1)
        XCTAssertTrue(parentEntity.childEntities.contains(childEntity))
        XCTAssertEqual(childEntity.parentEntity, parentEntity)
        XCTAssertNil(parentEntity.parentEntity)
    }
    
    func testFinancialEntityCRUD() throws {
        // MINIMAL TEST: Just check if we can create and save an entity
        let entity = FinancialEntity(context: context)
        entity.id = UUID()
        entity.name = "Minimal Test"
        entity.type = "Personal"
        entity.isActive = true
        entity.createdAt = Date()
        entity.lastModified = Date()
        
        // This is the critical test - can we save?
        do {
            try context.save()
            print("✅ Context save succeeded")
        } catch {
            XCTFail("Failed to save context: \(error)")
            return
        }
        
        // Basic assertion - entity should have properties set
        XCTAssertEqual(entity.name, "Minimal Test")
        XCTAssertEqual(entity.type, "Personal")
        XCTAssertTrue(entity.isActive)
        
        // MINIMAL READ TEST: Can we fetch anything at all?
        let request = NSFetchRequest<FinancialEntity>(entityName: "FinancialEntity")
        
        do {
            let results = try context.fetch(request)
            print("✅ Fetch succeeded, found \(results.count) entities")
            XCTAssertGreaterThan(results.count, 0, "Should have at least one entity")
        } catch {
            XCTFail("Failed to fetch entities: \(error)")
        }
    }
    
    func testFinancialEntityActivation() throws {
        let entity = FinancialEntity(context: context)
        entity.id = UUID()
        entity.name = "Activation Test"
        entity.type = "Personal"
        entity.isActive = true
        entity.createdAt = Date()
        entity.lastModified = Date()
        
        try context.save()
        
        // Test initial state
        XCTAssertTrue(entity.isActive)
        
        // Deactivate
        entity.deactivate()
        try context.save()
        XCTAssertFalse(entity.isActive)
        
        // Reactivate
        entity.activate()
        try context.save()
        XCTAssertTrue(entity.isActive)
    }
} 