import XCTest
import Combine
@testable import FinanceMate

final class BasiqSyncManagerTests: XCTestCase {

    var syncManager: BasiqSyncManager!
    var mockAPIClient: MockBasiqAPIClient!
    var mockAuthManager: MockBasiqAuthManager!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockAuthManager = MockBasiqAuthManager()
        mockAPIClient = MockBasiqAPIClient()
        syncManager = BasiqSyncManager(apiClient: mockAPIClient, authManager: mockAuthManager)
        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() {
        syncManager = nil
        mockAPIClient = nil
        mockAuthManager = nil
        cancellables = nil
        super.tearDown()
    }

    func testPerformBackgroundSync_Success() async throws {
        mockAuthManager.setupValidToken()
        mockAPIClient.setupMockData()

        await syncManager.performBackgroundSync()

        XCTAssertEqual(mockAPIClient.fetchConnectionsCallCount, 1)
        XCTAssertGreaterThanOrEqual(mockAPIClient.fetchTransactionsCallCount, 1)
    }

    func testPerformBackgroundSync_Unauthenticated() async throws {
        mockAuthManager.setupInvalidToken()

        await syncManager.performBackgroundSync()

        XCTAssertEqual(mockAPIClient.fetchConnectionsCallCount, 0)
    }

    func testSyncStatus_UpdatesCorrectly() async throws {
        mockAuthManager.setupValidToken()
        mockAPIClient.setupMockData()

        var statusUpdates: [BasiqConnectionStatus] = []

        syncManager.syncStatusPublisher
            .sink { status in
                statusUpdates.append(status)
            }
            .store(in: &cancellables)

        await syncManager.performBackgroundSync()

        XCTAssertFalse(statusUpdates.isEmpty)
    }
}

class MockBasiqAPIClient: BasiqAPIClient {
    var fetchConnectionsCallCount = 0
    var fetchTransactionsCallCount = 0

    func setupMockData() {
        // Setup mock data for testing
    }

    override func fetchConnections() async throws -> [BasiqConnection] {
        fetchConnectionsCallCount += 1
        return [
            BasiqConnection(
                id: "test-connection-1",
                institution: BasiqInstitution(
                    id: "AU00000",
                    name: "Test Bank",
                    shortName: "TB",
                    institutionType: "bank",
                    country: "AU",
                    serviceName: "Test Service",
                    serviceType: "personal",
                    loginIdCaption: "User ID",
                    passwordCaption: "Password",
                    tier: "1",
                    authorization: BasiqInstitutionAuth(adr: true, credentials: [])
                ),
                status: "OK",
                createdDate: "2025-01-01",
                updatedDate: "2025-01-01"
            )
        ]
    }

    override func fetchTransactions(for connectionId: String) async throws -> [BasiqTransaction] {
        fetchTransactionsCallCount += 1
        return [
            BasiqTransaction(
                id: "test-transaction-1",
                type: "transaction",
                status: "posted",
                description: "Test Transaction",
                amount: "100.00",
                currency: "AUD",
                postDate: "2025-01-01"
            )
        ]
    }
}