#!/usr/bin/env swift
import Foundation
import CoreData

// MARK: - Configuration

let jsonPath = "synthetic_transactions_50k.json"
let containerName = "FinanceMate"
let appBundleID = "com.ablankcanvas.financemate"

// MARK: - Core Data Stack Setup

// Define the model programmatically (matching PersistenceModelBuilder.swift)
func createModel() -> NSManagedObjectModel {
    let model = NSManagedObjectModel()

    // Transaction Entity
    let transactionEntity = NSEntityDescription()
    transactionEntity.name = "Transaction"
    transactionEntity.managedObjectClassName = "Transaction"

    // Attributes
    let id = createAttribute(name: "id", type: .UUIDAttributeType, optional: false)
    let amount = createAttribute(name: "amount", type: .doubleAttributeType, optional: false, defaultValue: 0.0)
    let itemDescription = createAttribute(name: "itemDescription", type: .stringAttributeType, optional: false, defaultValue: "")
    let date = createAttribute(name: "date", type: .dateAttributeType, optional: false)
    let source = createAttribute(name: "source", type: .stringAttributeType, optional: false, defaultValue: "manual")
    let category = createAttribute(name: "category", type: .stringAttributeType, optional: false, defaultValue: "Other")
    let note = createAttribute(name: "note", type: .stringAttributeType, optional: true)
    let taxCategory = createAttribute(name: "taxCategory", type: .stringAttributeType, optional: true)
    let sourceEmailID = createAttribute(name: "sourceEmailID", type: .stringAttributeType, optional: true)
    let importedDate = createAttribute(name: "importedDate", type: .dateAttributeType, optional: true)
    let emailSource = createAttribute(name: "emailSource", type: .stringAttributeType, optional: true)
    let transactionType = createAttribute(name: "transactionType", type: .stringAttributeType, optional: false, defaultValue: "expense")
    let contentHash = createAttribute(name: "contentHash", type: .integer64AttributeType, optional: false, defaultValue: 0)
    let externalTransactionId = createAttribute(name: "externalTransactionId", type: .stringAttributeType, optional: true)

    transactionEntity.properties = [id, amount, itemDescription, date, source, category, note, taxCategory,
                                  sourceEmailID, importedDate, transactionType, contentHash, emailSource, externalTransactionId]
    
    // Add uniqueness constraint
    transactionEntity.uniquenessConstraints = [[sourceEmailID]]

    // LineItem Entity (needed for relationship)
    let lineItemEntity = NSEntityDescription()
    lineItemEntity.name = "LineItem"
    lineItemEntity.managedObjectClassName = "LineItem"
    let li_id = createAttribute(name: "id", type: .UUIDAttributeType, optional: false)
    lineItemEntity.properties = [li_id]

    // Relationships
    let lineItemsRel = NSRelationshipDescription()
    lineItemsRel.name = "lineItems"
    lineItemsRel.destinationEntity = lineItemEntity
    lineItemsRel.minCount = 0
    lineItemsRel.maxCount = 0
    lineItemsRel.deleteRule = .cascadeDeleteRule
    lineItemsRel.isOptional = true

    let transactionRel = NSRelationshipDescription()
    transactionRel.name = "transaction"
    transactionRel.destinationEntity = transactionEntity
    transactionRel.minCount = 0
    transactionRel.maxCount = 1
    transactionRel.deleteRule = .nullifyDeleteRule
    transactionRel.isOptional = true

    lineItemsRel.inverseRelationship = transactionRel
    transactionRel.inverseRelationship = lineItemsRel

    transactionEntity.properties.append(lineItemsRel)
    lineItemEntity.properties.append(transactionRel)

    model.entities = [transactionEntity, lineItemEntity]
    return model
}

func createAttribute(name: String, type: NSAttributeType, optional: Bool, defaultValue: Any? = nil) -> NSAttributeDescription {
    let attr = NSAttributeDescription()
    attr.name = name
    attr.attributeType = type
    attr.isOptional = optional
    if let defaultValue = defaultValue {
        attr.defaultValue = defaultValue
    }
    return attr
}

// MARK: - Main Execution

print("🚀 Starting 50k Transaction Import...")

// 1. Locate Database
let home = FileManager.default.homeDirectoryForCurrentUser
let dbURL = home.appendingPathComponent("Library/Containers/\(appBundleID)/Data/Library/Application Support/\(containerName)/\(containerName).sqlite")

print("📂 Database path: \(dbURL.path)")

if !FileManager.default.fileExists(atPath: dbURL.path) {
    print("❌ Database not found at \(dbURL.path)")
    print("   Please run the app once to create the database.")
    exit(1)
}

// 2. Setup Core Data Stack
let model = createModel()
let psc = NSPersistentStoreCoordinator(managedObjectModel: model)

do {
    try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: dbURL, options: [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true])
} catch {
    print("❌ Failed to add persistent store: \(error)")
    exit(1)
}

let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
context.persistentStoreCoordinator = psc

// 3. Load JSON Data
let jsonURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent(jsonPath)
guard let jsonData = try? Data(contentsOf: jsonURL) else {
    print("❌ Failed to read JSON file at \(jsonURL.path)")
    exit(1)
}

struct RawTransaction: Decodable {
    let merchant: String
    let amount: String
    let date: String
    let category: String
    let gst: String
    let description: String
}

guard let rawTransactions = try? JSONDecoder().decode([RawTransaction].self, from: jsonData) else {
    print("❌ Failed to decode JSON")
    exit(1)
}

print("✅ Loaded \(rawTransactions.count) transactions from JSON")

// 4. Batch Insert
print("⏳ Inserting into Core Data (this may take a moment)...")

let batchSize = 5000
let total = rawTransactions.count
var imported = 0

context.performAndWait {
    // Process in batches to manage memory
    for i in stride(from: 0, to: total, by: batchSize) {
        let end = min(i + batchSize, total)
        let batch = rawTransactions[i..<end]
        
        for raw in batch {
            let entity = NSEntityDescription.insertNewObject(forEntityName: "Transaction", into: context)
            
            // Map fields
            entity.setValue(UUID(), forKey: "id")
            entity.setValue(Double(raw.amount) ?? 0.0, forKey: "amount")
            entity.setValue(raw.merchant, forKey: "itemDescription")
            entity.setValue("synthetic", forKey: "source")
            entity.setValue(raw.category, forKey: "category")
            entity.setValue(raw.description, forKey: "note")
            entity.setValue("expense", forKey: "transactionType")
            
            // Date parsing
            if let date = ISO8601DateFormatter().date(from: raw.date) {
                entity.setValue(date, forKey: "date")
            } else {
                entity.setValue(Date(), forKey: "date")
            }
        }
        
        // Save batch
        do {
            try context.save()
            context.reset() // Clear memory
            imported += batch.count
            print("   Imported \(imported)/\(total)...")
        } catch {
            print("❌ Failed to save batch: \(error)")
        }
    }
}

print("✅ Import Complete! \(imported) transactions added.")
print("   You can now launch the app to validate performance.")
