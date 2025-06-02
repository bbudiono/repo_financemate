//
//  DocumentManager.swift
//  FinanceMate-Sandbox
//
//  Created by Assistant on 6/2/25.
//

// SANDBOX FILE: For testing/development. See .cursorrules.

/*
* Purpose: Document workflow orchestration service coordinating all document processing services in Sandbox
* Issues & Complexity Summary: Initial TDD implementation - will fail tests to drive development
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~400
  - Core Algorithm Complexity: High
  - Dependencies: 6 New (service coordination, workflow state, queue management, concurrency)
  - State Management Complexity: Very High
  - Novelty/Uncertainty Factor: High
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 90%
* Problem Estimate (Inherent Problem Difficulty %): 88%
* Initial Code Complexity Estimate %: 89%
* Justification for Estimates: Complex service orchestration with state management, queuing, and error handling
* Final Code Complexity (Actual %): TBD - Initial implementation
* Overall Result Score (Success & Quality %): TBD - TDD iteration
* Key Variances/Learnings: TDD approach ensures robust workflow orchestration and service integration
* Last Updated: 2025-06-02
*/

import Foundation
import SwiftUI
import Combine

// MARK: - Document Manager Service

@MainActor
public class DocumentManager: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published public var isProcessing: Bool = false
    @Published public var processedDocuments: [WorkflowDocument] = []
    @Published public var processingQueue: [QueuedDocument] = []
    @Published public var workflowConfiguration: WorkflowConfiguration = WorkflowConfiguration()
    
    // MARK: - Private Properties
    
    private let documentProcessingService: DocumentProcessingService
    private let ocrService: OCRService
    private let financialDataExtractor: FinancialDataExtractor
    
    private let workflowQueue = DispatchQueue(label: "com.financemate.workflow", qos: .userInitiated)
    private var activeJobs: Set<UUID> = []
    private let maxConcurrentJobs: Int = 3
    
    // MARK: - Initialization
    
    public init() {
        self.documentProcessingService = DocumentProcessingService()
        self.ocrService = OCRService()
        self.financialDataExtractor = FinancialDataExtractor()
    }
    
    // MARK: - Public Document Processing Methods
    
    public func processDocument(url: URL) async -> Result<WorkflowDocument, Error> {
        isProcessing = true
        
        defer {
            Task { @MainActor in
                isProcessing = false
            }
        }
        
        let workflowId = UUID()
        let startTime = Date()
        
        do {
            // Create workflow document
            var workflowDocument = WorkflowDocument(
                id: workflowId,
                originalURL: url,
                workflowStatus: .processing,
                startTime: startTime,
                documentType: DocumentType.from(url: url),
                ocrResult: nil,
                financialData: nil,
                confidence: 0.0,
                processingSteps: []
            )
            
            // Step 1: Document Processing Service
            workflowDocument.addProcessingStep(step: "Document Analysis", status: .inProgress)
            let documentResult = await documentProcessingService.processDocument(url: url)
            
            switch documentResult {
            case .success(let processedDoc):
                workflowDocument.addProcessingStep(step: "Document Analysis", status: .completed)
                workflowDocument.documentType = processedDoc.documentType
                
                // Step 2: OCR Processing (for image formats)
                if isImageFormat(url: url) && workflowConfiguration.ocrEnabled {
                    workflowDocument.addProcessingStep(step: "OCR Text Extraction", status: .inProgress)
                    let ocrResult = await ocrService.extractTextResult(from: url)
                    
                    switch ocrResult {
                    case .success(let extractedText):
                        workflowDocument.ocrResult = extractedText
                        workflowDocument.addProcessingStep(step: "OCR Text Extraction", status: .completed)
                    case .failure:
                        workflowDocument.addProcessingStep(step: "OCR Text Extraction", status: .failed)
                    }
                }
                
                // Step 3: Financial Data Extraction
                if workflowConfiguration.financialExtractionEnabled {
                    workflowDocument.addProcessingStep(step: "Financial Data Extraction", status: .inProgress)
                    let textToAnalyze = workflowDocument.ocrResult ?? processedDoc.extractedText
                    let financialDocumentType = mapToFinancialDocumentType(processedDoc.documentType)
                    let financialResult = await financialDataExtractor.extractFinancialData(from: textToAnalyze, documentType: financialDocumentType)
                    
                    switch financialResult {
                    case .success(let financialData):
                        workflowDocument.financialData = financialData
                        workflowDocument.confidence = financialData.confidence
                        workflowDocument.addProcessingStep(step: "Financial Data Extraction", status: .completed)
                    case .failure:
                        workflowDocument.addProcessingStep(step: "Financial Data Extraction", status: .failed)
                    }
                }
                
                // Complete workflow
                workflowDocument.workflowStatus = .completed
                workflowDocument.endTime = Date()
                
                // Add to processed documents
                processedDocuments.append(workflowDocument)
                
                return .success(workflowDocument)
                
            case .failure(let error):
                workflowDocument.workflowStatus = .failed
                workflowDocument.endTime = Date()
                workflowDocument.addProcessingStep(step: "Document Analysis", status: .failed)
                return .failure(DocumentWorkflowError.documentProcessingFailed(error))
            }
            
        } catch {
            return .failure(DocumentWorkflowError.workflowFailed(error))
        }
    }
    
    public func processBatchDocuments(urls: [URL]) async -> [Result<WorkflowDocument, Error>] {
        var results: [Result<WorkflowDocument, Error>] = []
        
        // Process in batches respecting concurrency limits
        let batches = urls.chunked(into: maxConcurrentJobs)
        
        for batch in batches {
            let batchResults = await withTaskGroup(of: Result<WorkflowDocument, Error>.self) { group in
                var batchResults: [Result<WorkflowDocument, Error>] = []
                
                for url in batch {
                    group.addTask {
                        await self.processDocument(url: url)
                    }
                }
                
                for await result in group {
                    batchResults.append(result)
                }
                
                return batchResults
            }
            
            results.append(contentsOf: batchResults)
        }
        
        return results
    }
    
    // MARK: - Queue Management Methods
    
    public func addToProcessingQueue(url: URL, priority: ProcessingPriority = .normal) {
        let queuedDocument = QueuedDocument(
            id: UUID(),
            url: url,
            priority: priority,
            queuedAt: Date()
        )
        
        processingQueue.append(queuedDocument)
        processingQueue.sort { $0.priority.rawValue > $1.priority.rawValue }
    }
    
    public func processQueue() async {
        while !processingQueue.isEmpty {
            let document = processingQueue.removeFirst()
            _ = await processDocument(url: document.url)
        }
    }
    
    public func getQueueOrder() -> [QueuedDocument] {
        return processingQueue.sorted { $0.priority.rawValue > $1.priority.rawValue }
    }
    
    // MARK: - Document Retrieval Methods
    
    public func getProcessedDocuments() -> [WorkflowDocument] {
        return processedDocuments
    }
    
    public func getDocumentsByType(_ type: DocumentType) -> [WorkflowDocument] {
        return processedDocuments.filter { $0.documentType == type }
    }
    
    public func searchDocuments(query: String) -> [WorkflowDocument] {
        let lowercaseQuery = query.lowercased()
        return processedDocuments.filter { document in
            document.originalURL.lastPathComponent.lowercased().contains(lowercaseQuery) ||
            (document.ocrResult?.lowercased().contains(lowercaseQuery) ?? false) ||
            (document.financialData?.vendor?.lowercased().contains(lowercaseQuery) ?? false)
        }
    }
    
    // MARK: - Configuration Methods
    
    public func configureWorkflow(enableOCR: Bool, enableFinancialExtraction: Bool, maxConcurrentJobs: Int) {
        workflowConfiguration.ocrEnabled = enableOCR
        workflowConfiguration.financialExtractionEnabled = enableFinancialExtraction
        workflowConfiguration.maxConcurrentJobs = maxConcurrentJobs
    }
    
    // MARK: - Private Helper Methods
    
    private func isImageFormat(url: URL) -> Bool {
        let imageExtensions = ["jpg", "jpeg", "png", "tiff", "tif", "heic", "heif", "bmp"]
        return imageExtensions.contains(url.pathExtension.lowercased())
    }
    
    private func calculateOverallConfidence(steps: [ProcessingStep]) -> Double {
        let completedSteps = steps.filter { $0.status == .completed }
        return Double(completedSteps.count) / Double(steps.count)
    }
    
    private func mapToFinancialDocumentType(_ documentType: DocumentType) -> FinancialDocumentType {
        switch documentType {
        case .invoice:
            return .invoice
        case .receipt:
            return .receipt
        case .statement:
            return .statement
        case .contract:
            return .contract
        default:
            return .other
        }
    }
}

// MARK: - Supporting Data Models

public struct WorkflowDocument {
    public let id: UUID
    public let originalURL: URL
    public var workflowStatus: WorkflowStatus
    public let startTime: Date
    public var endTime: Date?
    public var documentType: DocumentType
    public var ocrResult: String?
    public var financialData: FinancialData?
    public var confidence: Double
    public var processingSteps: [ProcessingStep]
    
    public init(id: UUID, originalURL: URL, workflowStatus: WorkflowStatus, startTime: Date, documentType: DocumentType, ocrResult: String?, financialData: FinancialData?, confidence: Double, processingSteps: [ProcessingStep]) {
        self.id = id
        self.originalURL = originalURL
        self.workflowStatus = workflowStatus
        self.startTime = startTime
        self.documentType = documentType
        self.ocrResult = ocrResult
        self.financialData = financialData
        self.confidence = confidence
        self.processingSteps = processingSteps
    }
    
    public mutating func addProcessingStep(step: String, status: ProcessingStepStatus) {
        if let existingStepIndex = processingSteps.firstIndex(where: { $0.stepName == step }) {
            processingSteps[existingStepIndex].status = status
            processingSteps[existingStepIndex].completedAt = status == .completed ? Date() : nil
        } else {
            let newStep = ProcessingStep(
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

public struct QueuedDocument {
    public let id: UUID
    public let url: URL
    public let priority: ProcessingPriority
    public let queuedAt: Date
    
    public init(id: UUID, url: URL, priority: ProcessingPriority, queuedAt: Date) {
        self.id = id
        self.url = url
        self.priority = priority
        self.queuedAt = queuedAt
    }
}

public struct ProcessingStep {
    public let stepName: String
    public var status: ProcessingStepStatus
    public let startedAt: Date
    public var completedAt: Date?
    
    public init(stepName: String, status: ProcessingStepStatus, startedAt: Date, completedAt: Date?) {
        self.stepName = stepName
        self.status = status
        self.startedAt = startedAt
        self.completedAt = completedAt
    }
}

public struct WorkflowConfiguration {
    public var ocrEnabled: Bool = true
    public var financialExtractionEnabled: Bool = true
    public var maxConcurrentJobs: Int = 3
    
    public init() {}
}

public enum WorkflowStatus {
    case queued
    case processing
    case completed
    case failed
    case cancelled
    
    public var icon: String {
        switch self {
        case .queued: return "clock.badge"
        case .processing: return "arrow.triangle.2.circlepath"
        case .completed: return "checkmark.circle.fill"
        case .failed: return "exclamationmark.triangle.fill"
        case .cancelled: return "xmark.circle.fill"
        }
    }
    
    public var color: Color {
        switch self {
        case .queued: return .orange
        case .processing: return .blue
        case .completed: return .green
        case .failed: return .red
        case .cancelled: return .gray
        }
    }
}

public enum ProcessingStepStatus {
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

public enum ProcessingPriority: Int, CaseIterable {
    case low = 1
    case normal = 2
    case high = 3
    case urgent = 4
    
    public var displayName: String {
        switch self {
        case .low: return "Low"
        case .normal: return "Normal"
        case .high: return "High"
        case .urgent: return "Urgent"
        }
    }
}

public enum DocumentWorkflowError: Error, LocalizedError {
    case documentProcessingFailed(Error)
    case ocrProcessingFailed(Error)
    case financialExtractionFailed(Error)
    case workflowFailed(Error)
    case queueManagementFailed
    case configurationError
    
    public var errorDescription: String? {
        switch self {
        case .documentProcessingFailed(let error):
            return "Document processing failed: \(error.localizedDescription)"
        case .ocrProcessingFailed(let error):
            return "OCR processing failed: \(error.localizedDescription)"
        case .financialExtractionFailed(let error):
            return "Financial extraction failed: \(error.localizedDescription)"
        case .workflowFailed(let error):
            return "Workflow failed: \(error.localizedDescription)"
        case .queueManagementFailed:
            return "Queue management failed"
        case .configurationError:
            return "Configuration error"
        }
    }
}

// MARK: - Array Extension for Chunking

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}