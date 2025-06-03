//
//  DocumentProcessingService.swift
//  FinanceMate-Sandbox
//
//  Created by Assistant on 6/2/25.
//

// SANDBOX FILE: For testing/development. See .cursorrules.

/*
* Purpose: Document processing service for handling file analysis and content extraction in Sandbox
* Issues & Complexity Summary: Initial TDD implementation - will fail tests to drive development
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~200
  - Core Algorithm Complexity: Medium
  - Dependencies: 3 New (file processing, content extraction, type detection)
  - State Management Complexity: Medium
  - Novelty/Uncertainty Factor: Medium
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 70%
* Problem Estimate (Inherent Problem Difficulty %): 65%
* Initial Code Complexity Estimate %: 67%
* Justification for Estimates: Standard document processing with type detection and content extraction
* Final Code Complexity (Actual %): TBD - Initial implementation
* Overall Result Score (Success & Quality %): TBD - TDD iteration
* Key Variances/Learnings: TDD approach ensures robust document processing workflow
* Last Updated: 2025-06-02
*/

import Foundation
import PDFKit
import SwiftUI
import Combine

// MARK: - Document Processing Service

@MainActor
public class DocumentProcessingService: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published public var isProcessing: Bool = false
    @Published public var processedDocuments: [ProcessedDocument] = []
    
    // MARK: - Initialization
    
    public init() {
        // Initialize document processing service
    }
    
    // MARK: - Public Methods
    
    public func processDocument(url: URL) async -> Result<ProcessedDocument, Error> {
        isProcessing = true
        
        defer {
            Task { @MainActor in
                isProcessing = false
            }
        }
        
        do {
            // Detect file type
            let fileType = FileType.from(url: url)
            
            // Extract text content based on file type
            var extractedText = ""
            
            switch fileType {
            case .pdf:
                extractedText = extractTextFromPDF(url: url)
            case .image:
                extractedText = "" // OCR will handle this
            case .text:
                extractedText = try String(contentsOf: url, encoding: .utf8)
            default:
                extractedText = ""
            }
            
            let processedDocument = ProcessedDocument(
                id: UUID(),
                originalURL: url,
                fileType: fileType,
                extractedText: extractedText,
                extractedData: [:],
                processingStatus: .completed,
                processedDate: Date(),
                confidence: calculateProcessingConfidence(text: extractedText, type: fileType)
            )
            
            processedDocuments.append(processedDocument)
            
            return .success(processedDocument)
            
        } catch {
            return .failure(DocumentProcessingError.processingFailed(error))
        }
    }
    
    // MARK: - Private Methods
    
    private func extractTextFromPDF(url: URL) -> String {
        guard let pdfDocument = PDFDocument(url: url) else {
            return ""
        }
        
        var extractedText = ""
        
        for pageIndex in 0..<pdfDocument.pageCount {
            if let page = pdfDocument.page(at: pageIndex) {
                extractedText += page.string ?? ""
                extractedText += "\n"
            }
        }
        
        return extractedText
    }
    
    public func processDocuments(urls: [URL]) async -> [Result<ProcessedDocument, Error>] {
        var results: [Result<ProcessedDocument, Error>] = []
        
        for url in urls {
            let result = await processDocument(url: url)
            results.append(result)
        }
        
        return results
    }
    
    public func detectFileType(from url: URL) -> FileType {
        let fileName = url.lastPathComponent.lowercased()
        
        if fileName.contains("invoice") {
            return .invoice
        } else if fileName.contains("receipt") {
            return .receipt
        } else if fileName.contains("statement") {
            return .statement
        } else if fileName.contains("contract") || fileName.contains("lease") {
            return .contract
        } else {
            return FileType.from(url: url)
        }
    }
    
    private func calculateProcessingConfidence(text: String, type: FileType) -> Double {
        if text.isEmpty {
            return 0.1
        }
        
        switch type {
        case .pdf:
            return text.count > 100 ? 0.9 : 0.6
        case .text:
            return 0.8
        case .image:
            return 0.3 // Will improve with OCR
        default:
            return 0.5
        }
    }
}

// MARK: - Supporting Data Models

public struct ProcessedDocument {
    public let id: UUID
    public let originalURL: URL
    public let fileType: FileType
    public let extractedText: String
    public let extractedData: [String: Any]
    public let processingStatus: DocumentProcessingStatus
    public let processedDate: Date
    public let confidence: Double
    
    public init(id: UUID, originalURL: URL, fileType: FileType, extractedText: String, extractedData: [String: Any], processingStatus: DocumentProcessingStatus, processedDate: Date, confidence: Double) {
        self.id = id
        self.originalURL = originalURL
        self.fileType = fileType
        self.extractedText = extractedText
        self.extractedData = extractedData
        self.processingStatus = processingStatus
        self.processedDate = processedDate
        self.confidence = confidence
    }
}

public enum DocumentProcessingStatus: String, CaseIterable, Codable {
    case pending = "pending"
    case processing = "processing"
    case completed = "completed"
    case failed = "failed"
    case cancelled = "cancelled"
    
    var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .processing: return "Processing"
        case .completed: return "Completed"
        case .failed: return "Failed"
        case .cancelled: return "Cancelled"
        }
    }
    
    var color: Color {
        switch self {
        case .pending: return .orange
        case .processing: return .blue
        case .completed: return .green
        case .failed: return .red
        case .cancelled: return .gray
        }
    }
}

public enum FileType: String, CaseIterable {
    case pdf = "PDF"
    case image = "Image"
    case text = "Text"
    case invoice = "Invoice"
    case receipt = "Receipt"
    case statement = "Statement"
    case contract = "Contract"
    case other = "Other"
    
    public static func from(url: URL) -> FileType {
        let pathExtension = url.pathExtension.lowercased()
        
        switch pathExtension {
        case "pdf":
            return .pdf
        case "jpg", "jpeg", "png", "tiff", "tif", "heic", "heif", "bmp":
            return .image
        case "txt", "rtf":
            return .text
        default:
            return .other
        }
    }
    
    public var icon: String {
        switch self {
        case .pdf: return "doc.text"
        case .image: return "photo"
        case .text: return "text.alignleft"
        case .invoice: return "doc.text.fill"
        case .receipt: return "receipt"
        case .statement: return "list.bullet.rectangle"
        case .contract: return "doc.badge.gearshape"
        case .other: return "questionmark.square"
        }
    }
    
    public var color: Color {
        switch self {
        case .pdf: return .blue
        case .image: return .green
        case .text: return .gray
        case .invoice: return .orange
        case .receipt: return .purple
        case .statement: return .indigo
        case .contract: return .red
        case .other: return .secondary
        }
    }
}

public enum DocumentProcessingError: Error, LocalizedError {
    case processingFailed(Error)
    case unsupportedFormat
    case fileNotFound
    case accessDenied
    
    public var errorDescription: String? {
        switch self {
        case .processingFailed(let error):
            return "Document processing failed: \(error.localizedDescription)"
        case .unsupportedFormat:
            return "Unsupported document format"
        case .fileNotFound:
            return "Document file not found"
        case .accessDenied:
            return "Access denied to document"
        }
    }
}