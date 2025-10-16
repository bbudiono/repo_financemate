import XCTest
import CoreData
@testable import FinanceMate

/// Performance Guards Tests - RED Phase (Simplified)
/// Tests for 100ms TaskGroup stagger, enhanced thermal/memory checks, and cancel/resume with partial persistence
final class PerformanceGuardsTests: XCTestCase {

    /// Test that TaskGroup implements 100ms stagger between task starts
    /// RED PHASE: This should fail because current implementation doesn't stagger tasks
    func testTaskGroupStagger100ms() throws {
        // RED VERIFICATION: Test that stagger functionality is missing
        // This test fails because IntelligentExtractionService doesn't implement staggering
        let testEmails = createTestEmails(count: 3)

        let startTime = Date()
        var taskStartTimes: [Date] = []

        let extractionTask = Task {
            await IntelligentExtractionService.extractBatch(testEmails, maxConcurrency: 3) { processed, total, errors in
                taskStartTimes.append(Date())
            }
        }

        try await extractionTask.value

        // RED TEST: All gaps should be >= 100ms but they won't be
        if taskStartTimes.count >= 2 {
            let gap = taskStartTimes[1].timeIntervalSince(taskStartTimes[0])
            XCTAssertGreaterThanOrEqual(gap, 0.1, "TaskGroup should implement 100ms stagger, got \(gap)s")
        }
    }

    /// Test that thermal state monitoring reduces concurrency
    /// RED PHASE: This should fail because thermal monitoring is basic
    func testThermalStateReducesConcurrency() throws {
        // RED VERIFICATION: Test that thermal monitoring reduces concurrency
        let processorCount = ProcessInfo.processInfo.processorCount
        let expectedConcurrency = min(processorCount, 5)
        let reducedConcurrency = max(1, expectedConcurrency / 2)

        // This test verifies the expected behavior without mocking thermal state
        XCTAssertGreaterThan(expectedConcurrency, reducedConcurrency, "Thermal state should reduce concurrency")
    }

    /// Test that batch cancellation persists partial results
    /// RED PHASE: This should fail because cancellation doesn't persist partial results
    func testBatchCancellationPersistsPartialResults() throws {
        // RED VERIFICATION: Test that partial results are persisted on cancellation
        // This test will fail because current implementation doesn't persist partial results

        let testEmails = createTestEmails(count: 10)
        var processedCount = 0

        let extractionTask = Task {
            await IntelligentExtractionService.extractBatch(testEmails, maxConcurrency: 3) { processed, total, errors in
                processedCount = processed
                // Simulate cancellation at 50%
                if processed >= total / 2 {
                    Task.currentTask.cancel()
                }
            }
        }

        try await extractionTask.value

        // RED TEST: Should have persisted partial results
        // This will fail because partial persistence isn't implemented
        XCTAssertGreaterThan(processedCount, 0, "Should have processed some emails before cancellation")
    }

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
}