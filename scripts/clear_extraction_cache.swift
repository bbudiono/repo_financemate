#!/usr/bin/env swift
import Foundation
import CoreData

/// Clear poisoned extraction cache from Core Data
/// Run this script to delete all cached Gmail extractions with wrong merchant data
/// After running, re-fetch emails in app to extract with corrected logic

// Path to Core Data store
let storeURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
    .appendingPathComponent("com.ablankcanvas.FinanceMate")
    .appendingPathComponent("FinanceMate.sqlite")

print("📍 Core Data Store: \(storeURL.path)")

// Create persistent container
let container = NSPersistentContainer(name: "FinanceMate")
container.persistentStoreDescriptions = [NSPersistentStoreDescription(url: storeURL)]

var loadError: Error?
container.loadPersistentStores { description, error in
    if let error = error {
        loadError = error
        print("❌ Failed to load store: \(error.localizedDescription)")
    } else {
        print("✅ Store loaded: \(description.url?.lastPathComponent ?? "unknown")")
    }
}

guard loadError == nil else {
    print("\n⚠️  Could not load Core Data store")
    print("   The app must be closed before running this script")
    print("   Run: killall FinanceMate")
    exit(1)
}

let context = container.viewContext

// Query cached extractions (transactions with sourceEmailID)
let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Transaction")
fetchRequest.predicate = NSPredicate(format: "sourceEmailID != nil")

do {
    // Count before deletion
    let countRequest = NSFetchRequest<NSNumber>(entityName: "Transaction")
    countRequest.predicate = NSPredicate(format: "sourceEmailID != nil")
    countRequest.resultType = .countResultType

    let count = try context.count(for: countRequest)
    print("\n📊 Found \(count) cached extraction(s)")

    guard count > 0 else {
        print("✅ Cache already empty - nothing to clear")
        exit(0)
    }

    // Delete all cached extractions
    print("🗑️  Deleting cached extractions...")
    let batchDelete = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    try context.execute(batchDelete)
    try context.save()
    context.reset()

    print("✅ Successfully cleared \(count) cached extraction(s)")
    print("\n📋 NEXT STEPS:")
    print("   1. Launch FinanceMate app")
    print("   2. Navigate to Gmail tab")
    print("   3. Click 'Refresh' to re-fetch emails")
    print("   4. Verify 'defence.gov.au' shows as 'Department of Defence'")
    print("   5. Verify NO emails show 'Bunnings' unless from bunnings.com")

} catch {
    print("❌ Error clearing cache: \(error.localizedDescription)")
    exit(1)
}
