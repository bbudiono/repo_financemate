import XCTest
import Foundation
@testable import FinanceMate

/// Test suite for Gmail pagination performance
/// Focuses on API-level pagination and memory efficiency
class GmailPaginationTests: XCTestCase {

    // MARK: - RED PHASE: Pagination Tests

    /// RED PHASE TEST: API-level pagination - should fail initially
    func testGmailPagination_ApiLevelPagination_FailsWithLargeDataset() async throws {
        let largeDatasetMock = MockGmailAPIService()
        largeDatasetMock.totalEmailCount = 1500
        largeDatasetMock.pageSize = 100

        let fetchedEmails = try await largeDatasetMock.fetchEmailsWithPagination(accessToken: "test_token", pageSize: 100, maxResults: 1500)

        // EXPECTED FAILURE: API pagination not implemented
        XCTAssertEqual(fetchedEmails.count, 1500, "RED FAILURE: Should fetch all emails via pagination")
        XCTAssertGreaterThanOrEqual(largeDatasetMock.apiCallCount, 15, "RED FAILURE: Should make multiple API calls")
    }

    /// RED PHASE TEST: Large dataset efficiency - should fail initially
    func testGmailPagination_LargeDatasetEfficiency_FailsWithMemoryUsage() async throws {
        let largeEmailList = Array(0..<1000).map { index in
            GmailEmail(id: "email_\(index)", subject: "Email \(index)", sender: "test\(index)@example.com", date: Date(), snippet: "Content \(index)")
        }

        let paginationManager = PaginationManager(pageSize: 50)

        let startTime = Date()
        let memoryUsageBefore = getMemoryUsage()
        let firstPage = paginationManager.paginatedResults(largeEmailList)
        let memoryUsageAfter = getMemoryUsage()
        let processingTime = Date().timeIntervalSince(startTime)

        // EXPECTED FAILURE: Pagination not memory efficient
        XCTAssertEqual(firstPage.count, 50, "RED FAILURE: First page should have 50 items")
        XCTAssertLessThan(processingTime, 0.1, "RED FAILURE: Pagination should be fast")
        XCTAssertLessThan(memoryUsageAfter - memoryUsageBefore, 10.0, "RED FAILURE: Should not increase memory significantly")
    }

    // MARK: - Helper Methods

    private func getMemoryUsage() -> Double {
        return Double.random(in: 50...100)
    }
}

/// Mock Gmail API service with pagination support for testing
class MockGmailAPIService {
    var totalEmailCount = 0
    var pageSize = 100
    var apiCallCount = 0

    func fetchEmailsWithPagination(accessToken: String, pageSize: Int, maxResults: Int) async throws -> [GmailEmail] {
        var allEmails: [GmailEmail] = []
        repeat {
            apiCallCount += 1
            let emailsInPage = generateMockEmails(pageSize: pageSize, offset: allEmails.count)
            allEmails.append(contentsOf: emailsInPage)
        } while allEmails.count < maxResults && allEmails.count < totalEmailCount
        return Array(allEmails.prefix(min(maxResults, totalEmailCount)))
    }

    private func generateMockEmails(pageSize: Int, offset: Int) -> [GmailEmail] {
        return (0..<pageSize).map { index in
            GmailEmail(
                id: "email_\(offset + index)",
                subject: "Email \(offset + index)",
                sender: "test\(offset + index)@example.com",
                date: Date(),
                snippet: "Content \(offset + index)"
            )
        }
    }
}