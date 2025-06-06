// SANDBOX FILE: For testing/development. See .cursorrules.

//
//  DocumentTextExtractionService.swift
//  FinanceMate-Sandbox
//
//  Created by Assistant on 6/6/25.
//

/*
* Purpose: Atomic service for extracting text from various document formats
* Scope: Single responsibility - text extraction via OCR and direct reading
* Dependencies: PDFKit, Vision framework, OCRService
* Testing: Comprehensive unit tests with mock documents
* Integration: Part of FinancialDocumentProcessor modularization
*/

import Foundation
import PDFKit
import Vision

// MARK: - Document Text Extraction Service

@MainActor
public class DocumentTextExtractionService {
    
    // MARK: - Properties
    
    private let ocrService: OCRService
    
    // MARK: - Initialization
    
    public init(ocrService: OCRService = OCRService()) {
        self.ocrService = ocrService
    }
    
    // MARK: - Public Methods
    
    /// Extracts text from a document URL based on file type
    /// - Parameter url: The document URL to process
    /// - Returns: Extracted text content
    /// - Throws: DocumentExtractionError for unsupported formats or processing failures
    public func extractText(from url: URL) async throws -> String {
        let pathExtension = url.pathExtension.lowercased()
        
        switch pathExtension {
        case "pdf":
            return try extractTextFromPDF(url: url)
        case "jpg", "jpeg", "png", "tiff", "heic":
            return try await extractTextFromImage(url: url)
        case "txt", "rtf":
            return try extractTextFromTextFile(url: url)
        default:
            throw DocumentExtractionError.unsupportedFormat(pathExtension)
        }
    }
    
    /// Extracts text from multiple document URLs concurrently
    /// - Parameter urls: Array of document URLs to process
    /// - Returns: Array of extraction results with corresponding URLs
    public func extractTextFromMultipleDocuments(urls: [URL]) async -> [DocumentExtractionResult] {
        await withTaskGroup(of: DocumentExtractionResult.self) { group in
            var results: [DocumentExtractionResult] = []
            
            for url in urls {
                group.addTask {
                    do {
                        let text = try await self.extractText(from: url)
                        return DocumentExtractionResult(url: url, text: text, error: nil)
                    } catch {
                        return DocumentExtractionResult(url: url, text: "", error: error)
                    }
                }
            }
            
            for await result in group {
                results.append(result)
            }
            
            return results.sorted { $0.url.lastPathComponent < $1.url.lastPathComponent }
        }
    }
    
    /// Validates if a file format is supported for text extraction
    /// - Parameter url: The URL to check
    /// - Returns: True if the format is supported
    public func isFormatSupported(url: URL) -> Bool {
        let supportedExtensions = ["pdf", "jpg", "jpeg", "png", "tiff", "heic", "txt", "rtf"]
        return supportedExtensions.contains(url.pathExtension.lowercased())
    }
    
    /// Gets the extraction confidence based on file type and size
    /// - Parameter url: The URL to analyze
    /// - Returns: Confidence score between 0.0 and 1.0
    public func getExtractionConfidence(for url: URL) -> Double {
        let pathExtension = url.pathExtension.lowercased()
        
        switch pathExtension {
        case "pdf":
            return 0.95 // High confidence for PDFs with direct text
        case "txt", "rtf":
            return 0.98 // Very high confidence for text files
        case "png", "jpg", "jpeg":
            return 0.80 // Good confidence for common image formats
        case "tiff", "heic":
            return 0.75 // Good confidence for other image formats
        default:
            return 0.0 // No confidence for unsupported formats
        }
    }
    
    // MARK: - Private Extraction Methods
    
    private func extractTextFromPDF(url: URL) throws -> String {
        guard let pdfDocument = PDFDocument(url: url) else {
            throw DocumentExtractionError.pdfLoadFailed
        }
        
        guard pdfDocument.pageCount > 0 else {
            throw DocumentExtractionError.emptyDocument
        }
        
        var extractedText = ""
        
        for pageIndex in 0..<pdfDocument.pageCount {
            guard let page = pdfDocument.page(at: pageIndex) else {
                continue
            }
            
            let pageText = page.string ?? ""
            extractedText += pageText
            
            // Add page separator for multi-page documents
            if pageIndex < pdfDocument.pageCount - 1 {
                extractedText += "\n---PAGE-BREAK---\n"
            }
        }
        
        // Validate that we extracted meaningful content
        let cleanedText = extractedText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        guard !cleanedText.isEmpty else {
            throw DocumentExtractionError.noTextExtracted
        }
        
        return cleanedText
    }
    
    private func extractTextFromImage(url: URL) async throws -> String {
        // Validate image file exists and is readable
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw DocumentExtractionError.fileNotFound
        }
        
        do {
            let text = try await ocrService.extractText(from: url)
            
            // Validate OCR results
            let cleanedText = text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            guard !cleanedText.isEmpty else {
                throw DocumentExtractionError.ocrNoTextFound
            }
            
            return cleanedText
            
        } catch {
            throw DocumentExtractionError.ocrFailed(error)
        }
    }
    
    private func extractTextFromTextFile(url: URL) throws -> String {
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw DocumentExtractionError.fileNotFound
        }
        
        do {
            let text = try String(contentsOf: url, encoding: .utf8)
            
            // Validate file has content
            let cleanedText = text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            guard !cleanedText.isEmpty else {
                throw DocumentExtractionError.emptyDocument
            }
            
            return cleanedText
            
        } catch {
            throw DocumentExtractionError.textFileReadFailed(error)
        }
    }
}

// MARK: - Supporting Types

public struct DocumentExtractionResult {
    public let url: URL
    public let text: String
    public let error: Error?
    
    public var isSuccess: Bool {
        return error == nil && !text.isEmpty
    }
    
    public init(url: URL, text: String, error: Error?) {
        self.url = url
        self.text = text
        self.error = error
    }
}

public enum DocumentExtractionError: Error, LocalizedError {
    case unsupportedFormat(String)
    case pdfLoadFailed
    case emptyDocument
    case noTextExtracted
    case fileNotFound
    case ocrFailed(Error)
    case ocrNoTextFound
    case textFileReadFailed(Error)
    
    public var errorDescription: String? {
        switch self {
        case .unsupportedFormat(let format):
            return "Unsupported document format: \(format)"
        case .pdfLoadFailed:
            return "Failed to load PDF document"
        case .emptyDocument:
            return "Document contains no content"
        case .noTextExtracted:
            return "No text could be extracted from document"
        case .fileNotFound:
            return "Document file not found"
        case .ocrFailed(let error):
            return "OCR processing failed: \(error.localizedDescription)"
        case .ocrNoTextFound:
            return "OCR completed but no text was found"
        case .textFileReadFailed(let error):
            return "Failed to read text file: \(error.localizedDescription)"
        }
    }
    
    public var failureReason: String? {
        switch self {
        case .unsupportedFormat:
            return "The document format is not supported for text extraction"
        case .pdfLoadFailed:
            return "The PDF file may be corrupted or password protected"
        case .emptyDocument:
            return "The document appears to be empty"
        case .noTextExtracted:
            return "The document may be image-based or corrupted"
        case .fileNotFound:
            return "The file path is invalid or the file has been moved"
        case .ocrFailed:
            return "The OCR service encountered an error during processing"
        case .ocrNoTextFound:
            return "The image may not contain readable text"
        case .textFileReadFailed:
            return "The text file may be corrupted or use an unsupported encoding"
        }
    }
}