import Foundation
import CoreData

@objc(NetWealthSnapshot)
public class NetWealthSnapshot: NSManagedObject {
    
    // MARK: - Computed Properties
    
    /// Total assets formatted as currency
    public var formattedTotalAssets: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "AUD"
        return formatter.string(from: NSNumber(value: totalAssets)) ?? "$0.00"
    }
    
    /// Total liabilities formatted as currency
    public var formattedTotalLiabilities: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "AUD"
        return formatter.string(from: NSNumber(value: totalLiabilities)) ?? "$0.00"
    }
    
    /// Net wealth formatted as currency
    public var formattedNetWealth: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "AUD"
        return formatter.string(from: NSNumber(value: netWealth)) ?? "$0.00"
    }
    
    /// Snapshot date formatted as string
    public var formattedSnapshotDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        return formatter.string(from: snapshotDate)
    }
    
    /// Asset to liability ratio
    public var assetToLiabilityRatio: Double? {
        guard totalLiabilities > 0 else { return nil }
        return totalAssets / totalLiabilities
    }
    
    /// Debt to asset ratio (percentage)
    public var debtToAssetRatio: Double {
        guard totalAssets > 0 else { return 0 }
        return (totalLiabilities / totalAssets) * 100
    }
    
    /// Net wealth as percentage of total assets
    public var netWealthAssetPercentage: Double {
        guard totalAssets > 0 else { return 0 }
        return (netWealth / totalAssets) * 100
    }
    
    // MARK: - Factory Methods
    
    /// Create a new NetWealthSnapshot
    @discardableResult
    public static func create(
        in context: NSManagedObjectContext,
        entity: FinancialEntity,
        totalAssets: Double,
        totalLiabilities: Double,
        netWealth: Double,
        snapshotDate: Date = Date()
    ) -> NetWealthSnapshot {
        let snapshot = NetWealthSnapshot(context: context)
        snapshot.id = UUID()
        snapshot.financialEntity = entity
        snapshot.totalAssets = totalAssets
        snapshot.totalLiabilities = totalLiabilities
        snapshot.netWealth = netWealth
        snapshot.snapshotDate = snapshotDate
        snapshot.createdAt = Date()
        return snapshot
    }
    
    // MARK: - Fetch Requests
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<NetWealthSnapshot> {
        return NSFetchRequest<NetWealthSnapshot>(entityName: "NetWealthSnapshot")
    }
    
    /// Fetch snapshots for entity ordered by date
    public static func fetchSnapshots(
        for entity: FinancialEntity,
        in context: NSManagedObjectContext,
        limit: Int? = nil
    ) -> [NetWealthSnapshot] {
        let request: NSFetchRequest<NetWealthSnapshot> = NetWealthSnapshot.fetchRequest()
        request.predicate = NSPredicate(format: "financialEntity == %@", entity)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \NetWealthSnapshot.snapshotDate, ascending: false)]
        
        if let limit = limit {
            request.fetchLimit = limit
        }
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching net wealth snapshots: \(error)")
            return []
        }
    }
    
    /// Get latest snapshot for entity
    public static func latestSnapshot(
        for entity: FinancialEntity,
        in context: NSManagedObjectContext
    ) -> NetWealthSnapshot? {
        return fetchSnapshots(for: entity, in: context, limit: 1).first
    }
}

extension NetWealthSnapshot {
    @NSManaged public var id: UUID?
    @NSManaged public var totalAssets: Double
    @NSManaged public var totalLiabilities: Double
    @NSManaged public var netWealth: Double
    @NSManaged public var snapshotDate: Date
    @NSManaged public var createdAt: Date
    @NSManaged public var financialEntity: FinancialEntity
    @NSManaged public var assetBreakdown: NSSet
    @NSManaged public var liabilityBreakdown: NSSet
}