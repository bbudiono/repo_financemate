/*
* Purpose: REAL Document Processing Pipeline with PDFKit + Vision OCR integration - NO MOCK DATA
* Issues & Complexity Summary: Complex document processing pipeline with OCR, file handling, and async processing
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~350
  - Core Algorithm Complexity: High
  - Dependencies: 5 New (Foundation, SwiftUI, Combine, file handling, OCR integration)
  - State Management Complexity: High
  - Novelty/Uncertainty Factor: Medium
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 82%
* Problem Estimate (Inherent Problem Difficulty %): 80%
* Initial Code Complexity Estimate %: 81%
* Justification for Estimates: Complex document processing with multiple service integrations and async workflows
* Final Code Complexity (Actual %): TBD
* Overall Result Score (Success & Quality %): TBD
* Key Variances/Learnings: TDD approach ensures robust error handling and comprehensive functionality
* Last Updated: 2025-06-03
*/

import Combine
import Foundation
import PDFKit
import SwiftUI
import Vision

// MARK: - Document Processing Pipeline

@MainActor
public class DocumentProcessingPipeline: ObservableObject {
    // MARK: - Published Properties

    @Published public var isProcessing: Bool = false
    @Published public var processingProgress: Double = 0.0
    @Published public var currentOperation: String = ""

    // MARK: - Configuration Properties

    public var supportedFileTypes: Set<String> = ["pdf", "jpg", "jpeg", "png", "txt"]
    public var isOCREnabled: Bool = true
    public var isFinancialExtractionEnabled: Bool = true
    public var maxFileSize: Int = 50 * 1024 * 1024 // 50MB
    public var processingTimeout: TimeInterval = 60.0

    // MARK: - Private Properties

    private let ocrService: OCRService
    private let financialDataExtractor: FinancialDataExtractor
    private let processingQueue = DispatchQueue(label: "com.financemate.processing", qos: .userInitiated)
    private var configuration: DocumentProcessingConfiguration

    // MARK: - Initialization

    public init() {
        self.ocrService = OCRService()
        self.financialDataExtractor = FinancialDataExtractor()
        self.configuration = DocumentProcessingConfiguration()
        setupDefaultConfiguration()
    }

    private func setupDefaultConfiguration() {
        self.configuration = DocumentProcessingConfiguration(
            enableOCR: true,
            enableFinancialDataExtraction: true,
            maxFileSize: 50 * 1024 * 1024,
            processingTimeout: 60.0,
            outputFormat: .structured
        )
        applyConfiguration()
    }

    // MARK: - Configuration Methods

    public func configure(with config: DocumentProcessingConfiguration) {
        self.configuration = config
        applyConfiguration()
    }

    private func applyConfiguration() {
        self.isOCREnabled = configuration.enableOCR
        self.isFinancialExtractionEnabled = configuration.enableFinancialDataExtraction
        self.maxFileSize = configuration.maxFileSize
        self.processingTimeout = configuration.processingTimeout
    }

    // MARK: - File Validation

    public func validateFile(at url: URL) -> Bool {
        // Check if file exists
        guard FileManager.default.fileExists(atPath: url.path) else {
            return false
        }

        // Check file extension
        let fileExtension = url.pathExtension.lowercased()
        guard supportedFileTypes.contains(fileExtension) else {
            return false
        }

        // Check file size
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            if let fileSize = attributes[.size] as? Int, fileSize > maxFileSize {
                return false
            }
        } catch {
            return false
        }

        return true
    }

    // MARK: - Single Document Processing

    public func processDocument(at url: URL) async -> Result<PipelineProcessedDocument, Error> {
        // Update processing state
        isProcessing = true
        currentOperation = "Validating document"
        processingProgress = 0.1

        defer {
            Task { @MainActor in
                isProcessing = false
                currentOperation = ""
                processingProgress = 0.0
            }
        }

        // Validate file
        guard validateFile(at: url) else {
            return .failure(PipelineProcessingError.unsupportedFileType)
        }

        do {
            // Create processing document
            var processedDocument = PipelineProcessedDocument(
                id: UUID(),
                originalURL: url,
                documentType: DocumentType.from(url: url),
                status: .processing,
                startTime: Date(),
                extractedText: nil,
                ocrResult: nil,
                ocrConfidence: 0.0,
                financialData: nil,
                confidence: 0.0,
                processingSteps: []
            )

            // Step 1: Extract text content
            currentOperation = "Extracting text content"
            processingProgress = 0.3

            let extractedText = try await extractTextContent(from: url)
            processedDocument.extractedText = extractedText
            processedDocument.addProcessingStep(step: "Text Extraction", status: .completed)

            // Step 2: OCR processing (if enabled and applicable)
            if isOCREnabled && isImageFile(url) {
                currentOperation = "Performing OCR analysis"
                processingProgress = 0.5

                let ocrResult = await performOCRAnalysis(on: url)
                processedDocument.ocrResult = ocrResult.text
                processedDocument.ocrConfidence = ocrResult.confidence
                processedDocument.addProcessingStep(step: "OCR Analysis", status: .completed)
            }

            // Step 3: Financial data extraction (if enabled)
            if isFinancialExtractionEnabled {
                currentOperation = "Extracting financial data"
                processingProgress = 0.8

                let financialData = await extractFinancialData(from: processedDocument)
                processedDocument.financialData = financialData
                processedDocument.addProcessingStep(step: "Financial Data Extraction", status: .completed)
            }

            // Step 4: Calculate overall confidence
            processedDocument.confidence = calculateOverallConfidence(for: processedDocument)
            processedDocument.status = .completed
            processedDocument.endTime = Date()

            currentOperation = "Processing complete"
            processingProgress = 1.0

            return .success(processedDocument)
        } catch {
            return .failure(error)
        }
    }

    // MARK: - Batch Processing

    public func processDocuments(at urls: [URL]) async -> [Result<PipelineProcessedDocument, Error>] {
        var results: [Result<PipelineProcessedDocument, Error>] = []

        isProcessing = true
        currentOperation = "Processing batch of \(urls.count) documents"

        defer {
            Task { @MainActor in
                isProcessing = false
                currentOperation = ""
                processingProgress = 0.0
            }
        }

        for (index, url) in urls.enumerated() {
            let progress = Double(index) / Double(urls.count)
            processingProgress = progress

            let result = await processDocument(at: url)
            results.append(result)
        }

        processingProgress = 1.0
        return results
    }

    // MARK: - Private Processing Methods

    private func extractTextContent(from url: URL) async throws -> String {
        let fileExtension = url.pathExtension.lowercased()

        switch fileExtension {
        case "txt":
            return try String(contentsOf: url, encoding: .utf8)

        case "pdf":
            // Real PDF text extraction using PDFKit
            guard let pdfDocument = PDFDocument(url: url) else {
                throw PipelineProcessingError.processingFailed
            }

            var extractedText = ""
            for pageIndex in 0..<pdfDocument.pageCount {
                if let page = pdfDocument.page(at: pageIndex) {
                    extractedText += page.string ?? ""
                    extractedText += "\n"
                }
            }

            return extractedText.trimmingCharacters(in: .whitespacesAndNewlines)

        case "jpg", "jpeg", "png":
            // For image files, we'll rely on OCR for text extraction
            if isOCREnabled {
                return "" // OCR will handle text extraction
            } else {
                throw PipelineProcessingError.ocrRequired
            }

        default:
            throw PipelineProcessingError.unsupportedFileType
        }
    }

    private func performOCRAnalysis(on url: URL) async -> (text: String, confidence: Double) {
        // Real OCR processing using Vision framework
        await withCheckedContinuation { continuation in
            guard let image = NSImage(contentsOf: url) else {
                continuation.resume(returning: (text: "", confidence: 0.0))
                return
            }

            guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
                continuation.resume(returning: (text: "", confidence: 0.0))
                return
            }

            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    print("OCR Error: \(error.localizedDescription)")
                    continuation.resume(returning: (text: "", confidence: 0.0))
                    return
                }

                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(returning: (text: "", confidence: 0.0))
                    return
                }

                var extractedText = ""
                var totalConfidence = 0.0
                var observationCount = 0

                for observation in observations {
                    guard let topCandidate = observation.topCandidates(1).first else { continue }
                    extractedText += topCandidate.string + "\n"
                    totalConfidence += Double(topCandidate.confidence)
                    observationCount += 1
                }

                let averageConfidence = observationCount > 0 ? totalConfidence / Double(observationCount) : 0.0

                continuation.resume(returning: (
                    text: extractedText.trimmingCharacters(in: .whitespacesAndNewlines),
                    confidence: averageConfidence
                ))
            }

            // Configure OCR request for better accuracy
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

            do {
                try handler.perform([request])
            } catch {
                print("Failed to perform OCR: \(error.localizedDescription)")
                continuation.resume(returning: (text: "", confidence: 0.0))
            }
        }
    }

    private func extractFinancialData(from document: PipelineProcessedDocument) async -> ExtractedFinancialData? {
        let textToAnalyze = document.ocrResult ?? document.extractedText ?? ""

        guard !textToAnalyze.isEmpty else { return nil }

        // Convert DocumentType to FinancialDocumentType
        let financialDocumentType: FinancialDocumentType
        switch document.documentType {
        case .invoice:
            financialDocumentType = .invoice
        case .receipt:
            financialDocumentType = .receipt
        case .statement:
            financialDocumentType = .statement
        default:
            financialDocumentType = .other
        }

        let result = await financialDataExtractor.extractFinancialData(
            from: textToAnalyze,
            documentType: financialDocumentType
        )

        switch result {
        case .success(let financialData):
            return financialData
        case .failure:
            return nil
        }
    }

    private func calculateOverallConfidence(for document: PipelineProcessedDocument) -> Double {
        var confidenceScore = 0.5 // Base confidence

        // Text extraction confidence
        if let extractedText = document.extractedText, !extractedText.isEmpty {
            confidenceScore += 0.2
        }

        // OCR confidence
        if document.ocrResult != nil {
            confidenceScore += (document.ocrConfidence * 0.3)
        }

        // Financial data confidence
        if let financialData = document.financialData {
            confidenceScore += (financialData.confidence * 0.2)
        }

        return min(confidenceScore, 1.0)
    }

    private func isImageFile(_ url: URL) -> Bool {
        let imageExtensions = ["jpg", "jpeg", "png", "gif", "bmp", "tiff"]
        return imageExtensions.contains(url.pathExtension.lowercased())
    }
}

// MARK: - Configuration Structure

public struct DocumentProcessingConfiguration {
    public let enableOCR: Bool
    public let enableFinancialDataExtraction: Bool
    public let maxFileSize: Int
    public let processingTimeout: TimeInterval
    public let outputFormat: ProcessingOutputFormat

    public init(
        enableOCR: Bool = true,
        enableFinancialDataExtraction: Bool = true,
        maxFileSize: Int = 50 * 1024 * 1024,
        processingTimeout: TimeInterval = 60.0,
        outputFormat: ProcessingOutputFormat = .structured
    ) {
        self.enableOCR = enableOCR
        self.enableFinancialDataExtraction = enableFinancialDataExtraction
        self.maxFileSize = maxFileSize
        self.processingTimeout = processingTimeout
        self.outputFormat = outputFormat
    }
}

public enum ProcessingOutputFormat {
    case structured
    case raw
    case enhanced
}

// MARK: - Processed Document Model

public struct PipelineProcessedDocument: Identifiable {
    public let id: UUID
    public let originalURL: URL
    public let documentType: DocumentType
    public var status: PipelineProcessingStatus
    public let startTime: Date
    public var endTime: Date?
    public var extractedText: String?
    public var ocrResult: String?
    public var ocrConfidence: Double
    public var financialData: ExtractedFinancialData?
    public var confidence: Double
    public var processingSteps: [DocumentProcessingStep]

    public init(
        id: UUID,
        originalURL: URL,
        documentType: DocumentType,
        status: PipelineProcessingStatus,
        startTime: Date,
        extractedText: String? = nil,
        ocrResult: String? = nil,
        ocrConfidence: Double = 0.0,
        financialData: ExtractedFinancialData? = nil,
        confidence: Double = 0.0,
        processingSteps: [DocumentProcessingStep] = []
    ) {
        self.id = id
        self.originalURL = originalURL
        self.documentType = documentType
        self.status = status
        self.startTime = startTime
        self.extractedText = extractedText
        self.ocrResult = ocrResult
        self.ocrConfidence = ocrConfidence
        self.financialData = financialData
        self.confidence = confidence
        self.processingSteps = processingSteps
    }

    public mutating func addProcessingStep(step: String, status: PipelineStepStatus) {
        if let existingIndex = processingSteps.firstIndex(where: { $0.stepName == step }) {
            processingSteps[existingIndex].status = status
            processingSteps[existingIndex].completedAt = status == .completed ? Date() : nil
        } else {
            let newStep = DocumentProcessingStep(
                stepName: step,
                status: status,
                startedAt: Date(),
                completedAt: status == .completed ? Date() : nil
            )
            processingSteps.append(newStep)
        }
    }

    public var processingDuration: TimeInterval? {
        guard let endTime = endTime else { return nil }
        return endTime.timeIntervalSince(startTime)
    }
}

// MARK: - Processing Step Model

public struct DocumentProcessingStep {
    public let stepName: String
    public var status: PipelineStepStatus
    public let startedAt: Date
    public var completedAt: Date?

    public init(stepName: String, status: PipelineStepStatus, startedAt: Date, completedAt: Date? = nil) {
        self.stepName = stepName
        self.status = status
        self.startedAt = startedAt
        self.completedAt = completedAt
    }
}

// MARK: - Enums

public enum PipelineProcessingStatus {
    case pending
    case processing
    case completed
    case failed
    case timeout

    public var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .processing: return "Processing"
        case .completed: return "Completed"
        case .failed: return "Failed"
        case .timeout: return "Timeout"
        }
    }

    public var color: Color {
        switch self {
        case .pending: return .orange
        case .processing: return .blue
        case .completed: return .green
        case .failed: return .red
        case .timeout: return .red
        }
    }
}

public enum PipelineStepStatus {
    case pending
    case inProgress
    case completed
    case failed
    case skipped

    public var icon: String {
        switch self {
        case .pending: return "circle"
        case .inProgress: return "arrow.triangle.2.circlepath"
        case .completed: return "checkmark.circle.fill"
        case .failed: return "xmark.circle.fill"
        case .skipped: return "minus.circle.fill"
        }
    }
}

// MARK: - Error Types

public enum PipelineProcessingError: Error, LocalizedError {
    case unsupportedFileType
    case fileNotFound
    case fileSizeExceeded
    case ocrRequired
    case timeout
    case processingFailed
    case invalidConfiguration

    public var errorDescription: String? {
        switch self {
        case .unsupportedFileType:
            return "Unsupported file type"
        case .fileNotFound:
            return "File not found"
        case .fileSizeExceeded:
            return "File size exceeds maximum limit"
        case .ocrRequired:
            return "OCR is required for this file type"
        case .timeout:
            return "Processing timeout"
        case .processingFailed:
            return "Document processing failed"
        case .invalidConfiguration:
            return "Invalid configuration"
        }
    }
}
