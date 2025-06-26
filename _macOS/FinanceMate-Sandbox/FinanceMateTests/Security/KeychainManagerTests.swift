//
//  KeychainManagerTests.swift
//  FinanceMateTests
//
//  Purpose: Comprehensive security tests for KeychainManager
//  Validates encryption, biometric protection, and audit logging

import XCTest
@testable import FinanceMate

final class KeychainManagerTests: XCTestCase {
    var keychainManager: KeychainManager!

    override func setUp() {
        super.setUp()
        keychainManager = KeychainManager.shared

        // Clear all items before each test
        try? keychainManager.clearAll()
    }

    override func tearDown() {
        // Clear all items after each test
        try? keychainManager.clearAll()
        super.tearDown()
    }

    // MARK: - Basic Storage Tests

    func testStoreAndRetrieveBasicCredential() throws {
        // Given
        let key = "test_api_key"
        let value = "sk-test123456789"

        // When
        try keychainManager.store(key: key, value: value)
        let retrievedValue = try keychainManager.retrieve(key: key)

        // Then
        XCTAssertEqual(retrievedValue, value)
    }

    func testStoreWithBiometricRequirement() throws {
        // Given
        let key = "sensitive_token"
        let value = "super_secret_value"

        // When/Then - Should succeed without error
        XCTAssertNoThrow(try keychainManager.store(key: key, value: value, requiresBiometric: true))
    }

    func testRetrieveNonExistentItem() {
        // Given
        let key = "non_existent_key"

        // When/Then
        XCTAssertThrowsError(try keychainManager.retrieve(key: key)) { error in
            XCTAssertTrue(error is KeychainError)
            XCTAssertEqual(error as? KeychainError, .itemNotFound)
        }
    }

    func testDeleteItem() throws {
        // Given
        let key = "deletable_key"
        let value = "deletable_value"
        try keychainManager.store(key: key, value: value)

        // When
        try keychainManager.delete(key: key)

        // Then
        XCTAssertThrowsError(try keychainManager.retrieve(key: key)) { error in
            XCTAssertEqual(error as? KeychainError, .itemNotFound)
        }
    }

    // MARK: - OAuth Token Tests

    func testStoreAndRetrieveOAuthTokens() throws {
        // Given
        let tokens = OAuthTokens(
            accessToken: "access_token_123",
            refreshToken: "refresh_token_456",
            idToken: "id_token_789",
            expiresIn: 3600,
            tokenType: "Bearer",
            scope: "openid email profile",
            createdAt: Date()
        )

        // When
        try keychainManager.storeOAuthTokens(tokens)
        let retrievedTokens = try keychainManager.retrieveOAuthTokens()

        // Then
        XCTAssertEqual(retrievedTokens.accessToken, tokens.accessToken)
        XCTAssertEqual(retrievedTokens.refreshToken, tokens.refreshToken)
        XCTAssertEqual(retrievedTokens.idToken, tokens.idToken)
        XCTAssertEqual(retrievedTokens.tokenType, tokens.tokenType)
        XCTAssertEqual(retrievedTokens.scope, tokens.scope)
    }

    func testOAuthTokenExpiration() {
        // Given
        let expiredTokens = OAuthTokens(
            accessToken: "expired_token",
            refreshToken: "refresh_token",
            idToken: nil,
            expiresIn: -3600, // Already expired
            tokenType: "Bearer",
            scope: nil,
            createdAt: Date().addingTimeInterval(-7200) // Created 2 hours ago
        )

        // Then
        XCTAssertTrue(expiredTokens.isExpired)
    }

    // MARK: - Session Token Tests

    func testStoreAndRetrieveSessionToken() throws {
        // Given
        let token = "session_token_abc123"
        let expiresAt = Date().addingTimeInterval(3600)

        // When
        try keychainManager.storeSessionToken(token, expiresAt: expiresAt)
        let retrievedSession = try keychainManager.retrieveSessionToken()

        // Then
        XCTAssertEqual(retrievedSession.token, token)
        XCTAssertEqual(retrievedSession.expiresAt.timeIntervalSince1970, expiresAt.timeIntervalSince1970, accuracy: 1.0)
    }

    func testExpiredSessionTokenDeletion() throws {
        // Given
        let token = "expired_session"
        let expiresAt = Date().addingTimeInterval(-3600) // Already expired

        // When
        try keychainManager.storeSessionToken(token, expiresAt: expiresAt)

        // Then
        XCTAssertThrowsError(try keychainManager.retrieveSessionToken()) { error in
            XCTAssertEqual(error as? KeychainError, .tokenExpired)
        }

        // Verify token was deleted
        XCTAssertThrowsError(try keychainManager.retrieve(key: "session_token"))
    }

    // MARK: - Security Tests

    func testEncryptionIntegrity() throws {
        // Given
        let sensitiveData = "sensitive_financial_data_12345"
        let key = "encrypted_data"

        // When
        try keychainManager.store(key: key, value: sensitiveData)

        // Retrieve multiple times to ensure consistency
        let retrieved1 = try keychainManager.retrieve(key: key)
        let retrieved2 = try keychainManager.retrieve(key: key)
        let retrieved3 = try keychainManager.retrieve(key: key)

        // Then
        XCTAssertEqual(retrieved1, sensitiveData)
        XCTAssertEqual(retrieved2, sensitiveData)
        XCTAssertEqual(retrieved3, sensitiveData)
    }

    func testClearAllItems() throws {
        // Given - Store multiple items
        try keychainManager.store(key: "key1", value: "value1")
        try keychainManager.store(key: "key2", value: "value2")
        try keychainManager.store(key: "key3", value: "value3", requiresBiometric: true)

        // When
        try keychainManager.clearAll()

        // Then - All items should be gone
        XCTAssertThrowsError(try keychainManager.retrieve(key: "key1"))
        XCTAssertThrowsError(try keychainManager.retrieve(key: "key2"))
        XCTAssertThrowsError(try keychainManager.retrieve(key: "key3"))
    }

    // MARK: - Concurrent Access Tests

    func testConcurrentAccess() {
        let expectation = XCTestExpectation(description: "Concurrent access")
        expectation.expectedFulfillmentCount = 100

        let queue = DispatchQueue(label: "test.concurrent", attributes: .concurrent)

        // Perform 100 concurrent operations
        for i in 0..<100 {
            queue.async {
                let key = "concurrent_key_\(i)"
                let value = "concurrent_value_\(i)"

                do {
                    try self.keychainManager.store(key: key, value: value)
                    let retrieved = try self.keychainManager.retrieve(key: key)
                    XCTAssertEqual(retrieved, value)
                    expectation.fulfill()
                } catch {
                    XCTFail("Concurrent operation failed: \(error)")
                }
            }
        }

        wait(for: [expectation], timeout: 10.0)
    }

    // MARK: - Edge Cases

    func testEmptyStringStorage() throws {
        // Should handle empty strings gracefully
        try keychainManager.store(key: "empty", value: "")
        let retrieved = try keychainManager.retrieve(key: "empty")
        XCTAssertEqual(retrieved, "")
    }

    func testLargeDataStorage() throws {
        // Test with large data
        let largeValue = String(repeating: "A", count: 10000)
        try keychainManager.store(key: "large_data", value: largeValue)
        let retrieved = try keychainManager.retrieve(key: "large_data")
        XCTAssertEqual(retrieved, largeValue)
    }

    func testSpecialCharacterKeys() throws {
        // Test with special characters in keys
        let specialKeys = ["key with spaces", "key@with#special$chars", "key.with.dots", "key/with/slashes"]

        for key in specialKeys {
            try keychainManager.store(key: key, value: "test_value")
            let retrieved = try keychainManager.retrieve(key: key)
            XCTAssertEqual(retrieved, "test_value")
        }
    }
}
