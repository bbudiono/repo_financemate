import XCTest
import CoreData
@testable import FinanceMate

/// Tests for Extraction Health Analytics ViewModel
/// BLUEPRINT Line 156: Field-level accuracy and metrics computation
class ExtractionHealthViewModelTests: XCTestCase {
    var context: NSManagedObjectContext!
    var viewModel: ExtractionHealthViewModel!

    override func setUp() {
        super.setUp()
        context = PersistenceController.preview.container.viewContext
        viewModel = ExtractionHealthViewModel(context: context)
    }

    override func tearDown() {
        // Clean up test data
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ExtractionFeedback")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        try? context.execute(deleteRequest)
        super.tearDown()
    }

    /// Test field-level accuracy computation from feedback data
    func testFieldLevelAccuracyComputation() {
        // BLUEPRINT Line 156: Field-level accuracy metrics
        // Create test feedback with corrections for different fields
        createFeedback(field: "merchant", correct: true, merchant: "Woolworths")
        createFeedback(field: "merchant", correct: true, merchant: "Woolworths")
        createFeedback(field: "merchant", correct: false, merchant: "Coles")

        createFeedback(field: "amount", correct: true, merchant: "Test")
        createFeedback(field: "amount", correct: false, merchant: "Test")

        createFeedback(field: "gst", correct: false, merchant: "Test")
        createFeedback(field: "gst", correct: false, merchant: "Test")

        createFeedback(field: "invoice", correct: false, merchant: "Test")

        viewModel.loadAnalytics()

        // Field-level accuracy = (total - corrections) / total
        // merchant: 2 correct / 3 total = 66.7%
        XCTAssertEqual(viewModel.merchantAccuracy, 66.7, accuracy: 1.0)

        // amount: 1 correct / 2 total = 50%
        XCTAssertEqual(viewModel.amountAccuracy, 50.0, accuracy: 1.0)

        // gst: 0 correct / 2 total = 0%
        XCTAssertEqual(viewModel.gstAccuracy, 0.0, accuracy: 1.0)

        // invoice: 0 correct / 1 total = 0%
        XCTAssertEqual(viewModel.invoiceAccuracy, 0.0, accuracy: 1.0)
    }

    /// Test confidence distribution computation
    func testConfidenceDistribution() {
        // Create feedback with varying confidence levels
        createFeedback(field: "merchant", correct: true, merchant: "Test1", confidence: 0.95)
        createFeedback(field: "merchant", correct: true, merchant: "Test2", confidence: 0.85)
        createFeedback(field: "merchant", correct: true, merchant: "Test3", confidence: 0.65)
        createFeedback(field: "merchant", correct: true, merchant: "Test4", confidence: 0.40)

        viewModel.loadAnalytics()

        // Auto-approved: >0.9 = 1 item = 25%
        XCTAssertEqual(viewModel.autoApprovedPercent, 0.25, accuracy: 0.01)

        // Needs review: 0.7-0.9 = 1 item = 25%
        XCTAssertEqual(viewModel.needsReviewPercent, 0.25, accuracy: 0.01)

        // Manual: <0.7 = 2 items = 50%
        XCTAssertEqual(viewModel.manualReviewPercent, 0.50, accuracy: 0.01)
    }

    /// Test top corrected merchants computation
    func testTopCorrectedMerchants() {
        // Create corrections for different merchants
        for _ in 0..<5 { createFeedback(field: "merchant", correct: false, merchant: "Woolworths") }
        for _ in 0..<3 { createFeedback(field: "amount", correct: false, merchant: "Coles") }
        for _ in 0..<2 { createFeedback(field: "gst", correct: false, merchant: "ALDI") }
        createFeedback(field: "invoice", correct: false, merchant: "IGA")

        viewModel.loadAnalytics()

        XCTAssertEqual(viewModel.topCorrectedMerchants.count, 4)
        XCTAssertEqual(viewModel.topCorrectedMerchants[0].merchant, "Woolworths")
        XCTAssertEqual(viewModel.topCorrectedMerchants[0].count, 5)
        XCTAssertEqual(viewModel.topCorrectedMerchants[1].merchant, "Coles")
        XCTAssertEqual(viewModel.topCorrectedMerchants[1].count, 3)
    }

    // MARK: - Helper Methods

    private func createFeedback(field: String, correct: Bool, merchant: String, confidence: Double = 0.8) {
        let feedback = ExtractionFeedback(context: context)
        feedback.id = UUID()
        feedback.emailID = UUID().uuidString
        feedback.fieldName = field
        feedback.originalValue = correct ? "correct_value" : "wrong_value"
        feedback.correctedValue = "correct_value"
        feedback.merchant = merchant
        feedback.timestamp = Date()
        feedback.wasHallucination = false
        feedback.confidence = confidence
        feedback.extractionTier = "tier2"

        try? context.save()
    }
}
