import CoreData
import Foundation

/*
 * Purpose: WealthSnapshot entity for net worth tracking and financial dashboard support (I-Q-I Protocol Module 4/12)
 * Issues & Complexity Summary: Wealth tracking with asset allocation and performance metrics relationships
 * Key Complexity Drivers:
   - Logic Scope (Est. LoC): ~150 (focused wealth tracking responsibility)
   - Core Algorithm Complexity: Medium (wealth calculations, dashboard data)
   - Dependencies: 3 (CoreData, Foundation, AssetAllocation, PerformanceMetrics relationships)
   - State Management Complexity: Medium (real-time wealth updates)
   - Novelty/Uncertainty Factor: Low (standard Core Data patterns)
 * AI Pre-Task Self-Assessment: 90% (well-understood wealth tracking patterns)
 * Problem Estimate: 80%
 * Initial Code Complexity Estimate: 75%
 * I-Q-I Quality Target: 8+/10 - Professional enterprise standards with Australian financial context
 * Final Code Complexity: [TBD - Post I-Q-I evaluation]
 * Overall Result Score: [TBD - I-Q-I assessment pending]
 * Key Variances/Learnings: [TBD - I-Q-I optimization insights]
 * Last Updated: 2025-08-04
 */

/// WealthSnapshot entity representing point-in-time wealth positions for dashboard analytics
/// Responsibilities: Net worth calculations, wealth tracking, asset allocation relationships
/// I-Q-I Module: 4/12 - Wealth tracking with professional Australian financial standards
@objc(WealthSnapshot)
public class WealthSnapshot: NSManagedObject, Identifiable {
    
    // MARK: - Core Data Properties
    
    @NSManaged public var id: UUID
    @NSManaged public var date: Date
    @NSManaged public var totalAssets: Double
    @NSManaged public var totalLiabilities: Double
    @NSManaged public var netWorth: Double
    @NSManaged public var cashPosition: Double
    @NSManaged public var investmentValue: Double
    @NSManaged public var propertyValue: Double
    @NSManaged public var createdAt: Date
    
    // MARK: - Relationships
    
    @NSManaged public var assetAllocations: Set<AssetAllocation>
    @NSManaged public var performanceMetrics: Set<PerformanceMetrics>
    
    // MARK: - Core Data Lifecycle (Professional Implementation)
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        
        // Set default values for new wealth snapshots with professional standards
        self.id = UUID()
        self.createdAt = Date()
        
        // Calculate net worth from assets and liabilities
        updateNetWorth()
    }
    
    public override func willSave() {
        super.willSave()
        
        // Automatically update net worth when assets or liabilities change
        if isUpdated && !isDeleted {
            let assetKeys = ["totalAssets", "totalLiabilities"]
            if !Set(changedValues().keys).isDisjoint(with: assetKeys) {
                updateNetWorth()
            }
        }
    }
    
    // MARK: - Business Logic (Professional Australian Financial Calculations)
    
    /// Update calculated net worth based on assets and liabilities
    /// Quality: Professional financial calculation with precision handling
    private func updateNetWorth() {
        netWorth = totalAssets - totalLiabilities
    }
    
    /// Calculate debt-to-equity ratio for financial analysis
    /// - Returns: Debt-to-equity ratio or 0 if no assets
    /// - Quality: Professional financial ratio calculation
    public func calculateDebtToEquityRatio() -> Double {
        guard totalAssets > 0 else { return 0.0 }
        return totalLiabilities / totalAssets
    }
    
    /// Calculate liquidity ratio based on cash position
    /// - Returns: Cash as percentage of total assets
    /// - Quality: Professional liquidity analysis for Australian financial planning
    public func calculateLiquidityRatio() -> Double {
        guard totalAssets > 0 else { return 0.0 }
        return cashPosition / totalAssets
    }
    
    /// Check if this wealth snapshot indicates strong financial position
    /// - Returns: Boolean indicating strong financial health
    /// - Quality: Australian financial health assessment criteria
    public func hasStrongFinancialPosition() -> Bool {
        let debtRatio = calculateDebtToEquityRatio()
        let liquidityRatio = calculateLiquidityRatio()
        
        // Australian financial health benchmarks
        return netWorth > 0 && 
               debtRatio < 0.3 && // Less than 30% debt-to-equity
               liquidityRatio > 0.1 // At least 10% cash reserves
    }
    
    // MARK: - Factory Methods (Professional Quality with Validation)
    
    /// Creates a new WealthSnapshot with calculated net worth and validation
    /// - Parameters:
    ///   - context: NSManagedObjectContext for wealth snapshot creation
    ///   - date: Snapshot date for chronological tracking
    ///   - totalAssets: Total asset value (validated for financial accuracy)
    ///   - totalLiabilities: Total liability value (validated for financial accuracy)
    ///   - cashPosition: Current cash holdings
    ///   - investmentValue: Current investment portfolio value
    ///   - propertyValue: Current property portfolio value
    /// - Returns: Configured WealthSnapshot instance
    /// - Quality: Comprehensive validation and professional financial calculation
    static func create(
        in context: NSManagedObjectContext,
        date: Date,
        totalAssets: Double,
        totalLiabilities: Double,
        cashPosition: Double,
        investmentValue: Double,
        propertyValue: Double
    ) -> WealthSnapshot {
        // Validate financial amounts (professional Australian financial software standards)
        guard totalAssets.isFinite && !totalAssets.isNaN && totalAssets >= 0 else {
            fatalError("Total assets must be a valid non-negative number - financial integrity requirement")
        }
        
        guard totalLiabilities.isFinite && !totalLiabilities.isNaN && totalLiabilities >= 0 else {
            fatalError("Total liabilities must be a valid non-negative number - financial integrity requirement")
        }
        
        guard cashPosition.isFinite && !cashPosition.isNaN && cashPosition >= 0 else {
            fatalError("Cash position must be a valid non-negative number - financial integrity requirement")
        }
        
        // Create entity with proper error handling
        guard let entity = NSEntityDescription.entity(forEntityName: "WealthSnapshot", in: context) else {
            fatalError("WealthSnapshot entity not found in the provided context - Core Data configuration error")
        }
        
        // Initialize wealth snapshot with validated data
        let wealthSnapshot = WealthSnapshot(entity: entity, insertInto: context)
        wealthSnapshot.id = UUID()
        wealthSnapshot.date = date
        wealthSnapshot.totalAssets = totalAssets
        wealthSnapshot.totalLiabilities = totalLiabilities
        wealthSnapshot.cashPosition = cashPosition
        wealthSnapshot.investmentValue = investmentValue
        wealthSnapshot.propertyValue = propertyValue
        wealthSnapshot.createdAt = Date()
        
        // Net worth is automatically calculated in willSave()
        wealthSnapshot.netWorth = totalAssets - totalLiabilities
        
        return wealthSnapshot
    }
    
    // MARK: - Core Data Fetch Requests (Optimized Queries)
    
    /// Standard fetch request for WealthSnapshot entities
    /// Quality: Type-safe fetch request with proper entity name
    @nonobjc public class func fetchRequest() -> NSFetchRequest<WealthSnapshot> {
        return NSFetchRequest<WealthSnapshot>(entityName: "WealthSnapshot")
    }
    
    /// Fetch wealth snapshots within a date range for trend analysis
    /// - Parameters:
    ///   - startDate: Start of date range
    ///   - endDate: End of date range
    ///   - context: NSManagedObjectContext for query execution
    /// - Returns: Array of wealth snapshots within the specified date range
    /// - Quality: Efficient date-based queries for financial trend analysis
    public class func fetchSnapshots(
        from startDate: Date,
        to endDate: Date,
        in context: NSManagedObjectContext
    ) throws -> [WealthSnapshot] {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@ AND date <= %@", startDate as NSDate, endDate as NSDate)
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \WealthSnapshot.date, ascending: true)
        ]
        return try context.fetch(request)
    }
    
    /// Fetch the most recent wealth snapshot for current position
    /// - Parameter context: NSManagedObjectContext for query execution
    /// - Returns: Most recent WealthSnapshot or nil if none exists
    /// - Quality: Optimized query for current wealth position display
    public class func fetchLatestSnapshot(in context: NSManagedObjectContext) throws -> WealthSnapshot? {
        let request = fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \WealthSnapshot.date, ascending: false)
        ]
        request.fetchLimit = 1
        return try context.fetch(request).first
    }
    
    /// Fetch wealth snapshots with net worth above threshold
    /// - Parameters:
    ///   - minNetWorth: Minimum net worth threshold
    ///   - context: NSManagedObjectContext for query execution
    /// - Returns: Array of wealth snapshots above threshold
    /// - Quality: Efficient threshold-based queries for financial analysis
    public class func fetchSnapshots(
        withNetWorthAbove minNetWorth: Double,
        in context: NSManagedObjectContext
    ) throws -> [WealthSnapshot] {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "netWorth > %f", minNetWorth)
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \WealthSnapshot.netWorth, ascending: false)
        ]
        return try context.fetch(request)
    }
    
    // MARK: - Australian Financial Formatting (Localized Business Logic)
    
    /// Format net worth for Australian currency display
    /// - Returns: Formatted string with AUD currency symbol
    /// - Quality: Localized currency formatting for Australian financial software
    public func formattedNetWorthAUD() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "AUD"
        formatter.locale = Locale(identifier: "en_AU")
        
        return formatter.string(from: NSNumber(value: netWorth)) ?? "A$0.00"
    }
    
    /// Format total assets for Australian currency display
    /// - Returns: Formatted string with AUD currency symbol
    /// - Quality: Professional financial display formatting
    public func formattedTotalAssetsAUD() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "AUD"
        formatter.locale = Locale(identifier: "en_AU")
        
        return formatter.string(from: NSNumber(value: totalAssets)) ?? "A$0.00"
    }
    
    /// Get wealth growth summary for dashboard display
    /// - Parameter previousSnapshot: Previous wealth snapshot for comparison
    /// - Returns: Formatted wealth growth summary
    /// - Quality: Professional financial growth analysis for Australian users
    public func wealthGrowthSummary(comparedTo previousSnapshot: WealthSnapshot?) -> String {
        guard let previous = previousSnapshot else {
            return "First wealth snapshot - \(formattedNetWorthAUD())"
        }
        
        let growth = netWorth - previous.netWorth
        let growthPercentage = previous.netWorth != 0 ? (growth / abs(previous.netWorth)) * 100 : 0
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "AUD"
        formatter.locale = Locale(identifier: "en_AU")
        
        let growthString = formatter.string(from: NSNumber(value: growth)) ?? "A$0.00"
        
        if growth >= 0 {
            return "↗️ +\(growthString) (+\(String(format: "%.1f", growthPercentage))%)"
        } else {
            return "↘️ \(growthString) (\(String(format: "%.1f", growthPercentage))%)"
        }
    }
}

// MARK: - Extensions for Collection Operations (Professional Financial Analysis)

extension Collection where Element == WealthSnapshot {
    
    /// Calculate average net worth for the collection
    /// - Returns: Average net worth with precision handling
    /// - Quality: Professional financial aggregation for trend analysis
    func averageNetWorth() -> Double {
        guard !isEmpty else { return 0.0 }
        
        let total = reduce(0.0) { $0 + $1.netWorth }
        return total / Double(count)
    }
    
    /// Calculate net worth growth rate over the period
    /// - Returns: Growth rate as percentage or 0 if insufficient data
    /// - Quality: Professional financial growth calculation
    func netWorthGrowthRate() -> Double {
        guard count >= 2 else { return 0.0 }
        
        let sorted = sorted { $0.date < $1.date }
        guard let first = sorted.first, let last = sorted.last else { return 0.0 }
        
        guard first.netWorth != 0 else { return 0.0 }
        
        return ((last.netWorth - first.netWorth) / abs(first.netWorth)) * 100
    }
    
    /// Find snapshots with the highest net worth
    /// - Returns: Array of snapshots with maximum net worth
    /// - Quality: Professional financial peak analysis
    func snapshotsWithHighestNetWorth() -> [WealthSnapshot] {
        guard !isEmpty else { return [] }
        
        let maxNetWorth = map { $0.netWorth }.max() ?? 0
        return filter { abs($0.netWorth - maxNetWorth) < 0.01 }
    }
    
    /// Group snapshots by quarters for Australian financial year reporting
    /// - Returns: Dictionary of quarter strings to snapshot arrays
    /// - Quality: Australian financial year grouping (July-June)
    func groupedByAustralianFinancialQuarters() -> [String: [WealthSnapshot]] {
        var groups: [String: [WealthSnapshot]] = [:]
        
        let calendar = Calendar.current
        
        for snapshot in self {
            let components = calendar.dateComponents([.year, .month], from: snapshot.date)
            guard let year = components.year, let month = components.month else { continue }
            
            // Australian financial year runs July-June
            let financialYear = month >= 7 ? year + 1 : year
            let quarter: String
            
            switch month {
            case 7, 8, 9: quarter = "Q1 FY\(financialYear)"      // Jul-Sep
            case 10, 11, 12: quarter = "Q2 FY\(financialYear)"   // Oct-Dec
            case 1, 2, 3: quarter = "Q3 FY\(financialYear)"      // Jan-Mar
            case 4, 5, 6: quarter = "Q4 FY\(financialYear)"      // Apr-Jun
            default: continue
            }
            
            if groups[quarter] == nil {
                groups[quarter] = []
            }
            groups[quarter]?.append(snapshot)
        }
        
        return groups
    }
}