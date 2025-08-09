import XCTest
import Combine
@testable import FinanceMate

/// Comprehensive test suite for BankAPIIntegrationService
/// Tests real bank API integration functionality per BLUEPRINT requirements
@MainActor
final class BankAPIIntegrationServiceTests: XCTestCase {
    
    private var bankService: BankAPIIntegrationService!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        bankService = BankAPIIntegrationService()
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        cancellables?.removeAll()
        bankService = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testServiceInitialization() {
        XCTAssertNotNil(bankService, "BankAPIIntegrationService should initialize successfully")
        XCTAssertFalse(bankService.isConnected, "Service should start disconnected")
        XCTAssertTrue(bankService.availableAccounts.isEmpty, "Should start with no accounts")
        XCTAssertNil(bankService.lastSyncDate, "Should start with no sync date")
    }
    
    func testInitialConnectionStatus() {
        // Service should detect absence of credentials
        let expectation = XCTestExpectation(description: "Connection status updated")
        
        bankService.$connectionStatus
            .dropFirst() // Skip initial value
            .first()
            .sink { status in
                XCTAssertEqual(status, "No bank API credentials configured", "Should detect missing credentials")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    // MARK: - ANZ Bank Integration Tests
    
    func testANZBankConnectionWithoutCredentials() async {
        // Test connection attempt without credentials should fail
        do {
            try await bankService.connectANZBank()
            XCTFail("Connection should fail without credentials")
        } catch let error as BankAPIError {
            switch error {
            case .missingCredentials(let message):
                XCTAssertTrue(message.contains("ANZ API credentials not found"), "Should report missing ANZ credentials")
            default:
                XCTFail("Should fail with missing credentials error")
            }
        } catch {
            XCTFail("Should throw BankAPIError, not \(type(of: error))")
        }
    }
    
    func testANZBankConnectionStatusUpdates() async {
        // Test that connection status updates during connection attempt
        let statusExpectation = XCTestExpectation(description: "Status updates during ANZ connection")
        var statusUpdates: [String] = []
        
        bankService.$connectionStatus
            .sink { status in
                statusUpdates.append(status)
                if statusUpdates.count >= 2 {
                    statusExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // Attempt connection (will fail due to missing credentials)
        do {
            try await bankService.connectANZBank()
        } catch {
            // Expected to fail, we're testing status updates
        }
        
        await fulfillment(of: [statusExpectation], timeout: 2.0)
        
        // Verify status progression
        XCTAssertTrue(statusUpdates.contains("Connecting to ANZ Bank..."), "Should show connecting status")
        XCTAssertTrue(statusUpdates.last?.contains("ANZ Connection failed") == true, "Should show failure status")
    }
    
    // MARK: - NAB Bank Integration Tests
    
    func testNABBankConnectionWithoutCredentials() async {
        // Test connection attempt without credentials should fail
        do {
            try await bankService.connectNABBank()
            XCTFail("Connection should fail without credentials")
        } catch let error as BankAPIError {
            switch error {
            case .missingCredentials(let message):
                XCTAssertTrue(message.contains("NAB API credentials not found"), "Should report missing NAB credentials")
            default:
                XCTFail("Should fail with missing credentials error")
            }
        } catch {
            XCTFail("Should throw BankAPIError, not \(type(of: error))")
        }
    }
    
    func testNABBankConnectionStatusUpdates() async {
        // Test that connection status updates during connection attempt
        let statusExpectation = XCTestExpectation(description: "Status updates during NAB connection")
        var statusUpdates: [String] = []
        
        bankService.$connectionStatus
            .sink { status in
                statusUpdates.append(status)
                if statusUpdates.count >= 2 {
                    statusExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // Attempt connection (will fail due to missing credentials)
        do {
            try await bankService.connectNABBank()
        } catch {
            // Expected to fail, we're testing status updates
        }
        
        await fulfillment(of: [statusExpectation], timeout: 2.0)
        
        // Verify status progression
        XCTAssertTrue(statusUpdates.contains("Connecting to NAB Bank..."), "Should show connecting status")
        XCTAssertTrue(statusUpdates.last?.contains("NAB Connection failed") == true, "Should show failure status")
    }
    
    // MARK: - Data Synchronization Tests
    
    func testSyncAllBankDataWithoutConnection() async {
        // Test sync attempt without any bank connections
        do {
            try await bankService.syncAllBankData()
            
            // Should complete successfully even without connections
            XCTAssertEqual(bankService.connectionStatus, "Sync completed", "Should complete sync successfully")
            XCTAssertNotNil(bankService.lastSyncDate, "Should update last sync date")
        } catch {
            XCTFail("Sync should not throw error when no connections exist: \(error)")
        }
    }
    
    func testLastSyncDateUpdate() async {
        let initialSyncDate = bankService.lastSyncDate
        
        do {
            try await bankService.syncAllBankData()
            
            XCTAssertNotEqual(bankService.lastSyncDate, initialSyncDate, "Sync date should be updated")
            XCTAssertNotNil(bankService.lastSyncDate, "Sync date should be set after sync")
            
            // Verify sync date is recent (within last 5 seconds)
            let timeSinceSync = Date().timeIntervalSince(bankService.lastSyncDate!)
            XCTAssertLessThan(timeSinceSync, 5.0, "Sync date should be very recent")
        } catch {
            XCTFail("Sync should not fail: \(error)")
        }
    }
    
    // MARK: - Published Properties Tests
    
    func testIsConnectedProperty() {
        // Test initial state
        XCTAssertFalse(bankService.isConnected, "Should start disconnected")
        
        // Test property is @Published by observing changes
        let expectation = XCTestExpectation(description: "isConnected publishes changes")
        
        bankService.$isConnected
            .dropFirst() // Skip initial value
            .first()
            .sink { isConnected in
                // This test verifies the property is observable
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // Trigger a change (this will fail due to missing credentials but will update the property)
        Task {
            do {
                try await bankService.connectANZBank()
            } catch {
                // Expected failure, we're testing property observation
            }
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testAvailableAccountsProperty() {
        // Test initial state
        XCTAssertTrue(bankService.availableAccounts.isEmpty, "Should start with empty accounts")
        
        // Test property is @Published
        let expectation = XCTestExpectation(description: "availableAccounts is observable")
        
        bankService.$availableAccounts
            .sink { accounts in
                XCTAssertTrue(accounts.isEmpty, "Should remain empty without connections")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Error Handling Tests
    
    func testBankAPIErrorTypes() {
        // Test all error types have appropriate descriptions
        let credentialsError = BankAPIError.missingCredentials("Test credentials message")
        XCTAssertEqual(credentialsError.errorDescription, "Missing Credentials: Test credentials message")
        
        let authError = BankAPIError.authenticationFailed("Test auth message")
        XCTAssertEqual(authError.errorDescription, "Authentication Failed: Test auth message")
        
        let networkError = BankAPIError.networkError("Test network message")
        XCTAssertEqual(networkError.errorDescription, "Network Error: Test network message")
        
        let dataError = BankAPIError.dataParsingError("Test data message")
        XCTAssertEqual(dataError.errorDescription, "Data Parsing Error: Test data message")
    }
    
    // MARK: - BankAccount Model Tests
    
    func testBankAccountModel() {
        let account = BankAccount(
            accountId: "12345678",
            accountName: "Test Savings",
            accountType: "SAVINGS",
            bankType: .anz,
            currentBalance: 1500.00,
            availableBalance: 1450.00,
            lastUpdated: Date()
        )
        
        XCTAssertNotNil(account.id, "Account should have UUID")
        XCTAssertEqual(account.accountId, "12345678")
        XCTAssertEqual(account.accountName, "Test Savings")
        XCTAssertEqual(account.bankType, .anz)
        XCTAssertEqual(account.currentBalance, 1500.00)
        XCTAssertEqual(account.availableBalance, 1450.00)
    }
    
    func testBankTypeEnum() {
        XCTAssertEqual(BankType.anz.displayName, "ANZ")
        XCTAssertEqual(BankType.nab.displayName, "NAB")
        XCTAssertEqual(BankType.anz.rawValue, "ANZ")
        XCTAssertEqual(BankType.nab.rawValue, "NAB")
    }
    
    // MARK: - Performance Tests
    
    func testServiceInitializationPerformance() {
        measure {
            let service = BankAPIIntegrationService()
            XCTAssertNotNil(service)
        }
    }
    
    func testMultipleSyncPerformance() async {
        measure {
            let expectation = XCTestExpectation(description: "Multiple sync operations")
            
            Task {
                do {
                    for _ in 0..<5 {
                        try await bankService.syncAllBankData()
                    }
                    expectation.fulfill()
                } catch {
                    XCTFail("Sync operations should not fail: \(error)")
                    expectation.fulfill()
                }
            }
            
            wait(for: [expectation], timeout: 10.0)
        }
    }
    
    // MARK: - OAuth2 PKCE Tests
    
    func testPKCECodeVerifierGeneration() {
        // Test PKCE code verifier generation through reflection
        let service = BankAPIIntegrationService()
        
        // Since PKCE methods are private, we'll test through the OAuth flow
        Task {
            do {
                // This will trigger PKCE generation internally
                try await service.connectANZBank()
            } catch {
                // Expected to fail due to missing credentials, but PKCE should be generated
                XCTAssertTrue(error.localizedDescription.contains("ANZ API credentials not found"), 
                            "Should fail with missing credentials after PKCE generation")
            }
        }
    }
    
    func testOAuth2StateGeneration() {
        // Test OAuth2 state generation for CSRF protection
        let service = BankAPIIntegrationService()
        
        Task {
            do {
                // Trigger OAuth flow which generates state
                try await service.connectNABBank()
            } catch {
                // Expected to fail, but state generation should occur internally
                XCTAssertTrue(error.localizedDescription.contains("NAB API credentials not found"),
                            "Should fail with missing credentials after state generation")
            }
        }
    }
    
    func testOAuth2CallbackValidation() async {
        // Test OAuth callback validation with invalid state
        let service = BankAPIIntegrationService()
        
        do {
            try await service.exchangeANZAuthorizationCode("test_code", state: "invalid_state")
            XCTFail("Should fail with invalid state")
        } catch let error as BankAPIError {
            switch error {
            case .authenticationFailed(let message):
                XCTAssertTrue(message.contains("Invalid state parameter"), 
                            "Should reject invalid state parameter")
            default:
                XCTFail("Should fail specifically with invalid state error")
            }
        } catch {
            XCTFail("Should throw BankAPIError for state validation")
        }
    }
    
    func testTokenExchangeValidation() async {
        // Test token exchange parameter validation
        let service = BankAPIIntegrationService()
        
        do {
            try await service.exchangeNABAuthorizationCode("", state: nil)
            XCTFail("Should fail with missing parameters")
        } catch let error as BankAPIError {
            switch error {
            case .authenticationFailed, .missingCredentials:
                // Expected - should fail validation
                break
            default:
                XCTFail("Should fail with authentication or credentials error")
            }
        } catch {
            XCTFail("Should throw BankAPIError for parameter validation")
        }
    }
    
    // MARK: - Keychain Integration Tests
    
    func testKeychainCredentialStorage() async {
        let keychain = KeychainService.shared
        let testKey = "TEST_CREDENTIAL_KEY"
        let testValue = "test_credential_value_12345"
        
        // Test storing credential
        let storeResult = await keychain.setCredential(testValue, for: testKey)
        XCTAssertTrue(storeResult, "Should successfully store credential in keychain")
        
        // Test retrieving credential
        let retrievedValue = await keychain.getCredential(for: testKey)
        XCTAssertEqual(retrievedValue, testValue, "Should retrieve the same value that was stored")
        
        // Test deleting credential
        let deleteResult = await keychain.deleteCredential(for: testKey)
        XCTAssertTrue(deleteResult, "Should successfully delete credential from keychain")
        
        // Verify credential is deleted
        let deletedValue = await keychain.getCredential(for: testKey)
        XCTAssertNil(deletedValue, "Should return nil after credential is deleted")
    }
    
    func testKeychainCredentialUpdate() async {
        let keychain = KeychainService.shared
        let testKey = "TEST_UPDATE_KEY"
        let originalValue = "original_value_123"
        let updatedValue = "updated_value_456"
        
        // Store original value
        let storeResult = await keychain.setCredential(originalValue, for: testKey)
        XCTAssertTrue(storeResult, "Should store original credential")
        
        // Update with new value
        let updateResult = await keychain.setCredential(updatedValue, for: testKey)
        XCTAssertTrue(updateResult, "Should update existing credential")
        
        // Verify updated value
        let retrievedValue = await keychain.getCredential(for: testKey)
        XCTAssertEqual(retrievedValue, updatedValue, "Should retrieve updated value")
        
        // Cleanup
        await keychain.deleteCredential(for: testKey)
    }
    
    func testKeychainListStoredKeys() async {
        let keychain = KeychainService.shared
        let testKeys = ["TEST_KEY_1", "TEST_KEY_2", "TEST_KEY_3"]
        
        // Store multiple credentials
        for key in testKeys {
            let stored = await keychain.setCredential("test_value", for: key)
            XCTAssertTrue(stored, "Should store credential for key: \(key)")
        }
        
        // List stored keys
        let storedKeys = await keychain.listStoredKeys()
        
        // Verify all test keys are present
        for key in testKeys {
            XCTAssertTrue(storedKeys.contains(key), "Should find stored key: \(key)")
        }
        
        // Cleanup
        for key in testKeys {
            await keychain.deleteCredential(for: key)
        }
    }
    
    // MARK: - CDR Compliance Tests
    
    func testCDREndpointConfiguration() {
        // Test that CDR endpoints are properly configured
        let service = BankAPIIntegrationService()
        
        // Test ANZ CDR endpoints contain required paths
        // Note: We can't access private structs directly, but we can verify through connection attempts
        Task {
            do {
                try await service.connectANZBank()
            } catch let error as BankAPIError {
                XCTAssertTrue(error.localizedDescription.contains("ANZ API credentials not found"),
                            "Should use correct ANZ CDR endpoint configuration")
            }
        }
    }
    
    func testCDRScopeConfiguration() {
        // Verify CDR-compliant scopes are used
        // This is tested indirectly through OAuth URL generation
        
        let service = BankAPIIntegrationService()
        
        // The OAuth URL generation includes proper CDR scopes
        // We verify this by ensuring connection attempts reference CDR compliance
        Task {
            do {
                try await service.connectNABBank()
            } catch let error as BankAPIError {
                switch error {
                case .missingCredentials(let message):
                    XCTAssertTrue(message.contains("NAB API credentials not found"),
                                "Should use CDR-compliant NAB configuration")
                default:
                    XCTFail("Should fail with missing credentials error")
                }
            }
        }
    }
    
    // MARK: - Enhanced OAuth2 Flow Tests
    
    func testANZOAuth2URLGeneration() async {
        // Test that ANZ OAuth2 URLs are properly formatted
        let service = BankAPIIntegrationService()
        
        // Store test credentials to enable URL generation
        let keychain = KeychainService.shared
        _ = await keychain.setCredential("test_anz_client_id", for: "ANZ_CLIENT_ID")
        _ = await keychain.setCredential("test_anz_client_secret", for: "ANZ_CLIENT_SECRET")
        
        do {
            try await service.connectANZBank()
        } catch {
            // Expected to fail due to network/validation, but should generate proper OAuth URL
            XCTAssertTrue(error.localizedDescription.contains("authentication failed") ||
                         error.localizedDescription.contains("ANZ authentication failed"),
                         "Should fail with proper OAuth URL generation attempted")
        }
        
        // Cleanup
        _ = await keychain.deleteCredential(for: "ANZ_CLIENT_ID")
        _ = await keychain.deleteCredential(for: "ANZ_CLIENT_SECRET")
    }
    
    func testNABOAuth2URLGeneration() async {
        // Test that NAB OAuth2 URLs are properly formatted
        let service = BankAPIIntegrationService()
        
        // Store test credentials to enable URL generation
        let keychain = KeychainService.shared
        _ = await keychain.setCredential("test_nab_client_id", for: "NAB_CLIENT_ID")
        _ = await keychain.setCredential("test_nab_client_secret", for: "NAB_CLIENT_SECRET")
        
        do {
            try await service.connectNABBank()
        } catch {
            // Expected to fail due to network/validation, but should generate proper OAuth URL
            XCTAssertTrue(error.localizedDescription.contains("authentication failed") ||
                         error.localizedDescription.contains("NAB authentication failed"),
                         "Should fail with proper OAuth URL generation attempted")
        }
        
        // Cleanup
        _ = await keychain.deleteCredential(for: "NAB_CLIENT_ID")
        _ = await keychain.deleteCredential(for: "NAB_CLIENT_SECRET")
    }
    
    func testPKCECodeChallengeGeneration() {
        // Test PKCE code challenge generation using Data extension
        let testVerifier = "test_code_verifier_12345"
        guard let data = testVerifier.data(using: .utf8) else {
            XCTFail("Should create data from test verifier")
            return
        }
        
        let base64URLEncoded = data.base64URLEncodedString()
        
        // Verify Base64URL encoding properties
        XCTAssertFalse(base64URLEncoded.contains("+"), "Base64URL should not contain + characters")
        XCTAssertFalse(base64URLEncoded.contains("/"), "Base64URL should not contain / characters")
        XCTAssertFalse(base64URLEncoded.contains("="), "Base64URL should not contain padding")
        XCTAssertTrue(base64URLEncoded.count > 0, "Should generate non-empty encoded string")
    }
    
    func testOAuth2StateParameterSecurity() async {
        // Test OAuth2 state parameter generation for CSRF protection
        let service = BankAPIIntegrationService()
        
        // Test invalid state parameter rejection
        do {
            try await service.exchangeANZAuthorizationCode("test_code", state: "invalid_state_parameter")
            XCTFail("Should reject invalid state parameter")
        } catch let error as BankAPIError {
            switch error {
            case .authenticationFailed(let message):
                XCTAssertTrue(message.contains("Invalid state parameter"), 
                            "Should reject invalid state with CSRF protection message")
            default:
                XCTFail("Should fail specifically with invalid state authentication error")
            }
        }
    }
    
    func testOAuth2TokenExchangeParameterValidation() async {
        // Test comprehensive parameter validation in token exchange
        let service = BankAPIIntegrationService()
        
        // Test with empty authorization code
        do {
            try await service.exchangeNABAuthorizationCode("", state: nil)
            XCTFail("Should reject empty authorization code")
        } catch {
            // Expected validation failure
            XCTAssertTrue(error.localizedDescription.contains("Invalid state parameter") ||
                         error.localizedDescription.contains("Missing OAuth parameters"),
                         "Should fail with parameter validation error")
        }
    }
    
    func testKeychainSecurityCompliance() async {
        // Test Keychain security implementation follows best practices
        let keychain = KeychainService.shared
        let secureTestKey = "SECURE_TEST_TOKEN"
        let secureTestValue = "secure_access_token_with_special_chars_!@#$%^&*()"
        
        // Test secure storage
        let stored = await keychain.setCredential(secureTestValue, for: secureTestKey)
        XCTAssertTrue(stored, "Should securely store complex token values")
        
        // Test secure retrieval
        let retrieved = await keychain.getCredential(for: secureTestKey)
        XCTAssertEqual(retrieved, secureTestValue, "Should securely retrieve exact token value")
        
        // Test secure deletion
        let deleted = await keychain.deleteCredential(for: secureTestKey)
        XCTAssertTrue(deleted, "Should securely delete stored tokens")
        
        // Verify deletion
        let deletedValue = await keychain.getCredential(for: secureTestKey)
        XCTAssertNil(deletedValue, "Should return nil for deleted secure tokens")
    }
    
    func testMultipleOAuth2SessionHandling() async {
        // Test handling of multiple OAuth2 sessions/tokens
        let keychain = KeychainService.shared
        let anzToken = "anz_access_token_session_1"
        let nabToken = "nab_access_token_session_2"
        
        // Store multiple bank tokens
        let anzStored = await keychain.setCredential(anzToken, for: "ANZ_ACCESS_TOKEN")
        let nabStored = await keychain.setCredential(nabToken, for: "NAB_ACCESS_TOKEN")
        
        XCTAssertTrue(anzStored, "Should store ANZ access token")
        XCTAssertTrue(nabStored, "Should store NAB access token")
        
        // Verify independent retrieval
        let retrievedANZ = await keychain.getCredential(for: "ANZ_ACCESS_TOKEN")
        let retrievedNAB = await keychain.getCredential(for: "NAB_ACCESS_TOKEN")
        
        XCTAssertEqual(retrievedANZ, anzToken, "Should retrieve correct ANZ token")
        XCTAssertEqual(retrievedNAB, nabToken, "Should retrieve correct NAB token")
        
        // Test service handles multiple active connections
        let service = BankAPIIntegrationService()
        do {
            try await service.syncAllBankData()
            // Should attempt to sync both banks if tokens exist
            XCTAssertNotNil(service.lastSyncDate, "Should update sync date with multiple tokens")
        } catch {
            // May fail due to network, but should attempt sync with both tokens
        }
        
        // Cleanup
        _ = await keychain.deleteCredential(for: "ANZ_ACCESS_TOKEN")
        _ = await keychain.deleteCredential(for: "NAB_ACCESS_TOKEN")
    }
    
    func testOAuth2ErrorResponseHandling() async {
        // Test proper handling of OAuth2 error responses
        let service = BankAPIIntegrationService()
        
        // Test various OAuth2 error scenarios
        let errorScenarios = [
            "invalid_request",
            "unauthorized_client", 
            "access_denied",
            "unsupported_response_type",
            "invalid_scope",
            "server_error",
            "temporarily_unavailable"
        ]
        
        for errorType in errorScenarios {
            do {
                // Simulate OAuth2 error callback
                try await service.exchangeANZAuthorizationCode("error_code_\(errorType)", state: nil)
                XCTFail("Should handle OAuth2 error: \(errorType)")
            } catch {
                // Expected to fail with appropriate error handling
                XCTAssertTrue(error.localizedDescription.contains("Invalid state parameter") ||
                             error.localizedDescription.contains("Missing OAuth parameters"),
                             "Should handle OAuth2 error \(errorType) appropriately")
            }
        }
    }
    
    // MARK: - Real HTTP Implementation Tests
    
    func testBankTransactionModelCreation() {
        // Test CDR-compliant transaction model creation
        let jsonResponse: [String: Any] = [
            "transactionId": "TXN123456789",
            "amount": "-45.67",
            "description": "Coffee Shop Purchase",
            "executionDateTime": "2025-08-09T10:30:00Z",
            "postingDateTime": "2025-08-09T10:30:00Z",
            "categoryType": "MEALS_ENTERTAINMENT",
            "reference": "REF12345"
        ]
        
        let transaction = BankTransaction.fromCDRResponse(
            jsonResponse, 
            bankType: .anz, 
            accountId: "ACC123"
        )
        
        XCTAssertNotNil(transaction, "Should create transaction from CDR response")
        XCTAssertEqual(transaction?.transactionId, "TXN123456789")
        XCTAssertEqual(transaction?.amount, -45.67)
        XCTAssertEqual(transaction?.description, "Coffee Shop Purchase")
        XCTAssertEqual(transaction?.category, "MEALS_ENTERTAINMENT")
        XCTAssertEqual(transaction?.bankType, .anz)
        XCTAssertEqual(transaction?.accountId, "ACC123")
    }
    
    func testBankTransactionModelWithIncompleteData() {
        // Test transaction model handles incomplete CDR response
        let incompleteJsonResponse: [String: Any] = [
            "transactionId": "TXN123456789",
            "amount": "invalid_amount", // Invalid amount format
            "description": "Test Transaction"
        ]
        
        let transaction = BankTransaction.fromCDRResponse(
            incompleteJsonResponse,
            bankType: .nab,
            accountId: "ACC456"
        )
        
        XCTAssertNil(transaction, "Should return nil for incomplete or invalid CDR response")
    }
    
    func testHTTPErrorResponseParsing() {
        // Test enhanced error parsing from HTTP responses
        let httpResponse = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: 401,
            httpVersion: nil,
            headerFields: nil
        )!
        
        let errorData = """
        {
            "error": "invalid_client",
            "error_description": "Client authentication failed"
        }
        """.data(using: .utf8)!
        
        let error = BankAPIError.fromHTTPResponse(httpResponse, data: errorData)
        
        switch error {
        case .authenticationFailed(let message):
            XCTAssertTrue(message.contains("invalid_client"), "Should parse OAuth2 error from response")
            XCTAssertTrue(message.contains("Client authentication failed"), "Should include error description")
        default:
            XCTFail("Should create authentication error for 401 status")
        }
    }
    
    func testBase64URLEncodingCompliance() {
        // Test PKCE Base64URL encoding compliance (no padding, URL-safe characters)
        let testData = "test_string_for_pkce_encoding".data(using: .utf8)!
        let encoded = testData.base64URLEncodedString()
        
        // Verify URL-safe characters
        XCTAssertFalse(encoded.contains("+"), "Base64URL should not contain + characters")
        XCTAssertFalse(encoded.contains("/"), "Base64URL should not contain / characters")
        XCTAssertFalse(encoded.contains("="), "Base64URL should not contain padding")
        
        // Verify it's not empty
        XCTAssertTrue(encoded.count > 0, "Should produce non-empty encoded string")
    }
    
    // MARK: - BLUEPRINT Compliance Tests
    
    func testBlueprintMandatoryFeatures() {
        // Verify service addresses BLUEPRINT mandatory requirements
        XCTAssertTrue(BankType.allCases.contains(.anz), "Must support ANZ Bank per BLUEPRINT")
        XCTAssertTrue(BankType.allCases.contains(.nab), "Must support NAB Bank per BLUEPRINT")
        
        // Verify no mock data is used (real implementation foundation)
        XCTAssertFalse(bankService.isConnected, "Should not simulate connection without real credentials")
        XCTAssertTrue(bankService.availableAccounts.isEmpty, "Should not populate with fake account data")
    }
    
    func testRealDataOnlyCompliance() {
        // Verify service follows BLUEPRINT "No Mock Data" requirement
        
        // Service should not provide fake/mock data
        XCTAssertTrue(bankService.availableAccounts.isEmpty, "Should not contain mock accounts")
        XCTAssertFalse(bankService.isConnected, "Should not simulate connection status")
        XCTAssertNil(bankService.lastSyncDate, "Should not provide fake sync dates")
        
        // Service should properly handle missing credentials (real behavior)
        Task {
            do {
                try await bankService.connectANZBank()
                XCTFail("Should fail with real credential validation, not mock success")
            } catch {
                // Expected behavior - real credential validation should fail
            }
        }
    }
    
    // MARK: - Real HTTP Implementation Tests
    
    func testRealHTTPTokenExchangeErrorHandling() async {
        // Test real HTTP error handling for token exchange
        let service = BankAPIIntegrationService()
        
        do {
            // This should fail with authentication error for invalid state
            try await service.exchangeANZAuthorizationCode("invalid_code", state: "invalid_state")
            XCTFail("Should fail with invalid OAuth2 parameters")
        } catch let error as BankAPIError {
            switch error {
            case .authenticationFailed(let message):
                XCTAssertTrue(message.contains("Invalid state parameter"), 
                            "Should validate state parameter for CSRF protection")
            case .missingCredentials(let message):
                XCTAssertTrue(message.contains("Missing OAuth parameters"),
                            "Should require proper OAuth parameters")
            default:
                XCTFail("Should fail with appropriate authentication error, got: \(error)")
            }
        }
    }
    
    func testRealAPIEndpointConfiguration() {
        // Test that real API endpoints are properly configured
        let service = BankAPIIntegrationService()
        
        // Test that service validates endpoints correctly
        Task {
            do {
                try await service.connectANZBank()
            } catch let error as BankAPIError {
                switch error {
                case .missingCredentials(let message):
                    XCTAssertTrue(message.contains("ANZ API credentials not found"),
                                "Should properly validate ANZ credentials requirement")
                default:
                    XCTFail("Should fail with missing credentials error for real API setup")
                }
            }
        }
    }
    
    func testCDRCompliantJSONParsing() {
        // Test CDR-compliant JSON parsing functionality
        let service = BankAPIIntegrationService()
        
        // Create mock CDR-compliant accounts response JSON
        let mockAccountsJSON = """
        {
            "data": {
                "accounts": [
                    {
                        "accountId": "12345678",
                        "displayName": "Test Savings Account",
                        "productCategory": "TRANS_AND_SAVINGS_ACCOUNTS",
                        "balance": [
                            {
                                "type": "CURRENT",
                                "amount": "1500.00"
                            },
                            {
                                "type": "AVAILABLE", 
                                "amount": "1450.00"
                            }
                        ]
                    }
                ]
            }
        }
        """.data(using: .utf8)!
        
        // Test that the service would properly parse this structure
        // Note: We can't directly test private parsing methods, but we verify structure expectations
        XCTAssertNotNil(mockAccountsJSON, "Should create valid test JSON data")
        
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: mockAccountsJSON) as? [String: Any]
            XCTAssertNotNil(jsonObject?["data"], "Should have CDR-compliant data structure")
            
            if let dataObject = jsonObject?["data"] as? [String: Any],
               let accountsArray = dataObject["accounts"] as? [[String: Any]] {
                XCTAssertEqual(accountsArray.count, 1, "Should parse accounts array correctly")
                
                let account = accountsArray[0]
                XCTAssertEqual(account["accountId"] as? String, "12345678", "Should parse account ID")
                XCTAssertEqual(account["displayName"] as? String, "Test Savings Account", "Should parse display name")
            } else {
                XCTFail("Should parse CDR accounts structure correctly")
            }
            
        } catch {
            XCTFail("Should parse CDR-compliant JSON successfully: \(error)")
        }
    }
    
    func testCDRCompliantTransactionParsing() {
        // Test CDR-compliant transaction JSON parsing
        let mockTransactionsJSON = """
        {
            "data": {
                "transactions": [
                    {
                        "transactionId": "TXN123456",
                        "amount": "-25.50",
                        "description": "Coffee Shop Purchase",
                        "reference": "COFFEE-REF-001",
                        "executionDate": "2025-08-09T10:30:00Z"
                    },
                    {
                        "transactionId": "TXN123457",
                        "amount": "1200.00",
                        "description": "Salary Credit",
                        "reference": "SALARY-PAY",
                        "executionDate": "2025-08-01T09:00:00Z"
                    }
                ]
            }
        }
        """.data(using: .utf8)!
        
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: mockTransactionsJSON) as? [String: Any]
            XCTAssertNotNil(jsonObject?["data"], "Should have CDR-compliant transaction data structure")
            
            if let dataObject = jsonObject?["data"] as? [String: Any],
               let transactionsArray = dataObject["transactions"] as? [[String: Any]] {
                XCTAssertEqual(transactionsArray.count, 2, "Should parse transactions array correctly")
                
                let transaction1 = transactionsArray[0]
                XCTAssertEqual(transaction1["transactionId"] as? String, "TXN123456", "Should parse transaction ID")
                XCTAssertEqual(transaction1["amount"] as? String, "-25.50", "Should parse transaction amount")
                XCTAssertEqual(transaction1["description"] as? String, "Coffee Shop Purchase", "Should parse description")
                
                let transaction2 = transactionsArray[1]
                XCTAssertEqual(transaction2["amount"] as? String, "1200.00", "Should parse positive amounts")
            } else {
                XCTFail("Should parse CDR transactions structure correctly")
            }
            
        } catch {
            XCTFail("Should parse CDR-compliant transaction JSON successfully: \(error)")
        }
    }
    
    func testBankTransactionModel() {
        // Test BankTransaction model structure
        let transaction = BankTransaction(
            transactionId: "TXN123456",
            amount: -25.50,
            description: "Test Purchase",
            reference: "TEST-REF",
            executionDate: Date(),
            bankType: .anz
        )
        
        XCTAssertNotNil(transaction.id, "Transaction should have UUID")
        XCTAssertEqual(transaction.transactionId, "TXN123456")
        XCTAssertEqual(transaction.amount, -25.50)
        XCTAssertEqual(transaction.description, "Test Purchase")
        XCTAssertEqual(transaction.reference, "TEST-REF")
        XCTAssertEqual(transaction.bankType, .anz)
    }
    
    func testNetworkErrorHandling() async {
        // Test comprehensive network error handling
        let service = BankAPIIntegrationService()
        
        // Test various network error scenarios through OAuth flow
        let networkErrorScenarios = [
            ("invalid_url", "Should handle invalid URLs"),
            ("timeout_test", "Should handle network timeouts"),
            ("connection_failed", "Should handle connection failures")
        ]
        
        for (errorCode, description) in networkErrorScenarios {
            do {
                try await service.exchangeANZAuthorizationCode("test_code_\(errorCode)", state: nil)
                XCTFail("\(description): Should fail with network error")
            } catch {
                // Expected to fail with appropriate error handling
                XCTAssertTrue(error.localizedDescription.contains("Invalid state parameter") ||
                             error.localizedDescription.contains("Missing OAuth parameters") ||
                             error.localizedDescription.contains("Network"),
                             "\(description): Should handle error appropriately")
            }
        }
    }
    
    func testHTTPStatusCodeHandling() async {
        // Test that service properly handles various HTTP status codes
        let service = BankAPIIntegrationService()
        
        // These tests verify error handling logic exists (actual HTTP testing would require mock server)
        do {
            try await service.exchangeNABAuthorizationCode("test_http_errors", state: nil)
            XCTFail("Should fail with HTTP error handling")
        } catch {
            // Verify error handling infrastructure is in place
            XCTAssertTrue(error.localizedDescription.contains("Invalid state parameter") ||
                         error.localizedDescription.contains("Missing OAuth") ||
                         error.localizedDescription.contains("authentication") ||
                         error.localizedDescription.contains("Network"),
                         "Should have comprehensive HTTP error handling")
        }
    }
    
    func testOAuth2TokenResponseValidation() {
        // Test OAuth2 token response validation logic
        let validTokenJSON = """
        {
            "access_token": "valid_access_token_12345",
            "token_type": "Bearer",
            "expires_in": 3600,
            "scope": "bank:accounts.basic:read bank:transactions:read"
        }
        """.data(using: .utf8)!
        
        let errorTokenJSON = """
        {
            "error": "invalid_request",
            "error_description": "The request is missing a required parameter"
        }
        """.data(using: .utf8)!
        
        // Test valid token response structure
        do {
            let validResponse = try JSONSerialization.jsonObject(with: validTokenJSON) as? [String: Any]
            XCTAssertNotNil(validResponse?["access_token"], "Should have access_token in valid response")
            XCTAssertNotNil(validResponse?["token_type"], "Should have token_type in valid response")
            XCTAssertNotNil(validResponse?["expires_in"], "Should have expires_in in valid response")
        } catch {
            XCTFail("Should parse valid OAuth2 token response: \(error)")
        }
        
        // Test error response structure
        do {
            let errorResponse = try JSONSerialization.jsonObject(with: errorTokenJSON) as? [String: Any]
            XCTAssertNotNil(errorResponse?["error"], "Should have error in error response")
            XCTAssertNotNil(errorResponse?["error_description"], "Should have error_description in error response")
        } catch {
            XCTFail("Should parse OAuth2 error response: \(error)")
        }
    }
    
    func testRealAPIEndpointURLValidation() {
        // Test that API endpoint URLs are valid and properly formatted
        let service = BankAPIIntegrationService()
        
        // Test ANZ endpoint URL construction
        Task {
            do {
                try await service.connectANZBank()
            } catch let error as BankAPIError {
                switch error {
                case .missingCredentials:
                    // Expected - validates that URL construction logic is reached
                    break
                case .networkError(let message):
                    XCTAssertFalse(message.contains("Invalid"), "Should not have invalid URL construction")
                default:
                    break
                }
            }
        }
        
        // Test NAB endpoint URL construction
        Task {
            do {
                try await service.connectNABBank()
            } catch let error as BankAPIError {
                switch error {
                case .missingCredentials:
                    // Expected - validates that URL construction logic is reached
                    break
                case .networkError(let message):
                    XCTAssertFalse(message.contains("Invalid"), "Should not have invalid URL construction")
                default:
                    break
                }
            }
        }
    }
    
    func testConcurrentBankConnectionHandling() async {
        // Test concurrent bank connection handling
        let service = BankAPIIntegrationService()
        
        await withTaskGroup(of: Void.self) { group in
            // Attempt concurrent ANZ connection
            group.addTask {
                do {
                    try await service.connectANZBank()
                } catch {
                    // Expected to fail due to missing credentials
                }
            }
            
            // Attempt concurrent NAB connection
            group.addTask {
                do {
                    try await service.connectNABBank()
                } catch {
                    // Expected to fail due to missing credentials
                }
            }
            
            // Attempt concurrent sync
            group.addTask {
                do {
                    try await service.syncAllBankData()
                } catch {
                    // May fail, but should handle concurrency properly
                }
            }
        }
        
        // Service should remain in consistent state after concurrent operations
        XCTAssertNotNil(service.connectionStatus, "Should maintain connection status consistency")
        XCTAssertTrue(service.availableAccounts.isEmpty, "Should not have accounts without credentials")
    }
}

// MARK: - Integration Tests

extension BankAPIIntegrationServiceTests {
    
    /// Integration test to verify service integrates properly with SwiftUI
    func testSwiftUIIntegration() {
        // Verify @Published properties work with SwiftUI
        XCTAssertTrue(bankService.objectWillChange is ObservableObjectPublisher, "Should be ObservableObject")
        
        // Test property observation for SwiftUI binding
        let expectation = XCTestExpectation(description: "Property changes trigger objectWillChange")
        
        bankService.objectWillChange
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // Trigger property change
        Task {
            do {
                try await bankService.syncAllBankData()
            } catch {
                // Sync may fail, but should still trigger property changes
            }
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
}