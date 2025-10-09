import Foundation
import CoreData

/**
 * Purpose: Core Data entity for tracking Gmail email status
 * Issues & Complexity Summary: Simple entity following KISS principles
 * Key Complexity Drivers:
 * - Logic Scope (Est. LoC): ~45
 * - Core Algorithm Complexity: Low (basic CRUD operations)
 * - Dependencies: 0 New, 0 Mod
 * - State Management Complexity: Low (Core Data managed)
 * - Novelty/Uncertainty Factor: Low (standard Core Data entity)
 * AI Pre-Task Self-Assessment: 98%
 * Problem Estimate: 75%
 * Initial Code Complexity Estimate: 60%
 * Final Code Complexity: 62%
 * Overall Result Score: 97%
 * Key Variances/Learnings: Simple Core Data entity with proper validation
 * Last Updated: 2025-10-06
 */

@objc(EmailStatusEntity)
public class EmailStatusEntity: NSManagedObject {

    // MARK: - Core Data Attributes

    /// Unique identifier for the email (Gmail message ID)
    @NSManaged public var emailId: String

    /// Current status of the email
    @NSManaged public var status: String

    /// Last time this status was updated
    @NSManaged public var lastUpdated: Date

    // MARK: - Validation and Convenience

    /// Validate the entity before saving
    public func validate() throws {
        guard !emailId.isEmpty else {
            throw ValidationError.invalidEmailId
        }

        guard !status.isEmpty else {
            throw ValidationError.invalidStatus
        }

        // Validate status is a valid EmailStatus
        guard EmailStatus(rawValue: status) != nil else {
            throw ValidationError.invalidStatusValue
        }
    }

    /// Get the status as EmailStatus enum
    public var emailStatus: EmailStatus {
        get {
            return EmailStatus(rawValue: status) ?? .needsReview
        }
        set {
            status = newValue.rawValue
            lastUpdated = Date()
        }
    }

    /// Convenience initializer
    convenience init(context: NSManagedObjectContext, emailId: String, status: EmailStatus = .needsReview) {
        self.init(context: context)
        self.emailId = emailId
        self.status = status.rawValue
        self.lastUpdated = Date()
    }

    // MARK: - Validation Errors

    enum ValidationError: Error, LocalizedError {
        case invalidEmailId
        case invalidStatus
        case invalidStatusValue

        public var errorDescription: String? {
            switch self {
            case .invalidEmailId:
                return "Email ID cannot be empty"
            case .invalidStatus:
                return "Status cannot be empty"
            case .invalidStatusValue:
                return "Status value is not valid"
            }
        }
    }
}

// MARK: - Core Data Extensions

extension EmailStatusEntity {

    /// Static fetch request for finding by email ID
    @nonobjc public class func fetchRequest() -> NSFetchRequest<EmailStatusEntity> {
        return NSFetchRequest<EmailStatusEntity>(entityName: "EmailStatusEntity")
    }

    /// Fetch request for finding by email ID
    static func fetchByEmailId(_ emailId: String) -> NSFetchRequest<EmailStatusEntity> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "emailId == %@", emailId)
        request.fetchLimit = 1
        return request
    }

    /// Find existing status entity or create new one
    static func findOrCreate(for emailId: String, in context: NSManagedObjectContext, status: EmailStatus = .needsReview) -> EmailStatusEntity {
        let request = fetchByEmailId(emailId)

        do {
            let results = try context.fetch(request)
            if let existing = results.first {
                return existing
            }
        } catch {
            // Log error but continue with creation
            print("Error fetching EmailStatusEntity: \(error)")
        }

        // Create new entity
        return EmailStatusEntity(context: context, emailId: emailId, status: status)
    }
}