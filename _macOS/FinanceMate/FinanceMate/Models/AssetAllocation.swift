import CoreData
import Foundation

/*
 * Purpose: AssetAllocation entity for portfolio composition tracking (I-Q-I Protocol Module 5/12)
 * Issues & Complexity Summary: Asset class allocation with target vs actual tracking for Australian portfolios
 * Key Complexity Drivers:
   - Logic Scope (Est. LoC): ~120 (focused allocation tracking responsibility)
   - Core Algorithm Complexity: Low-Medium (allocation percentages, target tracking)
   - Dependencies: 2 (CoreData, WealthSnapshot relationship)
   - State Management Complexity: Low-Medium (allocation rebalancing)
   - Novelty/Uncertainty Factor: Low (established portfolio allocation patterns)
 * AI Pre-Task Self-Assessment: 92% (well-understood asset allocation patterns)
 * Problem Estimate: 75%
 * Initial Code Complexity Estimate: 70%
 * I-Q-I Quality Target: 8+/10 - Professional enterprise standards with Australian investment context
 * Final Code Complexity: [TBD - Post I-Q-I evaluation]
 * Overall Result Score: [TBD - I-Q-I assessment pending]
 * Key Variances/Learnings: [TBD - I-Q-I optimization insights]
 * Last Updated: 2025-08-04
 */

/// AssetAllocation entity representing portfolio composition and target allocation tracking
/// Responsibilities: Asset class allocation, target vs actual tracking, portfolio rebalancing support
/// I-Q-I Module: 5/12 - Asset allocation with professional Australian investment standards
@objc(AssetAllocation)
public class AssetAllocation: NSManagedObject, Identifiable {
    
    // MARK: - Core Data Properties
    
    @NSManaged public var id: UUID
    @NSManaged public var assetClass: String
    @NSManaged public var allocation: Double
    @NSManaged public var targetAllocation: Double
    @NSManaged public var currentValue: Double
    @NSManaged public var lastUpdated: Date
    
    // MARK: - Relationships (Professional Architecture)
    
    /// Parent wealth snapshot relationship (required - every allocation belongs to a snapshot)
    @NSManaged public var wealthSnapshot: WealthSnapshot
    
    // MARK: - Core Data Lifecycle (Professional Implementation)
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        
        // Initialize required properties with professional defaults
        self.id = UUID()
        self.lastUpdated = Date()
    }
    
    // MARK: - Business Logic (Professional Australian Investment Calculations)
    
    /// Calculate allocation variance from target
    /// - Returns: Variance as percentage points (positive = over-allocated, negative = under-allocated)
    /// - Quality: Professional portfolio rebalancing calculation
    public func calculateAllocationVariance() -> Double {
        return allocation - targetAllocation
    }
    
    /// Check if this allocation is significantly off target
    /// - Returns: Boolean indicating if rebalancing is recommended
    /// - Quality: Australian investment management best practices (5% tolerance)
    public func needsRebalancing() -> Bool {
        let variance = abs(calculateAllocationVariance())
        return variance > 5.0 // More than 5% off target
    }
    
    /// Calculate the dollar amount needed to reach target allocation
    /// - Parameter totalPortfolioValue: Total portfolio value for calculation
    /// - Returns: Dollar amount to buy (positive) or sell (negative) to reach target
    /// - Quality: Professional rebalancing calculation for Australian investors
    public func calculateRebalancingAmount(totalPortfolioValue: Double) -> Double {
        guard totalPortfolioValue > 0 else { return 0.0 }
        
        let targetValue = totalPortfolioValue * (targetAllocation / 100.0)
        return targetValue - currentValue
    }
    
    /// Check if this is a defensive asset class (bonds, cash, property)
    /// - Returns: Boolean indicating defensive asset classification
    /// - Quality: Australian investment classification standards
    public func isDefensiveAsset() -> Bool {
        let defensiveClasses = [
            "Cash",
            "Term Deposits",
            "Government Bonds",
            "Corporate Bonds",
            "Property",
            "REITs",
            "Infrastructure"
        ]
        
        return defensiveClasses.contains(assetClass)
    }
    
    /// Check if this is a growth asset class (equities, alternatives)
    /// - Returns: Boolean indicating growth asset classification
    /// - Quality: Australian investment classification standards
    public func isGrowthAsset() -> Bool {
        let growthClasses = [
            "Australian Equities",
            "International Equities",
            "Emerging Markets",
            "Private Equity",
            "Commodities",
            "Cryptocurrency"
        ]
        
        return growthClasses.contains(assetClass)
    }
    
    // MARK: - Factory Methods (Professional Quality with Validation)
    
    /// Creates a new AssetAllocation linked to a wealth snapshot with validation
    /// - Parameters:
    ///   - context: NSManagedObjectContext for asset allocation creation
    ///   - assetClass: Asset class name (validated against Australian investment categories)
    ///   - allocation: Current allocation percentage (0-100)
    ///   - targetAllocation: Target allocation percentage (0-100)
    ///   - currentValue: Current dollar value of this allocation
    ///   - wealthSnapshot: Parent wealth snapshot (required relationship)
    /// - Returns: Configured AssetAllocation instance
    /// - Quality: Comprehensive validation and professional Australian investment logic
    static func create(
        in context: NSManagedObjectContext,
        assetClass: String,
        allocation: Double,
        targetAllocation: Double,
        currentValue: Double,
        wealthSnapshot: WealthSnapshot
    ) -> AssetAllocation {
        // Validate asset class (professional Australian investment software standards)
        guard !assetClass.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            fatalError("Asset class cannot be empty - investment classification requirement")
        }
        
        // Validate allocation percentages
        guard allocation >= 0.0 && allocation <= 100.0 else {
            fatalError("Current allocation must be between 0% and 100% - portfolio integrity requirement")
        }
        
        guard targetAllocation >= 0.0 && targetAllocation <= 100.0 else {
            fatalError("Target allocation must be between 0% and 100% - portfolio planning requirement")
        }
        
        guard currentValue.isFinite && !currentValue.isNaN && currentValue >= 0 else {
            fatalError("Current value must be a valid non-negative number - financial integrity requirement")
        }
        
        // Create entity with proper error handling
        guard let entity = NSEntityDescription.entity(forEntityName: "AssetAllocation", in: context) else {
            fatalError("AssetAllocation entity not found in the provided context - Core Data configuration error")
        }
        
        // Initialize asset allocation with validated data
        let assetAllocation = AssetAllocation(entity: entity, insertInto: context)
        assetAllocation.id = UUID()
        assetAllocation.assetClass = assetClass.trimmingCharacters(in: .whitespacesAndNewlines)
        assetAllocation.allocation = allocation
        assetAllocation.targetAllocation = targetAllocation
        assetAllocation.currentValue = currentValue
        assetAllocation.wealthSnapshot = wealthSnapshot
        assetAllocation.lastUpdated = Date()
        
        return assetAllocation
    }
    
    // MARK: - Core Data Fetch Requests (Optimized Queries)
    
    /// Standard fetch request for AssetAllocation entities
    /// Quality: Type-safe fetch request with proper entity name
    @nonobjc public class func fetchRequest() -> NSFetchRequest<AssetAllocation> {
        return NSFetchRequest<AssetAllocation>(entityName: "AssetAllocation")
    }
    
    /// Fetch asset allocations for a specific wealth snapshot
    /// - Parameters:
    ///   - wealthSnapshot: WealthSnapshot to fetch allocations for
    ///   - context: NSManagedObjectContext for query execution
    /// - Returns: Array of asset allocations for the specified snapshot
    /// - Quality: Optimized Core Data query with proper sorting
    public class func fetchAllocations(
        for wealthSnapshot: WealthSnapshot,
        in context: NSManagedObjectContext
    ) throws -> [AssetAllocation] {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "wealthSnapshot == %@", wealthSnapshot)
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \AssetAllocation.allocation, ascending: false)
        ]
        return try context.fetch(request)
    }
    
    /// Fetch asset allocations that need rebalancing
    /// - Parameters:
    ///   - tolerance: Variance tolerance percentage (default 5%)
    ///   - context: NSManagedObjectContext for query execution
    /// - Returns: Array of asset allocations requiring rebalancing
    /// - Quality: Efficient query for portfolio management
    public class func fetchAllocationsNeedingRebalancing(
        tolerance: Double = 5.0,
        in context: NSManagedObjectContext
    ) throws -> [AssetAllocation] {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "ABS(allocation - targetAllocation) > %f", tolerance)
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \AssetAllocation.allocation, ascending: false)
        ]
        return try context.fetch(request)
    }
    
    // MARK: - Australian Investment Formatting (Localized Business Logic)
    
    /// Format current value for Australian currency display
    /// - Returns: Formatted string with AUD currency symbol
    /// - Quality: Localized currency formatting for Australian investment software
    public func formattedCurrentValueAUD() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "AUD"
        formatter.locale = Locale(identifier: "en_AU")
        
        return formatter.string(from: NSNumber(value: currentValue)) ?? "A$0.00"
    }
    
    /// Format allocation percentage with Australian display conventions
    /// - Returns: Formatted percentage string (e.g., "25.5%")
    /// - Quality: Australian display formatting for professional investment software
    public func formattedAllocationPercentage() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1
        formatter.locale = Locale(identifier: "en_AU")
        
        return formatter.string(from: NSNumber(value: allocation / 100.0)) ?? "0%"
    }
    
    /// Get rebalancing recommendation summary
    /// - Parameter totalPortfolioValue: Total portfolio value for calculation
    /// - Returns: Formatted rebalancing recommendation
    /// - Quality: Professional investment advice formatting for Australian investors
    public func rebalancingRecommendation(totalPortfolioValue: Double) -> String {
        let variance = calculateAllocationVariance()
        let rebalanceAmount = calculateRebalancingAmount(totalPortfolioValue: totalPortfolioValue)
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "AUD"
        formatter.locale = Locale(identifier: "en_AU")
        
        if abs(variance) <= 5.0 {
            return "✅ On target (\(String(format: "%.1f", variance))% variance)"
        } else if variance > 0 {
            let sellAmount = formatter.string(from: NSNumber(value: -rebalanceAmount)) ?? "A$0"
            return "📉 Over-weighted by \(String(format: "%.1f", variance))% - Consider selling \(sellAmount)"
        } else {
            let buyAmount = formatter.string(from: NSNumber(value: rebalanceAmount)) ?? "A$0"
            return "📈 Under-weighted by \(String(format: "%.1f", -variance))% - Consider buying \(buyAmount)"
        }
    }
}

// MARK: - Extensions for Collection Operations (Professional Portfolio Analysis)

extension Collection where Element == AssetAllocation {
    
    /// Validate that all allocations sum to approximately 100%
    /// - Returns: Boolean indicating if total allocations are valid
    /// - Quality: Professional portfolio validation for Australian investment management
    func validateTotalAllocation() -> Bool {
        let totalAllocation = reduce(0.0) { $0 + $1.allocation }
        
        // Allow for small precision errors (±1%)
        return abs(totalAllocation - 100.0) < 1.0
    }
    
    /// Calculate total portfolio value
    /// - Returns: Sum of all current values with precision
    /// - Quality: Professional financial aggregation for portfolio valuation
    func totalPortfolioValue() -> Double {
        return reduce(0.0) { $0 + $1.currentValue }
    }
    
    /// Group allocations by asset type (defensive vs growth)
    /// - Returns: Dictionary of asset types to allocation arrays
    /// - Quality: Professional Australian investment classification
    func groupedByAssetType() -> [String: [AssetAllocation]] {
        var groups: [String: [AssetAllocation]] = [
            "Defensive Assets": [],
            "Growth Assets": [],
            "Other Assets": []
        ]
        
        for allocation in self {
            if allocation.isDefensiveAsset() {
                groups["Defensive Assets"]?.append(allocation)
            } else if allocation.isGrowthAsset() {
                groups["Growth Assets"]?.append(allocation)
            } else {
                groups["Other Assets"]?.append(allocation)
            }
        }
        
        return groups
    }
    
    /// Calculate defensive asset percentage for risk profiling
    /// - Returns: Percentage of portfolio in defensive assets
    /// - Quality: Australian investment risk assessment calculation
    func defensiveAssetPercentage() -> Double {
        let defensiveAllocations = filter { $0.isDefensiveAsset() }
        return defensiveAllocations.reduce(0.0) { $0 + $1.allocation }
    }
    
    /// Find allocations most off target for rebalancing priority
    /// - Returns: Array of allocations sorted by variance from target
    /// - Quality: Professional portfolio rebalancing prioritization
    func allocationsByRebalancingPriority() -> [AssetAllocation] {
        return sorted { abs($0.calculateAllocationVariance()) > abs($1.calculateAllocationVariance()) }
    }
    
    /// Calculate portfolio balance score (0-100, higher is better)
    /// - Returns: Portfolio balance score based on target adherence
    /// - Quality: Professional portfolio management scoring for Australian investors
    func portfolioBalanceScore() -> Double {
        guard !isEmpty else { return 100.0 }
        
        let totalVariance = reduce(0.0) { $0 + abs($1.calculateAllocationVariance()) }
        let averageVariance = totalVariance / Double(count)
        
        // Convert to score: 0% variance = 100 score, 20% variance = 0 score
        return max(0.0, 100.0 - (averageVariance * 5.0))
    }
}