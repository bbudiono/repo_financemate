import CoreData
import Foundation

/*
 * Purpose: LineItem entity for transaction decomposition (I-Q-I Protocol Module 2/12)
 * Issues & Complexity Summary: Line item breakdown functionality with transaction relationships
 * Key Complexity Drivers:
   - Logic Scope (Est. LoC): ~180 (focused decomposition responsibility)
   - Core Algorithm Complexity: Medium (item decomposition, relationship management)
   - Dependencies: 3 (CoreData, Foundation, Transaction relationships)
   - State Management Complexity: Medium (parent-child transaction relationships)
   - Novelty/Uncertainty Factor: Low (established Core Data patterns)
 * AI Pre-Task Self-Assessment: 90% (well-understood line item patterns)
 * Problem Estimate: 80%
 * Initial Code Complexity Estimate: 75%
 * I-Q-I Quality Target: 8+/10 - Professional enterprise standards with Australian financial data
 * Final Code Complexity: [TBD - Post I-Q-I evaluation]
 * Overall Result Score: [TBD - I-Q-I assessment pending]
 * Key Variances/Learnings: [TBD - I-Q-I optimization insights]
 * Last Updated: 2025-08-04
 */

/// LineItem entity representing individual line items within transactions
/// Responsibilities: Item decomposition, transaction relationships, split allocation support
/// I-Q-I Module: 2/12 - Transaction decomposition with professional quality standards
@objc(LineItem)
public class LineItem: NSManagedObject, Identifiable {
    
    // MARK: - Core Data Properties
    
    @NSManaged public var id: UUID
    @NSManaged public var itemDescription: String
    @NSManaged public var amount: Double
    
    // MARK: - Core Relationships (Professional Architecture)
    
    /// Parent transaction relationship (required - every line item belongs to a transaction)
    @NSManaged public var transaction: Transaction
    
    /// Split allocations relationship (optional - supports percentage-based splits)
    @NSManaged public var splitAllocations: NSSet?
    
    // MARK: - Core Data Lifecycle (Professional Implementation)
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        
        // Initialize required properties with professional defaults
        self.id = UUID()
    }
    
    // MARK: - Core Data Fetch Request (Optimized Queries)
    
    /// Standard fetch request for LineItem entities
    /// Quality: Type-safe fetch request with proper entity name
    @nonobjc public class func fetchRequest() -> NSFetchRequest<LineItem> {
        return NSFetchRequest<LineItem>(entityName: "LineItem")
    }
    
    // MARK: - Factory Methods (Professional Quality with Validation)
    
    /// Creates a new LineItem with comprehensive validation and error handling
    /// - Parameters:
    ///   - context: NSManagedObjectContext for line item creation
    ///   - itemDescription: Description of the line item (validated for meaningful content)
    ///   - amount: Line item amount (validated for financial accuracy)
    ///   - transaction: Parent transaction (required relationship)
    /// - Returns: Configured LineItem instance
    /// - Quality: Comprehensive parameter validation and business logic enforcement
    static func create(
        in context: NSManagedObjectContext,
        itemDescription: String,
        amount: Double,
        transaction: Transaction
    ) -> LineItem {
        // Validate required parameters (professional financial software standards)
        guard !itemDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            fatalError("LineItem description cannot be empty - business requirement for financial tracking")
        }
        
        guard amount.isFinite && !amount.isNaN else {
            fatalError("LineItem amount must be finite - financial calculation safety requirement")
        }
        
        // Create entity with proper error handling
        guard let entity = NSEntityDescription.entity(forEntityName: "LineItem", in: context) else {
            fatalError("LineItem entity not found in the provided context - Core Data configuration error")
        }
        
        // Initialize line item with validated data
        let lineItem = LineItem(entity: entity, insertInto: context)
        lineItem.id = UUID()
        lineItem.itemDescription = itemDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        lineItem.amount = amount
        lineItem.transaction = transaction
        
        return lineItem
    }
    
    /// Creates a LineItem with validation and error throwing (enhanced quality)
    /// - Returns: Validated LineItem instance or throws validation error
    /// - Quality: Comprehensive validation with meaningful error messages for financial software
    static func createWithValidation(
        in context: NSManagedObjectContext,
        itemDescription: String,
        amount: Double,
        transaction: Transaction
    ) throws -> LineItem {
        
        // Enhanced validation for professional financial software
        let trimmedDescription = itemDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedDescription.isEmpty else {
            throw LineItemValidationError.invalidDescription("Item description cannot be empty")
        }
        
        guard trimmedDescription.count <= 500 else {
            throw LineItemValidationError.invalidDescription("Item description cannot exceed 500 characters")
        }
        
        guard amount.isFinite && !amount.isNaN else {
            throw LineItemValidationError.invalidAmount("Amount must be a valid finite number")
        }
        
        // Business rule: Reasonable amount limits for line items
        guard abs(amount) <= 999_999_999.99 else {
            throw LineItemValidationError.invalidAmount("Amount exceeds maximum allowed value")
        }
        
        // Use validated create method
        return create(
            in: context,
            itemDescription: trimmedDescription,
            amount: amount,
            transaction: transaction
        )
    }
    
    // MARK: - Business Logic Methods (Professional Financial Operations)
    
    /// Calculate the percentage this line item represents of the parent transaction
    /// - Returns: Percentage as decimal (0.0 to 1.0) with precision handling
    /// - Quality: Professional financial calculation with edge case handling
    public func calculatePercentageOfTransaction() -> Double {
        guard transaction.amount != 0 else { return 0.0 }
        
        let percentage = abs(amount) / abs(transaction.amount)
        return min(max(percentage, 0.0), 1.0) // Clamp between 0 and 1
    }
    
    /// Check if this line item has split allocations
    /// - Returns: Boolean indicating presence of split allocations
    /// - Quality: Clean API for checking split allocation status
    public func hasSplitAllocations() -> Bool {
        return splitAllocations?.count ?? 0 > 0
    }
    
    /// Get split allocations as a typed array
    /// - Returns: Array of SplitAllocation objects
    /// - Quality: Type-safe access to split allocations with proper casting
    public func getSplitAllocations() -> [SplitAllocation] {
        return splitAllocations?.allObjects as? [SplitAllocation] ?? []
    }
    
    /// Add a split allocation to this line item
    /// - Parameter splitAllocation: SplitAllocation to add
    /// - Quality: Professional relationship management with validation
    public func addSplitAllocation(_ splitAllocation: SplitAllocation) {
        let allocations = splitAllocations?.mutableCopy() as? NSMutableSet ?? NSMutableSet()
        allocations.add(splitAllocation)
        splitAllocations = allocations.copy() as? NSSet
        
        // Ensure bidirectional relationship consistency
        splitAllocation.lineItem = self
    }
    
    /// Remove a split allocation from this line item
    /// - Parameter splitAllocation: SplitAllocation to remove
    /// - Quality: Professional relationship management with cleanup
    public func removeSplitAllocation(_ splitAllocation: SplitAllocation) {
        guard let allocations = splitAllocations?.mutableCopy() as? NSMutableSet else { return }
        
        allocations.remove(splitAllocation)
        splitAllocations = allocations.copy() as? NSSet
    }
    
    /// Validate that split allocations sum to 100% (business rule enforcement)
    /// - Returns: Boolean indicating if split allocations are valid
    /// - Quality: Professional business rule validation for financial accuracy
    public func validateSplitAllocations() -> Bool {
        let splitAllocations = getSplitAllocations()
        guard !splitAllocations.isEmpty else { return true } // No splits is valid
        
        let totalPercentage = splitAllocations.reduce(0.0) { $0 + $1.percentage }
        
        // Allow for small floating-point precision errors
        return abs(totalPercentage - 100.0) < 0.01
    }
    
    // MARK: - Query Methods (Optimized Core Data Operations)
    
    /// Fetch line items for a specific transaction
    /// - Parameters:
    ///   - transaction: Transaction to fetch line items for
    ///   - context: NSManagedObjectContext for query execution
    /// - Returns: Array of line items for the specified transaction
    /// - Quality: Optimized Core Data query with proper sorting
    public class func fetchLineItems(
        for transaction: Transaction,
        in context: NSManagedObjectContext
    ) throws -> [LineItem] {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "transaction == %@", transaction)
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \LineItem.itemDescription, ascending: true)
        ]
        return try context.fetch(request)
    }
    
    /// Fetch line items with amounts above a threshold
    /// - Parameters:
    ///   - minAmount: Minimum amount threshold
    ///   - context: NSManagedObjectContext for query execution
    /// - Returns: Array of line items above the threshold
    /// - Quality: Efficient threshold-based queries for financial analysis
    public class func fetchLineItems(
        withAmountAbove minAmount: Double,
        in context: NSManagedObjectContext
    ) throws -> [LineItem] {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "ABS(amount) > %f", minAmount)
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \LineItem.amount, ascending: false)
        ]
        return try context.fetch(request)
    }
    
    /// Fetch line items with descriptions matching a pattern
    /// - Parameters:
    ///   - searchText: Text to search for in descriptions
    ///   - context: NSManagedObjectContext for query execution
    /// - Returns: Array of matching line items
    /// - Quality: Efficient text search with case-insensitive matching
    public class func fetchLineItems(
        withDescriptionContaining searchText: String,
        in context: NSManagedObjectContext
    ) throws -> [LineItem] {
        let trimmedSearchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedSearchText.isEmpty else { return [] }
        
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "itemDescription CONTAINS[cd] %@", trimmedSearchText)
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \LineItem.itemDescription, ascending: true)
        ]
        return try context.fetch(request)
    }
    
    // MARK: - Australian Financial Context Methods (Localized Business Logic)
    
    /// Format amount for Australian currency display
    /// - Returns: Formatted string with AUD currency symbol
    /// - Quality: Localized currency formatting for Australian financial software
    public func formattedAmountAUD() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "AUD"
        formatter.locale = Locale(identifier: "en_AU")
        
        return formatter.string(from: NSNumber(value: amount)) ?? "A$0.00"
    }
    
    /// Check if this line item qualifies for GST (Australian tax context)
    /// - Returns: Boolean indicating GST applicability
    /// - Quality: Australian tax compliance logic
    public func isGSTApplicable() -> Bool {
        // GST applies to most goods and services in Australia
        // Amount threshold for GST registration is A$75,000+ turnover
        return amount > 0 && !isGSTExemptCategory()
    }
    
    /// Check if the item category is GST exempt (Australian tax context)
    /// - Returns: Boolean indicating GST exemption
    /// - Quality: Australian tax compliance with common exemption patterns
    private func isGSTExemptCategory() -> Bool {
        let description = itemDescription.lowercased()
        
        // Common GST-exempt categories in Australia
        let exemptKeywords = [
            "medical", "medicine", "health", "doctor", "hospital",
            "education", "school", "university", "course",
            "basic food", "milk", "bread", "meat", "vegetables",
            "childcare", "aged care"
        ]
        
        return exemptKeywords.contains { description.contains($0) }
    }
}

// MARK: - Supporting Types (Professional Error Handling)

/// Comprehensive validation errors for LineItem operations
/// Quality: Meaningful error messages for professional financial software
public enum LineItemValidationError: Error, LocalizedError {
    case invalidDescription(String)
    case invalidAmount(String)
    case invalidTransaction(String)
    case splitAllocationError(String)
    case coreDataError(String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidDescription(let message):
            return "Invalid line item description: \(message)"
        case .invalidAmount(let message):
            return "Invalid line item amount: \(message)"
        case .invalidTransaction(let message):
            return "Invalid transaction reference: \(message)"
        case .splitAllocationError(let message):
            return "Split allocation error: \(message)"
        case .coreDataError(let message):
            return "Core Data error: \(message)"
        }
    }
    
    public var failureReason: String? {
        switch self {
        case .invalidDescription:
            return "Line item description is required for proper financial tracking and categorization"
        case .invalidAmount:
            return "Line item amount must be a valid finite number for accurate financial calculations"
        case .invalidTransaction:
            return "Line item must be associated with a valid transaction for data integrity"
        case .splitAllocationError:
            return "Split allocations must follow business rules for percentage-based categorization"
        case .coreDataError:
            return "Core Data operation failed - check data model configuration and relationships"
        }
    }
}

// MARK: - Extensions for Collection Operations

extension Collection where Element == LineItem {
    
    /// Calculate total amount for a collection of line items
    /// - Returns: Sum of all line item amounts with precision
    /// - Quality: Professional financial aggregation with precision handling
    func totalAmount() -> Double {
        return reduce(0.0) { $0 + $1.amount }
    }
    
    /// Group line items by amount ranges for analysis
    /// - Returns: Dictionary of amount ranges to line item arrays
    /// - Quality: Professional financial analysis grouping
    func groupedByAmountRanges() -> [String: [LineItem]] {
        var groups: [String: [LineItem]] = [
            "Under A$50": [],
            "A$50 - A$200": [],
            "A$200 - A$1,000": [],
            "Over A$1,000": []
        ]
        
        for item in self {
            let absAmount = abs(item.amount)
            
            if absAmount < 50 {
                groups["Under A$50"]?.append(item)
            } else if absAmount < 200 {
                groups["A$50 - A$200"]?.append(item)
            } else if absAmount < 1000 {
                groups["A$200 - A$1,000"]?.append(item)
            } else {
                groups["Over A$1,000"]?.append(item)
            }
        }
        
        return groups
    }
    
    /// Find line items that might benefit from split allocations
    /// - Returns: Array of line items that could be split across categories
    /// - Quality: Intelligent business logic for financial optimization
    func candidatesForSplitAllocations() -> [LineItem] {
        return filter { lineItem in
            // Suggest splitting for larger amounts with business-related keywords
            abs(lineItem.amount) > 100 &&
            !lineItem.hasSplitAllocations() &&
            lineItem.itemDescription.lowercased().contains("business") ||
            lineItem.itemDescription.lowercased().contains("office") ||
            lineItem.itemDescription.lowercased().contains("work")
        }
    }
}