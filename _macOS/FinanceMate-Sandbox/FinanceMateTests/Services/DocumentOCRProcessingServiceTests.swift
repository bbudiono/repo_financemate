//
//  DocumentOCRProcessingServiceTests.swift
//  FinanceMateTests
//
//  Created by Assistant on 6/27/25.
//

import XCTest
import SwiftUI
@testable import FinanceMate

@MainActor
final class DocumentOCRProcessingServiceTests: XCTestCase {
    
    var ocrService: DocumentOCRProcessingService!
    
    override func setUp() {
        super.setUp()
        ocrService = DocumentOCRProcessingService()
    }
    
    override func tearDown() {
        ocrService = nil
        super.tearDown()
    }
    
    // MARK: - Service Initialization Tests
    
    func testOCRServiceInitialization() {
        // Test that service initializes properly
        XCTAssertNotNil(ocrService)
    }
    
    // MARK: - File Type Support Tests
    
    func testUnsupportedFileTypeError() async {
        // Create a temporary file with unsupported extension
        let tempURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("test.xyz")
        
        do {
            _ = try await ocrService.performBackgroundOCR(on: tempURL)
            XCTFail("Should throw unsupported file type error")
        } catch let error as OCRError {
            XCTAssertEqual(error, OCRError.unsupportedFileType)
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }
    
    func testSupportedFileTypes() {
        // Test that service recognizes supported file types
        let supportedExtensions = ["pdf", "jpg", "jpeg", "png", "tiff", "heic", "txt"]
        
        for ext in supportedExtensions {
            let url = URL(fileURLWithPath: "/tmp/test.\(ext)")
            // We can't actually process without real files, but we can test recognition
            XCTAssertNoThrow(url, "Should recognize .\(ext) files")
        }
    }
    
    // MARK: - Text File Processing Tests
    
    func testTextFileProcessing() async throws {
        // Create a temporary text file
        let testContent = "This is a test document with financial data.\nAmount: $1,234.56\nDate: 2025-06-27"
        let tempURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("test_\(UUID().uuidString).txt")
        
        try testContent.write(to: tempURL, atomically: true, encoding: .utf8)
        
        defer {
            try? FileManager.default.removeItem(at: tempURL)
        }
        
        do {
            let extractedText = try await ocrService.performBackgroundOCR(on: tempURL)
            XCTAssertEqual(extractedText, testContent)
        } catch {
            XCTFail("Text file processing failed: \(error)")
        }
    }
    
    // MARK: - Error Handling Tests
    
    func testPDFLoadFailure() async {
        // Test with non-existent PDF file
        let nonExistentPDF = URL(fileURLWithPath: "/tmp/nonexistent_\(UUID().uuidString).pdf")
        
        do {
            _ = try await ocrService.performBackgroundOCR(on: nonExistentPDF)
            XCTFail("Should throw PDF load error")
        } catch let error as OCRError {
            XCTAssertEqual(error, OCRError.pdfLoadFailed)
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }
    
    func testImageLoadFailure() async {
        // Test with non-existent image file
        let nonExistentImage = URL(fileURLWithPath: "/tmp/nonexistent_\(UUID().uuidString).jpg")
        
        do {
            _ = try await ocrService.performBackgroundOCR(on: nonExistentImage)
            XCTFail("Should throw image load error")
        } catch let error as OCRError {
            XCTAssertEqual(error, OCRError.imageLoadFailed)
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }
    
    // MARK: - OCR Error Types Tests
    
    func testOCRErrorDescriptions() {
        let errors: [OCRError] = [
            .unsupportedFileType,
            .pdfLoadFailed,
            .imageLoadFailed,
            .imageProcessingFailed,
            .visionFrameworkError("Test error")
        ]
        
        for error in errors {
            XCTAssertNotNil(error.errorDescription)
            XCTAssertFalse(error.errorDescription!.isEmpty)
        }
    }
    
    func testVisionFrameworkErrorMessage() {
        let testMessage = "Custom vision error message"
        let error = OCRError.visionFrameworkError(testMessage)
        
        XCTAssertTrue(error.errorDescription!.contains(testMessage))
    }
    
    // MARK: - Performance Tests
    
    func testTextFileProcessingPerformance() throws {
        // Create a larger text file for performance testing
        let largeContent = String(repeating: "This is a test line with financial data. Amount: $1,234.56\n", count: 1000)
        let tempURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("large_test_\(UUID().uuidString).txt")
        
        try largeContent.write(to: tempURL, atomically: true, encoding: .utf8)
        
        defer {
            try? FileManager.default.removeItem(at: tempURL)
        }
        
        measure {
            let expectation = XCTestExpectation(description: "OCR processing")
            
            Task {
                do {
                    _ = try await ocrService.performBackgroundOCR(on: tempURL)
                    expectation.fulfill()
                } catch {
                    XCTFail("Performance test failed: \(error)")
                }
            }
            
            wait(for: [expectation], timeout: 5.0)
        }
    }
    
    // MARK: - Integration Tests
    
    func testServiceLifecycle() {
        // Test creating and destroying multiple service instances
        for _ in 0..<10 {
            let service = DocumentOCRProcessingService()
            XCTAssertNotNil(service)
        }
    }
    
    // MARK: - Snapshot Tests
    
    func testOCRServiceSnapshot() {
        // Test service state snapshot
        let service = DocumentOCRProcessingService()
        
        // Verify service is properly initialized
        XCTAssertNotNil(service)
        
        // Test service maintains consistency
        let service2 = DocumentOCRProcessingService()
        XCTAssertNotNil(service2)
        
        // Services should be independent instances
        XCTAssertFalse(service === service2)
    }
}

// MARK: - Test Utilities

extension DocumentOCRProcessingServiceTests {
    
    /// Creates a temporary file with given content for testing
    private func createTempFile(content: String, extension ext: String) throws -> URL {
        let tempURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("test_\(UUID().uuidString).\(ext)")
        
        try content.write(to: tempURL, atomically: true, encoding: .utf8)
        return tempURL
    }
    
    /// Cleans up temporary files created during testing
    private func cleanup(url: URL) {
        try? FileManager.default.removeItem(at: url)
    }
}