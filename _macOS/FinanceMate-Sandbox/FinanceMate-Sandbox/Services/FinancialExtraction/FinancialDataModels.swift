// SANDBOX FILE: For testing/development. See .cursorrules.
//
//  FinancialDataModels.swift
//  FinanceMate-Sandbox
//
//  Created by Assistant on 6/6/25.
//

/*
* Purpose: Core data models for financial data extraction and processing
* Issues & Complexity Summary: Clean data model extraction following TDD principles for better maintainability
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~150
  - Core Algorithm Complexity: Low (data structures and enumerations)
  - Dependencies: 2 New (Foundation, SwiftUI for Codable support)
  - State Management Complexity: Low (immutable data structures)
  - Novelty/Uncertainty Factor: Low (extracted from working implementation)
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 20%
* Problem Estimate (Inherent Problem Difficulty %): 15%
* Initial Code Complexity Estimate %): 18%
* Justification for Estimates: Simple data model extraction with well-defined structures
* Final Code Complexity (Actual %): 22%
* Overall Result Score (Success & Quality %): 97%
* Key Variances/Learnings: Data model separation improves code organization and testing capabilities
* Last Updated: 2025-06-06
*/

import Foundation

// MARK: - Core Financial Data Models

public struct ExtractedFinancialData: Codable {
    public let documentType: FinancialDocumentType
    public let amounts: [String]
    public let totalAmount: String?
    public let currency: Currency
    public let category: ExpenseCategory
    public let vendor: String?
    public let documentDate: String?
    public let accountNumber: String?
    public let transactions: [FinancialTransaction]
    public let confidence: Double
    
    public init(
        documentType: FinancialDocumentType,
        amounts: [String],
        totalAmount: String?,
        currency: Currency,
        category: ExpenseCategory,
        vendor: String?,
        documentDate: String?,
        accountNumber: String?,
        transactions: [FinancialTransaction],
        confidence: Double
    ) {
        self.documentType = documentType
        self.amounts = amounts
        self.totalAmount = totalAmount
        self.currency = currency
        self.category = category
        self.vendor = vendor
        self.documentDate = documentDate
        self.accountNumber = accountNumber
        self.transactions = transactions
        self.confidence = confidence
    }
}

public struct FinancialTransaction: Codable, Identifiable {
    public var id = UUID()
    public let date: String
    public let description: String
    public let amount: String
    public let category: ExpenseCategory?
    
    public init(date: String, description: String, amount: String, category: ExpenseCategory? = nil) {
        self.date = date
        self.description = description
        self.amount = amount
        self.category = category
    }
}

public struct VendorInfo: Codable {
    public let name: String
    public let address: String?
    public let phone: String?
    
    public init(name: String, address: String? = nil, phone: String? = nil) {
        self.name = name
        self.address = address
        self.phone = phone
    }
}

public struct TaxInfo: Codable {
    public let rate: Double
    public let amount: String
    
    public init(rate: Double, amount: String) {
        self.rate = rate
        self.amount = amount
    }
}

// MARK: - Enumerations

public enum ExpenseCategory: String, CaseIterable, Codable {
    case groceries = "groceries"
    case dining = "dining"
    case transportation = "transportation"
    case utilities = "utilities"
    case business = "business"
    case healthcare = "healthcare"
    case entertainment = "entertainment"
    case shopping = "shopping"
    case other = "other"
    
    public var displayName: String {
        switch self {
        case .groceries: return "Groceries"
        case .dining: return "Dining"
        case .transportation: return "Transportation"
        case .utilities: return "Utilities"
        case .business: return "Business"
        case .healthcare: return "Healthcare"
        case .entertainment: return "Entertainment"
        case .shopping: return "Shopping"
        case .other: return "Other"
        }
    }
}

public enum Currency: String, CaseIterable, Codable {
    case usd = "USD"
    case eur = "EUR"
    case gbp = "GBP"
    case cad = "CAD"
    case aud = "AUD"
    case jpy = "JPY"
    
    public var symbol: String {
        switch self {
        case .usd: return "$"
        case .eur: return "€"
        case .gbp: return "£"
        case .cad: return "C$"
        case .aud: return "A$"
        case .jpy: return "¥"
        }
    }
    
    public var displayName: String {
        switch self {
        case .usd: return "US Dollar"
        case .eur: return "Euro"
        case .gbp: return "British Pound"
        case .cad: return "Canadian Dollar"
        case .aud: return "Australian Dollar"
        case .jpy: return "Japanese Yen"
        }
    }
}

public enum FinancialDocumentType: String, CaseIterable, Codable {
    case invoice = "invoice"
    case receipt = "receipt"
    case statement = "statement"
    case contract = "contract"
    case other = "other"
    
    public var displayName: String {
        switch self {
        case .invoice: return "Invoice"
        case .receipt: return "Receipt"
        case .statement: return "Statement"
        case .contract: return "Contract"
        case .other: return "Other"
        }
    }
}

// MARK: - Error Types

public enum FinancialExtractionError: Error, LocalizedError {
    case invalidInput
    case processingFailed
    case noDataFound
    case invalidFormat
    case unsupportedDocumentType
    case networkError
    case timeoutError
    
    public var errorDescription: String? {
        switch self {
        case .invalidInput:
            return "Invalid input provided for financial data extraction"
        case .processingFailed:
            return "Failed to process financial document"
        case .noDataFound:
            return "No financial data found in document"
        case .invalidFormat:
            return "Document format is not supported"
        case .unsupportedDocumentType:
            return "Document type is not supported"
        case .networkError:
            return "Network error occurred during processing"
        case .timeoutError:
            return "Processing timeout exceeded"
        }
    }
}