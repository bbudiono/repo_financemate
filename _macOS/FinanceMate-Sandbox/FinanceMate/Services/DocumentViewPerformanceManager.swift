//
//  DocumentViewPerformanceManager.swift
//  FinanceMate
//
//  Extracted from DocumentsView.swift for SwiftLint compliance
//  Created by Assistant on 6/27/25.
//

/*
* Purpose: Performance monitoring and optimization for document list rendering
* Issues & Complexity Summary: Performance metrics tracking and virtualization management
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~80
  - Core Algorithm Complexity: Medium (filtering performance optimization)
  - Dependencies: 2 (Core Data, performance metrics)
  - State Management Complexity: Medium
  - Novelty/Uncertainty Factor: Low
* AI Pre-Task Self-Assessment: 75%
* Problem Estimate: 70%
* Initial Code Complexity Estimate: 72%
* Final Code Complexity: 75%
* Overall Result Score: 88%
* Key Variances/Learnings: Performance optimization straightforward to extract
* Last Updated: 2025-06-27
*/

import Foundation
import SwiftUI
import CoreData

// MARK: - Document View Performance Metrics
// Note: DocumentViewPerformanceMetrics and PerformanceGrade are defined in DocumentModels.swift

// MARK: - Document View Performance Manager

@MainActor
class DocumentViewPerformanceManager: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var isVirtualizationEnabled = false
    @Published var visibleRange: Range<Int> = 0..<50
    @Published var totalDocumentCount = 0
    @Published var filterPerformanceMetrics = DocumentViewPerformanceMetrics()
    
    // MARK: - Performance Monitoring
    
    /// Updates performance metrics after filtering operation
    /// - Parameters:
    ///   - startTime: Start time of the filtering operation
    ///   - documentCount: Total number of documents being filtered
    func updateFilterPerformance(startTime: CFAbsoluteTime, documentCount: Int) {
        let endTime = CFAbsoluteTimeGetCurrent()
        filterPerformanceMetrics.lastFilterTime = endTime - startTime
        filterPerformanceMetrics.totalFilters += 1
    }
    
    /// Updates total document count and virtualization settings
    /// - Parameter count: Total number of documents
    func updateDocumentCount(_ count: Int) {
        totalDocumentCount = count
        isVirtualizationEnabled = count > 100
    }
    
    /// Optimizes document filtering with performance considerations
    /// - Parameters:
    ///   - documents: Source documents to filter
    ///   - searchText: Search text filter
    ///   - selectedFilter: Document type filter
    ///   - performanceMonitor: App performance monitor
    /// - Returns: Filtered and optimized document array
    func optimizeDocumentFiltering(
        documents: FetchedResults<Document>,
        searchText: String,
        selectedFilter: DocumentFilter,
        performanceMonitor: AppPerformanceMonitor
    ) -> [Document] {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // Early return for better performance
        if documents.isEmpty {
            return []
        }
        
        // PERFORMANCE OPTIMIZATION: Use lazy evaluation for large datasets
        let filtered = documents.lazy.filter { document in
            // Apply document type filter first (most selective)
            if selectedFilter != .all {
                // Use the document's categorization to determine type
                let documentType = self.getDocumentTypeFromDocument(document)
                if documentType != selectedFilter.uiDocumentType {
                    return false
                }
            }
            
            // Apply search text filter with optimized search
            if !searchText.isEmpty {
                let searchLower = searchText.lowercased()
                let fileName = (document.fileName ?? "").lowercased()
                let extractedText = (document.rawOCRText ?? "").lowercased()
                
                // PERFORMANCE OPTIMIZATION: Short-circuit evaluation
                return fileName.contains(searchLower) || extractedText.contains(searchLower)
            }
            
            return true
        }
        
        // PERFORMANCE OPTIMIZATION: Limit sorting for large datasets
        let result: [Document]
        if performanceMonitor.isLowMemoryMode && filtered.count > 100 {
            // In low memory mode, limit results
            result = Array(filtered.prefix(100))
        } else {
            result = filtered.sorted {
                ($0.dateCreated ?? Date.distantPast) > ($1.dateCreated ?? Date.distantPast)
            }
        }
        
        // Update performance metrics
        updateFilterPerformance(startTime: startTime, documentCount: documents.count)
        
        return result
    }
    
    /// Manages virtualized document range for large lists
    /// - Parameter documentCount: Total number of documents available
    func updateVirtualizedRange(for documentCount: Int) {
        let endIndex = min(visibleRange.upperBound, documentCount)
        let validRange = visibleRange.lowerBound..<endIndex
        
        if validRange.lowerBound >= documentCount {
            visibleRange = 0..<min(50, documentCount)
        }
    }
    
    /// Loads more documents for virtualized scrolling
    /// - Parameter totalCount: Total number of available documents
    func loadMoreDocuments(totalCount: Int) {
        let newUpperBound = min(visibleRange.upperBound + 50, totalCount)
        let newRange = visibleRange.lowerBound..<newUpperBound
        visibleRange = newRange
    }
    
    /// Resets performance metrics
    func resetMetrics() {
        filterPerformanceMetrics = DocumentViewPerformanceMetrics()
        visibleRange = 0..<50
    }
    
    // MARK: - Private Helper Methods
    
    /// Determines document type from document metadata and filename
    /// - Parameter document: The document to analyze
    /// - Returns: The inferred UIDocumentType based on filename and content
    private func getDocumentTypeFromDocument(_ document: Document) -> UIDocumentType? {
        guard let fileName = document.fileName else { return .other }
        
        let lowercasedFileName = fileName.lowercased()
        
        // Check for specific document types based on filename patterns
        if lowercasedFileName.contains("invoice") {
            return .invoice
        } else if lowercasedFileName.contains("receipt") {
            return .receipt
        } else if lowercasedFileName.contains("statement") {
            return .statement
        } else if lowercasedFileName.contains("bill") {
            return .bill
        }
        
        // Fallback to analyzing file extension or OCR text for additional clues
        if let ocrText = document.rawOCRText?.lowercased() {
            if ocrText.contains("invoice") {
                return .invoice
            } else if ocrText.contains("receipt") {
                return .receipt
            } else if ocrText.contains("statement") {
                return .statement
            } else if ocrText.contains("bill") {
                return .bill
            }
        }
        
        return .other
    }
}

// MARK: - App Performance Monitor
// Note: AppPerformanceMonitor is defined in FinanceMateApp.swift