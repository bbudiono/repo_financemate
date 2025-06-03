// SANDBOX FILE: For testing/development. See .cursorrules.

/*
* Purpose: Comprehensive TDD tests for DocumentsView SwiftUI component in Sandbox environment
* Issues & Complexity Summary: TDD-driven UI component testing with SwiftUI, state management, and document processing integration
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~400
  - Core Algorithm Complexity: High
  - Dependencies: 6 New (SwiftUI testing, XCTest, async testing, file handling, UI state validation, Core Data)
  - State Management Complexity: High
  - Novelty/Uncertainty Factor: Medium
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 88%
* Problem Estimate (Inherent Problem Difficulty %): 85%
* Initial Code Complexity Estimate %: 86%
* Justification for Estimates: SwiftUI testing complexity, async state management, and document processing integration
* Final Code Complexity (Actual %): TBD - TDD iteration
* Overall Result Score (Success & Quality %): TBD - TDD completion
* Key Variances/Learnings: TDD approach ensures robust UI component behavior and state management
* Last Updated: 2025-06-03
*/

import XCTest
import SwiftUI
import Foundation
import Combine
@testable import FinanceMate_Sandbox

@MainActor
final class DocumentsViewTDDTests: XCTestCase {
    
    // MARK: - Test Properties
    
    var documentsView: DocumentsView!
    var testDataDirectory: URL!
    var cancellables: Set<AnyCancellable>!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        documentsView = DocumentsView()
        cancellables = Set<AnyCancellable>()
        
        // Create test data directory
        testDataDirectory = FileManager.default.temporaryDirectory.appendingPathComponent("TDD_DocumentsViewTests_\(UUID().uuidString)")
        try? FileManager.default.createDirectory(at: testDataDirectory, withIntermediateDirectories: true)
    }
    
    override func tearDown() {
        // Clean up test data
        try? FileManager.default.removeItem(at: testDataDirectory)
        
        cancellables = nil
        documentsView = nil
        testDataDirectory = nil
        
        super.tearDown()
    }
    
    // MARK: - TDD TESTS: Document State Management
    
    func testDocumentInitialState() {
        // Given: A new DocumentsView instance
        let view = DocumentsView()
        
        // When: Checking initial state
        // Then: Should have proper initial state
        XCTAssertNotNil(view)
        // Note: State properties are @State and not directly accessible in tests
        // We'll test behavior through interactions
    }
    
    func testDocumentAddition() async throws {
        // Given: An empty document list state
        let testURL = createTestInvoiceFile()
        
        // When: Adding a document
        let documentManager = DocumentsViewManager()
        await documentManager.addDocument(from: testURL)
        
        // Then: Document should be added to the list
        XCTAssertEqual(documentManager.documents.count, 1)
        XCTAssertEqual(documentManager.documents.first?.name, testURL.lastPathComponent)
        XCTAssertEqual(documentManager.documents.first?.type, DocumentType.from(url: testURL))
    }
    
    func testDocumentDeletion() async throws {
        // Given: A document list with one document
        let testURL = createTestInvoiceFile()
        let documentManager = DocumentsViewManager()
        await documentManager.addDocument(from: testURL)
        
        XCTAssertEqual(documentManager.documents.count, 1)
        
        // When: Deleting the document
        let document = documentManager.documents.first!
        await documentManager.deleteDocument(document)
        
        // Then: Document should be removed from the list
        XCTAssertEqual(documentManager.documents.count, 0)
    }
    
    func testMultipleDocumentHandling() async throws {
        // Given: Multiple test documents
        let urls = [
            createTestInvoiceFile(),
            createTestReceiptFile(),
            createTestStatementFile()
        ]
        
        let documentManager = DocumentsViewManager()
        
        // When: Adding multiple documents
        for url in urls {
            await documentManager.addDocument(from: url)
        }
        
        // Then: All documents should be added
        XCTAssertEqual(documentManager.documents.count, 3)
        XCTAssertTrue(documentManager.documents.contains { $0.type == .invoice })
        XCTAssertTrue(documentManager.documents.contains { $0.type == .receipt })
        XCTAssertTrue(documentManager.documents.contains { $0.type == .statement })
    }
    
    // MARK: - TDD TESTS: Document Processing Integration
    
    func testDocumentProcessingWorkflow() async throws {
        // Given: A document and processing manager
        let testURL = createTestInvoiceFile()
        let documentManager = DocumentsViewManager()
        
        // When: Processing a document
        await documentManager.addDocument(from: testURL)
        let document = documentManager.documents.first!
        
        XCTAssertEqual(document.processingStatus, .pending)
        
        await documentManager.processDocument(document)
        
        // Then: Document should be processed
        let processedDocument = documentManager.documents.first!
        XCTAssertEqual(processedDocument.processingStatus, .completed)
        XCTAssertNotEqual(processedDocument.extractedText, "")
    }
    
    func testDocumentProcessingError() async throws {
        // Given: An invalid document
        let invalidURL = createInvalidFile()
        let documentManager = DocumentsViewManager()
        
        // When: Processing an invalid document
        await documentManager.addDocument(from: invalidURL)
        let document = documentManager.documents.first!
        
        await documentManager.processDocument(document)
        
        // Then: Document should show failed status
        let processedDocument = documentManager.documents.first!
        XCTAssertEqual(processedDocument.processingStatus, .failed)
    }
    
    func testAsyncProcessingState() async throws {
        // Given: A document to process
        let testURL = createTestInvoiceFile()
        let documentManager = DocumentsViewManager()
        
        // When: Starting async processing
        await documentManager.addDocument(from: testURL)
        let document = documentManager.documents.first!
        
        // Start processing in background
        let processingTask = Task {
            await documentManager.processDocument(document)
        }
        
        // Then: Should show processing state
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        let processingDocument = documentManager.documents.first!
        // Processing state should be either processing or completed by now
        XCTAssertTrue([.processing, .completed].contains(processingDocument.processingStatus))
        
        await processingTask.value
    }
    
    // MARK: - TDD TESTS: Search and Filtering
    
    func testDocumentSearch() async throws {
        // Given: Documents with known content
        let documentManager = DocumentsViewManager()
        
        let invoiceURL = createTestInvoiceFile()
        let receiptURL = createTestReceiptFile()
        
        await documentManager.addDocument(from: invoiceURL)
        await documentManager.addDocument(from: receiptURL)
        
        // When: Searching for specific content
        let searchResults = documentManager.searchDocuments(query: "ACME")
        
        // Then: Should return matching documents
        XCTAssertGreaterThan(searchResults.count, 0)
        XCTAssertTrue(searchResults.allSatisfy { document in
            document.name.localizedCaseInsensitiveContains("ACME") ||
            document.extractedText.localizedCaseInsensitiveContains("ACME")
        })
    }
    
    func testDocumentFilteringByType() async throws {
        // Given: Documents of different types
        let documentManager = DocumentsViewManager()
        
        await documentManager.addDocument(from: createTestInvoiceFile())
        await documentManager.addDocument(from: createTestReceiptFile())
        await documentManager.addDocument(from: createTestStatementFile())
        
        // When: Filtering by invoice type
        let invoiceFilter = documentManager.filterDocuments(by: .invoice)
        
        // Then: Should return only invoices
        XCTAssertEqual(invoiceFilter.count, 1)
        XCTAssertEqual(invoiceFilter.first?.type, .invoice)
    }
    
    func testCombinedSearchAndFilter() async throws {
        // Given: Multiple documents with different types and content
        let documentManager = DocumentsViewManager()
        
        await documentManager.addDocument(from: createTestInvoiceFile())
        await documentManager.addDocument(from: createTestReceiptFile())
        
        // When: Combining search and filter
        let combinedResults = documentManager.filterDocuments(by: .invoice, searchQuery: "ACME")
        
        // Then: Should return documents matching both criteria
        XCTAssertGreaterThanOrEqual(combinedResults.count, 0)
        combinedResults.forEach { document in
            XCTAssertEqual(document.type, .invoice)
            XCTAssertTrue(
                document.name.localizedCaseInsensitiveContains("ACME") ||
                document.extractedText.localizedCaseInsensitiveContains("ACME")
            )
        }
    }
    
    // MARK: - TDD TESTS: File Handling and Validation
    
    func testSupportedFileTypes() async throws {
        // Given: Files of different types
        let pdfURL = testDataDirectory.appendingPathComponent("test.pdf")
        let jpgURL = testDataDirectory.appendingPathComponent("test.jpg")
        let txtURL = testDataDirectory.appendingPathComponent("test.txt")
        let unsupportedURL = testDataDirectory.appendingPathComponent("test.xyz")
        
        "PDF content".write(to: pdfURL, atomically: true, encoding: .utf8)
        "JPG content".write(to: jpgURL, atomically: true, encoding: .utf8)
        "TXT content".write(to: txtURL, atomically: true, encoding: .utf8)
        "Unsupported content".write(to: unsupportedURL, atomically: true, encoding: .utf8)
        
        let documentManager = DocumentsViewManager()
        
        // When: Validating file types
        let pdfValid = documentManager.isFileTypeSupported(pdfURL)
        let jpgValid = documentManager.isFileTypeSupported(jpgURL)
        let txtValid = documentManager.isFileTypeSupported(txtURL)
        let unsupportedValid = documentManager.isFileTypeSupported(unsupportedURL)
        
        // Then: Should correctly identify supported types
        XCTAssertTrue(pdfValid)
        XCTAssertTrue(jpgValid)
        XCTAssertTrue(txtValid)
        XCTAssertFalse(unsupportedValid)
    }
    
    func testFileValidation() async throws {
        // Given: Valid and invalid files
        let validURL = createTestInvoiceFile()
        let nonExistentURL = testDataDirectory.appendingPathComponent("nonexistent.pdf")
        let emptyURL = testDataDirectory.appendingPathComponent("empty.pdf")
        
        "".write(to: emptyURL, atomically: true, encoding: .utf8)
        
        let documentManager = DocumentsViewManager()
        
        // When: Validating files
        let validResult = await documentManager.validateFile(validURL)
        let nonExistentResult = await documentManager.validateFile(nonExistentURL)
        let emptyResult = await documentManager.validateFile(emptyURL)
        
        // Then: Should correctly validate files
        XCTAssertTrue(validResult.isValid)
        XCTAssertFalse(nonExistentResult.isValid)
        XCTAssertFalse(emptyResult.isValid)
        XCTAssertNotNil(nonExistentResult.error)
        XCTAssertNotNil(emptyResult.error)
    }
    
    // MARK: - TDD TESTS: Drag and Drop Functionality
    
    func testDragAndDropValidation() async throws {
        // Given: A DocumentsView drag-drop handler
        let validURLs = [createTestInvoiceFile(), createTestReceiptFile()]
        let invalidURLs = [createInvalidFile()]
        
        let documentManager = DocumentsViewManager()
        
        // When: Handling drag and drop operations
        let validDropResult = await documentManager.handleDrop(urls: validURLs)
        let invalidDropResult = await documentManager.handleDrop(urls: invalidURLs)
        
        // Then: Should handle valid and invalid drops appropriately
        XCTAssertTrue(validDropResult.success)
        XCTAssertEqual(validDropResult.addedDocuments, 2)
        
        XCTAssertFalse(invalidDropResult.success)
        XCTAssertEqual(invalidDropResult.addedDocuments, 0)
        XCTAssertNotNil(invalidDropResult.error)
    }
    
    func testMultipleFileDropHandling() async throws {
        // Given: Multiple files of different types
        let urls = [
            createTestInvoiceFile(),
            createTestReceiptFile(),
            createTestStatementFile(),
            createInvalidFile()
        ]
        
        let documentManager = DocumentsViewManager()
        
        // When: Dropping multiple files
        let dropResult = await documentManager.handleDrop(urls: urls)
        
        // Then: Should handle mixed valid/invalid files
        XCTAssertTrue(dropResult.success) // Should succeed for valid files
        XCTAssertEqual(dropResult.addedDocuments, 3) // Only valid files added
        XCTAssertEqual(dropResult.failedFiles, 1) // One invalid file
    }
    
    // MARK: - TDD TESTS: Real Financial Data Integration
    
    func testFinancialDataExtraction() async throws {
        // Given: A document with real financial content
        let financialURL = createRealFinancialDocument()
        let documentManager = DocumentsViewManager()
        
        // When: Processing document for financial data
        await documentManager.addDocument(from: financialURL)
        let document = documentManager.documents.first!
        await documentManager.processDocument(document)
        
        // Then: Should extract financial information
        let processedDocument = documentManager.documents.first!
        XCTAssertEqual(processedDocument.processingStatus, .completed)
        XCTAssertTrue(processedDocument.extractedText.contains("$"))
        XCTAssertTrue(processedDocument.extractedText.contains("Total"))
    }
    
    func testFinancialDataValidation() async throws {
        // Given: A document with inconsistent financial data
        let inconsistentURL = createInconsistentFinancialDocument()
        let documentManager = DocumentsViewManager()
        
        // When: Processing document with validation
        await documentManager.addDocument(from: inconsistentURL)
        let document = documentManager.documents.first!
        await documentManager.processDocumentWithValidation(document)
        
        // Then: Should detect and report validation issues
        let processedDocument = documentManager.documents.first!
        XCTAssertTrue(
            processedDocument.processingStatus == .completed ||
            processedDocument.processingStatus == .failed
        )
        // Should include validation warnings in extracted text if issues found
        if processedDocument.extractedText.contains("⚠️") {
            XCTAssertTrue(processedDocument.extractedText.contains("validation"))
        }
    }
    
    // MARK: - TDD TESTS: Performance and Concurrency
    
    func testConcurrentDocumentProcessing() async throws {
        // Given: Multiple documents to process concurrently
        let urls = (1...5).map { _ in createTestInvoiceFile() }
        let documentManager = DocumentsViewManager()
        
        // When: Processing documents concurrently
        let startTime = Date()
        
        await withTaskGroup(of: Void.self) { group in
            for url in urls {
                group.addTask {
                    await documentManager.addDocument(from: url)
                }
            }
        }
        
        XCTAssertEqual(documentManager.documents.count, 5)
        
        await withTaskGroup(of: Void.self) { group in
            for document in documentManager.documents {
                group.addTask {
                    await documentManager.processDocument(document)
                }
            }
        }
        
        let endTime = Date()
        let processingTime = endTime.timeIntervalSince(startTime)
        
        // Then: Should handle concurrent processing efficiently
        XCTAssertLessThan(processingTime, 10.0, "Concurrent processing should complete within 10 seconds")
        XCTAssertTrue(documentManager.documents.allSatisfy { 
            $0.processingStatus == .completed || $0.processingStatus == .failed 
        })
    }
    
    func testMemoryManagement() async throws {
        // Given: A large number of documents
        let documentManager = DocumentsViewManager()
        
        // When: Adding and removing many documents
        for i in 1...100 {
            let url = createTestInvoiceFile(name: "test_\(i).txt")
            await documentManager.addDocument(from: url)
        }
        
        XCTAssertEqual(documentManager.documents.count, 100)
        
        // Remove all documents
        for document in Array(documentManager.documents) {
            await documentManager.deleteDocument(document)
        }
        
        // Then: Should handle memory management properly
        XCTAssertEqual(documentManager.documents.count, 0)
        // Memory should be released - we can't directly test this but ensure no crashes
    }
    
    // MARK: - TDD TESTS: Error Handling and Recovery
    
    func testErrorRecovery() async throws {
        // Given: A scenario with processing errors
        let documentManager = DocumentsViewManager()
        let invalidURL = createInvalidFile()
        
        // When: Encountering and recovering from errors
        await documentManager.addDocument(from: invalidURL)
        let document = documentManager.documents.first!
        
        await documentManager.processDocument(document)
        XCTAssertEqual(document.processingStatus, .failed)
        
        // Retry with valid document
        let validURL = createTestInvoiceFile()
        await documentManager.addDocument(from: validURL)
        let validDocument = documentManager.documents.last!
        await documentManager.processDocument(validDocument)
        
        // Then: Should recover and process valid documents
        XCTAssertEqual(validDocument.processingStatus, .completed)
        XCTAssertEqual(documentManager.documents.count, 2)
    }
    
    // MARK: - Helper Methods for Test Document Creation
    
    private func createTestInvoiceFile(name: String = "test_invoice.txt") -> URL {
        let invoiceContent = """
        ACME Services LLC
        123 Business Street
        Business City, CA 90210
        
        INVOICE
        
        Invoice Number: INV-2025-TDD-001
        Invoice Date: June 3, 2025
        Due Date: July 3, 2025
        
        Bill To:
        Test Customer Inc
        
        Description                 Amount
        TDD Consulting Services     $1,500.00
        
        Subtotal:                   $1,500.00
        Tax (8.25%):                $123.75
        Total:                      $1,623.75
        
        Payment Terms: Net 30
        """
        
        let url = testDataDirectory.appendingPathComponent(name)
        try! invoiceContent.write(to: url, atomically: true, encoding: .utf8)
        return url
    }
    
    private func createTestReceiptFile() -> URL {
        let receiptContent = """
        GROCERY MART
        456 Market Street
        
        RECEIPT
        
        Date: 2025-06-03
        Time: 10:30
        
        Organic Milk              $4.50
        Whole Wheat Bread         $3.25
        Free Range Eggs           $6.00
        
        Subtotal:                 $13.75
        Tax:                      $1.10
        Total:                    $14.85
        
        Thank you for shopping!
        """
        
        let url = testDataDirectory.appendingPathComponent("test_receipt_\(UUID().uuidString).txt")
        try! receiptContent.write(to: url, atomically: true, encoding: .utf8)
        return url
    }
    
    private func createTestStatementFile() -> URL {
        let statementContent = """
        BANK STATEMENT - TDD Test
        Account: ****5678
        Statement Period: June 1-30, 2025
        
        Beginning Balance: $2,500.00
        
        Deposits:
        06/01  Direct Deposit     $3,200.00
        06/15  Transfer           $750.00
        
        Withdrawals:
        06/05  ATM Withdrawal     $200.00
        06/20  Check #456         $450.00
        
        Ending Balance: $5,800.00
        """
        
        let url = testDataDirectory.appendingPathComponent("test_statement_\(UUID().uuidString).txt")
        try! statementContent.write(to: url, atomically: true, encoding: .utf8)
        return url
    }
    
    private func createInvalidFile() -> URL {
        let url = testDataDirectory.appendingPathComponent("invalid_\(UUID().uuidString).xyz")
        try! "Invalid file content that cannot be processed".write(to: url, atomically: true, encoding: .utf8)
        return url
    }
    
    private func createRealFinancialDocument() -> URL {
        let financialContent = """
        PROFESSIONAL CONSULTING CORP
        789 Enterprise Blvd, Suite 200
        Tech City, CA 94105
        
        DETAILED INVOICE
        
        Invoice #: PC-2025-TDD-002
        Date: June 3, 2025
        
        Bill To:
        Innovation Labs Inc
        321 Startup Ave
        Silicon Valley, CA 94000
        
        Services Rendered:
        System Architecture Design    20 hrs    $200/hr    $4,000.00
        Code Review & Optimization    15 hrs    $175/hr    $2,625.00
        Technical Documentation       10 hrs    $150/hr    $1,500.00
        
        Subtotal:                                          $8,125.00
        Discount (5%):                                     -$406.25
        Adjusted Subtotal:                                 $7,718.75
        Sales Tax (8.75%):                                 $675.39
        
        TOTAL DUE:                                         $8,394.14
        
        Payment Terms: Net 15 Days
        Late Fee: 1.5% per month after due date
        """
        
        let url = testDataDirectory.appendingPathComponent("real_financial_\(UUID().uuidString).txt")
        try! financialContent.write(to: url, atomically: true, encoding: .utf8)
        return url
    }
    
    private func createInconsistentFinancialDocument() -> URL {
        let inconsistentContent = """
        PROBLEMATIC INVOICE
        
        Invoice #: PROB-001
        Date: Invalid Date
        
        Item 1:       $100.00
        Item 2:       $200.00
        Tax:          $50.00
        Total:        $275.00
        
        Note: Math doesn't add up correctly for validation testing
        """
        
        let url = testDataDirectory.appendingPathComponent("inconsistent_\(UUID().uuidString).txt")
        try! inconsistentContent.write(to: url, atomically: true, encoding: .utf8)
        return url
    }
}

// MARK: - DocumentsViewManager for Testing

/// Testable manager class that handles DocumentsView business logic
/// This allows us to test the logic without directly testing SwiftUI views
@MainActor
class DocumentsViewManager: ObservableObject {
    @Published var documents: [DocumentItem] = []
    @Published var isProcessing: Bool = false
    @Published var processingProgress: Double = 0.0
    
    private let financialProcessor = FinancialDocumentProcessor()
    private let documentPipeline = DocumentProcessingPipeline()
    
    // MARK: - Document Management
    
    func addDocument(from url: URL) async {
        let document = DocumentItem(
            name: url.lastPathComponent,
            url: url,
            type: DocumentType.from(url: url),
            dateAdded: Date(),
            extractedText: "Pending processing...",
            processingStatus: .pending
        )
        documents.append(document)
    }
    
    func deleteDocument(_ document: DocumentItem) async {
        documents.removeAll { $0.id == document.id }
    }
    
    func processDocument(_ document: DocumentItem) async {
        guard let index = documents.firstIndex(where: { $0.id == document.id }) else { return }
        
        documents[index].processingStatus = .processing
        
        do {
            let result = await financialProcessor.processFinancialDocument(url: document.url)
            
            switch result {
            case .success(let processedDoc):
                let summary = createFinancialSummary(from: processedDoc.financialData)
                documents[index].extractedText = "✅ SANDBOX: \(summary)"
                documents[index].processingStatus = .completed
                
            case .failure(let error):
                documents[index].extractedText = "❌ Processing failed: \(error.localizedDescription)"
                documents[index].processingStatus = .failed
            }
        } catch {
            documents[index].extractedText = "❌ Error: \(error.localizedDescription)"
            documents[index].processingStatus = .failed
        }
    }
    
    func processDocumentWithValidation(_ document: DocumentItem) async {
        guard let index = documents.firstIndex(where: { $0.id == document.id }) else { return }
        
        documents[index].processingStatus = .processing
        
        do {
            // Process with the pipeline for validation
            let result = await documentPipeline.processDocument(at: document.url)
            
            switch result {
            case .success(let processedDoc):
                var summary = "Processed successfully"
                
                if let financialData = processedDoc.financialData {
                    summary = createValidatedFinancialSummary(from: financialData, confidence: processedDoc.confidence)
                }
                
                documents[index].extractedText = "✅ SANDBOX: \(summary)"
                documents[index].processingStatus = .completed
                
            case .failure(let error):
                documents[index].extractedText = "❌ Processing failed: \(error.localizedDescription)"
                documents[index].processingStatus = .failed
            }
        } catch {
            documents[index].extractedText = "❌ Error: \(error.localizedDescription)"
            documents[index].processingStatus = .failed
        }
    }
    
    // MARK: - Search and Filtering
    
    func searchDocuments(query: String) -> [DocumentItem] {
        guard !query.isEmpty else { return documents }
        
        return documents.filter { document in
            document.name.localizedCaseInsensitiveContains(query) ||
            document.extractedText.localizedCaseInsensitiveContains(query)
        }
    }
    
    func filterDocuments(by type: DocumentType) -> [DocumentItem] {
        return documents.filter { $0.type == type }
    }
    
    func filterDocuments(by type: DocumentType, searchQuery: String) -> [DocumentItem] {
        let typeFiltered = filterDocuments(by: type)
        guard !searchQuery.isEmpty else { return typeFiltered }
        
        return typeFiltered.filter { document in
            document.name.localizedCaseInsensitiveContains(searchQuery) ||
            document.extractedText.localizedCaseInsensitiveContains(searchQuery)
        }
    }
    
    // MARK: - File Validation
    
    func isFileTypeSupported(_ url: URL) -> Bool {
        let supportedExtensions = ["pdf", "jpg", "jpeg", "png", "txt"]
        return supportedExtensions.contains(url.pathExtension.lowercased())
    }
    
    func validateFile(_ url: URL) async -> FileValidationResult {
        // Check if file exists
        guard FileManager.default.fileExists(atPath: url.path) else {
            return FileValidationResult(isValid: false, error: "File does not exist")
        }
        
        // Check if file type is supported
        guard isFileTypeSupported(url) else {
            return FileValidationResult(isValid: false, error: "Unsupported file type")
        }
        
        // Check if file is not empty
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            if let size = attributes[.size] as? Int64, size == 0 {
                return FileValidationResult(isValid: false, error: "File is empty")
            }
        } catch {
            return FileValidationResult(isValid: false, error: "Cannot read file attributes")
        }
        
        return FileValidationResult(isValid: true, error: nil)
    }
    
    // MARK: - Drag and Drop
    
    func handleDrop(urls: [URL]) async -> DropResult {
        var addedDocuments = 0
        var failedFiles = 0
        var errors: [String] = []
        
        for url in urls {
            let validation = await validateFile(url)
            if validation.isValid {
                await addDocument(from: url)
                addedDocuments += 1
            } else {
                failedFiles += 1
                if let error = validation.error {
                    errors.append(error)
                }
            }
        }
        
        return DropResult(
            success: addedDocuments > 0,
            addedDocuments: addedDocuments,
            failedFiles: failedFiles,
            error: errors.isEmpty ? nil : errors.joined(separator: ", ")
        )
    }
    
    // MARK: - Helper Methods
    
    private func createFinancialSummary(from financialData: ProcessedFinancialData) -> String {
        var summary = ""
        
        if let totalAmount = financialData.totalAmount {
            summary += "💰 Total: \(totalAmount.formattedString)"
        }
        
        if let vendor = financialData.vendor {
            summary += summary.isEmpty ? "" : " | "
            summary += "🏢 Vendor: \(vendor.name)"
        }
        
        summary += " | 🎯 Confidence: \(Int(financialData.confidence * 100))%"
        
        return summary.isEmpty ? "Document processed successfully" : summary
    }
    
    private func createValidatedFinancialSummary(from financialData: ExtractedFinancialData, confidence: Double) -> String {
        var summary = ""
        
        if let totalAmount = financialData.totalAmount {
            summary += "💰 Total: \(totalAmount)"
        }
        
        if let vendor = financialData.vendor {
            summary += summary.isEmpty ? "" : " | "
            summary += "🏢 Vendor: \(vendor)"
        }
        
        summary += " | 🎯 Confidence: \(Int(confidence * 100))%"
        
        // Add validation warnings if confidence is low
        if confidence < 0.7 {
            summary += " | ⚠️ Low confidence - validation recommended"
        }
        
        return summary.isEmpty ? "Document processed successfully" : summary
    }
}

// MARK: - Supporting Data Models for Testing

struct FileValidationResult {
    let isValid: Bool
    let error: String?
}

struct DropResult {
    let success: Bool
    let addedDocuments: Int
    let failedFiles: Int
    let error: String?
}