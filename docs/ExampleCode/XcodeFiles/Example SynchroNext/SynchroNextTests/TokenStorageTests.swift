// Purpose: Production test suite for TokenStorage with comprehensive secure storage testing.
// Issues & Complexity: Extensive tests for token storage, handling, and security.
// Ranking/Rating: 95% (Code), 92% (Problem) - Premium test suite for secure token storage in _macOS.

import XCTest
@testable import SynchroNext

/// Comprehensive test suite for TokenStorage ensuring full functionality and security of token management.
class TokenStorageTests: XCTestCase {
    
    // MARK: - Properties
    
    var tokenStorage: TokenStorage!
    let testToken = "test_token_1234567890"
    let testServiceName = "com.synchronext.test"
    
    // MARK: - Setup and Teardown
    
    override func setUp() {
        super.setUp()
        print("[TokenStorageTests.setUp] STARTING setup")
        // Use the correct argument label for TokenStorage
        tokenStorage = TokenStorage(service: testServiceName)
        // Ensure a clean state for the test service before each test
        // tokenStorage.clearAllTokens() // Commenting out to isolate issues
        print("[TokenStorageTests.setUp] FINISHED setup")
    }
    
    override func tearDown() {
        print("[TokenStorageTests.tearDown] STARTING tearDown")
        // It's good practice to clean up, but let's ensure this runs first
        // tokenStorage.clearAllTokens() // Ensure cleanup for the specific service after each test
        super.tearDown()
        print("[TokenStorageTests.tearDown] FINISHED tearDown")
    }
    
    // MARK: - Initialization Tests
    
    func testInitialization() {
        // Test initialization with default service name
        let defaultStorage = TokenStorage()
        XCTAssertNotNil(defaultStorage, "TokenStorage should initialize with default service name")
        
        // Test initialization with custom service name
        let customStorage = TokenStorage(service: "com.synchronext.custom")
        XCTAssertNotNil(customStorage, "TokenStorage should initialize with custom service name")
    }
    
    // MARK: - Token Storage Tests (Refactored)
    
    func testTokenStorageAndRetrieval() {
        // Store a token
        let key = "test_user_id"
        XCTAssertTrue(tokenStorage.storeToken(testToken, forKey: key), "Token storage should succeed")
        // Retrieve the token
        let retrievedToken = tokenStorage.getToken(forKey: key)
        // Verify
        XCTAssertNotNil(retrievedToken, "Retrieved token should not be nil")
        XCTAssertEqual(retrievedToken, testToken, "Retrieved token should match stored token")
    }
    
    func testTokenRemoval() {
        let key = "test_user_id"
        XCTAssertTrue(tokenStorage.storeToken(testToken, forKey: key), "Token storage should succeed")
        XCTAssertNotNil(tokenStorage.getToken(forKey: key), "Token should be stored")
        tokenStorage.deleteToken(forKey: key)
        XCTAssertNil(tokenStorage.getToken(forKey: key), "Token should be removed")
    }
    
    func testReplaceExistingToken() {
        let key = "test_user_id"
        XCTAssertTrue(tokenStorage.storeToken("initial_token", forKey: key), "Initial token storage should succeed")
        XCTAssertTrue(tokenStorage.storeToken("new_token", forKey: key), "Replacement token storage should succeed")
        let retrievedToken = tokenStorage.getToken(forKey: key)
        XCTAssertNotNil(retrievedToken, "Retrieved token should not be nil")
        XCTAssertEqual(retrievedToken, "new_token", "Retrieved token should match replaced token")
        XCTAssertNotEqual(retrievedToken, "initial_token", "Retrieved token should not match initial token")
    }
    
    func testClearAllTokens() {
        print("[TokenStorageTests.testClearAllTokens] TEST ENTRY POINT - START")
        let key1 = "testKey1ForClear"
        let value1 = "testToken1ForClear"
        let key2 = "testKey2ForClear"
        let value2 = "testToken2ForClear"

        // Ensure tokens are initially not present or clear them if they are (from previous runs)
        print("[TokenStorageTests.testClearAllTokens] Initial cleanup for key1.")
        tokenStorage.deleteToken(forKey: key1)
        print("[TokenStorageTests.testClearAllTokens] Initial cleanup for key2.")
        tokenStorage.deleteToken(forKey: key2)

        // Save some tokens specifically for this test
        print("[TokenStorageTests.testClearAllTokens] Saving token for key1: \\(key1)")
        let saveStatus1 = tokenStorage.storeToken(value1, forKey: key1)
        print("[TokenStorageTests.testClearAllTokens] Save status for key1: \\(saveStatus1)")
        XCTAssertTrue(saveStatus1, "Should be able to save token1 for clear test")

        print("[TokenStorageTests.testClearAllTokens] Saving token for key2: \\(key2)")
        let saveStatus2 = tokenStorage.storeToken(value2, forKey: key2)
        print("[TokenStorageTests.testClearAllTokens] Save status for key2: \\(saveStatus2)")
        XCTAssertTrue(saveStatus2, "Should be able to save token2 for clear test")

        // Verify they are saved
        let retrievedToken1BeforeClear = tokenStorage.getToken(forKey: key1)
        print("[TokenStorageTests.testClearAllTokens] Token for key1 BEFORE clear: \\(retrievedToken1BeforeClear ?? \"nil\")")
        XCTAssertEqual(retrievedToken1BeforeClear, value1, "Token1 should be present before clear")

        let retrievedToken2BeforeClear = tokenStorage.getToken(forKey: key2)
        print("[TokenStorageTests.testClearAllTokens] Token for key2 BEFORE clear: \\(retrievedToken2BeforeClear ?? \"nil\")")
        XCTAssertEqual(retrievedToken2BeforeClear, value2, "Token2 should be present before clear")

        // Clear all tokens
        print("[TokenStorageTests.testClearAllTokens] Calling clearAllTokens().")
        let clearResult = tokenStorage.clearAllTokens()
        print("[TokenStorageTests.testClearAllTokens] clearAllTokens() result: \\(clearResult)")
        XCTAssertTrue(clearResult, "clearAllTokens() should return true.")

        // Verify that the tokens are actually cleared
        let retrievedToken1AfterClear = tokenStorage.getToken(forKey: key1)
        print("[TokenStorageTests.testClearAllTokens] Token for key1 AFTER clear: \\(retrievedToken1AfterClear ?? \"nil\")")
        if retrievedToken1AfterClear != nil {
            print("!!!UNEXPECTED: Token for key1 ('\\(key1)') was found after clearAllTokens: '\\(retrievedToken1AfterClear!)'")
        }
        XCTAssertNil(retrievedToken1AfterClear, "Token for key1 should be nil after clearing all tokens.")

        let retrievedToken2AfterClear = tokenStorage.getToken(forKey: key2)
        print("[TokenStorageTests.testClearAllTokens] Token for key2 AFTER clear: \\(retrievedToken2AfterClear ?? \"nil\")")
        if retrievedToken2AfterClear != nil {
            print("!!!UNEXPECTED: Token for key2 ('\\(key2)') was found after clearAllTokens: '\\(retrievedToken2AfterClear!)'")
        }
        XCTAssertNil(retrievedToken2AfterClear, "Token for key2 should be nil after clearing all tokens.")
        
        print("[TokenStorageTests.testClearAllTokens] Test finished.")
    }
    
    func testCustomServiceName() {
        // Use the correct argument label for TokenStorage
        let customStorage = TokenStorage(service: "com.synchronext.custom")
        let key = "test_user_id"
        XCTAssertTrue(customStorage.storeToken(testToken, forKey: key))
        let retrieved = customStorage.getToken(forKey: key)
        XCTAssertEqual(retrieved, testToken)
        XCTAssertTrue(customStorage.clearAllTokens())
        XCTAssertNil(customStorage.getToken(forKey: key))
    }
} 