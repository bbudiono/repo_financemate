#!/usr/bin/env swift

import Foundation
import CoreData

// CRITICAL FIX: Invalidate ALL cached Gmail extractions to fix "Bunnings" bug
// The cache was poisoned by re-extraction logic using wrong field (note vs subject)

let storeURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
    .first!
    .appendingPathComponent("com.ablankcanvas.FinanceMate")
    .appendingPathComponent("FinanceMate.sqlite")

print("Store URL: \(storeURL.path)")

let container = NSPersistentContainer(name: "FinanceMate")
container.persistentStoreDescriptions.first?.url = storeURL

container.loadPersistentStores { description, error in
    if let error = error {
        print("ERROR: Failed to load store: \(error)")
        exit(1)
    }
}

let context = container.viewContext

// Find all Gmail-sourced transactions
let request = NSFetchRequest<NSManagedObject>(entityName: "Transaction")
request.predicate = NSPredicate(format: "source == %@", "gmail")

do {
    let transactions = try context.fetch(request)
    print("Found \(transactions.count) Gmail transactions")

    // Delete all cached Gmail transactions
    for transaction in transactions {
        context.delete(transaction)
    }

    try context.save()
    print("✅ Successfully invalidated \(transactions.count) cached extractions")
    print("Next Gmail fetch will re-extract with correct merchant logic")
} catch {
    print("❌ ERROR: \(error)")
    exit(1)
}
