import CoreData
import Foundation

/// GmailEmailRepository handles persistent storage and delta sync of Gmail emails
/// BLUEPRINT Line 74: Replaces 1-hour cache with permanent Core Data storage
/// BLUEPRINT Line 91: Implements delta sync to only fetch new emails
class GmailEmailRepository {
    private let context: NSManagedObjectContext
    private static let lastSyncKey = "gmail_last_sync_date"

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    // MARK: - Save Emails

    /// Save fetched emails to Core Data (replaces 1-hour UserDefaults cache)
    func saveEmails(_ emails: [GmailEmail]) throws {
        for email in emails {
            let exists = emailExists(withID: email.id)
            if !exists {
                let entity = NSEntityDescription.insertNewObject(
                    forEntityName: "GmailEmailEntity",
                    into: context
                )
                populateEntity(entity, with: email)
            }
        }
        try context.save()
        updateLastSyncDate()
        NSLog("[GmailEmailRepository] Saved \(emails.count) emails to Core Data")
    }

    // MARK: - Load Emails

    /// Load all emails from Core Data (survives app restart)
    func loadAllEmails() throws -> [GmailEmail] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "GmailEmailEntity")
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

        let results = try context.fetch(request) as! [NSManagedObject]
        return results.map { entityToModel($0) }
    }

    // MARK: - Delta Sync

    /// Build Gmail API query for delta sync (only fetch emails after lastSync)
    func buildDeltaSyncQuery() -> String? {
        // CRITICAL FIX: If Core Data is empty, ignore UserDefaults and fetch 5-year history
        // This handles database resets where UserDefaults still has stale lastSyncDate
        let emailCount = (try? loadAllEmails().count) ?? 0
        if emailCount == 0 {
            NSLog("[GmailEmailRepository] Core Data empty - fetching 5-year history (ignoring stale lastSyncDate)")
            return nil  // Forces GmailAPI to use 5-year query
        }

        guard let lastSync = getLastSyncDate() else {
            // First sync: fetch all
            return nil
        }

        // Format: "after:2025-10-16"
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: lastSync)
        NSLog("[GmailEmailRepository] Delta sync: after:\(dateString) (\(emailCount) emails in Core Data)")
        return "after:\(dateString)"
    }

    /// Get timestamp for delta sync query
    func getLastSyncDate() -> Date? {
        return UserDefaults.standard.object(forKey: Self.lastSyncKey) as? Date
    }

    /// Update last sync timestamp
    private func updateLastSyncDate() {
        UserDefaults.standard.set(Date(), forKey: Self.lastSyncKey)
    }

    // MARK: - Helper Methods

    private func emailExists(withID id: String) -> Bool {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "GmailEmailEntity")
        request.predicate = NSPredicate(format: "id == %@", id)
        request.returnsObjectsAsFaults = false

        do {
            let count = try context.count(for: request)
            return count > 0
        } catch {
            NSLog("[GmailEmailRepository] Error checking email existence: \(error)")
            return false
        }
    }

    private func populateEntity(_ entity: NSManagedObject, with email: GmailEmail) {
        entity.setValue(email.id, forKey: "id")
        entity.setValue(email.subject, forKey: "subject")
        entity.setValue(email.sender, forKey: "sender")
        entity.setValue(email.date, forKey: "date")
        entity.setValue(email.snippet, forKey: "snippet")
        entity.setValue(email.status.rawValue, forKey: "status")
        entity.setValue(Date(), forKey: "fetchedAt")

        // Serialize attachments if present
        if !email.attachments.isEmpty {
            if let data = try? JSONEncoder().encode(email.attachments) {
                entity.setValue(data, forKey: "attachmentsData")
            }
        }
    }

    private func entityToModel(_ entity: NSManagedObject) -> GmailEmail {
        let id = entity.value(forKey: "id") as? String ?? ""
        let subject = entity.value(forKey: "subject") as? String ?? ""
        let sender = entity.value(forKey: "sender") as? String ?? ""
        let date = entity.value(forKey: "date") as? Date ?? Date()
        let snippet = entity.value(forKey: "snippet") as? String ?? ""
        let statusStr = entity.value(forKey: "status") as? String ?? "unprocessed"
        let status = EmailStatus(rawValue: statusStr) ?? .needsReview

        var attachments: [GmailAttachment] = []
        if let attachmentData = entity.value(forKey: "attachmentsData") as? Data {
            attachments = (try? JSONDecoder().decode([GmailAttachment].self, from: attachmentData)) ?? []
        }

        return GmailEmail(
            id: id,
            subject: subject,
            sender: sender,
            date: date,
            snippet: snippet,
            status: status,
            attachments: attachments
        )
    }

    /// Clear repository (testing only)
    func clearAllEmails() throws {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "GmailEmailEntity")
        let batchDelete = NSBatchDeleteRequest(fetchRequest: request)
        try context.execute(batchDelete)
        UserDefaults.standard.removeObject(forKey: Self.lastSyncKey)
    }
}
