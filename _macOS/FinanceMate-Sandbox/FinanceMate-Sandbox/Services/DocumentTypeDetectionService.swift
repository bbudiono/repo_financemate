// SANDBOX FILE: For testing/development. See .cursorrules.

//
//  DocumentTypeDetectionService.swift
//  FinanceMate-Sandbox
//
//  Created by Assistant on 6/6/25.
//

/*
* Purpose: Atomic service for detecting and classifying financial document types
* Scope: Single responsibility - document type analysis and classification
* Dependencies: Foundation only
* Testing: Comprehensive unit tests with mock data
* Integration: Part of FinancialDocumentProcessor modularization
*/

import Foundation

// MARK: - Document Type Detection Service

public class DocumentTypeDetectionService {
    
    // MARK: - Public Methods
    
    /// Detects the financial document type based on URL and filename analysis
    /// - Parameter url: The document URL to analyze
    /// - Returns: The classified document type
    public func detectDocumentType(from url: URL) -> ProcessedDocumentType {
        let fileName = url.lastPathComponent.lowercased()
        let pathExtension = url.pathExtension.lowercased()
        
        // Analyze filename patterns first for more accurate classification
        let detectedType = analyzeFilenamePatterns(fileName: fileName)
        
        // If no specific pattern found, use extension-based fallback
        if detectedType == .unknown {
            return analyzeFileExtension(extension: pathExtension)
        }
        
        return detectedType
    }
    
    /// Detects document type from text content analysis
    /// - Parameter text: The extracted text content
    /// - Returns: The classified document type based on content
    public func detectDocumentTypeFromContent(text: String) -> ProcessedDocumentType {
        let lowerText = text.lowercased()
        
        // Score different document types based on keyword presence
        let typeScores = calculateDocumentTypeScores(text: lowerText)
        
        // Return the type with highest confidence score
        return typeScores.max(by: { $0.value < $1.value })?.key ?? .unknown
    }
    
    /// Validates if a document type is supported for financial processing
    /// - Parameter documentType: The document type to validate
    /// - Returns: True if the document type is supported
    public func isDocumentTypeSupported(_ documentType: ProcessedDocumentType) -> Bool {
        switch documentType {
        case .invoice, .receipt, .bankStatement, .taxDocument, .expenseReport:
            return true
        case .contract, .unknown:
            return false
        }
    }
    
    /// Gets confidence level for document type detection
    /// - Parameters:
    ///   - fileName: The filename to analyze
    ///   - content: Optional content for additional verification
    /// - Returns: Confidence score between 0.0 and 1.0
    public func getDetectionConfidence(fileName: String, content: String? = nil) -> Double {
        var confidence = 0.0
        
        // Filename pattern confidence
        confidence += filenameConfidence(fileName: fileName.lowercased())
        
        // Content-based confidence (if available)
        if let content = content {
            confidence += contentConfidence(text: content.lowercased())
        } else {
            confidence += 0.2 // Base confidence when no content available
        }
        
        return min(confidence, 1.0)
    }
    
    // MARK: - Private Methods
    
    private func analyzeFilenamePatterns(fileName: String) -> ProcessedDocumentType {
        let patterns: [(pattern: String, type: ProcessedDocumentType)] = [
            ("invoice", .invoice),
            ("inv-", .invoice),
            ("inv_", .invoice),
            ("receipt", .receipt),
            ("rcpt", .receipt),
            ("statement", .bankStatement),
            ("bank", .bankStatement),
            ("stmt", .bankStatement),
            ("tax", .taxDocument),
            ("1099", .taxDocument),
            ("w2", .taxDocument),
            ("w-2", .taxDocument),
            ("expense", .expenseReport),
            ("report", .expenseReport),
            ("contract", .contract),
            ("agreement", .contract)
        ]
        
        for (pattern, type) in patterns {
            if fileName.contains(pattern) {
                return type
            }
        }
        
        return .unknown
    }
    
    private func analyzeFileExtension(extension: String) -> ProcessedDocumentType {
        switch extension {
        case "pdf":
            return .invoice // Most common financial PDF type
        case "jpg", "jpeg", "png", "heic", "tiff":
            return .receipt // Most common financial image type
        case "txt", "rtf":
            return .expenseReport // Text-based reports
        default:
            return .unknown
        }
    }
    
    private func calculateDocumentTypeScores(text: String) -> [ProcessedDocumentType: Double] {
        let keywords: [ProcessedDocumentType: [String]] = [
            .invoice: ["invoice", "bill to", "invoice number", "due date", "payment terms", "subtotal"],
            .receipt: ["receipt", "thank you", "purchase", "cash", "credit card", "total paid"],
            .bankStatement: ["statement", "bank", "account balance", "transaction", "deposit", "withdrawal"],
            .taxDocument: ["tax", "w-2", "1099", "tax year", "federal", "withholding", "irs"],
            .expenseReport: ["expense", "report", "business", "travel", "meals", "mileage"],
            .contract: ["contract", "agreement", "terms", "conditions", "parties", "signature"]
        ]
        
        var scores: [ProcessedDocumentType: Double] = [:]
        
        for (documentType, keywordList) in keywords {
            var score = 0.0
            let totalKeywords = Double(keywordList.count)
            
            for keyword in keywordList {
                if text.contains(keyword) {
                    score += 1.0 / totalKeywords
                }
            }
            
            scores[documentType] = score
        }
        
        return scores
    }
    
    private func filenameConfidence(fileName: String) -> Double {
        let strongPatterns = ["invoice", "receipt", "statement", "tax"]
        let mediumPatterns = ["inv", "rcpt", "stmt", "1099", "w2"]
        let weakPatterns = ["doc", "file", "scan", "img"]
        
        for pattern in strongPatterns {
            if fileName.contains(pattern) {
                return 0.6
            }
        }
        
        for pattern in mediumPatterns {
            if fileName.contains(pattern) {
                return 0.4
            }
        }
        
        for pattern in weakPatterns {
            if fileName.contains(pattern) {
                return 0.1
            }
        }
        
        return 0.2 // Base confidence
    }
    
    private func contentConfidence(text: String) -> Double {
        let essentialKeywords = ["total", "amount", "date", "$"]
        let financialKeywords = ["tax", "invoice", "payment", "receipt"]
        
        var confidence = 0.0
        let textLength = text.count
        
        // Basic financial document indicators
        for keyword in essentialKeywords {
            if text.contains(keyword) {
                confidence += 0.1
            }
        }
        
        // Specific financial terminology
        for keyword in financialKeywords {
            if text.contains(keyword) {
                confidence += 0.05
            }
        }
        
        // Text length indicates complete document
        if textLength > 200 {
            confidence += 0.1
        } else if textLength > 50 {
            confidence += 0.05
        }
        
        return min(confidence, 0.4) // Max content confidence contribution
    }
}

// MARK: - Supporting Types (if not already defined elsewhere)

public enum ProcessedDocumentType: String, CaseIterable, Codable {
    case invoice = "Invoice"
    case receipt = "Receipt"
    case bankStatement = "Bank Statement"
    case taxDocument = "Tax Document"
    case expenseReport = "Expense Report"
    case contract = "Contract"
    case unknown = "Unknown"
}