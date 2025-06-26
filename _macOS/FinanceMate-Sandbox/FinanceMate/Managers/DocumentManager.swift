//
//  DocumentManager.swift
//  FinanceMate
//
//  Created by Assistant on 6/10/25.
//

import Combine
import Foundation
import SwiftUI

@MainActor
public class DocumentManager: ObservableObject {
    static let shared = DocumentManager()

    @Published public var isProcessing: Bool = false
    @Published public var processedDocuments: [ProcessedDocument] = []
    @Published public var processingQueue: [QueuedDocument] = []

    private init() {
        // Initialize with sample data for demonstration
        loadSampleData()
    }

    private func loadSampleData() {
        // Sample processed documents for UI display
        processedDocuments = [
            ProcessedDocument(id: UUID(), name: "Invoice_2024_001.pdf", status: .completed, processedAt: Date()),
            ProcessedDocument(id: UUID(), name: "Receipt_Store_123.jpg", status: .completed, processedAt: Date().addingTimeInterval(-3600)),
            ProcessedDocument(id: UUID(), name: "Statement_Bank.pdf", status: .processing, processedAt: Date().addingTimeInterval(-1800))
        ]
    }

    public func processDocument(at url: URL) async {
        isProcessing = true

        let queuedDoc = QueuedDocument(id: UUID(), name: url.lastPathComponent, url: url)
        processingQueue.append(queuedDoc)

        // Simulate processing delay
        try? await Task.sleep(nanoseconds: 2_000_000_000)

        // Remove from queue and add to processed
        if let index = processingQueue.firstIndex(where: { $0.id == queuedDoc.id }) {
            processingQueue.remove(at: index)
        }

        let processedDoc = ProcessedDocument(
            id: queuedDoc.id,
            name: queuedDoc.name,
            status: .completed,
            processedAt: Date()
        )
        processedDocuments.insert(processedDoc, at: 0)

        isProcessing = false
    }

    public func removeDocument(_ document: ProcessedDocument) {
        processedDocuments.removeAll { $0.id == document.id }
    }

    public func clearAllDocuments() {
        processedDocuments.removeAll()
        processingQueue.removeAll()
    }
}

// MARK: - Supporting Types

public struct ProcessedDocument: Identifiable {
    public let id: UUID
    public let name: String
    public let status: ProcessingStatus
    public let processedAt: Date

    public init(id: UUID, name: String, status: ProcessingStatus, processedAt: Date) {
        self.id = id
        self.name = name
        self.status = status
        self.processedAt = processedAt
    }
}

public struct QueuedDocument: Identifiable {
    public let id: UUID
    public let name: String
    public let url: URL

    public init(id: UUID, name: String, url: URL) {
        self.id = id
        self.name = name
        self.url = url
    }
}

public enum ProcessingStatus {
    case queued
    case processing
    case completed
    case failed

    public var displayName: String {
        switch self {
        case .queued: return "Queued"
        case .processing: return "Processing"
        case .completed: return "Completed"
        case .failed: return "Failed"
        }
    }

    public var color: Color {
        switch self {
        case .queued: return .orange
        case .processing: return .blue
        case .completed: return .green
        case .failed: return .red
        }
    }
}
