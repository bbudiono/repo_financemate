//
// TransactionValidationService.swift
// FinanceMate
//
// Purpose: Simple transaction validation coordination
// Issues & Complexity Summary: Validation coordination service
// Key Complexity Drivers:
//   - Logic Scope (Est. LoC): ~30
//   - Core Algorithm Complexity: Low
//   - Dependencies: 1 (Foundation)
//   - State Management Complexity: Low
//   - Novelty/Uncertainty Factor: Low
// AI Pre-Task Self-Assessment: 95%
// Problem Estimate: 98%
// Initial Code Complexity Estimate: 55%
// Final Code Complexity: 58%
// Overall Result Score: 94%
// Key Variances/Learnings: Simple coordination with focused validation
// Last Updated: 2025-01-04

import Foundation

/// Service for coordinating transaction validation
class TransactionValidationService {

    static let shared = TransactionValidationService()

    private init() {}

    /// Validate transaction amount
    /// - Parameter amount: Amount to validate
    /// - Throws: ValidationError for invalid amounts
    func validateAmount(_ amount: Double) throws {
        guard amount.isFinite else {
            throw ValidationError.invalidAmount("Amount must be a finite number")
        }
        guard abs(amount) <= 1_000_000 else {
            throw ValidationError.invalidAmount("Amount exceeds maximum limit")
        }
        guard abs(amount) >= 0.01 else {
            throw ValidationError.invalidAmount("Amount must be at least $0.01")
        }
    }

    /// Validate transaction category
    /// - Parameter category: Category to validate
    /// - Throws: ValidationError for invalid categories
    func validateCategory(_ category: String) throws {
        let trimmed = category.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw ValidationError.invalidCategory("Category cannot be empty")
        }
        guard trimmed.count <= 50 else {
            throw ValidationError.invalidCategory("Category too long")
        }
        guard trimmed.count >= 2 else {
            throw ValidationError.invalidCategory("Category too short")
        }
    }

    /// Validate transaction note
    /// - Parameter note: Note to validate
    /// - Throws: ValidationError for invalid notes
    func validateNote(_ note: String) throws {
        let trimmed = note.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count <= 200 else {
            throw ValidationError.invalidNote("Note too long")
        }
    }

    /// Sanitize category
    /// - Parameter category: Category to sanitize
    /// - Returns: Sanitized category
    func sanitizeCategory(_ category: String) -> String {
        return category.trimmingCharacters(in: .whitespacesAndNewlines).capitalized
    }

    /// Sanitize note
    /// - Parameter note: Note to sanitize
    /// - Returns: Sanitized note
    func sanitizeNote(_ note: String?) -> String? {
        guard let note = note else { return nil }
        return note.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

/// Validation error types
enum ValidationError: LocalizedError {
    case invalidAmount(String)
    case invalidCategory(String)
    case invalidNote(String)

    var errorDescription: String? {
        switch self {
        case .invalidAmount(let message):
            return "Invalid Amount: \(message)"
        case .invalidCategory(let message):
            return "Invalid Category: \(message)"
        case .invalidNote(let message):
            return "Invalid Note: \(message)"
        }
    }
}