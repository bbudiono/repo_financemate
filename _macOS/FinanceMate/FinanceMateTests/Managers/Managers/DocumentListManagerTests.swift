//
//  DocumentListManagerTests.swift
//  FinanceMateTests
//
//  Purpose: Comprehensive unit tests for DocumentListManager
//  Issues & Complexity Summary: Tests list virtualization, filtering, performance metrics, and document operations
//  Key Complexity Drivers:
//    - Logic Scope (Est. LoC): ~350
//    - Core Algorithm Complexity: High
//    - Dependencies: 4 (XCTest, CoreData, DocumentListManager, SwiftUI)
//    - State Management Complexity: High
//    - Novelty/Uncertainty Factor: Medium
//  AI Pre-Task Self-Assessment: 82%
//  Problem Estimate: 78%
//  Initial Code Complexity Estimate: 80%
//  Final Code Complexity: 85%
//  Overall Result Score: 93%
//  Key Variances/Learnings: Complex list virtualization and performance tracking testing
//  Last Updated: 2025-06-26

import XCTest
import CoreData
import SwiftUI
@testable import FinanceMate

@MainActor
final class DocumentListManagerTests: XCTestCase {
    var documentListManager: DocumentListManager!
    var testContext: NSManagedObjectContext!
    var persistentContainer: NSPersistentContainer!
    
    override func setUp() async throws {
        try await super.setUp()
        
        // Create in-memory Core Data stack for testing
        let model = createTestDataModel()
        persistentContainer = NSPersistentContainer(name: "TestModel", managedObjectModel: model)
        
        let storeDescription = NSPersistentStoreDescription()
        storeDescription.type = NSInMemoryStoreType
        persistentContainer.persistentStoreDescriptions = [storeDescription]
        
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load test store: \(error)")
            }
        }
        
        testContext = persistentContainer.viewContext
        documentListManager = DocumentListManager(viewContext: testContext)
    }
    
    override func tearDown() async throws {
        documentListManager = nil
        testContext = nil
        persistentContainer = nil
        try await super.tearDown()
    }
    
    // MARK: - Test Data Model Creation
    
    private func createTestDataModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()
        
        // Document Entity
        let documentEntity = NSEntityDescription()
        documentEntity.name = "Document"
        documentEntity.managedObjectClassName = "Document"
        
        let documentAttributes = [
            createAttribute(name: "id", type: .uuid),
            createAttribute(name: "fileName", type: .string),
            createAttribute(name: "rawOCRText", type: .string),
            createAttribute(name: "dateCreated", type: .date),
            createAttribute(name: "dateUpdated", type: .date),
            createAttribute(name: "documentType", type: .string),
            createAttribute(name: "fileSize", type: .integer64),
            createAttribute(name: "filePath", type: .string),
            createAttribute(name: "isProcessed", type: .boolean),
            createAttribute(name: "processingStatus", type: .string)
        ]
        documentEntity.properties = documentAttributes
        
        model.entities = [documentEntity]
        return model
    }
    
    private func createAttribute(name: String, type: NSAttributeType) -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = name
        attribute.attributeType = type
        attribute.isOptional = true
        if type == .boolean {
            attribute.defaultValue = false
        }
        return attribute
    }
    
    // MARK: - Test Helper Methods
    
    private func createTestDocument(fileName: String, ocrText: String = "", documentType: String = "other") -> Document {
        let document = Document(context: testContext)
        document.id = UUID()
        document.fileName = fileName
        document.rawOCRText = ocrText
        document.dateCreated = Date()
        document.dateUpdated = Date()
        document.documentType = documentType
        document.isProcessed = true
        document.fileSize = Int64.random(in: 1000...100000)
        
        try! testContext.save()
        return document
    }
    
    // MARK: - Initialization Tests
    
    func testDocumentListManagerInitialization() {
        XCTAssertNotNil(documentListManager)
        XCTAssertFalse(documentListManager.isProcessing)
        XCTAssertEqual(documentListManager.errorMessage, "")
        XCTAssertFalse(documentListManager.hasError)
        XCTAssertEqual(documentListManager.visibleRange, 0..<50)
        XCTAssertEqual(documentListManager.totalCount, 0)
        XCTAssertTrue(documentListManager.isVirtualizationEnabled)
    }
    
    // MARK: - Document Operations Tests
    
    func testPerformOperationWithNoDocuments() async throws {
        // When
        let documents = try await documentListManager.performOperation()
        
        // Then
        XCTAssertEqual(documents.count, 0)
        XCTAssertFalse(documentListManager.isProcessing)
        XCTAssertFalse(documentListManager.hasError)
    }
    
    func testPerformOperationWithDocuments() async throws {
        // Given
        let document1 = createTestDocument(fileName: "invoice1.pdf", ocrText: "Invoice content")
        let document2 = createTestDocument(fileName: "receipt2.pdf", ocrText: "Receipt content")
        
        // When
        let documents = try await documentListManager.performOperation()
        
        // Then
        XCTAssertEqual(documents.count, 2)
        XCTAssertFalse(documentListManager.isProcessing)
        XCTAssertFalse(documentListManager.hasError)
        
        // Verify documents are sorted by date created (newest first)
        XCTAssertEqual(documents.first?.id, document2.id) // Most recent first
        XCTAssertEqual(documents.last?.id, document1.id)
    }
    
    func testDeleteDocument() {
        // Given
        let document = createTestDocument(fileName: "test.pdf")
        let initialCount = try! testContext.count(for: Document.fetchRequest())
        XCTAssertEqual(initialCount, 1)
        
        // When
        documentListManager.deleteDocument(document)
        
        // Then
        let finalCount = try! testContext.count(for: Document.fetchRequest())
        XCTAssertEqual(finalCount, 0)
        XCTAssertFalse(documentListManager.hasError)
    }
    
    // MARK: - Filtering Tests
    
    func testFilteredDocumentsWithAllFilter() {
        // Given
        let documents = [
            createTestDocument(fileName: "invoice1.pdf", ocrText: "Invoice content"),
            createTestDocument(fileName: "receipt2.pdf", ocrText: "Receipt content"),
            createTestDocument(fileName: "statement3.pdf", ocrText: "Statement content")
        ]
        
        // When
        let filtered = documentListManager.filteredDocuments(searchText: "", filter: .all, documents: documents)
        
        // Then
        XCTAssertEqual(filtered.count, 3)
    }
    
    func testFilteredDocumentsWithInvoiceFilter() {
        // Given
        let documents = [
            createTestDocument(fileName: "invoice1.pdf", ocrText: "Invoice content"),
            createTestDocument(fileName: "receipt2.pdf", ocrText: "Receipt content"),
            createTestDocument(fileName: "statement3.pdf", ocrText: "Statement content")
        ]
        
        // When
        let filtered = documentListManager.filteredDocuments(searchText: "", filter: .invoices, documents: documents)
        
        // Then
        XCTAssertEqual(filtered.count, 1)
        XCTAssertEqual(filtered.first?.fileName, "invoice1.pdf")
    }
    
    func testFilteredDocumentsWithSearchText() {
        // Given
        let documents = [
            createTestDocument(fileName: "invoice1.pdf", ocrText: "Invoice content with special keyword"),
            createTestDocument(fileName: "receipt2.pdf", ocrText: "Receipt content"),
            createTestDocument(fileName: "special_document.pdf", ocrText: "Normal content")
        ]
        
        // When
        let filtered = documentListManager.filteredDocuments(searchText: "special", filter: .all, documents: documents)
        
        // Then
        XCTAssertEqual(filtered.count, 2)
        
        let fileNames = filtered.compactMap { $0.fileName }
        XCTAssertTrue(fileNames.contains("invoice1.pdf")) // Contains "special" in OCR text
        XCTAssertTrue(fileNames.contains("special_document.pdf")) // Contains "special" in filename
    }
    
    func testFilteredDocumentsWithSearchTextAndFilter() {
        // Given
        let documents = [
            createTestDocument(fileName: "invoice1.pdf", ocrText: "Invoice with payment details"),
            createTestDocument(fileName: "receipt2.pdf", ocrText: "Receipt with payment info"),
            createTestDocument(fileName: "statement3.pdf", ocrText: "Statement content")
        ]
        
        // When
        let filtered = documentListManager.filteredDocuments(searchText: "payment", filter: .invoices, documents: documents)
        
        // Then
        XCTAssertEqual(filtered.count, 1)
        XCTAssertEqual(filtered.first?.fileName, "invoice1.pdf")
    }
    
    func testFilteredDocumentsSortedByDateCreated() {
        // Given
        let document1 = createTestDocument(fileName: "old.pdf")
        Thread.sleep(forTimeInterval: 0.01) // Ensure different timestamps
        let document2 = createTestDocument(fileName: "new.pdf")
        
        let documents = [document1, document2]
        
        // When
        let filtered = documentListManager.filteredDocuments(searchText: "", filter: .all, documents: documents)
        
        // Then
        XCTAssertEqual(filtered.count, 2)
        XCTAssertEqual(filtered.first?.fileName, "new.pdf") // Newer document first
        XCTAssertEqual(filtered.last?.fileName, "old.pdf")
    }
    
    // MARK: - Virtualization Tests
    
    func testUpdateVisibleRange() {
        // Given
        let newRange = 25..<75
        
        // When
        documentListManager.updateVisibleRange(newRange)
        
        // Then
        XCTAssertEqual(documentListManager.visibleRange, newRange)
    }
    
    func testUpdateVisibleRangeWithSameRange() {
        // Given
        let originalRange = documentListManager.visibleRange
        
        // When
        documentListManager.updateVisibleRange(originalRange)
        
        // Then
        XCTAssertEqual(documentListManager.visibleRange, originalRange)
    }
    
    func testUpdateTotalCount() async {
        // Given
        createTestDocument(fileName: "doc1.pdf")
        createTestDocument(fileName: "doc2.pdf")
        createTestDocument(fileName: "doc3.pdf")
        
        // When
        await documentListManager.updateTotalCount()
        
        // Then
        XCTAssertEqual(documentListManager.totalCount, 3)
        
        // Should disable virtualization for small counts
        XCTAssertFalse(documentListManager.isVirtualizationEnabled)
    }
    
    func testUpdateTotalCountEnablesVirtualization() async {
        // Given - Create more than threshold documents (100+)
        for i in 0..<101 {
            createTestDocument(fileName: "doc\(i).pdf")
        }
        
        // When
        await documentListManager.updateTotalCount()
        
        // Then
        XCTAssertEqual(documentListManager.totalCount, 101)
        XCTAssertTrue(documentListManager.isVirtualizationEnabled)
    }
    
    // MARK: - Performance Metrics Tests
    
    func testPerformanceMetricsInitialization() {
        let metrics = documentListManager.listPerformanceMetrics
        
        XCTAssertEqual(metrics.lastFetchTime, 0)
        XCTAssertEqual(metrics.averageFetchTime, 0)
        XCTAssertEqual(metrics.lastFilterTime, 0)
        XCTAssertEqual(metrics.averageFilterTime, 0)
        XCTAssertEqual(metrics.documentsPerSecond, 0)
        XCTAssertEqual(metrics.filteredResultsPerSecond, 0)
        XCTAssertEqual(metrics.totalFetches, 0)
        XCTAssertEqual(metrics.totalFilters, 0)
    }
    
    func testPerformanceMetricsUpdateAfterOperation() async throws {
        // Given
        createTestDocument(fileName: "test.pdf")
        
        // When
        let _ = try await documentListManager.performOperation()
        
        // Then
        let metrics = documentListManager.listPerformanceMetrics
        XCTAssertGreaterThan(metrics.lastFetchTime, 0)
        XCTAssertGreaterThan(metrics.documentsPerSecond, 0)
        XCTAssertEqual(metrics.totalFetches, 1)
        XCTAssertEqual(metrics.averageFetchTime, metrics.lastFetchTime)
    }
    
    func testPerformanceMetricsUpdateAfterFiltering() {
        // Given
        let documents = [createTestDocument(fileName: "test.pdf")]
        
        // When
        let _ = documentListManager.filteredDocuments(searchText: "", filter: .all, documents: documents)
        
        // Then
        let metrics = documentListManager.listPerformanceMetrics
        XCTAssertGreaterThan(metrics.lastFilterTime, 0)
        XCTAssertGreaterThan(metrics.filteredResultsPerSecond, 0)
        XCTAssertEqual(metrics.totalFilters, 1)
        XCTAssertEqual(metrics.averageFilterTime, metrics.lastFilterTime)
    }
    
    func testIsPerformanceOptimal() {
        // Given - Set good performance metrics
        documentListManager.listPerformanceMetrics.averageFetchTime = 0.3
        documentListManager.listPerformanceMetrics.averageFilterTime = 0.05
        
        // When
        let isOptimal = documentListManager.isPerformanceOptimal()
        
        // Then
        XCTAssertTrue(isOptimal)
    }
    
    func testIsPerformanceNotOptimal() {
        // Given - Set poor performance metrics
        documentListManager.listPerformanceMetrics.averageFetchTime = 1.0
        documentListManager.listPerformanceMetrics.averageFilterTime = 0.5
        
        // When
        let isOptimal = documentListManager.isPerformanceOptimal()
        
        // Then
        XCTAssertFalse(isOptimal)
    }
    
    func testGetPerformanceRecommendations() {
        // Given - Set poor performance metrics
        documentListManager.listPerformanceMetrics.averageFetchTime = 1.5
        documentListManager.listPerformanceMetrics.averageFilterTime = 0.3
        documentListManager.totalCount = 1500
        documentListManager.isVirtualizationEnabled = false
        
        // When
        let recommendations = documentListManager.getPerformanceRecommendations()
        
        // Then
        XCTAssertEqual(recommendations.count, 3)
        XCTAssertTrue(recommendations.contains("Consider enabling virtualization for better performance"))
        XCTAssertTrue(recommendations.contains("Implement search indexing for faster filtering"))
        XCTAssertTrue(recommendations.contains("Enable list virtualization for large datasets"))
    }
    
    func testGetPerformanceRecommendationsWithGoodPerformance() {
        // Given - Set good performance metrics
        documentListManager.listPerformanceMetrics.averageFetchTime = 0.3
        documentListManager.listPerformanceMetrics.averageFilterTime = 0.05
        documentListManager.totalCount = 50
        documentListManager.isVirtualizationEnabled = true
        
        // When
        let recommendations = documentListManager.getPerformanceRecommendations()
        
        // Then
        XCTAssertEqual(recommendations.count, 0)
    }
    
    // MARK: - Error Handling Tests
    
    func testHandleError() {
        // Given
        let error = NSError(domain: "TestDomain", code: 123, userInfo: [NSLocalizedDescriptionKey: "Test error"])
        
        // When
        documentListManager.handleError(error)
        
        // Then
        XCTAssertTrue(documentListManager.hasError)
        XCTAssertEqual(documentListManager.errorMessage, "Test error")
        XCTAssertFalse(documentListManager.isProcessing)
    }
    
    func testReset() {
        // Given - Set some state
        documentListManager.isProcessing = true
        documentListManager.hasError = true
        documentListManager.errorMessage = "Some error"
        documentListManager.visibleRange = 100..<150
        documentListManager.listPerformanceMetrics.totalFetches = 10
        
        // When
        documentListManager.reset()
        
        // Then
        XCTAssertFalse(documentListManager.isProcessing)
        XCTAssertFalse(documentListManager.hasError)
        XCTAssertEqual(documentListManager.errorMessage, "")
        XCTAssertEqual(documentListManager.visibleRange, 0..<50)
        XCTAssertEqual(documentListManager.listPerformanceMetrics.totalFetches, 0)
    }
    
    // MARK: - Performance Grade Tests
    
    func testPerformanceGradeExcellent() {
        var metrics = ListPerformanceMetrics()
        metrics.averageFetchTime = 0.05
        metrics.averageFilterTime = 0.05
        
        XCTAssertEqual(metrics.performanceGrade, .excellent)
        XCTAssertEqual(metrics.performanceGrade.description, "Excellent")
        XCTAssertEqual(metrics.performanceGrade.color, .green)
    }
    
    func testPerformanceGradeGood() {
        var metrics = ListPerformanceMetrics()
        metrics.averageFetchTime = 0.2
        metrics.averageFilterTime = 0.2
        
        XCTAssertEqual(metrics.performanceGrade, .good)
        XCTAssertEqual(metrics.performanceGrade.description, "Good")
        XCTAssertEqual(metrics.performanceGrade.color, .blue)
    }
    
    func testPerformanceGradeFair() {
        var metrics = ListPerformanceMetrics()
        metrics.averageFetchTime = 0.4
        metrics.averageFilterTime = 0.4
        
        XCTAssertEqual(metrics.performanceGrade, .fair)
        XCTAssertEqual(metrics.performanceGrade.description, "Fair")
        XCTAssertEqual(metrics.performanceGrade.color, .orange)
    }
    
    func testPerformanceGradePoor() {
        var metrics = ListPerformanceMetrics()
        metrics.averageFetchTime = 0.8
        metrics.averageFilterTime = 0.8
        
        XCTAssertEqual(metrics.performanceGrade, .poor)
        XCTAssertEqual(metrics.performanceGrade.description, "Poor")
        XCTAssertEqual(metrics.performanceGrade.color, .red)
    }
    
    // MARK: - Document Type and Filter Tests
    
    func testUIDocumentTypeProperties() {
        let invoice = UIDocumentType.invoice
        XCTAssertEqual(invoice.icon, "doc.text")
        XCTAssertEqual(invoice.color, .blue)
        XCTAssertEqual(invoice.displayName, "Invoice")
        
        let receipt = UIDocumentType.receipt
        XCTAssertEqual(receipt.icon, "receipt")
        XCTAssertEqual(receipt.color, .green)
        XCTAssertEqual(receipt.displayName, "Receipt")
    }
    
    func testDocumentFilterUIDocumentType() {
        XCTAssertNil(DocumentFilter.all.uiDocumentType)
        XCTAssertEqual(DocumentFilter.invoices.uiDocumentType, .invoice)
        XCTAssertEqual(DocumentFilter.receipts.uiDocumentType, .receipt)
        XCTAssertEqual(DocumentFilter.statements.uiDocumentType, .statement)
        XCTAssertEqual(DocumentFilter.contracts.uiDocumentType, .contract)
    }
    
    func testDocumentFilterDisplayNames() {
        XCTAssertEqual(DocumentFilter.all.displayName, "All")
        XCTAssertEqual(DocumentFilter.invoices.displayName, "Invoices")
        XCTAssertEqual(DocumentFilter.receipts.displayName, "Receipts")
        XCTAssertEqual(DocumentFilter.statements.displayName, "Statements")
        XCTAssertEqual(DocumentFilter.contracts.displayName, "Contracts")
    }
    
    // MARK: - Error Types Tests
    
    func testDocumentListErrorDescriptions() {
        let fetchError = DocumentListError.fetchFailed("Network error")
        XCTAssertEqual(fetchError.errorDescription, "Failed to fetch documents: Network error")
        
        let deleteError = DocumentListError.deleteFailed("Permission denied")
        XCTAssertEqual(deleteError.errorDescription, "Failed to delete document: Permission denied")
        
        let countError = DocumentListError.countFailed("Database error")
        XCTAssertEqual(countError.errorDescription, "Failed to count documents: Database error")
        
        let virtualizationError = DocumentListError.virtualizationError("Memory issue")
        XCTAssertEqual(virtualizationError.errorDescription, "Virtualization error: Memory issue")
    }
    
    // MARK: - Concurrent Operations Tests
    
    func testConcurrentFiltering() {
        // Given
        let documents = (0..<100).map { i in
            createTestDocument(fileName: "document\(i).pdf", ocrText: "Content \(i)")
        }
        
        let expectation = XCTestExpectation(description: "Concurrent filtering")
        expectation.expectedFulfillmentCount = 10
        
        let queue = DispatchQueue(label: "test.concurrent", attributes: .concurrent)
        
        // When - Perform 10 concurrent filtering operations
        for i in 0..<10 {
            queue.async {
                Task { @MainActor in
                    let filtered = self.documentListManager.filteredDocuments(
                        searchText: "Content",
                        filter: .all,
                        documents: documents
                    )
                    XCTAssertEqual(filtered.count, 100)
                    expectation.fulfill()
                }
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
        
        // Then
        let metrics = documentListManager.listPerformanceMetrics
        XCTAssertEqual(metrics.totalFilters, 10)
    }
    
    // MARK: - Performance Tests
    
    func testFilteringPerformance() {
        // Given
        let documents = (0..<1000).map { i in
            createTestDocument(fileName: "document\(i).pdf", ocrText: "Content \(i)")
        }
        
        // When
        measure {
            let _ = documentListManager.filteredDocuments(searchText: "Content", filter: .all, documents: documents)
        }
    }
    
    func testFetchOperationPerformance() async throws {
        // Given
        for i in 0..<100 {
            createTestDocument(fileName: "document\(i).pdf")
        }
        
        // When
        measure {
            Task {
                try await documentListManager.performOperation()
            }
        }
    }
}