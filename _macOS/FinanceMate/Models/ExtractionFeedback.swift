import Foundation
import CoreData

/// Tracks user corrections to extraction results for continuous improvement
/// BLUEPRINT Section 3.1.1.4: User Feedback & Continuous Improvement
@objc(ExtractionFeedback)
public class ExtractionFeedback: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var emailID: String
    @NSManaged public var fieldName: String
    @NSManaged public var originalValue: String
    @NSManaged public var correctedValue: String
    @NSManaged public var merchant: String
    @NSManaged public var timestamp: Date
    @NSManaged public var wasHallucination: Bool
    @NSManaged public var confidence: Double
    @NSManaged public var extractionTier: String
}

extension ExtractionFeedback {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ExtractionFeedback> {
        return NSFetchRequest<ExtractionFeedback>(entityName: "ExtractionFeedback")
    }

    /// Fetch corrections for specific merchant in last 30 days
    static func recentCorrections(merchant: String, context: NSManagedObjectContext) -> [ExtractionFeedback] {
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "merchant == %@ AND timestamp > %@", merchant, thirtyDaysAgo as NSDate)
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]

        return (try? context.fetch(request)) ?? []
    }
}
