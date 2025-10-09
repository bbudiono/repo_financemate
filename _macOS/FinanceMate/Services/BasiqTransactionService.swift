import Foundation
import Combine
import os.log

/// Basiq API service for transaction synchronization and connection management
@MainActor
class BasiqTransactionService: ObservableObject {

    @Published var availableInstitutions: [BasiqInstitution] = []
    @Published var userConnections: [BasiqConnection] = []
    @Published var lastSyncDate: Date?
    @Published var isConnecting = false
    @Published var syncStatus: BasiqConnectionStatus = .disconnected
    @Published var errorMessage: String?

    private let apiClient: BasiqAPIClient
    private let syncManager: BasiqSyncManager

    init(authManager: BasiqAuthManager) {
        self.apiClient = BasiqAPIClient(authManager: authManager)
        self.syncManager = BasiqSyncManager(apiClient: apiClient, authManager: authManager)
        setupBindings()
    }

    func fetchInstitutions() async throws {
        syncStatus = .connecting
        do {
            let institutions = try await apiClient.fetchInstitutions()
            availableInstitutions = institutions
            syncStatus = .connected
        } catch {
            errorMessage = error.localizedDescription
            syncStatus = .error(error.localizedDescription)
            throw error
        }
    }

    func createConnection(institutionId: String, loginId: String, password: String) async throws -> String {
        isConnecting = true
        syncStatus = .connecting

        do {
            let connectionId = try await apiClient.createConnection(
                institutionId: institutionId,
                loginId: loginId,
                password: password
            )
            isConnecting = false
            syncStatus = .connected
            return connectionId
        } catch {
            isConnecting = false
            errorMessage = error.localizedDescription
            syncStatus = .error(error.localizedDescription)
            throw error
        }
    }

    func fetchConnections() async throws {
        do {
            let connections = try await apiClient.fetchConnections()
            userConnections = connections
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }

    func fetchTransactions(for connectionId: String, limit: Int = 500) async throws -> [BasiqTransaction] {
        syncStatus = .syncing

        do {
            let transactions = try await apiClient.fetchTransactions(for: connectionId, limit: limit)
            syncStatus = .connected
            lastSyncDate = Date()
            return transactions
        } catch {
            errorMessage = error.localizedDescription
            syncStatus = .error(error.localizedDescription)
            throw error
        }
    }

    func performBackgroundSync() async {
        await syncManager.performBackgroundSync()
    }

    private func setupBindings() {
        syncManager.$syncStatus.assign(to: &$syncStatus)
        syncManager.$lastSyncDate.assign(to: &$lastSyncDate)
        syncManager.$errorMessage.assign(to: &$errorMessage)
    }

    #if DEBUG
    func debugState() -> String {
        return "Institutions: \(availableInstitutions.count), Connections: \(userConnections.count), Status: \(syncStatus.displayString)"
    }
    #endif
}

#if DEBUG
extension BasiqTransactionService {
    static let preview: BasiqTransactionService = {
        let authManager = BasiqAuthManager.preview
        let service = BasiqTransactionService(authManager: authManager)
        service.availableInstitutions = [
            BasiqInstitution(
                id: "AU00000",
                name: "Commonwealth Bank of Australia",
                shortName: "CBA",
                institutionType: "bank",
                country: "AU",
                serviceName: "CommBank",
                serviceType: "personal",
                loginIdCaption: "Client Number",
                passwordCaption: "Password",
                tier: "1",
                authorization: BasiqInstitutionAuth(adr: true, credentials: [])
            )
        ]
        service.syncStatus = .connected
        return service
    }()
}
#endif