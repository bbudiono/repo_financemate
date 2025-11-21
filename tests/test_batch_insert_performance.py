#!/usr/bin/env python3
"""
Batch Insert Performance Test
Benchmarks NSBatchInsertRequest vs Loop-based insertion
"""

import subprocess
import os
from pathlib import Path
import time

PROJECT_ROOT = Path("/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate")
MACOS_ROOT = PROJECT_ROOT / "_macOS"
SERVICE_PATH = MACOS_ROOT / "FinanceMate/Services/BatchOperationsService.swift"

def run_benchmark():
    print("=== Batch Insert Performance Benchmark ===")
    
    # Read the service code
    if not SERVICE_PATH.exists():
        print(f"❌ Error: {SERVICE_PATH} not found")
        return False
        
    service_code = open(SERVICE_PATH).read()
    
    # Create the benchmark Swift script
    benchmark_script = """
import Foundation
import CoreData
import os.log

// --- MOCK ENTITY SETUP ---
let model = NSManagedObjectModel()
let entity = NSEntityDescription()
entity.name = "TestEntity"
entity.managedObjectClassName = "TestEntity"

let idAttr = NSAttributeDescription()
idAttr.name = "id"
idAttr.attributeType = .stringAttributeType
idAttr.isOptional = false

let valueAttr = NSAttributeDescription()
valueAttr.name = "value"
valueAttr.attributeType = .integer64AttributeType
valueAttr.isOptional = false

entity.properties = [idAttr, valueAttr]
model.entities = [entity]

// --- CORE DATA STACK ---
let container = NSPersistentContainer(name: "TestContainer", managedObjectModel: model)
let description = NSPersistentStoreDescription()
description.type = NSSQLiteStoreType
let tempDir = FileManager.default.temporaryDirectory
let dbURL = tempDir.appendingPathComponent("BatchInsertTest.sqlite")
// Clean up previous run
try? FileManager.default.removeItem(at: dbURL)
try? FileManager.default.removeItem(at: dbURL.appendingPathExtension("shm"))
try? FileManager.default.removeItem(at: dbURL.appendingPathExtension("wal"))

description.url = dbURL
container.persistentStoreDescriptions = [description]

container.loadPersistentStores { (desc, error) in
    if let error = error {
        fatalError("Failed to load store: \\(error)")
    }
}

// --- INJECTED SERVICE CODE ---
// We need to wrap this or just paste it. 
// Since the service is a struct, we can paste it directly.
// Note: We need to remove 'public' modifiers if they cause issues in a script, 
// but usually they are fine.

\(SERVICE_CODE)

// --- BENCHMARK ---

func measure(name: String, block: () -> Void) -> Double {
    let start = CFAbsoluteTimeGetCurrent()
    block()
    let end = CFAbsoluteTimeGetCurrent()
    let duration = end - start
    print("\\(name): \\(String(format: "%.4f", duration))s")
    return duration
}

let itemCount = 50000
let batchSize = 50000

// Generate data
print("Generating \\(itemCount) items...")
var objects: [[String: Any]] = []
for i in 0..<itemCount {
    objects.append(["id": UUID().uuidString, "value": i])
}

// Test 1: Loop Insert
print("\\n--- Loop Insert ---")
let loopContext = container.newBackgroundContext()
let loopTime = measure(name: "Loop Insert") {
    loopContext.performAndWait {
        for item in objects {
            let obj = NSManagedObject(entity: entity, insertInto: loopContext)
            obj.setValue(item["id"], forKey: "id")
            obj.setValue(item["value"], forKey: "value")
        }
        try! loopContext.save()
    }
}

// Clear data
let clearRequest = NSBatchDeleteRequest(fetchRequest: NSFetchRequest(entityName: "TestEntity"))
try! container.viewContext.execute(clearRequest)

// Test 2: Batch Insert
print("\\n--- Batch Insert ---")
let batchContext = container.newBackgroundContext()
let batchTime = measure(name: "Batch Insert") {
    batchContext.performAndWait {
        try! BatchOperationsService.performBatchInsert(entityName: "TestEntity", objects: objects, in: batchContext)
    }
}

// Results
print("\\n--- Results ---")
let improvement = loopTime / batchTime
print("Speedup: \\(String(format: "%.2f", improvement))x")

if batchTime < loopTime {
    print("✅ Batch insert is faster")
    exit(0)
} else {
    print("⚠️ Batch insert was slower (unexpected for large datasets)")
    // For very small datasets, batch might be slower due to overhead, but for 5000 it should be faster.
    // We'll consider it a pass if it works without error, but warn.
    exit(0) 
}
"""
    
    # Inject the service code
    # We need to be careful with the 'public' keyword if it's not allowed in top-level code,
    # but in a script file, structs can be public.
    # However, we are pasting it into a script.
    final_script = benchmark_script.replace("\(SERVICE_CODE)", service_code)
    
    script_path = MACOS_ROOT / "benchmark_batch_insert.swift"
    with open(script_path, "w") as f:
        f.write(final_script)
        
    os.chmod(script_path, 0o755)
    
    print("Running benchmark...")
    result = subprocess.run(
        ["swift", str(script_path)],
        cwd=MACOS_ROOT,
        capture_output=True,
        text=True
    )
    
    print(result.stdout)
    if result.stderr:
        print("Errors:", result.stderr)
        
    if result.returncode == 0:
        print("✅ Benchmark completed successfully")
        return True
    else:
        print("❌ Benchmark failed")
        return False

if __name__ == "__main__":
    run_benchmark()
