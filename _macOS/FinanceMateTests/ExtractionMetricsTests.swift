import XCTest
import CoreData
@testable import FinanceMate

/// Test suite for ExtractionMetrics Core Data entity (BLUEPRINT Line 192)
/// Validates daily aggregation of extraction performance metrics
final class ExtractionMetricsTests: XCTestCase {
    var context: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        context = PersistenceController.preview.container.viewContext
    }

    override func tearDown() {
        context = nil
        super.tearDown()
    }

    // RED: Test entity creation with all 10 required fields
    func testExtractionMetricsEntityCreation() {
        let metrics = ExtractionMetrics(context: context)

        metrics.date = Date()
        metrics.totalExtractions = 50
        metrics.tier1Count = 10
        metrics.tier2Count = 35
        metrics.tier3Count = 5
        metrics.avgExtractionTime = 1.72
        metrics.avgConfidence = 0.83
        metrics.hallucinationCount = 2
        metrics.errorCount = 3
        metrics.cacheHitRate = 0.45

        XCTAssertNotNil(metrics)
        XCTAssertEqual(metrics.totalExtractions, 50)
        XCTAssertEqual(metrics.tier1Count, 10)
        XCTAssertEqual(metrics.tier2Count, 35)
        XCTAssertEqual(metrics.tier3Count, 5)
        XCTAssertEqual(metrics.avgExtractionTime, 1.72, accuracy: 0.01)
        XCTAssertEqual(metrics.avgConfidence, 0.83, accuracy: 0.01)
        XCTAssertEqual(metrics.hallucinationCount, 2)
        XCTAssertEqual(metrics.errorCount, 3)
        XCTAssertEqual(metrics.cacheHitRate, 0.45, accuracy: 0.01)
    }

    // RED: Test default values
    func testExtractionMetricsDefaultValues() {
        let metrics = ExtractionMetrics(context: context)
        metrics.date = Date()

        XCTAssertEqual(metrics.totalExtractions, 0)
        XCTAssertEqual(metrics.tier1Count, 0)
        XCTAssertEqual(metrics.tier2Count, 0)
        XCTAssertEqual(metrics.tier3Count, 0)
        XCTAssertEqual(metrics.avgExtractionTime, 0.0)
        XCTAssertEqual(metrics.avgConfidence, 0.0)
        XCTAssertEqual(metrics.hallucinationCount, 0)
        XCTAssertEqual(metrics.errorCount, 0)
        XCTAssertEqual(metrics.cacheHitRate, 0.0)
    }

    // RED: Test persistence
    func testExtractionMetricsPersistence() throws {
        let metrics = ExtractionMetrics(context: context)
        metrics.date = Date()
        metrics.totalExtractions = 100
        metrics.avgConfidence = 0.91

        try context.save()

        let fetchRequest = ExtractionMetrics.fetchRequest()
        let results = try context.fetch(fetchRequest)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.totalExtractions, 100)
        XCTAssertEqual(results.first?.avgConfidence, 0.91, accuracy: 0.01)
    }
}
