import Foundation
import CoreData

// --- MOCK SERVICES ---

// Mock TransactionValidationService for testing
class MockTransactionValidationService {
    static let shared = MockTransactionValidationService()
    
    func validateTransaction(_ properties: [String: Any]) throws {
        if let amount = properties["amount"] as? Double {
            if amount > 1_000_000 {
                throw NSError(domain: "Validation", code: 1, userInfo: [NSLocalizedDescriptionKey: "Amount too high"])
            }
        }
    }
}

// --- CORE DATA STACK ---

let model = NSManagedObjectModel()

// Transaction Entity
let transactionEntity = NSEntityDescription()
transactionEntity.name = "Transaction"
transactionEntity.managedObjectClassName = "Transaction"

// Attributes
let idAttr = NSAttributeDescription()
idAttr.name = "id"
idAttr.attributeType = .UUIDAttributeType
idAttr.isOptional = false

let amountAttr = NSAttributeDescription()
amountAttr.name = "amount"
amountAttr.attributeType = .doubleAttributeType
amountAttr.isOptional = false

let categoryAttr = NSAttributeDescription()
categoryAttr.name = "category"
categoryAttr.attributeType = .stringAttributeType
categoryAttr.isOptional = true

let dateAttr = NSAttributeDescription()
dateAttr.name = "date"
dateAttr.attributeType = .dateAttributeType
dateAttr.isOptional = true

let noteAttr = NSAttributeDescription()
noteAttr.name = "note"
noteAttr.attributeType = .stringAttributeType
noteAttr.isOptional = true

transactionEntity.properties = [idAttr, amountAttr, categoryAttr, dateAttr, noteAttr]
model.entities = [transactionEntity]

let container = NSPersistentContainer(name: "TestContainer", managedObjectModel: model)
let description = NSPersistentStoreDescription()
description.type = NSSQLiteStoreType
let tempDir = FileManager.default.temporaryDirectory
let dbURL = tempDir.appendingPathComponent("ValidationTest.sqlite")
// Clean up previous run
try? FileManager.default.removeItem(at: dbURL)
try? FileManager.default.removeItem(at: dbURL.appendingPathExtension("shm"))
try? FileManager.default.removeItem(at: dbURL.appendingPathExtension("wal"))

description.url = dbURL
container.persistentStoreDescriptions = [description]

container.loadPersistentStores { (desc, error) in
    if let error = error {
        fatalError("Failed to load store: \(error)")
    }
}

// --- TEST CASES ---

func testBatchInsertValidation() {
    print("Testing Batch Insert Validation...")
    
    let context = container.newBackgroundContext()
    
    let validItem: [String: Any] = [
        "id": UUID(),
        "amount": 100.0,
        "category": "Groceries",
        "date": Date(),
        "note": "Valid Item"
    ]
    
    let invalidItem: [String: Any] = [
        "id": UUID(),
        "amount": 2_000_000.0, // Invalid amount > 1M
        "category": "Luxury",
        "date": Date(),
        "note": "Invalid Item"
    ]
    
    let objects = [validItem, invalidItem]
    
    // Simulate BatchOperationsService logic
    var validObjects = [[String: Any]]()
    for object in objects {
        do {
            try MockTransactionValidationService.shared.validateTransaction(object)
            validObjects.append(object)
        } catch {
            print("  ✅ Caught invalid item: \(error.localizedDescription)")
        }
    }
    
    if validObjects.count == 1 {
        print("  ✅ Validation filtered correctly (1 valid, 1 invalid)")
    } else {
        print("  ❌ Validation failed to filter correctly. Count: \(validObjects.count)")
        exit(1)
    }
    
    // Perform insert
    let request = NSBatchInsertRequest(entityName: "Transaction", objects: validObjects)
    request.resultType = .objectIDs
    
    do {
        let result = try context.execute(request) as? NSBatchInsertResult
        let ids = result?.result as? [NSManagedObjectID] ?? []
        
        if ids.count == 1 {
            print("  ✅ Batch insert succeeded with 1 item")
        } else {
            print("  ❌ Batch insert count mismatch. Expected 1, got \(ids.count)")
            exit(1)
        }
    } catch {
        print("  ❌ Batch insert failed: \(error)")
        exit(1)
    }
}

// --- RUN TESTS ---

testBatchInsertValidation()

print("\nAll validation tests passed!")
