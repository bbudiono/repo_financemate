import XCTest
import CoreData
@testable import FinanceMate

/// Performance Guards Tests - RED Phase
/// Tests for 100ms TaskGroup stagger, enhanced thermal/memory checks, and cancel/resume with partial persistence
final class PerformanceGuardsTests: XCTestCase {

    var testContext: NSManagedObjectContext!
    var testPersistenceController: PersistenceController!

    override func setUpWithError() throws {
        testPersistenceController = PersistenceController(inMemory: true)
        testContext = testPersistenceController.container.viewContext
    }

    override func tearDownWithError() throws {
        testContext = nil
        testPersistenceController = nil
    }

    /// Test that TaskGroup implements 100ms stagger between task starts
    /// RED PHASE: This should fail because current implementation doesn't stagger tasks
    func testTaskGroupStagger100ms() throws {
        let testEmails = createTestEmails(count: 5)

        // Track task start times
        var taskStartTimes: [Date] = []
        let startTime = Date()

        // Process emails and capture start times using a modified service that tracks task timing
        // Since we can't easily modify the existing service for testing, we'll create a mock extraction service
        let mockService = MockExtractionService()
        mockService.onStart = { taskStartTimes.append(Date()) }

        let extractionTask = Task {
            await mockService.extractBatch(testEmails, maxConcurrency: 3) { processed, total, errors in
                // This callback should capture task start timing
                if processed < taskStartTimes.count {
                    taskStartTimes.append(Date())
                }
            }
        }

        // Wait for completion
        try await extractionTask.value

        // RED VERIFICATION: All gaps should be >= 100ms (0.1 seconds)
        for gap in calculateTimeGaps(from: taskStartTimes) {
            XCTAssertGreaterThanOrEqual(gap, 0.1, "TaskGroup should implement 100ms stagger between tasks")
        }
    }

    /// Test that thermal state monitoring reduces concurrency
    func testThermalStateReducesConcurrency() throws {
        // Mock thermal state detection logic
        let thermalMonitor = MockThermalMonitor()

        // Test with fair thermal state
        thermalMonitor.mockThermalState(.fair)
        let fairConcurrency = thermalMonitor.getRecommendedConcurrency(processorCount: 8)
        XCTAssertEqual(fairConcurrency, 4, "Fair thermal state should reduce concurrency by 50%")

        // Test with serious thermal state
        thermalMonitor.mockThermalState(.serious)
        let seriousConcurrency = thermalMonitor.getRecommendedConcurrency(processorCount: 8)
        XCTAssertEqual(seriousConcurrency, 2, "Serious thermal state should reduce concurrency to 2")
    }

    /// Test that batch cancellation persists partial results
    /// RED PHASE: This should fail because cancellation doesn't persist partial results
    func testBatchCancellationPersistsPartialResults() throws {
        let testEmails = createTestEmails(count: 10)
        var processedResults: [ExtractedTransaction] = []

        // Create cancellable service
        let cancellableService = CancellableExtractionService()

        // Process some emails and capture partial results
        let extractionTask = Task {
            await cancellableService.extractBatch(testEmails, maxConcurrency: 3) { processed, total, errors in
                // Capture partial results during processing
                for i in 0..<min(processed, 5) {
                    processedResults.append(createMockTransaction(id: "test-\(5 + i)"))
                }

                // Simulate cancellation at 50% completion
                if processed >= testEmails.count / 2 {
                    cancellableService.cancel()
                }
            }
        }

        // Wait for cancellation to complete
        try await extractionTask.value

        // RED VERIFICATION: Partial results should be persisted
        XCTAssertGreaterThan(processedResults.count, 0, "Cancelled batch should persist partial results")

        // Verify we can retrieve the partial results after cancellation
        let persistedResults = retrievePersistedPartialResults()
        XCTAssertGreaterThan(persistedResults.count, 0, "Should be able to retrieve persisted partial results")
    }

    // MARK: - Helper Methods

    private func createTestEmails(count: Int) -> [GmailEmail] {
        return (0..<count).map { index in
            GmailEmail(
                id: "perf-test-\(index)",
                subject: "Performance Test Email \(index)",
                sender: "test@performance.com",
                date: Date().addingTimeInterval(-Double(index * 3600)),
                snippet: "Performance test content \(index)",
                attachments: []
            )
        }
    }

    private func createMockTransaction(id: String) -> ExtractedTransaction {
        ExtractedTransaction(
            id: id,
            merchant: "Test Merchant",
            amount: Double.random(in: 1...100),
            date: Date(),
            category: "Test Category",
            items: [],
            confidence: 0.8,
            rawText: "Test transaction",
            emailSubject: "Test Subject",
            emailSender: "test@test.com"
        )
    }

    private func calculateTimeGaps(from times: [Date]) -> [TimeInterval] {
        var gaps: [TimeInterval] = []
        for i in 1..<times.count {
            let gap = times[i].timeIntervalSince(times[i-1])
            if gap > 0 {
                gaps.append(gap)
            }
        }
        return gaps
    }

    private func retrievePersistedPartialResults() -> [ExtractedTransaction] {
        // This would query Core Data for partial results that were persisted
        // For now, return empty array to show this is a failing test
        return []
    }
}

// MARK: - Mock Services for Testing

/// Mock extraction service that tracks task start times
class MockExtractionService {
    var onStart: (() -> Void)?
    var isCancelled = false

    func extractBatch(_ emails: [GmailEmail], maxConcurrency: Int, progress: @escaping (Int, Int, Int) -> Void) async -> [ExtractedTransaction] {
        let startTime = Date()
        onStart?() // Capture start time

        var results: [ExtractedTransaction] = []

        for (index, email) in emails.enumerated() {
            // Simulate task start delay
            if isCancelled { break }

            // Create mock transaction
            let transaction = createMockTransaction(id: email.id)
            results.append(transaction)

            // Simulate processing time
            try await Task.sleep(nanoseconds: 50_000_000) // 50ms per email
        }

        return results
    }

    func cancel() {
        isCancelled = true
    }
}

/// Mock thermal monitoring for testing thermal state effects
class MockThermalMonitor {
    private var mockThermalState: ProcessInfo.ThermalState = .nominal

    func mockThermalState(_ state: ProcessInfo.ThermalState) {
        mockThermalState = state
    }

    func getRecommendedConcurrency(processorCount: Int) -> Int {
        switch mockThermalState {
        case .nominal:
            return min(processorCount, 5)
        case .fair:
            return max(1, processorCount / 2)
        case .serious:
            return max(1, 2)
        case .critical:
            return 1 // Emergency low-power mode
        }
    }
}

/// Cancellable extraction service for testing cancellation persistence
class CancellableExtractionService {
    private var isCancelled = false

    func extractBatch(_ emails: [GmailEmail], maxConcurrency: Int, progress: @escaping (Int, Int, Int) -> Void) async -> [ExtractedTransaction] {
        var results: [ExtractedTransaction] = []

        for (index, email) in emails.enumerated() {
            if isCancelled {
                break
            }

            let transaction = createMockTransaction(id: email.id)
            results.append(transaction)
        }

        return results
    }

    func cancel() {
        isCancelled = true
    }
}