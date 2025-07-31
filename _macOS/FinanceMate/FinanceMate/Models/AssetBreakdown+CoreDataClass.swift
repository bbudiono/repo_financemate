import Foundation
import CoreData

@objc(AssetBreakdown)
public class AssetBreakdown: NSManagedObject {
    
    // MARK: - Computed Properties
    
    /// Asset type as enum
    public var type: Asset.AssetType {
        get {
            return Asset.AssetType.from(string: self.assetType ?? "Other")
        }
        set {
            self.assetType = newValue.stringValue
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
    
    /// Create a new AssetBreakdown
    @discardableResult
    public static func create(
        in context: NSManagedObjectContext,
        assetType: Asset.AssetType,
        value: Double,
        snapshot: NetWealthSnapshot
    ) -> AssetBreakdown {
        let breakdown = AssetBreakdown(context: context)
        breakdown.id = UUID()
        breakdown.type = assetType
        breakdown.value = value
        breakdown.netWealthSnapshot = snapshot
        return breakdown
    }
    
    // MARK: - Fetch Requests
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<AssetBreakdown> {
        return NSFetchRequest<AssetBreakdown>(entityName: "AssetBreakdown")
    }
}

extension AssetBreakdown {
    @NSManaged public var id: UUID?
    @NSManaged public var assetType: String?
    @NSManaged public var value: Double
    @NSManaged public var netWealthSnapshot: NetWealthSnapshot
}