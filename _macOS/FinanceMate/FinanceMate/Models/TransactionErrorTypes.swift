import Foundation

/*
 * Purpose: Transaction error handling types (I-Q-I Protocol Supporting Module)
 * Issues & Complexity Summary: Error types and validation for transaction operations
 * Key Complexity Drivers:
   - Logic Scope (Est. LoC): ~75 (focused error handling responsibility)
   - Core Algorithm Complexity: Low (error type definitions and messages)
   - Dependencies: 1 (Foundation)
   - State Management Complexity: Low (stateless error types)
   - Novelty/Uncertainty Factor: Low (established error handling patterns)
 * AI Pre-Task Self-Assessment: 98% (well-understood error handling patterns)
 * Problem Estimate: 65%
 * Initial Code Complexity Estimate: 60%
 * I-Q-I Quality Target: 8+/10 - Professional enterprise standards with meaningful error messages
 * Final Code Complexity: [TBD - Post I-Q-I evaluation]
 * Overall Result Score: [TBD - I-Q-I assessment pending]
 * Key Variances/Learnings: [TBD - I-Q-I optimization insights]
 * Last Updated: 2025-08-04
 */

// MARK: - Supporting Types (Professional Error Handling)

/// Transaction validation errors with Australian financial context
/// Quality: Meaningful error messages for professional Australian financial software
public enum TransactionValidationError: Error, LocalizedError {
    case invalidAmount(String)
    case invalidCategory(String)
    case invalidType(String)
    case invalidNote(String)
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
        case .invalidNote(let message):
            return "Invalid transaction note: \(message)"
        case .invalidDate(let message):
            return "Invalid transaction date: \(message)"
        case .coreDataError(let message):
            return "Core Data error: \(message)"
        }
    }
    
    public var failureReason: String? {
        switch self {
        case .invalidAmount:
            return "Transaction amount must be finite and non-zero for accurate financial tracking"
        case .invalidCategory:
            return "Transaction category is required for proper classification and reporting"
        case .invalidType:
            return "Transaction type must be valid for proper accounting and analysis"
        case .invalidNote:
            return "Transaction note must be within reasonable length limits"
        case .invalidDate:
            return "Transaction date must be valid for proper chronological ordering"
        case .coreDataError:
            return "Core Data operation failed - check data model configuration and relationships"
        }
    }
}

// MARK: - Core Data Operation Errors (Professional Error Handling)

/// Core Data operation errors for transaction management
/// Quality: Comprehensive error handling for Core Data operations
public enum CoreDataError: Error, LocalizedError {
    case entityNotFound
    case saveFailed
    case fetchFailed
    case relationshipError
    
    public var errorDescription: String? {
        switch self {
        case .entityNotFound:
            return "Core Data entity not found"
        case .saveFailed:
            return "Failed to save to Core Data"
        case .fetchFailed:
            return "Failed to fetch from Core Data"
        case .relationshipError:
            return "Core Data relationship error"
        }
    }
    
    public var failureReason: String? {
        switch self {
        case .entityNotFound:
            return "The requested Core Data entity could not be found in the data model"
        case .saveFailed:
            return "Core Data save operation failed - check data integrity and constraints"
        case .fetchFailed:
            return "Core Data fetch operation failed - check query syntax and context"
        case .relationshipError:
            return "Core Data relationship operation failed - check entity relationships"
        }
    }
}