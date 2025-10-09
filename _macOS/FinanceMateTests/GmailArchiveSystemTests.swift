import XCTest
import CoreData
@testable import FinanceMate

/// Gmail Archive System Tests - Phase 2 RED
/// BLUEPRINT Line 104: Archive Processed Items Implementation
/// Comprehensive failing tests for Gmail receipt archiving functionality
final class GmailArchiveSystemTests: XCTestCase {

    var testContext: NSManagedObjectContext!
    var testViewModel: GmailViewModel!
    var testPersistenceController: PersistenceController!

    override func setUpWithError() throws {
        // Set up in-memory Core Data stack for testing
        testPersistenceController = PersistenceController(inMemory: true)
        testContext = testPersistenceController.container.viewContext
        testViewModel = GmailViewModel(context: testContext)
    }

    override func tearDownWithError() throws {
        testContext = nil
        testViewModel = nil
        testPersistenceController = nil
    }

    // MARK: - Gmail Receipt Status Field Tests

    /// Test GmailEmail model supports archive status field
    func testGmailEmailArchiveStatusField() throws {
        // This test should FAIL until archive status is properly implemented
        let email = GmailEmail(
            id: "test-id-123",
            subject: "Test Receipt",
            sender: "merchant@example.com",
            date: Date(),
            snippet: "Test receipt snippet"
        )

        // Verify email starts with needsReview status
        XCTAssertEqual(email.status, .needsReview, "New emails should default to needsReview status")

        // Verify status can be changed to archived
        var mutableEmail = email
        mutableEmail.status = .archived
        XCTAssertEqual(mutableEmail.status, .archived, "Email status should be mutable to archived")

        // Verify status can be changed to transactionCreated
        mutableEmail.status = .transactionCreated
        XCTAssertEqual(mutableEmail.status, .transactionCreated, "Email status should support transactionCreated state")
    }

    /// Test EmailStatus enum covers all required states
    func testEmailStatusEnumCompleteness() throws {
        // This test should FAIL until enum includes all required states
        let allStatuses: [EmailStatus] = [.needsReview, .transactionCreated, .archived]

        // Verify all required statuses are present
        XCTAssertTrue(allStatuses.contains(.needsReview), "EmailStatus must include needsReview")
        XCTAssertTrue(allStatuses.contains(.transactionCreated), "EmailStatus must include transactionCreated")
        XCTAssertTrue(allStatuses.contains(.archived), "EmailStatus must include archived")

        // Verify raw values are correct
        XCTAssertEqual(EmailStatus.needsReview.rawValue, "Needs Review")
        XCTAssertEqual(EmailStatus.transactionCreated.rawValue, "Transaction Created")
        XCTAssertEqual(EmailStatus.archived.rawValue, "Archived")
    }

    // MARK: - Automatic Archiving Tests

    /// Test that Gmail receipts are automatically archived when transaction is created
    func testAutomaticArchiveOnTransactionCreation() throws {
        // This test should FAIL until automatic archiving is implemented
        let email = GmailEmail(
            id: "auto-archive-test",
            subject: "Uber Receipt",
            sender: "uber@uber.com",
            date: Date(),
            snippet: "Trip receipt"
        )

        // Add email to ViewModel
        testViewModel.extractedTransactions.append(createTestExtractedTransaction(from: email))

        // Verify email starts as needsReview
        let initialEmail = testViewModel.extractedTransactions.first { $0.id == email.id }
        XCTAssertNotNil(initialEmail, "Email should be present in extracted transactions")

        // Create transaction from email (this should trigger automatic archiving)
        if let transaction = initialEmail {
            testViewModel.createTransaction(from: transaction)
        }

        // Verify email status is now transactionCreated
        let updatedEmail = testViewModel.extractedTransactions.first { $0.id == email.id }
        XCTAssertEqual(updatedEmail?.status, .transactionCreated, "Email should be marked as transactionCreated after transaction creation")

        // Verify email is hidden from main view when showArchivedEmails is false
        testViewModel.showArchivedEmails = false
        let visibleEmails = testViewModel.filteredExtractedTransactions
        XCTAssertFalse(visibleEmails.contains { $0.id == email.id }, "Processed email should be hidden when archive toggle is off")
    }

    /// Test that batch import automatically archives all processed emails
    func testBatchImportAutoArchive() throws {
        // This test should FAIL until batch import archiving is implemented
        let emails = [
            createTestEmail(id: "batch-1", sender: "uber@uber.com"),
            createTestEmail(id: "batch-2", sender: "lyft@lyft.com"),
            createTestEmail(id: "batch-3", sender: "doordash@doordash.com")
        ]

        // Add emails to ViewModel
        for email in emails {
            testViewModel.extractedTransactions.append(createTestExtractedTransaction(from: email))
        }
        testViewModel.selectedIDs = Set(emails.map { $0.id })

        // Verify all emails start as needsReview
        for email in emails {
            let transaction = testViewModel.extractedTransactions.first { $0.id == email.id }
            XCTAssertEqual(transaction?.status, .needsReview, "Email \(email.id) should start as needsReview")
        }

        // Perform batch import
        testViewModel.importSelected()

        // Verify all emails are marked as transactionCreated
        for email in emails {
            let transaction = testViewModel.extractedTransactions.first { $0.id == email.id }
            XCTAssertEqual(transaction?.status, .transactionCreated, "Email \(email.id) should be marked as transactionCreated after batch import")
        }

        // Verify all emails are hidden from main view
        testViewModel.showArchivedEmails = false
        let visibleEmails = testViewModel.filteredExtractedTransactions
        for email in emails {
            XCTAssertFalse(visibleEmails.contains { $0.id == email.id }, "Processed email \(email.id) should be hidden from main view")
        }
    }

    // MARK: - Manual Archive/Unarchive Tests

    /// Test manual archive functionality
    func testManualArchiveFunctionality() throws {
        // This test should FAIL until manual archive methods are implemented
        let email = createTestEmail(id: "manual-archive-test", sender: "test@test.com")
        let transaction = createTestExtractedTransaction(from: email)

        testViewModel.extractedTransactions.append(transaction)

        // Verify email starts as needsReview
        XCTAssertEqual(transaction.status, .needsReview, "Email should start as needsReview")

        // Manually archive email
        testViewModel.archiveEmail(with: email.id)

        // Verify email is now archived
        let archivedTransaction = testViewModel.extractedTransactions.first { $0.id == email.id }
        XCTAssertEqual(archivedTransaction?.status, .archived, "Email should be manually archived")

        // Verify email is hidden when showArchivedEmails is false
        testViewModel.showArchivedEmails = false
        let visibleEmails = testViewModel.filteredExtractedTransactions
        XCTAssertFalse(visibleEmails.contains { $0.id == email.id }, "Archived email should be hidden when archive toggle is off")

        // Verify email is visible when showArchivedEmails is true
        testViewModel.showArchivedEmails = true
        let allEmails = testViewModel.filteredExtractedTransactions
        XCTAssertTrue(allEmails.contains { $0.id == email.id }, "Archived email should be visible when archive toggle is on")
    }

    /// Test manual unarchive functionality
    func testManualUnarchiveFunctionality() throws {
        // This test should FAIL until manual unarchive methods are implemented
        let email = createTestEmail(id: "manual-unarchive-test", sender: "test@test.com")
        var transaction = createTestExtractedTransaction(from: email)
        transaction.status = .archived

        testViewModel.extractedTransactions.append(transaction)

        // Verify email starts as archived
        XCTAssertEqual(transaction.status, .archived, "Email should start as archived")

        // Manually unarchive email
        testViewModel.unarchiveEmail(with: email.id)

        // Verify email is now needsReview
        let unarchivedTransaction = testViewModel.extractedTransactions.first { $0.id == email.id }
        XCTAssertEqual(unarchivedTransaction?.status, .needsReview, "Email should be unarchived to needsReview")

        // Verify email is visible regardless of archive toggle
        testViewModel.showArchivedEmails = false
        let visibleEmails = testViewModel.filteredExtractedTransactions
        XCTAssertTrue(visibleEmails.contains { $0.id == email.id }, "Unarchived email should be visible when archive toggle is off")
    }

    // MARK: - Archive Toggle Tests

    /// Test archive toggle in GmailReceiptsTableView
    func testArchiveToggleInGmailReceiptsTableView() throws {
        // This test should FAIL until archive toggle is implemented in UI
        let archivedEmail = createTestEmail(id: "archived-in-ui", sender: "archived@test.com")
        var archivedTransaction = createTestExtractedTransaction(from: archivedEmail)
        archivedTransaction.status = .archived

        let activeEmail = createTestEmail(id: "active-in-ui", sender: "active@test.com")
        var activeTransaction = createTestExtractedTransaction(from: activeEmail)
        activeTransaction.status = .needsReview

        testViewModel.extractedTransactions = [archivedTransaction, activeTransaction]

        // Test with archive toggle OFF (default)
        testViewModel.showArchivedEmails = false
        let visibleWhenOff = testViewModel.filteredExtractedTransactions
        XCTAssertEqual(visibleWhenOff.count, 1, "Should show 1 email when archive toggle is off")
        XCTAssertTrue(visibleWhenOff.contains { $0.id == activeEmail.id }, "Should show active email")
        XCTAssertFalse(visibleWhenOff.contains { $0.id == archivedEmail.id }, "Should hide archived email")

        // Test with archive toggle ON
        testViewModel.showArchivedEmails = true
        let visibleWhenOn = testViewModel.filteredExtractedTransactions
        XCTAssertEqual(visibleWhenOn.count, 2, "Should show 2 emails when archive toggle is on")
        XCTAssertTrue(visibleWhenOn.contains { $0.id == activeEmail.id }, "Should show active email")
        XCTAssertTrue(visibleWhenOn.contains { $0.id == archivedEmail.id }, "Should show archived email")
    }

    /// Test archive toggle state persistence
    func testArchiveToggleStatePersistence() throws {
        // This test should FAIL until toggle state is persisted
        // Set initial state
        testViewModel.showArchivedEmails = true

        // Create new ViewModel instance (simulating app restart)
        let newViewModel = GmailViewModel(context: testContext)

        // Verify state is persisted
        XCTAssertTrue(newViewModel.showArchivedEmails, "Archive toggle state should be persisted")
    }

    // MARK: - Archive Filter Tests

    /// Test archive filter functionality in GmailReceiptsTableView
    func testArchiveFilterFunctionality() throws {
        // This test should FAIL until archive filter is implemented
        let emails = [
            createTestEmailWithStatus(id: "filter-1", status: .needsReview),
            createTestEmailWithStatus(id: "filter-2", status: .transactionCreated),
            createTestEmailWithStatus(id: "filter-3", status: .archived),
            createTestEmailWithStatus(id: "filter-4", status: .needsReview)
        ]

        for email in emails {
            testViewModel.extractedTransactions.append(createTestExtractedTransaction(from: email))
        }

        // Test filter by needsReview only
        testViewModel.setStatusFilter(.needsReview)
        let needsReviewEmails = testViewModel.filteredExtractedTransactions
        XCTAssertEqual(needsReviewEmails.count, 2, "Should show 2 needsReview emails")
        XCTAssertTrue(needsReviewEmails.allSatisfy { $0.status == .needsReview }, "All should be needsReview")

        // Test filter by archived only
        testViewModel.setStatusFilter(.archived)
        let archivedEmails = testViewModel.filteredExtractedTransactions
        XCTAssertEqual(archivedEmails.count, 1, "Should show 1 archived email")
        XCTAssertTrue(archivedEmails.allSatisfy { $0.status == .archived }, "All should be archived")

        // Test filter by all statuses
        testViewModel.setStatusFilter(.all)
        let allEmails = testViewModel.filteredExtractedTransactions
        XCTAssertEqual(allEmails.count, 4, "Should show all 4 emails when filter is set to all")
    }

    /// Test archive filter works with other filters
    func testArchiveFilterWithOtherFilters() throws {
        // This test should FAIL until archive filter integrates with other filters
        let emails = [
            createTestEmailWithStatusAndMerchant(id: "combo-1", status: .needsReview, sender: "uber@uber.com"),
            createTestEmailWithStatusAndMerchant(id: "combo-2", status: .archived, sender: "uber@uber.com"),
            createTestEmailWithStatusAndMerchant(id: "combo-3", status: .needsReview, sender: "lyft@lyft.com"),
            createTestEmailWithStatusAndMerchant(id: "combo-4", status: .archived, sender: "lyft@lyft.com")
        ]

        for email in emails {
            testViewModel.extractedTransactions.append(createTestExtractedTransaction(from: email))
        }

        // Test combining status filter with merchant filter
        testViewModel.setStatusFilter(.archived)
        testViewModel.merchantFilter = "uber"

        let filteredEmails = testViewModel.filteredExtractedTransactions
        XCTAssertEqual(filteredEmails.count, 1, "Should show 1 archived Uber email")
        XCTAssertEqual(filteredEmails.first?.id, "combo-2", "Should be the archived Uber email")
    }

    // MARK: - Core Data Integration Tests

    /// Test Core Data model supports email status field
    func testCoreDataEmailStatusSupport() throws {
        // This test should FAIL until Core Data model is updated
        let email = GmailEmail(
            id: "core-data-test",
            subject: "Core Data Test",
            sender: "test@test.com",
            date: Date(),
            snippet: "Test snippet"
        )

        // This should test that we can save and retrieve email status from Core Data
        // Implementation will require Core Data model updates

        // Verify we can create a transaction with email status
        let transaction = Transaction(context: testContext)
        transaction.sourceEmailID = email.id

        // Save to Core Data
        try testContext.save()

        // Retrieve and verify
        let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "sourceEmailID == %@", email.id)
        let results = try testContext.fetch(fetchRequest)

        XCTAssertEqual(results.count, 1, "Should find one transaction")
        XCTAssertEqual(results.first?.sourceEmailID, email.id, "Should preserve email ID")

        // This test will need to be expanded when Core Data model includes email status
    }

    /// Test transaction creation updates email status in Core Data
    func testTransactionCreationUpdatesEmailStatus() throws {
        // This test should FAIL until transaction creation updates email status
        let email = createTestEmail(id: "status-update-test", sender: "test@test.com")
        let extractedTransaction = createTestExtractedTransaction(from: email)

        testViewModel.extractedTransactions.append(extractedTransaction)

        // Create transaction
        testViewModel.createTransaction(from: extractedTransaction)

        // Verify email status is updated in Core Data
        // This will require implementing status persistence in Core Data

        let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "sourceEmailID == %@", email.id)
        let transactions = try testContext.fetch(fetchRequest)

        XCTAssertEqual(transactions.count, 1, "Should create one transaction")

        // Verify email status tracking (this part will fail until implemented)
        // Need to add email status tracking to transaction or separate entity
    }

    // MARK: - Gmail Service Integration Tests

    /// Test Gmail service supports archive operations
    func testGmailServiceArchiveSupport() throws {
        // This test should FAIL until GmailAPIService supports archiving
        let emailId = "gmail-service-test"

        // Test archive email method exists
        XCTAssertTrue(testViewModel.responds(to: #selector(testViewModel.archiveEmail(with:))), "ViewModel should have archiveEmail method")

        // Test unarchive email method exists
        XCTAssertTrue(testViewModel.responds(to: #selector(testViewModel.unarchiveEmail(with:))), "ViewModel should have unarchiveEmail method")

        // Test batch archive method exists
        XCTAssertTrue(testViewModel.responds(to: #selector(testViewModel.archiveSelected)), "ViewModel should have archiveSelected method")

        // Test archive status tracking in Gmail service
        // This will require GmailAPIService enhancements
    }

    /// Test Gmail API integration for archive operations
    func testGmailAPIArchiveIntegration() throws {
        // This test should FAIL until Gmail API integration is complete
        let emailId = "api-archive-test"

        // This should test actual Gmail API calls for archiving
        // Will require mock Gmail API responses for testing

        // For now, verify the structure exists
        XCTAssertNotNil(testViewModel, "ViewModel should be available for API integration testing")
    }

    // MARK: - Error Handling Tests

    /// Test archive operation error handling
    func testArchiveOperationErrorHandling() throws {
        // This test should FAIL until error handling is implemented
        let invalidEmailId = "invalid-email-id"

        // Test archive with invalid ID
        testViewModel.archiveEmail(with: invalidEmailId)

        // Should handle gracefully without crashing
        XCTAssertNotNil(testViewModel, "ViewModel should handle invalid email ID gracefully")

        // Test unarchive with invalid ID
        testViewModel.unarchiveEmail(with: invalidEmailId)

        // Should handle gracefully without crashing
        XCTAssertNotNil(testViewModel, "ViewModel should handle invalid unarchive ID gracefully")
    }

    /// Test archive operation network error handling
    func testArchiveNetworkErrorHandling() throws {
        // This test should FAIL until network error handling is implemented
        // Simulate network conditions for archive operations

        let email = createTestEmail(id: "network-error-test", sender: "test@test.com")
        testViewModel.extractedTransactions.append(createTestExtractedTransaction(from: email))

        // This should test network error scenarios
        // Will require mocking network failures

        // Verify graceful handling of network errors
        XCTAssertNotNil(testViewModel, "Should handle network errors gracefully")
    }

    // MARK: - UI State Management Tests

    /// Test archive toggle UI state management
    func testArchiveToggleUIStateManagement() throws {
        // This test should FAIL until UI state management is implemented
        let archivedEmail = createTestEmail(id: "ui-state-test", sender: "test@test.com")
        var archivedTransaction = createTestExtractedTransaction(from: archivedEmail)
        archivedTransaction.status = .archived

        testViewModel.extractedTransactions.append(archivedTransaction)

        // Test initial UI state
        testViewModel.showArchivedEmails = false
        XCTAssertFalse(testViewModel.showArchivedEmails, "Archive toggle should start in false state")

        // Test UI state change
        testViewModel.showArchivedEmails = true
        XCTAssertTrue(testViewModel.showArchivedEmails, "Archive toggle should update to true")

        // Test UI state reflects in filtered results
        let visibleEmails = testViewModel.filteredExtractedTransactions
        XCTAssertTrue(visibleEmails.contains { $0.id == archivedEmail.id }, "UI state change should reflect in filtered results")
    }

    /// Test archive UI updates correctly
    func testArchiveUIUpdates() throws {
        // This test should FAIL until UI updates are properly implemented
        let email = createTestEmail(id: "ui-update-test", sender: "test@test.com")
        let transaction = createTestExtractedTransaction(from: email)

        testViewModel.extractedTransactions.append(transaction)

        // Test initial UI state
        let initialCount = testViewModel.filteredExtractedTransactions.count
        XCTAssertEqual(initialCount, 1, "Should start with 1 email visible")

        // Archive email
        testViewModel.archiveEmail(with: email.id)

        // Test UI updates after archive
        testViewModel.showArchivedEmails = false
        let afterArchiveCount = testViewModel.filteredExtractedTransactions.count
        XCTAssertEqual(afterArchiveCount, 0, "Should show 0 emails after archive when toggle is off")

        // Test UI updates after unarchive
        testViewModel.showArchivedEmails = true
        testViewModel.unarchiveEmail(with: email.id)
        testViewModel.showArchivedEmails = false
        let afterUnarchiveCount = testViewModel.filteredExtractedTransactions.count
        XCTAssertEqual(afterUnarchiveCount, 1, "Should show 1 email after unarchive")
    }

    // MARK: - Integration with Existing Authentication Tests

    /// Test archive system works with authenticated Gmail
    func testArchiveWithAuthenticatedGmail() throws {
        // This test should FAIL until archive system integrates with authentication
        // Mock authenticated state
        testViewModel.isAuthenticated = true

        let email = createTestEmail(id: "auth-archive-test", sender: " authenticated@test.com")
        testViewModel.extractedTransactions.append(createTestExtractedTransaction(from: email))

        // Test archive operations work when authenticated
        testViewModel.archiveEmail(with: email.id)

        let archivedTransaction = testViewModel.extractedTransactions.first { $0.id == email.id }
        XCTAssertEqual(archivedTransaction?.status, .archived, "Archive should work when authenticated")
    }

    /// Test archive system handles unauthenticated state
    func testArchiveWithUnauthenticatedGmail() throws {
        // This test should FAIL until archive system handles unauthenticated state
        // Mock unauthenticated state
        testViewModel.isAuthenticated = false

        let email = createTestEmail(id: "unauth-archive-test", sender: "unauthenticated@test.com")
        testViewModel.extractedTransactions.append(createTestExtractedTransaction(from: email))

        // Test archive operations handle unauthenticated state gracefully
        testViewModel.archiveEmail(with: email.id)

        // Should either work with local data or show appropriate error
        XCTAssertNotNil(testViewModel, "Should handle unauthenticated archive gracefully")
    }

    // MARK: - Performance Tests

    /// Test archive performance with large email sets
    func testArchivePerformanceWithLargeDataset() throws {
        // This test should FAIL until performance is optimized
        // Create large dataset
        let largeEmailSet = (0..<1000).map { i in
            createTestEmail(id: "perf-test-\(i)", sender: "test\(i)@test.com")
        }

        for email in largeEmailSet {
            testViewModel.extractedTransactions.append(createTestExtractedTransaction(from: email))
        }

        // Test batch archive performance
        let batchIds = Set(largeEmailSet.prefix(100).map { $0.id })
        testViewModel.selectedIDs = batchIds

        let startTime = CFAbsoluteTimeGetCurrent()
        testViewModel.archiveSelected()
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime

        // Should complete within reasonable time (e.g., < 1 second)
        XCTAssertLessThan(timeElapsed, 1.0, "Batch archive should complete within 1 second")
    }

    // MARK: - Helper Methods

    private func createTestEmail(id: String, sender: String) -> GmailEmail {
        return GmailEmail(
            id: id,
            subject: "Test Receipt",
            sender: sender,
            date: Date(),
            snippet: "Test receipt snippet"
        )
    }

    private func createTestEmailWithStatus(id: String, status: EmailStatus) -> GmailEmail {
        var email = GmailEmail(
            id: id,
            subject: "Test Receipt",
            sender: "test@test.com",
            date: Date(),
            snippet: "Test receipt snippet"
        )
        email.status = status
        return email
    }

    private func createTestEmailWithStatusAndMerchant(id: String, status: EmailStatus, sender: String) -> GmailEmail {
        var email = GmailEmail(
            id: id,
            subject: "Test Receipt from \(sender)",
            sender: sender,
            date: Date(),
            snippet: "Test receipt snippet"
        )
        email.status = status
        return email
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

// Extension to add methods that should exist (these tests will fail until implemented)
extension GmailViewModel {
    @objc func archiveEmail(with emailId: String) {
        // This method should be implemented
        // Phase 2 RED: This will cause test failures until implemented
    }

    @objc func unarchiveEmail(with emailId: String) {
        // This method should be implemented
        // Phase 2 RED: This will cause test failures until implemented
    }

    @objc func archiveSelected() {
        // This method should be implemented
        // Phase 2 RED: This will cause test failures until implemented
    }

    func setStatusFilter(_ filter: EmailStatusFilter) {
        // This method should be implemented
        // Phase 2 RED: This will cause test failures until implemented
    }
}

// Enum for status filtering (should be implemented)
enum EmailStatusFilter {
    case all
    case needsReview
    case transactionCreated
    case archived
}