import Foundation
import CoreData

/// ViewModel for Extraction Health analytics dashboard
/// BLUEPRINT Line 156: Field-level accuracy, confidence distribution, merchant corrections
@MainActor
class ExtractionHealthViewModel: ObservableObject {
    private let context: NSManagedObjectContext

    @Published var totalExtractions: Int = 0
    @Published var autoApprovedPercent: Double = 0.0
    @Published var needsReviewPercent: Double = 0.0
    @Published var manualReviewPercent: Double = 0.0
    @Published var topCorrectedMerchants: [(merchant: String, count: Int)] = []

    // BLUEPRINT Line 156: Field-level accuracy metrics
    @Published var merchantAccuracy: Double = 0.0
    @Published var amountAccuracy: Double = 0.0
    @Published var gstAccuracy: Double = 0.0
    @Published var invoiceAccuracy: Double = 0.0

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func loadAnalytics() {
        // P0 FIX: Safe Calendar operations (2025-10-11)
        // SECURITY: Prevents crashes if Calendar date computation fails
        guard let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) else {
            NSLog("[ANALYTICS-ERROR] Failed to compute 30-day window")
            return
        }

        let request = ExtractionFeedback.fetchRequest()
        request.predicate = NSPredicate(format: "timestamp > %@", thirtyDaysAgo as NSDate)

        guard let feedbacks = try? context.fetch(request) else { return }

        totalExtractions = feedbacks.count

        // Confidence distribution (BLUEPRINT Line 156)
        if !feedbacks.isEmpty {
            let autoApproved = feedbacks.filter { $0.confidence > 0.9 }.count
            let needsReview = feedbacks.filter { $0.confidence >= 0.7 && $0.confidence <= 0.9 }.count
            let manual = feedbacks.filter { $0.confidence < 0.7 }.count

            autoApprovedPercent = Double(autoApproved) / Double(feedbacks.count)
            needsReviewPercent = Double(needsReview) / Double(feedbacks.count)
            manualReviewPercent = Double(manual) / Double(feedbacks.count)
        }

        // Top corrected merchants (BLUEPRINT Line 156.3)
        let merchantCounts = Dictionary(grouping: feedbacks, by: { $0.merchant })
            .mapValues { $0.count }
            .sorted { $0.value > $1.value }
            .prefix(5)

        topCorrectedMerchants = merchantCounts.map { (merchant: $0.key, count: $0.value) }

        // Field-level accuracy (BLUEPRINT Line 156.5)
        computeFieldAccuracy(feedbacks: feedbacks)
    }

    private func computeFieldAccuracy(feedbacks: [ExtractionFeedback]) {
        // Group by field name
        let byField = Dictionary(grouping: feedbacks, by: { $0.fieldName })

        // Accuracy = (total - corrections) / total * 100
        // Correction detected when originalValue != correctedValue
        merchantAccuracy = calculateAccuracy(for: "merchant", in: byField)
        amountAccuracy = calculateAccuracy(for: "amount", in: byField)
        gstAccuracy = calculateAccuracy(for: "gst", in: byField)
        invoiceAccuracy = calculateAccuracy(for: "invoice", in: byField)
    }

    private func calculateAccuracy(for field: String, in grouped: [String: [ExtractionFeedback]]) -> Double {
        guard let items = grouped[field], !items.isEmpty else { return 0.0 }

        let correct = items.filter { $0.originalValue == $0.correctedValue }.count
        return (Double(correct) / Double(items.count)) * 100.0
    }

    func exportFeedbackData() {
        NSLog("[ANALYTICS] Exporting feedback data to CSV")
        // CSV export implementation deferred (KISS - future enhancement)
    }
}
