// Purpose: Sandbox test suite for TokenStorage with comprehensive secure storage testing.
// Issues & Complexity: Extensive tests for token storage, handling, and security.
// Ranking/Rating: 95% (Code), 92% (Problem) - Premium test suite for secure token storage in _macOS.
// SANDBOX FILE: For testing/development. See .cursorrules §5.3.1.

import XCTest
@testable import SynchroNext_Sandbox

/// Comprehensive test suite for TokenStorage ensuring full functionality and security of token management.
class SandboxTokenStorageTests: XCTestCase {
    
    // MARK: - Properties
    
    var tokenStorage: TokenStorage!
    let testToken = "test_token_1234567890"
    let testServiceName = "com.synchronext.sandbox.test"
    
    // MARK: - Setup and Teardown
    
    override func setUp() {
        super.setUp()
        // Create a dedicated test instance with a unique service name to avoid conflicts
        tokenStorage = TokenStorage(serviceName: testServiceName)
        
        // Clean up any existing tokens from previous test runs
        tokenStorage.removeToken()
    }
    
    override func tearDown() {
        // Clean up after tests
        tokenStorage.removeToken()
        tokenStorage = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialization() {
        // Test initialization with default service name
        let defaultStorage = TokenStorage()
        XCTAssertNotNil(defaultStorage, "TokenStorage should initialize with default service name")
        
        // Test initialization with custom service name
        let customStorage = TokenStorage(serviceName: "com.synchronext.sandbox.custom")
        XCTAssertNotNil(customStorage, "TokenStorage should initialize with custom service name")
    }
    
    // MARK: - Token Storage Tests
    
    func testTokenStorageAndRetrieval() {
        // Store a token
        XCTAssertNoThrow(try tokenStorage.storeToken(testToken, provider: .apple, userId: "test_user_id"), "Token storage should not throw")
        
        // Retrieve the token
        let retrievedToken = tokenStorage.retrieveToken()
        
        // Verify
        XCTAssertNotNil(retrievedToken, "Retrieved token should not be nil")
        XCTAssertEqual(retrievedToken?.token, testToken, "Retrieved token should match stored token")
        XCTAssertEqual(retrievedToken?.provider, .apple, "Retrieved provider should match stored provider")
        XCTAssertEqual(retrievedToken?.userId, "test_user_id", "Retrieved userId should match stored userId")
    }
    
    func testDifferentProviderTokens() {
        // Store tokens for different providers
        XCTAssertNoThrow(try tokenStorage.storeToken("apple_token", provider: .apple, userId: "apple_user"), "Apple token storage should not throw")
        
        // Simulate Google provider
        let googleProvider: AuthProvider.ProviderType = .google
        XCTAssertNoThrow(try tokenStorage.storeToken("google_token", provider: googleProvider, userId: "google_user"), "Google token storage should not throw")
        
        // Retrieve tokens
        let retrievedToken = tokenStorage.retrieveToken()
        
        // Verify most recent token was retrieved (should be Google)
        XCTAssertNotNil(retrievedToken, "Retrieved token should not be nil")
        XCTAssertEqual(retrievedToken?.token, "google_token", "Retrieved token should match most recent token")
        XCTAssertEqual(retrievedToken?.provider, googleProvider, "Retrieved provider should match most recent provider")
        XCTAssertEqual(retrievedToken?.userId, "google_user", "Retrieved userId should match most recent userId")
    }
    
    func testTokenRemoval() {
        // Store a token
        XCTAssertNoThrow(try tokenStorage.storeToken(testToken, provider: .apple, userId: "test_user_id"), "Token storage should not throw")
        
        // Verify it's stored
        XCTAssertNotNil(tokenStorage.retrieveToken(), "Token should be stored")
        
        // Remove the token
        tokenStorage.removeToken()
        
        // Verify it's removed
        XCTAssertNil(tokenStorage.retrieveToken(), "Token should be removed")
    }
    
    func testReplaceExistingToken() {
        // Store an initial token
        XCTAssertNoThrow(try tokenStorage.storeToken("initial_token", provider: .apple, userId: "initial_user"), "Initial token storage should not throw")
        
        // Replace with a new token
        XCTAssertNoThrow(try tokenStorage.storeToken("new_token", provider: .apple, userId: "new_user"), "Replacement token storage should not throw")
        
        // Retrieve and verify
        let retrievedToken = tokenStorage.retrieveToken()
        
        XCTAssertNotNil(retrievedToken, "Retrieved token should not be nil")
        XCTAssertEqual(retrievedToken?.token, "new_token", "Retrieved token should match replaced token")
        XCTAssertEqual(retrievedToken?.userId, "new_user", "Retrieved userId should match replaced userId")
        XCTAssertNotEqual(retrievedToken?.token, "initial_token", "Retrieved token should not match initial token")
    }
    
    // MARK: - Token Validation Tests
    
    func testTokenValidation() {
        // Test valid tokens
        XCTAssertTrue(tokenStorage.isValidToken("abcdef1234567890"), "Standard alphanumeric token should be valid")
        XCTAssertTrue(tokenStorage.isValidToken("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c"), "JWT token should be valid")
        
        // Test invalid tokens
        XCTAssertFalse(tokenStorage.isValidToken(""), "Empty string should not be valid")
        XCTAssertFalse(tokenStorage.isValidToken("   "), "Whitespace should not be valid")
        XCTAssertFalse(tokenStorage.isValidToken("abc"), "Token that's too short should not be valid")
    }
    
    func testInvalidTokenStorageAttempt() {
        // Test storing invalid tokens throws appropriate errors
        let invalidTokens = ["", "   ", "abc"]
        
        for invalidToken in invalidTokens {
            XCTAssertThrowsError(try tokenStorage.storeToken(invalidToken, provider: .apple, userId: "test_user")) { error in
                guard let storageError = error as? TokenStorageError else {
                    XCTFail("Expected TokenStorageError, got \(error)")
                    return
                }
                
                XCTAssertEqual(storageError, TokenStorageError.invalidToken, "Should throw invalidToken error")
            }
        }
    }
    
    // MARK: - Keychain Security Tests
    
    func testKeyChainSecurity() {
        // Store a token
        XCTAssertNoThrow(try tokenStorage.storeToken(testToken, provider: .apple, userId: "test_user_id"), "Token storage should not throw")
        
        // Try to access the token from a different instance with the same service name (should work)
        let sameServiceStorage = TokenStorage(serviceName: testServiceName)
        let tokenFromSameService = sameServiceStorage.retrieveToken()
        XCTAssertNotNil(tokenFromSameService, "Token should be accessible from same service")
        XCTAssertEqual(tokenFromSameService?.token, testToken, "Token should match across same service instances")
        
        // Try to access the token from a different instance with a different service name (should not work)
        let differentServiceStorage = TokenStorage(serviceName: "com.synchronext.sandbox.different")
        let tokenFromDifferentService = differentServiceStorage.retrieveToken()
        XCTAssertNil(tokenFromDifferentService, "Token should not be accessible from different service")
    }
} 