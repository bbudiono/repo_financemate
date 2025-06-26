//
//  DocumentListManager.swift
//  FinanceMate
//
//  Created by Assistant on 6/11/25.
//

import CoreData
import Foundation
import SwiftUI

/// Specialized Manager for Document List Operations
/// Handles list virtualization, filtering, and performance optimization
@MainActor
class DocumentListManager: ObservableObject, DocumentManagerProtocol {
    typealias DataType = [Document]

    // MARK: - Core Properties
    @Published var isProcessing: Bool = false
    @Published var errorMessage: String = ""
    @Published var hasError: Bool = false

    // MARK: - List Management Properties
    @Published var visibleRange: Range<Int> = 0..<50 // Virtualization window
    @Published var totalCount: Int = 0
    @Published var isVirtualizationEnabled: Bool = true

    // MARK: - Performance Tracking
    @Published var listPerformanceMetrics = ListPerformanceMetrics()

    // MARK: - Core Data Context
    private let viewContext: NSManagedObjectContext

    // MARK: - Configuration
    private let virtualizationThreshold = 100 // Enable virtualization for lists > 100 items
    private let chunkSize = 50 // Number of items to load at once

    // MARK: - Initialization
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
    }

    // MARK: - DocumentManagerProtocol Implementation
    func performOperation() async throws -> [Document] {
        let startTime = CFAbsoluteTimeGetCurrent()
        isProcessing = true

        do {
            let documents = try await fetchDocuments()

            let endTime = CFAbsoluteTimeGetCurrent()
            updatePerformanceMetrics(fetchTime: endTime - startTime, documentCount: documents.count)

            isProcessing = false
            return documents
        } catch {
            handleError(error)
            throw error
        }
    }

    func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        hasError = true
        isProcessing = false
    }

    func reset() {
        isProcessing = false
        errorMessage = ""
        hasError = false
        visibleRange = 0..<chunkSize
        listPerformanceMetrics = ListPerformanceMetrics()
    }

    // MARK: - List Operations

    /// Fetch documents with optional pagination for virtualization
    private func fetchDocuments() async throws -> [Document] {
        try await withCheckedThrowingContinuation { continuation in
            let fetchRequest: NSFetchRequest<Document> = Document.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Document.dateCreated, ascending: false)]

            // Apply virtualization if enabled
            if isVirtualizationEnabled && totalCount > virtualizationThreshold {
                fetchRequest.fetchOffset = visibleRange.lowerBound
                fetchRequest.fetchLimit = visibleRange.count
            }

            do {
                let documents = try viewContext.fetch(fetchRequest)
                continuation.resume(returning: documents)
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    /// Filter documents based on search text and filter criteria
    func filteredDocuments(searchText: String, filter: DocumentFilter, documents: [Document]) -> [Document] {
        let startTime = CFAbsoluteTimeGetCurrent()

        let filtered = documents.filter { document in
            // Apply document type filter
            if filter != .all && getDocumentType(document) != filter.uiDocumentType {
                return false
            }

            // Apply search text filter
            if !searchText.isEmpty {
                let fileName = document.fileName ?? ""
                let extractedText = document.rawOCRText ?? ""
                return fileName.localizedCaseInsensitiveContains(searchText) ||
                       extractedText.localizedCaseInsensitiveContains(searchText)
            }

            return true
        }

        let sorted = filtered.sorted {
            ($0.dateCreated ?? Date.distantPast) > ($1.dateCreated ?? Date.distantPast)
        }

        let endTime = CFAbsoluteTimeGetCurrent()
        updateFilterPerformanceMetrics(filterTime: endTime - startTime, resultCount: sorted.count)

        return sorted
    }

    /// Delete document from Core Data
    func deleteDocument(_ document: Document) {
        viewContext.delete(document)

        do {
            try viewContext.save()
            print("✅ DocumentListManager: Document deleted successfully - \(document.fileName ?? "Unknown")")
        } catch {
            handleError(DocumentListError.deleteFailed(error.localizedDescription))
            print("❌ DocumentListManager: Failed to delete document - \(error)")
        }
    }

    /// Update visible range for virtualization
    func updateVisibleRange(_ newRange: Range<Int>) {
        guard newRange != visibleRange else { return }

        visibleRange = newRange

        // Trigger refresh if we need to load more data
        if isVirtualizationEnabled {
            Task {
                try await performOperation()
            }
        }
    }

    /// Calculate total document count for virtualization
    func updateTotalCount() async {
        do {
            let fetchRequest: NSFetchRequest<Document> = Document.fetchRequest()
            let count = try viewContext.count(for: fetchRequest)

            await MainActor.run {
                totalCount = count

                // Enable/disable virtualization based on count
                isVirtualizationEnabled = count > virtualizationThreshold
            }
        } catch {
            handleError(DocumentListError.countFailed(error.localizedDescription))
        }
    }

    /// Get document type classification
    private func getDocumentType(_ document: Document) -> UIDocumentType {
        guard let fileName = document.fileName else { return .other }
        let filename = fileName.lowercased()

        if filename.contains("invoice") { return .invoice }
        if filename.contains("receipt") { return .receipt }
        if filename.contains("statement") { return .statement }
        if filename.contains("contract") { return .contract }

        return .other
    }

    // MARK: - Performance Optimization

    /// Update performance metrics for list operations
    private func updatePerformanceMetrics(fetchTime: TimeInterval, documentCount: Int) {
        listPerformanceMetrics.lastFetchTime = fetchTime
        listPerformanceMetrics.documentsPerSecond = Double(documentCount) / fetchTime
        listPerformanceMetrics.totalFetches += 1

        // Update average fetch time
        listPerformanceMetrics.averageFetchTime =
            (listPerformanceMetrics.averageFetchTime * Double(listPerformanceMetrics.totalFetches - 1) + fetchTime) /
            Double(listPerformanceMetrics.totalFetches)
    }

    /// Update performance metrics for filtering operations
    private func updateFilterPerformanceMetrics(filterTime: TimeInterval, resultCount: Int) {
        listPerformanceMetrics.lastFilterTime = filterTime
        listPerformanceMetrics.filteredResultsPerSecond = Double(resultCount) / filterTime
        listPerformanceMetrics.totalFilters += 1

        // Update average filter time
        listPerformanceMetrics.averageFilterTime =
            (listPerformanceMetrics.averageFilterTime * Double(listPerformanceMetrics.totalFilters - 1) + filterTime) /
            Double(listPerformanceMetrics.totalFilters)
    }

    /// Check if list performance is optimal
    func isPerformanceOptimal() -> Bool {
        listPerformanceMetrics.averageFetchTime < 0.5 && // < 500ms fetch time
               listPerformanceMetrics.averageFilterTime < 0.1    // < 100ms filter time
    }

    /// Get performance recommendations
    func getPerformanceRecommendations() -> [String] {
        var recommendations: [String] = []

        if listPerformanceMetrics.averageFetchTime > 1.0 {
            recommendations.append("Consider enabling virtualization for better performance")
        }

        if listPerformanceMetrics.averageFilterTime > 0.2 {
            recommendations.append("Implement search indexing for faster filtering")
        }

        if totalCount > 1000 && !isVirtualizationEnabled {
            recommendations.append("Enable list virtualization for large datasets")
        }

        return recommendations
    }
}

// MARK: - Performance Metrics Data Model

struct ListPerformanceMetrics {
    var lastFetchTime: TimeInterval = 0
    var averageFetchTime: TimeInterval = 0
    var lastFilterTime: TimeInterval = 0
    var averageFilterTime: TimeInterval = 0
    var documentsPerSecond: Double = 0
    var filteredResultsPerSecond: Double = 0
    var totalFetches: Int = 0
    var totalFilters: Int = 0
    var memoryUsage: Int64 = 0

    var performanceGrade: PerformanceGrade {
        let avgTime = (averageFetchTime + averageFilterTime) / 2

        if avgTime < 0.1 {
            return .excellent
        } else if avgTime < 0.3 {
            return .good
        } else if avgTime < 0.6 {
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

// MARK: - Document Filter Type Extensions

extension DocumentFilter {
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
}

// MARK: - Document Filter Enum

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

    var documentType: DocumentType? {
        switch self {
        case .all: return nil
        case .invoices: return .invoice
        case .receipts: return .receipt
        case .statements: return .statement
        case .contracts: return .other
        }
    }
}

// MARK: - List-Specific Error Types

enum DocumentListError: Error, LocalizedError {
    case fetchFailed(String)
    case deleteFailed(String)
    case countFailed(String)
    case virtualizationError(String)

    var errorDescription: String? {
        switch self {
        case .fetchFailed(let message):
            return "Failed to fetch documents: \(message)"
        case .deleteFailed(let message):
            return "Failed to delete document: \(message)"
        case .countFailed(let message):
            return "Failed to count documents: \(message)"
        case .virtualizationError(let message):
            return "Virtualization error: \(message)"
        }
    }
}
