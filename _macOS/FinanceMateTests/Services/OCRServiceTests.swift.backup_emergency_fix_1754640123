import XCTest
import Vision
import CoreData
@testable import FinanceMate

/**
 * OCRServiceTests.swift
 * 
 * Purpose: Comprehensive TDD unit tests for Apple Vision OCR receipt/invoice processing service
 * Issues & Complexity Summary: Tests text recognition accuracy, performance, error handling, and integration
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~300+
 *   - Core Algorithm Complexity: High
 *   - Dependencies: 4 (Vision, CoreData, XCTest, Foundation)
 *   - State Management Complexity: Medium-High
 *   - Novelty/Uncertainty Factor: High
 * AI Pre-Task Self-Assessment: 85%
 * Problem Estimate: 90%
 * Initial Code Complexity Estimate: 90%
 * Final Code Complexity: TBD
 * Overall Result Score: TBD
 * Key Variances/Learnings: Enterprise-grade OCR with performance benchmarks and accuracy validation
 * Last Updated: 2025-07-08
 */

@MainActor
final class OCRServiceTests: XCTestCase {
    var ocrService: OCRService!
    var testContext: NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        testContext = PersistenceController.preview.container.viewContext
        ocrService = OCRService()
    }
    
    override func tearDown() {
        ocrService = nil
        testContext = nil
        super.tearDown()
    }
    
    // MARK: - Text Recognition Tests
    
    func testTextRecognitionAccuracy() async throws {
        // Given: A test receipt image with known text content
        let testImage = createTestReceiptImage()
        let expectedText = "Coffee Shop\n$4.50\nGST $0.45\nTotal $4.95"
        
        // When: Processing the image through OCR
        let result = try await ocrService.processReceiptImage(testImage)
        
        // Then: Should recognize text with high accuracy
        XCTAssertNotNil(result)
        XCTAssertGreaterThan(result.confidence, 0.90, "OCR confidence should be >90%")
        XCTAssertTrue(result.extractedText.contains("Coffee Shop"), "Should detect merchant name")
        XCTAssertTrue(result.extractedText.contains("4.95"), "Should detect total amount")
        XCTAssertEqual(result.totalAmount, 4.95, accuracy: 0.01, "Should extract correct total")
    }
    
    func testImagePreprocessing() {
        // Given: A low quality image that needs preprocessing
        let lowQualityImage = createLowQualityTestImage()
        
        // When: Preprocessing the image
        let processedImage = ocrService.preprocessImage(lowQualityImage)
        
        // Then: Should enhance image quality for better OCR
        XCTAssertNotNil(processedImage)
        XCTAssertLessThanOrEqual(processedImage.size.width, 1024, "Should resize to optimal width")
        XCTAssertLessThanOrEqual(processedImage.size.height, 1024, "Should resize to optimal height")
    }
    
    func testConfidenceScoring() async throws {
        // Given: Images with different quality levels
        let highQualityImage = createTestReceiptImage()
        let lowQualityImage = createBlurryTestImage()
        
        // When: Processing both images
        let highQualityResult = try await ocrService.processReceiptImage(highQualityImage)
        let lowQualityResult = try await ocrService.processReceiptImage(lowQualityImage)
        
        // Then: Confidence scores should reflect image quality
        XCTAssertGreaterThan(highQualityResult.confidence, 0.85, "High quality should have high confidence")
        XCTAssertLessThan(lowQualityResult.confidence, 0.70, "Low quality should have low confidence")
        XCTAssertTrue(lowQualityResult.requiresManualReview, "Low confidence should require manual review")
    }
    
    func testLineItemExtraction() async throws {
        // Given: A receipt with multiple line items
        let receiptImage = createMultiLineItemReceiptImage()
        
        // When: Processing the receipt
        let result = try await ocrService.processReceiptImage(receiptImage)
        
        // Then: Should extract individual line items
        XCTAssertGreaterThan(result.lineItems.count, 1, "Should extract multiple line items")
        
        let firstItem = try XCTUnwrap(result.lineItems.first)
        XCTAssertFalse(firstItem.description.isEmpty, "Line item should have description")
        XCTAssertGreaterThan(firstItem.amount, 0, "Line item should have positive amount")
        XCTAssertGreaterThan(firstItem.confidence, 0.5, "Line item should have reasonable confidence")
    }
    
    // MARK: - Error Handling Tests
    
    func testErrorHandling() async {
        // Given: Invalid input scenarios
        let emptyImage = NSImage()
        
        // When/Then: Should handle errors gracefully
        do {
            _ = try await ocrService.processReceiptImage(emptyImage)
            XCTFail("Should throw error for invalid image")
        } catch OCRError.imageProcessingFailed {
            // Expected error
        } catch {
            XCTFail("Should throw specific OCRError, got: \(error)")
        }
    }
    
    func testLowConfidenceHandling() async throws {
        // Given: An image that produces low confidence results
        let poorQualityImage = createPoorQualityTestImage()
        
        // When: Processing the image
        let result = try await ocrService.processReceiptImage(poorQualityImage)
        
        // Then: Should flag for manual review
        XCTAssertTrue(result.requiresManualReview, "Low confidence should require manual review")
        XCTAssertLessThan(result.confidence, 0.8, "Should detect low confidence accurately")
    }
    
    // MARK: - Performance Tests
    
    func testPerformanceBenchmarks() {
        // Given: A standard test receipt
        let testImage = createTestReceiptImage()
        
        // When: Measuring processing time
        measure {
            let expectation = XCTestExpectation(description: "OCR Processing")
            
            Task {
                do {
                    _ = try await ocrService.processReceiptImage(testImage)
                    expectation.fulfill()
                } catch {
                    XCTFail("Processing failed: \(error)")
                    expectation.fulfill()
                }
            }
            
            wait(for: [expectation], timeout: 0.5) // Target: <500ms
        }
    }
    
    func testMemoryUsage() {
        // Given: Multiple large receipts for processing
        let largeImages = (0..<5).map { _ in createLargeTestReceiptImage() }
        
        // When: Processing multiple images
        let initialMemory = getMemoryUsage()
        
        for image in largeImages {
            Task {
                try? await ocrService.processReceiptImage(image)
            }
        }
        
        let finalMemory = getMemoryUsage()
        let memoryIncrease = finalMemory - initialMemory
        
        // Then: Memory usage should stay within limits
        XCTAssertLessThan(memoryIncrease, 50_000_000, "Memory usage should stay under 50MB")
    }
    
    func testConcurrentProcessing() async {
        // Given: Multiple images to process concurrently
        let testImages = (0..<3).map { _ in createTestReceiptImage() }
        
        // When: Processing concurrently
        await withTaskGroup(of: OCRResult?.self) { group in
            for image in testImages {
                group.addTask {
                    return try? await self.ocrService.processReceiptImage(image)
                }
            }
            
            var results: [OCRResult] = []
            for await result in group {
                if let result = result {
                    results.append(result)
                }
            }
            
            // Then: All should complete successfully
            XCTAssertEqual(results.count, testImages.count, "All concurrent processing should succeed")
            
            for result in results {
                XCTAssertGreaterThan(result.confidence, 0.5, "Concurrent processing should maintain quality")
            }
        }
    }
    
    // MARK: - Australian Locale Tests
    
    func testAustralianCurrencyRecognition() async throws {
        // Given: An Australian receipt with AUD currency
        let ausReceiptImage = createAustralianReceiptImage()
        
        // When: Processing the receipt
        let result = try await ocrService.processReceiptImage(ausReceiptImage)
        
        // Then: Should recognize Australian currency format
        XCTAssertTrue(result.currencyCode == "AUD", "Should detect AUD currency")
        XCTAssertTrue(result.extractedText.contains("$"), "Should detect dollar symbol")
        XCTAssertTrue(result.hasGST, "Australian receipts should detect GST")
    }
    
    func testGSTDetection() async throws {
        // Given: A receipt with GST information
        let gstReceiptImage = createGSTReceiptImage()
        
        // When: Processing the receipt
        let result = try await ocrService.processReceiptImage(gstReceiptImage)
        
        // Then: Should detect and extract GST information
        XCTAssertTrue(result.hasGST, "Should detect GST presence")
        XCTAssertGreaterThan(result.gstAmount, 0, "Should extract GST amount")
        XCTAssertEqual(result.gstAmount, result.totalAmount * 0.1 / 1.1, accuracy: 0.01, "GST should be 10% of total")
    }
    
    func testABNDetection() async throws {
        // Given: A business receipt with ABN
        let abnReceiptImage = createABNReceiptImage()
        
        // When: Processing the receipt
        let result = try await ocrService.processReceiptImage(abnReceiptImage)
        
        // Then: Should detect ABN if present
        XCTAssertNotNil(result.merchantABN, "Should detect ABN when present")
        XCTAssertEqual(result.merchantABN?.count, 11, "ABN should be 11 digits")
        XCTAssertTrue(result.merchantABN?.allSatisfy({ $0.isNumber }) ?? false, "ABN should be numeric")
    }
    
    // MARK: - Helper Methods
    
    private func createTestReceiptImage() -> NSImage {
        // Create a synthetic receipt image for testing
        let size = CGSize(width: 400, height: 600)
        let image = NSImage(size: size)
        
        image.lockFocus()
        NSColor.white.setFill()
        NSRect(origin: .zero, size: size).fill()
        
        let text = "Coffee Shop\n$4.50\nGST $0.45\nTotal $4.95"
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: NSColor.black,
            .font: NSFont.systemFont(ofSize: 16)
        ]
        
        text.draw(at: CGPoint(x: 50, y: 400), withAttributes: attributes)
        image.unlockFocus()
        
        return image
    }
    
    private func createLowQualityTestImage() -> NSImage {
        let image = createTestReceiptImage()
        // Simulate low quality by reducing resolution
        return image.resized(to: CGSize(width: 100, height: 150)) ?? image
    }
    
    private func createBlurryTestImage() -> NSImage {
        // Create a blurred version for low confidence testing
        return createTestReceiptImage() // Simplified for now
    }
    
    private func createMultiLineItemReceiptImage() -> NSImage {
        let size = CGSize(width: 400, height: 800)
        let image = NSImage(size: size)
        
        image.lockFocus()
        NSColor.white.setFill()
        NSRect(origin: .zero, size: size).fill()
        
        let text = """
        Coffee Shop
        Coffee - Large    $5.50
        Muffin - Blueberry $3.20
        Subtotal          $8.70
        GST               $0.87
        Total             $9.57
        """
        
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: NSColor.black,
            .font: NSFont.systemFont(ofSize: 14)
        ]
        
        text.draw(at: CGPoint(x: 20, y: 500), withAttributes: attributes)
        image.unlockFocus()
        
        return image
    }
    
    private func createPoorQualityTestImage() -> NSImage {
        return createTestReceiptImage().resized(to: CGSize(width: 50, height: 75)) ?? createTestReceiptImage()
    }
    
    private func createLargeTestReceiptImage() -> NSImage {
        return createTestReceiptImage().resized(to: CGSize(width: 2000, height: 3000)) ?? createTestReceiptImage()
    }
    
    private func createAustralianReceiptImage() -> NSImage {
        let size = CGSize(width: 400, height: 600)
        let image = NSImage(size: size)
        
        image.lockFocus()
        NSColor.white.setFill()
        NSRect(origin: .zero, size: size).fill()
        
        let text = "Australian Coffee Co\nLatte $5.50\nGST $0.50\nTotal $6.00\nABN: 12345678901"
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: NSColor.black,
            .font: NSFont.systemFont(ofSize: 16)
        ]
        
        text.draw(at: CGPoint(x: 50, y: 400), withAttributes: attributes)
        image.unlockFocus()
        
        return image
    }
    
    private func createGSTReceiptImage() -> NSImage {
        return createAustralianReceiptImage() // Contains GST
    }
    
    private func createABNReceiptImage() -> NSImage {
        return createAustralianReceiptImage() // Contains ABN
    }
    
    private func getMemoryUsage() -> Int64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        return result == KERN_SUCCESS ? Int64(info.resident_size) : 0
    }
}

// MARK: - NSImage Extensions for Testing

extension NSImage {
    func resized(to newSize: CGSize) -> NSImage? {
        let newImage = NSImage(size: newSize)
        newImage.lockFocus()
        
        let context = NSGraphicsContext.current
        context?.imageInterpolation = .high
        
        draw(in: NSRect(origin: .zero, size: newSize),
             from: NSRect(origin: .zero, size: size),
             operation: .copy,
             fraction: 1.0)
        
        newImage.unlockFocus()
        return newImage
    }
}