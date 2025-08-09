import CoreData
import Foundation

/*
 * Purpose: InvestmentTransaction entity for buy/sell transaction records (I-Q-I Protocol Module 11/12)
 * Issues & Complexity Summary: Investment transaction tracking with Australian brokerage compliance
 * Key Complexity Drivers:
   - Logic Scope (Est. LoC): ~90 (focused transaction recording responsibility)
   - Core Algorithm Complexity: Low-Medium (transaction recording, fee tracking)
   - Dependencies: 2 (CoreData, Investment relationship)
   - State Management Complexity: Low (transaction immutability)
   - Novelty/Uncertainty Factor: Low (established transaction recording patterns)
 * AI Pre-Task Self-Assessment: 95% (well-understood transaction patterns)
 * Problem Estimate: 68%
 * Initial Code Complexity Estimate: 62%
 * I-Q-I Quality Target: 8+/10 - Professional enterprise standards with Australian brokerage context
 * Final Code Complexity: [TBD - Post I-Q-I evaluation]
 * Overall Result Score: [TBD - I-Q-I assessment pending]
 * Key Variances/Learnings: [TBD - I-Q-I optimization insights]
 * Last Updated: 2025-08-04
 */

/// InvestmentTransaction entity representing buy/sell transaction records with Australian brokerage compliance
/// Responsibilities: Transaction recording, fee tracking, trade history, audit trail maintenance
/// I-Q-I Module: 11/12 - Investment transaction tracking with professional Australian brokerage standards
@objc(InvestmentTransaction)
public class InvestmentTransaction: NSManagedObject, Identifiable {
    
    // MARK: - Core Data Properties
    
    @NSManaged public var id: UUID
    @NSManaged public var type: String
    @NSManaged public var quantity: Double
    @NSManaged public var price: Double
    @NSManaged public var fees: Double
    @NSManaged public var date: Date
    @NSManaged public var notes: String?
    
    // MARK: - Relationships (Professional Architecture)
    
    /// Parent investment relationship (required - every transaction belongs to an investment)
    @NSManaged public var investment: Investment
    
    // MARK: - Core Data Lifecycle (Professional Implementation)
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        
        // Initialize required properties with professional defaults
        self.id = UUID()
        self.date = Date()
    }
    
    // MARK: - Business Logic (Professional Australian Investment Transaction Management)
    
    /// Calculate total transaction value including fees
    /// - Returns: Total cost for buy transactions or net proceeds for sell transactions
    /// - Quality: Professional transaction value calculation with fee inclusion
    public func calculateTotalValue() -> Double {
        let grossValue = quantity * price
        
        // For buy transactions, add fees to cost
        // For sell transactions, subtract fees from proceeds
        switch getTransactionType() {
        case .buy:
            return grossValue + fees
        case .sell:
            return grossValue - fees
        }
    }
    
    /// Calculate transaction value excluding fees (gross value)
    /// - Returns: Gross transaction value before fees
    /// - Quality: Professional gross value calculation for reporting
    public func calculateGrossValue() -> Double {
        return quantity * price
    }
    
    /// Get transaction type as enum
    /// - Returns: InvestmentTransactionType enum value
    /// - Quality: Type-safe transaction type access
    public func getTransactionType() -> InvestmentTransactionType {
        return InvestmentTransactionType(rawValue: type) ?? .buy
    }
    
    /// Calculate brokerage fee percentage
    /// - Returns: Fee as percentage of gross transaction value
    /// - Quality: Professional fee analysis for Australian brokerage comparison
    public func calculateFeePercentage() -> Double {
        let grossValue = calculateGrossValue()
        guard grossValue > 0 else { return 0.0 }
        return (fees / grossValue) * 100.0
    }
    
    /// Check if this is a substantial transaction (>$10,000 AUD)
    /// - Returns: Boolean indicating substantial transaction for Australian reporting
    /// - Quality: Australian financial reporting threshold compliance
    public func isSubstantialTransaction() -> Bool {
        let grossValue = calculateGrossValue()
        return grossValue > 10000.0 // AUD $10,000 threshold
    }
    
    /// Calculate impact on investment average cost (for buy transactions)
    /// - Parameter existingQuantity: Current quantity before this transaction
    /// - Parameter existingAverageCost: Current average cost before this transaction
    /// - Returns: New average cost after this transaction, or nil for sell transactions
    /// - Quality: Professional average cost calculation for cost basis tracking
    public func calculateNewAverageCost(existingQuantity: Double, existingAverageCost: Double) -> Double? {
        guard getTransactionType() == .buy else { return nil }
        
        let existingTotalCost = existingQuantity * existingAverageCost
        let transactionTotalCost = calculateTotalValue()
        let totalCost = existingTotalCost + transactionTotalCost
        let totalQuantity = existingQuantity + quantity
        
        return totalQuantity > 0 ? totalCost / totalQuantity : 0.0
    }
    
    // MARK: - Factory Methods (Professional Quality with Validation)
    
    /// Creates a new InvestmentTransaction with comprehensive validation
    /// - Parameters:
    ///   - context: NSManagedObjectContext for transaction creation
    ///   - investment: Parent investment (required relationship)
    ///   - type: Transaction type (buy or sell)
    ///   - quantity: Number of shares/units (validated for positive value)
    ///   - price: Price per share/unit (validated for positive value)
    ///   - fees: Transaction fees and costs (validated for non-negative value)
    ///   - date: Transaction date (validated for reasonable date range)
    /// - Returns: Configured InvestmentTransaction instance
    /// - Quality: Comprehensive validation and professional transaction creation
    static func create(
        in context: NSManagedObjectContext,
        investment: Investment,
        type: InvestmentTransactionType,
        quantity: Double,
        price: Double,
        fees: Double,
        date: Date
    ) -> InvestmentTransaction {
        // Validate transaction values (professional Australian investment software standards)
        guard quantity > 0 && quantity.isFinite else {
            fatalError("Transaction quantity must be positive and finite - trade integrity requirement")
        }
        
        guard price > 0 && price.isFinite else {
            fatalError("Transaction price must be positive and finite - market value requirement")
        }
        
        guard fees >= 0 && fees.isFinite else {
            fatalError("Transaction fees must be non-negative and finite - cost tracking requirement")
        }
        
        // Validate date is reasonable (not in distant future, not before 1970)
        let earliestDate = Date(timeIntervalSince1970: 0) // 1970-01-01
        let latestDate = Date().addingTimeInterval(24 * 60 * 60) // Tomorrow
        guard date >= earliestDate && date <= latestDate else {
            fatalError("Transaction date must be within reasonable range - temporal integrity requirement")
        }
        
        // Create entity with proper error handling
        guard let entity = NSEntityDescription.entity(forEntityName: "InvestmentTransaction", in: context) else {
            fatalError("InvestmentTransaction entity not found in the provided context - Core Data configuration error")
        }
        
        // Initialize transaction with validated data
        let transaction = InvestmentTransaction(entity: entity, insertInto: context)
        transaction.id = UUID()
        transaction.investment = investment
        transaction.type = type.rawValue
        transaction.quantity = quantity
        transaction.price = price
        transaction.fees = fees
        transaction.date = date
        
        return transaction
    }
    
    /// Creates an InvestmentTransaction with validation and error throwing (enhanced quality)
    /// - Returns: Validated InvestmentTransaction instance or throws validation error
    /// - Quality: Comprehensive validation with meaningful error messages for Australian investment software
    static func createWithValidation(
        in context: NSManagedObjectContext,
        investment: Investment,
        type: InvestmentTransactionType,
        quantity: Double,
        price: Double,
        fees: Double,
        date: Date,
        notes: String? = nil
    ) throws -> InvestmentTransaction {
        
        // Enhanced validation for professional Australian investment software
        guard quantity > 0 && quantity.isFinite else {
            throw TransactionValidationError.invalidQuantity("Transaction quantity must be positive and finite")
        }
        
        guard price > 0 && price.isFinite else {
            throw TransactionValidationError.invalidPrice("Transaction price must be positive and finite")
        }
        
        guard fees >= 0 && fees.isFinite else {
            throw TransactionValidationError.invalidFees("Transaction fees must be non-negative and finite")
        }
        
        // Validate reasonable transaction size (not microscopic, not impossibly large)
        let grossValue = quantity * price
        guard grossValue > 0.01 else { // Minimum 1 cent transaction
            throw TransactionValidationError.invalidAmount("Transaction value too small (minimum A$0.01)")
        }
        
        guard grossValue < 1_000_000_000.0 else { // Maximum $1B transaction
            throw TransactionValidationError.invalidAmount("Transaction value too large (maximum A$1,000,000,000)")
        }
        
        // Validate fee reasonableness (not more than 10% of transaction value)
        let feePercentage = (fees / grossValue) * 100.0
        guard feePercentage <= 10.0 else {
            throw TransactionValidationError.invalidFees("Transaction fees exceed 10% of transaction value")
        }
        
        // Validate date range
        let earliestDate = Date(timeIntervalSince1970: 0) // 1970-01-01
        let latestDate = Date().addingTimeInterval(24 * 60 * 60) // Tomorrow
        guard date >= earliestDate && date <= latestDate else {
            throw TransactionValidationError.invalidDate("Transaction date must be between 1970 and tomorrow")
        }
        
        // Create transaction using standard method
        let transaction = create(
            in: context,
            investment: investment,
            type: type,
            quantity: quantity,
            price: price,
            fees: fees,
            date: date
        )
        
        // Add optional notes
        if let notes = notes?.trimmingCharacters(in: .whitespacesAndNewlines), !notes.isEmpty {
            transaction.notes = notes
        }
        
        return transaction
    }
    
    // MARK: - Core Data Fetch Requests (Optimized Queries)
    
    /// Standard fetch request for InvestmentTransaction entities
    /// Quality: Type-safe fetch request with proper entity name
    @nonobjc public class func fetchRequest() -> NSFetchRequest<InvestmentTransaction> {
        return NSFetchRequest<InvestmentTransaction>(entityName: "InvestmentTransaction")
    }
    
    /// Fetch transactions for a specific investment
    /// - Parameters:
    ///   - investment: Investment to fetch transactions for
    ///   - context: NSManagedObjectContext for query execution
    /// - Returns: Array of transactions for the specified investment
    /// - Quality: Optimized Core Data query with proper sorting
    public class func fetchTransactions(
        for investment: Investment,
        in context: NSManagedObjectContext
    ) throws -> [InvestmentTransaction] {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "investment == %@", investment)
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \InvestmentTransaction.date, ascending: false)
        ]
        return try context.fetch(request)
    }
    
    /// Fetch transactions by type (buy or sell)
    /// - Parameters:
    ///   - type: Transaction type to filter by
    ///   - context: NSManagedObjectContext for query execution
    /// - Returns: Array of transactions of the specified type
    /// - Quality: Efficient type-based queries for transaction analysis
    public class func fetchTransactions(
        ofType type: InvestmentTransactionType,
        in context: NSManagedObjectContext
    ) throws -> [InvestmentTransaction] {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "type == %@", type.rawValue)
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \InvestmentTransaction.date, ascending: false)
        ]
        return try context.fetch(request)
    }
    
    /// Fetch transactions within date range for reporting
    /// - Parameters:
    ///   - fromDate: Start date for range
    ///   - toDate: End date for range
    ///   - context: NSManagedObjectContext for query execution
    /// - Returns: Array of transactions within date range
    /// - Quality: Date-based queries for period reporting
    public class func fetchTransactions(
        from fromDate: Date,
        to toDate: Date,
        in context: NSManagedObjectContext
    ) throws -> [InvestmentTransaction] {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@ AND date <= %@", fromDate as NSDate, toDate as NSDate)
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \InvestmentTransaction.date, ascending: false)
        ]
        return try context.fetch(request)
    }
    
    // MARK: - Australian Investment Formatting (Localized Business Logic)
    
    /// Format total transaction value for Australian currency display
    /// - Returns: Formatted string with AUD currency symbol
    /// - Quality: Localized currency formatting for Australian investment software
    public func formattedTotalValueAUD() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "AUD"
        formatter.locale = Locale(identifier: "en_AU")
        
        return formatter.string(from: NSNumber(value: calculateTotalValue())) ?? "A$0.00"
    }
    
    /// Format transaction fees for Australian currency display
    /// - Returns: Formatted fee string with AUD currency symbol
    /// - Quality: Professional fee display formatting
    public func formattedFeesAUD() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "AUD"
        formatter.locale = Locale(identifier: "en_AU")
        
        return formatter.string(from: NSNumber(value: fees)) ?? "A$0.00"
    }
    
    /// Get comprehensive transaction summary for Australian users
    /// - Returns: Formatted transaction summary with key details
    /// - Quality: Professional transaction reporting for Australian investment tracking
    public func transactionSummary() -> String {
        let typeIcon = getTransactionType().getDisplayColor()
        let dateString = date.formatted(date: .abbreviated, time: .omitted)
        let totalValue = formattedTotalValueAUD()
        let feeString = formattedFeesAUD()
        let priceString = String(format: "A$%.3f", price)
        
        return "\(typeIcon) \(getTransactionType().rawValue) \(String(format: "%.0f", quantity)) @ \(priceString)\n\(dateString) • \(totalValue) (fees: \(feeString))"
    }
    
    /// Get transaction type description with context
    /// - Returns: Contextual transaction type description
    /// - Quality: User-friendly transaction description for Australian investors
    public func getTransactionDescription() -> String {
        let type = getTransactionType()
        let quantityString = String(format: "%.0f", quantity)
        let symbol = investment.symbol
        
        switch type {
        case .buy:
            return "Bought \(quantityString) \(symbol)"
        case .sell:
            return "Sold \(quantityString) \(symbol)"
        }
    }
}

// MARK: - Supporting Types (Professional Error Handling)

/// Transaction validation errors with Australian investment context
/// Quality: Meaningful error messages for professional Australian investment software
public enum TransactionValidationError: Error, LocalizedError {
    case invalidQuantity(String)
    case invalidPrice(String)
    case invalidFees(String)
    case invalidAmount(String)
    case invalidDate(String)
    case coreDataError(String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidQuantity(let message):
            return "Invalid transaction quantity: \(message)"
        case .invalidPrice(let message):
            return "Invalid transaction price: \(message)"
        case .invalidFees(let message):
            return "Invalid transaction fees: \(message)"
        case .invalidAmount(let message):
            return "Invalid transaction amount: \(message)"
        case .invalidDate(let message):
            return "Invalid transaction date: \(message)"
        case .coreDataError(let message):
            return "Core Data error: \(message)"
        }
    }
    
    public var failureReason: String? {
        switch self {
        case .invalidQuantity:
            return "Transaction quantity must be positive for accurate position tracking"
        case .invalidPrice:
            return "Transaction price must be positive for accurate valuation and cost basis"
        case .invalidFees:
            return "Transaction fees must be non-negative for accurate cost tracking"
        case .invalidAmount:
            return "Transaction amount must be within reasonable limits for Australian market"
        case .invalidDate:
            return "Transaction date must be within reasonable historical range"
        case .coreDataError:
            return "Core Data operation failed - check data model configuration and relationships"
        }
    }
}

// MARK: - Extensions for Collection Operations (Professional Transaction Analysis)

extension Collection where Element == InvestmentTransaction {
    
    /// Calculate total transaction volume across all transactions
    /// - Returns: Sum of all transaction values with precision
    /// - Quality: Professional transaction volume analysis
    func totalVolume() -> Double {
        return reduce(0.0) { $0 + $1.calculateTotalValue() }
    }
    
    /// Calculate total fees paid across all transactions
    /// - Returns: Sum of all transaction fees
    /// - Quality: Professional fee analysis for cost optimization
    func totalFees() -> Double {
        return reduce(0.0) { $0 + $1.fees }
    }
    
    /// Group transactions by type (buy vs sell)
    /// - Returns: Dictionary of transaction types to transaction arrays
    /// - Quality: Professional transaction type analysis
    func groupedByType() -> [InvestmentTransactionType: [InvestmentTransaction]] {
        var groups: [InvestmentTransactionType: [InvestmentTransaction]] = [
            .buy: [],
            .sell: []
        ]
        
        for transaction in self {
            groups[transaction.getTransactionType()]?.append(transaction)
        }
        
        return groups
    }
    
    /// Calculate average fee percentage across all transactions
    /// - Returns: Average fee as percentage of transaction value
    /// - Quality: Professional fee efficiency analysis
    func averageFeePercentage() -> Double {
        guard !isEmpty else { return 0.0 }
        
        let totalFeePercentage = reduce(0.0) { $0 + $1.calculateFeePercentage() }
        return totalFeePercentage / Double(count)
    }
    
    /// Filter transactions within date range
    /// - Parameters:
    ///   - fromDate: Start date for filtering
    ///   - toDate: End date for filtering
    /// - Returns: Array of transactions within the specified date range
    /// - Quality: Professional date-based transaction filtering
    func transactionsInRange(from fromDate: Date, to toDate: Date) -> [InvestmentTransaction] {
        return filter { transaction in
            transaction.date >= fromDate && transaction.date <= toDate
        }
    }
    
    /// Get transaction summary for reporting
    /// - Returns: Comprehensive transaction summary string
    /// - Quality: Professional transaction reporting for Australian investment analysis
    func transactionSummary() -> String {
        guard !isEmpty else { return "No transactions recorded" }
        
        let typeGroups = groupedByType()
        let buyCount = typeGroups[.buy]?.count ?? 0
        let sellCount = typeGroups[.sell]?.count ?? 0
        let totalVolume = self.totalVolume()
        let totalFees = self.totalFees()
        let avgFeePercentage = averageFeePercentage()
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "AUD"
        formatter.locale = Locale(identifier: "en_AU")
        
        let volumeString = formatter.string(from: NSNumber(value: totalVolume)) ?? "A$0.00"
        let feesString = formatter.string(from: NSNumber(value: totalFees)) ?? "A$0.00"
        
        return "\(count) transactions: \(buyCount) buys, \(sellCount) sells\nTotal volume: \(volumeString), Total fees: \(feesString) (avg \(String(format: "%.2f", avgFeePercentage))%)"
    }
}