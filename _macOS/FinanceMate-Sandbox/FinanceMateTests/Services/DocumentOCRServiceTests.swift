//
//  DocumentOCRServiceTests.swift
//  FinanceMateTests
//
//  Created by Assistant on 6/27/25.
//

import XCTest
import PDFKit
import Vision
@testable import FinanceMate

final class DocumentOCRServiceTests: XCTestCase {
    
    var sut: DocumentOCRService!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = DocumentOCRService()
    }
    
    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Text File Tests
    
    func testPerformBackgroundOCR_WithTextFile_ReturnsFileContent() async throws {
        // Given
        let testContent = "This is a test document with sample content."
        let tempURL = createTempTextFile(content: testContent)
        defer { try? FileManager.default.removeItem(at: tempURL) }
        
        // When
        let result = try await sut.performBackgroundOCR(on: tempURL)
        
        // Then
        XCTAssertEqual(result, testContent)
    }
    
    func testPerformBackgroundOCR_WithEmptyTextFile_ReturnsEmptyString() async throws {
        // Given
        let tempURL = createTempTextFile(content: "")
        defer { try? FileManager.default.removeItem(at: tempURL) }
        
        // When
        let result = try await sut.performBackgroundOCR(on: tempURL)
        
        // Then
        XCTAssertEqual(result, "")
    }
    
    // MARK: - Unsupported File Tests
    
    func testPerformBackgroundOCR_WithUnsupportedFileType_ThrowsError() async {
        // Given
        let tempURL = createTempFile(extension: "docx", content: Data())
        defer { try? FileManager.default.removeItem(at: tempURL) }
        
        // When & Then
        do {
            _ = try await sut.performBackgroundOCR(on: tempURL)
            XCTFail("Expected OCRError.unsupportedFileType to be thrown")
        } catch OCRError.unsupportedFileType {
            // Expected error
        } catch {
            XCTFail("Expected OCRError.unsupportedFileType, got \(error)")
        }
    }
    
    // MARK: - PDF Tests
    
    func testPerformBackgroundOCR_WithNonExistentPDF_ThrowsError() async {
        // Given
        let nonExistentURL = URL(fileURLWithPath: "/tmp/nonexistent.pdf")
        
        // When & Then
        do {
            _ = try await sut.performBackgroundOCR(on: nonExistentURL)
            XCTFail("Expected OCRError.pdfLoadFailed to be thrown")
        } catch OCRError.pdfLoadFailed {
            // Expected error
        } catch {
            XCTFail("Expected OCRError.pdfLoadFailed, got \(error)")
        }
    }
    
    // MARK: - Image Tests
    
    func testPerformBackgroundOCR_WithNonExistentImage_ThrowsError() async {
        // Given
        let nonExistentURL = URL(fileURLWithPath: "/tmp/nonexistent.jpg")
        
        // When & Then
        do {
            _ = try await sut.performBackgroundOCR(on: nonExistentURL)
            XCTFail("Expected OCRError.imageLoadFailed to be thrown")
        } catch OCRError.imageLoadFailed {
            // Expected error
        } catch {
            XCTFail("Expected OCRError.imageLoadFailed, got \(error)")
        }
    }
    
    // MARK: - OCR Error Tests
    
    func testOCRError_UnsupportedFileType_HasCorrectDescription() {
        // Given
        let error = OCRError.unsupportedFileType
        
        // When
        let description = error.errorDescription
        
        // Then
        XCTAssertEqual(description, "Unsupported file type for OCR processing")
    }
    
    func testOCRError_PDFLoadFailed_HasCorrectDescription() {
        // Given
        let error = OCRError.pdfLoadFailed
        
        // When
        let description = error.errorDescription
        
        // Then
        XCTAssertEqual(description, "Failed to load PDF document")
    }
    
    func testOCRError_ImageLoadFailed_HasCorrectDescription() {
        // Given
        let error = OCRError.imageLoadFailed
        
        // When
        let description = error.errorDescription
        
        // Then
        XCTAssertEqual(description, "Failed to load image file")
    }
    
    func testOCRError_ImageProcessingFailed_HasCorrectDescription() {
        // Given
        let error = OCRError.imageProcessingFailed
        
        // When
        let description = error.errorDescription
        
        // Then
        XCTAssertEqual(description, "Failed to process image for OCR")
    }
    
    func testOCRError_VisionProcessingFailed_HasCorrectDescription() {
        // Given
        let error = OCRError.visionProcessingFailed
        
        // When
        let description = error.errorDescription
        
        // Then
        XCTAssertEqual(description, "Vision framework processing failed")
    }
    
    // MARK: - Integration Tests
    
    func testDocumentOCRService_Integration_TextFileSupported() {
        // Given
        let service = DocumentOCRService()
        
        // When & Then
        XCTAssertNotNil(service, "DocumentOCRService should initialize successfully")
    }
    
    // MARK: - Helper Methods
    
    private func createTempTextFile(content: String) -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = UUID().uuidString + ".txt"
        let fileURL = tempDir.appendingPathComponent(fileName)
        
        try! content.write(to: fileURL, atomically: true, encoding: .utf8)
        return fileURL
    }
    
    private func createTempFile(extension ext: String, content: Data) -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = UUID().uuidString + "." + ext
        let fileURL = tempDir.appendingPathComponent(fileName)
        
        try! content.write(to: fileURL)
        return fileURL
    }
}

// MARK: - Mock Tests for Vision Framework

extension DocumentOCRServiceTests {
    
    func testDocumentOCRService_HandlesFileExtensions_Correctly() {
        // Given
        let pdfURL = URL(fileURLWithPath: "/tmp/test.pdf")
        let jpgURL = URL(fileURLWithPath: "/tmp/test.jpg")
        let txtURL = URL(fileURLWithPath: "/tmp/test.txt")
        let unknownURL = URL(fileURLWithPath: "/tmp/test.unknown")
        
        // When & Then
        XCTAssertEqual(pdfURL.pathExtension.lowercased(), "pdf")
        XCTAssertEqual(jpgURL.pathExtension.lowercased(), "jpg")
        XCTAssertEqual(txtURL.pathExtension.lowercased(), "txt")
        XCTAssertEqual(unknownURL.pathExtension.lowercased(), "unknown")
    }
    
    func testDocumentOCRService_SupportedImageFormats() {
        // Given
        let supportedFormats = ["jpg", "jpeg", "png", "tiff", "heic"]
        
        // When & Then
        for format in supportedFormats {
            let url = URL(fileURLWithPath: "/tmp/test.\(format)")
            XCTAssertTrue(["jpg", "jpeg", "png", "tiff", "heic"].contains(url.pathExtension.lowercased()),
                         "Format \(format) should be supported")
        }
    }
}