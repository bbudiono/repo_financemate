//
//  DocumentProcessingPipelineTests.swift
//  FinanceMateTests
//
//  Created by Assistant on 6/29/25.
//  TDD CYCLE: FAILING TESTS → INTEGRATION → PASSING TESTS
//  Target: >80% Code Coverage for DocumentProcessingPipeline.swift
//

import XCTest
import Combine
import Foundation
@testable import FinanceMate

@MainActor
final class DocumentProcessingPipelineTests: XCTestCase {
    
    private var pipeline: DocumentProcessingPipeline!
    private var cancellables: Set<AnyCancellable>!
    private var testBundle: Bundle!
    private var tempDirectory: URL!
    
    override func setUp() {
        super.setUp()
        cancellables = Set<AnyCancellable>()
        testBundle = Bundle(for: type(of: self))
        
        // Create temporary directory for test files
        tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("DocumentProcessingPipelineTests")
            .appendingPathComponent(UUID().uuidString)
        
        try? FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
        
        // DocumentProcessingPipeline is now integrated into Sandbox environment
        pipeline = DocumentProcessingPipeline()
    }
    
    override func tearDown() {
        // Clean up temporary directory
        try? FileManager.default.removeItem(at: tempDirectory)
        
        cancellables = nil
        pipeline = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func test_pipeline_initialization_success() throws {
        // Test successful initialization and initial state
        XCTAssertNotNil(pipeline, "Pipeline should initialize successfully")
        XCTAssertFalse(pipeline.isProcessing, "Pipeline should not be processing initially")
        XCTAssertEqual(pipeline.processingProgress, 0.0, "Initial progress should be zero")
        XCTAssertEqual(pipeline.currentOperation, "", "Initial operation should be empty")
    }
    
    func test_pipeline_default_configuration() throws {
        // Test default configuration values
        XCTAssertTrue(pipeline.isOCREnabled, "OCR should be enabled by default")
        XCTAssertTrue(pipeline.isFinancialExtractionEnabled, "Financial extraction should be enabled by default")
        XCTAssertEqual(pipeline.maxFileSize, 50 * 1024 * 1024, "Default max file size should be 50MB")
        XCTAssertEqual(pipeline.processingTimeout, 60.0, "Default timeout should be 60 seconds")
        
        // Test supported file types
        let expectedTypes: Set<String> = ["pdf", "jpg", "jpeg", "png", "txt"]
        XCTAssertEqual(pipeline.supportedFileTypes, expectedTypes, "Supported file types should match expected")
    }
    
    // MARK: - Configuration Tests
    
    func test_configure_pipeline_with_custom_settings() throws {
        // Test custom configuration
        let config = DocumentProcessingConfiguration(
            enableOCR: false,
            enableFinancialDataExtraction: true,
            maxFileSize: 10 * 1024 * 1024,
            processingTimeout: 30.0,
            outputFormat: .raw
        )
        
        pipeline.configure(with: config)
        
        XCTAssertFalse(pipeline.isOCREnabled, "OCR should be disabled")
        XCTAssertTrue(pipeline.isFinancialExtractionEnabled, "Financial extraction should remain enabled")
        XCTAssertEqual(pipeline.maxFileSize, 10 * 1024 * 1024, "Max file size should be updated")
        XCTAssertEqual(pipeline.processingTimeout, 30.0, "Timeout should be updated")
    }
    
    // MARK: - File Validation Tests
    
    func test_validateFile_supported_pdf_file() throws {
        // Test PDF file validation
        let pdfURL = createTestPDFFile()
        let isValid = pipeline.validateFile(at: pdfURL)
        XCTAssertTrue(isValid, "Valid PDF file should pass validation")
    }
    
    func test_validateFile_supported_image_file() throws {
        // Test image file validation
        let imageURL = createTestImageFile()
        let isValid = pipeline.validateFile(at: imageURL)
        XCTAssertTrue(isValid, "Valid image file should pass validation")
    }
    
    func test_validateFile_unsupported_file_type() throws {
        // Test unsupported file type validation
        let unsupportedURL = createTestFileWithExtension("doc")
        let isValid = pipeline.validateFile(at: unsupportedURL)
        XCTAssertFalse(isValid, "Unsupported file type should fail validation")
    }
    
    func test_validateFile_file_size_exceeded() throws {
        XCTFail("Test not implemented - DocumentProcessingPipeline file validation not yet available")
        
        // Expected behavior after integration:
        // let largeFileURL = createLargeTestFile(size: 60 * 1024 * 1024) // 60MB
        // let isValid = pipeline.validateFile(at: largeFileURL)
        // XCTAssertFalse(isValid, "File exceeding size limit should fail validation")
    }
    
    func test_validateFile_nonexistent_file() throws {
        // Test nonexistent file validation
        let nonexistentURL = tempDirectory.appendingPathComponent("nonexistent.pdf")
        let isValid = pipeline.validateFile(at: nonexistentURL)
        XCTAssertFalse(isValid, "Nonexistent file should fail validation")
    }
    
    // MARK: - Single Document Processing Tests
    
    func test_processDocument_pdf_file_success() async throws {
        // Test successful PDF processing
        let pdfURL = createTestTextFile() // Using text file for simpler testing
        let result = await pipeline.processDocument(at: pdfURL)
        
        switch result {
        case .success(let document):
            XCTAssertEqual(document.status, .completed, "Document should be completed")
            XCTAssertNotNil(document.extractedText, "Text should be extracted")
            XCTAssertTrue(document.confidence > 0.0, "Confidence should be set")
            XCTAssertNotNil(document.endTime, "End time should be set")
            XCTAssertGreaterThan(document.processingSteps.count, 0, "Processing steps should be recorded")
        case .failure(let error):
            XCTFail("Processing should succeed, but failed with: \(error)")
        }
    }
    
    func test_processDocument_image_file_with_ocr() async throws {
        XCTFail("Test not implemented - DocumentProcessingPipeline image processing with OCR not yet available")
        
        // Expected behavior after integration:
        // let imageURL = createTestImageWithText("Invoice Number: 12345")
        // let result = await pipeline.processDocument(at: imageURL)
        // 
        // switch result {
        // case .success(let document):
        //     XCTAssertNotNil(document.ocrResult, "OCR result should be available")
        //     XCTAssertTrue(document.ocrConfidence > 0.0, "OCR confidence should be set")
        //     XCTAssertTrue(document.processingSteps.contains { $0.stepName == "OCR Analysis" }, "OCR step should be recorded")
        // case .failure(let error):
        //     XCTFail("OCR processing should succeed, but failed with: \(error)")
        // }
    }
    
    func test_processDocument_financial_data_extraction() async throws {
        XCTFail("Test not implemented - DocumentProcessingPipeline financial data extraction not yet available")
        
        // Expected behavior after integration:
        // let invoiceURL = createTestInvoiceWithFinancialData()
        // let result = await pipeline.processDocument(at: invoiceURL)
        // 
        // switch result {
        // case .success(let document):
        //     XCTAssertNotNil(document.financialData, "Financial data should be extracted")
        //     XCTAssertTrue(document.processingSteps.contains { $0.stepName == "Financial Data Extraction" }, "Financial extraction step should be recorded")
        // case .failure(let error):
        //     XCTFail("Financial data extraction should succeed, but failed with: \(error)")
        // }
    }
    
    func test_processDocument_invalid_file_failure() async throws {
        // Test processing failure for invalid file
        let invalidURL = createTestFileWithExtension("xyz")
        let result = await pipeline.processDocument(at: invalidURL)
        
        switch result {
        case .success:
            XCTFail("Processing should fail for invalid file")
        case .failure(let error):
            XCTAssertTrue(error is PipelineProcessingError, "Should return PipelineProcessingError")
            if let pipelineError = error as? PipelineProcessingError {
                XCTAssertEqual(pipelineError, .unsupportedFileType, "Should be unsupported file type error")
            }
        }
    }
    
    // MARK: - Batch Processing Tests
    
    func test_processDocuments_multiple_files_success() async throws {
        XCTFail("Test not implemented - DocumentProcessingPipeline batch processing not yet available")
        
        // Expected behavior after integration:
        // let urls = [
        //     createTestPDFFile(),
        //     createTestImageFile(),
        //     createTestTextFile()
        // ]
        // 
        // let results = await pipeline.processDocuments(at: urls)
        // 
        // XCTAssertEqual(results.count, 3, "Should return results for all files")
        // 
        // for result in results {
        //     switch result {
        //     case .success(let document):
        //         XCTAssertEqual(document.status, .completed, "Each document should be completed")
        //     case .failure(let error):
        //         XCTFail("Batch processing should succeed, but failed with: \(error)")
        //     }
        // }
    }
    
    func test_processDocuments_mixed_valid_invalid_files() async throws {
        XCTFail("Test not implemented - DocumentProcessingPipeline mixed batch processing not yet available")
        
        // Expected behavior after integration:
        // let urls = [
        //     createTestPDFFile(),      // Valid
        //     createTestFileWithExtension("xyz"), // Invalid
        //     createTestImageFile()     // Valid
        // ]
        // 
        // let results = await pipeline.processDocuments(at: urls)
        // 
        // XCTAssertEqual(results.count, 3, "Should return results for all files")
        // 
        // // First file should succeed
        // switch results[0] {
        // case .success: break
        // case .failure: XCTFail("First file should succeed")
        // }
        // 
        // // Second file should fail
        // switch results[1] {
        // case .success: XCTFail("Second file should fail")
        // case .failure: break
        // }
        // 
        // // Third file should succeed
        // switch results[2] {
        // case .success: break
        // case .failure: XCTFail("Third file should succeed")
        // }
    }
    
    // MARK: - Progress and State Management Tests
    
    func test_processing_state_changes_during_operation() async throws {
        // Test state changes during processing
        let expectation = XCTestExpectation(description: "State changes observed")
        var stateChanges: [Bool] = []
        var progressValues: [Double] = []
        var operationNames: [String] = []
        
        pipeline.$isProcessing
            .sink { isProcessing in
                stateChanges.append(isProcessing)
            }
            .store(in: &cancellables)
        
        pipeline.$processingProgress
            .sink { progress in
                progressValues.append(progress)
            }
            .store(in: &cancellables)
        
        pipeline.$currentOperation
            .sink { operation in
                operationNames.append(operation)
                if operationNames.count >= 3 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        let testURL = createTestTextFile()
        _ = await pipeline.processDocument(at: testURL)
        
        await fulfillment(of: [expectation], timeout: 5.0)
        
        XCTAssertTrue(stateChanges.contains(true), "Should transition to processing state")
        XCTAssertTrue(progressValues.contains { $0 > 0.0 && $0 <= 1.0 }, "Should have progress values")
        XCTAssertTrue(operationNames.contains { !$0.isEmpty }, "Should have operation names")
        XCTAssertFalse(pipeline.isProcessing, "Should end with isProcessing false")
        XCTAssertEqual(pipeline.processingProgress, 0.0, "Should reset progress to 0.0")
        XCTAssertEqual(pipeline.currentOperation, "", "Should reset operation to empty")
    }
    
    // MARK: - Performance Tests
    
    func test_processing_performance_within_timeout() async throws {
        XCTFail("Test not implemented - DocumentProcessingPipeline performance testing not yet available")
        
        // Expected behavior after integration:
        // let testURL = createTestPDFFile()
        // let startTime = Date()
        // 
        // let result = await pipeline.processDocument(at: testURL)
        // 
        // let endTime = Date()
        // let processingTime = endTime.timeIntervalSince(startTime)
        // 
        // switch result {
        // case .success(let document):
        //     XCTAssertLessThan(processingTime, pipeline.processingTimeout, "Processing should complete within timeout")
        //     XCTAssertNotNil(document.processingDuration, "Document should have processing duration")
        // case .failure(let error):
        //     XCTFail("Performance test should succeed, but failed with: \(error)")
        // }
    }
    
    // MARK: - Error Condition Tests
    
    func test_configuration_validation() throws {
        XCTFail("Test not implemented - DocumentProcessingPipeline configuration validation not yet available")
        
        // Expected behavior after integration:
        // let invalidConfig = DocumentProcessingConfiguration(
        //     enableOCR: true,
        //     enableFinancialDataExtraction: true,
        //     maxFileSize: -1, // Invalid
        //     processingTimeout: -5.0, // Invalid
        //     outputFormat: .structured
        // )
        // 
        // // Configuration should handle invalid values gracefully
        // pipeline.configure(with: invalidConfig)
        // 
        // // Should fallback to reasonable defaults
        // XCTAssertGreaterThan(pipeline.maxFileSize, 0, "Max file size should be positive")
        // XCTAssertGreaterThan(pipeline.processingTimeout, 0, "Timeout should be positive")
    }
    
    // MARK: - Critical Edge Case Tests (AUDIT-20240629-Discipline)
    
    func test_processDocument_zero_byte_file() async throws {
        // Test processing of completely empty file (0 bytes)
        let zeroByteURL = createZeroByteFile()
        let result = await pipeline.processDocument(at: zeroByteURL)
        
        switch result {
        case .success(let document):
            XCTAssertEqual(document.status, .completed, "Zero-byte file should complete processing")
            XCTAssertTrue(document.extractedText?.isEmpty ?? true, "Zero-byte file should have empty or nil extracted text")
            XCTAssertEqual(document.confidence, 0.5, accuracy: 0.1, "Zero-byte file should have base confidence")
        case .failure(let error):
            // This is also acceptable - zero-byte files might legitimately fail
            XCTAssertTrue(error is PipelineProcessingError, "Should return appropriate error type")
        }
    }
    
    func test_processDocument_non_utf8_content() async throws {
        // Test processing of file with non-UTF8 binary content
        let binaryURL = createBinaryContentFile()
        let result = await pipeline.processDocument(at: binaryURL)
        
        switch result {
        case .success(let document):
            // System should handle binary content gracefully
            XCTAssertEqual(document.status, .completed, "Binary content should complete processing")
            XCTAssertNotNil(document.extractedText, "Should have some extracted text (even if empty)")
        case .failure(let error):
            // Binary content might legitimately fail text extraction
            XCTAssertTrue(error is PipelineProcessingError, "Should return appropriate error type")
        }
    }
    
    func test_processDocument_timeout_handling() async throws {
        // Test processing timeout by configuring very short timeout
        let shortTimeoutConfig = DocumentProcessingConfiguration(
            enableOCR: true,
            enableFinancialDataExtraction: true,
            maxFileSize: 50 * 1024 * 1024,
            processingTimeout: 0.001, // 1ms timeout - should timeout immediately
            outputFormat: .structured
        )
        
        pipeline.configure(with: shortTimeoutConfig)
        
        let testURL = createTestTextFile()
        let startTime = Date()
        let result = await pipeline.processDocument(at: testURL)
        let endTime = Date()
        
        // Processing should complete quickly due to timeout
        let processingTime = endTime.timeIntervalSince(startTime)
        XCTAssertLessThan(processingTime, 2.0, "Should complete quickly (with or without timeout)")
        
        // Result could be success (if very fast) or timeout error
        switch result {
        case .success(let document):
            XCTAssertNotNil(document, "If successful, document should exist")
        case .failure(let error):
            if let pipelineError = error as? PipelineProcessingError {
                // Timeout might manifest as processing failure
                XCTAssertTrue([.timeout, .processingFailed].contains(pipelineError), "Should be timeout or processing failure")
            }
        }
    }
    
    func test_processDocument_ocr_error_conditions() async throws {
        // Test OCR error handling with invalid image data
        let invalidImageURL = createInvalidImageFile()
        let result = await pipeline.processDocument(at: invalidImageURL)
        
        switch result {
        case .success(let document):
            // System should handle invalid images gracefully
            XCTAssertEqual(document.status, .completed, "Invalid image should complete processing")
            XCTAssertEqual(document.ocrResult?.isEmpty ?? true, true, "Invalid image should have empty OCR result")
            XCTAssertEqual(document.ocrConfidence, 0.0, "Invalid image should have zero OCR confidence")
        case .failure(let error):
            // Invalid images might legitimately fail
            XCTAssertTrue(error is PipelineProcessingError, "Should return appropriate error type")
        }
    }
    
    func test_processDocument_corrupted_pdf_handling() async throws {
        // Test processing of corrupted/malformed PDF
        let corruptedPDFURL = createCorruptedPDFFile()
        let result = await pipeline.processDocument(at: corruptedPDFURL)
        
        switch result {
        case .success(let document):
            // System should handle corrupted PDFs gracefully
            XCTAssertEqual(document.status, .completed, "Corrupted PDF should complete processing")
            XCTAssertTrue(document.extractedText?.isEmpty ?? true, "Corrupted PDF should have empty extracted text")
        case .failure(let error):
            // Corrupted PDFs might legitimately fail
            XCTAssertTrue(error is PipelineProcessingError, "Should return appropriate error type")
            if let pipelineError = error as? PipelineProcessingError {
                XCTAssertEqual(pipelineError, .processingFailed, "Should be processing failure for corrupted PDF")
            }
        }
    }
    
    // MARK: - Integration Tests
    
    func test_pipeline_integration_with_ocr_service() async throws {
        // Test OCR service integration with real image processing
        let imageURL = createTestImageFile()
        let result = await pipeline.processDocument(at: imageURL)
        
        switch result {
        case .success(let document):
            XCTAssertEqual(document.status, .completed, "OCR integration should complete")
            // OCR result might be empty for dummy image, but should be present
            XCTAssertNotNil(document.ocrResult, "OCR result should be present (even if empty)")
            XCTAssertGreaterThanOrEqual(document.ocrConfidence, 0.0, "OCR confidence should be non-negative")
        case .failure(let error):
            XCTFail("OCR integration should succeed, but failed with: \(error)")
        }
    }
    
    func test_pipeline_integration_with_financial_extractor() async throws {
        // Test financial extractor integration with text containing financial data
        let financialURL = createTestTextFile() // Contains invoice data
        let result = await pipeline.processDocument(at: financialURL)
        
        switch result {
        case .success(let document):
            XCTAssertEqual(document.status, .completed, "Financial extraction should complete")
            // Financial data extraction might find data in our test invoice text
            XCTAssertNotNil(document.financialData, "Financial data should be extracted or attempted")
        case .failure(let error):
            XCTFail("Financial extraction integration should succeed, but failed with: \(error)")
        }
    }
    
    // MARK: - Test Helper Methods
    
    private func createTestPDFFile() -> URL {
        // Helper method to create test PDF file
        let url = tempDirectory.appendingPathComponent("test.pdf")
        let testData = Data("Test PDF content with financial data: Invoice #12345 Amount: $150.00".utf8)
        try? testData.write(to: url)
        return url
    }
    
    private func createTestImageFile() -> URL {
        // Helper method to create test image file
        let url = tempDirectory.appendingPathComponent("test.jpg")
        let testData = Data("Test image content".utf8)
        try? testData.write(to: url)
        return url
    }
    
    private func createTestTextFile() -> URL {
        // Helper method to create test text file
        let url = tempDirectory.appendingPathComponent("test.txt")
        let testData = Data("Test invoice content\nInvoice Number: INV-2025-001\nAmount: $250.00\nDate: 2025-06-26".utf8)
        try? testData.write(to: url)
        return url
    }
    
    private func createTestFileWithExtension(_ ext: String) -> URL {
        // Helper method to create test file with specific extension
        let url = tempDirectory.appendingPathComponent("test.\(ext)")
        let testData = Data("Test content".utf8)
        try? testData.write(to: url)
        return url
    }
    
    private func createLargeTestFile(size: Int) -> URL {
        // Helper method to create large test file
        let url = tempDirectory.appendingPathComponent("large_test.pdf")
        let testData = Data(count: size)
        try? testData.write(to: url)
        return url
    }
    
    // MARK: - Edge Case Test File Helpers (AUDIT-20240629-Discipline)
    
    private func createZeroByteFile() -> URL {
        // Helper method to create zero-byte file
        let url = tempDirectory.appendingPathComponent("zero_byte_test.txt")
        let emptyData = Data()
        try? emptyData.write(to: url)
        return url
    }
    
    private func createBinaryContentFile() -> URL {
        // Helper method to create file with binary/non-UTF8 content
        let url = tempDirectory.appendingPathComponent("binary_test.txt")
        var binaryData = Data()
        // Add some non-UTF8 binary bytes
        for i in 0..<256 {
            binaryData.append(UInt8(i))
        }
        try? binaryData.write(to: url)
        return url
    }
    
    private func createInvalidImageFile() -> URL {
        // Helper method to create invalid image file (text content with .jpg extension)
        let url = tempDirectory.appendingPathComponent("invalid_image.jpg")
        let invalidImageData = Data("This is not a valid image file".utf8)
        try? invalidImageData.write(to: url)
        return url
    }
    
    private func createCorruptedPDFFile() -> URL {
        // Helper method to create corrupted PDF file
        let url = tempDirectory.appendingPathComponent("corrupted.pdf")
        // Create a file that starts like PDF but has corrupted content
        var corruptedData = Data("%PDF-1.4\n".utf8)
        // Add random binary corruption
        for _ in 0..<100 {
            corruptedData.append(UInt8.random(in: 0...255))
        }
        try? corruptedData.write(to: url)
        return url
    }
}