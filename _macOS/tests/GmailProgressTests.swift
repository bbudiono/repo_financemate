import XCTest
@testable import FinanceMate

/// PHASE 1: Gmail Progress Counter Tests - RED
/// Tests missing accurate progress counters and ETA calculation
final class GmailProgressTests: XCTestCase {

    func testGmailPagination_ProgressCountersAreAccurate() async throws {
        let totalTarget = 100
        let processedSoFar = 75
        let uniqueEmails = 68
        let duplicatesFiltered = 7
        let fetchErrors = 2
        let startTime = Date().addingTimeInterval(-30)

        let progress = GmailPaginationEnhancer.createProgressSnapshot(
            totalTarget: totalTarget,
            processedSoFar: processedSoFar,
            currentPage: 3,
            uniqueEmails: uniqueEmails,
            duplicatesFiltered: duplicatesFiltered,
            fetchErrors: fetchErrors,
            estimatedTotal: 120,
            startTime: startTime
        )

        XCTAssertEqual(progress.totalTarget, totalTarget, "Should track total target")
        XCTAssertEqual(progress.processedSoFar, processedSoFar, "Should track processed count")
        XCTAssertEqual(progress.uniqueEmailsFound, uniqueEmails, "Should track unique emails")
        XCTAssertEqual(progress.duplicatesFiltered, duplicatesFiltered, "Should track duplicates")
        XCTAssertEqual(progress.fetchErrors, fetchErrors, "Should track errors")

        XCTAssertEqual(progress.processedPercentage, 0.75, accuracy: 0.01, "Should calculate 75% processed")
        XCTAssertGreaterThan(progress.emailsPerSecond, 2.0, "Should calculate reasonable rate")
        XCTAssertNotNil(progress.estimatedTimeRemaining, "Should calculate ETA")
    }

    func testGmailPagination_ETACalculationIsRealistic() async throws {
        let startTime = Date().addingTimeInterval(-60)
        let processedSoFar = 30
        let totalTarget = 100

        let progress = GmailPaginationEnhancer.createProgressSnapshot(
            totalTarget: totalTarget,
            processedSoFar: processedSoFar,
            currentPage: 2,
            uniqueEmails: 28,
            duplicatesFiltered: 2,
            fetchErrors: 0,
            estimatedTotal: totalTarget,
            startTime: startTime
        )

        XCTAssertEqual(progress.processedPercentage, 0.3, accuracy: 0.01, "Should be 30% complete")
        XCTAssertEqual(progress.emailsPerSecond, 0.5, accuracy: 0.1, "Should process ~0.5 emails/second")

        if let eta = progress.estimatedTimeRemaining {
            XCTAssertEqual(eta, 140, accuracy: 20, "ETA should be realistic based on processing rate")
        } else {
            XCTFail("ETA should be calculated")
        }
    }
}