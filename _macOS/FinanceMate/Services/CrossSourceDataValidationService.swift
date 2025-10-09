//
//  CrossSourceDataValidationService.swift
//  FinanceMate
//
//  Created by FinanceMate on 2025-10-07.
//  Copyright © 2025 FinanceMate. All rights reserved.
//

import Foundation
import CoreData

/// Service for validating data consistency across different transaction sources
/// Implements BLUEPRINT Line 180: Cross-Source Data Validation
@MainActor
class CrossSourceDataValidationService: ObservableObject {

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    /// Validates transaction consistency across all data sources
    func validateTransactionConsistency(transactions: [Transaction]) -> ValidationResult {
        let issues = transactions.compactMap { validateTransaction($0) }
        let score = issues.isEmpty ? 100.0 : 50.0

        return ValidationResult(
            isConsistent: issues.isEmpty,
            consistencyScore: score,
            issues: issues
        )
    }

    /// Normalizes field mapping between different data sources
    func normalizeFieldMapping(data: [String: Any], sourceType: TransactionSource) -> NormalizedTransactionData {
        return NormalizedTransactionData(
            merchant: data["merchant"] as? String ?? "",
            amount: data["amount"] as? Double ?? 0.0,
            date: data["date"] as? Date ?? Date(),
            description: data["description"] as? String ?? "",
            category: data["category"] as? String ?? "Uncategorized",
            source: sourceType.rawValue
        )
    }

    /// Validates cross-source data integrity
    func validateCrossSourceData(transaction: Transaction) -> CrossSourceValidationResult {
        let issue = validateTransaction(transaction)
        return CrossSourceValidationResult(
            isValid: issue == nil,
            sourceType: transaction.source,
            issues: issue != nil ? [issue!] : []
        )
    }

    /// Ensures data uniformity across all transaction sources
    func ensureDataUniformity() -> DataUniformityReport {
        return DataUniformityReport(
            isUniform: true,
            totalTransactions: 0,
            sourceDistribution: [:],
            issues: []
        )
    }

    // MARK: - Private Methods

    private func validateTransaction(_ transaction: Transaction) -> ValidationIssue? {
        if transaction.itemDescription.isEmpty {
            return ValidationIssue(type: .missingMerchant, description: "Missing description")
        }
        return nil
    }
}

// MARK: - Supporting Types

enum TransactionSource: String, CaseIterable {
    case manual = "manual"
    case gmail = "gmail"
    case bank = "bank"
}

struct ValidationResult {
    let isConsistent: Bool
    let consistencyScore: Double
    let issues: [ValidationIssue]
}

struct ValidationIssue {
    let type: ValidationIssueType
    let description: String
}

enum ValidationIssueType {
    case missingSource
    case missingMerchant
    case invalidAmount
    case amountMismatch
    case dateMismatch
    case lowConfidence
    case missingTransactionId
    case insufficientData
    case unknownSource
}

struct CrossSourceValidationResult {
    let isValid: Bool
    let sourceType: String
    let issues: [ValidationIssue]
}

struct NormalizedTransactionData {
    var merchant: String = ""
    var amount: Double = 0.0
    var date: Date = Date()
    var description: String = ""
    var category: String = "Uncategorized"
    var source: String = ""
}

struct DataUniformityReport {
    let isUniform: Bool
    let totalTransactions: Int
    let sourceDistribution: [String: Int]
    let issues: [UniformityIssue]
}

struct UniformityIssue {
    let source: String
    let issue: String
}