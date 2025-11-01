import CoreData
import os.log

struct PersistenceController {
    private static let logger = Logger(subsystem: "FinanceMate", category: "PersistenceController")

    static let shared = PersistenceController()
    static let preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let viewContext = controller.container.viewContext

        let transaction = Transaction(context: viewContext)

        do {
            try viewContext.save()
        } catch {
            logger.error("Preview save error: \(error.localizedDescription)")
        }
        return controller
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        // Use modular model builder for KISS principle compliance
        container = NSPersistentContainer(name: "FinanceMate", managedObjectModel: PersistenceModelBuilder.createModel())

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { description, error in
            if let error = error {
                Self.logger.error("Core Data load error: \(error.localizedDescription)")
            } else {
                // BLUEPRINT Line 229: Set file protection attributes for Privacy Act compliance
                // macOS approach: Set file attributes after store creation
                if let storeURL = description.url, !inMemory {
                    Self.setFileProtection(for: storeURL)
                }
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    /// Set file protection attributes for Core Data files (macOS approach)
    /// - Parameter url: Core Data store URL
    private static func setFileProtection(for url: URL) {
        do {
            // Protect all SQLite files: main .sqlite, -shm (shared memory), -wal (write-ahead log)
            let sqliteFiles = [
                url.path,  // FinanceMate.sqlite
                url.path + "-shm",  // Shared memory file
                url.path + "-wal"   // Write-ahead log
            ]

            for filePath in sqliteFiles {
                // Skip if file doesn't exist yet (-shm/-wal created later)
                guard FileManager.default.fileExists(atPath: filePath) else { continue }

                // Set POSIX permissions: owner read/write only (0600)
                try FileManager.default.setAttributes(
                    [.posixPermissions: 0o600],  // rw------- (owner only)
                    ofItemAtPath: filePath
                )
            }

            // Secure the directory: owner access only (0700)
            let secureDir = url.deletingLastPathComponent()
            try FileManager.default.setAttributes(
                [.posixPermissions: 0o700],  // rwx------ (directory owner only)
                ofItemAtPath: secureDir.path
            )

            logger.info("Core Data file protection applied: POSIX 0600 (owner read/write only)")
            logger.info("Protected files: .sqlite, -shm, -wal")
            logger.info("Note: macOS relies on FileVault for disk-level encryption")
        } catch {
            logger.error("Failed to set file protection: \(error.localizedDescription)")
        }
    }

    // MARK: - Data Deletion (Privacy Act Compliance - BLUEPRINT Line 231)

    /// Delete all data for account removal (Privacy Act requirement)
    /// Uses NSBatchDeleteRequest for performance with large datasets
    func deleteAll() throws {
        let context = container.viewContext

        // Entity names in order (delete children first to maintain referential integrity)
        let entityNames = ["SplitAllocation", "LineItem", "ExtractionMetrics", "ExtractionFeedback", "Transaction", "GmailEmail"]

        for entityName in entityNames {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            batchDeleteRequest.resultType = .resultTypeObjectIDs

            do {
                let result = try context.execute(batchDeleteRequest) as? NSBatchDeleteResult
                let objectIDArray = result?.result as? [NSManagedObjectID] ?? []

                // Merge changes into context
                let changes = [NSDeletedObjectsKey: objectIDArray]
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context])

                Self.logger.info("Deleted all \(entityName) records: \(objectIDArray.count) items")
            } catch {
                Self.logger.error("Failed to delete \(entityName): \(error.localizedDescription)")
                throw error
            }
        }

        // Save context to persist deletions
        try context.save()
        Self.logger.info("All user data deleted successfully (Privacy Act compliance)")
    }

    /// Clear cache and refresh in-memory objects
    func clear() {
        container.viewContext.refreshAllObjects()  // Clear in-memory cache
        Self.logger.info("Cache cleared")
    }
}
