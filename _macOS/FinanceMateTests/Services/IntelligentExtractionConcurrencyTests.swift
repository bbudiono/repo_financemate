import XCTest
import CoreData
@testable import FinanceMate

class IntelligentExtractionConcurrencyTests: XCTestCase {

    var persistenceController: PersistenceController!

    override func setUp() {
        super.setUp()
        // Use in-memory store for testing
        persistenceController = PersistenceController(inMemory: true)
        // Inject into singleton for the service to use
        // Note: This relies on the service using PersistenceController.shared.
        // In a real test environment, we might need to mock the singleton or inject dependencies.
        // For now, we assume the service uses the shared instance, which we can't easily swap out 
        // without a proper DI container. 
        // However, since we can't easily mock the singleton in Swift without DI, 
        // we will rely on the fact that the test runner might not have initialized the app's real persistence controller yet.
        // If it has, we are testing against the real DB (or whatever was set up).
        // Ideally, we should refactor the service to accept a context/controller.
        
        // BUT, for this specific concurrency crash test, the crash happens because of WRONG context usage.
        // Even if we use the real DB, the crash would occur if the bug wasn't fixed.
        // So running this test is valuable regardless of the store type.
    }

    func testConcurrentBatchExtraction() async throws {
        // 1. Setup: Create 100 mock emails
        let count = 100
        var emails: [GmailEmail] = []
        
        for i in 0..<count {
            emails.append(GmailEmail(
                id: "email_\(i)",
                subject: "Receipt for Order #\(i)",
                sender: "receipts@merchant\(i % 5).com", // 5 distinct merchants
                date: Date(),
                snippet: "Thank you for your purchase of $\(Double(i) * 10.0)",
                status: "unread"
            ))
        }
        
        // 2. Execute: Run batch extraction with high concurrency
        // The fix involves using newBackgroundContext() inside the service.
        // If the fix is working, this should NOT crash and should complete.
        // If the fix is missing (using viewContext), this might crash or hang or throw concurrency violations.
        
        let expectation = XCTestExpectation(description: "Batch extraction completes")
        
        let results = await IntelligentExtractionService.extractBatch(
            emails,
            maxConcurrency: 20
        ) { processed, total, errors in
            if processed == total {
                expectation.fulfill()
            }
        }
        
        // 3. Assert
        XCTAssertEqual(results.count, count, "Should extract all emails")
        
        // Verify results integrity
        for (index, tx) in results.sorted(by: { $0.id < $1.id }).enumerated() {
            // Note: IDs are string sorted, so email_1, email_10, email_100... 
            // We just check that we have valid transactions.
            XCTAssertFalse(tx.merchant.isEmpty)
            XCTAssertEqual(tx.confidence, 0.9, accuracy: 0.1) // Regex should hit (Tier 1)
        }
    }
}
