// SANDBOX FILE: For testing/development. See .cursorrules.

import Foundation
import Combine

// Using a simple keychain wrapper instead of KeychainSwift for Sandbox
class SimpleKeychain {
    func set(_ value: String, forKey key: String) {
        UserDefaults.standard.set(value, forKey: "keychain_\(key)")
    }
    
    func get(_ key: String) -> String? {
        return UserDefaults.standard.string(forKey: "keychain_\(key)")
    }
    
    func delete(_ key: String) {
        UserDefaults.standard.removeObject(forKey: "keychain_\(key)")
    }
}

/*
 * Purpose: Basiq API integration for Australian bank account connectivity and transaction sync
 * Issues & Complexity Summary: Complex OAuth flow, secure token management, real-time sync
 * Key Complexity Drivers:
   - Logic Scope (Est. LoC): ~500
   - Core Algorithm Complexity: High (OAuth, API integration, error handling)
   - Dependencies: Foundation, Combine, KeychainSwift, URLSession
   - State Management Complexity: High (authentication state, sync status)
   - Novelty/Uncertainty Factor: High (External API integration, Australian banking)
 * AI Pre-Task Self-Assessment: 78%
 * Problem Estimate: 85%
 * Initial Code Complexity Estimate: 82%
 * Final Code Complexity: TBD
 * Overall Result Score: TBD
 * Key Variances/Learnings: TBD
 * Last Updated: 2025-08-08
 */

// MARK: - Basiq API Models

struct BasiqAuthResponse: Codable {
    let accessToken: String
    let refreshToken: String?
    let expiresIn: Int
    let tokenType: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
        case tokenType = "token_type"
    }
}

struct BasiqInstitution: Codable, Identifiable {
    let id: String
    let name: String
    let shortName: String
    let institutionType: String
    let country: String
    let serviceName: String
    let serviceType: String
    let loginIdCaption: String?
    let passwordCaption: String?
    let tier: String
    let authorization: BasiqInstitutionAuth
}

struct BasiqInstitutionAuth: Codable {
    let adr: Bool
    let credentials: [BasiqCredential]
}

struct BasiqCredential: Codable {
    let id: String
    let name: String
    let type: String
    let label: String
    let encrypted: Bool
    let optional: Bool
}

struct BasiqConnection: Codable, Identifiable {
    let id: String
    let status: String
    let lastUsed: String?
    let institution: BasiqInstitution
    let accounts: [BasiqAccount]?
}

struct BasiqAccount: Codable, Identifiable {
    let id: String
    let name: String
    let accountNo: String?
    let balance: String
    let availableBalance: String?
    let type: String
    let subType: String?
    let class: String
    let product: String?
    let currency: String
    let lastUpdated: String
}

struct BasiqTransaction: Codable, Identifiable {
    let id: String
    let status: String
    let description: String
    let amount: String
    let account: String
    let balance: String?
    let direction: String
    let class: String
    let institution: String
    let connection: String
    let enrich: BasiqEnrichment?
    let postDate: String
    let transactionDate: String?
    let subClass: BasiqSubClass?
}

struct BasiqEnrichment: Codable {
    let merchant: BasiqMerchant?
    let location: BasiqLocation?
    let category: BasiqCategory?
}

struct BasiqMerchant: Codable {
    let businessName: String?
    let website: String?
    let phoneNumber: String?
}

struct BasiqLocation: Codable {
    let latitude: Double?
    let longitude: Double?
    let address: String?
    let suburb: String?
    let state: String?
    let postcode: String?
}

struct BasiqCategory: Codable {
    let anzsic: BasiqANZSIC?
}

struct BasiqANZSIC: Codable {
    let division: String?
    let subdivision: String?
    let group: String?
    let class: String?
}

struct BasiqSubClass: Codable {
    let code: String
    let title: String
}

struct BasiqError: Codable, Error {
    let correlationId: String?
    let data: [BasiqErrorData]?
    
    struct BasiqErrorData: Codable {
        let code: String
        let title: String
        let detail: String
        let source: BasiqErrorSource?
    }
    
    struct BasiqErrorSource: Codable {
        let parameter: String?
        let pointer: String?
    }
}

// MARK: - Basiq API Service

@MainActor
class BasiqAPIService: ObservableObject {
    
    // MARK: - Properties
    
    @Published var isAuthenticated = false
    @Published var isConnecting = false
    @Published var connectionStatus: ConnectionStatus = .disconnected
    @Published var availableInstitutions: [BasiqInstitution] = []
    @Published var userConnections: [BasiqConnection] = []
    @Published var lastSyncDate: Date?
    @Published var errorMessage: String?
    
    private let keychain = SimpleKeychain()
    private let session = URLSession.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Configuration
    
    private let baseURL = "https://au-api.basiq.io"
    private let apiVersion = "3.0"
    private let clientId: String
    private let clientSecret: String
    
    // Keychain keys
    private let accessTokenKey = "basiq_access_token"
    private let refreshTokenKey = "basiq_refresh_token"
    private let tokenExpiryKey = "basiq_token_expiry"
    
    enum ConnectionStatus {
        case disconnected
        case connecting
        case connected
        case syncing
        case error(String)
    }
    
    // MARK: - Initialization
    
    init() {
        // Load from environment or configuration
        self.clientId = ProcessInfo.processInfo.environment["BASIQ_CLIENT_ID"] ?? ""
        self.clientSecret = ProcessInfo.processInfo.environment["BASIQ_CLIENT_SECRET"] ?? ""
        
        // Check for existing authentication
        checkExistingAuthentication()
        
        #if DEBUG
        if clientId.isEmpty || clientSecret.isEmpty {
            print("⚠️ BASIQ API: Client credentials not configured")
        }
        #endif
    }
    
    // MARK: - Authentication
    
    func authenticate() async throws {
        guard !clientId.isEmpty && !clientSecret.isEmpty else {
            throw BasiqAPIError.missingCredentials
        }
        
        let url = URL(string: "\(baseURL)/token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("Basic \(basicAuthHeader())", forHTTPHeaderField: "Authorization")
        request.setValue(apiVersion, forHTTPHeaderField: "basiq-version")
        
        let body = "grant_type=client_credentials&scope=SERVER_ACCESS"
        request.httpBody = body.data(using: .utf8)
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw BasiqAPIError.invalidResponse
            }
            
            if httpResponse.statusCode == 200 {
                let authResponse = try JSONDecoder().decode(BasiqAuthResponse.self, from: data)
                await storeTokens(authResponse)
                await MainActor.run {
                    self.isAuthenticated = true
                    self.connectionStatus = .connected
                }
            } else {
                let error = try? JSONDecoder().decode(BasiqError.self, from: data)
                throw BasiqAPIError.authenticationFailed(error?.data?.first?.detail ?? "Unknown error")
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.connectionStatus = .error(error.localizedDescription)
            }
            throw error
        }
    }
    
    private func basicAuthHeader() -> String {
        let credentials = "\(clientId):\(clientSecret)"
        let credentialsData = credentials.data(using: .utf8)!
        return credentialsData.base64EncodedString()
    }
    
    private func storeTokens(_ authResponse: BasiqAuthResponse) async {
        keychain.set(authResponse.accessToken, forKey: accessTokenKey)
        if let refreshToken = authResponse.refreshToken {
            keychain.set(refreshToken, forKey: refreshTokenKey)
        }
        
        let expiryDate = Date().addingTimeInterval(TimeInterval(authResponse.expiresIn))
        keychain.set(expiryDate.timeIntervalSince1970.description, forKey: tokenExpiryKey)
    }
    
    private func checkExistingAuthentication() {
        guard let token = keychain.get(accessTokenKey),
              let expiryString = keychain.get(tokenExpiryKey),
              let expiryInterval = Double(expiryString) else {
            return
        }
        
        let expiryDate = Date(timeIntervalSince1970: expiryInterval)
        if expiryDate > Date() {
            isAuthenticated = true
            connectionStatus = .connected
        } else {
            // Token expired, clear stored tokens
            clearTokens()
        }
    }
    
    private func clearTokens() {
        keychain.delete(accessTokenKey)
        keychain.delete(refreshTokenKey)
        keychain.delete(tokenExpiryKey)
        isAuthenticated = false
        connectionStatus = .disconnected
    }
    
    // MARK: - API Requests
    
    private func authenticatedRequest(url: URL, method: String = "GET", body: Data? = nil) throws -> URLRequest {
        guard let token = keychain.get(accessTokenKey) else {
            throw BasiqAPIError.notAuthenticated
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue(apiVersion, forHTTPHeaderField: "basiq-version")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let body = body {
            request.httpBody = body
        }
        
        return request
    }
    
    // MARK: - Institutions
    
    func fetchInstitutions() async throws {
        await MainActor.run {
            self.connectionStatus = .connecting
        }
        
        let url = URL(string: "\(baseURL)/institutions")!
        let request = try authenticatedRequest(url: url)
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw BasiqAPIError.invalidResponse
            }
            
            if httpResponse.statusCode == 200 {
                let institutionsResponse = try JSONDecoder().decode(BasiqInstitutionsResponse.self, from: data)
                await MainActor.run {
                    self.availableInstitutions = institutionsResponse.data
                    self.connectionStatus = .connected
                }
            } else {
                let error = try? JSONDecoder().decode(BasiqError.self, from: data)
                throw BasiqAPIError.requestFailed(error?.data?.first?.detail ?? "Failed to fetch institutions")
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.connectionStatus = .error(error.localizedDescription)
            }
            throw error
        }
    }
    
    // MARK: - Connections
    
    func createConnection(institutionId: String, loginId: String, password: String) async throws -> String {
        await MainActor.run {
            self.isConnecting = true
            self.connectionStatus = .connecting
        }
        
        let url = URL(string: "\(baseURL)/users/temp/connections")!
        
        let connectionData: [String: Any] = [
            "institution": ["id": institutionId],
            "loginId": loginId,
            "password": password
        ]
        
        let body = try JSONSerialization.data(withJSONObject: connectionData)
        let request = try authenticatedRequest(url: url, method: "POST", body: body)
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw BasiqAPIError.invalidResponse
            }
            
            if httpResponse.statusCode == 201 || httpResponse.statusCode == 202 {
                let connectionResponse = try JSONDecoder().decode(BasiqConnectionResponse.self, from: data)
                await MainActor.run {
                    self.isConnecting = false
                    self.connectionStatus = .connected
                }
                return connectionResponse.id
            } else {
                let error = try? JSONDecoder().decode(BasiqError.self, from: data)
                throw BasiqAPIError.connectionFailed(error?.data?.first?.detail ?? "Failed to create connection")
            }
        } catch {
            await MainActor.run {
                self.isConnecting = false
                self.errorMessage = error.localizedDescription
                self.connectionStatus = .error(error.localizedDescription)
            }
            throw error
        }
    }
    
    func fetchConnections() async throws {
        let url = URL(string: "\(baseURL)/users/temp/connections")!
        let request = try authenticatedRequest(url: url)
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw BasiqAPIError.invalidResponse
            }
            
            if httpResponse.statusCode == 200 {
                let connectionsResponse = try JSONDecoder().decode(BasiqConnectionsResponse.self, from: data)
                await MainActor.run {
                    self.userConnections = connectionsResponse.data
                }
            } else {
                let error = try? JSONDecoder().decode(BasiqError.self, from: data)
                throw BasiqAPIError.requestFailed(error?.data?.first?.detail ?? "Failed to fetch connections")
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
            throw error
        }
    }
    
    // MARK: - Transactions
    
    func fetchTransactions(for connectionId: String, limit: Int = 500) async throws -> [BasiqTransaction] {
        await MainActor.run {
            self.connectionStatus = .syncing
        }
        
        let url = URL(string: "\(baseURL)/users/temp/transactions?filter=connection.id.eq('\(connectionId)')&limit=\(limit)")!
        let request = try authenticatedRequest(url: url)
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw BasiqAPIError.invalidResponse
            }
            
            if httpResponse.statusCode == 200 {
                let transactionsResponse = try JSONDecoder().decode(BasiqTransactionsResponse.self, from: data)
                await MainActor.run {
                    self.connectionStatus = .connected
                    self.lastSyncDate = Date()
                }
                return transactionsResponse.data
            } else {
                let error = try? JSONDecoder().decode(BasiqError.self, from: data)
                throw BasiqAPIError.requestFailed(error?.data?.first?.detail ?? "Failed to fetch transactions")
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.connectionStatus = .error(error.localizedDescription)
            }
            throw error
        }
    }
    
    // MARK: - Background Sync
    
    func performBackgroundSync() async {
        guard isAuthenticated else {
            try? await authenticate()
            return
        }
        
        do {
            try await fetchConnections()
            
            for connection in userConnections {
                let transactions = try await fetchTransactions(for: connection.id)
                // Process and store transactions locally
                await processTransactions(transactions, for: connection)
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Background sync failed: \(error.localizedDescription)"
            }
        }
    }
    
    private func processTransactions(_ transactions: [BasiqTransaction], for connection: BasiqConnection) async {
        // Convert Basiq transactions to local Transaction model
        // This would integrate with Core Data to store locally
        // Implementation would depend on the existing Transaction model
        
        #if DEBUG
        print("📊 BASIQ: Processing \(transactions.count) transactions for \(connection.institution.name)")
        #endif
        
        // TODO: Implement Core Data integration
        // - Map BasiqTransaction to local Transaction model
        // - Handle duplicate detection
        // - Update local database
        // - Trigger UI refresh
    }
}

// MARK: - Response Models

private struct BasiqInstitutionsResponse: Codable {
    let data: [BasiqInstitution]
}

private struct BasiqConnectionResponse: Codable {
    let id: String
}

private struct BasiqConnectionsResponse: Codable {
    let data: [BasiqConnection]
}

private struct BasiqTransactionsResponse: Codable {
    let data: [BasiqTransaction]
}

// MARK: - Error Types

enum BasiqAPIError: LocalizedError {
    case missingCredentials
    case notAuthenticated
    case invalidResponse
    case authenticationFailed(String)
    case connectionFailed(String)
    case requestFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .missingCredentials:
            return "Basiq API credentials are not configured"
        case .notAuthenticated:
            return "Not authenticated with Basiq API"
        case .invalidResponse:
            return "Invalid response from Basiq API"
        case .authenticationFailed(let message):
            return "Authentication failed: \(message)"
        case .connectionFailed(let message):
            return "Connection failed: \(message)"
        case .requestFailed(let message):
            return "Request failed: \(message)"
        }
    }
}

// MARK: - Preview Support

#if DEBUG
extension BasiqAPIService {
    static let preview: BasiqAPIService = {
        let service = BasiqAPIService()
        service.isAuthenticated = true
        service.connectionStatus = .connected
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
                authorization: BasiqInstitutionAuth(
                    adr: true,
                    credentials: []
                )
            )
        ]
        return service
    }()
}
#endif
