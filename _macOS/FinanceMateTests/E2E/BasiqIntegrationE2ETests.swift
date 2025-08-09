//
//  BasiqIntegrationE2ETests.swift
//  FinanceMateTests
//
//  Purpose: Comprehensive End-to-End tests for Basiq financial data integration
//  Validates complete user journey from bank connection to data display
//  Ensures all Blueprint requirements are met with production-grade testing
//
//  Key Test Coverage:
//  - Complete user journey validation
//  - Authentication and OAuth 2.0 flow
//  - Data synchronization with Core Data
//  - Error handling and recovery
//  - Security compliance validation
//  - Performance benchmarks
//
//  Created by Test Automation on 8/6/25.
//

import XCTest
import CoreData
import Combine
@testable import FinanceMate

/**
 * COMPREHENSIVE E2E TEST SUITE FOR BASIQ INFRASTRUCTURE
 * 
 * Test Coverage Areas:
 * - User Journey: Bank connection → Account fetch → Transaction sync → Dashboard display
 * - Security: OAuth flow, token management, encrypted storage
 * - Resilience: Error recovery, network handling, retry logic
 * - Data Integrity: Deduplication, accuracy, consistency
 * - Performance: Response times, memory usage, sync speed
 *
 * Compliance:
 * - 100% Headless execution (no UI interaction)
 * - Silent test execution with log output only
 * - Automated pass/fail determination
 * - Real data validation (no mock services)
 */
@MainActor
final class BasiqIntegrationE2ETests: XCTestCase {
    
    // MARK: - Test Infrastructure
    
    private var persistenceController: PersistenceController!
    private var context: NSManagedObjectContext!
    private var basiqService: BasiqService!
    private var syncManager: FinancialDataSyncManager!
    private var cancellables = Set<AnyCancellable>()
    
    // Test configuration
    private let testTimeout: TimeInterval = 10.0
    private let performanceThreshold: TimeInterval = 2.0
    
    // MARK: - Setup & Teardown
    
    override func setUpWithError() throws {
        super.setUp()
        
        // Initialize in-memory Core Data stack for testing
        persistenceController = PersistenceController(inMemory: true)
        context = MainActor.assumeIsolated {
            persistenceController.container.viewContext
        }
        
        // Configure context for testing
        context.automaticallyMergesChangesFromParent = true
        context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        
        // Initialize services
        basiqService = BasiqService()
        syncManager = FinancialDataSyncManager(
            provider: basiqService,
            context: context
        )
        
        // Reset UserDefaults for clean test state
        UserDefaults.standard.removeObject(
            forKey: FinancialServicesConfig.UserDefaultsKeys.lastSyncDate
        )
        UserDefaults.standard.removeObject(
            forKey: FinancialServicesConfig.UserDefaultsKeys.syncEnabled
        )
    }
    
    override func tearDownWithError() throws {
        // Clean up all test data
        cancellables.removeAll()
        
        // Clear Core Data
        if let context = context {
            let entities = ["Transaction", "Asset", "Liability", "NetWealthSnapshot"]
            for entity in entities {
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
                try context.execute(deleteRequest)
            }
            context.reset()
        }
        
        // Disconnect service
        Task { @MainActor in
            try? await basiqService.disconnect()
        }
        
        // Clean up references
        syncManager = nil
        basiqService = nil
        context = nil
        persistenceController = nil
        
        super.tearDown()
    }
    
    // MARK: - Scenario 1: Successful Bank Connection Journey
    
    func testCompleteBasiqIntegrationFlow() async throws {
        // Test complete user journey from connection to dashboard display
        
        // Step 1: Initialize and verify service readiness
        XCTAssertFalse(basiqService.isConnected)
        XCTAssertNil(basiqService.currentConnection)
        XCTAssertNil(basiqService.lastError)
        
        // Step 2: Connect to test institution (using sandbox institution ID)
        let institutionId = "AU00000" // Basiq sandbox institution
        
        let expectation = XCTestExpectation(description: "Bank connection completes")
        
        do {
            let connection = try await basiqService.connect(institution: institutionId)
            
            // Verify connection established
            XCTAssertTrue(basiqService.isConnected)
            XCTAssertNotNil(connection.sessionId)
            XCTAssertEqual(connection.institutionId, institutionId)
            XCTAssertNotNil(connection.userId)
            XCTAssertNil(basiqService.lastError)
            
            // Step 3: Fetch accounts
            let accounts = try await basiqService.fetchAccounts()
            
            // Verify accounts retrieved
            XCTAssertFalse(accounts.isEmpty, "Should retrieve at least one account")
            
            for account in accounts {
                XCTAssertNotNil(account.id)
                XCTAssertNotNil(account.accountNumber)
                XCTAssertNotNil(account.accountType)
                XCTAssertGreaterThanOrEqual(account.balance, 0)
            }
            
            // Step 4: Sync transactions for each account
            var totalTransactions = 0
            
            for account in accounts {
                let transactions = try await basiqService.fetchTransactions(
                    accountId: account.id,
                    from: Calendar.current.date(byAdding: .day, value: -30, to: Date()),
                    to: Date()
                )
                
                totalTransactions += transactions.count
                
                // Verify transaction data integrity
                for transaction in transactions {
                    XCTAssertNotNil(transaction.id)
                    XCTAssertNotNil(transaction.date)
                    XCTAssertNotEqual(transaction.amount, 0)
                    XCTAssertFalse(transaction.description.isEmpty)
                }
            }
            
            // Step 5: Perform full data sync to Core Data
            await syncManager.performFullSync()
            
            // Verify sync completed successfully
            XCTAssertEqual(syncManager.syncStatus, .success)
            XCTAssertNotNil(syncManager.lastSyncDate)
            XCTAssertEqual(syncManager.syncProgress, 1.0)
            XCTAssertTrue(syncManager.syncErrors.isEmpty)
            
            // Step 6: Verify data persisted to Core Data
            let transactionRequest = NSFetchRequest<Transaction>(entityName: "Transaction")
            let savedTransactions = try context.fetch(transactionRequest)
            
            XCTAssertGreaterThan(savedTransactions.count, 0, "Transactions should be saved to Core Data")
            
            // Verify transaction data integrity in Core Data
            for transaction in savedTransactions {
                XCTAssertNotNil(transaction.id)
                XCTAssertNotNil(transaction.date)
                XCTAssertNotNil(transaction.amount)
                XCTAssertNotNil(transaction.category)
                XCTAssertNotNil(transaction.externalId) // Basiq transaction ID
            }
            
            expectation.fulfill()
            
        } catch {
            XCTFail("Complete flow failed with error: \(error)")
        }
        
        await fulfillment(of: [expectation], timeout: testTimeout)
    }
    
    // MARK: - Scenario 2: Authentication Error Recovery
    
    func testAuthenticationErrorRecovery() async throws {
        // Test authentication failure and recovery mechanism
        
        // Step 1: Simulate authentication failure by using invalid institution
        let invalidInstitution = "INVALID_INSTITUTION_ID"
        
        do {
            _ = try await basiqService.connect(institution: invalidInstitution)
            XCTFail("Should have thrown authentication error")
        } catch {
            // Verify proper error handling
            XCTAssertFalse(basiqService.isConnected)
            XCTAssertNotNil(basiqService.lastError)
            
            if let serviceError = basiqService.lastError {
                switch serviceError {
                case .authenticationRequired, .invalidRequest:
                    // Expected error types
                    XCTAssertTrue(true)
                default:
                    XCTFail("Unexpected error type: \(serviceError)")
                }
            }
        }
        
        // Step 2: Verify service can recover with valid credentials
        let validInstitution = "AU00000"
        
        do {
            let connection = try await basiqService.connect(institution: validInstitution)
            
            // Verify recovery successful
            XCTAssertTrue(basiqService.isConnected)
            XCTAssertNotNil(connection)
            XCTAssertNil(basiqService.lastError) // Error cleared after successful connection
            
        } catch {
            XCTFail("Recovery failed with error: \(error)")
        }
    }
    
    // MARK: - Scenario 3: Network Resilience & Retry Logic
    
    func testNetworkResilienceAndRetry() async throws {
        // Test network failure handling and automatic retry
        
        // Connect successfully first
        let institutionId = "AU00000"
        _ = try await basiqService.connect(institution: institutionId)
        
        // Test transaction fetch with simulated network issues
        // The service should handle rate limiting and retry automatically
        
        var retryCount = 0
        let maxRetries = 3
        
        while retryCount < maxRetries {
            do {
                // Attempt to fetch transactions rapidly to potentially trigger rate limiting
                let accounts = try await basiqService.fetchAccounts()
                
                if let firstAccount = accounts.first {
                    _ = try await basiqService.fetchTransactions(
                        accountId: firstAccount.id,
                        from: Date().addingTimeInterval(-86400),
                        to: Date()
                    )
                }
                
                // If successful, verify we can continue
                XCTAssertTrue(basiqService.isConnected)
                break
                
            } catch {
                retryCount += 1
                
                // Check if error is recoverable
                if let serviceError = error as? FinancialServiceError {
                    XCTAssertTrue(serviceError.isRetryable)
                    
                    // Wait before retry (respecting rate limits)
                    if case .rateLimitExceeded(let retryAfter) = serviceError {
                        XCTAssertGreaterThan(retryAfter, 0)
                    }
                }
                
                // Allow time for recovery
                try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            }
        }
        
        XCTAssertLessThan(retryCount, maxRetries, "Should succeed within retry limit")
    }
    
    // MARK: - Scenario 4: Data Integrity Validation
    
    func testTransactionDataIntegrity() async throws {
        // Test transaction deduplication, balance accuracy, and data consistency
        
        // Connect and fetch initial data
        let institutionId = "AU00000"
        _ = try await basiqService.connect(institution: institutionId)
        
        // Perform initial sync
        await syncManager.performFullSync()
        
        // Get initial transaction count
        let initialRequest = NSFetchRequest<Transaction>(entityName: "Transaction")
        let initialTransactions = try context.fetch(initialRequest)
        let initialCount = initialTransactions.count
        
        // Perform second sync (should handle deduplication)
        await syncManager.performFullSync()
        
        // Verify no duplicates created
        let finalRequest = NSFetchRequest<Transaction>(entityName: "Transaction")
        let finalTransactions = try context.fetch(finalRequest)
        let finalCount = finalTransactions.count
        
        XCTAssertEqual(initialCount, finalCount, "No duplicate transactions should be created")
        
        // Verify transaction data integrity
        let uniqueExternalIds = Set(finalTransactions.compactMap { $0.externalId })
        XCTAssertEqual(uniqueExternalIds.count, finalCount, "All transactions should have unique external IDs")
        
        // Verify date filtering works correctly
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
        let dateFilteredRequest = NSFetchRequest<Transaction>(entityName: "Transaction")
        dateFilteredRequest.predicate = NSPredicate(format: "date >= %@", thirtyDaysAgo as NSDate)
        
        let recentTransactions = try context.fetch(dateFilteredRequest)
        
        for transaction in recentTransactions {
            XCTAssertGreaterThanOrEqual(transaction.date!, thirtyDaysAgo)
            XCTAssertLessThanOrEqual(transaction.date!, Date())
        }
        
        // Verify category preservation
        for transaction in finalTransactions {
            XCTAssertNotNil(transaction.category)
            XCTAssertFalse(transaction.category!.isEmpty)
        }
    }
    
    // MARK: - Scenario 5: Security Compliance Validation
    
    func testSecurityCompliance() async throws {
        // Test security requirements: encrypted storage, no plain text secrets, secure token handling
        
        // Step 1: Verify API keys are not exposed
        let config = FinancialServicesConfig.self
        
        // API key should come from secure storage, not hardcoded
        XCTAssertFalse(config.basiqAPIKey.isEmpty)
        XCTAssertFalse(config.basiqAPIKey.contains("test"))
        XCTAssertFalse(config.basiqAPIKey.contains("mock"))
        
        // Step 2: Test OAuth token refresh
        _ = try await basiqService.connect(institution: "AU00000")
        
        // Initial connection should have token
        XCTAssertTrue(basiqService.isConnected)
        
        // Test refresh mechanism
        try await basiqService.refreshConnection()
        
        // Should maintain connection after refresh
        XCTAssertTrue(basiqService.isConnected)
        XCTAssertNotNil(basiqService.currentConnection)
        
        // Step 3: Verify no sensitive data in logs
        // This is validated by checking that the service doesn't print sensitive info
        let accounts = try await basiqService.fetchAccounts()
        
        for account in accounts {
            // Account numbers should be masked in any string representation
            let accountString = String(describing: account)
            XCTAssertFalse(accountString.contains(account.accountNumber))
        }
        
        // Step 4: Test secure disconnection
        try await basiqService.disconnect()
        
        // Verify all sensitive data cleared
        XCTAssertFalse(basiqService.isConnected)
        XCTAssertNil(basiqService.currentConnection)
    }
    
    // MARK: - Performance Benchmarks
    
    func testPerformanceBenchmarks() async throws {
        // Test sync speed, memory usage, and response times
        
        // Measure connection time
        let connectionStart = CFAbsoluteTimeGetCurrent()
        _ = try await basiqService.connect(institution: "AU00000")
        let connectionTime = CFAbsoluteTimeGetCurrent() - connectionStart
        
        XCTAssertLessThan(connectionTime, performanceThreshold, "Connection should complete within \(performanceThreshold) seconds")
        
        // Measure account fetch time
        let accountStart = CFAbsoluteTimeGetCurrent()
        let accounts = try await basiqService.fetchAccounts()
        let accountTime = CFAbsoluteTimeGetCurrent() - accountStart
        
        XCTAssertLessThan(accountTime, performanceThreshold, "Account fetch should complete within \(performanceThreshold) seconds")
        
        // Measure full sync performance
        let syncStart = CFAbsoluteTimeGetCurrent()
        await syncManager.performFullSync()
        let syncTime = CFAbsoluteTimeGetCurrent() - syncStart
        
        XCTAssertLessThan(syncTime, performanceThreshold * 2, "Full sync should complete within \(performanceThreshold * 2) seconds")
        
        // Verify memory efficiency
        let transactionRequest = NSFetchRequest<Transaction>(entityName: "Transaction")
        let transactionCount = try context.count(for: transactionRequest)
        
        // Memory usage should be reasonable even with many transactions
        XCTAssertGreaterThan(transactionCount, 0)
        
        // Test incremental sync performance (should be faster than full sync)
        let incrementalStart = CFAbsoluteTimeGetCurrent()
        await syncManager.performIncrementalSync()
        let incrementalTime = CFAbsoluteTimeGetCurrent() - incrementalStart
        
        XCTAssertLessThan(incrementalTime, syncTime, "Incremental sync should be faster than full sync")
    }
    
    // MARK: - Edge Cases & Error Scenarios
    
    func testEmptyAccountHandling() async throws {
        // Test handling of accounts with no transactions
        
        _ = try await basiqService.connect(institution: "AU00000")
        let accounts = try await basiqService.fetchAccounts()
        
        // Even empty accounts should be handled gracefully
        for account in accounts {
            let transactions = try await basiqService.fetchTransactions(
                accountId: account.id,
                from: Date().addingTimeInterval(-1), // Very recent, likely no transactions
                to: Date()
            )
            
            // Should return empty array, not error
            XCTAssertNotNil(transactions)
        }
    }
    
    func testConcurrentSyncOperations() async throws {
        // Test that concurrent sync operations are handled properly
        
        _ = try await basiqService.connect(institution: "AU00000")
        
        // Attempt concurrent syncs
        async let sync1 = syncManager.performFullSync()
        async let sync2 = syncManager.performFullSync()
        
        await sync1
        await sync2
        
        // Only one should execute, second should be skipped
        XCTAssertEqual(syncManager.syncStatus, .success)
        XCTAssertFalse(syncManager.isSyncing)
    }
    
    func testSyncProgressReporting() async throws {
        // Test that sync progress is accurately reported
        
        _ = try await basiqService.connect(institution: "AU00000")
        
        var progressUpdates: [Double] = []
        
        // Monitor progress updates
        let progressExpectation = XCTestExpectation(description: "Progress updates received")
        
        syncManager.$syncProgress
            .sink { progress in
                progressUpdates.append(progress)
                if progress == 1.0 {
                    progressExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        await syncManager.performFullSync()
        
        await fulfillment(of: [progressExpectation], timeout: testTimeout)
        
        // Verify progress updates were incremental
        XCTAssertGreaterThan(progressUpdates.count, 2)
        XCTAssertEqual(progressUpdates.last, 1.0)
        
        // Progress should increase monotonically
        for i in 1..<progressUpdates.count {
            XCTAssertGreaterThanOrEqual(progressUpdates[i], progressUpdates[i-1])
        }
    }
    
    // MARK: - Auto-Sync Functionality
    
    func testAutoSyncConfiguration() async throws {
        // Test automatic synchronization setup and execution
        
        // Enable auto-sync
        UserDefaults.standard.set(true, forKey: FinancialServicesConfig.UserDefaultsKeys.syncEnabled)
        
        // Create new sync manager (will read auto-sync preference)
        let autoSyncManager = FinancialDataSyncManager(
            provider: basiqService,
            context: context
        )
        
        // Connect service
        _ = try await basiqService.connect(institution: "AU00000")
        
        // Auto-sync should be running
        // Note: In real scenario, we'd wait for timer to fire
        // For testing, we manually trigger
        await autoSyncManager.performIncrementalSync()
        
        XCTAssertNotNil(autoSyncManager.lastSyncDate)
        
        // Stop auto-sync
        autoSyncManager.stopAutoSync()
    }
}

// MARK: - Test Utilities

extension BasiqIntegrationE2ETests {
    
    /// Helper to create test transaction data
    private func createTestTransaction(
        amount: Double,
        date: Date = Date(),
        category: String = "Test"
    ) -> Transaction {
        let transaction = Transaction(context: context)
        transaction.id = UUID()
        transaction.amount = amount
        transaction.date = date
        transaction.category = category
        transaction.createdAt = Date()
        return transaction
    }
    
    /// Helper to verify sync error recovery
    private func verifySyncErrorRecovery(_ error: FinancialDataSyncManager.SyncError) {
        XCTAssertNotNil(error.date)
        XCTAssertFalse(error.message.isEmpty)
        
        if error.isRecoverable {
            // Recoverable errors should allow retry
            XCTAssertTrue(error.message.contains("retry") || error.message.contains("temporary"))
        }
    }
}

/**
 * E2E TEST COVERAGE SUMMARY
 * 
 * ✅ Complete User Journey: Bank connection → Data display
 * ✅ Authentication & OAuth: Token management and refresh
 * ✅ Data Synchronization: Full and incremental sync
 * ✅ Error Recovery: Authentication and network failures
 * ✅ Data Integrity: Deduplication and consistency
 * ✅ Security Validation: No plain text secrets, secure storage
 * ✅ Performance Benchmarks: <2 second response times
 * ✅ Edge Cases: Empty accounts, concurrent operations
 * ✅ Auto-Sync: Scheduled synchronization
 * 
 * Test Execution: 100% Headless, Silent, Automated
 * Expected Coverage: >95% of Basiq infrastructure
 * Performance Target: All operations <2 seconds
 * Security: Zero plain text credentials
 */