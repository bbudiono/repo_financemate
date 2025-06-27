//
//  DocumentFileProcessingServiceTests.swift
//  FinanceMateTests
//
//  Created by Assistant on 6/27/25.
//

import XCTest
import CoreData
import SwiftUI
@testable import FinanceMate

@MainActor
final class DocumentFileProcessingServiceTests: XCTestCase {
    
    var processingService: DocumentFileProcessingService!
    var testContext: NSManagedObjectContext!
    var coreDataStack: CoreDataStack!
    
    override func setUp() {
        super.setUp()
        
        // Set up in-memory Core Data stack for testing
        coreDataStack = CoreDataStack.shared
        testContext = coreDataStack.newBackgroundContext()
        processingService = DocumentFileProcessingService(context: testContext)
    }
    
    override func tearDown() {
        processingService = nil
        testContext = nil
        super.tearDown()
    }
    
    // MARK: - Service Initialization Tests
    
    func testServiceInitialization() {
        XCTAssertNotNil(processingService)
    }
    
    // MARK: - Document Type Detection Tests
    
    func testDocumentTypeDetection() {
        let testCases: [(filename: String, expectedType: UIDocumentType)] = [
            ("invoice_2025.pdf", .invoice),
            ("receipt_grocery.jpg", .receipt),
            ("bank_statement.pdf", .statement),
            ("contract_lease.pdf", .contract),
            ("random_document.pdf", .other)
        ]
        
        for testCase in testCases {
            let document = Document(context: testContext)
            document.fileName = testCase.filename
            
            let detectedType = DocumentFileProcessingService.getDocumentType(document)
            XCTAssertEqual(detectedType, testCase.expectedType, 
                          "Failed for filename: \(testCase.filename)")
        }
    }
    
    func testDocumentTypeDetectionWithNilFilename() {
        let document = Document(context: testContext)
        document.fileName = nil
        
        let detectedType = DocumentFileProcessingService.getDocumentType(document)
        XCTAssertEqual(detectedType, .other)
    }
    
    // MARK: - Processing Status Tests
    
    func testProcessingStatusDetection() {
        let testCases: [(status: String?, expectedUIStatus: UIProcessingStatus)] = [
            ("processing", .processing),
            ("completed", .completed),
            ("error", .error),
            (nil, .pending),
            ("unknown", .pending)
        ]
        
        for testCase in testCases {
            let document = Document(context: testContext)
            document.processingStatus = testCase.status
            
            let detectedStatus = DocumentFileProcessingService.getProcessingStatus(document)
            XCTAssertEqual(detectedStatus, testCase.expectedUIStatus,
                          "Failed for status: \(testCase.status ?? "nil")")
        }
    }
    
    // MARK: - File Processing Tests
    
    func testProcessSingleTextDocument() async throws {
        // Create a temporary text file
        let testContent = "Test financial document\nAmount: $1,234.56"
        let tempURL = createTempFile(content: testContent, extension: "txt")
        
        defer { cleanup(url: tempURL) }
        
        do {
            try await processingService.processDocumentWithErrorHandling(url: tempURL)
            
            // Verify document was created in Core Data
            let fetchRequest: NSFetchRequest<Document> = Document.fetchRequest()
            let documents = try testContext.fetch(fetchRequest)
            
            XCTAssertEqual(documents.count, 1)
            
            let document = documents.first!
            XCTAssertEqual(document.fileName, tempURL.lastPathComponent)
            XCTAssertEqual(document.filePath, tempURL.path)
            XCTAssertEqual(document.mimeType, "text/plain")
            XCTAssertNotNil(document.dateCreated)
        } catch {
            XCTFail("Document processing failed: \(error)")
        }
    }
    
    func testProcessNonExistentFile() async {
        let nonExistentURL = URL(fileURLWithPath: "/tmp/nonexistent_\(UUID().uuidString).txt")
        
        do {
            try await processingService.processDocumentWithErrorHandling(url: nonExistentURL)
            XCTFail("Should throw file access error")
        } catch let error as DocumentError {
            switch error {
            case .fileAccessError:
                break // Expected error
            default:
                XCTFail("Wrong error type: \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testProcessMultipleDocuments() async throws {
        // Create multiple test files
        let testFiles = [
            createTempFile(content: "Document 1", extension: "txt"),
            createTempFile(content: "Document 2", extension: "txt")
        ]
        
        defer {
            testFiles.forEach { cleanup(url: $0) }
        }
        
        let result = await processingService.processDocuments(urls: testFiles)
        
        XCTAssertEqual(result.successCount, 2)
        XCTAssertEqual(result.errorCount, 0)
        
        // Verify documents were created
        let fetchRequest: NSFetchRequest<Document> = Document.fetchRequest()
        let documents = try testContext.fetch(fetchRequest)
        
        XCTAssertEqual(documents.count, 2)
    }
    
    func testProcessMixedSuccessAndFailure() async throws {
        // Create one valid file and one non-existent file reference
        let validFile = createTempFile(content: "Valid document", extension: "txt")
        let invalidFile = URL(fileURLWithPath: "/tmp/nonexistent_\(UUID().uuidString).txt")
        
        defer { cleanup(url: validFile) }
        
        let result = await processingService.processDocuments(urls: [validFile, invalidFile])
        
        XCTAssertEqual(result.successCount, 1)
        XCTAssertEqual(result.errorCount, 1)
    }
    
    // MARK: - MIME Type Detection Tests
    
    func testMimeTypeDetection() {
        let testCases: [(extension: String, expectedMimeType: String)] = [
            ("pdf", "application/pdf"),
            ("jpg", "image/jpeg"),
            ("jpeg", "image/jpeg"),
            ("png", "image/png"),
            ("txt", "text/plain"),
            ("tiff", "image/tiff"),
            ("heic", "image/heic"),
            ("unknown", "application/octet-stream")
        ]
        
        for testCase in testCases {
            let tempFile = createTempFile(content: "test", extension: testCase.extension)
            defer { cleanup(url: tempFile) }
            
            Task {
                do {
                    try await processingService.processDocumentWithErrorHandling(url: tempFile)
                    
                    let fetchRequest: NSFetchRequest<Document> = Document.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "fileName == %@", tempFile.lastPathComponent)
                    
                    let documents = try testContext.fetch(fetchRequest)
                    XCTAssertEqual(documents.count, 1)
                    
                    let document = documents.first!
                    XCTAssertEqual(document.mimeType, testCase.expectedMimeType,
                                  "Failed for extension: \(testCase.extension)")
                } catch {
                    XCTFail("Processing failed for \(testCase.extension): \(error)")
                }
            }
        }
    }
    
    // MARK: - Error Handling Tests
    
    func testDocumentErrorTypes() {
        let errors: [DocumentError] = [
            .saveError("Test save error"),
            .ocrError("Test OCR error"),
            .fileAccessError("Test file access error"),
            .invalidFileType("Test invalid type")
        ]
        
        for error in errors {
            XCTAssertNotNil(error.errorDescription)
            XCTAssertFalse(error.errorDescription!.isEmpty)
        }
    }
    
    // MARK: - Performance Tests
    
    func testBulkDocumentProcessingPerformance() throws {
        // Create multiple test files for performance testing
        let fileCount = 10
        let testFiles = (0..<fileCount).map { index in
            createTempFile(content: "Performance test document \(index)", extension: "txt")
        }
        
        defer {
            testFiles.forEach { cleanup(url: $0) }
        }
        
        measure {
            let expectation = XCTestExpectation(description: "Bulk processing")
            
            Task {
                let result = await processingService.processDocuments(urls: testFiles)
                XCTAssertEqual(result.successCount, fileCount)
                XCTAssertEqual(result.errorCount, 0)
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 10.0)
        }
    }
    
    // MARK: - Integration Tests
    
    func testEndToEndDocumentProcessing() async throws {
        // Test complete workflow from file creation to Core Data storage
        let testDocument = "Invoice #12345\nAmount: $999.99\nDate: 2025-06-27"
        let tempURL = createTempFile(content: testDocument, extension: "txt")
        
        defer { cleanup(url: tempURL) }
        
        // Process the document
        try await processingService.processDocumentWithErrorHandling(url: tempURL)
        
        // Verify document in Core Data
        let fetchRequest: NSFetchRequest<Document> = Document.fetchRequest()
        let documents = try testContext.fetch(fetchRequest)
        
        XCTAssertEqual(documents.count, 1)
        
        let document = documents.first!
        XCTAssertEqual(document.fileName, tempURL.lastPathComponent)
        XCTAssertEqual(document.filePath, tempURL.path)
        XCTAssertEqual(document.mimeType, "text/plain")
        XCTAssertNotNil(document.dateCreated)
        XCTAssertTrue(document.fileSize > 0)
        
        // Verify OCR processing (should complete for text files)
        let expectation = XCTestExpectation(description: "OCR completion")
        
        // Wait for OCR processing to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            do {
                try self.testContext.refresh(document, mergeChanges: true)
                XCTAssertNotEqual(document.rawOCRText, "Processing...")
                expectation.fulfill()
            } catch {
                XCTFail("Failed to refresh document: \(error)")
            }
        }
        
        await fulfillment(of: [expectation], timeout: 5.0)
    }
    
    // MARK: - Snapshot Tests
    
    func testDocumentProcessingSnapshot() async throws {
        let testContent = "Snapshot test document"
        let tempURL = createTempFile(content: testContent, extension: "txt")
        
        defer { cleanup(url: tempURL) }
        
        // Take snapshot before processing
        let initialCount = try testContext.count(for: Document.fetchRequest())
        
        // Process document
        try await processingService.processDocumentWithErrorHandling(url: tempURL)
        
        // Take snapshot after processing
        let finalCount = try testContext.count(for: Document.fetchRequest())
        
        XCTAssertEqual(finalCount, initialCount + 1)
    }
}

// MARK: - Test Utilities

extension DocumentFileProcessingServiceTests {
    
    private func createTempFile(content: String, extension ext: String) -> URL {
        let tempURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("test_\(UUID().uuidString).\(ext)")
        
        do {
            try content.write(to: tempURL, atomically: true, encoding: .utf8)
            return tempURL
        } catch {
            XCTFail("Failed to create temp file: \(error)")
            fatalError()
        }
    }
    
    private func cleanup(url: URL) {
        try? FileManager.default.removeItem(at: url)
    }
}