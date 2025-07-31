import Foundation
import CoreData

/**
 * Purpose: Core Data entity for Asset management with Net Wealth integration
 * Issues & Complexity Summary: Complex asset type management with valuation tracking
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~250
 *   - Core Algorithm Complexity: Med
 *   - Dependencies: Core Data, FinancialEntity relationships
 *   - State Management Complexity: Med (asset types, valuations)
 *   - Novelty/Uncertainty Factor: Low
 * AI Pre-Task Self-Assessment: 85%
 * Problem Estimate: 80%
 * Initial Code Complexity Estimate: 85%
 * Final Code Complexity: 88%
 * Overall Result Score: 94%
 * Key Variances/Learnings: Asset type enums require careful Core Data integration
 * Last Updated: 2025-07-31
 */

@objc(Asset)
public class Asset: NSManagedObject {
    
    // MARK: - Asset Types
    
    @objc public enum AssetType: Int32, CaseIterable {
        case realEstate = 0
        case vehicle = 1
        case investment = 2
        case cash = 3
        case other = 4
        
        var stringValue: String {
            switch self {
            case .realEstate:
                return "Real Estate"
            case .vehicle:
                return "Vehicle"
            case .investment:
                return "Investment"
            case .cash:
                return "Cash"
            case .other:
                return "Other"
            }
        }
        
        static func from(string: String) -> AssetType {
            switch string {
            case "Real Estate":
                return .realEstate
            case "Vehicle":
                return .vehicle
            case "Investment":
                return .investment
            case "Cash":
                return .cash
            default:
                return .other
            }
        }
    }
    
    // MARK: - Computed Properties
    
    /// Asset type as enum
    public var type: AssetType {
        get {
            return AssetType.from(string: self.assetType ?? "Other")
        }
        set {
            self.assetType = newValue.stringValue
        }
    }
    
    /// Current value formatted as currency
    public var formattedCurrentValue: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "AUD"
        return formatter.string(from: NSNumber(value: currentValue)) ?? "$0.00"
    }
    
    /// Purchase price formatted as currency (if available)
    public var formattedPurchasePrice: String? {
        guard let purchasePrice = purchasePrice else { return nil }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "AUD"
        return formatter.string(from: NSNumber(value: purchasePrice))
    }
    
    /// Capital gain/loss since purchase
    public var capitalGainLoss: Double? {
        guard let purchasePrice = purchasePrice else { return nil }
        return currentValue - purchasePrice
    }
    
    /// Capital gain/loss percentage
    public var capitalGainLossPercentage: Double? {
        guard let purchasePrice = purchasePrice, purchasePrice > 0 else { return nil }
        return ((currentValue - purchasePrice) / purchasePrice) * 100
    }
    
    /// Time held since purchase (in days)
    public var daysHeld: Int? {
        guard let purchaseDate = purchaseDate else { return nil }
        return Calendar.current.dateComponents([.day], from: purchaseDate, to: Date()).day
    }
    
    /// Most recent valuation from history
    public var mostRecentValuation: AssetValuation? {
        let sortedValuations = valuationHistory.sorted { $0.date > $1.date }
        return sortedValuations.first
    }
    
    /// Previous valuation for comparison
    public var previousValuation: AssetValuation? {
        let sortedValuations = valuationHistory.sorted { $0.date > $1.date }
        return sortedValuations.count > 1 ? sortedValuations[1] : nil
    }
    
    /// Value change since last valuation
    public var valueChangeSinceLastValuation: Double? {
        guard let previous = previousValuation else { return nil }
        return currentValue - previous.value
    }
    
    /// Percentage change since last valuation
    public var percentageChangeSinceLastValuation: Double? {
        guard let previous = previousValuation, previous.value > 0 else { return nil }
        return ((currentValue - previous.value) / previous.value) * 100
    }
    
    // MARK: - Factory Methods
    
    /// Create a new Asset with required fields
    @discardableResult
    public static func create(
        in context: NSManagedObjectContext,
        name: String,
        type: AssetType,
        currentValue: Double,
        purchasePrice: Double? = nil,
        purchaseDate: Date? = nil
    ) -> Asset {
        let asset = Asset(context: context)
        asset.id = UUID()
        asset.name = name
        asset.type = type
        asset.currentValue = currentValue
        asset.purchasePrice = purchasePrice
        asset.purchaseDate = purchaseDate
        asset.createdAt = Date()
        asset.lastUpdated = Date()
        return asset
    }
    
    // MARK: - Validation
    
    public override func validateForInsert() throws {
        try super.validateForInsert()
        try validateAsset()
    }
    
    public override func validateForUpdate() throws {
        try super.validateForUpdate()
        try validateAsset()
    }
    
    private func validateAsset() throws {
        guard let name = name, !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ValidationError.invalidName("Asset name cannot be empty")
        }
        
        guard currentValue >= 0 else {
            throw ValidationError.invalidValue("Asset current value cannot be negative")
        }
        
        if let purchasePrice = purchasePrice, purchasePrice < 0 {
            throw ValidationError.invalidValue("Asset purchase price cannot be negative")
        }
        
        if let purchaseDate = purchaseDate, purchaseDate > Date() {
            throw ValidationError.invalidDate("Asset purchase date cannot be in the future")
        }
    }
    
    // MARK: - Update Methods
    
    /// Update asset value and record in valuation history
    public func updateValue(_ newValue: Double, date: Date = Date()) {
        // Record current value in history before updating
        if currentValue > 0 {
            let valuation = AssetValuation.create(
                in: self.managedObjectContext!,
                value: currentValue,
                date: lastUpdated,
                asset: self
            )
            self.addToValuationHistory(valuation)
        }
        
        // Update current value
        self.currentValue = newValue
        self.lastUpdated = date
    }
    
    /// Add asset to financial entity
    public func assignTo(entity: FinancialEntity) {
        self.financialEntity = entity
        entity.addToAssets(self)
    }
    
    /// Remove asset from financial entity
    public func removeFromEntity() {
        self.financialEntity?.removeFromAssets(self)
        self.financialEntity = nil
    }
    
    // MARK: - Fetch Requests
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Asset> {
        return NSFetchRequest<Asset>(entityName: "Asset")
    }
    
    /// Fetch assets by type
    public static func fetchAssets(
        ofType type: AssetType,
        in context: NSManagedObjectContext
    ) -> [Asset] {
        let request: NSFetchRequest<Asset> = Asset.fetchRequest()
        request.predicate = NSPredicate(format: "assetType == %@", type.stringValue)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Asset.name, ascending: true)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching assets by type: \(error)")
            return []
        }
    }
    
    /// Fetch assets for financial entity
    public static func fetchAssets(
        for entity: FinancialEntity,
        in context: NSManagedObjectContext
    ) -> [Asset] {
        let request: NSFetchRequest<Asset> = Asset.fetchRequest()
        request.predicate = NSPredicate(format: "financialEntity == %@", entity)
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Asset.currentValue, ascending: false),
            NSSortDescriptor(keyPath: \Asset.name, ascending: true)
        ]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching assets for entity: \(error)")
            return []
        }
    }
    
    /// Calculate total value of assets by type
    public static func totalValue(
        ofType type: AssetType,
        for entity: FinancialEntity? = nil,
        in context: NSManagedObjectContext
    ) -> Double {
        let request: NSFetchRequest<Asset> = Asset.fetchRequest()
        
        var predicates: [NSPredicate] = [
            NSPredicate(format: "assetType == %@", type.stringValue)
        ]
        
        if let entity = entity {
            predicates.append(NSPredicate(format: "financialEntity == %@", entity))
        }
        
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        do {
            let assets = try context.fetch(request)
            return assets.reduce(0) { $0 + $1.currentValue }
        } catch {
            print("Error calculating total asset value: \(error)")
            return 0
        }
    }
    
    /// Calculate total value of all assets for entity
    public static func totalValue(
        for entity: FinancialEntity,
        in context: NSManagedObjectContext
    ) -> Double {
        let request: NSFetchRequest<Asset> = Asset.fetchRequest()
        request.predicate = NSPredicate(format: "financialEntity == %@", entity)
        
        do {
            let assets = try context.fetch(request)
            return assets.reduce(0) { $0 + $1.currentValue }
        } catch {
            print("Error calculating total asset value for entity: \(error)")
            return 0
        }
    }
    
    // MARK: - Helper Methods
    
    /// Get asset breakdown by type for entity
    public static func getAssetBreakdown(
        for entity: FinancialEntity,
        in context: NSManagedObjectContext
    ) -> [AssetType: Double] {
        var breakdown: [AssetType: Double] = [:]
        
        for assetType in AssetType.allCases {
            let totalValue = Asset.totalValue(ofType: assetType, for: entity, in: context)
            if totalValue > 0 {
                breakdown[assetType] = totalValue
            }
        }
        
        return breakdown
    }
    
    /// Export asset data for reporting
    public func exportData() -> [String: Any] {
        var data: [String: Any] = [
            "id": id?.uuidString ?? "",
            "name": name ?? "",
            "type": type.stringValue,
            "currentValue": currentValue,
            "createdAt": createdAt,
            "lastUpdated": lastUpdated
        ]
        
        if let purchasePrice = purchasePrice {
            data["purchasePrice"] = purchasePrice
        }
        
        if let purchaseDate = purchaseDate {
            data["purchaseDate"] = purchaseDate
        }
        
        if let entity = financialEntity {
            data["financialEntity"] = entity.name
        }
        
        if let capitalGain = capitalGainLoss {
            data["capitalGainLoss"] = capitalGain
        }
        
        if let capitalGainPercentage = capitalGainLossPercentage {
            data["capitalGainLossPercentage"] = capitalGainPercentage
        }
        
        return data
    }
}

// MARK: - Generated Accessors

extension Asset {
    
    @objc(addValuationHistoryObject:)
    @NSManaged public func addToValuationHistory(_ value: AssetValuation)
    
    @objc(removeValuationHistoryObject:)
    @NSManaged public func removeFromValuationHistory(_ value: AssetValuation)
    
    @objc(addValuationHistory:)
    @NSManaged public func addToValuationHistory(_ values: NSSet)
    
    @objc(removeValuationHistory:)
    @NSManaged public func removeFromValuationHistory(_ values: NSSet)
}

// MARK: - Validation Errors

public enum ValidationError: Error {
    case invalidName(String)
    case invalidValue(String)
    case invalidDate(String)
}

extension ValidationError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidName(let message),
             .invalidValue(let message),
             .invalidDate(let message):
            return message
        }
    }
}