import Foundation
import CoreData

@objc(AssetValuation)
public class AssetValuation: NSManagedObject {
    
    // MARK: - Computed Properties
    
    /// Value formatted as currency
    public var formattedValue: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "AUD"
        return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }
    
    /// Date formatted as string
    public var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    // MARK: - Factory Methods
    
    /// Create a new AssetValuation
    @discardableResult
    public static func create(
        in context: NSManagedObjectContext,
        value: Double,
        date: Date,
        asset: Asset
    ) -> AssetValuation {
        let valuation = AssetValuation(context: context)
        valuation.id = UUID()
        valuation.value = value
        valuation.date = date
        valuation.asset = asset
        return valuation
    }
    
    // MARK: - Fetch Requests
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<AssetValuation> {
        return NSFetchRequest<AssetValuation>(entityName: "AssetValuation")
    }
}

extension AssetValuation {
    @NSManaged public var id: UUID?
    @NSManaged public var value: Double
    @NSManaged public var date: Date
    @NSManaged public var asset: Asset
}