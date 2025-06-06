// SANDBOX FILE: For testing/development. See .cursorrules.

//
//  DocumentTextExtractionServiceTests.swift
//  FinanceMate-SandboxTests
//
//  Created by Assistant on 6/6/25.
//

import XCTest
import PDFKit
@testable import FinanceMate_Sandbox

class DocumentTextExtractionServiceTests: XCTestCase {
    
    var service: DocumentTextExtractionService!
    var mockOCRService: MockOCRService!
    
    override func setUp() {
        super.setUp()
        mockOCRService = MockOCRService()
        service = DocumentTextExtractionService(ocrService: mockOCRService)
    }
    
    override func tearDown() {
        service = nil
        mockOCRService = nil
        super.tearDown()
    }
    
    // MARK: - Format Support Tests
    
    func testSupportedFormats() {
        let supportedURLs = [
            URL(fileURLWithPath: "/test/document.pdf"),
            URL(fileURLWithPath: "/test/image.jpg"),
            URL(fileURLWithPath: "/test/photo.jpeg"),
            URL(fileURLWithPath: "/test/scan.png"),
            URL(fileURLWithPath: "/test/receipt.tiff"),
            URL(fileURLWithPath: "/test/invoice.heic"),
            URL(fileURLWithPath: "/test/data.txt"),
            URL(fileURLWithPath: "/test/report.rtf")
        ]
        
        for url in supportedURLs {
            XCTAssertTrue(service.isFormatSupported(url: url), "Should support format: \(url.pathExtension)")
        }
    }
    
    func testUnsupportedFormats() {
        let unsupportedURLs = [
            URL(fileURLWithPath: "/test/document.doc"),
            URL(fileURLWithPath: "/test/presentation.ppt"),
            URL(fileURLWithPath: "/test/spreadsheet.xls"),
            URL(fileURLWithPath: "/test/unknown.xyz")
        ]
        
        for url in unsupportedURLs {
            XCTAssertFalse(service.isFormatSupported(url: url), "Should not support format: \(url.pathExtension)")
        }
    }
    
    // MARK: - Confidence Level Tests
    
    func testExtractionConfidenceLevels() {
        let confidenceTests = [
            (URL(fileURLWithPath: "/test/document.pdf"), 0.95),
            (URL(fileURLWithPath: "/test/text.txt"), 0.98),
            (URL(fileURLWithPath: "/test/report.rtf"), 0.98),
            (URL(fileURLWithPath: "/test/image.png"), 0.80),
            (URL(fileURLWithPath: "/test/photo.jpg"), 0.80),
            (URL(fileURLWithPath: "/test/scan.tiff"), 0.75),
            (URL(fileURLWithPath: "/test/unknown.xyz"), 0.0)
        ]
        
        for (url, expectedConfidence) in confidenceTests {
            let confidence = service.getExtractionConfidence(for: url)
            XCTAssertEqual(confidence, expectedConfidence, accuracy: 0.01, 
                          "Confidence for \(url.pathExtension) should be \(expectedConfidence)")
        }
    }
    
    // MARK: - Text File Extraction Tests
    
    func testExtractTextFromValidTextFile() async throws {
        let testContent = "Sample invoice text\nTotal: $100.00\nDate: 2024-06-06"
        let tempURL = createTemporaryTextFile(content: testContent)
        defer { removeTemporaryFile(url: tempURL) }
        
        let extractedText = try await service.extractText(from: tempURL)
        XCTAssertEqual(extractedText, testContent, "Should extract exact text content")
    }
    
    func testExtractTextFromEmptyTextFile() async {
        let tempURL = createTemporaryTextFile(content: "")
        defer { removeTemporaryFile(url: tempURL) }
        
        do {
            _ = try await service.extractText(from: tempURL)
            XCTFail("Should throw error for empty text file")
        } catch DocumentExtractionError.emptyDocument {
            // Expected behavior
        } catch {
            XCTFail("Should throw emptyDocument error, got: \(error)")
        }
    }
    
    func testExtractTextFromNonexistentFile() async {
        let nonexistentURL = URL(fileURLWithPath: "/nonexistent/file.txt")
        
        do {
            _ = try await service.extractText(from: nonexistentURL)
            XCTFail("Should throw error for nonexistent file")
        } catch DocumentExtractionError.fileNotFound {
            // Expected behavior
        } catch {
            XCTFail("Should throw fileNotFound error, got: \(error)")
        }
    }
    
    // MARK: - Image OCR Tests
    
    func testExtractTextFromImageSuccess() async throws {
        let imageURL = URL(fileURLWithPath: "/test/receipt.jpg")
        let expectedText = "Receipt\nTotal: $50.00\nThank you!"
        
        // Create temporary image file
        let tempURL = createTemporaryImageFile()
        defer { removeTemporaryFile(url: tempURL) }
        
        mockOCRService.mockResult = .success(expectedText)
        
        let extractedText = try await service.extractText(from: tempURL)
        XCTAssertEqual(extractedText, expectedText, "Should extract text from image via OCR")
    }
    
    func testExtractTextFromImageOCRFailure() async {
        let tempURL = createTemporaryImageFile()
        defer { removeTemporaryFile(url: tempURL) }
        
        let mockError = NSError(domain: "OCRError", code: 1, userInfo: nil)
        mockOCRService.mockResult = .failure(mockError)
        
        do {
            _ = try await service.extractText(from: tempURL)
            XCTFail("Should throw error when OCR fails")
        } catch DocumentExtractionError.ocrFailed {
            // Expected behavior
        } catch {
            XCTFail("Should throw ocrFailed error, got: \(error)")
        }
    }
    
    func testExtractTextFromImageNoTextFound() async {
        let tempURL = createTemporaryImageFile()
        defer { removeTemporaryFile(url: tempURL) }
        
        mockOCRService.mockResult = .success("") // Empty result
        
        do {
            _ = try await service.extractText(from: tempURL)
            XCTFail("Should throw error when no text found")
        } catch DocumentExtractionError.ocrNoTextFound {
            // Expected behavior
        } catch {
            XCTFail("Should throw ocrNoTextFound error, got: \(error)")
        }
    }
    
    // MARK: - PDF Extraction Tests
    
    func testExtractTextFromValidPDF() async throws {
        let testContent = "Invoice #123\nTotal: $200.00"
        let tempURL = createTemporaryPDFFile(content: testContent)
        defer { removeTemporaryFile(url: tempURL) }
        
        let extractedText = try await service.extractText(from: tempURL)
        XCTAssertTrue(extractedText.contains("Invoice #123"), "Should extract PDF text content")
        XCTAssertTrue(extractedText.contains("Total: $200.00"), "Should extract PDF text content")
    }
    
    func testExtractTextFromMultiPagePDF() async throws {
        let page1Content = "Page 1 Content"
        let page2Content = "Page 2 Content"
        let tempURL = createTemporaryMultiPagePDFFile(pages: [page1Content, page2Content])
        defer { removeTemporaryFile(url: tempURL) }
        
        let extractedText = try await service.extractText(from: tempURL)
        XCTAssertTrue(extractedText.contains("Page 1 Content"), "Should extract first page")
        XCTAssertTrue(extractedText.contains("Page 2 Content"), "Should extract second page")
        XCTAssertTrue(extractedText.contains("---PAGE-BREAK---"), "Should include page break marker")
    }
    
    // MARK: - Unsupported Format Tests
    
    func testExtractTextFromUnsupportedFormat() async {
        let unsupportedURL = URL(fileURLWithPath: "/test/document.doc")
        
        do {
            _ = try await service.extractText(from: unsupportedURL)
            XCTFail("Should throw error for unsupported format")
        } catch DocumentExtractionError.unsupportedFormat(let format) {
            XCTAssertEqual(format, "doc", "Should identify the unsupported format")
        } catch {
            XCTFail("Should throw unsupportedFormat error, got: \(error)")
        }
    }
    
    // MARK: - Multiple Document Extraction Tests
    
    func testExtractTextFromMultipleDocuments() async {
        let textContent = "Test document content"
        let imageText = "OCR extracted text"
        
        let textURL = createTemporaryTextFile(content: textContent)
        let imageURL = createTemporaryImageFile()
        let unsupportedURL = URL(fileURLWithPath: "/nonexistent/file.doc")
        
        defer {
            removeTemporaryFile(url: textURL)
            removeTemporaryFile(url: imageURL)
        }
        
        mockOCRService.mockResult = .success(imageText)
        
        let results = await service.extractTextFromMultipleDocuments(urls: [textURL, imageURL, unsupportedURL])
        
        XCTAssertEqual(results.count, 3, "Should return results for all URLs")
        
        // Check text file result
        let textResult = results.first { $0.url.pathExtension == "txt" }
        XCTAssertNotNil(textResult, "Should have text file result")
        XCTAssertTrue(textResult!.isSuccess, "Text extraction should succeed")
        XCTAssertEqual(textResult!.text, textContent, "Should extract correct text content")
        
        // Check image file result
        let imageResult = results.first { $0.url.pathExtension == "jpg" }
        XCTAssertNotNil(imageResult, "Should have image file result")
        XCTAssertTrue(imageResult!.isSuccess, "Image extraction should succeed")
        XCTAssertEqual(imageResult!.text, imageText, "Should extract OCR text")
        
        // Check unsupported file result
        let unsupportedResult = results.first { $0.url.pathExtension == "doc" }
        XCTAssertNotNil(unsupportedResult, "Should have unsupported file result")
        XCTAssertFalse(unsupportedResult!.isSuccess, "Unsupported extraction should fail")
        XCTAssertNotNil(unsupportedResult!.error, "Should have error for unsupported format")
    }
    
    // MARK: - Performance Tests
    
    func testPerformanceFormatSupport() {
        let testURL = URL(fileURLWithPath: "/test/document.pdf")
        
        measure {
            for _ in 0..<1000 {
                _ = service.isFormatSupported(url: testURL)
            }
        }
    }
    
    func testPerformanceConfidenceCalculation() {
        let testURL = URL(fileURLWithPath: "/test/document.pdf")
        
        measure {
            for _ in 0..<1000 {
                _ = service.getExtractionConfidence(for: testURL)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func createTemporaryTextFile(content: String) -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let tempURL = tempDir.appendingPathComponent(UUID().uuidString).appendingPathExtension("txt")
        
        try! content.write(to: tempURL, atomically: true, encoding: .utf8)
        return tempURL
    }
    
    private func createTemporaryImageFile() -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let tempURL = tempDir.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpg")
        
        // Create a minimal JPEG file (just header bytes for testing)
        let jpegHeader = Data([0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46])
        try! jpegHeader.write(to: tempURL)
        
        return tempURL
    }
    
    private func createTemporaryPDFFile(content: String) -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let tempURL = tempDir.appendingPathComponent(UUID().uuidString).appendingPathExtension("pdf")
        
        let pdfDocument = PDFDocument()
        let page = PDFPage()
        
        // Create a simple text-based PDF page
        let attributedString = NSAttributedString(string: content)
        let bounds = CGRect(x: 0, y: 0, width: 612, height: 792) // Standard page size
        
        page.setBounds(bounds, for: .mediaBox)
        pdfDocument.insert(page, at: 0)
        
        pdfDocument.write(to: tempURL)
        return tempURL
    }
    
    private func createTemporaryMultiPagePDFFile(pages: [String]) -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let tempURL = tempDir.appendingPathComponent(UUID().uuidString).appendingPathExtension("pdf")
        
        let pdfDocument = PDFDocument()
        
        for (index, content) in pages.enumerated() {
            let page = PDFPage()
            let bounds = CGRect(x: 0, y: 0, width: 612, height: 792)
            page.setBounds(bounds, for: .mediaBox)
            pdfDocument.insert(page, at: index)
        }
        
        pdfDocument.write(to: tempURL)
        return tempURL
    }
    
    private func removeTemporaryFile(url: URL) {
        try? FileManager.default.removeItem(at: url)
    }
}

// MARK: - Mock OCR Service

class MockOCRService: OCRService {
    var mockResult: Result<String, Error> = .success("Mock OCR Result")
    
    override func extractText(from url: URL) async throws -> String {
        switch mockResult {
        case .success(let text):
            return text
        case .failure(let error):
            throw error
        }
    }
}