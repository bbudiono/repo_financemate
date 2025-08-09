import XCTest
import CoreData
import Combine
@testable import FinanceMate

/**
 * OCRViewModelTests.swift
 * 
 * Purpose: Comprehensive TDD unit tests for OCR MVVM integration layer with async processing and state management
 * Issues & Complexity Summary: Tests async workflows, state management, error handling, and UI integration patterns
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~350+
 *   - Core Algorithm Complexity: Medium-High
 *   - Dependencies: 4 (CoreData, Combine, XCTest, SwiftUI)
 *   - State Management Complexity: High
 *   - Novelty/Uncertainty Factor: Medium
 * AI Pre-Task Self-Assessment: 88%
 * Problem Estimate: 85%
 * Initial Code Complexity Estimate: 87%
 * Final Code Complexity: TBD
 * Overall Result Score: TBD
 * Key Variances/Learnings: MVVM pattern with comprehensive OCR workflow state management
 * Last Updated: 2025-07-08
 */

// EMERGENCY FIX: Removed to eliminate Swift Concurrency crashes
// COMPREHENSIVE FIX: Removed ALL Swift Concurrency patterns to eliminate TaskLocal crashes
final class OCRViewModelTests: XCTestCase {
    var viewModel: OCRViewModel!
    var testContext: NSManagedObjectContext!
    var persistenceController: PersistenceController!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        persistenceController = PersistenceController(inMemory: true)
        testContext = persistenceController.container.viewContext
        viewModel = OCRViewModel(context: testContext)
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        cancellables.removeAll()
        viewModel = nil
        testContext = nil
        persistenceController = nil
        super.tearDown()
    }
    
    // MARK: - State Management Tests
    
    func testInitialState() {
        // Given: Newly created OCR ViewModel
        
        // Then: Should have correct initial state
        XCTAssertFalse(viewModel.isProcessing, "Should not be processing initially")
        XCTAssertNil(viewModel.extractedData, "Should have no extracted data initially")
        XCTAssertNil(viewModel.matchedTransaction, "Should have no matched transaction initially")
        XCTAssertFalse(viewModel.showReviewInterface, "Should not show review interface initially")
        XCTAssertNil(viewModel.errorMessage, "Should have no error message initially")
        XCTAssertEqual(viewModel.processingStep, .idle, "Should be in idle step initially")
    }
    
    func testAsyncImageProcessing() {
        // Given: A test receipt image
        let testImage = createTestReceiptImage()
        let expectation = XCTestExpectation(description: "Processing completed")
        
        // Monitor state changes
        viewModel.$isProcessing
            .dropFirst() // Skip initial false value
            .sink { isProcessing in
                if !isProcessing {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When: Processing receipt image
        viewModel.processReceiptImage(testImage)
        
        // Wait for processing to complete
        fulfillment(of: [expectation], timeout: 2.0)
        
        // Then: Should complete processing with results
        XCTAssertFalse(viewModel.isProcessing, "Should not be processing after completion")
        XCTAssertNotNil(viewModel.extractedData, "Should have extracted data after processing")
        XCTAssertNil(viewModel.errorMessage, "Should have no error after successful processing")
    }
    
    func testProcessingSteps() {
        // Given: A test receipt image and step tracking
        let testImage = createTestReceiptImage()
        var observedSteps: [OCRProcessingStep] = []
        
        viewModel.$processingStep
            .sink { step in
                observedSteps.append(step)
            }
            .store(in: &cancellables)
        
        // When: Processing receipt image
        viewModel.processReceiptImage(testImage)
        
        // Then: Should progress through expected steps
        XCTAssertTrue(observedSteps.contains(.idle), "Should start with idle step")
        XCTAssertTrue(observedSteps.contains(.preprocessing), "Should include preprocessing step")
        XCTAssertTrue(observedSteps.contains(.textRecognition), "Should include text recognition step")
        XCTAssertTrue(observedSteps.contains(.dataExtraction), "Should include data extraction step")
        XCTAssertTrue(observedSteps.contains(.transactionMatching), "Should include transaction matching step")
        XCTAssertTrue(observedSteps.contains(.completed), "Should end with completed step")
    }
    
    func testProgressTracking() {
        // Given: A test receipt image and progress tracking
        let testImage = createTestReceiptImage()
        var progressValues: [Double] = []
        
        viewModel.$progress
            .sink { progress in
                progressValues.append(progress)
            }
            .store(in: &cancellables)
        
        // When: Processing receipt image
        viewModel.processReceiptImage(testImage)
        
        // Then: Should show progress increasing
        XCTAssertTrue(progressValues.first == 0.0, "Should start with 0% progress")
        XCTAssertTrue(progressValues.last == 1.0, "Should end with 100% progress")
        XCTAssertTrue(progressValues.count > 3, "Should have multiple progress updates")
        
        // Verify progress is non-decreasing
        for i in 1..<progressValues.count {
            XCTAssertGreaterThanOrEqual(progressValues[i], progressValues[i-1], 
                                      "Progress should be non-decreasing")
        }
    }
    
    // MARK: - Error Handling Tests
    
    func testErrorStateHandling() {
        // Given: An invalid image that will cause processing to fail
        let invalidImage = NSImage() // Empty image
        
        // When: Processing invalid image
        viewModel.processReceiptImage(invalidImage)
        
        // Then: Should handle error gracefully
        XCTAssertFalse(viewModel.isProcessing, "Should not be processing after error")
        XCTAssertNotNil(viewModel.errorMessage, "Should have error message after failure")
        XCTAssertNil(viewModel.extractedData, "Should have no extracted data after error")
        XCTAssertEqual(viewModel.processingStep, .failed, "Should be in failed step after error")
    }
    
    func testLowConfidenceHandling() {
        // Given: An image that will produce low confidence results
        let lowQualityImage = createLowQualityTestImage()
        
        // When: Processing low quality image
        viewModel.processReceiptImage(lowQualityImage)
        
        // Then: Should trigger manual review for low confidence
        XCTAssertTrue(viewModel.showReviewInterface, "Should show review interface for low confidence")
        XCTAssertNotNil(viewModel.extractedData, "Should still have extracted data")
        XCTAssertEqual(viewModel.processingStep, .reviewRequired, "Should be in review required step")
    }
    
    func testErrorRecovery() {
        // Given: An initial error state
        viewModel.processReceiptImage(NSImage()) // Cause error
        XCTAssertNotNil(viewModel.errorMessage, "Should have error after invalid processing")
        
        // When: Processing a valid image after error
        let validImage = createTestReceiptImage()
        viewModel.processReceiptImage(validImage)
        
        // Then: Should clear error and process successfully
        XCTAssertNil(viewModel.errorMessage, "Should clear error after successful processing")
        XCTAssertNotNil(viewModel.extractedData, "Should have extracted data after recovery")
        XCTAssertEqual(viewModel.processingStep, .completed, "Should be in completed step after recovery")
    }
    
    // MARK: - Transaction Integration Tests
    
    func testTransactionMatching() {
        // Given: An existing transaction that should match
        let amount = 25.50
        let date = Date()
        let merchantName = "Test Cafe"
        
        let existingTransaction = createTestTransaction(
            amount: amount,
            date: date,
            note: merchantName
        )
        
        // Create a test image that will generate matching OCR result
        let testImage = createTestReceiptImageWithData(
            amount: amount,
            date: date,
            merchant: merchantName
        )
        
        // When: Processing receipt that matches existing transaction
        viewModel.processReceiptImage(testImage)
        
        // Then: Should find and link to existing transaction
        XCTAssertNotNil(viewModel.matchedTransaction, "Should find matching transaction")
        XCTAssertEqual(viewModel.matchedTransaction?.id, existingTransaction.id, "Should match correct transaction")
        XCTAssertEqual(viewModel.processingStep, .completed, "Should complete successfully with match")
    }
    
    func testLineItemCreation() {
        // Given: An existing transaction and receipt with line items
        let existingTransaction = createTestTransaction(
            amount: 15.75,
            date: Date(),
            note: "Grocery Store"
        )
        
        let testImage = createMultiLineItemReceiptImage()
        
        // When: Processing receipt with line items
        viewModel.processReceiptImage(testImage)
        
        // Manually set matched transaction for testing
        viewModel.matchedTransaction = existingTransaction
        viewModel.createLineItemsFromOCR()
        
        // Then: Should create line items for the transaction
        let lineItems = existingTransaction.lineItems
        XCTAssertGreaterThan(lineItems.count, 0, "Should create line items from OCR")
        
        // Verify line item details
        if let firstItem = lineItems.first {
            XCTAssertFalse(firstItem.itemDescription.isEmpty, "Line item should have description")
            XCTAssertGreaterThan(firstItem.amount, 0, "Line item should have positive amount")
        }
    }
    
    func testNoMatchScenario() {
        // Given: A receipt that won't match any existing transactions
        let testImage = createTestReceiptImageWithData(
            amount: 999.99,
            date: Date(),
            merchant: "Nonexistent Store"
        )
        
        // When: Processing receipt with no matches
        viewModel.processReceiptImage(testImage)
        
        // Then: Should process successfully but have no match
        XCTAssertNotNil(viewModel.extractedData, "Should have extracted data")
        XCTAssertNil(viewModel.matchedTransaction, "Should have no matched transaction")
        XCTAssertEqual(viewModel.processingStep, .completed, "Should complete successfully")
    }
    
    // MARK: - Memory Management Tests
    
    func testMemoryManagement() {
        // Given: Multiple large image processing operations
        let largeImages = (0..<5).map { _ in createLargeTestReceiptImage() }
        
        // When: Processing multiple large images
        for image in largeImages {
            viewModel.processReceiptImage(image)
            // Clear previous results to simulate real usage
            viewModel.clearResults()
        }
        
        // Then: Should not leak memory or crash
        XCTAssertNil(viewModel.extractedData, "Should clear extracted data")
        XCTAssertNil(viewModel.matchedTransaction, "Should clear matched transaction")
        XCTAssertFalse(viewModel.isProcessing, "Should not be processing")
    }
    
    func testConcurrentProcessing() {
        // Given: Multiple processing requests
        let images = [
            createTestReceiptImage(),
            createTestReceiptImage(),
            createTestReceiptImage()
        ]
        
        // When: Starting multiple processing operations concurrently
        withTaskGroup(of: Void.self) { group in
            for image in images {
                group.add// EMERGENCY FIX: Removed Task block - immediate execution
// COMPREHENSIVE FIX: Removed ALL Swift Concurrency patterns to eliminate TaskLocal crashes
        self.viewModel.processReceiptImage(image)
            }
        }
        
        // Then: Should handle concurrent requests gracefully
        XCTAssertFalse(viewModel.isProcessing, "Should not be processing after completion")
        XCTAssertNotNil(viewModel.extractedData, "Should have final extracted data")
    }
    
    // MARK: - UI Integration Tests
    
    func testReviewInterfaceFlow() {
        // Given: A low confidence result that triggers review
        let lowQualityImage = createLowQualityTestImage()
        
        // When: Processing low quality image
        viewModel.processReceiptImage(lowQualityImage)
        
        // Then: Should show review interface
        XCTAssertTrue(viewModel.showReviewInterface, "Should show review interface")
        
        // When: User approves the results
        viewModel.approveOCRResults()
        
        // Then: Should proceed to completion
        XCTAssertFalse(viewModel.showReviewInterface, "Should hide review interface")
        XCTAssertEqual(viewModel.processingStep, .completed, "Should complete after approval")
    }
    
    func testManualCorrection() {
        // Given: OCR results that need correction
        viewModel.processReceiptImage(createTestReceiptImage())
        
        guard let originalData = viewModel.extractedData else {
            XCTFail("Should have extracted data")
            return
        }
        
        // When: User makes manual corrections
        let correctedAmount = 99.99
        let correctedMerchant = "Corrected Store Name"
        
        viewModel.updateExtractedAmount(correctedAmount)
        viewModel.updateMerchantName(correctedMerchant)
        
        // Then: Should update the extracted data
        XCTAssertEqual(viewModel.extractedData?.totalAmount, correctedAmount, "Should update amount")
        XCTAssertEqual(viewModel.extractedData?.merchantName, correctedMerchant, "Should update merchant name")
        XCTAssertTrue(viewModel.extractedData?.manuallyEdited ?? false, "Should mark as manually edited")
    }
    
    // MARK: - Performance Tests
    
    func testProcessingPerformance() {
        // Given: A standard test receipt
        let testImage = createTestReceiptImage()
        
        // When: Measuring processing performance
        measure {
            // EMERGENCY FIX: Removed Task block - immediate execution
// COMPREHENSIVE FIX: Removed ALL Swift Concurrency patterns to eliminate TaskLocal crashes
        viewModel.processReceiptImage(testImage)
        }
    }
    
    // MARK: - Helper Methods
    
    private func createTestTransaction(amount: Double, date: Date, note: String) -> Transaction {
        let transaction = Transaction.create(
            in: testContext,
            amount: amount,
            category: "General"
        )
        transaction.date = date
        transaction.note = note
        transaction.createdAt = Date()
        
        try! testContext.save()
        return transaction
    }
    
    private func createTestReceiptImage() -> NSImage {
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
    
    private func createTestReceiptImageWithData(amount: Double, date: Date, merchant: String) -> NSImage {
        let size = CGSize(width: 400, height: 600)
        let image = NSImage(size: size)
        
        image.lockFocus()
        NSColor.white.setFill()
        NSRect(origin: .zero, size: size).fill()
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        let dateString = formatter.string(from: date)
        
        let text = "\(merchant)\n\(dateString)\nTotal $\(String(format: "%.2f", amount))"
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: NSColor.black,
            .font: NSFont.systemFont(ofSize: 16)
        ]
        
        text.draw(at: CGPoint(x: 50, y: 400), withAttributes: attributes)
        image.unlockFocus()
        
        return image
    }
    
    private func createLowQualityTestImage() -> NSImage {
        return createTestReceiptImage().resized(to: CGSize(width: 50, height: 75)) ?? createTestReceiptImage()
    }
    
    private func createMultiLineItemReceiptImage() -> NSImage {
        let size = CGSize(width: 400, height: 800)
        let image = NSImage(size: size)
        
        image.lockFocus()
        NSColor.white.setFill()
        NSRect(origin: .zero, size: size).fill()
        
        let text = """
        Grocery Store
        Bread          $3.50
        Milk           $4.20
        Eggs           $5.50
        Subtotal      $13.20
        GST            $1.32
        Total         $14.52
        """
        
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: NSColor.black,
            .font: NSFont.systemFont(ofSize: 14)
        ]
        
        text.draw(at: CGPoint(x: 20, y: 500), withAttributes: attributes)
        image.unlockFocus()
        
        return image
    }
    
    private func createLargeTestReceiptImage() -> NSImage {
        return createTestReceiptImage().resized(to: CGSize(width: 2000, height: 3000)) ?? createTestReceiptImage()
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

// MARK: - Mock Processing Steps

enum OCRProcessingStep {
    case idle
    case preprocessing
    case textRecognition
    case dataExtraction
    case transactionMatching
    case reviewRequired
    case completed
    case failed
}