//
//  DocumentFileHandlingService.swift
//  FinanceMate
//
//  Extracted from DocumentsView.swift for SwiftLint compliance
//  Created by Assistant on 6/28/25.
//

/*
* Purpose: Document file processing, OCR, and Core Data persistence service
* Issues & Complexity Summary: Complex file handling with OCR processing and database operations
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~250
  - Core Algorithm Complexity: High (OCR, file processing)
  - Dependencies: 5 (Vision, PDFKit, Core Data, FileManager, VisionKit)
  - State Management Complexity: High
  - Novelty/Uncertainty Factor: Medium
* AI Pre-Task Self-Assessment: 70%
* Problem Estimate: 80%
* Initial Code Complexity Estimate: 85%
* Final Code Complexity: 88%
* Overall Result Score: 85%
* Key Variances/Learnings: OCR integration more complex than expected
* Last Updated: 2025-06-28
*/

import Foundation
import CoreData
import PDFKit
import Vision
import VisionKit
import UniformTypeIdentifiers

// MARK: - Document File Handling Service

@MainActor
class DocumentFileHandlingService: ObservableObject {
    
    private let viewContext: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
    }
    
    // MARK: - File Processing
    
    func processDocumentWithErrorHandling(url: URL) async throws {
        // Create Core Data Document entity
        let document = Document(context: viewContext)
        document.id = UUID()
        document.fileName = url.lastPathComponent
        document.filePath = url.path
        document.dateCreated = Date()
        document.rawOCRText = "Processing..."
        document.processingStatus = "processing"
        document.mimeType = getMimeType(for: url)

        // Get file size
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            document.fileSize = attributes[.size] as? Int64 ?? 0
        } catch {
            document.fileSize = 0
        }

        // Save to Core Data immediately with processing status
        do {
            try viewContext.save()
        } catch {
            throw DocumentError.saveError(error.localizedDescription)
        }

        // Real OCR processing using Apple Vision framework
        do {
            let extractedText = try await performBackgroundOCR(on: url)

            await MainActor.run {
                document.rawOCRText = extractedText.isEmpty ? "No text detected" : extractedText
                document.processingStatus = "completed"

                do {
                    try viewContext.save()
                } catch {
                    document.rawOCRText = "Save failed: \(error.localizedDescription)"
                    document.processingStatus = "error"
                }
            }
        } catch {
            await MainActor.run {
                document.rawOCRText = "OCR failed: \(error.localizedDescription)"
                document.processingStatus = "error"

                do {
                    try viewContext.save()
                } catch {
                    // Document will remain in error state
                }
            }
            throw DocumentError.ocrError(error.localizedDescription)
        }
    }
    
    // MARK: - Bulk File Processing
    
    func processBulkFiles(_ urls: [URL]) async -> (successCount: Int, errorCount: Int) {
        var successCount = 0
        var errorCount = 0
        
        for url in urls {
            do {
                try await processDocumentWithErrorHandling(url: url)
                successCount += 1
            } catch {
                errorCount += 1
            }
        }
        
        return (successCount, errorCount)
    }
    
    // MARK: - MIME Type Detection
    
    private func getMimeType(for url: URL) -> String {
        let pathExtension = url.pathExtension.lowercased()
        switch pathExtension {
        case "pdf": return "application/pdf"
        case "jpg", "jpeg": return "image/jpeg"
        case "png": return "image/png"
        case "txt": return "text/plain"
        case "tiff": return "image/tiff"
        case "heic": return "image/heic"
        default: return "application/octet-stream"
        }
    }
    
    // MARK: - OCR Processing
    
    private func performBackgroundOCR(on url: URL) async throws -> String {
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
            for pageIndex in 0..<min(pdfDocument.pageCount, 10) { // Limit to first 10 pages
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
                let pageImage = NSImage(cgImage: cgImage, size: pageRect.size)

                let ocrText = try await performVisionOCR(on: cgImage)
                fullText += ocrText + "\n"
            }
        }

        return fullText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func extractTextFromImage(url: URL) async throws -> String {
        guard let nsImage = NSImage(contentsOf: url) else {
            throw OCRError.imageLoadFailed
        }

        guard let cgImage = nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            throw OCRError.imageProcessingFailed
        }

        return try await performVisionOCR(on: cgImage)
    }

    private func performVisionOCR(on cgImage: CGImage) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
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
                continuation.resume(throwing: error)
            }
        }
    }
    
    // MARK: - Document Management
    
    func deleteDocument(_ document: Document) {
        viewContext.delete(document)

        do {
            try viewContext.save()
            print("✅ Document deleted from Core Data: \(document.fileName ?? "Unknown")")
        } catch {
            print("❌ Failed to delete document: \(error)")
        }
    }
}