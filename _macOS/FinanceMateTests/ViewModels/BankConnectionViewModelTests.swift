//
//  BankConnectionViewModelTests.swift
//  FinanceMateTests
//
//  Created by AI Dev Agent on 2025-07-09.
//  Copyright © 2025 FinanceMate. All rights reserved.
//

import XCTest
import CoreData
@testable import FinanceMate

@MainActor
class BankConnectionViewModelTests: XCTestCase {
    
    var viewModel: BankConnectionViewModel!
    var testContext: NSManagedObjectContext!
    var mockAuthManager: MockBasiqAuthenticationManager!
    var mockBankService: MockBankDataService!
    
    override func setUp() {
        super.setUp()
        
        // Create test Core Data context
        testContext = PersistenceController.preview.container.viewContext
        
        // Create mock services
        mockAuthManager = MockBasiqAuthenticationManager()
        mockBankService = MockBankDataService()
        
        // Initialize view model with dependencies
        viewModel = BankConnectionViewModel(
            context: testContext,
            authManager: mockAuthManager,
            bankService: mockBankService
        )
    }
    
    override func tearDown() {
        viewModel = nil
        testContext = nil
        mockAuthManager = nil
        mockBankService = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialState() {
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(viewModel.connectedBankAccounts.isEmpty)
        XCTAssertFalse(viewModel.isAuthenticated)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertNil(viewModel.selectedBankAccount)
    }
    
    // MARK: - Authentication Tests
    
    func testAuthenticateWithAPIKey() async {
        // Given
        let apiKey = "test_api_key_123"
        mockAuthManager.shouldSucceedAuthentication = true
        
        // When
        await viewModel.authenticateWithAPIKey(apiKey)
        
        // Then
        XCTAssertTrue(viewModel.isAuthenticated)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertTrue(mockAuthManager.authenticateWithAPIKeyCalled)
    }
    
    func testAuthenticateWithAPIKeyFailure() async {
        // Given
        let apiKey = "invalid_api_key"
        mockAuthManager.shouldSucceedAuthentication = false
        mockAuthManager.authenticationError = BasiqAuthError.invalidAPIKey
        
        // When
        await viewModel.authenticateWithAPIKey(apiKey)
        
        // Then
        XCTAssertFalse(viewModel.isAuthenticated)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.errorMessage, "Invalid API key provided")
    }
    
    func testAuthenticationLoadingState() async {
        // Given
        let apiKey = "test_api_key_123"
        mockAuthManager.shouldDelayAuthentication = true
        
        // When
        let authTask = Task {
            await viewModel.authenticateWithAPIKey(apiKey)
        }
        
        // Then (during authentication)
        XCTAssertTrue(viewModel.isLoading)
        
        // Wait for completion
        await authTask.value
        
        // Then (after authentication)
        XCTAssertFalse(viewModel.isLoading)
    }
    
    // MARK: - Bank Account Connection Tests
    
    func testFetchBankAccounts() async {
        // Given
        mockAuthManager.isAuthenticated = true
        mockBankService.mockBankAccounts = [
            MockBankAccount(id: "acc_1", bankName: "Commonwealth Bank", accountNumber: "123456789"),
            MockBankAccount(id: "acc_2", bankName: "ANZ Bank", accountNumber: "987654321")
        ]
        
        // When
        await viewModel.fetchBankAccounts()
        
        // Then
        XCTAssertEqual(viewModel.connectedBankAccounts.count, 2)
        XCTAssertEqual(viewModel.connectedBankAccounts.first?.bankName, "Commonwealth Bank")
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testFetchBankAccountsWithoutAuthentication() async {
        // Given
        mockAuthManager.isAuthenticated = false
        
        // When
        await viewModel.fetchBankAccounts()
        
        // Then
        XCTAssertTrue(viewModel.connectedBankAccounts.isEmpty)
        XCTAssertEqual(viewModel.errorMessage, "Please authenticate with your bank first")
    }
    
    func testConnectBankAccount() async {
        // Given
        mockAuthManager.isAuthenticated = true
        let bankConnectionData = BankConnectionData(
            bankName: "Westpac",
            accountNumber: "111222333",
            accountType: "Savings",
            entityId: UUID()
        )
        
        // When
        await viewModel.connectBankAccount(bankConnectionData)
        
        // Then
        XCTAssertEqual(viewModel.connectedBankAccounts.count, 1)
        XCTAssertEqual(viewModel.connectedBankAccounts.first?.bankName, "Westpac")
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testDisconnectBankAccount() async {
        // Given
        let bankAccount = createTestBankAccount()
        viewModel.connectedBankAccounts = [bankAccount]
        
        // When
        await viewModel.disconnectBankAccount(bankAccount)
        
        // Then
        XCTAssertTrue(viewModel.connectedBankAccounts.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    // MARK: - Bank Account Management Tests
    
    func testSelectBankAccount() {
        // Given
        let bankAccount = createTestBankAccount()
        viewModel.connectedBankAccounts = [bankAccount]
        
        // When
        viewModel.selectBankAccount(bankAccount)
        
        // Then
        XCTAssertEqual(viewModel.selectedBankAccount?.id, bankAccount.id)
    }
    
    func testUpdateBankAccount() async {
        // Given
        let bankAccount = createTestBankAccount()
        let updatedData = BankConnectionData(
            bankName: "Updated Bank Name",
            accountNumber: "999888777",
            accountType: "Checking",
            entityId: UUID()
        )
        
        // When
        await viewModel.updateBankAccount(bankAccount, with: updatedData)
        
        // Then
        XCTAssertEqual(bankAccount.bankName, "Updated Bank Name")
        XCTAssertEqual(bankAccount.accountType, "Checking")
        XCTAssertNil(viewModel.errorMessage)
    }
    
    // MARK: - Error Handling Tests
    
    func testHandleNetworkError() async {
        // Given
        mockAuthManager.isAuthenticated = true
        mockBankService.shouldFailFetchAccounts = true
        mockBankService.fetchAccountsError = NetworkError.connectionFailed
        
        // When
        await viewModel.fetchBankAccounts()
        
        // Then
        XCTAssertTrue(viewModel.connectedBankAccounts.isEmpty)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.errorMessage?.contains("Network error") == true)
    }
    
    func testClearError() {
        // Given
        viewModel.errorMessage = "Test error"
        
        // When
        viewModel.clearError()
        
        // Then
        XCTAssertNil(viewModel.errorMessage)
    }
    
    // MARK: - Loading State Tests
    
    func testLoadingStateManagement() async {
        // Given
        mockAuthManager.isAuthenticated = true
        mockBankService.shouldDelayFetchAccounts = true
        
        // When
        let fetchTask = Task {
            await viewModel.fetchBankAccounts()
        }
        
        // Then (during fetch)
        XCTAssertTrue(viewModel.isLoading)
        
        // Wait for completion
        await fetchTask.value
        
        // Then (after fetch)
        XCTAssertFalse(viewModel.isLoading)
    }
    
    // MARK: - Core Data Integration Tests
    
    func testPersistBankAccount() async {
        // Given
        let bankConnectionData = BankConnectionData(
            bankName: "Test Bank",
            accountNumber: "123456789",
            accountType: "Savings",
            entityId: UUID()
        )
        
        // When
        await viewModel.connectBankAccount(bankConnectionData)
        
        // Then
        let fetchRequest: NSFetchRequest<BankAccount> = BankAccount.fetchRequest()
        let savedAccounts = try? testContext.fetch(fetchRequest)
        
        XCTAssertEqual(savedAccounts?.count, 1)
        XCTAssertEqual(savedAccounts?.first?.bankName, "Test Bank")
        XCTAssertEqual(savedAccounts?.first?.accountType, "Savings")
    }
    
    func testDeleteBankAccountFromCoreData() async {
        // Given
        let bankAccount = createTestBankAccount()
        try? testContext.save()
        
        // When
        await viewModel.disconnectBankAccount(bankAccount)
        
        // Then
        let fetchRequest: NSFetchRequest<BankAccount> = BankAccount.fetchRequest()
        let remainingAccounts = try? testContext.fetch(fetchRequest)
        
        XCTAssertEqual(remainingAccounts?.count, 0)
    }
    
    // MARK: - Entity Assignment Tests
    
    func testAssignBankAccountToEntity() async {
        // Given
        let entity = createTestFinancialEntity()
        let bankConnectionData = BankConnectionData(
            bankName: "Test Bank",
            accountNumber: "123456789",
            accountType: "Savings",
            entityId: entity.id
        )
        
        // When
        await viewModel.connectBankAccount(bankConnectionData)
        
        // Then
        let bankAccount = viewModel.connectedBankAccounts.first
        XCTAssertEqual(bankAccount?.financialEntity?.id, entity.id)
    }
    
    // MARK: - Sync Tests
    
    func testSyncBankAccountTransactions() async {
        // Given
        let bankAccount = createTestBankAccount()
        mockBankService.mockTransactions = [
            MockTransaction(id: "txn_1", amount: 100.0, description: "Test Transaction 1"),
            MockTransaction(id: "txn_2", amount: -50.0, description: "Test Transaction 2")
        ]
        
        // When
        await viewModel.syncTransactions(for: bankAccount)
        
        // Then
        XCTAssertTrue(mockBankService.syncTransactionsCalled)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    // MARK: - Validation Tests
    
    func testValidateBankConnectionData() {
        // Given
        let validData = BankConnectionData(
            bankName: "Test Bank",
            accountNumber: "123456789",
            accountType: "Savings",
            entityId: UUID()
        )
        
        let invalidData = BankConnectionData(
            bankName: "",
            accountNumber: "123",
            accountType: "",
            entityId: UUID()
        )
        
        // When & Then
        XCTAssertTrue(viewModel.validateBankConnectionData(validData))
        XCTAssertFalse(viewModel.validateBankConnectionData(invalidData))
    }
    
    func testValidateBankConnectionDataErrors() {
        // Given
        let invalidData = BankConnectionData(
            bankName: "",
            accountNumber: "123",
            accountType: "",
            entityId: UUID()
        )
        
        // When
        let isValid = viewModel.validateBankConnectionData(invalidData)
        
        // Then
        XCTAssertFalse(isValid)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.errorMessage?.contains("Bank name is required") == true)
    }
    
    // MARK: - Performance Tests
    
    func testPerformanceFetchLargeBankAccountList() async {
        // Given
        mockAuthManager.isAuthenticated = true
        mockBankService.mockBankAccounts = (1...100).map { index in
            MockBankAccount(
                id: "acc_\(index)",
                bankName: "Bank \(index)",
                accountNumber: "12345678\(index)"
            )
        }
        
        // When
        let startTime = CFAbsoluteTimeGetCurrent()
        await viewModel.fetchBankAccounts()
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        // Then
        XCTAssertEqual(viewModel.connectedBankAccounts.count, 100)
        XCTAssertLessThan(timeElapsed, 1.0) // Should complete within 1 second
    }
    
    // MARK: - Helper Methods
    
    private func createTestBankAccount() -> BankAccount {
        let bankAccount = BankAccount(context: testContext)
        bankAccount.id = UUID()
        bankAccount.bankName = "Test Bank"
        bankAccount.accountNumber = "123456789"
        bankAccount.accountType = "Savings"
        bankAccount.isActive = true
        bankAccount.lastSyncDate = Date()
        return bankAccount
    }
    
    private func createTestFinancialEntity() -> FinancialEntity {
        let entity = FinancialEntity(context: testContext)
        entity.id = UUID()
        entity.name = "Test Entity"
        entity.type = "Personal"
        entity.isActive = true
        entity.createdAt = Date()
        entity.lastModified = Date()
        return entity
    }
}

// MARK: - Mock Classes

class MockBasiqAuthenticationManager: BasiqAuthenticationManager {
    var shouldSucceedAuthentication = true
    var shouldDelayAuthentication = false
    var authenticationError: BasiqAuthError?
    var authenticateWithAPIKeyCalled = false
    
    override func authenticateWithAPIKey(_ apiKey: String) async throws {
        authenticateWithAPIKeyCalled = true
        
        if shouldDelayAuthentication {
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
        }
        
        if shouldSucceedAuthentication {
            await MainActor.run {
                self.isAuthenticated = true
            }
        } else {
            if let error = authenticationError {
                throw error
            }
        }
    }
}

class MockBankDataService: BankDataService {
    var mockBankAccounts: [MockBankAccount] = []
    var mockTransactions: [MockTransaction] = []
    var shouldFailFetchAccounts = false
    var shouldDelayFetchAccounts = false
    var fetchAccountsError: Error?
    var syncTransactionsCalled = false
    
    override func fetchBankAccounts() async throws -> [BankAccount] {
        if shouldDelayFetchAccounts {
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
        }
        
        if shouldFailFetchAccounts {
            throw fetchAccountsError ?? NetworkError.connectionFailed
        }
        
        return mockBankAccounts.map { mockAccount in
            let bankAccount = BankAccount(context: PersistenceController.preview.container.viewContext)
            bankAccount.id = UUID()
            bankAccount.bankName = mockAccount.bankName
            bankAccount.accountNumber = mockAccount.accountNumber
            bankAccount.accountType = "Savings"
            bankAccount.isActive = true
            return bankAccount
        }
    }
    
    override func syncTransactions(for bankAccount: BankAccount) async throws {
        syncTransactionsCalled = true
        
        if shouldDelayFetchAccounts {
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
        }
        
        // Simulate successful sync
    }
}

// MARK: - Mock Data Models

struct MockBankAccount {
    let id: String
    let bankName: String
    let accountNumber: String
}

struct MockTransaction {
    let id: String
    let amount: Double
    let description: String
}

// MARK: - Error Types

enum NetworkError: Error {
    case connectionFailed
    case invalidResponse
    case authenticationRequired
}

enum BasiqAuthError: Error, LocalizedError {
    case invalidAPIKey
    case tokenExchangeFailed(Int)
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidAPIKey:
            return "Invalid API key provided"
        case .tokenExchangeFailed(let code):
            return "Token exchange failed with status: \(code)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}

// MARK: - Data Models

struct BankConnectionData {
    let bankName: String
    let accountNumber: String
    let accountType: String
    let entityId: UUID
}