//
//  DocumentOCRProcessingService.swift
//  FinanceMate
//
//  Extracted from DocumentsView.swift for SwiftLint compliance
//  Created by Assistant on 6/27/25.
//

/*
* Purpose: OCR processing service for documents using Apple Vision framework
* Issues & Complexity Summary: Complex OCR logic with PDF and image processing
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~120
  - Core Algorithm Complexity: High (OCR, PDF parsing, image processing)
  - Dependencies: 4 (Vision, PDFKit, Quartz, CoreGraphics)
  - State Management Complexity: Low
  - Novelty/Uncertainty Factor: Medium
* AI Pre-Task Self-Assessment: 85%
* Problem Estimate: 90%
* Initial Code Complexity Estimate: 88%
* Final Code Complexity: 92%
* Overall Result Score: 90%
* Key Variances/Learnings: OCR accuracy varies by document quality, error handling crucial
* Last Updated: 2025-06-27
*/

import Foundation
import Vision
import VisionKit
import PDFKit
import Quartz
import AppKit

// MARK: - OCR Error Types

enum OCRError: LocalizedError {
    case unsupportedFileType
    case pdfLoadFailed
    case imageLoadFailed
    case imageProcessingFailed
    case visionFrameworkError(String)
    
    var errorDescription: String? {
        switch self {
        case .unsupportedFileType:
            return "Unsupported file type for OCR processing"
        case .pdfLoadFailed:
            return "Failed to load PDF document"
        case .imageLoadFailed:
            return "Failed to load image file"
        case .imageProcessingFailed:
            return "Failed to process image for OCR"
        case .visionFrameworkError(let message):
            return "Vision framework error: \(message)"
        }
    }
}

// MARK: - Document OCR Processing Service

class DocumentOCRProcessingService: ObservableObject {
    
    // MARK: - Public Methods
    
    /// Performs OCR processing on a document URL
    /// - Parameter url: The file URL to process
    /// - Returns: Extracted text content
    /// - Throws: OCRError if processing fails
    func performBackgroundOCR(on url: URL) async throws -> String {
        let fileExtension = url.pathExtension.lowercased()
        
        switch fileExtension {
        case "pdf":
            return try await extractTextFromPDF(url: url)
        case "jpg", "jpeg", "png", "tiff", "heic":
            return try await extractTextFromImage(url: url)
        case "txt":
            return try String(contentsOf: url, encoding: .utf8)
        default:
            throw OCRError.unsupportedFileType
        }
    }
    
    // MARK: - Private PDF Processing
    
    private func extractTextFromPDF(url: URL) async throws -> String {
        guard let pdfDocument = PDFDocument(url: url) else {
            throw OCRError.pdfLoadFailed
        }
        
        var fullText = ""
        
        // First try to extract native text
        for pageIndex in 0..<pdfDocument.pageCount {
            guard let page = pdfDocument.page(at: pageIndex) else { continue }
            if let pageText = page.string {
                fullText += pageText + "\n"
            }
        }
        
        // If no native text found, use OCR on PDF pages
        if fullText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            fullText = try await performOCROnPDFPages(pdfDocument: pdfDocument)
        }
        
        return fullText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func performOCROnPDFPages(pdfDocument: PDFDocument) async throws -> String {
        var fullText = ""
        
        // Limit to first 10 pages for performance
        let maxPages = min(pdfDocument.pageCount, 10)
        
        for pageIndex in 0..<maxPages {
            guard let page = pdfDocument.page(at: pageIndex) else { continue }
            
            let pageRect = page.bounds(for: .mediaBox)
            
            // Create image from PDF page using macOS APIs
            let nsImage = NSImage(size: pageRect.size)
            nsImage.lockFocus()
            
            let context = NSGraphicsContext.current!.cgContext
            context.translateBy(x: 0, y: pageRect.size.height)
            context.scaleBy(x: 1.0, y: -1.0)
            page.draw(with: .mediaBox, to: context)
            
            nsImage.unlockFocus()
            
            guard let cgImage = nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
                continue
            }
            
            let ocrText = try await performVisionOCR(on: cgImage)
            fullText += ocrText + "\n"
        }
        
        return fullText
    }
    
    // MARK: - Private Image Processing
    
    private func extractTextFromImage(url: URL) async throws -> String {
        guard let nsImage = NSImage(contentsOf: url) else {
            throw OCRError.imageLoadFailed
        }
        
        guard let cgImage = nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            throw OCRError.imageProcessingFailed
        }
        
        return try await performVisionOCR(on: cgImage)
    }
    
    // MARK: - Vision Framework OCR
    
    private func performVisionOCR(on cgImage: CGImage) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: OCRError.visionFrameworkError(error.localizedDescription))
                    return
                }
                
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(returning: "")
                    return
                }
                
                let recognizedText = observations.compactMap { observation in
                    observation.topCandidates(1).first?.string
                }.joined(separator: "\n")
                
                continuation.resume(returning: recognizedText)
            }
            
            // Configure for maximum accuracy
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            
            do {
                try requestHandler.perform([request])
            } catch {
                continuation.resume(throwing: OCRError.visionFrameworkError(error.localizedDescription))
            }
        }
    }
}