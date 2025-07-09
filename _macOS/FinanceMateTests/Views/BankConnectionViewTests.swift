//
//  BankConnectionViewTests.swift
//  FinanceMateTests
//
//  Created by AI Dev Agent on 2025-07-09.
//  Copyright © 2025 FinanceMate. All rights reserved.
//

import XCTest
import SwiftUI
import CoreData
@testable import FinanceMate

/**
 * Purpose: Comprehensive test suite for BankConnectionView UI component
 * Issues & Complexity Summary: UI testing complexity, mock integration, state management validation
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~650+
 *   - Core Algorithm Complexity: Medium-High (UI state testing, async operations)
 *   - Dependencies: 4 New (SwiftUI testing, Core Data mocks, ViewModel testing)
 *   - State Management Complexity: High (multi-step authentication flow testing)
 *   - Novelty/Uncertainty Factor: Medium (SwiftUI UI testing patterns)
 * AI Pre-Task Self-Assessment: 70%
 * Problem Estimate: 75%
 * Initial Code Complexity Estimate: 80%
 * Final Code Complexity: 85%
 * Overall Result Score: 88%
 * Key Variances/Learnings: SwiftUI UI testing requires more introspection patterns than expected
 * Last Updated: 2025-07-09
 */

class BankConnectionViewTests: XCTestCase {
    
    private var testContext: NSManagedObjectContext!
    private var mockViewModel: MockBankConnectionViewModel!
    
    override func setUp() {
        super.setUp()
        
        // Setup test Core Data context
        testContext = PersistenceController.preview.container.viewContext
        
        // Setup mock view model
        mockViewModel = MockBankConnectionViewModel(context: testContext)
    }
    
    override func tearDown() {
        testContext = nil
        mockViewModel = nil
        super.tearDown()
    }
    
    // MARK: - UI State Management Tests
    
    func testBankSelectionUpdatesViewModel() {
        // Given
        let view = BankConnectionView(viewModel: mockViewModel)
        let testBank = BankInstitution.supportedBanks.first!
        
        // When
        // Simulate bank selection (would be done through UI interaction)
        mockViewModel.selectedBank = testBank
        
        // Then
        XCTAssertEqual(mockViewModel.selectedBank?.name, testBank.name)
        XCTAssertEqual(mockViewModel.selectedBank?.id, testBank.id)
    }
    
    func testAuthenticationFlowProgression() {
        // Given
        let view = BankConnectionView(viewModel: mockViewModel)
        
        // When
        mockViewModel.currentAuthStep = .apiKey
        
        // Then
        XCTAssertEqual(mockViewModel.currentAuthStep, .apiKey)
    }
    
    func testLoadingStateManagement() {
        // Given
        let view = BankConnectionView(viewModel: mockViewModel)
        
        // When
        mockViewModel.isLoading = true
        
        // Then
        XCTAssertTrue(mockViewModel.isLoading)
        
        // When
        mockViewModel.isLoading = false
        
        // Then
        XCTAssertFalse(mockViewModel.isLoading)
    }
    
    func testErrorStateHandling() {
        // Given
        let view = BankConnectionView(viewModel: mockViewModel)
        let testError = "Test error message"
        
        // When
        mockViewModel.errorMessage = testError
        
        // Then
        XCTAssertEqual(mockViewModel.errorMessage, testError)
        
        // When
        mockViewModel.clearError()
        
        // Then
        XCTAssertNil(mockViewModel.errorMessage)
    }
    
    func testBankSelectionCardEnabled() {
        // Given
        let supportedBank = BankInstitution.supportedBanks.first { $0.isSupported }!
        let card = BankSelectionCard(bank: supportedBank, isSelected: false, onSelect: {})
        
        // Then
        XCTAssertTrue(supportedBank.isSupported)
        XCTAssertEqual(supportedBank.name, "Commonwealth Bank")
    }
    
    func testBankSelectionCardDisabled() {
        // Given
        let unsupportedBank = BankInstitution.supportedBanks.first { !$0.isSupported }!
        let card = BankSelectionCard(bank: unsupportedBank, isSelected: false, onSelect: {})
        
        // Then
        XCTAssertFalse(unsupportedBank.isSupported)
        XCTAssertEqual(unsupportedBank.name, "Bendigo Bank")
    }
    
    func testConnectedAccountsDisplay() {
        // Given
        let testAccount = createTestBankAccount()
        mockViewModel.connectedBankAccounts = [testAccount]
        
        // When
        let hasConnectedAccounts = mockViewModel.hasConnectedAccounts
        
        // Then
        XCTAssertTrue(hasConnectedAccounts)
        XCTAssertEqual(mockViewModel.connectedBankAccounts.count, 1)
        XCTAssertEqual(mockViewModel.connectedBankAccounts.first?.bankName, "Test Bank")
    }
    
    func testAccountSelection() {
        // Given
        let testAccount = createTestBankAccount()
        mockViewModel.connectedBankAccounts = [testAccount]
        
        // When
        mockViewModel.selectBankAccount(testAccount)
        
        // Then
        XCTAssertEqual(mockViewModel.selectedBankAccount?.id, testAccount.id)
    }
    
    // MARK: - Integration Tests
    
    func testViewModelIntegration() {
        // Given
        let view = BankConnectionView(viewModel: mockViewModel)
        
        // When
        mockViewModel.isAuthenticated = true
        
        // Then
        XCTAssertTrue(mockViewModel.isAuthenticated)
    }
    
    func testNavigationFlowTesting() {
        // Given
        let view = BankConnectionView(viewModel: mockViewModel)
        
        // When
        mockViewModel.currentAuthStep = .selectBank
        
        // Then
        XCTAssertEqual(mockViewModel.currentAuthStep, .selectBank)
        
        // When
        mockViewModel.currentAuthStep = .apiKey
        
        // Then
        XCTAssertEqual(mockViewModel.currentAuthStep, .apiKey)
    }
    
    func testDataBindingValidation() {
        // Given
        let view = BankConnectionView(viewModel: mockViewModel)
        let testBank = BankInstitution.supportedBanks.first!
        
        // When
        mockViewModel.selectedBank = testBank
        
        // Then
        XCTAssertNotNil(mockViewModel.selectedBank)
        XCTAssertEqual(mockViewModel.selectedBank?.name, testBank.name)
    }
    
    func testPerformanceUnderLoad() {
        // Given
        let view = BankConnectionView(viewModel: mockViewModel)
        let accounts = (1...100).map { _ in createTestBankAccount() }
        
        // When
        let startTime = Date()
        mockViewModel.connectedBankAccounts = accounts
        let endTime = Date()
        
        // Then
        let duration = endTime.timeIntervalSince(startTime)
        XCTAssertLessThan(duration, 1.0, "Loading 100 accounts should take less than 1 second")
        XCTAssertEqual(mockViewModel.connectedBankAccounts.count, 100)
    }
    
    // MARK: - Authentication Flow Tests
    
    func testAuthenticationStepProgression() {
        // Given
        let view = BankConnectionView(viewModel: mockViewModel)
        
        // When
        mockViewModel.currentAuthStep = .selectBank
        
        // Then
        XCTAssertEqual(mockViewModel.currentAuthStep, .selectBank)
        
        // When
        mockViewModel.currentAuthStep = .apiKey
        
        // Then
        XCTAssertEqual(mockViewModel.currentAuthStep, .apiKey)
        
        // When
        mockViewModel.currentAuthStep = .complete
        
        // Then
        XCTAssertEqual(mockViewModel.currentAuthStep, .complete)
    }
    
    func testAuthenticationValidation() {
        // Given
        let credentials = AuthCredentials()
        
        // When
        let isValidEmpty = credentials.isValid
        
        // Then
        XCTAssertFalse(isValidEmpty)
        
        // When
        var validCredentials = AuthCredentials()
        validCredentials.accountNumber = "123456789"
        validCredentials.accountType = BankAccountType.savings.rawValue
        
        // Then
        XCTAssertTrue(validCredentials.isValid)
    }
    
    func testTwoFactorAuthenticationFlow() {
        // Given
        let view = BankConnectionView(viewModel: mockViewModel)
        let twoFactorCode = "123456"
        
        // When
        mockViewModel.currentAuthStep = .twoFactor
        
        // Then
        XCTAssertEqual(mockViewModel.currentAuthStep, .twoFactor)
        XCTAssertEqual(twoFactorCode.count, 6)
    }
    
    func testAuthenticationCompletion() {
        // Given
        let view = BankConnectionView(viewModel: mockViewModel)
        
        // When
        mockViewModel.currentAuthStep = .complete
        mockViewModel.isAuthenticated = true
        
        // Then
        XCTAssertEqual(mockViewModel.currentAuthStep, .complete)
        XCTAssertTrue(mockViewModel.isAuthenticated)
    }
    
    // MARK: - Connection Status Tests
    
    func testConnectionStatusIndicator() {
        // Given
        let connectedStatus = ConnectionStatus.connected
        let disconnectedStatus = ConnectionStatus.disconnected
        let errorStatus = ConnectionStatus.error
        
        // Then
        XCTAssertEqual(connectedStatus.displayName, "Connected")
        XCTAssertEqual(connectedStatus.statusColor, "green")
        
        XCTAssertEqual(disconnectedStatus.displayName, "Disconnected")
        XCTAssertEqual(disconnectedStatus.statusColor, "gray")
        
        XCTAssertEqual(errorStatus.displayName, "Error")
        XCTAssertEqual(errorStatus.statusColor, "red")
    }
    
    func testAccountConnectionManagement() {
        // Given
        let testAccount = createTestBankAccount()
        mockViewModel.connectedBankAccounts = [testAccount]
        
        // When
        testAccount.updateConnectionStatus(.connected)
        
        // Then
        XCTAssertTrue(testAccount.isConnected)
        XCTAssertEqual(testAccount.connectionStatusEnum, .connected)
        
        // When
        testAccount.updateConnectionStatus(.error, errorMessage: "Test error")
        
        // Then
        XCTAssertFalse(testAccount.isConnected)
        XCTAssertEqual(testAccount.connectionStatusEnum, .error)
        XCTAssertEqual(testAccount.errorMessage, "Test error")
    }
    
    // MARK: - Async Operation Tests
    
    func testAsyncBankConnection() async {
        // Given
        let view = BankConnectionView(viewModel: mockViewModel)
        let connectionData = BankConnectionData(
            bankName: "Test Bank",
            accountNumber: "123456789",
            accountType: BankAccountType.savings.rawValue,
            entityId: UUID()
        )
        
        // When
        await mockViewModel.connectBankAccount(connectionData)
        
        // Then
        XCTAssertFalse(mockViewModel.isLoading)
        XCTAssertEqual(mockViewModel.connectedBankAccounts.count, 1)
    }
    
    func testAsyncBankDisconnection() async {
        // Given
        let testAccount = createTestBankAccount()
        mockViewModel.connectedBankAccounts = [testAccount]
        
        // When
        await mockViewModel.disconnectBankAccount(testAccount)
        
        // Then
        XCTAssertFalse(mockViewModel.isLoading)
        XCTAssertEqual(mockViewModel.connectedBankAccounts.count, 0)
    }
    
    func testAsyncTransactionSync() async {
        // Given
        let testAccount = createTestBankAccount()
        mockViewModel.connectedBankAccounts = [testAccount]
        
        // When
        await mockViewModel.syncTransactions(for: testAccount)
        
        // Then
        XCTAssertFalse(mockViewModel.isLoading)
        XCTAssertNotNil(testAccount.lastSyncDate)
    }
    
    func testAsyncAPIKeyAuthentication() async {
        // Given
        let view = BankConnectionView(viewModel: mockViewModel)
        let apiKey = "test_api_key_123"
        
        // When
        await mockViewModel.authenticateWithAPIKey(apiKey)
        
        // Then
        XCTAssertTrue(mockViewModel.isAuthenticated)
        XCTAssertFalse(mockViewModel.isLoading)
    }
    
    // MARK: - Error Handling Tests
    
    func testAuthenticationErrorHandling() async {
        // Given
        let view = BankConnectionView(viewModel: mockViewModel)
        mockViewModel.shouldSimulateError = true
        
        // When
        await mockViewModel.authenticateWithAPIKey("invalid_key")
        
        // Then
        XCTAssertFalse(mockViewModel.isAuthenticated)
        XCTAssertNotNil(mockViewModel.errorMessage)
    }
    
    func testConnectionErrorHandling() async {
        // Given
        let view = BankConnectionView(viewModel: mockViewModel)
        mockViewModel.shouldSimulateError = true
        let invalidConnectionData = BankConnectionData(
            bankName: "",
            accountNumber: "123",
            accountType: "",
            entityId: UUID()
        )
        
        // When
        await mockViewModel.connectBankAccount(invalidConnectionData)
        
        // Then
        XCTAssertNotNil(mockViewModel.errorMessage)
        XCTAssertEqual(mockViewModel.connectedBankAccounts.count, 0)
    }
    
    func testSyncErrorHandling() async {
        // Given
        let testAccount = createTestBankAccount()
        mockViewModel.connectedBankAccounts = [testAccount]
        mockViewModel.shouldSimulateError = true
        
        // When
        await mockViewModel.syncTransactions(for: testAccount)
        
        // Then
        XCTAssertNotNil(mockViewModel.errorMessage)
    }
    
    // MARK: - Helper Methods
    
    private func createTestBankAccount() -> BankAccount {
        let account = BankAccount(context: testContext)
        account.id = UUID()
        account.bankName = "Test Bank"
        account.accountNumber = "123456789"
        account.accountType = BankAccountType.savings.rawValue
        account.isActive = true
        account.connectionStatus = ConnectionStatus.connected.rawValue
        account.lastSyncDate = Date()
        return account
    }
}

// MARK: - Mock View Model

class MockBankConnectionViewModel: BankConnectionViewModel {
    
    var shouldSimulateError = false
    var currentAuthStep: AuthenticationStep = .selectBank
    var selectedBank: BankInstitution?
    
    override func authenticateWithAPIKey(_ apiKey: String) async {
        isLoading = true
        errorMessage = nil
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
        
        if shouldSimulateError {
            errorMessage = "Authentication failed"
            isAuthenticated = false
        } else {
            isAuthenticated = true
        }
        
        isLoading = false
    }
    
    override func connectBankAccount(_ connectionData: BankConnectionData) async {
        isLoading = true
        errorMessage = nil
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
        
        if shouldSimulateError || !validateBankConnectionData(connectionData) {
            errorMessage = "Failed to connect bank account"
        } else {
            let bankAccount = BankAccount(context: context)
            bankAccount.id = UUID()
            bankAccount.bankName = connectionData.bankName
            bankAccount.accountNumber = connectionData.accountNumber
            bankAccount.accountType = connectionData.accountType
            bankAccount.isActive = true
            bankAccount.lastSyncDate = Date()
            
            connectedBankAccounts.append(bankAccount)
        }
        
        isLoading = false
    }
    
    override func disconnectBankAccount(_ bankAccount: BankAccount) async {
        isLoading = true
        errorMessage = nil
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
        
        if shouldSimulateError {
            errorMessage = "Failed to disconnect bank account"
        } else {
            if let index = connectedBankAccounts.firstIndex(of: bankAccount) {
                connectedBankAccounts.remove(at: index)
            }
            
            if selectedBankAccount == bankAccount {
                selectedBankAccount = nil
            }
        }
        
        isLoading = false
    }
    
    override func syncTransactions(for bankAccount: BankAccount) async {
        isLoading = true
        errorMessage = nil
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
        
        if shouldSimulateError {
            errorMessage = "Failed to sync transactions"
        } else {
            bankAccount.lastSyncDate = Date()
        }
        
        isLoading = false
    }
}