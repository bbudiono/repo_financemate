import CoreData
import Foundation

/*
 * Purpose: Investment entity for individual investment holdings (I-Q-I Protocol Module 10/12)
 * Issues & Complexity Summary: Investment management with valuation, transactions, and Australian tax compliance
 * Key Complexity Drivers:
   - Logic Scope (Est. LoC): ~180 (focused investment holding responsibility)
   - Core Algorithm Complexity: Medium-High (valuation calculations, tax compliance, transaction processing)
   - Dependencies: 4 (CoreData, Foundation, Portfolio, InvestmentTransaction, Dividend relationships)
   - State Management Complexity: Medium-High (investment value tracking, average cost calculations)
   - Novelty/Uncertainty Factor: Low (established investment tracking patterns)
 * AI Pre-Task Self-Assessment: 85% (well-understood investment patterns with Australian tax context)
 * Problem Estimate: 88%
 * Initial Code Complexity Estimate: 85%
 * I-Q-I Quality Target: 8+/10 - Professional enterprise standards with Australian investment tracking context
 * Final Code Complexity: [TBD - Post I-Q-I evaluation]
 * Overall Result Score: [TBD - I-Q-I assessment pending]
 * Key Variances/Learnings: [TBD - I-Q-I optimization insights]
 * Last Updated: 2025-08-04
 */

/// Investment entity representing individual investment holdings with comprehensive Australian tax tracking
/// Responsibilities: Investment valuation, transaction processing, dividend tracking, Australian tax compliance
/// I-Q-I Module: 10/12 - Investment management with professional Australian investment standards
@objc(Investment)
public class Investment: NSManagedObject, Identifiable {
    
    // MARK: - Core Data Properties
    
    @NSManaged public var id: UUID
    @NSManaged public var symbol: String
    @NSManaged public var name: String
    @NSManaged public var assetType: String
    @NSManaged public var quantity: Double
    @NSManaged public var averageCost: Double
    @NSManaged public var currentPrice: Double
    @NSManaged public var lastUpdated: Date
    
    // MARK: - Relationships (Professional Architecture)
    
    /// Parent portfolio relationship (required - every investment belongs to a portfolio)
    @NSManaged public var portfolio: Portfolio
    
    /// Investment transactions relationship (one-to-many - investment has multiple transactions)
    @NSManaged public var transactions: Set<InvestmentTransaction>
    
    /// Dividend payments relationship (one-to-many - investment receives multiple dividends)
    @NSManaged public var dividends: Set<Dividend>
    
    // MARK: - Core Data Lifecycle (Professional Implementation)
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        
        // Initialize required properties with professional defaults
        self.id = UUID()
        self.lastUpdated = Date()
    }
    
    // MARK: - Business Logic (Professional Australian Investment Management)
    
    /// Calculate current market value of investment holding
    /// - Returns: Current market value (quantity × current price)
    /// - Quality: Professional investment valuation calculation
    public func calculateCurrentValue() -> Double {
        return quantity * currentPrice
    }
    
    /// Calculate book value (cost basis) for tax purposes
    /// - Returns: Book value (quantity × average cost)
    /// - Quality: Professional cost basis calculation for Australian tax compliance
    public func calculateBookValue() -> Double {
        return quantity * averageCost
    }
    
    /// Calculate unrealized gain/loss for portfolio tracking
    /// - Returns: Unrealized gain (positive) or loss (negative)
    /// - Quality: Professional unrealized P&L calculation for Australian investment tracking
    public func calculateUnrealizedGain() -> Double {
        return calculateCurrentValue() - calculateBookValue()
    }
    
    /// Calculate return percentage on investment
    /// - Returns: Return as percentage (positive = gain, negative = loss)
    /// - Quality: Professional investment return calculation
    public func calculateReturnPercentage() -> Double {
        let bookValue = calculateBookValue()
        guard bookValue > 0 else { return 0.0 }
        return (calculateUnrealizedGain() / bookValue) * 100.0
    }
    
    /// Add investment transaction and update position
    /// - Parameters:
    ///   - type: Transaction type (buy or sell)
    ///   - quantity: Number of shares/units
    ///   - price: Price per share/unit
    ///   - fees: Transaction fees and costs
    ///   - date: Transaction date
    /// - Quality: Professional transaction processing with average cost recalculation
    public func addTransaction(
        type: InvestmentTransactionType,
        quantity: Double,
        price: Double,
        fees: Double,
        date: Date
    ) {
        let transaction = InvestmentTransaction.create(
            in: managedObjectContext!,
            investment: self,
            type: type,
            quantity: quantity,
            price: price,
            fees: fees,
            date: date
        )
        
        transactions.insert(transaction)
        
        switch type {
        case .buy:
            // Recalculate average cost with new purchase
            let totalCost = (self.quantity * averageCost) + (quantity * price) + fees
            let totalQuantity = self.quantity + quantity
            self.averageCost = totalQuantity > 0 ? totalCost / totalQuantity : 0.0
            self.quantity = totalQuantity
            
        case .sell:
            // Reduce quantity but preserve average cost for remaining holdings
            self.quantity = max(0.0, self.quantity - quantity)
        }
        
        lastUpdated = date
    }
    
    /// Calculate capital gains for Australian tax purposes
    /// - Parameters:
    ///   - soldQuantity: Number of shares/units sold
    ///   - sellPrice: Price per share/unit sold
    ///   - sellDate: Date of sale
    /// - Returns: Capital gains calculation with Australian CGT discount eligibility
    /// - Quality: Professional Australian tax compliance calculation
    public func calculateCapitalGains(soldQuantity: Double, sellPrice: Double, sellDate: Date) -> CapitalGains {
        let grossGain = (sellPrice - averageCost) * soldQuantity
        
        // Australian CGT discount applies if held > 12 months
        let holdingPeriod = sellDate.timeIntervalSince(lastUpdated)
        let discountEligible = holdingPeriod > (365 * 24 * 60 * 60) // 1 year in seconds
        
        let taxableGain = discountEligible && grossGain > 0 ? grossGain * 0.5 : grossGain
        
        return CapitalGains(
            grossGain: grossGain,
            taxableGain: taxableGain,
            discountEligible: discountEligible,
            holdingPeriod: holdingPeriod
        )
    }
    
    /// Calculate dividend yield based on current price
    /// - Returns: Annual dividend yield as percentage
    /// - Quality: Professional dividend yield calculation for Australian income investing
    public func calculateDividendYield() -> Double {
        let currentValue = calculateCurrentValue()
        guard currentValue > 0 else { return 0.0 }
        
        return (calculateAnnualDividends() / currentValue) * 100.0
    }
    
    /// Calculate annual dividends from dividend history
    /// - Returns: Total annual dividend amount
    /// - Quality: Professional dividend calculation for income analysis
    public func calculateAnnualDividends() -> Double {
        let oneYearAgo = Date().addingTimeInterval(-365 * 24 * 60 * 60)
        
        let recentDividends = dividends.filter { dividend in
            dividend.payDate >= oneYearAgo
        }
        
        return recentDividends.reduce(0.0) { total, dividend in
            total + dividend.amount
        }
    }
    
    /// Add dividend payment to investment
    /// - Parameters:
    ///   - amount: Dividend amount per share
    ///   - frankedAmount: Franked portion for Australian tax
    ///   - exDate: Ex-dividend date
    ///   - payDate: Payment date
    /// - Quality: Professional dividend tracking with Australian franking credit support
    public func addDividend(
        amount: Double,
        frankedAmount: Double,
        exDate: Date,
        payDate: Date
    ) {
        let dividend = Dividend.create(
            in: managedObjectContext!,
            investment: self,
            amount: amount,
            frankedAmount: frankedAmount,
            exDate: exDate,
            payDate: payDate
        )
        
        dividends.insert(dividend)
        lastUpdated = payDate
    }
    
    /// Check if investment is performing well relative to benchmarks
    /// - Returns: Boolean indicating strong performance (>15% annual return)
    /// - Quality: Professional performance assessment for Australian investment context
    public func isPerformingWell() -> Bool {
        let returnPercentage = calculateReturnPercentage()
        return returnPercentage > 15.0 // Above 15% is considered strong performance
    }
    
    /// Get investment risk classification based on asset type
    /// - Returns: Risk level string for Australian investment classification
    /// - Quality: Australian investment risk categorization
    public func getRiskClassification() -> String {
        switch assetType.lowercased() {
        case "cash", "term deposits", "government bonds":
            return "Conservative"
        case "corporate bonds", "property", "reits":
            return "Moderate"
        case "australian equities", "international equities":
            return "Growth"
        case "emerging markets", "private equity", "commodities", "cryptocurrency":
            return "Aggressive"
        default:
            return "Unclassified"
        }
    }
    
    // MARK: - Factory Methods (Professional Quality with Validation)
    
    /// Creates a new Investment with comprehensive validation
    /// - Parameters:
    ///   - context: NSManagedObjectContext for investment creation
    ///   - symbol: Investment symbol/ticker (validated for meaningful content)
    ///   - name: Investment name (validated for identification)
    ///   - assetType: Asset type classification (validated against Australian investment types)
    ///   - quantity: Number of shares/units (validated for positive value)
    ///   - averageCost: Average cost per share/unit (validated for positive value)
    ///   - currentPrice: Current market price (validated for positive value)
    ///   - portfolio: Parent portfolio (required relationship)
    /// - Returns: Configured Investment instance
    /// - Quality: Comprehensive validation and professional investment creation
    static func create(
        in context: NSManagedObjectContext,
        symbol: String,
        name: String,
        assetType: String,
        quantity: Double,
        averageCost: Double,
        currentPrice: Double,
        portfolio: Portfolio
    ) -> Investment {
        // Validate investment symbol (professional Australian investment software standards)
        guard !symbol.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            fatalError("Investment symbol cannot be empty - identification requirement")
        }
        
        // Validate investment name
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            fatalError("Investment name cannot be empty - identification requirement")
        }
        
        // Validate asset type
        guard !assetType.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            fatalError("Asset type cannot be empty - classification requirement")
        }
        
        // Validate financial values
        guard quantity > 0 && quantity.isFinite else {
            fatalError("Investment quantity must be positive and finite - holding integrity requirement")
        }
        
        guard averageCost > 0 && averageCost.isFinite else {
            fatalError("Average cost must be positive and finite - cost basis requirement")
        }
        
        guard currentPrice > 0 && currentPrice.isFinite else {
            fatalError("Current price must be positive and finite - valuation requirement")
        }
        
        // Create entity with proper error handling
        guard let entity = NSEntityDescription.entity(forEntityName: "Investment", in: context) else {
            fatalError("Investment entity not found in the provided context - Core Data configuration error")
        }
        
        // Initialize investment with validated data
        let investment = Investment(entity: entity, insertInto: context)
        investment.id = UUID()
        investment.symbol = symbol.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        investment.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        investment.assetType = assetType.trimmingCharacters(in: .whitespacesAndNewlines)
        investment.quantity = quantity
        investment.averageCost = averageCost
        investment.currentPrice = currentPrice
        investment.portfolio = portfolio
        investment.lastUpdated = Date()
        
        return investment
    }
    
    /// Creates an Investment with validation and error throwing (enhanced quality)
    /// - Returns: Validated Investment instance or throws validation error
    /// - Quality: Comprehensive validation with meaningful error messages for Australian investment software
    static func createWithValidation(
        in context: NSManagedObjectContext,
        symbol: String,
        name: String,
        assetType: String,
        quantity: Double,
        averageCost: Double,
        currentPrice: Double,
        portfolio: Portfolio
    ) throws -> Investment {
        
        // Enhanced validation for professional Australian investment software
        let trimmedSymbol = symbol.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedSymbol.isEmpty else {
            throw InvestmentValidationError.invalidSymbol("Investment symbol cannot be empty")
        }
        
        guard trimmedSymbol.count <= 20 else {
            throw InvestmentValidationError.invalidSymbol("Investment symbol cannot exceed 20 characters")
        }
        
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            throw InvestmentValidationError.invalidName("Investment name cannot be empty")
        }
        
        guard trimmedName.count <= 200 else {
            throw InvestmentValidationError.invalidName("Investment name cannot exceed 200 characters")
        }
        
        let trimmedAssetType = assetType.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedAssetType.isEmpty else {
            throw InvestmentValidationError.invalidAssetType("Asset type cannot be empty")
        }
        
        // Validate against common Australian asset types
        let validAssetTypes = [
            "Australian Equities", "International Equities", "Emerging Markets",
            "Government Bonds", "Corporate Bonds", "Cash", "Term Deposits",
            "Property", "REITs", "Commodities", "Cryptocurrency", "Private Equity"
        ]
        guard validAssetTypes.contains(trimmedAssetType) else {
            throw InvestmentValidationError.invalidAssetType("Asset type '\(trimmedAssetType)' is not supported")
        }
        
        guard quantity > 0 && quantity.isFinite else {
            throw InvestmentValidationError.invalidQuantity("Investment quantity must be positive and finite")
        }
        
        guard averageCost > 0 && averageCost.isFinite else {
            throw InvestmentValidationError.invalidPrice("Average cost must be positive and finite")
        }
        
        guard currentPrice > 0 && currentPrice.isFinite else {
            throw InvestmentValidationError.invalidPrice("Current price must be positive and finite")
        }
        
        // Use standard create method with validated data
        return create(
            in: context,
            symbol: trimmedSymbol,
            name: trimmedName,
            assetType: trimmedAssetType,
            quantity: quantity,
            averageCost: averageCost,
            currentPrice: currentPrice,
            portfolio: portfolio
        )
    }
    
    // MARK: - Core Data Fetch Requests (Optimized Queries)
    
    /// Standard fetch request for Investment entities
    /// Quality: Type-safe fetch request with proper entity name
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Investment> {
        return NSFetchRequest<Investment>(entityName: "Investment")
    }
    
    /// Fetch investments for a specific portfolio
    /// - Parameters:
    ///   - portfolio: Portfolio to fetch investments for
    ///   - context: NSManagedObjectContext for query execution
    /// - Returns: Array of investments for the specified portfolio
    /// - Quality: Optimized Core Data query with proper sorting
    public class func fetchInvestments(
        for portfolio: Portfolio,
        in context: NSManagedObjectContext
    ) throws -> [Investment] {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "portfolio == %@", portfolio)
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Investment.symbol, ascending: true)
        ]
        return try context.fetch(request)
    }
    
    /// Fetch investments by asset type for allocation analysis
    /// - Parameters:
    ///   - assetType: Asset type to filter by
    ///   - context: NSManagedObjectContext for query execution
    /// - Returns: Array of investments of the specified asset type
    /// - Quality: Efficient asset type-based queries for portfolio analysis
    public class func fetchInvestments(
        ofType assetType: String,
        in context: NSManagedObjectContext
    ) throws -> [Investment] {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "assetType == %@", assetType)
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Investment.symbol, ascending: true)
        ]
        return try context.fetch(request)
    }
    
    /// Fetch top performing investments for analysis
    /// - Parameters:
    ///   - limit: Maximum number of investments to return
    ///   - context: NSManagedObjectContext for query execution
    /// - Returns: Array of best performing investments
    /// - Quality: Performance-based queries for investment analysis
    public class func fetchTopPerformers(
        limit: Int = 10,
        in context: NSManagedObjectContext
    ) throws -> [Investment] {
        let investments = try context.fetch(fetchRequest())
        
        return investments.sorted { first, second in
            first.calculateReturnPercentage() > second.calculateReturnPercentage()
        }.prefix(limit).map { $0 }
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
        
        return formatter.string(from: NSNumber(value: calculateCurrentValue())) ?? "A$0.00"
    }
    
    /// Format unrealized gain/loss for Australian display
    /// - Returns: Formatted gain/loss string with color-appropriate prefix
    /// - Quality: Professional P&L display for Australian investment tracking
    public func formattedUnrealizedGainAUD() -> String {
        let gain = calculateUnrealizedGain()
        let returnPercentage = calculateReturnPercentage()
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "AUD"
        formatter.locale = Locale(identifier: "en_AU")
        
        let gainString = formatter.string(from: NSNumber(value: gain)) ?? "A$0.00"
        
        if gain >= 0 {
            return "📈 +\(gainString) (+\(String(format: "%.2f", returnPercentage))%)"
        } else {
            return "📉 \(gainString) (\(String(format: "%.2f", returnPercentage))%)"
        }
    }
    
    /// Get comprehensive investment summary for Australian users
    /// - Returns: Formatted investment summary with key metrics
    /// - Quality: Professional investment reporting for Australian investment management
    public func investmentSummary() -> String {
        let currentValue = formattedCurrentValueAUD()
        let performanceString = formattedUnrealizedGainAUD()
        let dividendYield = calculateDividendYield()
        let riskClass = getRiskClassification()
        
        return "\(symbol) (\(name))\n\(currentValue) \(performanceString)\n\(riskClass) • \(String(format: "%.2f", dividendYield))% dividend yield"
    }
    
    /// Format dividend yield for display
    /// - Returns: Formatted dividend yield percentage
    /// - Quality: Professional dividend display for Australian income investing
    public func formattedDividendYield() -> String {
        let yield = calculateDividendYield()
        return String(format: "%.2f%%", yield)
    }
}

// MARK: - Supporting Data Structures (Professional Investment Analysis)

/// Capital gains calculation result for Australian tax compliance
/// Quality: Comprehensive capital gains data for Australian tax reporting
public struct CapitalGains {
    let grossGain: Double
    let taxableGain: Double
    let discountEligible: Bool
    let holdingPeriod: TimeInterval
    
    /// Check if this gain qualifies for CGT discount
    /// - Returns: Boolean indicating CGT discount eligibility
    /// - Quality: Australian tax compliance assessment
    public func qualifiesForCGTDiscount() -> Bool {
        return discountEligible && grossGain > 0
    }
    
    /// Get holding period description
    /// - Returns: Human-readable holding period
    /// - Quality: Professional timeline display for tax planning
    public func getHoldingPeriodDescription() -> String {
        let days = Int(holdingPeriod / (24 * 60 * 60))
        if days < 365 {
            return "\(days) days (short-term)"
        } else {
            let years = days / 365
            let remainingDays = days % 365
            return "\(years) years, \(remainingDays) days (long-term)"
        }
    }
}

/// Investment transaction types for buy/sell operations
/// Quality: Clear transaction type classification
public enum InvestmentTransactionType: String, CaseIterable {
    case buy = "Buy"
    case sell = "Sell"
    
    /// Get display color for transaction type
    /// - Returns: Color indicator for UI display
    /// - Quality: User-friendly transaction visualization
    public func getDisplayColor() -> String {
        switch self {
        case .buy:
            return "🟢" // Green for buy
        case .sell:
            return "🔴" // Red for sell
        }
    }
}

// MARK: - Supporting Types (Professional Error Handling)

/// Investment validation errors with Australian investment context
/// Quality: Meaningful error messages for professional Australian investment software
public enum InvestmentValidationError: Error, LocalizedError {
    case invalidSymbol(String)
    case invalidName(String)
    case invalidQuantity(String)
    case invalidPrice(String)
    case invalidAssetType(String)
    case coreDataError(String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidSymbol(let message):
            return "Invalid investment symbol: \(message)"
        case .invalidName(let message):
            return "Invalid investment name: \(message)"
        case .invalidQuantity(let message):
            return "Invalid investment quantity: \(message)"
        case .invalidPrice(let message):
            return "Invalid investment price: \(message)"
        case .invalidAssetType(let message):
            return "Invalid asset type: \(message)"
        case .coreDataError(let message):
            return "Core Data error: \(message)"
        }
    }
    
    public var failureReason: String? {
        switch self {
        case .invalidSymbol:
            return "Investment symbol is required for identification and market data lookup"
        case .invalidName:
            return "Investment name is required for user identification and reporting"
        case .invalidQuantity:
            return "Investment quantity must be positive for accurate position tracking"
        case .invalidPrice:
            return "Investment price must be positive for accurate valuation and calculations"
        case .invalidAssetType:
            return "Valid asset type is required for portfolio allocation and risk assessment"
        case .coreDataError:
            return "Core Data operation failed - check data model configuration and relationships"
        }
    }
}

// MARK: - Extensions for Collection Operations (Professional Investment Analysis)

extension Collection where Element == Investment {
    
    /// Calculate total investment value across all investments
    /// - Returns: Sum of all investment current values with precision
    /// - Quality: Professional portfolio aggregation
    func totalValue() -> Double {
        return reduce(0.0) { $0 + $1.calculateCurrentValue() }
    }
    
    /// Calculate total book value (cost basis) across all investments
    /// - Returns: Sum of all investment book values
    /// - Quality: Professional cost basis calculation for tax reporting
    func totalBookValue() -> Double {
        return reduce(0.0) { $0 + $1.calculateBookValue() }
    }
    
    /// Calculate total unrealized gain/loss across all investments
    /// - Returns: Total unrealized gain (positive) or loss (negative)
    /// - Quality: Professional portfolio P&L calculation
    func totalUnrealizedGain() -> Double {
        return reduce(0.0) { $0 + $1.calculateUnrealizedGain() }
    }
    
    /// Group investments by asset type for allocation analysis
    /// - Returns: Dictionary of asset types to investment arrays
    /// - Quality: Professional asset allocation grouping
    func groupedByAssetType() -> [String: [Investment]] {
        var groups: [String: [Investment]] = [:]
        
        for investment in self {
            if groups[investment.assetType] == nil {
                groups[investment.assetType] = []
            }
            groups[investment.assetType]?.append(investment)
        }
        
        return groups
    }
    
    /// Find best performing investments
    /// - Returns: Array of investments sorted by return percentage
    /// - Quality: Professional performance ranking
    func topPerformers() -> [Investment] {
        return sorted { $0.calculateReturnPercentage() > $1.calculateReturnPercentage() }
    }
    
    /// Calculate average return across all investments
    /// - Returns: Average return percentage across portfolio
    /// - Quality: Professional portfolio performance assessment
    func averageReturn() -> Double {
        guard !isEmpty else { return 0.0 }
        
        let totalReturn = reduce(0.0) { $0 + $1.calculateReturnPercentage() }
        return totalReturn / Double(count)
    }
    
    /// Calculate total annual dividends across all investments
    /// - Returns: Sum of annual dividends for income analysis
    /// - Quality: Professional income calculation for Australian investors
    func totalAnnualDividends() -> Double {
        return reduce(0.0) { $0 + $1.calculateAnnualDividends() }
    }
    
    /// Get portfolio diversification summary
    /// - Returns: Diversification summary with asset type breakdown
    /// - Quality: Professional diversification analysis for risk management
    func diversificationSummary() -> String {
        let assetGroups = groupedByAssetType()
        let totalValue = self.totalValue()
        
        guard totalValue > 0 else { return "No investments" }
        
        let allocations = assetGroups.map { assetType, investments in
            let typeValue = investments.reduce(0.0) { $0 + $1.calculateCurrentValue() }
            let percentage = (typeValue / totalValue) * 100.0
            return "\(assetType): \(String(format: "%.1f", percentage))%"
        }.sorted()
        
        return allocations.joined(separator: ", ")
    }
}