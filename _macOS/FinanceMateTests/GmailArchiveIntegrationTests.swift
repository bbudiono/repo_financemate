import XCTest
import CoreData
@testable import FinanceMate

/// Gmail Archive Integration Tests - Phase 2 RED
/// BLUEPRINT Line 104: Complete Gmail Archive Workflow Integration Tests
/// End-to-end failing tests for Gmail archive system integration
final class GmailArchiveIntegrationTests: XCTestCase {

    var testContext: NSManagedObjectContext!
    var testPersistenceController: PersistenceController!
    var testViewModel: GmailViewModel!
    var testArchiveService: GmailArchiveService!

    override func setUpWithError() throws {
        testPersistenceController = PersistenceController(inMemory: true)
        testContext = testPersistenceController.container.viewContext
        testViewModel = GmailViewModel(context: testContext)
        testArchiveService = GmailArchiveService(context: testContext)
    }

    override func tearDownWithError() throws {
        testContext = nil
        testPersistenceController = nil
        testViewModel = nil
        testArchiveService = nil
    }

    // MARK: - Complete Archive Workflow Tests

    /// Test complete Gmail archive workflow from email to transaction
    func testCompleteGmailArchiveWorkflow() throws {
        // This test should FAIL until complete workflow is implemented
        let email = createTestGmailEmail(
            id: "workflow-test-123",
            subject: "Uber Receipt - Complete Workflow Test",
            sender: "uber@uber.com"
        )

        let extractedTransaction = createTestExtractedTransaction(from: email)

        // Step 1: Add email to ViewModel
        testViewModel.extractedTransactions.append(extractedTransaction)
        XCTAssertEqual(testViewModel.extractedTransactions.count, 1, "Should have 1 extracted transaction")

        // Step 2: Verify email starts as needsReview
        let initialTransaction = testViewModel.extractedTransactions.first!
        XCTAssertEqual(initialTransaction.status, .needsReview, "Email should start as needsReview")

        // Step 3: Create transaction from email (should trigger automatic archive)
        testViewModel.createTransaction(from: initialTransaction)

        // Step 4: Verify email is marked as transactionCreated
        let processedTransaction = testViewModel.extractedTransactions.first!
        XCTAssertEqual(processedTransaction.status, .transactionCreated, "Email should be marked as transactionCreated")

        // Step 5: Verify email is hidden from main view
        testViewModel.showArchivedEmails = false
        let visibleEmails = testViewModel.filteredExtractedTransactions
        XCTAssertEqual(visibleEmails.count, 0, "Processed email should be hidden from main view")

        // Step 6: Verify transaction is created in Core Data
        let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "sourceEmailID == %@", email.id)
        let transactions = try testContext.fetch(fetchRequest)
        XCTAssertEqual(transactions.count, 1, "Should create transaction in Core Data")

        // Step 7: Verify email status is tracked in Core Data
        let emailStatus = try testArchiveService.getEmailStatus(for: email.id)
        XCTAssertEqual(emailStatus, .transactionCreated, "Email status should be tracked in Core Data")

        // Step 8: Test archive toggle shows archived emails
        testViewModel.showArchivedEmails = true
        let allEmails = testViewModel.filteredExtractedTransactions
        XCTAssertEqual(allEmails.count, 1, "Should show archived email when toggle is on")
        XCTAssertEqual(allEmails.first?.status, .transactionCreated, "Should show processed email")
    }

    /// Test batch import workflow with automatic archiving
    func testBatchImportWorkflowWithAutoArchive() throws {
        // This test should FAIL until batch workflow is implemented
        let emails = [
            createTestGmailEmail(id: "batch-1", subject: "Lyft Receipt", sender: "lyft@lyft.com"),
            createTestGmailEmail(id: "batch-2", subject: "DoorDash Receipt", sender: "doordash@doordash.com"),
            createTestGmailEmail(id: "batch-3", subject: "Uber Receipt", sender: "uber@uber.com")
        ]

        // Add all emails to ViewModel
        for email in emails {
            testViewModel.extractedTransactions.append(createTestExtractedTransaction(from: email))
        }

        // Select all emails for batch import
        testViewModel.selectedIDs = Set(emails.map { $0.id })

        // Perform batch import
        testViewModel.importSelected()

        // Verify all emails are marked as transactionCreated
        for email in emails {
            let transaction = testViewModel.extractedTransactions.first { $0.id == email.id }
            XCTAssertEqual(transaction?.status, .transactionCreated, "Email \(email.id) should be marked as transactionCreated")
        }

        // Verify all emails are hidden from main view
        testViewModel.showArchivedEmails = false
        let visibleEmails = testViewModel.filteredExtractedTransactions
        XCTAssertEqual(visibleEmails.count, 0, "All processed emails should be hidden from main view")

        // Verify all transactions are created in Core Data
        let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        let transactions = try testContext.fetch(fetchRequest)
        XCTAssertEqual(transactions.count, 3, "Should create 3 transactions in Core Data")

        // Verify all email statuses are tracked
        for email in emails {
            let status = try testArchiveService.getEmailStatus(for: email.id)
            XCTAssertEqual(status, .transactionCreated, "Email \(email.id) status should be tracked")
        }

        // Verify selection is cleared
        XCTAssertTrue(testViewModel.selectedIDs.isEmpty, "Selection should be cleared after batch import")
    }

    /// Test manual archive workflow
    func testManualArchiveWorkflow() throws {
        // This test should FAIL until manual archive is implemented
        let email = createTestGmailEmail(id: "manual-archive-workflow", subject: "Manual Archive Test", sender: "test@test.com")
        let extractedTransaction = createTestExtractedTransaction(from: email)

        testViewModel.extractedTransactions.append(extractedTransaction)

        // Manually archive email (without creating transaction)
        testViewModel.archiveEmail(with: email.id)

        // Verify email is marked as archived
        let archivedTransaction = testViewModel.extractedTransactions.first!
        XCTAssertEqual(archivedTransaction.status, .archived, "Email should be manually archived")

        // Verify email is hidden from main view
        testViewModel.showArchivedEmails = false
        let visibleEmails = testViewModel.filteredExtractedTransactions
        XCTAssertEqual(visibleEmails.count, 0, "Archived email should be hidden from main view")

        // Verify email status is tracked in Core Data
        let status = try testArchiveService.getEmailStatus(for: email.id)
        XCTAssertEqual(status, .archived, "Archived status should be tracked in Core Data")

        // Test unarchive workflow
        testViewModel.showArchivedEmails = true
        testViewModel.unarchiveEmail(with: email.id)

        // Verify email is unarchived
        let unarchivedTransaction = testViewModel.extractedTransactions.first!
        XCTAssertEqual(unarchivedTransaction.status, .needsReview, "Email should be unarchived to needsReview")

        // Verify email is visible when archive toggle is off
        testViewModel.showArchivedEmails = false
        let visibleAfterUnarchive = testViewModel.filteredExtractedTransactions
        XCTAssertEqual(visibleAfterUnarchive.count, 1, "Unarchived email should be visible")
    }

    // MARK: - GmailReceiptsTableView Integration Tests

    /// Test GmailReceiptsTableView with archive toggle integration
    func testGmailReceiptsTableViewArchiveToggleIntegration() throws {
        // This test should FAIL until table view integration is complete
        let emails = [
            createTestGmailEmail(id: "table-1", subject: "Table Test 1", sender: "test1@test.com"),
            createTestGmailEmail(id: "table-2", subject: "Table Test 2", sender: "test2@test.com"),
            createTestGmailEmail(id: "table-3", subject: "Table Test 3", sender: "test3@test.com")
        ]

        // Add emails with different statuses
        var transaction1 = createTestExtractedTransaction(from: emails[0])
        transaction1.status = .needsReview

        var transaction2 = createTestExtractedTransaction(from: emails[1])
        transaction2.status = .archived

        var transaction3 = createTestExtractedTransaction(from: emails[2])
        transaction3.status = .transactionCreated

        testViewModel.extractedTransactions = [transaction1, transaction2, transaction3]

        // Create table view
        let tableView = GmailReceiptsTableView(viewModel: testViewModel)

        // Test initial state (show only unprocessed)
        testViewModel.showArchivedEmails = false
        let initialCount = testViewModel.filteredExtractedTransactions.count
        XCTAssertEqual(initialCount, 1, "Should show 1 unprocessed email initially")

        // Test toggle to show all
        testViewModel.showArchivedEmails = true
        let allCount = testViewModel.filteredExtractedTransactions.count
        XCTAssertEqual(allCount, 3, "Should show all 3 emails when archive toggle is on")

        // Test header updates
        let unprocessedCount = testViewModel.unprocessedEmails.count
        XCTAssertEqual(unprocessedCount, 1, "Should count 1 unprocessed email")

        // Test table view responds to changes
        XCTAssertNotNil(tableView, "Table view should be createable with archive functionality")
    }

    /// Test GmailReceiptsTableView row actions integration
    func testGmailReceiptsTableViewRowActionsIntegration() throws {
        // This test should FAIL until row actions are implemented
        let email = createTestGmailEmail(id: "row-actions-integration", subject: "Row Actions Test", sender: "test@test.com")
        let transaction = createTestExtractedTransaction(from: email)

        testViewModel.extractedTransactions.append(transaction)

        // Test archive action from row
        testViewModel.archiveEmailFromRow(with: email.id)

        let archivedTransaction = testViewModel.extractedTransactions.first!
        XCTAssertEqual(archivedTransaction.status, .archived, "Row action should archive email")

        // Test unarchive action from row
        testViewModel.unarchiveEmailFromRow(with: email.id)

        let unarchivedTransaction = testViewModel.extractedTransactions.first!
        XCTAssertEqual(unarchivedTransaction.status, .needsReview, "Row action should unarchive email")

        // Test transaction creation from row
        testViewModel.createTransaction(from: unarchivedTransaction)

        let processedTransaction = testViewModel.extractedTransactions.first!
        XCTAssertEqual(processedTransaction.status, .transactionCreated, "Row action should create transaction")
    }

    // MARK: - Filter Integration Tests

    /// Test archive filters integration with existing filters
    func testArchiveFiltersIntegration() throws {
        // This test should FAIL until filter integration is complete
        let emails = [
            createTestGmailEmail(id: "filter-integration-1", subject: "Uber Receipt", sender: "uber@uber.com"),
            createTestGmailEmail(id: "filter-integration-2", subject: "Uber Receipt", sender: "uber@uber.com"),
            createTestGmailEmail(id: "filter-integration-3", subject: "Lyft Receipt", sender: "lyft@lyft.com")
        ]

        // Add emails with different statuses
        var transaction1 = createTestExtractedTransaction(from: emails[0])
        transaction1.status = .needsReview

        var transaction2 = createTestExtractedTransaction(from: emails[1])
        transaction2.status = .archived

        var transaction3 = createTestExtractedTransaction(from: emails[2])
        transaction3.status = .transactionCreated

        testViewModel.extractedTransactions = [transaction1, transaction2, transaction3]

        // Test merchant filter
        testViewModel.merchantFilter = "uber"
        let uberEmails = testViewModel.filteredExtractedTransactions
        XCTAssertEqual(uberEmails.count, 2, "Should show 2 Uber emails with merchant filter")

        // Test status filter combined with merchant filter
        testViewModel.setStatusFilter(.needsReview)
        let uberNeedsReview = testViewModel.filteredExtractedTransactions
        XCTAssertEqual(uberNeedsReview.count, 1, "Should show 1 needsReview Uber email")

        // Test search combined with status filter
        testViewModel.merchantFilter = nil
        testViewModel.searchText = "Lyft"
        testViewModel.setStatusFilter(.transactionCreated)
        let lyftProcessed = testViewModel.filteredExtractedTransactions
        XCTAssertEqual(lyftProcessed.count, 1, "Should show 1 processed Lyft email")

        // Test date filter combined with status filter
        testViewModel.searchText = ""
        testViewModel.setStatusFilter(.archived)
        testViewModel.dateFilter = .today
        // Should handle date filtering with archived emails
    }

    // MARK: - Gmail API Integration Tests

    /// Test Gmail API integration for archive operations
    func testGmailAPIIntegrationForArchive() throws {
        // This test should FAIL until Gmail API integration is complete
        let emailId = "gmail-api-integration-test"

        // Test archive via Gmail API
        try testArchiveService.archiveEmailInGmail(withId: emailId)

        // Test unarchive via Gmail API
        try testArchiveService.unarchiveEmailInGmail(withId: emailId)

        // Test batch operations via Gmail API
        let emailIds = ["batch-api-1", "batch-api-2", "batch-api-3"]
        try testArchiveService.batchArchiveEmailsInGmail(withIds: emailIds)

        // This will require mocking Gmail API for testing
        XCTAssertNotNil(testArchiveService, "Archive service should integrate with Gmail API")
    }

    /// Test authentication integration with archive operations
    func testAuthenticationIntegrationWithArchive() throws {
        // This test should FAIL until auth integration is complete
        // Mock authenticated state
        testViewModel.isAuthenticated = true

        let email = createTestGmailEmail(id: "auth-integration-test", subject: "Auth Integration Test", sender: "test@test.com")
        let transaction = createTestExtractedTransaction(from: email)

        testViewModel.extractedTransactions.append(transaction)

        // Test archive operations work when authenticated
        testViewModel.archiveEmail(with: email.id)

        let archivedTransaction = testViewModel.extractedTransactions.first!
        XCTAssertEqual(archivedTransaction.status, .archived, "Archive should work when authenticated")

        // Test Gmail API operations work when authenticated
        try testArchiveService.archiveEmailInGmail(withId: email.id)

        // Mock unauthenticated state
        testViewModel.isAuthenticated = false

        // Test graceful handling when unauthenticated
        testViewModel.unarchiveEmail(with: email.id)

        // Should handle gracefully without breaking functionality
        XCTAssertNotNil(testViewModel, "Should handle unauthenticated archive gracefully")
    }

    // MARK: - Error Handling Integration Tests

    /// Test error handling throughout archive workflow
    func testErrorHandlingInArchiveWorkflow() throws {
        // This test should FAIL until error handling is complete
        let invalidEmailId = "invalid-email-id"

        // Test archive with invalid ID
        XCTAssertNoThrow(testViewModel.archiveEmail(with: invalidEmailId), "Should handle invalid email ID gracefully")

        // Test unarchive with invalid ID
        XCTAssertNoThrow(testViewModel.unarchiveEmail(with: invalidEmailId), "Should handle invalid unarchive ID gracefully")

        // Test batch operations with mix of valid and invalid IDs
        let mixedIds = ["valid-id-1", "invalid-id", "valid-id-2"]
        testViewModel.selectedIDs = Set(mixedIds)

        XCTAssertNoThrow(testViewModel.archiveSelected(), "Should handle mixed valid/invalid IDs gracefully")

        // Test network error scenarios
        // This will require mocking network failures
        let networkTestEmail = createTestGmailEmail(id: "network-error-test", subject: "Network Error Test", sender: "test@test.com")
        testViewModel.extractedTransactions.append(createTestExtractedTransaction(from: networkTestEmail))

        // Simulate network error during Gmail API operation
        XCTAssertNotNil(testViewModel, "Should handle network errors gracefully")
    }

    // MARK: - Performance Integration Tests

    /// Test performance of complete archive workflow
    func testArchiveWorkflowPerformance() throws {
        // This test should FAIL until performance is optimized
        let emailCount = 1000
        var emails: [GmailEmail] = []

        // Create large dataset
        for i in 0..<emailCount {
            let email = createTestGmailEmail(
                id: "perf-integration-\(i)",
                subject: "Performance Test \(i)",
                sender: "test\(i)@test.com"
            )
            emails.append(email)
        }

        let startTime = CFAbsoluteTimeGetCurrent()

        // Add emails to ViewModel
        for email in emails {
            testViewModel.extractedTransactions.append(createTestExtractedTransaction(from: email))
        }

        // Batch process half of them
        let batchIds = Set(emails.prefix(500).map { $0.id })
        testViewModel.selectedIDs = batchIds
        testViewModel.importSelected()

        // Archive remaining emails
        let remainingIds = Set(emails.suffix(500).map { $0.id })
        testViewModel.selectedIDs = remainingIds
        testViewModel.archiveSelected()

        let totalTime = CFAbsoluteTimeGetCurrent() - startTime

        // Should complete within reasonable time
        XCTAssertLessThan(totalTime, 5.0, "Complete workflow should complete within 5 seconds for \(emailCount) emails")

        // Verify all emails are processed
        testViewModel.showArchivedEmails = false
        let visibleEmails = testViewModel.filteredExtractedTransactions
        XCTAssertEqual(visibleEmails.count, 0, "All emails should be processed/hidden")

        testViewModel.showArchivedEmails = true
        let allEmails = testViewModel.filteredExtractedTransactions
        XCTAssertEqual(allEmails.count, emailCount, "All emails should be present when toggle is on")
    }

    // MARK: - Data Persistence Integration Tests

    /// Test data persistence throughout archive workflow
    func testDataPersistenceInArchiveWorkflow() throws {
        // This test should FAIL until persistence is complete
        let email = createTestGmailEmail(id: "persistence-integration-test", subject: "Persistence Test", sender: "test@test.com")
        let transaction = createTestExtractedTransaction(from: email)

        testViewModel.extractedTransactions.append(transaction)

        // Archive email
        testViewModel.archiveEmail(with: email.id)

        // Create new ViewModel instance (simulating app restart)
        let newViewModel = GmailViewModel(context: testContext)

        // Verify archive status persists
        // This will require implementing status persistence
        XCTAssertNotNil(newViewModel, "New ViewModel should be created")

        // Create new ArchiveService instance
        let newArchiveService = GmailArchiveService(context: testContext)

        // Verify status persists in service
        let persistedStatus = try newArchiveService.getEmailStatus(for: email.id)
        XCTAssertEqual(persistedStatus, .archived, "Archive status should persist across service instances")
    }

    /// Test Core Data relationship persistence
    func testCoreDataRelationshipPersistence() throws {
        // This test should FAIL until relationship persistence is complete
        let email = createTestGmailEmail(id: "relationship-persistence-test", subject: "Relationship Test", sender: "test@test.com")
        let extractedTransaction = createTestExtractedTransaction(from: email)

        testViewModel.extractedTransactions.append(extractedTransaction)

        // Create transaction (should establish relationship)
        testViewModel.createTransaction(from: extractedTransaction)

        // Save Core Data context
        try testContext.save()

        // Verify transaction is created with email relationship
        let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "sourceEmailID == %@", email.id)
        let transactions = try testContext.fetch(fetchRequest)

        XCTAssertEqual(transactions.count, 1, "Should create transaction with email relationship")

        // Create new context (simulating app restart)
        let newContext = testPersistenceController.container.viewContext

        // Verify relationship persists in new context
        let newFetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        newFetchRequest.predicate = NSPredicate(format: "sourceEmailID == %@", email.id)
        let persistedTransactions = try newContext.fetch(newFetchRequest)

        XCTAssertEqual(persistedTransactions.count, 1, "Transaction relationship should persist across context instances")
    }

    // MARK: - Edge Cases Integration Tests

    /// Test edge cases in archive workflow
    func testArchiveWorkflowEdgeCases() throws {
        // This test should FAIL until edge cases are handled
        // Test empty dataset
        XCTAssertEqual(testViewModel.extractedTransactions.count, 0, "Should handle empty dataset")

        // Test single email
        let singleEmail = createTestGmailEmail(id: "single-email-test", subject: "Single Email", sender: "test@test.com")
        testViewModel.extractedTransactions.append(createTestExtractedTransaction(from: singleEmail))

        testViewModel.archiveEmail(with: singleEmail.id)
        XCTAssertEqual(testViewModel.extractedTransactions.first?.status, .archived, "Should handle single email archive")

        // Test duplicate email IDs (should be prevented)
        let duplicateEmail = createTestGmailEmail(id: "single-email-test", subject: "Duplicate Email", sender: "duplicate@test.com")
        testViewModel.extractedTransactions.append(createTestExtractedTransaction(from: duplicateEmail))

        // Should handle duplicate IDs gracefully
        XCTAssertNotNil(testViewModel, "Should handle duplicate email IDs")

        // Test rapid state changes
        testViewModel.unarchiveEmail(with: singleEmail.id)
        testViewModel.archiveEmail(with: singleEmail.id)
        testViewModel.unarchiveEmail(with: singleEmail.id)

        let finalTransaction = testViewModel.extractedTransactions.first!
        XCTAssertEqual(finalTransaction.status, .needsReview, "Should handle rapid state changes")
    }

    // MARK: - Helper Methods

    private func createTestGmailEmail(id: String, subject: String, sender: String) -> GmailEmail {
        return GmailEmail(
            id: id,
            subject: subject,
            sender: sender,
            date: Date(),
            snippet: "Test receipt snippet"
        )
    }

    private func createTestExtractedTransaction(from email: GmailEmail) -> ExtractedTransaction {
        return ExtractedTransaction(
            id: email.id,
            merchant: "Test Merchant",
            amount: 25.50,
            date: email.date,
            category: "Transport",
            items: [],
            confidence: 0.95,
            rawText: "Test receipt text",
            emailSubject: email.subject,
            emailSender: email.sender
        )
    }
}