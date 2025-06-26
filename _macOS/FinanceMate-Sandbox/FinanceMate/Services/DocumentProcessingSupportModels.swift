//
//  DocumentProcessingSupportModels.swift
//  FinanceMate
//
//  Created by Assistant on 6/11/25.
//

/*
* Purpose: Supporting data models for DocumentProcessingManager architecture
* Implementation: Manager pattern compatible models with atomic testing support
* Integration: TaskMaster-AI Level 5-6 compatible data structures
*/

import CoreGraphics
import Foundation
import SwiftUI

// MARK: - Essential Support Models

/// Document type classification for UI
public enum DocumentType: String, CaseIterable {
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
        case .other: return "Document"
        }
    }

    public var icon: String {
        switch self {
        case .invoice: return "doc.text"
        case .receipt: return "receipt"
        case .statement: return "doc.plaintext"
        case .contract: return "doc.text.fill"
        case .other: return "doc"
        }
    }

    public var color: Color {
        switch self {
        case .invoice: return .blue
        case .receipt: return .green
        case .statement: return .purple
        case .contract: return .orange
        case .other: return .gray
        }
    }
}

/// Enhanced document metadata structure
public struct DocumentMetadata: Codable {
    public let fileSize: Int64
    public let mimeType: String
    public let creationDate: Date
    public let modificationDate: Date
    public let fileName: String
    public let fileExtension: String
    public let pageCount: Int?

    public init(
        fileSize: Int64,
        mimeType: String,
        creationDate: Date = Date(),
        modificationDate: Date = Date(),
        fileName: String,
        fileExtension: String,
        pageCount: Int? = nil
    ) {
        self.fileSize = fileSize
        self.mimeType = mimeType
        self.creationDate = creationDate
        self.modificationDate = modificationDate
        self.fileName = fileName
        self.fileExtension = fileExtension
        self.pageCount = pageCount
    }
}

/// Financial document type classification
public enum FinancialDocumentType: String, Codable, CaseIterable {
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

/// Expense category classification
public enum ExpenseCategory: String, Codable, CaseIterable {
    case office = "office"
    case travel = "travel"
    case meals = "meals"
    case utilities = "utilities"
    case supplies = "supplies"
    case marketing = "marketing"
    case other = "other"

    public var displayName: String {
        switch self {
        case .office: return "Office"
        case .travel: return "Travel"
        case .meals: return "Meals"
        case .utilities: return "Utilities"
        case .supplies: return "Supplies"
        case .marketing: return "Marketing"
        case .other: return "Other"
        }
    }
}

/// Risk level assessment
public enum RiskLevel: String, Codable, CaseIterable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case critical = "critical"

    public var displayName: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        case .critical: return "Critical"
        }
    }

    public var color: Color {
        switch self {
        case .low: return .green
        case .medium: return .yellow
        case .high: return .orange
        case .critical: return .red
        }
    }
}

// MARK: - Enhanced Validation Support Models

/// Performance grade assessment for validation
public enum PerformanceGrade: String, Codable, CaseIterable {
    case excellent = "excellent"
    case good = "good"
    case fair = "fair"
    case poor = "poor"

    public var displayName: String {
        switch self {
        case .excellent: return "Excellent"
        case .good: return "Good"
        case .fair: return "Fair"
        case .poor: return "Poor"
        }
    }

    public var color: Color {
        switch self {
        case .excellent: return .green
        case .good: return .blue
        case .fair: return .orange
        case .poor: return .red
        }
    }

    public var score: Double {
        switch self {
        case .excellent: return 1.0
        case .good: return 0.8
        case .fair: return 0.6
        case .poor: return 0.4
        }
    }
}

/// Enhanced validation results
public struct ValidationResults: Codable {
    public let overallScore: Double
    public let fieldValidations: [FieldValidation]
    public let suggestions: [String]
    public let riskAssessment: RiskAssessment?
    public let timestamp: Date

    public init(
        overallScore: Double,
        fieldValidations: [FieldValidation],
        suggestions: [String],
        riskAssessment: RiskAssessment? = nil,
        timestamp: Date = Date()
    ) {
        self.overallScore = overallScore
        self.fieldValidations = fieldValidations
        self.suggestions = suggestions
        self.riskAssessment = riskAssessment
        self.timestamp = timestamp
    }
}

/// Field-specific validation
public struct FieldValidation: Codable, Identifiable {
    public let id = UUID()
    public let field: String
    public let confidence: Double
    public let status: ValidationStatus
    public let issues: [String]

    public init(field: String, confidence: Double, status: ValidationStatus, issues: [String]) {
        self.field = field
        self.confidence = confidence
        self.status = status
        self.issues = issues
    }
}

/// Validation status
public enum ValidationStatus: String, Codable, CaseIterable {
    case validated = "validated"
    case warning = "warning"
    case error = "error"
    case pending = "pending"

    public var displayName: String {
        switch self {
        case .validated: return "Validated"
        case .warning: return "Warning"
        case .error: return "Error"
        case .pending: return "Pending"
        }
    }

    public var color: Color {
        switch self {
        case .validated: return .green
        case .warning: return .orange
        case .error: return .red
        case .pending: return .gray
        }
    }
}

/// Risk assessment structure
public struct RiskAssessment: Codable {
    public let riskLevel: RiskLevel
    public let factors: [String]
    public let score: Double
    public let recommendations: [String]

    public init(riskLevel: RiskLevel, factors: [String], score: Double, recommendations: [String]) {
        self.riskLevel = riskLevel
        self.factors = factors
        self.score = score
        self.recommendations = recommendations
    }
}

/// AI Analysis Result
public struct AIAnalysisResult: Codable {
    public let confidence: Double
    public let structureValid: Bool
    public let issues: [String]
    public let recommendations: [String]
    public let metadata: [String: String]

    public init(
        confidence: Double,
        structureValid: Bool,
        issues: [String],
        recommendations: [String] = [],
        metadata: [String: String] = [:]
    ) {
        self.confidence = confidence
        self.structureValid = structureValid
        self.issues = issues
        self.recommendations = recommendations
        self.metadata = metadata
    }
}
