#!/usr/bin/env swift
import Foundation

/*
 CACHE POISON CLEANUP SCRIPT
 
 This script provides instructions for clearing poisoned cache from Core Data.
 Poisoned cache occurs when defence.gov.au and other government domains show
 wrong merchants due to cached itemDescription field.
 
 To execute in Swift code:
 ```
 let context = PersistenceController.shared.container.viewContext
 let deleteRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Transaction")
 deleteRequest.predicate = NSPredicate(format: "sourceEmailID != nil")
 let batchDelete = NSBatchDeleteRequest(fetchRequest: deleteRequest)
 
 do {
     try context.execute(batchDelete)
     try context.save()
     context.reset()
     NSLog("[CACHE-CLEAR] Cleared all cached extractions")
 } catch {
     NSLog("[CACHE-ERROR] Failed to clear cache: \(error)")
 }
 ```
 */

print("""
==== CACHE POISON CLEANUP INSTRUCTIONS ====

The cache has been poisoned with wrong merchant data.
This happens when defence.gov.au emails cached as "Bunnings" instead of "Department of Defence".

SOLUTION:
1. Build the app: xcodebuild -scheme FinanceMate build
2. Launch the app in Development
3. Go to Settings tab
4. Clear Gmail cache (if button exists) OR
5. Use Core Data debugging to clear Transaction records with sourceEmailID

The app will re-extract with FIXED logic:
- defence.gov.au -> "Department of Defence"
- goldcoast.qld.gov.au -> "Gold Coast Council"
- ato.gov.au -> "Australian Taxation Office"

After clearing cache:
1. Navigate to Gmail tab
2. Click "Refresh" to re-fetch emails
3. Verify merchants are correct in transaction list

Expected result: Defence emails show "Department of Defence" merchant
""")
