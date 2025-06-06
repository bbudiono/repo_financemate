// SANDBOX FILE: For testing/development. See .cursorrules.

//
//  CommonTypes.swift
//  FinanceMate-Sandbox
//
//  Created by Assistant on 6/5/25.
//

/*
* Purpose: Shared type definitions to prevent duplicate enum conflicts
* Issues & Complexity Summary: Central type definitions for LLM providers and authentication
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~100
  - Core Algorithm Complexity: Low
  - Dependencies: 0 New (Foundation types only)
  - State Management Complexity: Low
  - Novelty/Uncertainty Factor: Low
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 30%
* Problem Estimate (Inherent Problem Difficulty %): 25%
* Initial Code Complexity Estimate %: 28%
* Justification for Estimates: Simple enum definitions with string mappings
* Final Code Complexity (Actual %): 28%
* Overall Result Score (Success & Quality %): 95%
* Key Variances/Learnings: Centralized type definitions prevent compilation conflicts
* Last Updated: 2025-06-05
*/

import Foundation

// MARK: - Document Type Definitions

/// Document type enumeration used across financial processing services
public enum ProcessedDocumentType: String, CaseIterable, Codable {
    case invoice = "Invoice"
    case receipt = "Receipt"
    case bankStatement = "Bank Statement"
    case taxDocument = "Tax Document"
    case expenseReport = "Expense Report"
    case contract = "Contract"
    case unknown = "Unknown"
    
    public var icon: String {
        switch self {
        case .invoice: return "doc.text.fill"
        case .receipt: return "receipt"
        case .bankStatement: return "building.columns"
        case .taxDocument: return "doc.badge.plus"
        case .expenseReport: return "chart.line.uptrend.xyaxis"
        case .contract: return "doc.badge.gearshape"
        case .unknown: return "questionmark.square"
        }
    }
    
    public var color: String {
        switch self {
        case .invoice: return "blue"
        case .receipt: return "green"
        case .bankStatement: return "indigo"
        case .taxDocument: return "red"
        case .expenseReport: return "orange"
        case .contract: return "purple"
        case .unknown: return "gray"
        }
    }
}

// MARK: - Financial Data Models

/// Extracted expense category enumeration used across financial processing services
public enum ExtractedExpenseCategory: String, CaseIterable, Codable, Comparable {
    case office = "Office Supplies"
    case travel = "Travel"
    case meals = "Meals & Entertainment"
    case utilities = "Utilities"
    case software = "Software"
    case marketing = "Marketing"
    case professional = "Professional Services"
    case equipment = "Equipment"
    case maintenance = "Maintenance"
    case insurance = "Insurance"
    case other = "Other"
    
    public static func < (lhs: ExtractedExpenseCategory, rhs: ExtractedExpenseCategory) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    
    public var icon: String {
        switch self {
        case .office: return "pencil.and.outline"
        case .travel: return "airplane"
        case .meals: return "fork.knife"
        case .utilities: return "bolt"
        case .software: return "app.badge"
        case .marketing: return "megaphone"
        case .professional: return "briefcase"
        case .equipment: return "desktopcomputer"
        case .maintenance: return "wrench.and.screwdriver"
        case .insurance: return "shield"
        case .other: return "questionmark.circle"
        }
    }
    
    public var color: String {
        switch self {
        case .office: return "blue"
        case .travel: return "green"
        case .meals: return "orange"
        case .utilities: return "yellow"
        case .software: return "purple"
        case .marketing: return "pink"
        case .professional: return "indigo"
        case .equipment: return "gray"
        case .maintenance: return "brown"
        case .insurance: return "red"
        case .other: return "secondary"
        }
    }
}

/// Extracted amount structure used across financial processing services
public struct ExtractedAmount: Codable, Equatable {
    public let value: Double
    public let currency: String
    public let formattedString: String
    
    public init(value: Double, currency: String, formattedString: String) {
        self.value = value
        self.currency = currency
        self.formattedString = formattedString
    }
}

/// Extracted line item structure used across financial processing services
public struct ExtractedLineItem: Codable, Equatable {
    public let description: String
    public let quantity: Double
    public let unitPrice: Double
    public let totalAmount: ExtractedAmount
    public let category: ExtractedExpenseCategory
    
    public init(description: String, quantity: Double, unitPrice: Double, totalAmount: ExtractedAmount, category: ExtractedExpenseCategory) {
        self.description = description
        self.quantity = quantity
        self.unitPrice = unitPrice
        self.totalAmount = totalAmount
        self.category = category
    }
}

/// Extracted vendor structure used across financial processing services
public struct ExtractedVendor: Codable, Equatable {
    public let name: String
    public let address: String?
    public let taxId: String?
    
    public init(name: String, address: String?, taxId: String?) {
        self.name = name
        self.address = address
        self.taxId = taxId
    }
}

/// Extracted customer structure used across financial processing services
public struct ExtractedCustomer: Codable, Equatable {
    public let name: String
    public let address: String?
    public let email: String?
    
    public init(name: String, address: String?, email: String?) {
        self.name = name
        self.address = address
        self.email = email
    }
}

/// Extracted date structure used across financial processing services
public struct ExtractedDate: Codable, Equatable {
    public let date: Date
    public let type: ExtractedDateType
    public let context: String
    
    public init(date: Date, type: ExtractedDateType, context: String) {
        self.date = date
        self.type = type
        self.context = context
    }
}

/// Extracted date type enumeration used across financial processing services
public enum ExtractedDateType: String, CaseIterable, Codable {
    case invoiceDate = "Invoice Date"
    case dueDate = "Due Date"
    case serviceDate = "Service Date"
    case paymentDate = "Payment Date"
    case transactionDate = "Transaction Date"
}

/// Extracted tax information structure used across financial processing services
public struct ExtractedTaxInfo: Codable, Equatable {
    public let taxAmount: ExtractedAmount?
    public let taxRate: Double?
    public let taxId: String?
    public let isTaxExempt: Bool
    
    public init(taxAmount: ExtractedAmount?, taxRate: Double?, taxId: String?, isTaxExempt: Bool) {
        self.taxAmount = taxAmount
        self.taxRate = taxRate
        self.taxId = taxId
        self.isTaxExempt = isTaxExempt
    }
}

// MARK: - LLM Provider Types

/// Shared LLM Provider enumeration used across all services
public enum LLMProvider: String, CaseIterable, Codable {
    case openai = "openai"
    case anthropic = "anthropic"
    case googleai = "googleai"
    
    public var displayName: String {
        switch self {
        case .openai: return "OpenAI"
        case .anthropic: return "Anthropic"
        case .googleai: return "Google AI"
        }
    }
    
    public var apiKeyEnvironmentVariable: String {
        switch self {
        case .openai: return "OPENAI_API_KEY"
        case .anthropic: return "ANTHROPIC_API_KEY"
        case .googleai: return "GOOGLE_AI_API_KEY"
        }
    }
}

// MARK: - Authentication Types

public enum AuthenticationProvider: String, CaseIterable, Codable {
    case apple = "apple"
    case google = "google"
    case microsoft = "microsoft"
    
    public var displayName: String {
        switch self {
        case .apple: return "Apple"
        case .google: return "Google"
        case .microsoft: return "Microsoft"
        }
    }
}

public enum AuthenticationState: Equatable {
    case unauthenticated
    case authenticating
    case authenticated
    case failed(String)
    
    public static func == (lhs: AuthenticationState, rhs: AuthenticationState) -> Bool {
        switch (lhs, rhs) {
        case (.unauthenticated, .unauthenticated),
             (.authenticating, .authenticating),
             (.authenticated, .authenticated):
            return true
        case (.failed(let lhsError), .failed(let rhsError)):
            return lhsError == rhsError
        default:
            return false
        }
    }
}

// MARK: - API Response Types

public struct APIResponse<T: Codable>: Codable {
    public let data: T?
    public let error: String?
    public let timestamp: Date
    
    public init(data: T? = nil, error: String? = nil) {
        self.data = data
        self.error = error
        self.timestamp = Date()
    }
}

public struct LLMAuthenticationResult {
    public let provider: LLMProvider
    public let isValid: Bool
    public let error: String?
    public let responseTime: TimeInterval?
    public let success: Bool
    public let userInfo: [String: Any]?
    public let fallbackUsed: String?
    
    public init(provider: LLMProvider, isValid: Bool, error: String? = nil, responseTime: TimeInterval? = nil) {
        self.provider = provider
        self.isValid = isValid
        self.error = error
        self.responseTime = responseTime
        self.success = isValid
        self.userInfo = nil
        self.fallbackUsed = nil
    }
    
    public init(provider: LLMProvider, success: Bool, userInfo: [String: Any]? = nil, error: String? = nil, responseTime: TimeInterval? = nil, fallbackUsed: String? = nil) {
        self.provider = provider
        self.isValid = success
        self.success = success
        self.userInfo = userInfo
        self.error = error
        self.responseTime = responseTime
        self.fallbackUsed = fallbackUsed
    }
}