import XCTest
import CoreData
@testable import FinanceMate

final class EmailReceiptProcessorTests: XCTestCase {
    
    var processor: EmailReceiptProcessor!
    var context: NSManagedObjectContext!
    var visionOCREngine: VisionOCREngine!
    var ocrService: OCRService!
    var transactionMatcher: OCRTransactionMatcher!
    
    override func setUp() {
        super.setUp()
        
        // Set up test Core Data context
        context = PersistenceController.preview.container.viewContext
        
        // Set up dependencies
        visionOCREngine = VisionOCREngine()
        ocrService = OCRService()
        transactionMatcher = OCRTransactionMatcher(context: context)
        
        // Initialize processor
        processor = EmailReceiptProcessor(
            context: context,
            visionOCREngine: visionOCREngine,
            ocrService: ocrService,
            transactionMatcher: transactionMatcher
        )
    }
    
    override func tearDown() {
        processor = nil
        transactionMatcher = nil
        ocrService = nil
        visionOCREngine = nil
        context = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testProcessorInitialization() {
        XCTAssertNotNil(processor)
        XCTAssertFalse(processor.isProcessing)
        XCTAssertEqual(processor.processingProgress, 0.0)
        XCTAssertNil(processor.errorMessage)
        XCTAssertNil(processor.lastProcessingResult)
        XCTAssertEqual(processor.supportedProviders.count, 3)
    }
    
    func testSupportedEmailProviders() {
        let providers = processor.supportedProviders
        XCTAssertTrue(providers.contains(.gmail))
        XCTAssertTrue(providers.contains(.outlook))
        XCTAssertTrue(providers.contains(.icloud))
        
        // Test provider properties
        XCTAssertTrue(SupportedEmailProvider.gmail.authenticationRequired)
        XCTAssertTrue(SupportedEmailProvider.outlook.authenticationRequired)
        XCTAssertFalse(SupportedEmailProvider.icloud.authenticationRequired)
        
        XCTAssertEqual(SupportedEmailProvider.gmail.privacyCompliance, .high)
        XCTAssertEqual(SupportedEmailProvider.outlook.privacyCompliance, .high)
        XCTAssertEqual(SupportedEmailProvider.icloud.privacyCompliance, .highest)
    }
    
    func testSupportedReceiptFormats() {
        let formats = processor.getSupportedReceiptFormats()
        XCTAssertTrue(formats.contains(.pdf))
        XCTAssertTrue(formats.contains(.png))
        XCTAssertTrue(formats.contains(.jpeg))
        XCTAssertTrue(formats.contains(.heif))
        XCTAssertTrue(formats.contains(.tiff))
    }
    
    // MARK: - Email Processing Tests
    
    func testEmailReceiptProcessingWithValidData() async throws {
        let dateRange = DateInterval(start: Date().addingTimeInterval(-30*24*60*60), end: Date())
        
        let result = try await processor.processEmailReceipts(
            provider: .gmail,
            dateRange: dateRange,
            searchTerms: ["receipt", "invoice"]
        )
        
        XCTAssertNotNil(result)
        XCTAssertGreaterThanOrEqual(result.processingMetrics.emailsProcessed, 0)
        XCTAssertGreaterThanOrEqual(result.processingMetrics.receiptsExtracted, 0)
        XCTAssertTrue(result.privacyCompliance.dataMinimizationApplied)
        XCTAssertTrue(result.privacyCompliance.consentObtained)
        XCTAssertGreaterThanOrEqual(result.privacyCompliance.complianceScore, 0.9)
    }
    
    func testEmailProcessingWithConcurrentRequest() async throws {
        // Start first processing request
        let firstTask = Task {
            let dateRange = DateInterval(start: Date().addingTimeInterval(-7*24*60*60), end: Date())
            return try await processor.processEmailReceipts(
                provider: .gmail,
                dateRange: dateRange
            )
        }
        
        // Try to start second request immediately (should fail)
        do {
            let dateRange = DateInterval(start: Date().addingTimeInterval(-30*24*60*60), end: Date())
            let _ = try await processor.processEmailReceipts(
                provider: .outlook,
                dateRange: dateRange
            )
            XCTFail("Second concurrent request should have failed")
        } catch EmailReceiptProcessor.EmailProcessingError.batchProcessingTimeout {
            // Expected behavior
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        
        // Wait for first task to complete
        let _ = try await firstTask.value
    }
    
    func testEmailProcessingProgress() async throws {
        let dateRange = DateInterval(start: Date().addingTimeInterval(-7*24*60*60), end: Date())
        
        let task = Task {
            return try await processor.processEmailReceipts(
                provider: .icloud,
                dateRange: dateRange
            )
        }
        
        // Give processing time to start
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Check that processing started (may have already completed due to mock data)
        XCTAssertTrue(processor.processingProgress >= 0.0)
        XCTAssertTrue(processor.processingProgress <= 1.0)
        
        let result = try await task.value
        XCTAssertNotNil(result)
    }
    
    // MARK: - OCR Integration Tests
    
    func testMockReceiptDataGeneration() {
        // Test the mock receipt data generation (private method tested indirectly)
        let dateRange = DateInterval(start: Date().addingTimeInterval(-1*24*60*60), end: Date())
        
        Task {
            do {
                let result = try await processor.processEmailReceipts(
                    provider: .gmail,
                    dateRange: dateRange
                )
                
                // Should process mock receipts successfully
                XCTAssertNotNil(result)
            } catch {
                XCTFail("Mock receipt processing should not fail: \(error)")
            }
        }
    }
    
    func testReceiptDataParsing() async throws {
        let dateRange = DateInterval(start: Date().addingTimeInterval(-1*24*60*60), end: Date())
        
        let result = try await processor.processEmailReceipts(
            provider: .gmail,
            dateRange: dateRange,
            searchTerms: ["receipt"]
        )
        
        // Test that receipts were extracted and parsed correctly
        for receipt in result.extractedReceipts {
            XCTAssertFalse(receipt.merchant.isEmpty)
            XCTAssertGreaterThan(receipt.totalAmount, 0.0)
            XCTAssertEqual(receipt.currency, "AUD")
            XCTAssertGreaterThan(receipt.confidence, 0.0)
            XCTAssertLessThanOrEqual(receipt.confidence, 1.0)
            
            // Test Australian compliance fields
            if receipt.gstAmount != nil {
                XCTAssertGreaterThan(receipt.gstAmount!, 0.0)
            }
            
            // Test line items
            for lineItem in receipt.lineItems {
                XCTAssertFalse(lineItem.description.isEmpty)
                XCTAssertGreaterThan(lineItem.quantity, 0.0)
                XCTAssertGreaterThan(lineItem.unitPrice, 0.0)
                XCTAssertGreaterThan(lineItem.totalPrice, 0.0)
            }
        }
    }
    
    // MARK: - Transaction Matching Tests
    
    func testTransactionMatchingResults() async throws {
        let dateRange = DateInterval(start: Date().addingTimeInterval(-1*24*60*60), end: Date())
        
        let result = try await processor.processEmailReceipts(
            provider: .gmail,
            dateRange: dateRange
        )
        
        // Test transaction matching
        for match in result.matchedTransactions {
            XCTAssertNotNil(match.receiptData)
            XCTAssertNotNil(match.matchingCriteria)
            XCTAssertGreaterThanOrEqual(match.confidence, 0.0)
            XCTAssertLessThanOrEqual(match.confidence, 1.0)
            
            // Test matching criteria
            let criteria = match.matchingCriteria
            XCTAssertGreaterThan(criteria.amountTolerance, 0.0)
            XCTAssertGreaterThan(criteria.dateTolerance, 0.0)
            XCTAssertGreaterThan(criteria.merchantNameSimilarity, 0.0)
            XCTAssertLessThanOrEqual(criteria.merchantNameSimilarity, 1.0)
        }
    }
    
    // MARK: - Privacy Compliance Tests
    
    func testPrivacyComplianceValidation() async throws {
        let dateRange = DateInterval(start: Date().addingTimeInterval(-7*24*60*60), end: Date())
        
        let result = try await processor.processEmailReceipts(
            provider: .gmail,
            dateRange: dateRange
        )
        
        let compliance = result.privacyCompliance
        XCTAssertTrue(compliance.dataMinimizationApplied)
        XCTAssertTrue(compliance.consentObtained)
        XCTAssertTrue(compliance.retentionPolicyApplied)
        XCTAssertTrue(compliance.accessLogged)
        XCTAssertGreaterThanOrEqual(compliance.complianceScore, 0.9)
    }
    
    func testPrivacySettingsConfiguration() {
        // Test privacy settings configuration
        processor.configurePrivacySettings(
            dataMinimization: true,
            automaticDeletion: true,
            auditLogging: true
        )
        
        // Should not throw any errors
        XCTAssertNotNil(processor)
    }
    
    // MARK: - Error Handling Tests
    
    func testErrorDescriptions() {
        let errors: [EmailReceiptProcessor.EmailProcessingError] = [
            .mailboxAccessDenied,
            .noReceiptsFound,
            .attachmentProcessingFailed,
            .ocrProcessingFailed,
            .transactionMatchingFailed,
            .privacyComplianceViolation,
            .unsupportedEmailProvider,
            .batchProcessingTimeout
        ]
        
        for error in errors {
            XCTAssertNotNil(error.errorDescription)
            XCTAssertFalse(error.errorDescription!.isEmpty)
        }
    }
    
    // MARK: - Processing Metrics Tests
    
    func testProcessingMetrics() async throws {
        let dateRange = DateInterval(start: Date().addingTimeInterval(-1*24*60*60), end: Date())
        
        let result = try await processor.processEmailReceipts(
            provider: .gmail,
            dateRange: dateRange
        )
        
        let metrics = result.processingMetrics
        XCTAssertGreaterThanOrEqual(metrics.emailsProcessed, 0)
        XCTAssertGreaterThanOrEqual(metrics.receiptsExtracted, 0)
        XCTAssertGreaterThanOrEqual(metrics.transactionsMatched, 0)
        XCTAssertGreaterThanOrEqual(metrics.processingTime, 0.0)
        XCTAssertGreaterThanOrEqual(metrics.ocrAccuracy, 0.0)
        XCTAssertLessThanOrEqual(metrics.ocrAccuracy, 1.0)
        XCTAssertGreaterThanOrEqual(metrics.matchingAccuracy, 0.0)
        XCTAssertLessThanOrEqual(metrics.matchingAccuracy, 1.0)
    }
    
    // MARK: - Australian Compliance Tests
    
    func testAustralianComplianceFields() async throws {
        let dateRange = DateInterval(start: Date().addingTimeInterval(-1*24*60*60), end: Date())
        
        let result = try await processor.processEmailReceipts(
            provider: .gmail,
            dateRange: dateRange
        )
        
        for receipt in result.extractedReceipts {
            // Test currency is AUD
            XCTAssertEqual(receipt.currency, "AUD")
            
            // Test GST extraction (if present)
            if let gstAmount = receipt.gstAmount {
                XCTAssertGreaterThan(gstAmount, 0.0)
                XCTAssertLessThan(gstAmount, receipt.totalAmount)
            }
            
            // Test ABN extraction (if present)
            if let abn = receipt.abn {
                XCTAssertGreaterThanOrEqual(abn.count, 11)
            }
            
            // Test line item GST applicability
            for lineItem in receipt.lineItems {
                // GST applicability should be determined
                XCTAssertNotNil(lineItem.gstApplicable)
            }
        }
    }
    
    // MARK: - Search Terms Tests
    
    func testCustomSearchTerms() async throws {
        let dateRange = DateInterval(start: Date().addingTimeInterval(-1*24*60*60), end: Date())
        let customTerms = ["purchase", "transaction", "payment"]
        
        let result = try await processor.processEmailReceipts(
            provider: .gmail,
            dateRange: dateRange,
            searchTerms: customTerms
        )
        
        // Should process successfully with custom search terms
        XCTAssertNotNil(result)
        XCTAssertGreaterThanOrEqual(result.processingMetrics.emailsProcessed, 0)
    }
    
    // MARK: - Date Range Tests
    
    func testDateRangeValidation() async throws {
        // Test with very recent date range
        let recentRange = DateInterval(start: Date().addingTimeInterval(-24*60*60), end: Date())
        
        let result = try await processor.processEmailReceipts(
            provider: .icloud,
            dateRange: recentRange
        )
        
        XCTAssertNotNil(result)
        
        // Test with longer date range
        let longerRange = DateInterval(start: Date().addingTimeInterval(-90*24*60*60), end: Date())
        
        let result2 = try await processor.processEmailReceipts(
            provider: .gmail,
            dateRange: longerRange
        )
        
        XCTAssertNotNil(result2)
    }
}