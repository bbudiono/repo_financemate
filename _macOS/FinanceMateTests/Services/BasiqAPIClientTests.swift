import XCTest
@testable import FinanceMate

final class BasiqAPIClientTests: XCTestCase {

    var apiClient: BasiqAPIClient!
    var mockAuthManager: MockBasiqAuthManager!

    override func setUp() {
        super.setUp()
        mockAuthManager = MockBasiqAuthManager()
        apiClient = BasiqAPIClient(authManager: mockAuthManager)
    }

    override func tearDown() {
        apiClient = nil
        mockAuthManager = nil
        super.tearDown()
    }

    func testFetchInstitutions_Success() async throws {
        mockAuthManager.setupValidToken()
        let institutions = try await apiClient.fetchInstitutions()
        XCTAssertFalse(institutions.isEmpty)
    }

    func testFetchInstitutions_Unauthenticated() async throws {
        mockAuthManager.setupInvalidToken()
        do {
            _ = try await apiClient.fetchInstitutions()
            XCTFail("Should throw error when not authenticated")
        } catch let error as BasiqAPIError {
            XCTAssertEqual(error, .notAuthenticated)
        }
    }

    func testCreateConnection_Success() async throws {
        mockAuthManager.setupValidToken()
        let connectionId = try await apiClient.createConnection(
            institutionId: "AU00000",
            loginId: "testuser",
            password: "testpass"
        )
        XCTAssertFalse(connectionId.isEmpty)
    }

    func testFetchConnections_Success() async throws {
        mockAuthManager.setupValidToken()
        let connections = try await apiClient.fetchConnections()
        XCTAssertFalse(connections.isEmpty)
    }

    func testFetchTransactions_Success() async throws {
        mockAuthManager.setupValidToken()
        let transactions = try await apiClient.fetchTransactions(for: "test-connection-id")
        XCTAssertFalse(transactions.isEmpty)
    }
}

// MARK: - Mock Classes

class MockBasiqAuthManager: BasiqAuthManager {
    private var validToken = false
    private var mockToken = "mock-bearer-token-12345"

    func setupValidToken() {
        validToken = true
    }

    func setupInvalidToken() {
        validToken = false
    }

    override func getAccessToken() -> String? {
        return validToken ? mockToken : nil
    }

    override var isTokenValid: Bool {
        return validToken
    }
}