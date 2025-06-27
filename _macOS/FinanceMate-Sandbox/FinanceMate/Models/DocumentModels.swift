//
//  DocumentModels.swift
//  FinanceMate
//
//  Created by Assistant on 6/28/25.
//  Extracted from DocumentsView.swift for SwiftLint compliance
//

import Foundation
import SwiftUI

// MARK: - Document Filter Types

enum DocumentFilter: CaseIterable {
    case all
    case invoices
    case receipts
    case statements
    case contracts

    var displayName: String {
        switch self {
        case .all: return "All"
        case .invoices: return "Invoices"
        case .receipts: return "Receipts"
        case .statements: return "Statements"
        case .contracts: return "Contracts"
        }
    }

    var uiDocumentType: UIDocumentType? {
        switch self {
        case .all: return nil
        case .invoices: return .invoice
        case .receipts: return .receipt
        case .statements: return .statement
        case .contracts: return .contract
        }
    }
}

enum UIDocumentType: CaseIterable {
    case invoice
    case receipt
    case statement
    case contract
    case other

    var icon: String {
        switch self {
        case .invoice: return "doc.text"
        case .receipt: return "receipt"
        case .statement: return "doc.plaintext"
        case .contract: return "doc.badge.ellipsis"
        case .other: return "doc"
        }
    }

    var color: Color {
        switch self {
        case .invoice: return .blue
        case .receipt: return .green
        case .statement: return .orange
        case .contract: return .purple
        case .other: return .gray
        }
    }

    var displayName: String {
        switch self {
        case .invoice: return "Invoice"
        case .receipt: return "Receipt"
        case .statement: return "Statement"
        case .contract: return "Contract"
        case .other: return "Other"
        }
    }

    static func from(url: URL) -> UIDocumentType {
        let filename = url.lastPathComponent.lowercased()
        if filename.contains("invoice") { return .invoice }
        if filename.contains("receipt") { return .receipt }
        if filename.contains("statement") { return .statement }
        if filename.contains("contract") { return .contract }
        return .other
    }
}

// MARK: - Document Processing Status

enum UIProcessingStatus {
    case pending
    case processing
    case completed
    case error

    var icon: String {
        switch self {
        case .pending: return "clock"
        case .processing: return "arrow.triangle.2.circlepath"
        case .completed: return "checkmark.circle"
        case .error: return "exclamationmark.triangle"
        }
    }

    var color: Color {
        switch self {
        case .pending: return .orange
        case .processing: return .blue
        case .completed: return .green
        case .error: return .red
        }
    }

    var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .processing: return "Processing"
        case .completed: return "Ready"
        case .error: return "Error"
        }
    }
}

// MARK: - Document Error Types

enum DocumentError: Error, LocalizedError {
    case saveError(String)
    case ocrError(String)
    case fileAccessError(String)
    case unsupportedFormat(String)

    var errorDescription: String? {
        switch self {
        case .saveError(let message):
            return "Failed to save document: \(message)"
        case .ocrError(let message):
            return "OCR processing failed: \(message)"
        case .fileAccessError(let message):
            return "File access error: \(message)"
        case .unsupportedFormat(let message):
            return "Unsupported file format: \(message)"
        }
    }
}

// MARK: - OCR Error Types

enum OCRError: Error, LocalizedError {
    case imagePreprocessingFailed
    case textRecognitionFailed
    case noTextFound
    case invalidImageFormat

    var errorDescription: String? {
        switch self {
        case .imagePreprocessingFailed:
            return "Failed to preprocess image for OCR"
        case .textRecognitionFailed:
            return "Text recognition failed"
        case .noTextFound:
            return "No text found in the document"
        case .invalidImageFormat:
            return "Invalid image format for OCR processing"
        }
    }
}

// MARK: - Performance Metrics

struct DocumentViewPerformanceMetrics {
    var lastFilterTime: TimeInterval = 0
    var totalFilters: Int = 0

    var performanceGrade: PerformanceGrade {
        if lastFilterTime < 0.1 {
            return .excellent
        } else if lastFilterTime < 0.3 {
            return .good
        } else if lastFilterTime < 0.6 {
            return .fair
        } else {
            return .poor
        }
    }
}

enum PerformanceGrade {
    case excellent
    case good
    case fair
    case poor

    var description: String {
        switch self {
        case .excellent: return "Excellent"
        case .good: return "Good"
        case .fair: return "Fair"
        case .poor: return "Poor"
        }
    }

    var color: Color {
        switch self {
        case .excellent: return .green
        case .good: return .blue
        case .fair: return .orange
        case .poor: return .red
        }
    }
}