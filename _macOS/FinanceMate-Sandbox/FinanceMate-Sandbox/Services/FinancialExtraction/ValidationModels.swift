// SANDBOX FILE: For testing/development. See .cursorrules.
//
//  ValidationModels.swift
//  FinanceMate-Sandbox
//
//  Created by Assistant on 6/6/25.
//

/*
* Purpose: Validation and analysis models for financial data processing and quality assurance
* Issues & Complexity Summary: Validation model extraction supporting TDD approach for comprehensive data quality checks
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~80
  - Core Algorithm Complexity: Low (validation structures and result models)
  - Dependencies: 2 New (Foundation, FinancialDataModels)
  - State Management Complexity: Low (validation result structures)
  - Novelty/Uncertainty Factor: Low (extracted from working implementation)
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 15%
* Problem Estimate (Inherent Problem Difficulty %): 12%
* Initial Code Complexity Estimate %): 14%
* Justification for Estimates: Simple validation model structures with clear interfaces
* Final Code Complexity (Actual %): 17%
* Overall Result Score (Success & Quality %): 98%
* Key Variances/Learnings: Validation model separation enables better testing and error handling
* Last Updated: 2025-06-06
*/

import Foundation

// MARK: - Validation Models

public struct ValidationResult {
    public let isValid: Bool
    public let errors: [FinancialValidationError]
    public let warnings: [String]
    public let confidence: Double
    
    public init(isValid: Bool, errors: [FinancialValidationError] = [], warnings: [String] = [], confidence: Double = 1.0) {
        self.isValid = isValid
        self.errors = errors
        self.warnings = warnings
        self.confidence = confidence
    }
}

public enum FinancialValidationError: Error, LocalizedError {
    case missingRequiredAmount
    case invalidAmountFormat
    case inconsistentAmounts
    case missingVendorInfo
    case invalidDateFormat
    case futureDateDetected
    case suspiciousAmountPattern
    case duplicateTransaction
    case invalidCurrency
    case amountMismatch
    
    public var errorDescription: String? {
        switch self {
        case .missingRequiredAmount:
            return "Required amount information is missing"
        case .invalidAmountFormat:
            return "Amount format is invalid or unrecognizable"
        case .inconsistentAmounts:
            return "Amounts are inconsistent across the document"
        case .missingVendorInfo:
            return "Vendor information is missing or incomplete"
        case .invalidDateFormat:
            return "Date format is invalid or unrecognizable"
        case .futureDateDetected:
            return "Future date detected in financial document"
        case .suspiciousAmountPattern:
            return "Suspicious amount pattern detected"
        case .duplicateTransaction:
            return "Duplicate transaction detected"
        case .invalidCurrency:
            return "Invalid or unsupported currency detected"
        case .amountMismatch:
            return "Amount totals do not match"
        }
    }
}

public struct LineItem {
    public let description: String
    public let amount: String
    public let quantity: Int?
    public let unitPrice: String?
    
    public init(description: String, amount: String, quantity: Int? = nil, unitPrice: String? = nil) {
        self.description = description
        self.amount = amount
        self.quantity = quantity
        self.unitPrice = unitPrice
    }
}

// MARK: - Analysis Models

public struct RecurringAnalysis {
    public let patterns: [RecurringPattern]
    public let confidence: Double
    public let totalRecurringAmount: Double
    
    public init(patterns: [RecurringPattern], confidence: Double, totalRecurringAmount: Double) {
        self.patterns = patterns
        self.confidence = confidence
        self.totalRecurringAmount = totalRecurringAmount
    }
}

public struct RecurringPattern {
    public let vendorName: String
    public let transactions: [FinancialTransaction]
    public let averageAmount: Double
    public let frequency: TransactionFrequency
    public let confidence: Double
    
    public init(vendorName: String, transactions: [FinancialTransaction], averageAmount: Double, frequency: TransactionFrequency, confidence: Double) {
        self.vendorName = vendorName
        self.transactions = transactions
        self.averageAmount = averageAmount
        self.frequency = frequency
        self.confidence = confidence
    }
}

public enum TransactionFrequency: String, CaseIterable {
    case weekly = "weekly"
    case biweekly = "biweekly"
    case monthly = "monthly"
    case quarterly = "quarterly"
    case yearly = "yearly"
    case irregular = "irregular"
    
    public var displayName: String {
        switch self {
        case .weekly: return "Weekly"
        case .biweekly: return "Bi-weekly"
        case .monthly: return "Monthly"
        case .quarterly: return "Quarterly"
        case .yearly: return "Yearly"
        case .irregular: return "Irregular"
        }
    }
}

public struct FraudAnalysis {
    public let riskScore: Double
    public let riskFactors: [FraudRiskFactor]
    public let isHighRisk: Bool
    public let confidence: Double
    
    public init(riskScore: Double, riskFactors: [FraudRiskFactor], isHighRisk: Bool, confidence: Double) {
        self.riskScore = riskScore
        self.riskFactors = riskFactors
        self.isHighRisk = isHighRisk
        self.confidence = confidence
    }
}

public enum FraudRiskFactor: String, CaseIterable {
    case unusualAmount = "unusual_amount"
    case suspiciousVendor = "suspicious_vendor"
    case duplicateTransaction = "duplicate_transaction"
    case roundNumbers = "round_numbers"
    case weekendTransaction = "weekend_transaction"
    case unusualLocation = "unusual_location"
    case highFrequency = "high_frequency"
    case inconsistentPattern = "inconsistent_pattern"
    
    public var displayName: String {
        switch self {
        case .unusualAmount: return "Unusual Amount"
        case .suspiciousVendor: return "Suspicious Vendor"
        case .duplicateTransaction: return "Duplicate Transaction"
        case .roundNumbers: return "Round Numbers"
        case .weekendTransaction: return "Weekend Transaction"
        case .unusualLocation: return "Unusual Location"
        case .highFrequency: return "High Frequency"
        case .inconsistentPattern: return "Inconsistent Pattern"
        }
    }
    
    public var riskWeight: Double {
        switch self {
        case .unusualAmount: return 0.3
        case .suspiciousVendor: return 0.4
        case .duplicateTransaction: return 0.8
        case .roundNumbers: return 0.2
        case .weekendTransaction: return 0.1
        case .unusualLocation: return 0.3
        case .highFrequency: return 0.3
        case .inconsistentPattern: return 0.4
        }
    }
}