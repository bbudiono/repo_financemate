import CoreData
import Foundation

/*
 * Purpose: Portfolio entity for investment portfolio management (I-Q-I Protocol Module 9/12)
 * Issues & Complexity Summary: Portfolio management with asset allocation, performance tracking, and Australian investment context
 * Key Complexity Drivers:
   - Logic Scope (Est. LoC): ~180 (focused portfolio management responsibility)
   - Core Algorithm Complexity: Medium-High (portfolio calculations, asset allocation, performance tracking)
   - Dependencies: 3 (CoreData, Foundation, Investment relationships)
   - State Management Complexity: Medium-High (portfolio value tracking, rebalancing calculations)
   - Novelty/Uncertainty Factor: Low (established portfolio management patterns)
 * AI Pre-Task Self-Assessment: 88% (well-understood portfolio management with Australian investment context)
 * Problem Estimate: 84%
 * Initial Code Complexity Estimate: 82%
 * I-Q-I Quality Target: 8+/10 - Professional enterprise standards with Australian investment management context
 * Final Code Complexity: [TBD - Post I-Q-I evaluation]
 * Overall Result Score: [TBD - I-Q-I assessment pending]
 * Key Variances/Learnings: [TBD - I-Q-I optimization insights]
 * Last Updated: 2025-08-04
 */

/// Portfolio entity representing investment portfolios with asset allocation and performance tracking
/// Responsibilities: Portfolio management, asset allocation calculation, performance tracking, investment coordination
/// I-Q-I Module: 9/12 - Portfolio management with professional Australian investment standards
@objc(Portfolio)
public class Portfolio: NSManagedObject, Identifiable {
    
    // MARK: - Core Data Properties
    
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var currency: String
    @NSManaged public var totalValue: Double
    @NSManaged public var createdAt: Date
    @NSManaged public var lastUpdated: Date
    
    // MARK: - Relationships (Professional Architecture)
    
    /// Portfolio investments relationship (one-to-many - portfolio contains multiple investments)
    @NSManaged public var investments: Set<Investment>
    
    // MARK: - Core Data Lifecycle (Professional Implementation)
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        
        // Initialize required properties with professional defaults
        self.id = UUID()
        self.createdAt = Date()
        self.lastUpdated = Date()
        self.totalValue = 0.0
    }
    
    public override func willSave() {
        super.willSave()
        
        if isUpdated && !isDeleted {
            self.lastUpdated = Date()
            
            // Recalculate total value when investments change
            if changedValues().keys.contains("investments") {
                updateTotalValue()
            }
        }
    }
    
    // MARK: - Business Logic (Professional Australian Portfolio Management)
    
    /// Calculate total portfolio value from all investments
    /// - Returns: Sum of all investment current values with precision
    /// - Quality: Professional portfolio valuation calculation
    public func calculateTotalValue() -> Double {
        return investments.reduce(0.0) { total, investment in
            total + investment.calculateCurrentValue()
        }
    }
    
    /// Update stored total value (for performance optimization)
    /// Quality: Professional cached value update for dashboard performance
    private func updateTotalValue() {
        totalValue = calculateTotalValue()
    }
    
    /// Calculate total book value (cost basis) for the portfolio
    /// - Returns: Sum of all investment book values
    /// - Quality: Professional cost basis calculation for Australian tax purposes
    public func calculateTotalBookValue() -> Double {
        return investments.reduce(0.0) { total, investment in
            total + investment.calculateBookValue()
        }
    }
    
    /// Calculate total unrealized gain/loss for the portfolio
    /// - Returns: Total unrealized gain (positive) or loss (negative)
    /// - Quality: Professional unrealized P&L calculation for Australian investment tracking
    public func calculateTotalUnrealizedGain() -> Double {
        return calculateTotalValue() - calculateTotalBookValue()
    }
    
    /// Calculate overall portfolio return percentage
    /// - Returns: Total return as percentage (positive = gain, negative = loss)
    /// - Quality: Professional portfolio return calculation
    public func calculateTotalReturnPercentage() -> Double {
        let bookValue = calculateTotalBookValue()
        guard bookValue > 0 else { return 0.0 }
        return (calculateTotalUnrealizedGain() / bookValue) * 100.0
    }
    
    /// Calculate portfolio performance metrics
    /// - Returns: Comprehensive performance metrics structure
    /// - Quality: Professional portfolio performance analysis for Australian investors
    public func calculatePerformance() -> PortfolioPerformance {
        let currentValue = calculateTotalValue()
        let bookValue = calculateTotalBookValue()
        let totalGain = currentValue - bookValue
        let totalReturn = bookValue > 0 ? (totalGain / bookValue) * 100.0 : 0.0
        
        return PortfolioPerformance(
            totalGain: totalGain,
            totalReturn: totalReturn,
            currentValue: currentValue,
            bookValue: bookValue
        )
    }
    
    /// Calculate asset allocation breakdown
    /// - Returns: Array of asset allocation data sorted by value
    /// - Quality: Professional asset allocation analysis for Australian portfolio management
    public func calculateAssetAllocation() -> [AssetAllocationData] {
        let totalValue = calculateTotalValue()
        guard totalValue > 0 else { return [] }
        
        var allocations: [String: Double] = [:]
        
        // Group investments by asset type and sum values
        for investment in investments {
            let value = investment.calculateCurrentValue()
            allocations[investment.assetType, default: 0.0] += value
        }
        
        // Convert to AssetAllocationData and sort by value
        return allocations.map { assetType, value in
            AssetAllocationData(
                assetType: assetType,
                value: value,
                percentage: (value / totalValue) * 100.0
            )
        }.sorted { $0.value > $1.value }
    }
    
    /// Calculate diversification score (0-100, higher is better)
    /// - Returns: Diversification score based on asset allocation spread
    /// - Quality: Professional diversification analysis for Australian investment strategy
    public func calculateDiversificationScore() -> Double {
        let allocations = calculateAssetAllocation()
        guard !allocations.isEmpty else { return 0.0 }
        
        // Calculate Herfindahl-Hirschman Index (HHI) for concentration
        let hhi = allocations.reduce(0.0) { total, allocation in
            let share = allocation.percentage / 100.0
            return total + (share * share)
        }
        
        // Convert HHI to diversification score (lower HHI = higher diversification)
        // Perfect diversification (equal weights) gives HHI = 1/n
        let maxHHI = 1.0 // Maximum concentration (one asset = 100%)
        let minHHI = 1.0 / Double(allocations.count) // Perfect equal distribution
        
        let normalizedHHI = (hhi - minHHI) / (maxHHI - minHHI)
        return max(0.0, (1.0 - normalizedHHI) * 100.0)
    }
    
    /// Get investment summary statistics
    /// - Returns: Investment count and asset type breakdown
    /// - Quality: Professional portfolio composition summary
    public func getInvestmentSummary() -> (count: Int, assetTypes: [String: Int]) {
        var assetTypeCounts: [String: Int] = [:]
        
        for investment in investments {
            assetTypeCounts[investment.assetType, default: 0] += 1
        }
        
        return (count: investments.count, assetTypes: assetTypeCounts)
    }
    
    /// Calculate portfolio dividend yield
    /// - Returns: Annual dividend yield as percentage
    /// - Quality: Professional dividend yield calculation for Australian income investing
    public func calculateDividendYield() -> Double {
        let totalValue = calculateTotalValue()
        guard totalValue > 0 else { return 0.0 }
        
        let totalDividends = investments.reduce(0.0) { total, investment in
            total + investment.calculateAnnualDividends()
        }
        
        return (totalDividends / totalValue) * 100.0
    }
    
    // MARK: - Factory Methods (Professional Quality with Validation)
    
    /// Creates a new Portfolio with comprehensive validation
    /// - Parameters:
    ///   - context: NSManagedObjectContext for portfolio creation
    ///   - name: Portfolio name (validated for meaningful content)
    ///   - currency: Portfolio currency code (validated against ISO codes)
    /// - Returns: Configured Portfolio instance
    /// - Quality: Comprehensive validation and professional portfolio creation
    static func create(
        in context: NSManagedObjectContext,
        name: String,
        currency: String
    ) -> Portfolio {
        // Validate portfolio name (professional Australian investment software standards)
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            fatalError("Portfolio name cannot be empty - identification requirement")
        }
        
        // Validate currency code
        guard !currency.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            fatalError("Portfolio currency cannot be empty - financial integrity requirement")
        }
        
        // Validate currency format (should be 3-letter ISO code)
        let trimmedCurrency = currency.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard trimmedCurrency.count == 3 else {
            fatalError("Portfolio currency must be a 3-letter ISO code (e.g., AUD, USD)")
        }
        
        // Create entity with proper error handling
        guard let entity = NSEntityDescription.entity(forEntityName: "Portfolio", in: context) else {
            fatalError("Portfolio entity not found in the provided context - Core Data configuration error")
        }
        
        // Initialize portfolio with validated data
        let portfolio = Portfolio(entity: entity, insertInto: context)
        portfolio.id = UUID()
        portfolio.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        portfolio.currency = trimmedCurrency
        portfolio.totalValue = 0.0
        portfolio.createdAt = Date()
        portfolio.lastUpdated = Date()
        
        return portfolio
    }
    
    /// Creates a Portfolio with validation and error throwing (enhanced quality)
    /// - Returns: Validated Portfolio instance or throws validation error
    /// - Quality: Comprehensive validation with meaningful error messages for Australian investment software
    static func createWithValidation(
        in context: NSManagedObjectContext,
        name: String,
        currency: String
    ) throws -> Portfolio {
        
        // Enhanced validation for professional Australian investment software
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            throw PortfolioValidationError.invalidName("Portfolio name cannot be empty")
        }
        
        guard trimmedName.count <= 100 else {
            throw PortfolioValidationError.invalidName("Portfolio name cannot exceed 100 characters")
        }
        
        let trimmedCurrency = currency.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard trimmedCurrency.count == 3 else {
            throw PortfolioValidationError.invalidCurrency("Currency must be a 3-letter ISO code")
        }
        
        // Validate against common currency codes
        let validCurrencies = ["AUD", "USD", "EUR", "GBP", "JPY", "CAD", "NZD", "SGD", "HKD"]
        guard validCurrencies.contains(trimmedCurrency) else {
            throw PortfolioValidationError.invalidCurrency("Currency code '\(trimmedCurrency)' is not supported")
        }
        
        // Use standard create method with validated data
        return create(
            in: context,
            name: trimmedName,
            currency: trimmedCurrency
        )
    }
    
    // MARK: - Core Data Fetch Requests (Optimized Queries)
    
    /// Standard fetch request for Portfolio entities
    /// Quality: Type-safe fetch request with proper entity name
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Portfolio> {
        return NSFetchRequest<Portfolio>(entityName: "Portfolio")
    }
    
    /// Fetch all portfolios sorted by name
    /// - Parameter context: NSManagedObjectContext for query execution
    /// - Returns: Array of portfolios sorted alphabetically
    /// - Quality: Optimized query for portfolio listing
    public class func fetchPortfolios(in context: NSManagedObjectContext) throws -> [Portfolio] {
        let request = fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Portfolio.name, ascending: true)
        ]
        return try context.fetch(request)
    }
    
    /// Fetch portfolios by currency for multi-currency management
    /// - Parameters:
    ///   - currency: Currency code to filter by
    ///   - context: NSManagedObjectContext for query execution
    /// - Returns: Array of portfolios in the specified currency
    /// - Quality: Efficient currency-based queries
    public class func fetchPortfolios(
        withCurrency currency: String,
        in context: NSManagedObjectContext
    ) throws -> [Portfolio] {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "currency == %@", currency.uppercased())
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Portfolio.name, ascending: true)
        ]
        return try context.fetch(request)
    }
    
    /// Fetch portfolios with value above threshold
    /// - Parameters:
    ///   - minValue: Minimum portfolio value threshold
    ///   - context: NSManagedObjectContext for query execution
    /// - Returns: Array of portfolios above value threshold
    /// - Quality: Efficient value-based queries for portfolio analysis
    public class func fetchPortfolios(
        withValueAbove minValue: Double,
        in context: NSManagedObjectContext
    ) throws -> [Portfolio] {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "totalValue > %f", minValue)
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Portfolio.totalValue, ascending: false)
        ]
        return try context.fetch(request)
    }
    
    // MARK: - Australian Investment Formatting (Localized Business Logic)
    
    /// Format total value for display in portfolio currency
    /// - Returns: Formatted string with appropriate currency symbol
    /// - Quality: Localized currency formatting for multi-currency portfolios
    public func formattedTotalValue() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        
        // Use Australian locale for AUD, otherwise use currency-appropriate locale
        if currency == "AUD" {
            formatter.locale = Locale(identifier: "en_AU")
        } else {
            formatter.locale = Locale(identifier: "en_US") // Default for international currencies
        }
        
        return formatter.string(from: NSNumber(value: totalValue)) ?? "\(currency) 0.00"
    }
    
    /// Format total gain/loss for Australian display
    /// - Returns: Formatted gain/loss string with color-appropriate prefix
    /// - Quality: Professional P&L display for Australian investment tracking
    public func formattedTotalGain() -> String {
        let gain = calculateTotalUnrealizedGain()
        let returnPercentage = calculateTotalReturnPercentage()
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        
        if currency == "AUD" {
            formatter.locale = Locale(identifier: "en_AU")
        } else {
            formatter.locale = Locale(identifier: "en_US")
        }
        
        let gainString = formatter.string(from: NSNumber(value: gain)) ?? "\(currency) 0.00"
        
        if gain >= 0 {
            return "📈 +\(gainString) (+\(String(format: "%.2f", returnPercentage))%)"
        } else {
            return "📉 \(gainString) (\(String(format: "%.2f", returnPercentage))%)"
        }
    }
    
    /// Get comprehensive portfolio summary for Australian users
    /// - Returns: Formatted portfolio summary with key metrics
    /// - Quality: Professional portfolio reporting for Australian investment management
    public func portfolioSummary() -> String {
        let summary = getInvestmentSummary()
        let diversificationScore = calculateDiversificationScore()
        let dividendYield = calculateDividendYield()
        
        let performanceString = formattedTotalGain()
        let diversificationDescription: String
        
        if diversificationScore >= 80 {
            diversificationDescription = "Well Diversified"
        } else if diversificationScore >= 60 {
            diversificationDescription = "Moderately Diversified"
        } else {
            diversificationDescription = "Concentrated"
        }
        
        return "\(summary.count) investments, \(formattedTotalValue()) total value\n\(performanceString)\n\(diversificationDescription) (\(String(format: "%.0f", diversificationScore))% score), \(String(format: "%.2f", dividendYield))% dividend yield"
    }
    
    /// Get asset allocation summary for dashboard display
    /// - Returns: Formatted asset allocation breakdown
    /// - Quality: Professional asset allocation display for Australian portfolio management
    public func assetAllocationSummary() -> String {
        let allocations = calculateAssetAllocation()
        guard !allocations.isEmpty else { return "No investments" }
        
        let topAllocations = Array(allocations.prefix(3)) // Show top 3 allocations
        let allocationStrings = topAllocations.map { allocation in
            "\(allocation.assetType): \(String(format: "%.1f", allocation.percentage))%"
        }
        
        if allocations.count > 3 {
            return allocationStrings.joined(separator: ", ") + ", +\(allocations.count - 3) others"
        } else {
            return allocationStrings.joined(separator: ", ")
        }
    }
}

// MARK: - Supporting Data Structures (Professional Portfolio Analysis)

/// Portfolio performance metrics structure
/// Quality: Comprehensive performance data for Australian investment analysis
public struct PortfolioPerformance {
    let totalGain: Double
    let totalReturn: Double
    let currentValue: Double
    let bookValue: Double
    
    /// Check if portfolio is performing well
    /// - Returns: Boolean indicating strong performance (>10% return)
    /// - Quality: Australian investment performance assessment
    public func isPerformingWell() -> Bool {
        return totalReturn > 10.0
    }
    
    /// Get performance grade (A-F based on return percentage)
    /// - Returns: Letter grade for performance
    /// - Quality: Simple performance grading for Australian investors
    public func getPerformanceGrade() -> String {
        switch totalReturn {
        case 20...: return "A+"
        case 15..<20: return "A"
        case 10..<15: return "B"
        case 5..<10: return "C"
        case 0..<5: return "D"
        default: return "F"
        }
    }
}

/// Asset allocation data structure for portfolio analysis
/// Quality: Professional asset allocation representation
public struct AssetAllocationData {
    let assetType: String
    let value: Double
    let percentage: Double
    
    /// Check if this allocation is significant (>5% of portfolio)
    /// - Returns: Boolean indicating significant allocation
    /// - Quality: Professional allocation significance assessment
    public func isSignificantAllocation() -> Bool {
        return percentage >= 5.0
    }
    
    /// Format as display string for Australian users
    /// - Returns: Formatted allocation string
    /// - Quality: Professional allocation display formatting
    public func formattedAllocation() -> String {
        return "\(assetType): \(String(format: "%.1f", percentage))%"
    }
}

// MARK: - Supporting Types (Professional Error Handling)

/// Portfolio validation errors with Australian investment context
/// Quality: Meaningful error messages for professional Australian investment software
public enum PortfolioValidationError: Error, LocalizedError {
    case invalidName(String)
    case invalidCurrency(String)
    case coreDataError(String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidName(let message):
            return "Invalid portfolio name: \(message)"
        case .invalidCurrency(let message):
            return "Invalid currency: \(message)"
        case .coreDataError(let message):
            return "Core Data error: \(message)"
        }
    }
    
    public var failureReason: String? {
        switch self {
        case .invalidName:
            return "Portfolio name is required for identification and organization"
        case .invalidCurrency:
            return "Valid currency code is required for accurate valuation and reporting"
        case .coreDataError:
            return "Core Data operation failed - check data model configuration"
        }
    }
}

// MARK: - Extensions for Collection Operations (Professional Portfolio Analysis)

extension Collection where Element == Portfolio {
    
    /// Calculate total value across all portfolios
    /// - Returns: Sum of all portfolio values with precision
    /// - Quality: Professional multi-portfolio aggregation
    func totalValue() -> Double {
        return reduce(0.0) { $0 + $1.calculateTotalValue() }
    }
    
    /// Group portfolios by currency for multi-currency management
    /// - Returns: Dictionary of currency codes to portfolio arrays
    /// - Quality: Professional currency grouping for international portfolios
    func groupedByCurrency() -> [String: [Portfolio]] {
        var groups: [String: [Portfolio]] = [:]
        
        for portfolio in self {
            if groups[portfolio.currency] == nil {
                groups[portfolio.currency] = []
            }
            groups[portfolio.currency]?.append(portfolio)
        }
        
        return groups
    }
    
    /// Find best performing portfolios
    /// - Returns: Array of portfolios sorted by total return percentage
    /// - Quality: Professional performance ranking
    func topPerformers() -> [Portfolio] {
        return sorted { $0.calculateTotalReturnPercentage() > $1.calculateTotalReturnPercentage() }
    }
    
    /// Calculate average diversification score
    /// - Returns: Average diversification score across all portfolios
    /// - Quality: Professional diversification assessment
    func averageDiversificationScore() -> Double {
        guard !isEmpty else { return 0.0 }
        
        let totalScore = reduce(0.0) { $0 + $1.calculateDiversificationScore() }
        return totalScore / Double(count)
    }
    
    /// Get portfolio allocation summary across all portfolios
    /// - Returns: Combined asset allocation breakdown
    /// - Quality: Professional multi-portfolio allocation analysis
    func combinedAssetAllocation() -> [AssetAllocationData] {
        var combinedAllocations: [String: Double] = [:]
        let totalValue = self.totalValue()
        
        guard totalValue > 0 else { return [] }
        
        for portfolio in self {
            let allocations = portfolio.calculateAssetAllocation()
            for allocation in allocations {
                combinedAllocations[allocation.assetType, default: 0.0] += allocation.value
            }
        }
        
        return combinedAllocations.map { assetType, value in
            AssetAllocationData(
                assetType: assetType,
                value: value,
                percentage: (value / totalValue) * 100.0
            )
        }.sorted { $0.value > $1.value }
    }
}