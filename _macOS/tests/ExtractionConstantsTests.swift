import XCTest
@testable import FinanceMate

/// Test extraction pipeline constants
/// ATOMIC: Code quality improvement - centralize magic numbers
class ExtractionConstantsTests: XCTestCase {

    func testExtractionThresholdsAreConfigurable() {
        // Verify tier thresholds match BLUEPRINT Section 3.1.1.4
        XCTAssertEqual(ExtractionConstants.tier1ConfidenceThreshold, 0.8, "Tier 1 regex threshold")
        XCTAssertEqual(ExtractionConstants.tier2ConfidenceThreshold, 0.7, "Tier 2 Foundation Models threshold")
        XCTAssertEqual(ExtractionConstants.manualReviewConfidence, 0.3, "Tier 3 manual review confidence")
    }

    func testBadgeThresholdsMatchBLUEPRINT() {
        // BLUEPRINT Line 130: Confidence badge thresholds
        XCTAssertEqual(ExtractionConstants.autoApprovedThreshold, 0.9, "Green badge threshold")
        XCTAssertEqual(ExtractionConstants.needsReviewThreshold, 0.7, "Yellow badge threshold")
    }

    func testPerformanceLimits() {
        // Extraction pipeline constraints
        XCTAssertEqual(ExtractionConstants.maxConcurrentExtractions, 5, "Concurrent TaskGroup limit")
        XCTAssertEqual(ExtractionConstants.extractionTimeout, 10.0, "Extraction timeout in seconds")
    }
}
