import Foundation
import CoreData

/// Core Data entity for daily extraction performance metrics (BLUEPRINT Line 192)
/// Tracks extraction quality, tier distribution, and cache efficiency
@objc(ExtractionMetrics)
public class ExtractionMetrics: NSManagedObject {
    @NSManaged public var date: Date
    @NSManaged public var totalExtractions: Int32
    @NSManaged public var tier1Count: Int32
    @NSManaged public var tier2Count: Int32
    @NSManaged public var tier3Count: Int32
    @NSManaged public var avgExtractionTime: Double
    @NSManaged public var avgConfidence: Double
    @NSManaged public var hallucinationCount: Int32
    @NSManaged public var errorCount: Int32
    @NSManaged public var cacheHitRate: Double
}

// MARK: - Fetch Request
extension ExtractionMetrics {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ExtractionMetrics> {
        return NSFetchRequest<ExtractionMetrics>(entityName: "ExtractionMetrics")
    }
}
