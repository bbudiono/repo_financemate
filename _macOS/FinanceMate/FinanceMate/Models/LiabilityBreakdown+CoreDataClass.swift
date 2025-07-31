import Foundation
import CoreData

@objc(LiabilityBreakdown)
public class LiabilityBreakdown: NSManagedObject {
    
    // MARK: - Computed Properties
    
    /// Liability type as enum
    public var type: Liability.LiabilityType {
        get {
            return Liability.LiabilityType.from(string: self.liabilityType ?? "Other")
        }
        set {
            self.liabilityType = newValue.stringValue
        }
    }
    
    /// Value formatted as currency
    public var formattedValue: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "AUD"
        return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }
    
    // MARK: - Factory Methods
    
    /// Create a new LiabilityBreakdown
    @discardableResult
    public static func create(
        in context: NSManagedObjectContext,
        liabilityType: Liability.LiabilityType,
        value: Double,
        snapshot: NetWealthSnapshot
    ) -> LiabilityBreakdown {
        let breakdown = LiabilityBreakdown(context: context)
        breakdown.id = UUID()
        breakdown.type = liabilityType
        breakdown.value = value
        breakdown.netWealthSnapshot = snapshot
        return breakdown
    }
    
    // MARK: - Fetch Requests
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<LiabilityBreakdown> {
        return NSFetchRequest<LiabilityBreakdown>(entityName: "LiabilityBreakdown")
    }
}

extension LiabilityBreakdown {
    @NSManaged public var id: UUID?
    @NSManaged public var liabilityType: String?
    @NSManaged public var value: Double
    @NSManaged public var netWealthSnapshot: NetWealthSnapshot
}