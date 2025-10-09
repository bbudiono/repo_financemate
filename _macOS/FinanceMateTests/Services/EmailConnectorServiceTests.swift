import XCTest
import CoreData
@testable import FinanceMate

/// Test suite for EmailConnectorService
/// Validates Gmail functionality consolidation and service integration
class EmailConnectorServiceTests: XCTestCase {
    var emailConnectorService: EmailConnectorService!
    var mockAPIService: MockGmailAPIService!
    var mockCacheService: MockEmailCacheService!
    var mockCoreDataManager: MockCoreDataManager!
    var testContext: NSManagedObjectContext!

    override func setUpWithError() throws {
        try super.setUpWithError()

        // Create test Core Data context
        testContext = createTestContext()

        // Create mock services
        mockAPIService = MockGmailAPIService()
        mockCacheService = MockEmailCacheService()
        mockCoreDataManager = MockCoreDataManager(context: testContext)

        // Create service with mocks
        emailConnectorService = EmailConnectorService(
            apiService: mockAPIService,
            cacheService: mockCacheService,
            coreDataManager: mockCoreDataManager
        )
    }

    override func tearDownWithError() throws {
        emailConnectorService = nil
        mockAPIService = nil
        mockCacheService = nil
        mockCoreDataManager = nil
        testContext = nil
        try super.tearDownWithError()
    }

    // MARK: - Authentication Tests

    func testCheckAuthentication_Authenticated_ReturnsTrue() async throws {
        // Given
        mockAPIService.isAuthenticated = true

        // When
        let result = await emailConnectorService.checkAuthentication()

        // Then
        XCTAssertTrue(result)
        XCTAssertTrue(mockAPIService.checkAuthenticationCalled)
    }

    func testCheckAuthentication_NotAuthenticated_ReturnsFalse() async throws {
        // Given
        mockAPIService.isAuthenticated = false

        // When
        let result = await emailConnectorService.checkAuthentication()

        // Then
        XCTAssertFalse(result)
        XCTAssertTrue(mockAPIService.checkAuthenticationCalled)
    }

    func testAuthenticate_ValidCode_CallsAPIService() async throws {
        // Given
        let authCode = "test_auth_code"

        // When
        try await emailConnectorService.authenticate(with: authCode)

        // Then
        XCTAssertTrue(mockAPIService.authenticateCalled)
        XCTAssertEqual(mockAPIService.lastAuthCode, authCode)
    }

    func testAuthenticate_InvalidCode_ThrowsError() async throws {
        // Given
        let authCode = "invalid_code"
        mockAPIService.shouldThrowAuthError = true

        // When & Then
        do {
            try await emailConnectorService.authenticate(with: authCode)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is OAuthError)
            XCTAssertTrue(mockAPIService.authenticateCalled)
        }
    }

    // MARK: - Email Fetching Tests

    func testFetchEmails_CacheHit_ReturnsCachedEmails() async throws {
        // Given
        let cachedEmails = createTestEmails(count: 3)
        mockCacheService.cachedEmails = cachedEmails

        // When
        let result = try await emailConnectorService.fetchEmails()

        // Then
        XCTAssertEqual(result.count, 3)
        XCTAssertTrue(mockCacheService.loadCachedEmailsCalled)
        XCTAssertFalse(mockAPIService.fetchEmailsCalled)
    }

    func testFetchEmails_CacheMiss_FetchesFromAPI() async throws {
        // Given
        let apiEmails = createTestEmails(count: 5)
        mockCacheService.cachedEmails = nil
        mockAPIService.emailsToReturn = apiEmails

        // When
        let result = try await emailConnectorService.fetchEmails()

        // Then
        XCTAssertEqual(result.count, 5)
        XCTAssertTrue(mockCacheService.loadCachedEmailsCalled)
        XCTAssertTrue(mockAPIService.fetchEmailsCalled)
        XCTAssertTrue(mockCacheService.saveEmailsToCacheCalled)
        XCTAssertEqual(mockCacheService.savedEmails?.count, 5)
    }

    func testFetchEmails_APIError_ThrowsError() async throws {
        // Given
        mockCacheService.cachedEmails = nil
        mockAPIService.shouldThrowFetchError = true

        // When & Then
        do {
            _ = try await emailConnectorService.fetchEmails()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is GmailAPIError)
            XCTAssertTrue(mockAPIService.fetchEmailsCalled)
        }
    }

    // MARK: - Transaction Extraction Tests

    func testExtractTransactions_ValidEmails_ReturnsTransactions() {
        // Given
        let emails = createTestEmails(count: 2)
        let expectedTransactions = createTestTransactions(count: 4)
        mockAPIService.transactionsToReturn = expectedTransactions

        // When
        let result = emailConnectorService.extractTransactions(from: emails)

        // Then
        XCTAssertEqual(result.count, 4)
        XCTAssertTrue(mockAPIService.extractTransactionsCalled)
    }

    // MARK: - Transaction Saving Tests

    func testSaveTransaction_ValidTransaction_SavesSuccessfully() async throws {
        // Given
        let transaction = createTestTransactions(count: 1).first!
        mockCoreDataManager.shouldSucceedSave = true

        // When
        let result = try await emailConnectorService.saveTransaction(transaction)

        // Then
        XCTAssertTrue(result)
        XCTAssertTrue(mockCoreDataManager.saveTransactionCalled)
    }

    func testSaveTransaction_SaveError_ThrowsError() async throws {
        // Given
        let transaction = createTestTransactions(count: 1).first!
        mockCoreDataManager.shouldSucceedSave = false

        // When & Then
        do {
            _ = try await emailConnectorService.saveTransaction(transaction)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is CoreDataError)
            XCTAssertTrue(mockCoreDataManager.saveTransactionCalled)
        }
    }

    func testSaveTransactions_MultipleTransactions_SavesCorrectCount() async throws {
        // Given
        let transactions = createTestTransactions(count: 3)
        mockCoreDataManager.savedCount = 2

        // When
        let result = try await emailConnectorService.saveTransactions(transactions)

        // Then
        XCTAssertEqual(result, 2)
        XCTAssertTrue(mockCoreDataManager.saveTransactionsCalled)
    }

    // MARK: - Utility Tests

    func testClearCache_CallsCacheService() {
        // When
        emailConnectorService.clearCache()

        // Then
        XCTAssertTrue(mockCacheService.clearCacheCalled)
    }

    func testIsAuthenticated_ReturnsAPIServiceStatus() {
        // Given
        mockAPIService.isAuthenticated = true

        // When
        let result = emailConnectorService.isAuthenticated

        // Then
        XCTAssertTrue(result)
    }

    // MARK: - Helper Methods

    private func createTestContext() -> NSManagedObjectContext {
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: NSManagedObjectModel())
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = persistentStoreCoordinator
        return context
    }

    private func createTestEmails(count: Int) -> [GmailEmail] {
        return (0..<count).map { index in
            GmailEmail(
                id: "email_\(index)",
                subject: "Test Email \(index)",
                sender: "test\(index)@example.com",
                date: Date(),
                snippet: "Test content \(index)"
            )
        }
    }

    private func createTestTransactions(count: Int) -> [ExtractedTransaction] {
        return (0..<count).map { index in
            ExtractedTransaction(
                merchant: "Merchant \(index)",
                amount: Double(index + 1) * 10.0,
                date: Date(),
                category: "Test Category",
                confidence: 0.8
            )
        }
    }
}

// MARK: - Mock Classes

class MockGmailAPIService: GmailAPIService {
    var isAuthenticated = false
    var checkAuthenticationCalled = false
    var authenticateCalled = false
    var lastAuthCode = ""
    var shouldThrowAuthError = false
    var fetchEmailsCalled = false
    var shouldThrowFetchError = false
    var emailsToReturn: [GmailEmail] = []
    var extractTransactionsCalled = false
    var transactionsToReturn: [ExtractedTransaction] = []

    override func checkAuthentication() async -> Bool {
        checkAuthenticationCalled = true
        return isAuthenticated
    }

    override func authenticate(with authCode: String) async throws {
        authenticateCalled = true
        lastAuthCode = authCode
        if shouldThrowAuthError {
            throw OAuthError.authenticationFailed("Mock error")
        }
    }

    override func fetchEmails(maxResults: Int = 500) async throws -> [GmailEmail] {
        fetchEmailsCalled = true
        if shouldThrowFetchError {
            throw GmailAPIError.invalidURL("Mock error")
        }
        return emailsToReturn
    }

    override func extractTransactions(from email: GmailEmail) -> [ExtractedTransaction] {
        extractTransactionsCalled = true
        return transactionsToReturn
    }
}

class MockEmailCacheService: EmailCacheService {
    var loadCachedEmailsCalled = false
    var saveEmailsToCacheCalled = false
    var clearCacheCalled = false
    var cachedEmails: [GmailEmail]?
    var savedEmails: [GmailEmail]?

    override func loadCachedEmails() -> [GmailEmail]? {
        loadCachedEmailsCalled = true
        return cachedEmails
    }

    override func saveEmailsToCache(_ emails: [GmailEmail]) {
        saveEmailsToCacheCalled = true
        savedEmails = emails
    }

    override func clearCache() {
        clearCacheCalled = true
    }
}

class MockCoreDataManager: CoreDataManager {
    var saveTransactionCalled = false
    var saveTransactionsCalled = false
    var shouldSucceedSave = true
    var savedCount = 0

    override func saveTransaction(_ extractedTransaction: ExtractedTransaction) async throws -> Bool {
        saveTransactionCalled = true
        if shouldSucceedSave {
            return true
        } else {
            throw CoreDataError.saveFailed(NSError(domain: "TestError", code: 1))
        }
    }

    override func saveTransactions(_ transactions: [ExtractedTransaction]) async throws -> Int {
        saveTransactionsCalled = true
        if shouldSucceedSave {
            return savedCount
        } else {
            throw CoreDataError.saveFailed(NSError(domain: "TestError", code: 1))
        }
    }
}