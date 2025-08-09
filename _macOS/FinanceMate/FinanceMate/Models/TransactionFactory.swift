import CoreData
import Foundation

/*
 * Purpose: Transaction factory methods for validated creation (I-Q-I Protocol Supporting Module)
 * Issues & Complexity Summary: Professional transaction creation with comprehensive validation
 * Key Complexity Drivers:
   - Logic Scope (Est. LoC): ~120 (focused creation and validation responsibility)
   - Core Algorithm Complexity: Medium (validation logic, error handling)
   - Dependencies: 3 (CoreData, Foundation, Transaction model)
   - State Management Complexity: Low (stateless factory methods)
   - Novelty/Uncertainty Factor: Low (established factory patterns)
 * AI Pre-Task Self-Assessment: 92% (well-understood factory patterns with validation)
 * Problem Estimate: 75%
 * Initial Code Complexity Estimate: 72%
 * I-Q-I Quality Target: 8+/10 - Professional enterprise standards with comprehensive validation
 * Final Code Complexity: [TBD - Post I-Q-I evaluation]
 * Overall Result Score: [TBD - I-Q-I assessment pending]
 * Key Variances/Learnings: [TBD - I-Q-I optimization insights]
 * Last Updated: 2025-08-04
 */

/// Transaction factory methods for validated creation with Australian financial software standards
/// Responsibilities: Validated transaction creation, comprehensive error handling, professional defaults
/// I-Q-I Supporting Module: Professional transaction factory with Australian compliance
extension Transaction {
    
    // MARK: - Factory Methods (Professional Quality with Validation)
    
    /// Creates a new Transaction with comprehensive validation
    /// - Parameters:
    ///   - context: NSManagedObjectContext for transaction creation
    ///   - amount: Transaction amount (validated for finite value)
    ///   - category: Transaction category (validated for meaningful content)
    ///   - note: Optional transaction note
    ///   - date: Transaction date (defaults to current date)
    ///   - type: Transaction type (validated against supported types)
    /// - Returns: Configured Transaction instance
    /// - Quality: Comprehensive validation and professional transaction creation
    static func create(
        in context: NSManagedObjectContext,
        amount: Double,
        category: String,
        note: String? = nil,
        date: Date = Date(),
        type: String = "expense"
    ) -> Transaction {
        // Validate transaction data (professional Australian financial software standards)
        guard amount.isFinite && amount != 0 else {
            fatalError("Transaction amount must be finite and non-zero - financial integrity requirement")
        }
        
        guard !category.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            fatalError("Transaction category cannot be empty - classification requirement")
        }
        
        // Validate transaction type
        let validTypes = ["income", "expense", "transfer"]
        let normalizedType = type.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard validTypes.contains(normalizedType) else {
            fatalError("Transaction type must be 'income', 'expense', or 'transfer' - type classification requirement")
        }
        
        // Create entity with proper error handling
        guard let entity = NSEntityDescription.entity(forEntityName: "Transaction", in: context) else {
            fatalError("Transaction entity not found in the provided context - Core Data configuration error")
        }
        
        // Initialize transaction with validated data
        let transaction = Transaction(entity: entity, insertInto: context)
        // Note: id, createdAt, entityId, and type are set in awakeFromInsert()
        transaction.amount = amount
        transaction.category = category.trimmingCharacters(in: .whitespacesAndNewlines)
        transaction.note = note?.trimmingCharacters(in: .whitespacesAndNewlines)
        transaction.date = date
        transaction.type = normalizedType
        
        return transaction
    }
    
    /// Creates a Transaction with validation and error throwing (enhanced quality)
    /// - Returns: Validated Transaction instance or throws validation error
    /// - Quality: Comprehensive validation with meaningful error messages for Australian financial software
    static func createWithValidation(
        in context: NSManagedObjectContext,
        amount: Double,
        category: String,
        note: String? = nil,
        date: Date = Date(),
        type: String = "expense"
    ) throws -> Transaction {
        
        // Enhanced validation for professional Australian financial software
        guard amount.isFinite && amount != 0 else {
            throw TransactionValidationError.invalidAmount("Transaction amount must be finite and non-zero")
        }
        
        let trimmedCategory = category.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedCategory.isEmpty else {
            throw TransactionValidationError.invalidCategory("Transaction category cannot be empty")
        }
        
        guard trimmedCategory.count <= 100 else {
            throw TransactionValidationError.invalidCategory("Transaction category cannot exceed 100 characters")
        }
        
        // Validate transaction type
        let validTypes = ["income", "expense", "transfer"]
        let normalizedType = type.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard validTypes.contains(normalizedType) else {
            throw TransactionValidationError.invalidType("Transaction type must be 'income', 'expense', or 'transfer'")
        }
        
        // Validate note length if provided
        if let note = note?.trimmingCharacters(in: .whitespacesAndNewlines), note.count > 500 {
            throw TransactionValidationError.invalidNote("Transaction note cannot exceed 500 characters")
        }
        
        // Use standard create method with validated data
        return create(
            in: context,
            amount: amount,
            category: trimmedCategory,
            note: note?.trimmingCharacters(in: .whitespacesAndNewlines),
            date: date,
            type: normalizedType
        )
    }
}