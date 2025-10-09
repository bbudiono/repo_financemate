import Foundation
import CoreData
import os.log

/// Simple Gmail archive service for essential operations
class GmailArchiveService {
    private let context: NSManagedObjectContext
    private let logger = Logger(subsystem: "FinanceMate", category: "GmailArchiveService")

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    /// Get emails by status
    /// - Parameter status: Email status filter
    /// - Returns: Array of email IDs
    func getEmailIds(withStatus status: EmailStatus) throws -> [String] {
        let request = NSFetchRequest<EmailStatusEntity>(entityName: "EmailStatusEntity")
        request.predicate = NSPredicate(format: "status == %@", status.rawValue)

        do {
            let results = try context.fetch(request)
            return results.map { $0.emailId }
        } catch {
            logger.error("Failed to get emails with status \(status.rawValue): \(error.localizedDescription)")
            throw ArchiveError.fetchFailed(error)
        }
    }

    /// Count emails by status
    /// - Parameter status: Email status filter
    /// - Returns: Count of emails
    func countEmails(withStatus status: EmailStatus) throws -> Int {
        let request = NSFetchRequest<EmailStatusEntity>(entityName: "EmailStatusEntity")
        request.predicate = NSPredicate(format: "status == %@", status.rawValue)

        do {
            return try context.count(for: request)
        } catch {
            logger.error("Failed to count emails with status \(status.rawValue): \(error.localizedDescription)")
            throw ArchiveError.fetchFailed(error)
        }
    }
}

enum ArchiveError: Error, LocalizedError {
    case fetchFailed(Error)

    var errorDescription: String? {
        switch self {
        case .fetchFailed(let error):
            return "Fetch failed: \(error.localizedDescription)"
        }
    }
}