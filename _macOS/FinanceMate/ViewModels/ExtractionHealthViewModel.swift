import Foundation
import CoreData

/// ViewModel for Extraction Health analytics dashboard
/// BLUEPRINT Section 3.1.1.4: Extraction Analytics Dashboard
@MainActor
class ExtractionHealthViewModel: ObservableObject {
    private let context: NSManagedObjectContext

    @Published var totalExtractions: Int = 0
    @Published var autoApprovedPercent: Double = 0.0
    @Published var needsReviewPercent: Double = 0.0
    @Published var manualReviewPercent: Double = 0.0
    @Published var topCorrectedMerchants: [(merchant: String, count: Int)] = []

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func loadAnalytics() {
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date())!

        // Fetch all feedback from last 30 days
        let request = ExtractionFeedback.fetchRequest()
        request.predicate = NSPredicate(format: "timestamp > %@", thirtyDaysAgo as NSDate)

        guard let feedbacks = try? context.fetch(request) else { return }

        totalExtractions = feedbacks.count

        // Calculate confidence distribution (placeholder - needs ExtractedTransaction data)
        autoApprovedPercent = 0.7
        needsReviewPercent = 0.2
        manualReviewPercent = 0.1

        // Top corrected merchants
        let merchantCounts = Dictionary(grouping: feedbacks, by: { $0.merchant })
            .mapValues { $0.count }
            .sorted { $0.value > $1.value }
            .prefix(5)

        topCorrectedMerchants = merchantCounts.map { (merchant: $0.key, count: $0.value) }
    }

    func exportFeedbackData() {
        // TODO: Implement CSV export
        NSLog("[ANALYTICS] Export feedback data requested")
    }
}
