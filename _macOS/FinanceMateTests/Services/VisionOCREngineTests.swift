//
// VisionOCREngineTests.swift
// FinanceMateTests
//
// Created by AI Agent on 2025-07-08.
// UR-104: OCR & Document Intelligence - TDD Implementation
//

/*
 * Purpose: Test suite for VisionOCREngine OCR processing capabilities
 * Issues & Complexity Summary: TDD-driven OCR engine validation with financial document focus
 * Key Complexity Drivers:
   - Logic Scope (Est. LoC): ~500 (comprehensive OCR testing)
   - Core Algorithm Complexity: High (Vision Framework + financial parsing)
   - Dependencies: Vision Framework, test image assets, mock data
   - State Management Complexity: Medium (async OCR processing)
   - Novelty/Uncertainty Factor: Medium (financial document OCR patterns)
 * AI Pre-Task Self-Assessment: 85%
 * Problem Estimate: 90%
 * Initial Code Complexity Estimate: 88%
 * Final Code Complexity: TBD
 * Overall Result Score: TBD
 * Key Variances/Learnings: TDD approach for OCR validation
 * Last Updated: 2025-07-08
 */

import XCTest
import Vision
import CoreImage
@testable import FinanceMate

@MainActor
final class VisionOCREngineTests: XCTestCase {
    
    // MARK: - Test Properties
    private var ocrEngine: VisionOCREngine!
    private var testBundle: Bundle!
    
    // MARK: - Test Setup
    override func setUpWithError() throws {
        try super.setUpWithError()
        ocrEngine = VisionOCREngine()
        testBundle = Bundle(for: VisionOCREngineTests.self)
    }
    
    override func tearDownWithError() throws {
        ocrEngine = nil
        testBundle = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Core OCR Processing Tests
    
    func testOCREngineInitialization() {
        // Given: Fresh OCR engine instance
        let engine = VisionOCREngine()
        
        // Then: Should be properly initialized
        XCTAssertNotNil(engine, "VisionOCREngine should initialize successfully")
    }
    
    func testBasicTextRecognitionFromImage() async throws {
        // Given: Simple text image
        let testImage = try createTestImageWithText("WOOLWORTHS\n$45.67\n15/07/2025")
        
        // When: Processing image with OCR
        let result = try await ocrEngine.recognizeText(from: testImage)
        
        // Then: Should extract basic text correctly
        XCTAssertFalse(result.recognizedText.isEmpty, "Should recognize text from image")
        XCTAssertTrue(result.recognizedText.contains("WOOLWORTHS"), "Should recognize merchant name")
        XCTAssertGreaterThan(result.confidence, 0.8, "Should have high confidence for simple text")
    }
    
    func testFinancialDataExtractionAccuracy() async throws {
        // Given: Receipt-like test image with financial data
        let receiptText = """
        COLES SUPERMARKETS
        ABN: 37 004 085 616
        GST INCLUDED: $4.56
        TOTAL: $45.67
        DATE: 15/07/2025
        """
        let testImage = try createTestImageWithText(receiptText)
        
        // When: Processing with financial focus
        let result = try await ocrEngine.recognizeFinancialDocument(from: testImage)
        
        // Then: Should extract financial data with high precision
        XCTAssertNotNil(result.merchantName, "Should extract merchant name")
        XCTAssertEqual(result.merchantName, "COLES SUPERMARKETS", "Should extract correct merchant name")
        XCTAssertNotNil(result.totalAmount, "Should extract total amount")
        XCTAssertEqual(result.totalAmount, 45.67, accuracy: 0.01, "Should extract correct total amount")
        XCTAssertNotNil(result.date, "Should extract transaction date")
        XCTAssertGreaterThan(result.confidence, 0.95, "Should achieve >95% confidence for financial data")
    }
    
    func testAustralianCurrencyFormatting() async throws {
        // Given: Australian currency formatted receipt
        let receiptText = """
        BUNNINGS WAREHOUSE
        ITEM 1: $12.95
        ITEM 2: $7.50
        GST: $2.05
        TOTAL: $22.50 AUD
        """
        let testImage = try createTestImageWithText(receiptText)
        
        // When: Processing Australian receipt
        let result = try await ocrEngine.recognizeFinancialDocument(from: testImage)
        
        // Then: Should handle Australian currency correctly
        XCTAssertEqual(result.totalAmount, 22.50, "Should parse AUD amounts correctly")
        XCTAssertEqual(result.currency, "AUD", "Should detect Australian currency")
        XCTAssertNotNil(result.gstAmount, "Should extract GST amount")
        XCTAssertEqual(result.gstAmount, 2.05, accuracy: 0.01, "Should extract correct GST amount")
    }
    
    func testABNRecognitionCompliance() async throws {
        // Given: Receipt with Australian Business Number
        let receiptText = """
        HARVEY NORMAN
        ABN: 67 003 335 445
        TAX INVOICE
        TOTAL: $899.00
        """
        let testImage = try createTestImageWithText(receiptText)
        
        // When: Processing receipt with ABN
        let result = try await ocrEngine.recognizeFinancialDocument(from: testImage)
        
        // Then: Should extract and validate ABN
        XCTAssertNotNil(result.abn, "Should extract ABN from receipt")
        XCTAssertEqual(result.abn, "67 003 335 445", "Should extract correct ABN format")
        XCTAssertTrue(result.isValidABN, "Should validate ABN format correctly")
    }
    
    func testDateFormatRecognition() async throws {
        // Given: Receipt with Australian date format
        let receiptText = """
        KMART AUSTRALIA
        DATE: 25/12/2024
        TIME: 14:30
        TOTAL: $156.89
        """
        let testImage = try createTestImageWithText(receiptText)
        
        // When: Processing date information
        let result = try await ocrEngine.recognizeFinancialDocument(from: testImage)
        
        // Then: Should parse Australian date format correctly
        XCTAssertNotNil(result.date, "Should extract transaction date")
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.day, .month, .year], from: result.date!)
        XCTAssertEqual(dateComponents.day, 25, "Should parse day correctly")
        XCTAssertEqual(dateComponents.month, 12, "Should parse month correctly")
        XCTAssertEqual(dateComponents.year, 2024, "Should parse year correctly")
    }
    
    // MARK: - Error Handling Tests
    
    func testPoorImageQualityHandling() async throws {
        // Given: Low quality/blurry image
        let blurryImage = try createBlurryTestImage()
        
        // When: Processing poor quality image
        let result = try await ocrEngine.recognizeText(from: blurryImage)
        
        // Then: Should handle gracefully with appropriate confidence
        XCTAssertLessThan(result.confidence, 0.5, "Should report low confidence for poor quality")
        XCTAssertNotNil(result.error, "Should provide error information for poor quality")
    }
    
    func testEmptyImageHandling() async throws {
        // Given: Empty/blank image
        let emptyImage = try createEmptyTestImage()
        
        // When: Processing empty image
        do {
            _ = try await ocrEngine.recognizeText(from: emptyImage)
            XCTFail("Should throw error for empty image")
        } catch {
            // Then: Should throw appropriate error
            XCTAssertTrue(error is VisionOCREngine.OCRError, "Should throw OCRError for empty image")
        }
    }
    
    func testUnsupportedImageFormatHandling() async throws {
        // Given: Unsupported image format
        // When/Then: Should handle unsupported formats gracefully
        // This test validates error handling for various image format issues
        
        let invalidData = Data([0x00, 0x01, 0x02]) // Invalid image data
        
        do {
            _ = try await ocrEngine.recognizeText(fromImageData: invalidData)
            XCTFail("Should throw error for invalid image data")
        } catch {
            XCTAssertTrue(error is VisionOCREngine.OCRError, "Should throw OCRError for invalid data")
        }
    }
    
    // MARK: - Performance Tests
    
    func testOCRProcessingPerformance() async throws {
        // Given: Standard receipt image
        let testImage = try createTestImageWithText("WOOLWORTHS\n$45.67\n15/07/2025")
        
        // When: Measuring processing time
        let startTime = CFAbsoluteTimeGetCurrent()
        _ = try await ocrEngine.recognizeText(from: testImage)
        let processingTime = CFAbsoluteTimeGetCurrent() - startTime
        
        // Then: Should complete within performance target
        XCTAssertLessThan(processingTime, 3.0, "OCR processing should complete within 3 seconds")
    }
    
    func testBatchProcessingMemoryUsage() async throws {
        // Given: Multiple images to process
        let images = try (1...10).map { _ in
            try createTestImageWithText("COLES\n$25.50\n01/07/2025")
        }
        
        // When: Processing batch of images
        let initialMemory = getMemoryUsage()
        for image in images {
            _ = try await ocrEngine.recognizeText(from: image)
        }
        let finalMemory = getMemoryUsage()
        
        // Then: Memory usage should remain reasonable
        let memoryIncrease = finalMemory - initialMemory
        XCTAssertLessThan(memoryIncrease, 100.0, "Memory increase should be less than 100MB for batch processing")
    }
    
    // MARK: - Integration Tests
    
    func testConcurrentOCRProcessing() async throws {
        // Given: Multiple OCR requests
        let testImages = try (1...5).map { index in
            try createTestImageWithText("MERCHANT \(index)\n$\(index * 10).00\n01/07/2025")
        }
        
        // When: Processing concurrently
        let results = try await withThrowingTaskGroup(of: OCRResult.self) { group in
            for image in testImages {
                group.addTask {
                    return try await self.ocrEngine.recognizeText(from: image)
                }
            }
            
            var allResults: [OCRResult] = []
            for try await result in group {
                allResults.append(result)
            }
            return allResults
        }
        
        // Then: All requests should complete successfully
        XCTAssertEqual(results.count, 5, "Should process all concurrent requests")
        for result in results {
            XCTAssertGreaterThan(result.confidence, 0.7, "All concurrent requests should have good confidence")
        }
    }
    
    // MARK: - Helper Methods
    
    private func createTestImageWithText(_ text: String) throws -> CGImage {
        // Create a test image with specified text for OCR testing
        let size = CGSize(width: 400, height: 300)
        let renderer = NSGraphicsContext.cgContext(withSize: size)
        
        let context = CGContext(data: nil, width: Int(size.width), height: Int(size.height),
                               bitsPerComponent: 8, bytesPerRow: 0,
                               space: CGColorSpaceCreateDeviceRGB(),
                               bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        
        // Fill with white background
        context.setFillColor(CGColor.white)
        context.fill(CGRect(origin: .zero, size: size))
        
        // Add black text
        context.setFillColor(CGColor.black)
        
        // Create attributed string for text rendering
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 16),
            .foregroundColor: NSColor.black
        ]
        
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        let line = CTLineCreateWithAttributedString(attributedString)
        
        context.textPosition = CGPoint(x: 20, y: size.height - 50)
        CTLineDraw(line, context)
        
        guard let image = context.makeImage() else {
            throw NSError(domain: "TestError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to create test image"])
        }
        
        return image
    }
    
    private func createBlurryTestImage() throws -> CGImage {
        // Create a blurry test image to test poor quality handling
        let originalImage = try createTestImageWithText("BLURRY TEXT $123.45")
        
        let ciImage = CIImage(cgImage: originalImage)
        let filter = CIFilter(name: "CIGaussianBlur")!
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(5.0, forKey: kCIInputRadiusKey)
        
        let context = CIContext()
        guard let outputImage = filter.outputImage,
              let blurryImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            throw NSError(domain: "TestError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to create blurry image"])
        }
        
        return blurryImage
    }
    
    private func createEmptyTestImage() throws -> CGImage {
        // Create an empty white image
        let size = CGSize(width: 100, height: 100)
        let context = CGContext(data: nil, width: Int(size.width), height: Int(size.height),
                               bitsPerComponent: 8, bytesPerRow: 0,
                               space: CGColorSpaceCreateDeviceRGB(),
                               bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        
        context.setFillColor(CGColor.white)
        context.fill(CGRect(origin: .zero, size: size))
        
        guard let image = context.makeImage() else {
            throw NSError(domain: "TestError", code: 3, userInfo: [NSLocalizedDescriptionKey: "Failed to create empty image"])
        }
        
        return image
    }
    
    private func getMemoryUsage() -> Double {
        // Get current memory usage in MB
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            return Double(info.resident_size) / 1024.0 / 1024.0 // Convert to MB
        } else {
            return 0.0
        }
    }
}

// MARK: - Test Data Structures

extension VisionOCREngineTests {
    struct OCRResult {
        let recognizedText: String
        let confidence: Double
        let error: Error?
        let merchantName: String?
        let totalAmount: Double?
        let currency: String?
        let date: Date?
        let abn: String?
        let gstAmount: Double?
        let isValidABN: Bool
    }
}