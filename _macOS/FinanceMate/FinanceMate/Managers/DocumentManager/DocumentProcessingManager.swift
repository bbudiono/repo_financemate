// DocumentProcessingManager.swift
// Purpose: Centralized document processing operations extracted from DocumentsView
// Part of unified Manager architecture for FinanceMate

import Foundation
import PDFKit
import SwiftUI
import Vision

@MainActor
class DocumentProcessingManager: ObservableObject {
    @Published var isProcessing = false
    @Published var processingProgress: Double = 0.0
    @Published var lastProcessedDocument: ProcessedDocument?
    @Published var processingError: ProcessingError?

    private let ocrService = OCRService()
    private let validationService = DocumentValidationManager()
    private let metadataService = DocumentMetadataManager()

    // MARK: - Core Processing Operations

    func processDocument(from url: URL) async throws -> ProcessedDocument {
        isProcessing = true
        processingProgress = 0.0
        defer { isProcessing = false }

        do {
            // Step 1: Validate document
            processingProgress = 0.1
            try await validationService.validateDocument(at: url)

            // Step 2: Extract metadata
            processingProgress = 0.3
            let metadata = try await metadataService.extractMetadata(from: url)

            // Step 3: Perform OCR
            processingProgress = 0.5
            let ocrResults = try await ocrService.extractText(from: url)

            // Step 4: Process financial data
            processingProgress = 0.8
            let financialData = try await extractFinancialData(from: ocrResults)

            // Step 5: Create processed document
            processingProgress = 1.0
            let processedDocument = ProcessedDocument(
                id: UUID(),
                originalURL: url,
                metadata: metadata,
                ocrResults: ocrResults,
                financialData: financialData,
                processedAt: Date()
            )

            lastProcessedDocument = processedDocument
            return processedDocument
        } catch {
            processingError = ProcessingError.processingFailed(error)
            throw error
        }
    }

    func batchProcessDocuments(urls: [URL]) async throws -> [ProcessedDocument] {
        isProcessing = true
        processingProgress = 0.0
        defer { isProcessing = false }

        var processedDocuments: [ProcessedDocument] = []
        let totalUrls = urls.count

        for (index, url) in urls.enumerated() {
            do {
                let processed = try await processDocument(from: url)
                processedDocuments.append(processed)
                processingProgress = Double(index + 1) / Double(totalUrls)
            } catch {
                print("Failed to process document at \(url): \(error)")
                continue
            }
        }

        return processedDocuments
    }

    // MARK: - Private Processing Methods

    private func extractFinancialData(from ocrResults: OCRResults) async throws -> FinancialData {
        // Extract financial information from OCR text
        let extractedData = FinancialData()

        // Parse amounts, dates, vendor information, etc.
        let amountPattern = #"\$?[\d,]+\.?\d{0,2}"#
        let datePattern = #"\d{1,2}[\/\-]\d{1,2}[\/\-]\d{2,4}"#

        // Implementation would use regex and AI models for extraction
        // For now, return basic structure

        return extractedData
    }
}

// MARK: - Supporting Data Models

struct ProcessedDocument: Identifiable, Codable {
    let id: UUID
    let originalURL: URL
    let metadata: DocumentMetadata
    let ocrResults: OCRResults
    let financialData: FinancialData
    let processedAt: Date
}

struct DocumentMetadata: Codable {
    let fileName: String
    let fileSize: Int64
    let fileType: String
    let creationDate: Date?
    let modificationDate: Date?
    let pageCount: Int?
}

struct OCRResults: Codable {
    let rawText: String
    let confidence: Double
    let textBlocks: [TextBlock]
    let processingDuration: TimeInterval
}

struct TextBlock: Codable {
    let text: String
    let confidence: Double
    let boundingBox: CGRect
}

struct FinancialData: Codable {
    var amounts: [Amount] = []
    var dates: [Date] = []
    var vendorInfo: VendorInfo?
    var lineItems: [LineItem] = []
    var totalAmount: Decimal?
    var currency: String = "USD"
}

struct Amount: Codable {
    let value: Decimal
    let currency: String
    let type: AmountType
    let confidence: Double
}

enum AmountType: String, Codable {
    case total
    case subtotal
    case tax
    case tip
    case discount
    case lineItem
}

struct VendorInfo: Codable {
    let name: String?
    let address: String?
    let phone: String?
    let email: String?
    let website: String?
}

struct LineItem: Codable {
    let description: String
    let quantity: Decimal?
    let unitPrice: Decimal?
    let totalPrice: Decimal
    let category: String?
}

enum ProcessingError: LocalizedError {
    case invalidFileType
    case fileNotFound
    case ocrFailed(Error)
    case processingFailed(Error)
    case validationFailed(String)

    var errorDescription: String? {
        switch self {
        case .invalidFileType:
            return "Unsupported file type. Please use PDF, JPEG, PNG, or HEIC files."
        case .fileNotFound:
            return "The selected file could not be found."
        case .ocrFailed(let error):
            return "OCR processing failed: \(error.localizedDescription)"
        case .processingFailed(let error):
            return "Document processing failed: \(error.localizedDescription)"
        case .validationFailed(let message):
            return "Document validation failed: \(message)"
        }
    }
}
